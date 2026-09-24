#!/usr/bin/env bash
# odeo-context.sh, the Odeo plugin's SessionStart and SubagentStart hook.
#
# A plugin install has no install.sh step, so nothing writes ~/.claude/CLAUDE.md. This hook
# delivers the same content as context instead, which also means every plugin update
# updates the baseline:
#
#   odeo-context.sh baseline <part> <SessionStart|SubagentStart>
#       Part <part> of the whole global/CLAUDE.md. Claude Code caps each hook's
#       additionalContext at 10,000 characters but measures every hook separately and
#       delivers all of them (code.claude.com/docs/en/hooks), so hooks.json registers one
#       command per part. Parts break at `## ` section boundaries, and a section larger
#       than the budget breaks at line boundaries, so no part is ever over the cap.
#       SubagentStart matters because a dispatched agent (builder, reviewers) does not see
#       the main session's context; with install.sh it read ~/.claude/CLAUDE.md itself.
#       Prints nothing when the user's own global carries the Security Baseline heading.
#   odeo-context.sh language SessionStart
#       Applies the plugin's userConfig `output_language` (the dialog Claude Code shows when
#       the plugin is enabled, and a row in /config; hooks receive it as
#       CLAUDE_PLUGIN_OPTION_OUTPUT_LANGUAGE) to the global setting, but only when that
#       value CHANGES since the last session (state in CLAUDE_PLUGIN_DATA), so a /odeo:language
#       change is never clobbered and the last change wins. On the first run a language
#       that is already set is kept and the difference is named. Without the option (an
#       older client), asks Claude to ask the user once while no global language is set.
#   odeo-context.sh legacy SessionStart
#       While an old install.sh install is still in the home directory (its markers:
#       ~/.claude/odeo-docs, ~/.claude-templates, ~/bin/merge-gate.sh), points at
#       odeo-migrate-legacy.sh, because those copies load every skill and agent twice.
#
# Output is the documented hookSpecificOutput JSON, or nothing. It never blocks a
# session: every valid invocation exits 0, and a broken install is reported in the context
# (and on stderr) instead of failing silently. Exit 2 only for a wiring error (bad args).
#
# CLAUDE_GLOBAL_CONFIG overrides the user global path (same as resolve-language.sh), so
# tests never touch the real $HOME/.claude/CLAUDE.md.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE="$ROOT/global/CLAUDE.md"
LANG_STATUS="$ROOT/bin/language-status.sh"
SET_GLOBAL="$ROOT/bin/set-global-language.sh"
USER_GLOBAL="${CLAUDE_GLOBAL_CONFIG:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md}"
MARKER='## Security Baseline (non-negotiable'
BUDGET=9200    # content chars per part; the header line keeps each part under 9,500

usage() {
  echo "usage: odeo-context.sh baseline <part> <SessionStart|SubagentStart> | language SessionStart | legacy SessionStart" >&2
  exit 2
}

# emit_json <event>: reads text on stdin, prints it as hookSpecificOutput JSON. Escaping
# is char by char (not gsub) because awks disagree on backslashes in gsub replacements.
emit_json() {
  awk -v ev="$1" '
    function esc(s,   out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") out = out "\\\\"
        else if (c == "\"") out = out "\\\""
        else if (c == "\t") out = out "\\t"
        else if (c == "\r") out = out "\\r"
        else out = out c
      }
      return out
    }
    { lines[++n] = $0 }
    END {
      if (n == 0) exit
      printf "{\"hookSpecificOutput\":{\"hookEventName\":\"%s\",\"additionalContext\":\"", ev
      for (i = 1; i <= n; i++) printf "%s%s", (i > 1 ? "\\n" : ""), esc(lines[i])
      printf "\"}}\n"
    }'
}

warn() { # warn <event> <message>: visible to Claude (context) and in the debug log (stderr)
  echo "odeo-context: $2" >&2
  printf 'Odeo plugin: %s\n' "$2" | emit_json "$1"
}

user_has_baseline() {
  [ -f "$USER_GLOBAL" ] && grep -q "^$MARKER" "$USER_GLOBAL"
}

# print_part <part>: prints part <part> of global/CLAUDE.md (without its leading HTML
# comment, which addresses install-era readers) under a one-line header; nothing if the
# file has fewer parts.
print_part() {
  awk -v want="$1" -v budget="$BUDGET" '
    NR == 1 && /^<!--/ { skipping = 1 }
    skipping { if (/-->/) skipping = 0; next }
    /^## / || ns == 0 { ns++ }
    { sl[ns, ++sc[ns]] = $0; slen[ns] += length($0) + 1 }
    function add(line) { pl[np, ++pc[np]] = line; cur += length(line) + 1 }
    function next_part() { if (cur > 0) { np++; cur = 0 } }
    END {
      np = 1; cur = 0
      for (s = 1; s <= ns; s++) {
        if (cur + slen[s] > budget) next_part()
        for (i = 1; i <= sc[s]; i++) {
          if (cur > 0 && cur + length(sl[s, i]) + 1 > budget) next_part()
          add(sl[s, i])
        }
      }
      if (cur == 0) np--
      if (want > np) exit
      printf "Odeo global baseline, part %d of %d (delivered by the Odeo plugin; the user'"'"'s own ~/.claude/CLAUDE.md takes precedence where the two conflict).\n\n", want, np
      for (i = 1; i <= pc[want]; i++) print pl[want, i]
    }' "$BASELINE"
}

