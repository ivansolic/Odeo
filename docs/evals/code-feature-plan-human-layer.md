---
artifact: scripts/skills-lint.sh C17 (plan_layers + comparison) + tests/skills-lint.test.sh C17 cases + docs/invariants.md C17 row
type: code
branch: feature/plan-human-layer
reviewed_commit: 2859827
artifact_version: 5
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

Branch `feature/plan-human-layer`, read at HEAD `2859827`. The branch was rebased onto main
`95d17e3`, so this record is re-anchored from `4ffdc25`, the pre-rebase HEAD. Scope: lint C17
in `scripts/skills-lint.sh`, its test cases in `tests/skills-lint.test.sh`, and the C17 row in
`docs/invariants.md`. The prose files are out of scope.

## Re-anchor check (rebase, 2859827)

- `git diff 4ffdc25 2859827 -- scripts tests docs/invariants.md` is empty. Nothing in scope
  changed across the rebase.
- Main brought in only `.claude-plugin/plugin.json`, `README.md` and
  `docs/evals/code-chore-release-0-3-3.md` (`git diff --stat c97979d 95d17e3`). None of these
  are in scope.
- `95d17e3` is an ancestor of HEAD. `git range-diff c97979d..4ffdc25 95d17e3..HEAD` shows "=" on
  all 11 commits, so every patch is unchanged, the C17 commit (`e5e1b49` -> `6b5e8f8`) and its
  fix (`310d96a` -> `3528452`) included.
- skills-lint is clean on the worktree at 2859827.

## Earlier re-anchor (babe300, carried over)

- `git diff e5dbea0 babe300 -- scripts tests docs/invariants.md` was empty. The only code-side
  changes there were one example table row in `docs/plan-format.md` (not the `Plan layers:`
  line) and worked-example text in `skills/build/SKILL.md`.

## Round-3 delta, verified (carried over, unchanged)

- Only `tests/skills-lint.test.sh` changed between 4f001fa and e5dbea0. The empty-list case
  (`tests/skills-lint.test.sh:331-337`) captures `rc=$?` straight after the substitution. Any
  exit code other than 1 fails and prints the code, and the message is checked only when the
  exit code is right.

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
- Re-anchor after the rebase onto main 95d17e3 (2859827): an empty
  `git diff 4ffdc25 2859827 -- scripts tests docs/invariants.md`, range-diff "=" on all 11
  commits, and main touched nothing in scope. skills-lint is clean. Scores and verdict carry
  over: 12/12, APPROVE. Regression note: same.
