#!/usr/bin/env bash
# Tests the bin/ compatibility wrappers. The programs live in scripts/; bin/ holds one
# wrapper per program so that git hooks and ~/bin shims written by Odeo 0.2.x, which only
# search */odeo/*/bin, still reach the current program after an update. A missing or
# broken wrapper would switch off an installed secret gate once the old cache is swept.
#
# Under test: bin/ and scripts/ name exactly the same programs; each wrapper forwards
# arguments, stdin and the exit code; it resolves scripts/ through a symlink (an old
# install.sh link install points ~/bin at it) and from a copied plugin root.
#
# Observed failing (2026-09-29), each mutant checked to differ from the original:
#   MA a wrapper deleted                  -> 1 FAIL (the name sets differ)
#   MB wrapper drops "$@"                 -> 2 FAIL (arguments, symlink)
#   MC wrapper runs without exec, exit 0  -> 2 FAIL (exit code, symlink)
#   MD symlinks not followed              -> 1 FAIL (symlink)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_eq() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$2', got '$3')"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# 1) one wrapper per program, and nothing else in bin/
names() { ( cd "$1" && ls -1 ) | sort; }
assert_eq "bin/ and scripts/ name the same programs" "$(names "$ROOT/scripts")" "$(names "$ROOT/bin")"
nonexec=""
for w in "$ROOT"/bin/*; do [ -x "$w" ] || nonexec="$nonexec $(basename "$w")"; done
assert_eq "every wrapper is executable" "" "$nonexec"

# A copied plugin root whose scripts/ holds a probe under every wrapper's name, so each
# wrapper is exercised without running the real program.
plug="$TMP/plugin"; mkdir -p "$plug/scripts"; cp -R "$ROOT/bin" "$plug/bin"
for w in "$ROOT"/bin/*; do
  n="$(basename "$w")"
  printf '#!/usr/bin/env bash\nprintf "%%s|" "$@"; printf "stdin=%%s|" "$(cat)"; echo "%s"; exit 7\n' "$n" > "$plug/scripts/$n"
  chmod +x "$plug/scripts/$n"
done

# 2) every wrapper forwards arguments (with spaces), stdin and the exit code
badargs=""; badrc=""
for w in "$plug"/bin/*; do
  n="$(basename "$w")"
  out="$(printf 'IN' | "$w" "a b" c 2>&1)"; rc=$?
  [ "$out" = "a b|c|stdin=IN|$n" ] || badargs="$badargs $n"
  [ "$rc" = 7 ] || badrc="$badrc $n"
done
assert_eq "every wrapper forwards arguments and stdin" "" "$badargs"
assert_eq "every wrapper passes the exit code through" "" "$badrc"

# 3) reached through a symlink in another directory (install.sh link mode)
mkdir -p "$TMP/home/bin"; ln -s "$plug/bin/secret-scan.sh" "$TMP/home/bin/secret-scan.sh"
out="$(printf '' | "$TMP/home/bin/secret-scan.sh" x 2>&1)"; rc=$?
assert_eq "a symlinked wrapper finds scripts/" "x|stdin=|secret-scan.sh 7" "$out $rc"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