# Prints the scope of the GLOBAL language setting (global | default), read through
# language-status.sh against an empty project so a project-level line cannot mask it.
global_language_scope() {
  local empty scope
  empty="$(mktemp -d)" || return 1
  scope="$(CLAUDE_GLOBAL_CONFIG="$USER_GLOBAL" "$LANG_STATUS" "$empty" 2>/dev/null | awk '{ print $2 }')"
  rmdir "$empty"
  [ -n "$scope" ] || return 1
  printf '%s' "$scope"
}

# Prints the effective GLOBAL language code (resolve-language.sh against an empty project).
global_language_code() {
  local empty code
  empty="$(mktemp -d)" || return 1
  code="$(CLAUDE_GLOBAL_CONFIG="$USER_GLOBAL" "$ROOT/bin/resolve-language.sh" "$empty" 2>/dev/null)"
  rmdir "$empty"
  printf '%s' "$code"
}

language_nudge() {
  cat <<'EOF'
Odeo output language is not set yet. Once, at the start of your first reply in this session, ask the user which language Odeo should write its documents in (PRDs, stories, plans, reviews): English, Deutsch, Hrvatski or Français. Offer them as selectable options (AskUserQuestion) where the host supports it. Then run `set-global-language.sh <en|de|hr|fr>`. If the user skips or declines, run `set-global-language.sh en` so they are not asked again. Code, comments, filenames and commit messages always stay English. They can change it any time with /odeo:language.
EOF
}

legacy_nudge() {
  cat <<'EOF'
Odeo: an old install.sh installation is still in this home directory (~/.claude/odeo-docs, ~/.claude-templates or ~/bin/merge-gate.sh), so Odeo's skills and agents load twice, once from the plugin and once from those copies. If their ~/.claude/CLAUDE.md is the old install.sh copy of the baseline, it also no longer updates; the plugin delivers the current one only when that file lacks the Security Baseline heading. Tell the user once, and offer to run `odeo-migrate-legacy.sh` (a dry run that lists what would move), then `odeo-migrate-legacy.sh --apply` only after they say yes. It moves the copies aside into ~/.claude/odeo-legacy-<timestamp>/ and deletes nothing.
EOF
}

run_legacy() {
  if [ -e "$HOME/.claude/odeo-docs" ] || [ -e "$HOME/.claude-templates" ] || [ -e "$HOME/bin/merge-gate.sh" ]; then
    legacy_nudge | emit_json SessionStart
  fi
}

run_baseline() { # run_baseline <part> <event>
  user_has_baseline && return 0
  if [ ! -f "$BASELINE" ]; then
    [ "$1" = 1 ] && warn "$2" "baseline file not found at $BASELINE; the Security Baseline is NOT loaded. Reinstall the plugin."
    return 0
  fi
  print_part "$1" | emit_json "$2"
}

# sync_dialog_language <option>: applies a changed dialog value; prints context, if any
sync_dialog_language() {
  local opt="$1" state="${CLAUDE_PLUGIN_DATA}/synced-language" last="" scope err
  [ -f "$state" ] && last="$(cat "$state")"
  [ "$opt" = "$last" ] && return 0
  scope="$(global_language_scope)" || scope=""
  if [ -z "$last" ] && [ "$scope" = "global" ]; then
    # First run with a language already set: keep it, it may be a deliberate choice,
    # while the dialog value may be its untouched default.
    printf '%s' "$opt" > "$state"
    printf 'Odeo: the plugin setting says output language "%s", but the global setting is already "%s" and was kept. If the user wants the plugin setting, run `/odeo:language %s --global`; otherwise say nothing about it.\n' \
      "$opt" "$(global_language_code)" "$opt" | emit_json SessionStart
    return 0
  fi
  # The value is recorded either way: a refusal (a symlinked global, an invalid code) is
  # reported ONCE per dialog value instead of degrading every session with the same warning.
  if err="$(CLAUDE_GLOBAL_CONFIG="$USER_GLOBAL" "$SET_GLOBAL" "$opt" --overwrite 2>&1)"; then
    printf '%s' "$opt" > "$state"
  else
    printf '%s' "$opt" > "$state"
    warn SessionStart "could not apply the plugin's output language \"$opt\" to the global setting ($err). Tell the user once; they can set it per project with \`/odeo:language $opt\` inside that project."
  fi
}

run_language() {
  local scope opt="${CLAUDE_PLUGIN_OPTION_OUTPUT_LANGUAGE:-}"
  if [ -n "$opt" ] && [ -n "${CLAUDE_PLUGIN_DATA:-}" ] && [ -x "$SET_GLOBAL" ] && [ -x "$LANG_STATUS" ]; then
    mkdir -p "$CLAUDE_PLUGIN_DATA" 2>/dev/null
    sync_dialog_language "$opt"
    return 0
  fi
  if [ ! -x "$LANG_STATUS" ]; then
    warn SessionStart "language check unavailable ($LANG_STATUS missing); run /odeo:language to set the output language."
  elif ! scope="$(global_language_scope)"; then
    warn SessionStart "language check unavailable (language-status.sh returned nothing); run /odeo:language to set the output language."
  elif [ "$scope" = "default" ]; then
    language_nudge | emit_json SessionStart
  fi
}

case "${1:-}" in
  baseline)
    [ "$#" -eq 3 ] || usage
    case "$2" in ''|*[!0-9]*) usage ;; esac
    case "$3" in SessionStart|SubagentStart) ;; *) usage ;; esac
    run_baseline "$2" "$3" ;;
  language)
    [ "$#" -eq 2 ] && [ "$2" = SessionStart ] || usage
    run_language ;;
  legacy)
    [ "$#" -eq 2 ] && [ "$2" = SessionStart ] || usage
    run_legacy ;;
  *) usage ;;
esac
exit 0
