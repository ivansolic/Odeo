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

# 4. --assertions counts what the suites report, and SAYS when some were skipped. A suite that
#    skips assertions (a root guard, a shell that refuses
#    SHELLOPTS) makes the total environment-dependent, and without the note a machine that ran
#    a different amount of the suite reads as a drifted README, which sends the reader to fix a
#    document that is correct.
#    Run against a miniature tree rather than this repo: the real --assertions pass runs
#    every suite and takes minutes, and a slow test gets skipped, which is how this whole
#    class of check rots.
mini="$(mktemp -d)"; mkdir -p "$mini/bin" "$mini/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini/bin/foo.sh"; chmod +x "$mini/bin/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP - b"\necho "ok   - c"\n' > "$mini/tests/skippy.test.sh"
cat > "$mini/README.md" <<'MINI'
├── bin/   ← 1 executables
│   └── *.test.sh   ← 2 suites, 2 assertions. 1 of the 1 programs have their own suite
MINI
out4="$( cd "$mini" && bash "$CHECK" --assertions 2>&1 )"; rc4=$?
[[ "$rc4" -eq 0 ]] && ok "--assertions totals the suites' ok lines (exit 0)" \
  || bad "--assertions miscounted a tree built to match (exit $rc4): $out4"
case "$out4" in *"1 check(s) were SKIPPED"*) ok "and it reports that 1 check was skipped";;
  *) bad "a skipped check was counted silently (got: ${out4:-<empty>})";; esac
#    The other direction: no skips, no note. A note that always prints teaches the reader to
#    ignore it, which is the same as not having one.
printf '#!/usr/bin/env bash\necho "ok   - b"\necho "ok   - c"\n' > "$mini/tests/skippy.test.sh"
out5="$( cd "$mini" && bash "$CHECK" --assertions 2>&1 )"
case "$out5" in *SKIPPED*) bad "the skip note printed when nothing was skipped";;
  *) ok "and it stays quiet when nothing was skipped";; esac
rm -rf "$mini"

# 5. AN INCOMPLETE MEASUREMENT IS NOT EVIDENCE, IN EITHER DIRECTION. The note told the reader
#    the count could read LOW, and the check still FAILED on any mismatch. So a machine that
#    ran MORE of the suite than the author's (one skip fewer) counted HIGHER, got `DRIFTED`,
#    exit 1, and the instruction "Fix the NUMBER in the document, never this check": it was
#    told to edit a correct README and break it for everyone else. That was live in this repo,
#    where bash 3.2 skips a case bash 5 runs.
#
#    The rule under test: when anything was skipped, the assertion count reports UNVERIFIED and
#    does NOT fail, while the claims this run CAN measure completely stay fatal. The assertion
#    is on the OUTCOME (exit code and word), not on the note's prose, which is what let the
#    previous version pass while the harm was live.
mini5="$(mktemp -d)"; mkdir -p "$mini5/bin" "$mini5/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini5/bin/foo.sh"; chmod +x "$mini5/bin/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini5/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP - b"\necho "ok   - c"\n' > "$mini5/tests/skippy.test.sh"
# The README claims 2. This run measures 2, so the count itself is honest; the rows below bend
# the README instead of the tree, one in each direction.
for direction in high low; do
  case "$direction" in
    high) documented=1 ;;   # a machine that ran MORE than the author's: measured > documented
    low)  documented=3 ;;   # a machine that ran LESS: measured < documented
  esac
  cat > "$mini5/README.md" <<MINI5
├── bin/   ← 1 executables
│   └── *.test.sh   ← 2 suites, $documented assertions. 1 of the 1 programs have their own suite
MINI5
  out="$( cd "$mini5" && bash "$CHECK" --assertions 2>&1 )"; rc=$?
  [[ "$rc" -eq 0 ]] \
    && ok "a count that could not be fully measured does not fail the check ($direction reading)" \
    || bad "an unmeasurable count exited $rc, telling the reader to edit a correct README ($direction): $out"
  case "$out" in *UNVERIFIED*) ok "and it is reported as UNVERIFIED, not as drift ($direction)";;
    *) bad "the mismatch was not marked unverified ($direction): ${out:-<empty>}";; esac
  case "$out" in *DRIFTED*) bad "it still called an unmeasurable count drift ($direction)";;
    *) ok "and the word DRIFTED is not used for it ($direction)";; esac
done
# The exemption is SCOPED. A claim this run measures completely is still fatal, skip or no skip,
# because otherwise one skipped case would switch the whole document off.
cat > "$mini5/README.md" <<'MINI5'
├── bin/   ← 999 executables
│   └── *.test.sh   ← 2 suites, 2 assertions. 1 of the 1 programs have their own suite
MINI5
out="$( cd "$mini5" && bash "$CHECK" --assertions 2>&1 )"; rc=$?
[[ "$rc" -ne 0 ]] && ok "a claim that CAN be measured still fails while another is unverified" \
  || bad "one skipped case switched off the claims this run could verify: $out"
