#!/usr/bin/env bash
# set-project-language.sh, writer of the PROJECT-level output-language override.
#
# Updates (or inserts) the single canonical `output_language: <code>` line in a
# project CLAUDE.md, the exact line bin/resolve-language.sh reads for the project
# precedence level. It always leaves EXACTLY ONE such line, so repeated calls
# change the value instead of stacking duplicates.
#
# Unlike bin/set-global-language.sh (idempotent by default, which is what
# protects the install-time "asked exactly once" guarantee), this script IS a
# change path: overwriting an existing project value is its job, because the
# project override is the per-repo setting /language changes.
#
# Only records WHICH language to write prose in; machine surfaces (filenames,
# frontmatter keys, commit types, code) stay English regardless of the code.
#
# Usage:
#   set-project-language.sh <project-dir> <code>     # code in: en de hr fr
#
# Exit codes:
#   0  the project CLAUDE.md now carries exactly one line with <code>
#   1  invalid code, no CLAUDE.md in <project-dir>, or the write failed
#   2  usage error (wrong arg count, or project dir not found)
set -uo pipefail

usage() { echo "usage: set-project-language.sh <project-dir> <code>  (code: en de hr fr)" >&2; exit 2; }

[ "$#" -eq 2 ] || usage
PROJECT_DIR="$1"
CODE="$2"

[ -d "$PROJECT_DIR" ] || { echo "set-project-language: project dir not found: $PROJECT_DIR" >&2; exit 2; }

# Valid codes. Literal, self-contained list; MUST stay identical to USR-002's.
# tests/language-allowlist-agreement.test.sh enforces agreement across all copies.
VALID="en de hr fr"
valid=0
for c in $VALID; do [ "$CODE" = "$c" ] && valid=1; done
if [ "$valid" -ne 1 ]; then
  echo "set-project-language: unknown language: $CODE (allowed: $VALID)" >&2
  exit 1
fi

TARGET="$PROJECT_DIR/CLAUDE.md"
if [ ! -f "$TARGET" ]; then
  echo "set-project-language: no CLAUDE.md in $PROJECT_DIR (run /setup-project first, or set the global default instead)" >&2
  exit 1
fi

if [ ! -w "$TARGET" ]; then
  echo "set-project-language: $TARGET is not writable" >&2
  exit 1
fi

tmp="$(mktemp)" || { echo "set-project-language: could not create a temp file" >&2; exit 1; }
# Clean up the temp file even on a signal (every explicit error path also removes it).
trap 'rm -f "$tmp"' EXIT

# Same three branches, in the same order, and the same anchor and emitted line as
# bin/init-project.sh, so both writers produce an identical canonical line.
# ONE DELIBERATE DIVERGENCE: init-project.sh replaces with sed (rewrites EVERY
# matching line); this writer uses awk to keep the FIRST and drop the rest, so a
# hand-edited duplicate collapses. That is a superset, never a conflict. Do not
# "harmonize" the two, and do not remove the collapse.
if grep -qE '^output_language:' "$TARGET"; then
  if ! awk -v line="output_language: $CODE" '
    /^output_language:/ { if (!seen) { print line; seen=1 } ; next }
    { print }
  ' "$TARGET" > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: rewrite failed for $TARGET" >&2; exit 1
  fi
elif grep -qE '^## Conventions' "$TARGET"; then
  if ! awk -v line="output_language: $CODE" '
    { print }
    /^## Conventions/ && !done { print ""; print line; done=1 }
  ' "$TARGET" > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: insert failed for $TARGET" >&2; exit 1
  fi
else
  # No line and no anchor: append. resolve-language.sh reads the first
  # ^output_language: match anywhere, so a trailing line is read fine. The
  # leading \n also supplies the separator when the file has no final newline.
  if ! { cat "$TARGET" && printf '\noutput_language: %s\n' "$CODE"; } > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: append failed for $TARGET" >&2; exit 1
  fi
fi

# Write THROUGH the original path so the file keeps its mode (mv would replace
# it with a 600 temp file) and so a symlinked CLAUDE.md is followed rather than
# replaced. The temp file is complete before this runs.
# Not atomic: a failure mid-write leaves a truncated file. Accepted for a
# one-line config edit, because mv would clobber the mode and break the symlink
# case; the tradeoff is stated here rather than left invisible.
if ! cat "$tmp" > "$TARGET"; then
  rm -f "$tmp"; echo "set-project-language: could not write $TARGET" >&2; exit 1
fi
rm -f "$tmp"
echo "set-project-language: project output language set to $CODE."
exit 0
