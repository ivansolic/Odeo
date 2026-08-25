---
artifact: bin/spec-gate.sh + tests/spec-gate.test.sh + AGENTS.md (spec-gate every-record fix)
type: code
branch: fix/spec-gate-every-record
reviewed_commit: 9333ff7
artifact_version: 1
date: 2026-08-25
scorer: code-reviewer
model: claude-opus-4-8
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: none
---

## Artifact

Branch `fix/spec-gate-every-record` at `9333ff7`, one commit, three files:

1. `bin/spec-gate.sh`: the verdict + tier checks (step 3/3b) now loop over EVERY
   enrolled covering record instead of only the newest, refusing the artifact on
   the first non-approval or fast-tier-without-waiver (`bad=1; break` ->
   `[[ "$bad" -eq 1 ]] && { fail=1; continue; }`). The newest-record computation
   is retained solely for the freshness check (step 4) and the committed-record
   guard.
2. `tests/spec-gate.test.sh`: three new cases, 13b (older REQUEST CHANGES hidden
   by newer PASS), 13c (fast-tier sibling hidden by newer strong), 13d (two clean
   records still pass).
3. `AGENTS.md`: spec-freshness bullet reworded to state the every-record rule and
   that both gates enforce EVERY covering record.

Fixes the same class merge-gate closed for `/merge`: an older sibling rejection
or fast-tier PASS hiding behind a later strong PASS.

## Verification (by measurement)

- `bash tests/spec-gate.test.sh` -> 29/29 pass. Full suite: 26/26 `tests/*.test.sh`
  files green.
- Revert experiment (new tests against main's single-record spec-gate, in /tmp):
  13b and 13c redden (both `rc=0 want=1`, the bug lets the sibling through), 13d
  stays green (`rc=0`). Proves the negative tests exercise the fix, not a tautology.
  Full fail lines:
  - `FAIL - an older sibling REQUEST CHANGES is not hidden by a newer PASS (rc=0 want=1)`
  - `FAIL - a fast-tier sibling is not hidden by a newer strong PASS (rc=0 want=1)`
  Reverted suite: `passed: 27, failed: 2`.
- Control flow (runtime): two-artifact invocation where A has an older REQUEST
  CHANGES sibling and B has no record. Both are evaluated (A refused via the
  sibling loop citing `a-old.md`, B still reached its own "no eval record covers
  USR-002" refusal), overall `rc=1`. Confirms `bad=1; break -> fail=1; continue`
  refuses the current artifact without short-circuiting the next one.
- `bad` is reset to 0 at the top of each artifact's record loop (line 152, inside
  the `for abs` loop); no staleness across artifacts.
- Safety: line 55 refuses the whole run if `docs/evals` is dirty; test 10 (dirty
  record bypass) passes, so an uncommitted hand-edit to PASS never reaches the
  verdict loop. The loop only sees committed records.
- Freshness unchanged: tests 6 and 13 (record older than artifact -> refuse) pass;
  freshness still evaluates the newest record's commit time.
- Inner loop edge cases: `records` has its trailing newline stripped (line 125)
  and is non-empty by the time the loop runs (line 126 guard), so `<<< "$records"`
  yields exactly one iteration per element with no empty-line iteration; the
  `[[ -n "$r" ]] || continue` guard is correct belt-and-suspenders. No off-by-one.
- Both code files bit-identical to their `9333ff7` blobs after review; mutations
  were confined to /tmp; `git status --porcelain` holds only this untracked record.

## Findings

Critical: none.
Important: none.
Nitpicks:
- `docs/system-map.md:136` and `skills/build/SKILL.md:13` describe the gate in the
  singular ("a passing eval record" / "a non-passing verdict"). Neither asserts
  newest-only selection, so neither now contradicts the fix, but system-map could
  optionally gain "every covering record" to mirror the AGENTS.md wording.

## Scores

correctness 2/2 - the every-record loop is correct; freshness and the committed
guard correctly retain the newest-record computation; no edge-case gap found in
the herestring iteration, the `bad` reset, or the freshness/verdict split.
security 2/2 - deny-by-default preserved; the dirty-evals guard still walls
uncommitted records out of the verdict loop (test 10 green); the sibling hole
that let a rejection ride behind a later PASS is closed, matching merge-gate.
performance 2/2 - two small passes over a tiny record list; irrelevant.
readability 2/2 - the retained-newest comment and the step-3 block comment
explain exactly why the loop refuses the artifact rather than exits.
testing 2/2 - three new cases; the two negative ones provably fail on the
pre-fix code and the positive one guards against refusing on record count.
conventions 2/2 - English comments, conventional commit subject, fix/ branch,
AGENTS.md updated so the mechanism no longer enforces an undocumented behaviour.

total 12/12 (threshold >= 9, no zero) -> APPROVE.

## Ceiling

12/12, reached. A self-contained gate fix with a measured red->green proof and
matching documentation has no structural cap.

## History

- 2026-08-25 (`9333ff7`, claude-opus-4-8): first review. APPROVE, 12/12. No prior
  record for this story/branch, so no regression comparison.
