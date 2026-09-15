#!/usr/bin/env bash
# Tests for bin/docs-claims-check.sh, the anchor against MEASUREMENT DECAY.
#
# WHY THIS EXISTS. Documents drift from the system they describe, silently, because
# nothing re-derives their claims. Measured in this repo: README claimed "31 assertions"
# when there were 818; it listed 6 of 21 bin scripts while reading as exhaustive; the task
# ledger said the repo was unprotected when it had been protected for weeks. Every one was
# found by a human happening to look. This check makes the countable claims verifiable, so
# a number that has gone stale FAILS instead of waiting to mislead someone.
#
# It deliberately covers only what can be COUNTED. "The design layer is optional" is prose
# a script cannot judge; "22 executables" is not. A check that pretends to verify judgment
# would be the more dangerous thing, so the scope is stated rather than implied.
#
# Run: bash tests/docs-claims-check.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/bin/docs-claims-check.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

[[ -x "$CHECK" ]] || { echo "FAIL - instrument broken: $CHECK missing or not executable"; exit 1; }

# 1. The real repo passes. This is the positive control: a checker that cannot pass on a
#    correct tree proves nothing when it later fails.
( cd "$ROOT" && bash "$CHECK" >/dev/null 2>&1 ); rc=$?
[[ "$rc" -eq 0 ]] && ok "the real repo's documented claims match reality (exit 0)" \
  || bad "the real repo FAILS its own claims check (exit $rc) , fix the claim or the check"

# 2. A stale count must FAIL, and name the claim. This is the whole point: the README
#    number that went wrong in this repo was a count, and it drifted unnoticed for weeks.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp -R "$ROOT"/{bin,tests,skills,agents} "$tmp"/ 2>/dev/null
cp "$ROOT/README.md" "$tmp"/
# bend the executables claim to a number that is certainly wrong
perl -pi -e 's/← \d+ executables/← 999 executables/' "$tmp/README.md"
out="$( cd "$tmp" && bash "$CHECK" 2>&1 )"; rc=$?
[[ "$rc" -ne 0 ]] && ok "a drifted count FAILS (exit $rc)" \
  || bad "a drifted count passed: the check cannot see the defect it exists for"
case "$out" in *999*|*executable*) ok "and the failure names the claim that drifted";;
  *) bad "failed without naming the drifted claim (got: ${out:-<empty>})";; esac

# 3. A claim the check does not know about must not be invented as a pass. If README stops
#    carrying a claim, the check must SAY so rather than silently verify nothing, which is
#    how a green check becomes meaningless.
tmp2="$(mktemp -d)"
cp -R "$ROOT"/{bin,tests,skills,agents} "$tmp2"/ 2>/dev/null
printf '# Odeo\n\nNo countable claims here at all.\n' > "$tmp2/README.md"
out2="$( cd "$tmp2" && bash "$CHECK" 2>&1 )"; rc2=$?
[[ "$rc2" -ne 0 ]] && ok "a README carrying none of the expected claims FAILS (exit $rc2)" \
  || bad "a README with no claims passed: the check would go green on a gutted document"
rm -rf "$tmp2"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "docs-claims-check: all $pass assertions passed."; else echo "docs-claims-check: $fail FAILURE(S) above."; fi
exit "$fail"
