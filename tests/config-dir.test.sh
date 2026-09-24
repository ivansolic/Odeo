#!/usr/bin/env bash
# Every reader and writer of the user's global CLAUDE.md honours CLAUDE_CONFIG_DIR.
#
# Claude Code's CLAUDE_CONFIG_DIR moves "all settings, session history, and plugins" out of
# ~/.claude (code.claude.com/docs/en/env-vars). Claude then loads that directory's
# CLAUDE.md, so a script that still read ~/.claude/CLAUDE.md would disagree with the
# session: the baseline hook could stay silent because a DIFFERENT file carries the
# heading, and /language would write a file the session never loads. The five sites are
# checked together, behaviourally, so one of them cannot drift from the rest.
#
# Observed failing (2026-09-24): reverting the default in each of the five files ALONE
# reddens its own case (language-status 1, prose-language-check 1, resolve-language 1,
# set-global-language 4, odeo-context 1). Each mutant checked to differ from the original.
# Dropping `cp -p` from the atomic overwrite reddens the mode case; its fixture is 644
# because mktemp creates 600, which would make a lost mode invisible.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_eq() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$2', got '$3')"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
H="$TMP/home"; CFG="$TMP/config"; P="$TMP/project"; mkdir -p "$H/.claude" "$CFG" "$P"
# ~/.claude/CLAUDE.md says one thing, the config dir's CLAUDE.md says another
printf '# old\n## Security Baseline (non-negotiable, applies to ALL code)\noutput_language: fr\n' > "$H/.claude/CLAUDE.md"
printf '# active\noutput_language: de\n' > "$CFG/CLAUDE.md"
run() { env -u CLAUDE_GLOBAL_CONFIG HOME="$H" CLAUDE_CONFIG_DIR="$CFG" "$@"; }

assert_eq "resolve-language reads the config dir" "de" "$(run "$ROOT/bin/resolve-language.sh" "$P" 2>/dev/null)"
assert_eq "language-status reads the config dir" "de global" "$(run "$ROOT/bin/language-status.sh" "$P" 2>/dev/null)"
run "$ROOT/bin/set-global-language.sh" hr --overwrite >/dev/null 2>&1
assert_eq "set-global-language writes the config dir" "output_language: hr" "$(grep '^output_language:' "$CFG/CLAUDE.md")"
assert_eq "set-global-language leaves ~/.claude alone" "output_language: fr" "$(grep '^output_language:' "$H/.claude/CLAUDE.md")"
# the baseline hook: the ACTIVE global has no baseline heading, so the baseline is delivered
out="$(run "$ROOT/hooks/odeo-context.sh" baseline 1 SessionStart 2>/dev/null)"
case "$out" in *"Odeo global baseline"*) ok "hook checks the active global for the heading";;
  *) bad "hook stayed silent because ~/.claude/CLAUDE.md has the heading";; esac
# prose-language-check resolves through the same default (English prose vs expected hr)
doc="$P/doc.md"; printf '# T\n\nThe team will review the plan and the user will see the result of the work in the app.\n' > "$doc"
out="$(run "$ROOT/bin/prose-language-check.sh" "$P" "$doc" 2>&1)"
case "$out" in *"expected=hr "*) ok "prose-language-check expects the config dir's language";;
  *) bad "prose-language-check did not use the config dir (${out:0:80})";; esac

# the overwrite is an atomic rename beside the target: mode kept, no temp file left
m="$TMP/mode.md"; printf '# G\noutput_language: en\n' > "$m"; chmod 644 "$m"   # not 600: mktemp itself creates 600, which would mask a lost mode
CLAUDE_GLOBAL_CONFIG="$m" "$ROOT/bin/set-global-language.sh" de --overwrite >/dev/null 2>&1
assert_eq "overwrite keeps the file mode" "644" "$(stat -f %Lp "$m" 2>/dev/null || stat -c %a "$m")"
assert_eq "overwrite leaves no temp file" "0" "$(ls "$TMP" | grep -c '^mode\.md\.')"
assert_eq "overwrite applied" "output_language: de" "$(grep '^output_language:' "$m")"

# without CLAUDE_CONFIG_DIR, ~/.claude/CLAUDE.md is still the default
assert_eq "no config dir -> ~/.claude" "fr" "$(env -u CLAUDE_GLOBAL_CONFIG -u CLAUDE_CONFIG_DIR HOME="$H" "$ROOT/bin/resolve-language.sh" "$P" 2>/dev/null)"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
