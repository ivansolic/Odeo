---
artifact: scripts/skills-lint.sh C17 (plan_layers + comparison) + tests/skills-lint.test.sh C17 cases + docs/invariants.md C17 row
type: code
branch: feature/plan-human-layer
reviewed_commit: babe300
artifact_version: 4
date: 2026-10-01
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 12/12
---

## Artifact

Branch `feature/plan-human-layer`, read at HEAD `babe300`, re-anchored from `e5dbea0`. Scope:
lint C17 in `scripts/skills-lint.sh`, its test cases in `tests/skills-lint.test.sh`, and the C17
row in `docs/invariants.md`. The prose files are out of scope.

## Re-anchor check (babe300)

- `git diff e5dbea0 babe300 -- scripts tests docs/invariants.md` is empty. Nothing in scope
  changed.
- Outside scope, the diff touches one example table row in `docs/plan-format.md` (around line
  195, not the `Plan layers:` line at line 21) and worked-example text in
  `skills/build/SKILL.md`. The rest of the diff is review records under `docs/evals/`.
- skills-lint is clean on the worktree at babe300, so C17 still passes on the real files.

## Round-3 delta, verified (carried over, unchanged)

- I ran `git diff 4f001fa e5dbea0 -- scripts tests docs/invariants.md`. Only
  `tests/skills-lint.test.sh` changed. `scripts/skills-lint.sh` and `docs/invariants.md` are
  identical to 4f001fa, so the round-2 analysis of the lint itself still holds.
- The round-2 nitpick is fixed. The empty-list case (`tests/skills-lint.test.sh:331-337`)
  now captures `rc=$?` straight after `out="$( bash "$LINT" "$d" 2>&1 )"`, which is the exit
  status of the substitution. An exit code other than 1 prefixes `out` with `(exit N, want 1)`,
  and the first `case` arm turns that into a FAIL that shows the code. The message is checked
  only when the exit code is right. The logic is correct, and the case now fails on either a
  wrong exit code or a wrong message.

## Findings

### Critical
- None.

### Important
- None.

### Nitpicks
- `tests/skills-lint.test.sh:333-335`: the exit code is passed into the `case` by prefixing
  it to the output string. A plain `if [[ $rc -ne 1 ]]; then FAIL; elif [[ "$out" == *"empty 'Plan layers:'"* ]]; then ok; else FAIL; fi`
  would read more directly. The FAIL text "passed an empty list" is also loose when the exit
  code is 2 rather than 0, though the code itself is printed. Optional.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## Verdict

APPROVE

## History

- Round 1 (d995419): 11/12, APPROVE WITH COMMENTS. Important: `grep -m1` did not hold the
  "one line" invariant. Four nitpicks on wording and row order.
- Round 2 (4f001fa): 12/12, APPROVE. All five items fixed, two new tests. One optional nit:
  the empty-list test did not check the exit code.
- Round 3 (e5dbea0): 12/12, APPROVE. The nit is fixed, and the lint and invariants row are
  unchanged. Regression note: same (12 -> 12).
- Re-anchor (babe300): code in scope unchanged, verified by an empty
  `git diff e5dbea0 babe300 -- scripts tests docs/invariants.md`, and skills-lint is clean.
  Scores and verdict carry over: 12/12, APPROVE. Regression note: same.
