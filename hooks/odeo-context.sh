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
#       While no GLOBAL output language is set, asks Claude to ask the user once.
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
USER_GLOBAL="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"
MARKER='## Security Baseline (non-negotiable'
BUDGET=9200    # content chars per part; the header line keeps each part under 9,500

usage() {
  echo "usage: odeo-context.sh baseline <part> <SessionStart|SubagentStart> | language SessionStart" >&2
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

language_nudge() {
  cat <<'EOF'
Odeo output language is not set yet. Once, at the start of your first reply in this session, ask the user which language Odeo should write its documents in (PRDs, stories, plans, reviews): English, Deutsch, Hrvatski or Français. Offer them as selectable options (AskUserQuestion) where the host supports it. Then run `set-global-language.sh <en|de|hr|fr>`. If the user skips or declines, run `set-global-language.sh en` so they are not asked again. Code, comments, filenames and commit messages always stay English. They can change it any time with /language.
EOF
}

run_baseline() { # run_baseline <part> <event>
  user_has_baseline && return 0
  if [ ! -f "$BASELINE" ]; then
    [ "$1" = 1 ] && warn "$2" "baseline file not found at $BASELINE; the Security Baseline is NOT loaded. Reinstall the plugin."
    return 0
  fi
  print_part "$1" | emit_json "$2"
}

run_language() {
  local scope
  if [ ! -x "$LANG_STATUS" ]; then
    warn SessionStart "language check unavailable ($LANG_STATUS missing); run /language to set the output language."
  elif ! scope="$(global_language_scope)"; then
    warn SessionStart "language check unavailable (language-status.sh returned nothing); run /language to set the output language."
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
  *) usage ;;
esac
exit 0
