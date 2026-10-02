#!/usr/bin/env bash
# Tests for scripts/docs-claims-check.sh, the anchor against MEASUREMENT DECAY.
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
CHECK="$ROOT/scripts/docs-claims-check.sh"
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
cp -R "$ROOT"/{scripts,tests,skills,agents} "$tmp"/ 2>/dev/null
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
cp -R "$ROOT"/{scripts,tests,skills,agents} "$tmp2"/ 2>/dev/null
printf '# Odeo\n\nNo countable claims here at all.\n' > "$tmp2/README.md"
out2="$( cd "$tmp2" && bash "$CHECK" 2>&1 )"; rc2=$?
[[ "$rc2" -ne 0 ]] && ok "a README carrying none of the expected claims FAILS (exit $rc2)" \
  || bad "a README with no claims passed: the check would go green on a gutted document"
rm -rf "$tmp2"

# 4. A SKIPPED CASE IS ADDED BACK, so the total is the same on every machine. A suite that
#    cannot run a case (a root guard, a shell that refuses SHELLOPTS, a locale that is not
#    installed) prints `SKIP <n> - <reason>`, n being the assertions the case makes when it runs.
#    The check adds n to the `ok` lines, so the README carries ONE number and any mismatch is
#    drift. Before this, a SKIP line carried no count, so the total moved with the machine and
#    every machine that skipped anything reported the claim as UNVERIFIED: +6 real assertions
#    from a merged branch went unnoticed that way. Observed failing (2026-10-02) before the
#    count was read: the total was 2, not 4, and the claim was UNVERIFIED.
#    Run against a miniature tree rather than this repo: the real --assertions pass runs
#    every suite and takes minutes, and a slow test gets skipped, which is how this whole
#    class of check rots.
mini="$(mktemp -d)"; mkdir -p "$mini/scripts" "$mini/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini/scripts/foo.sh"; chmod +x "$mini/scripts/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP 2 - b cannot run here"\necho "ok   - c"\n' > "$mini/tests/skippy.test.sh"
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 2 suites, 4 assertions. 1 of the 1 programs have their own suite\n' > "$mini/README.md"
out4="$( cd "$mini" && bash "$CHECK" --assertions 2>&1 )"; rc4=$?
[[ "$rc4" -eq 0 ]] && ok "a skipped case's assertions are added back (exit 0)" \
  || bad "the full total did not match a README built for it (exit $rc4): $out4"
case "$out4" in *"ok: assertions = 4"*) ok "and the total is ok + skipped = 4";;
  *) bad "the skipped assertions were not added back: ${out4:-<empty>}";; esac
case "$out4" in *"2 assertion(s) in 1 skipped case(s) were added back"*) ok "and it says what it added back";;
  *) bad "the skip was added back silently: ${out4:-<empty>}";; esac
case "$out4" in *"skippy.test.sh: SKIP 2 - b cannot run here"*) ok "and it quotes the suite's own reason for the skip";;
  *) bad "the note does not quote why the case was skipped: ${out4:-<empty>}";; esac
case "$out4" in *UNVERIFIED*) bad "a fully accounted total is still called unverified";;
  *) ok "and a fully accounted total is not called unverified";; esac
#    The other direction: no skips, no note. A note that always prints teaches the reader to
#    ignore it, which is the same as not having one.
printf '#!/usr/bin/env bash\necho "ok   - b"\necho "ok   - c"\n' > "$mini/tests/skippy.test.sh"
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 2 suites, 3 assertions. 1 of the 1 programs have their own suite\n' > "$mini/README.md"
out5="$( cd "$mini" && bash "$CHECK" --assertions 2>&1 )"
case "$out5" in *"added back"*) bad "the skip note printed when nothing was skipped";;
  *) ok "and it stays quiet when nothing was skipped";; esac
rm -rf "$mini"

