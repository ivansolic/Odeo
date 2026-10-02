---
artifact: fix-assertion-count-honesty
type: code
branch: fix/assertion-count-honesty
reviewed_commit: 91e979c
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

## Scope reviewed

This is round 2. I read `git diff 9be9472 91e979c`, which has three code commits: `12c5740`
(the check reads skip lines in any casing and has its own uncounted-skip counter), `75570fd`
(the three root guards declare their counts, README 1421) and `91e979c` (the CI step). The
round-1 record is commit `764837c`. The contract is unchanged: the README assertion count is
one number on every machine.

What I checked myself:
- The three new counts against their run branches. prose-language-check G7 makes 1 assertion
  (`assert_eq`). token-report makes 1 (`expect_exit`). odeo-context makes 2 (`assert_exit` and
  `assert_empty`). All three are correct.
- The new tripwire. `grep -c '^  assert_locale "'` matches exactly the 4 in-loop calls (lines
  278, 295, 307, 317). It does not match the definition (column 0) or the comments.
- The CI log of private run 36986787500 at 91e979c (ubuntu). It shows `SKIP 8` for both locales
  and `SKIP 2` for case 40, then "note: 18 assertion(s) in 3 skipped case(s) were added back",
  then "ok: assertions = 1421". macOS skips a different set (case 40 only, 2 added back) and
  reaches the same 1421. That is the first two-machine evidence for the branch's claim. Together
  with the locale and SHELLOPTS skips, it also explains the old 1399 vs 1383 gap: Linux skipped
  case 40 as well.
- A mutation of the new `|| "$skip_fail" -gt 0` in `count_reason` (Important 1 below). The
  mutant survives the suite.

## Findings

### Important
1. **The new "blames neither the README" assertion cannot fail, so the round-1 harm is not
   pinned.** In tests/docs-claims-check.test.sh:108 the uncounted-skip loop uses a README
   claiming 2 assertions. With the skip uncounted, the run also measures 2, so the claim matches
   and no DRIFTED or "Fix the NUMBER" can appear whatever `count_reason` does. I removed
   `|| "$skip_fail" -gt 0` from scripts/docs-claims-check.sh:141 and ran the same fixture:
   - With README=2, the output is identical to the shipped script, so the suite stays green.
   - With README=4 (the full count, which is what a real README carries), the mutant prints
     `DRIFTED` and "Fix the NUMBER in the document". The shipped script prints `UNVERIFIED`.

   That is exactly the root scenario from round 1, and no test holds it. Fix: write the README
   in that loop with a count above the ok lines (for example 3), so the uncounted skip leaves
   the total short. Then the `*"Fix the NUMBER"*` arm actually guards `count_reason`. Watch the
   mutant above go red before you claim it.

### Nitpicks
- scripts/docs-claims-check.sh:123: `SKIP 08 - x` is now refused, which is correct. But the
  message calls it a "skip line without a count" when it has a malformed count. Say "without a
  valid count", or leave it.
- The 4c96dcb bisect point: leaving the history as it is is fine for a fast-forward merge. I do
  not ask for a squash.

## Round-1 findings, status
- Uncounted root skips: fixed. The class is closed for every printed casing by
  `grep -iE '^skip'`. The residual is a guard that skips in silence, which no grep can see. It
  is stated, not hidden, and the CI step now shows any such silent machine difference as
  DRIFTED on Linux.
- Stale contract comments: fixed (the header Exit text and the `claim()` comment).
- False "exited non-zero" cause: fixed with `skip_fail`, its own message and its own footer.
  This is tested, apart from the `count_reason` arm above.
- CI step: added after the suites loop, and timeout-minutes is 20. Keeping the loop for
  per-suite log output is the right call. The step ran green on Linux at 91e979c.
- Nitpicks: the regex is `[1-9][0-9]*`, the tripwire counts calls and states its indent limit,
  and the case-6 header is in the past tense. All done.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 1/2 · conventions 2/2 -> total 11/12 (threshold: >=9, no zero)

## Ceiling
12/12 is reachable. Testing returns to 2 once the uncounted-skip fixture's README count makes
the "blames neither" assertion able to fail. That is a one-number change plus the mutation run.

## Verdict
APPROVE WITH COMMENTS. The branch's invariant now holds and has been measured on two machines
with different skip sets. One test assertion is vacuous and should be made real before merge.

## History
- Round 1 (9be9472): REQUEST CHANGES, 9/12. Four uncounted root-dependent assertions, stale
  contract comments, a false "exited non-zero" cause, and the CI step missing.
- Round 2 (91e979c): APPROVE WITH COMMENTS, 11/12. Better by 2: all round-1 findings fixed,
  plus Linux CI evidence for 1421. One new Important: a vacuous assertion in the
  uncounted-skip loop, shown by a surviving mutant.
