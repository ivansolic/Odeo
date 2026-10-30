#!/usr/bin/env bash
# Tests for scripts/odeo-removed-scripts.txt, the list of programs a release no longer ships
# (PRD-002 R8, USR-010). hooks/odeo-context.sh reads it to name a git hook that still calls one
# of them, and scripts/install-git-guards.sh reads it to decide which pre-push hook to move
# aside. The file is data, not a program: it must not be executable, or docs-claims-check
# would count it among the programs.
#
# This is the part that needs no internal files, so it also runs in a published snapshot. That
# the list matches the maintainer's own record of what was cut is proven where that record is,
# by .claude/maintainer/tests/removed-scripts.test.sh.
#
# Observed failing (2026-10-30), each mutant checked to differ from the original:
#   M1 the list file deleted                                   -> 5 FAIL (exists, shape, sorted, no listed name shipped, not executable)
#   M2 a name appended out of order (aaa-first.sh at the end)  -> 1 FAIL (sorted and unique)
#   M3 a duplicate line added                                  -> 1 FAIL (sorted and unique)
#   M4 a name without the .sh suffix                           -> 2 FAIL (shape, and the order)
#   M5 a listed name restored as a file in scripts/            -> 1 FAIL (no listed name is shipped)
#   M6 the list made executable (chmod +x)                     -> 1 FAIL (not executable)
#   M7 a name with a path separator ("../x.sh")                -> 2 FAIL (shape, and the order)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$ROOT/scripts/odeo-removed-scripts.txt"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

[ -s "$LIST" ] && ok "list exists and is not empty" || bad "scripts/odeo-removed-scripts.txt missing or empty"

# one name per line, `#` lines and blank lines are comments; the same shape the two readers accept
names="$(grep -vE '^#|^$' "$LIST" 2>/dev/null)"
bad_lines="$(printf '%s\n' "$names" | grep -vcE '^[a-z0-9][a-z0-9._-]*\.sh$')"
[ -n "$names" ] && [ "$bad_lines" = "0" ] && ok "every line is a script name ending in .sh" || bad "$bad_lines malformed line(s) in the list (or no names)"

[ -n "$names" ] && [ "$names" = "$(printf '%s\n' "$names" | LC_ALL=C sort -u)" ] && ok "list is sorted and unique" || bad "list is not sorted/unique"

shipped=""
while IFS= read -r n; do
  [ -n "$n" ] && [ -e "$ROOT/scripts/$n" ] && shipped="$shipped $n"
done <<< "$names"
[ -n "$names" ] && [ -z "$shipped" ] && ok "no listed name is shipped in scripts/" || bad "listed but still in scripts/:$shipped"

[ -f "$LIST" ] && [ ! -x "$LIST" ] && ok "list is data: not executable" || bad "list is executable (docs-claims-check would count it as a program)"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