# 5. WITH EVERY SKIP COUNTED, A MISMATCH IS DRIFT IN BOTH DIRECTIONS, and a SKIP without a count
#    is a broken suite. The old rule excused any mismatch while something was skipped, because
#    a skipped case held an unknown number of assertions; with the number declared there is
#    nothing left to excuse. Observed failing (2026-10-02) under the old rule: both directions
#    were UNVERIFIED at exit 0, and the bare SKIP was accepted.
mini5="$(mktemp -d)"; mkdir -p "$mini5/scripts" "$mini5/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini5/scripts/foo.sh"; chmod +x "$mini5/scripts/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini5/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP 2 - b cannot run here"\necho "ok   - c"\n' > "$mini5/tests/skippy.test.sh"
for documented in 3 5; do   # the full total is 4: one below and one above
  printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 2 suites, %s assertions. 1 of the 1 programs have their own suite\n' "$documented" > "$mini5/README.md"
  out="$( cd "$mini5" && bash "$CHECK" --assertions 2>&1 )"; rc=$?
  [[ "$rc" -ne 0 ]] && ok "a README at $documented against a full total of 4 fails" \
    || bad "a README at $documented passed against a full total of 4: $out"
  case "$out" in *DRIFTED*"Fix the NUMBER"*) ok "and it is drift, with the fix-the-document footer ($documented)";;
    *) bad "the mismatch was not reported as drift ($documented): ${out:-<empty>}";; esac
done
# The README sits ABOVE the ok lines (3 against 2), as a real README does when a skipped case
# went uncounted, so withholding the number is what keeps it from being called drifted. With a
# README at 2 the "blames neither" check could not fail: review round 2 measured a mutant that
# no longer withholds it staying green there, and red here.
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 2 suites, 3 assertions. 1 of the 1 programs have their own suite\n' > "$mini5/README.md"
#    Every spelling that is not a counted SKIP is refused, including the lowercase `skip -` and
#    `skip:` three suites used for their root guards (review round 1: as root they vanished from
#    the total and a correct README was called drifted), and a count of 0, which skips nothing.
#    Observed failing (2026-10-02, round 1) for the lowercase lines, read case-sensitively.
for bare in 'SKIP - b cannot run here' 'skip - b cannot run here' 'skip: b cannot run here' 'SKIP 0 - b'; do
  printf '#!/usr/bin/env bash\necho "%s"\necho "ok   - c"\n' "$bare" > "$mini5/tests/skippy.test.sh"
  out="$( cd "$mini5" && bash "$CHECK" --assertions 2>&1 )"; rc=$?
  [[ "$rc" -ne 0 ]] && ok "'$bare' fails the run" || bad "'$bare' was accepted: $out"
  case "$out" in *"skippy.test.sh"*"skip line without a valid count"*) ok "and it names the suite and the missing count ('$bare')";;
    *) bad "the uncounted skip was not named ('$bare'): ${out:-<empty>}";; esac
  case "$out" in *"carry no count"*) ok "and the footer names the uncounted skip ('$bare')";;
    *) bad "the footer does not name the uncounted skip ('$bare'): ${out:-<empty>}";; esac
  case "$out" in *"Fix the NUMBER"*|*"exited non-zero"*) bad "an uncounted skip blames the README or a suite exit ('$bare')";;
    *) ok "and it blames neither the README nor an exit code ('$bare')";; esac
done
rm -rf "$mini5"

