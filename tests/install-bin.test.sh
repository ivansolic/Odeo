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

# The expected set: EVERY regular file in bin/, counted WITHOUT the shebang predicate the
# implementation uses. Deriving it with the same rule made this suite structurally blind:
# a planted shebang-less executable was skipped by the install and the suite still printed
# "all assertions passed", because both sides agreed to ignore the same file. A test whose
# expectation is filtered by the rule under test can only confirm that rule is consistent
# with itself. The contract is "every file in bin/ is installed, or the install FAILS", so
# the count comes from the directory and the skip case below covers the other direction.
# ONE named exception, by name and not by rule: odeo-migrate-legacy.sh must run from the
# plugin root it reads Odeo's names from, so install.sh never places it in ~/bin.
EXCLUDED="odeo-migrate-legacy.sh"
expected=0
for s in "$ROOT"/bin/*; do
  [[ -f "$s" ]] || continue
  [[ "$(basename "$s")" == "$EXCLUDED" ]] && continue
  expected=$((expected+1))
done
[[ "$expected" -gt 0 ]] || { echo "FAIL - instrument broken: no files found in bin/"; exit 1; }
ok "instrument: bin/ holds $expected files, counted independently of the shebang rule"

# Extract the loop under test, so the assertion runs the REAL code rather than a
# paraphrase of it, without executing the rest of install.sh (which writes to ~/.claude).
loop="$(awk '/^# BEGIN bin-install/,/^# END bin-install$/' "$ROOT/install.sh")"
# The extraction is a TEXT RANGE, so it fails OPEN: if a marker moves, awk runs to EOF and
# silently hands back the rest of install.sh, and the cases below then redden for the wrong
# reason (measured with the previous markers: 9 lines became 111). Named BEGIN/END markers
# replaced a range keyed on code lines, which broke the moment the code they pointed at
# grew a second guard. Bound it and fail LOUD either way, so marker drift can never
# masquerade as a behaviour finding.
loop_lines=$(printf '%s\n' "$loop" | wc -l | tr -d ' ')
if [[ -z "$loop" || "$loop_lines" -gt 40 ]] \
   || ! printf '%s' "$loop" | grep -q 'installed > 0' \
   || ! printf '%s' "$loop" | grep -q 'END bin-install'; then
  echo "FAIL - instrument broken: extracted $loop_lines lines from install.sh, expected the"
  echo "       BEGIN/END bin-install block. A marker in install.sh moved or was removed."
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

# Same, but PRINTS stderr and still returns the status, so a case can assert the message
# and not merely the exit code. Kept separate from run_loop rather than made to do both:
# a helper that prints AND sets a status is the shape that produced the empty-string bug
# above, so the two uses stay in two functions.
run_loop_err() {
  local repo="$1" home="$2" errfile
  errfile="$(mktemp)"
  (
    set +e
    REPO_DIR="$repo"; HOME="$home"
    place() { cp "$1" "$2"; }
    mkdir -p "$home/bin"
    eval "$loop"
  ) >/dev/null 2>"$errfile"
  local rc=$?
  cat "$errfile"; rm -f "$errfile"
  return $rc
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
[[ ! -e "$h/bin/$EXCLUDED" ]] && ok "the excluded program is not installed ($EXCLUDED)" \
  || bad "$EXCLUDED was installed into ~/bin"
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

# 3. Empty bin/: installing zero programs must FAIL LOUDLY, never exit 0 quietly. The
#    message is asserted too, not just the status: deleting the explanation while keeping
#    `exit 1` would otherwise stay green, and a bare non-zero exit tells a user nothing.
tmp="$(mktemp -d)"; h="$tmp/home"; emptyrepo="$tmp/repo"
mkdir -p "$emptyrepo/bin" "$h"
err="$(run_loop_err "$emptyrepo" "$h")"; rc=$?
[[ "$rc" != "0" ]] && ok "zero programs is a loud failure (exit $rc)" \
  || bad "zero programs exited 0: a clean-looking install with no guards on PATH"
case "$err" in *"no programs found"*) ok "and it says why (message on stderr)";;
  *) bad "failed without an explanation on stderr (got: ${err:-<empty>})";; esac
rm -rf "$tmp"

# 4. A file in bin/ that is NOT a program (no shebang) must STOP the install, naming it.
#    This is the direction the suite was blind to: the implementation skipped such a file
#    silently and this suite agreed, because both filtered by the same rule. Measured then:
#    22 of 23 installed, suite green. Now a skip is a failure, so "every program in bin/"
#    is enforceable instead of aspirational.
tmp="$(mktemp -d)"; h="$tmp/home"; plantrepo="$tmp/repo"
mkdir -p "$plantrepo/bin" "$h"; cp "$ROOT"/bin/* "$plantrepo/bin/" 2>/dev/null
printf 'echo not-a-program\n' > "$plantrepo/bin/odeo-helper"; chmod +x "$plantrepo/bin/odeo-helper"
err="$(run_loop_err "$plantrepo" "$h")"; rc=$?
[[ "$rc" != "0" ]] && ok "a shebang-less file in bin/ stops the install (exit $rc)" \
  || bad "a shebang-less file was skipped SILENTLY (install exited 0)"
case "$err" in *odeo-helper*) ok "and the offending file is named";;
  *) bad "failed without naming the skipped file (got: ${err:-<empty>})";; esac
rm -rf "$tmp"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "install-bin: all $pass assertions passed."; else echo "install-bin: $fail FAILURE(S) above."; fi
exit "$fail"