case "$out" in *DRIFTED*) ok "and that one is still reported as drift";;
  *) bad "the measurable claim failed without naming drift: ${out:-<empty>}";; esac
rm -rf "$mini5"

# 6. A SUITE THAT FAILS IS NOT AN UNVERIFIED COUNT. The assertion total was read out of each
#    suite's `ok` lines and the suite's EXIT CODE was thrown away, which did not matter while any
#    mismatch failed: a broken suite produced a wrong total and the run went red anyway, for the
#    wrong reason but loudly. Adding the unverified outcome removed that accident, and the case
#    it removed it for is the worst one: a suite that ERRORS now reports fewer assertions, the
#    mismatch is excused as unverified, and the run ends GREEN on every machine that skips
#    anything, which here is every machine. A broken instrument must never read as a clean bill.
mini6="$(mktemp -d)"; mkdir -p "$mini6/bin" "$mini6/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini6/bin/foo.sh"; chmod +x "$mini6/bin/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini6/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP - b"\necho "ok   - c"\n' > "$mini6/tests/skippy.test.sh"
printf '#!/usr/bin/env bash\necho "FAIL - d"\nexit 1\n' > "$mini6/tests/broken.test.sh"
cat > "$mini6/README.md" <<'MINI6'
├── bin/   ← 1 executables
│   └── *.test.sh   ← 3 suites, 2 assertions. 1 of the 1 programs have their own suite
MINI6
out6="$( cd "$mini6" && bash "$CHECK" --assertions 2>&1 )"; rc6=$?
[[ "$rc6" -ne 0 ]] && ok "a suite that FAILS makes the run red even when another skipped (exit $rc6)" \
  || bad "a broken suite passed as an unverified count: the instrument reads as a clean bill"
case "$out6" in *broken.test.sh*) ok "and the failure names the suite that broke";;
  *) bad "it failed without naming the broken suite: ${out6:-<empty>}";; esac
rm -rf "$mini6"

# 7. THE LAST LINE MUST NOT CONTRADICT THE RUN. With an unverified claim above it, the summary
#    still read "every countable claim matches the tree", which is the exact shape of claim this
#    program exists to catch, printed by the program itself. A reader who scrolls to the end,
#    which is what a summary is for, gets the opposite of what happened.
mini7="$(mktemp -d)"; mkdir -p "$mini7/bin" "$mini7/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini7/bin/foo.sh"; chmod +x "$mini7/bin/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini7/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP - b"\necho "ok   - c"\n' > "$mini7/tests/skippy.test.sh"
cat > "$mini7/README.md" <<'MINI7'
├── bin/   ← 1 executables
│   └── *.test.sh   ← 2 suites, 7 assertions. 1 of the 1 programs have their own suite
MINI7
out7="$( cd "$mini7" && bash "$CHECK" --assertions 2>&1 )"; rc7=$?
[[ "$rc7" -eq 0 ]] && ok "an unverified claim still exits 0" || bad "unverified run exited $rc7: $out7"
last7="$(printf '%s\n' "$out7" | grep -v '^$' | tail -1)"
case "$last7" in *"every countable claim matches"*)
    bad "the summary claims everything matches while a claim went unverified: $last7";;
  *UNVERIFIED*|*unverified*) ok "and the summary says how many claims went unverified";;
  *) bad "the summary neither claims success nor names the unverified claim: $last7";; esac
#    And the other direction: a fully verified run must still say so plainly, or the summary
#    becomes noise that a reader learns to skip.
printf '#!/usr/bin/env bash\necho "ok   - b"\necho "ok   - c"\n' > "$mini7/tests/skippy.test.sh"
cat > "$mini7/README.md" <<'MINI7'
├── bin/   ← 1 executables
│   └── *.test.sh   ← 2 suites, 3 assertions. 1 of the 1 programs have their own suite
MINI7
out8="$( cd "$mini7" && bash "$CHECK" --assertions 2>&1 )"; rc8=$?
[[ "$rc8" -eq 0 ]] && ok "a fully measured run still exits 0" || bad "clean run exited $rc8: $out8"
case "$out8" in *"every countable claim matches"*) ok "and still says every claim matches";;
  *) bad "a clean run no longer states the clean result: ${out8:-<empty>}";; esac
rm -rf "$mini7"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "docs-claims-check: all $pass assertions passed."; else echo "docs-claims-check: $fail FAILURE(S) above."; fi
exit "$fail"