# 6. A SUITE THAT FAILS IS NOT AN UNVERIFIED COUNT. The assertion total was read out of each
#    suite's `ok` lines and the suite's EXIT CODE was thrown away, which did not matter while any
#    mismatch failed: a broken suite produced a wrong total and the run went red anyway, for the
#    wrong reason but loudly. The unverified outcome (then granted to any run that skipped a case,
#    since removed) took that accident away, and for the worst case: a suite that ERRORED reported
#    fewer assertions, the mismatch was excused as unverified, and the run ended GREEN on every
#    machine that skipped anything. A broken instrument must never read as a clean bill.
mini6="$(mktemp -d)"; mkdir -p "$mini6/scripts" "$mini6/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini6/scripts/foo.sh"; chmod +x "$mini6/scripts/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini6/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP 1 - b"\necho "ok   - c"\n' > "$mini6/tests/skippy.test.sh"
printf '#!/usr/bin/env bash\necho "FAIL - d"\nexit 1\n' > "$mini6/tests/broken.test.sh"
cat > "$mini6/README.md" <<'MINI6'
├── scripts/   ← 1 executables
│   └── *.test.sh   ← 3 suites, 2 assertions. 1 of the 1 programs have their own suite
MINI6
out6="$( cd "$mini6" && bash "$CHECK" --assertions 2>&1 )"; rc6=$?
[[ "$rc6" -ne 0 ]] && ok "a suite that FAILS makes the run red even when another skipped (exit $rc6)" \
  || bad "a broken suite passed as an unverified count: the instrument reads as a clean bill"
case "$out6" in *broken.test.sh*) ok "and the failure names the suite that broke";;
  *) bad "it failed without naming the broken suite: ${out6:-<empty>}";; esac
#    And the LAST WORD fits the cause. Only a suite broke and the README is correct, so the
#    footer must send the reader to the suite, not tell them to "Fix the NUMBER in the document".
#    Observed failing (2026-09-30) before the footer counted suite failures: both checks below.
case "$out6" in *"exited non-zero"*) ok "and the footer says a suite failed, not the document";;
  *) bad "the footer does not name the failed suite as the cause: ${out6:-<empty>}";; esac
case "$out6" in *"Fix the NUMBER"*) bad "the footer tells the reader to edit a correct README";;
  *) ok "and it does not tell the reader to edit the README";; esac
#    6c. THE SAME WITH NOTHING SKIPPED, which is the ordinary machine. A broken suite reports
#    fewer `ok` lines, so the total misses a README that is RIGHT, and with no skip to excuse it
#    the count used to be judged DRIFTED, adding "Fix the NUMBER" under the suite's own remedy.
#    A total from a run where a suite failed is not a measurement, so it is not judged at all.
#    Observed failing (2026-09-30, round-1 review) with only the skip able to excuse the total.
printf '#!/usr/bin/env bash\necho "ok   - b"\n' > "$mini6/tests/skippy.test.sh"
printf '#!/usr/bin/env bash\necho "ok   - d"\nexit 1\n' > "$mini6/tests/broken.test.sh"
# README at the HEALTHY count: foo 1 + skippy 1 + broken's 2 when it works = 4; broken now
# reports 1, so the run measures 3. A README equal to the broken total would prove nothing.
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 3 suites, 4 assertions. 1 of the 1 programs have their own suite\n' > "$mini6/README.md"
out6c="$( cd "$mini6" && bash "$CHECK" --assertions 2>&1 )"; rc6c=$?
[[ "$rc6c" -ne 0 ]] && ok "6c: a failed suite with nothing skipped is still red (exit $rc6c)" \
  || bad "6c: a failed suite with nothing skipped passed"
case "$out6c" in *"exited non-zero"*) ok "6c: and the footer sends the reader to the suite";;
  *) bad "6c: the footer does not name the suite: ${out6c:-<empty>}";; esac
case "$out6c" in *"Fix the NUMBER"*|*DRIFTED*) bad "6c: a correct README is called drifted: ${out6c:-<empty>}";;
  *) ok "6c: and a correct README is not called drifted";; esac
#    Control: with a README that really drifted and every suite green, the drift footer stays.
printf '#!/usr/bin/env bash\necho "ok   - b"\n' > "$mini6/tests/skippy.test.sh"; rm "$mini6/tests/broken.test.sh"
printf '├── scripts/   ← 7 executables\n│   └── *.test.sh   ← 2 suites, 2 assertions. 1 of the 1 programs have their own suite\n' > "$mini6/README.md"
out6b="$( cd "$mini6" && bash "$CHECK" --assertions 2>&1 )"
case "$out6b" in *"Fix the NUMBER"*) ok "a real drift still gets the fix-the-document footer";;
  *) bad "a real drift lost its footer: ${out6b:-<empty>}";; esac
