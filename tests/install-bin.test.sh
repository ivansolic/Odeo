#!/usr/bin/env bash
# Tests for install.sh's bin/ installation contract.
#
# WHY THIS EXISTS. install.sh globbed `bin/*.sh` while its own comment claimed "all of
# bin/", so `bin/token-report.py` was never installed. Nothing caught it: it surfaced
# only when README started advertising a count that included it. The first fix then
# selected on the EXEC BIT, which on a checkout that lost its exec bits would install
# NOTHING and still exit 0, the same silent-skip defect widened to every file.
#
# So the contract this pins is deliberately two-sided:
#   1. EVERY program in bin/ reaches ~/bin (not just *.sh), so a documented command
#      cannot be missing.
#   2. Installing ZERO programs is a LOUD failure, never a clean-looking success.
#
# Run: bash tests/install-bin.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
ok()   { echo "ok   - $1"; pass=$((pass+1)); }
bad()  { echo "FAIL - $1"; fail=$((fail+1)); }

# The expected set: every file in bin/ carrying a shebang. Derived from the tree, never
# hardcoded, so adding a program to bin/ cannot silently fall out of the contract.
expected=0
for s in "$ROOT"/bin/*; do
  [[ -f "$s" ]] || continue
  head -c 2 "$s" 2>/dev/null | grep -q '#!' && expected=$((expected+1))
done
[[ "$expected" -gt 0 ]] || { echo "FAIL - instrument broken: no programs found in bin/"; exit 1; }
echo "ok   - instrument: bin/ carries $expected programs"

# Extract the loop under test, so the assertion runs the REAL code rather than a
# paraphrase of it, without executing the rest of install.sh (which writes to ~/.claude).
loop="$(awk '/^installed=0$/,/^\(\( installed > 0 \)\)/' "$ROOT/install.sh")"
# The extraction is a TEXT RANGE, so it fails open: if either marker moves, awk runs to EOF
# and silently hands back the rest of install.sh, and the cases below then redden for the
# wrong reason (measured: 9 lines becomes 111). Bound it explicitly, and fail LOUD, so a
# marker drift can never masquerade as a behaviour finding.
loop_lines=$(printf '%s\n' "$loop" | wc -l | tr -d ' ')
if [[ -z "$loop" || "$loop_lines" -gt 20 ]] || ! printf '%s' "$loop" | grep -q 'installed > 0'; then
  echo "FAIL - instrument broken: extracted $loop_lines lines from install.sh, expected the bin"
  echo "       loop (<=20 lines ending at the count guard). The markers in install.sh moved."
  exit 1
fi

# run_loop <repo-dir> <home-dir> -> RETURNS the loop's exit status, installs into <home>/bin.
# It must RETURN the status rather than print it: the loop under test ends in `exit 1`, which
# leaves the subshell immediately, so any `echo $?` after it never runs and the caller would
# read an EMPTY string. Empty compares unequal to "0", so the zero-programs case would pass
# for the wrong reason while proving nothing (lessons.md: a helper either prints its result or
# sets a status, never both, and a negative result needs an instrument proven to give a positive).
run_loop() {
  local repo="$1" home="$2"
  (
    set +e
    REPO_DIR="$repo"; HOME="$home"
    place() { cp "$1" "$2"; }          # the real place() also handles symlink mode; copy is enough here
    mkdir -p "$home/bin"
    eval "$loop"
  ) >/dev/null 2>&1
  return $?
}

# 1. Normal checkout: every program lands in ~/bin, token-report.py included.
tmp="$(mktemp -d)"; h="$tmp/home"
run_loop "$ROOT" "$h"; rc=$?
got=$(ls "$h/bin" 2>/dev/null | wc -l | tr -d ' ')
[[ "$rc" == "0" ]] && ok "normal checkout: exit 0" || bad "normal checkout: exit $rc (want 0)"
[[ "$got" == "$expected" ]] && ok "installs every program in bin/ ($got)" \
  || bad "installed $got of $expected programs"
[[ -f "$h/bin/token-report.py" ]] && ok "the non-.sh program is installed (token-report.py)" \
  || bad "token-report.py missing from ~/bin (the original defect)"
rm -rf "$tmp"

# 2. Exec bits stripped (the Windows-clone shape .gitattributes guards against): the
#    programs must STILL install, because selection is by shebang, not by the exec bit.
tmp="$(mktemp -d)"; h="$tmp/home"; fakerepo="$tmp/repo"
mkdir -p "$fakerepo/bin"; cp "$ROOT"/bin/* "$fakerepo/bin/" 2>/dev/null
chmod -x "$fakerepo"/bin/* 2>/dev/null
run_loop "$fakerepo" "$h"; rc=$?
got=$(ls "$h/bin" 2>/dev/null | wc -l | tr -d ' ')
[[ "$got" == "$expected" ]] && ok "a checkout with no exec bits still installs all $expected" \
  || bad "exec-bitless checkout installed $got of $expected (silent-skip defect)"
rm -rf "$tmp"

# 3. Empty bin/: installing zero programs must FAIL LOUDLY, never exit 0 quietly.
tmp="$(mktemp -d)"; h="$tmp/home"; emptyrepo="$tmp/repo"
mkdir -p "$emptyrepo/bin" "$h"
run_loop "$emptyrepo" "$h"; rc=$?
[[ "$rc" != "0" ]] && ok "zero programs is a loud failure (exit $rc)" \
  || bad "zero programs exited 0: a clean-looking install with no guards on PATH"
rm -rf "$tmp"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "install-bin: all $pass assertions passed."; else echo "install-bin: $fail FAILURE(S) above."; fi
exit "$fail"
