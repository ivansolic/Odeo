#!/usr/bin/env bash
# copy-check.sh finds wording copied from a source skill: any run of 9 or more consecutive
# words (case and punctuation ignored) shared by an Odeo file and a source file
# (PRD-003 R24, USR-029: no wording copied from a source skill).
#
# Maintainer tooling, not a shipped suite: copy-check.sh lives in .claude/maintainer/ and
# is never published.
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 in copy-check.sh change the default threshold 9 -> 10          -> the 9-word cases FAIL
#   M2 in copy-check.sh drop the punctuation normalisation            -> the case/punctuation
#      and sentence-boundary cases FAIL
#   M3 in copy-check.sh change the exit code for shared runs 1 -> 0   -> the shared-run cases FAIL
#   M4 in copy-check.sh reset the word stream per line (no run across lines) -> the line-break
#      case FAILS
#   M5 in copy-check.sh loop bound `i + min - 1 <= ns` -> `i + min <= ns` -> the whole-file case
#      FAILS (same for `no`)
#   M6 in copy-check.sh delete the min-words check                     -> the min-words 0 and
#      abc cases FAIL
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CC="$ROOT/.claude/maintainer/copy-check.sh"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
O="$TMP/odeo.md"; S="$TMP/source.md"

# run <odeo-text> <source-text>: sets $rc and $out
run() { printf '%s\n' "$1" > "$O"; printf '%s\n' "$2" > "$S"; out="$(bash "$CC" "$O" "$S" 2>&1)"; rc=$?; }

run "alpha one two three four five six seven eight nine omega" "beta one two three four five six seven eight nine gamma"
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "one two three four five six seven eight nine"; then ok "9 shared words: exit 1 and run printed"
else bad "9 shared words: rc=$rc out=$out"; fi

run "alpha one two three four five six seven eight omega" "beta one two three four five six seven eight gamma"
if [ "$rc" -eq 0 ]; then ok "8 shared words: exit 0"; else bad "8 shared words: rc=$rc out=$out"; fi

run "alpha One, two; THREE. four five six seven eight nine omega" "beta one two three four five six seven eight nine gamma"
if [ "$rc" -eq 1 ]; then ok "case and punctuation ignored: exit 1"; else bad "case and punctuation: rc=$rc out=$out"; fi

run "alpha one two three four. five six seven eight nine omega" "beta one two three four five six seven eight nine gamma"
if [ "$rc" -eq 1 ]; then ok "run across a sentence boundary: exit 1"; else bad "sentence boundary: rc=$rc out=$out"; fi

run $'x one two three four\nfive six seven eight nine y' "one two three four five six seven eight nine"
if [ "$rc" -eq 1 ]; then ok "run across a line break: exit 1"; else bad "line break: rc=$rc out=$out"; fi

run "one two three four five six seven eight nine" "one two three four five six seven eight nine"
if [ "$rc" -eq 1 ]; then ok "run filling both files exactly: exit 1"; else bad "whole-file run: rc=$rc out=$out"; fi

run "alpha one two three four five six seven eight omega" "beta one two three four five six seven eight gamma"
out="$(bash "$CC" "$O" "$S" 8 2>&1)"; rc=$?
if [ "$rc" -eq 1 ]; then ok "min-words 8 finds 8 shared words: exit 1"; else bad "min-words 8: rc=$rc out=$out"; fi

for m in 0 abc; do
  out="$(bash "$CC" "$O" "$S" "$m" 2>&1)"; rc=$?
  if [ "$rc" -eq 2 ]; then ok "min-words $m: exit 2"; else bad "min-words $m: rc=$rc"; fi
done

printf 'one two three four five six seven eight nine\n' > "$O"; : > "$S"
out="$(bash "$CC" "$O" "$S" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then ok "empty source file: exit 0"; else bad "empty source file: rc=$rc out=$out"; fi

: > "$O"; printf 'beta one two three four five six seven eight nine gamma\n' > "$S"
out="$(bash "$CC" "$O" "$S" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then ok "empty odeo file: exit 0"; else bad "empty odeo file: rc=$rc out=$out"; fi

out="$(bash "$CC" 2>&1)"; rc=$?
if [ "$rc" -eq 2 ]; then ok "missing argument: exit 2"; else bad "missing argument: rc=$rc"; fi

out="$(bash "$CC" "$TMP/nonexistent.md" "$S" 2>&1)"; rc=$?
if [ "$rc" -eq 2 ]; then ok "nonexistent file: exit 2"; else bad "nonexistent file: rc=$rc"; fi

exit "$fail"