case "$out6b" in *"exited non-zero"*) bad "a drift with green suites blames a suite";;
  *) ok "and it does not blame a suite";; esac
rm -rf "$mini6"

# 7. THE LAST LINE STATES THE CLEAN RESULT PLAINLY, skips included. With every skip counted, a
#    run that reaches the summary measured every claim, so the summary says so. (It used to have a
#    second form for an UNVERIFIED claim; that state now arises only with a failed suite, which
#    exits 1 before the summary, so the form was removed rather than left untested.)
mini7="$(mktemp -d)"; mkdir -p "$mini7/scripts" "$mini7/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini7/scripts/foo.sh"; chmod +x "$mini7/scripts/foo.sh"
printf '#!/usr/bin/env bash\necho "ok   - a"\n' > "$mini7/tests/foo.test.sh"
printf '#!/usr/bin/env bash\necho "SKIP 1 - b"\necho "ok   - c"\n' > "$mini7/tests/skippy.test.sh"
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 2 suites, 3 assertions. 1 of the 1 programs have their own suite\n' > "$mini7/README.md"
out8="$( cd "$mini7" && bash "$CHECK" --assertions 2>&1 )"; rc8=$?
[[ "$rc8" -eq 0 ]] && ok "a fully measured run with a counted skip exits 0" || bad "clean run exited $rc8: $out8"
last8="$(printf '%s\n' "$out8" | grep -v '^$' | tail -1)"
case "$last8" in *"every countable claim matches"*) ok "and the last line says every claim matches";;
  *) bad "a clean run no longer states the clean result: $last8";; esac
rm -rf "$mini7"

# 8. A SUITE NEVER WAITS ON THE CALLER'S STDIN. Run in the background with stdin left open, a
#    suite that read from it waited forever: the whole check was killed at a 30-minute limit
#    with no output (2026-10-02). Suites run with stdin from /dev/null. The fixture suite reads
#    with a 3-second limit and passes only when the read returns at once (end-of-file); the check is fed a pipe that stays
#    open for 5 seconds, so the RED is bounded and cannot hang this suite. Observed failing
#    (2026-10-02) before the redirect: the fixture timed out and the run went red.
mini8="$(mktemp -d)"; mkdir -p "$mini8/scripts" "$mini8/tests"
printf '#!/usr/bin/env bash\necho hi\n' > "$mini8/scripts/foo.sh"; chmod +x "$mini8/scripts/foo.sh"
# bash 3.2 returns 1 for both a timeout and end-of-file, so the fixture measures the wait: EOF
# returns at once, an open pipe holds the read for its full 3 seconds.
printf '#!/usr/bin/env bash\nstart=$SECONDS; read -r -t 3 x; waited=$((SECONDS-start))\nif [ "$waited" -lt 2 ]; then echo "ok   - stdin is closed"; else echo "FAIL - stdin was open, waited ${waited}s"; exit 1; fi\n' > "$mini8/tests/foo.test.sh"
printf '├── scripts/   ← 1 executables\n│   └── *.test.sh   ← 1 suites, 1 assertions. 1 of the 1 programs have their own suite\n' > "$mini8/README.md"
out9="$( cd "$mini8" && sleep 5 | bash "$CHECK" --assertions 2>&1 )"; rc9=$?
[[ "$rc9" -eq 0 ]] && ok "a suite run under an open stdin still gets end-of-file" \
  || bad "a suite saw the caller's open stdin (exit $rc9): $out9"
rm -rf "$mini8"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "docs-claims-check: all $pass assertions passed."; else echo "docs-claims-check: $fail FAILURE(S) above."; fi
exit "$fail"
