#!/usr/bin/env bash
# set-global-language.sh, idempotent writer of the GLOBAL output-language default.
#
# Writes a single `output_language: <code>` line into the user global config that
# bin/resolve-language.sh reads for its global precedence level. It is the write
# counterpart to that reader: same file, same line format, same code allowlist.
#
# IDEMPOTENT BY DESIGN: if the config already carries an output_language: line,
# this does nothing and reports "already set". That is what enforces "asked
# exactly once" across re-installs: the caller (install.sh) never re-prompts
# because the line is already there (a skip writes `en`, so even a skip counts).
#
# This only records WHICH language to write prose in; machine surfaces (filenames,
# frontmatter keys, commit types, code) stay English regardless of the code stored.
#
# Usage:
#   set-global-language.sh <code>        # code in: en de hr fr
#
# Exit codes:
#   0  line present after the call (freshly written, or already set)
#   1  invalid code
#   2  usage error (wrong number of args)
#
# The global config path is overridable via CLAUDE_GLOBAL_CONFIG so tests never
# touch the real $HOME/.claude/CLAUDE.md (matches bin/resolve-language.sh).
set -uo pipefail

usage() { echo "usage: set-global-language.sh <code>  (code: en de hr fr)" >&2; exit 2; }

[ "$#" -eq 1 ] || usage
CODE="$1"

# Valid language codes. Literal, self-contained list (matches resolve-language.sh
# and init-project.sh: each file stands alone, no cross-sourcing). The set MUST
# stay identical to USR-002's allowlist.
VALID="en de hr fr"
valid=0
for c in $VALID; do [ "$CODE" = "$c" ] && valid=1; done
if [ "$valid" -ne 1 ]; then
  echo "set-global-language: unknown language: $CODE (allowed: $VALID)" >&2
  exit 1
fi

GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"

# Idempotence gate. The grep runs against $GLOBAL_CONFIG ONLY; this script takes no
# project-dir argument and never inspects a project CLAUDE.md, so the gate can never
# be confused by a project-level line. If a global line already exists, leave it.
if [ -f "$GLOBAL_CONFIG" ] && grep -qE '^output_language:' "$GLOBAL_CONFIG"; then
  echo "set-global-language: global output language already set, leaving it unchanged."
  exit 0
fi

# Ensure the parent dir and file exist (a --link install or a hand-removed file).
mkdir -p "$(dirname "$GLOBAL_CONFIG")"
[ -f "$GLOBAL_CONFIG" ] || : > "$GLOBAL_CONFIG"

# Append the canonical line on its own line. Appended (not inserted at an anchor)
# because the user global CLAUDE.md has no guaranteed structure; resolve-language.sh
# reads the first ^output_language: match anywhere, so a trailing line is read fine.
printf '\noutput_language: %s\n' "$CODE" >> "$GLOBAL_CONFIG"
echo "set-global-language: global output language set to $CODE."
exit 0
