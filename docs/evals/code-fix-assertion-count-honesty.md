---
artifact: fix-assertion-count-honesty
type: code
branch: fix/assertion-count-honesty
reviewed_commit: 64f0635
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## Scope reviewed

This is round 3, the last round the review loop allows. I read `git diff 91e979c 64f0635`.
The only code commit is `64f0635`; `df635c7` is the round-2 record. Two things changed:
- tests/docs-claims-check.test.sh: the uncounted-skip fixture's README now claims 3 assertions
  against 2 `ok` lines, with a comment explaining why.
- scripts/docs-claims-check.sh:123: the message now reads "skip line without a valid count",
  and the test matches the new wording.

What I checked myself:
- I re-ran the round-2 mutant (dropping `|| "$skip_fail" -gt 0` at
  scripts/docs-claims-check.sh:141). I ran the real docs-claims-check suite against it, pointed
  at the mutant. "an uncounted skip blames the README or a suite exit" now goes red for all FOUR
  spellings: `SKIP -`, `skip -`, `skip:` and `SKIP 0 -`. The dispatch said three of four. The
  mutation is stronger than reported, and the commit body makes no count claim, so nothing in
  the history needs correcting.
- The two other failures that run printed come from my setup, not the code: the copied test
  resolved the real-repo case against /tmp, which has no README.
- The shipped check prints UNVERIFIED, not DRIFTED, for every spelling with README=3. Line 141
  is intact.
- The wording change is matched in the one test that pins it. The assertion count is unchanged,
  so README 1421 stands. The Linux CI evidence from round 2 (1421, 18 added back) still applies:
  this commit changes no suite's `ok` or SKIP output on the real tree.

## Findings

### Critical
- None.

### Important
- None.

### Nitpicks
- None open. The 4c96dcb bisect point stays as accepted in round 2 (fast-forward merge, no
  squash asked).

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling
12/12 is reached.

## Verdict
APPROVE. The invariant "one number on every machine" holds. Every skip spelling that is not a
counted `SKIP <n> - ` is refused. The number is withheld rather than called drift when a skip
goes uncounted, and that is now pinned by a mutation that goes red. The total has been measured
on two machines with different skip sets. The one stated residual is a guard that skips in
complete silence, which no output grep can see. It is named in the branch, and the Linux CI step
would show it as DRIFTED.

## History
- Round 1 (9be9472): REQUEST CHANGES, 9/12. Four uncounted root-dependent assertions, stale
  contract comments, a false "exited non-zero" cause, and the CI step missing.
- Round 2 (91e979c): APPROVE WITH COMMENTS, 11/12. All round-1 findings fixed, and Linux CI
  showed 1421. One vacuous assertion in the uncounted-skip loop, shown by a surviving mutant.
- Round 3 (64f0635): APPROVE, 12/12. Better by 1. The fixture now lets the assertion fail. The
  mutant goes red for 4 of 4 spellings.

Trajectory: 9 -> 11 -> 12.
