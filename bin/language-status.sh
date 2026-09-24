#!/usr/bin/env bash
# language-status.sh, reports the EFFECTIVE output language and WHERE it is set.
#
# The read side of the /odeo:language command. bin/resolve-language.sh answers WHICH
# code is effective; this script adds WHICH LEVEL set it (the scope), which the
# resolver deliberately does not expose. The CODE is always taken from
# resolve-language.sh, so the two can never disagree on the value; only the
# scope is derived here, with the resolver's exact normalize and allowlist rules.
#
# Usage:
#   language-status.sh <project-dir>
#
# Output, exactly one line on stdout:
#   <code> <scope>       scope: project | global | default
#     project  the project CLAUDE.md carries a valid output_language: line
#     global   no valid project line; the global config carries a valid one
#     default  neither level has a valid line, the built-in en fallback applies
#
# Exit codes:
#   0  status written to stdout
#   2  usage error (wrong arg count, project dir not found, resolver missing)
#
# CLAUDE_GLOBAL_CONFIG overrides the global config path (same as
# resolve-language.sh), so tests never touch the real $HOME/.claude/CLAUDE.md.
set -uo pipefail

usage() { echo "usage: language-status.sh <project-dir>" >&2; exit 2; }

[ "$#" -eq 1 ] || usage

PROJECT_DIR="$1"
[ -d "$PROJECT_DIR" ] || { echo "language-status: project dir not found: $PROJECT_DIR" >&2; exit 2; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$HERE/resolve-language.sh"
[ -f "$RESOLVER" ] || { echo "language-status: resolver not found: $RESOLVER" >&2; exit 2; }

# Valid codes. Literal, self-contained list (same convention as
# resolve-language.sh and set-global-language.sh). MUST stay identical to
# USR-002's allowlist; tests/language-allowlist-agreement.test.sh enforces it.
VALID="en de hr fr"
GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md}"

# read_lang FILE, same rules as resolve-language.sh: first ^output_language:
# line, strip CR, trim, lowercase, print only a recognized code.
read_lang() {
  local file="$1"
  [ -f "$file" ] || return 0
  local raw
  raw="$(grep -m1 -E '^output_language:' "$file" 2>/dev/null || true)"
  [ -n "$raw" ] || return 0
  local val
  val="$(printf '%s' "$raw" | sed -E 's/^output_language:[[:space:]]*//' \
        | tr -d '\r' | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[[:space:]]+$//')"
  local c
  for c in $VALID; do [ "$val" = "$c" ] && { printf '%s' "$c"; return 0; }; done
  return 0
}

# The code comes from the resolver: single source of truth for precedence.
code="$(CLAUDE_GLOBAL_CONFIG="$GLOBAL_CONFIG" bash "$RESOLVER" "$PROJECT_DIR")" \
  || { echo "language-status: resolver failed for $PROJECT_DIR" >&2; exit 2; }
code="$(printf '%s' "$code" | tr -d '\r\n')"

if [ -n "$(read_lang "$PROJECT_DIR/CLAUDE.md")" ]; then
  scope=project
elif [ -n "$(read_lang "$GLOBAL_CONFIG")" ]; then
  scope=global
else
  scope=default
fi

printf '%s %s\n' "$code" "$scope"
exit 0
