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
#   set-global-language.sh <code>                # code in: en de hr fr
#   set-global-language.sh <code> --overwrite    # CHANGE an existing value
#
# Without --overwrite it is idempotent by design (see above): an existing line is
# left alone. --overwrite is the explicit opt-in the /language command uses to
# CHANGE the global default; install.sh never passes it, so the install-time
# "asked exactly once, never silently overwritten" guarantee is unaffected.
#
# The no-flag path is unchanged for every NON-SYMLINK input. One deliberate delta:
# a symlinked config is now refused on BOTH paths (it previously appended through
# the link, which under a --link install would have written into the repo's tracked
# global/CLAUDE.md). install.sh cannot reach it, since it skips symlinks first.
#
# Exit codes:
#   0  line present after the call (freshly written, changed, or already set)
#   1  invalid code, or a symlinked config that must not be rewritten
#   2  usage error (wrong number of args, or an unknown flag)
#
# The global config path is overridable via CLAUDE_GLOBAL_CONFIG so tests never
# touch the real $HOME/.claude/CLAUDE.md (matches bin/resolve-language.sh).
set -uo pipefail

usage() { echo "usage: set-global-language.sh <code> [--overwrite]  (code: en de hr fr)" >&2; exit 2; }

CODE=""
OVERWRITE=0
SEEN_CODE=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --overwrite) OVERWRITE=1; shift ;;
    -*)          usage ;;
    *)           # A second bare token is a usage error. Counted rather than inferred
                 # from emptiness, so an explicit empty argument stays a usage error
                 # (matching what USR-003 shipped) instead of being treated as "no code".
                 [ "$SEEN_CODE" -eq 0 ] || usage
                 CODE="$1"; SEEN_CODE=1; shift ;;
  esac
done
[ "$SEEN_CODE" -eq 1 ] || usage

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

# Idempotence gate (USR-003's "asked exactly once"): WITHOUT --overwrite an existing
# line is left exactly as it is. The grep runs against $GLOBAL_CONFIG ONLY; this
# script takes no project-dir argument and never inspects a project CLAUDE.md, so the
# gate can never be confused by a project-level line.
HAS_LINE=0
if [ -f "$GLOBAL_CONFIG" ] && grep -qE '^output_language:' "$GLOBAL_CONFIG"; then
  HAS_LINE=1
fi
if [ "$HAS_LINE" -eq 1 ] && [ "$OVERWRITE" -ne 1 ]; then
  echo "set-global-language: global output language already set, leaving it unchanged."
  exit 0
fi

# About to write. Refuse a symlinked config: under a --link install
# ~/.claude/CLAUDE.md points at the repo's tracked global/CLAUDE.md, and writing
# through it would mutate a committed file.
if [ -L "$GLOBAL_CONFIG" ]; then
  echo "set-global-language: $GLOBAL_CONFIG is a symlink (--link install); refusing to rewrite it. Set the language for this project instead." >&2
  exit 1
fi

if [ "$HAS_LINE" -eq 1 ]; then
  # --overwrite: replace at the position of the FIRST line, drop any further
  # ones, and write THROUGH the path so the file keeps its mode. Not atomic
  # (a failure mid-write leaves a truncated file); accepted for a one-line
  # config edit, same tradeoff as set-project-language.sh.
  if [ ! -w "$GLOBAL_CONFIG" ]; then
    echo "set-global-language: $GLOBAL_CONFIG is not writable" >&2
    exit 1
  fi
  tmp="$(mktemp)" || { echo "set-global-language: could not create a temp file" >&2; exit 1; }
  # Clean up the temp file even on a signal (every explicit error path also removes it).
  trap 'rm -f "$tmp"' EXIT
  if ! awk -v line="output_language: $CODE" '
    /^output_language:/ { if (!seen) { print line; seen=1 } ; next }
    { print }
  ' "$GLOBAL_CONFIG" > "$tmp"; then
    rm -f "$tmp"; echo "set-global-language: rewrite failed for $GLOBAL_CONFIG" >&2; exit 1
  fi
  if ! cat "$tmp" > "$GLOBAL_CONFIG"; then
    rm -f "$tmp"; echo "set-global-language: could not write $GLOBAL_CONFIG" >&2; exit 1
  fi
  rm -f "$tmp"
  echo "set-global-language: global output language changed to $CODE."
  exit 0
fi

# Ensure the parent dir and file exist (a --link install or a hand-removed file).
mkdir -p "$(dirname "$GLOBAL_CONFIG")"
[ -f "$GLOBAL_CONFIG" ] || : > "$GLOBAL_CONFIG"

# Append the canonical line on its own line. Appended (not inserted at an anchor)
# because the user global CLAUDE.md has no guaranteed structure; resolve-language.sh
# reads the first ^output_language: match anywhere, so a trailing line is read fine.
# The write MUST be checked: an unwritable config would otherwise print success and
# exit 0 with nothing written (a false success, and a lie about the exit contract
# above). A -w pre-check cannot replace this, because the file may legitimately not
# exist yet at this point.
if ! printf '\noutput_language: %s\n' "$CODE" >> "$GLOBAL_CONFIG"; then
  echo "set-global-language: could not write $GLOBAL_CONFIG" >&2
  exit 1
fi
echo "set-global-language: global output language set to $CODE."
exit 0
