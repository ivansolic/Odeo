---
artifact: community-freshness-reminder
type: code
branch: feature/community-freshness-reminder
reviewed_commit: 8987849
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 11/12
verdict: APPROVE
---

# Code review: community knowledge freshness reminder (round 2)

## Scope reviewed

Round 2 re-anchors the review on `8987849`. It reads the round-1 fix delta
`git diff 9a6eae4..8987849` (3 files, +26/-2: `hooks/odeo-context.sh`,
`tests/odeo-context.test.sh`, `tests/community-sync.test.sh`) on top of the full round-1
review of `git diff main...9a6eae4` (7 files). Plan:
`~/.claude/plans/wobbly-kindling-cascade.md`, a plan-mode plan with design rules 1 to 6 and
a test list. Nothing else moved since round 1.

## Verdict

APPROVE. All round-1 findings are fixed in code or tests. The two items that were not
applied are decisions for the human: one changes the approved plan, the other is a product
choice. Neither is a defect against the plan.

## Round-1 findings, verified at 8987849

- **Important, untested "cannot record" branch: fixed.** A new 4f case
  (`tests/odeo-context.test.sh:295-300`) points `CLAUDE_PLUGIN_DATA` at `data/sub` under a
  `chmod 500` dir with a stale copy, then asserts exit 0 and empty stdout. The case is
  skipped as root, and the permission is restored before the next case, so the cleanup trap
  still works. The mutation (emit even though the state was not recorded) produces stdout
  and fails the empty assertion. M30 records it.
- **No stamp and no HEAD: fixed.** `hooks/odeo-context.sh:273-275` now reports `stale`
  when neither file exists. The check sits after the fallback, so a stamp that exists still
  wins. A test was added, and M31 records the mutation.
- **The boundary comment: fixed.** `hooks/odeo-context.sh:261-262` now says the offset was
  measured on BSD only and GNU was not measured, which matches what was measured.
- **The duplicated path: pinned.** A literal-match test (`tests/odeo-context.test.sh:305-309`)
  now fails if either file drifts. It checks the text rather than behavior, but that fits
  here, because the property is "the same string".
- **Move-aside mutation: recorded** as M23b in the `tests/community-sync.test.sh` header.
  It matches what I observed in round 1 (1 FAIL).

## Held for the human (not code findings)

- FETCH_HEAD instead of `.git/HEAD` as the fallback for copies synced before this change.
  The plan's rule 1 names HEAD, so switching is a plan change and belongs at the gate. It
  is transitional: the worst case is one reminder that comes early.
- A permanent opt-out for users who never want community knowledge. This is a product
  decision. Today they are reminded every 14 days.

## Critical

None.

## Important

None.

## Nitpicks

- `hooks/odeo-context.sh:284`: for a HEAD-less clone, the reminder now says "has not been
  refreshed in 14 days or more". The more precise statement would be "cannot be dated".
  A sync then answers "offline?", which points the user to the move-aside remedy, so the
  outcome is still right. Optional: a third message for that state. Not scored.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## What's good

- Every fix came with a mutation that was observed failing and recorded next to the ones
  from round 1. The two new silent-path tests are each guarded by the same positive-control
  shape as the first 4f case.
- The HEAD-less fix keeps the right precedence: a stamp, then HEAD, then "cannot be dated,
  remind". That closes the silent-forever state without touching the normal path.

## History

- Round 1, `9a6eae4`: APPROVE WITH COMMENTS, 11/12 (testing 1). Important: the branch that
  skips the reminder when its state cannot be recorded was untested. Nitpicks: a HEAD-less
  clone stayed silent forever; the BSD/GNU claim in the boundary comment was unmeasured; the
  community path was duplicated without a check; the move-aside mutation was unrecorded;
  the FETCH_HEAD fallback; the opt-out.
- Round 2, `8987849`: APPROVE, 12/12. Regression note: better (+1, testing 1 -> 2). All
  code-level findings were fixed. The FETCH_HEAD fallback and the opt-out were held for the
  human as a plan change and a product decision.
