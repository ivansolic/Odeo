---
artifact: feature-review-loop-ends-at-approve
type: code
branch: feature/review-loop-ends-at-approve
reviewed_commit: 4a83eaf
artifact_version: 3
date: 2026-10-23
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: feature/review-loop-ends-at-approve, round 3 (re-anchor)

## Scope reviewed

- `git show 4a83eaf` in full, and `git diff --stat 0fabcd5..4a83eaf`: outside `docs/evals/`
  only `scripts/merge-gate.sh` (+3/-2, refusal text) and `tests/merge-gate.test.sh`
  (+4/-4, comment rewrap) moved. 13 changed content lines in total, all in one `echo` block
  and one comment block. No logic, list or pathspec changed (`bash -n` clean).
- `grep` for the old wording across tests/, docs/ (records excluded), skills/, AGENTS.md and
  README.md: no test or document quotes the refusal text, so the reword breaks nothing.
- Round-2 findings carried forward below. The round-2 probe and mutation evidence stands,
  because the gate's PROSE_FILES, PROSE_DIRS and NOT_PROSE are byte-identical at 4a83eaf.
  Test suite not re-run (builder reports 88/88; no executable line changed).

## Round-2 nitpicks, verified

1. `scripts/merge-gate.sh:312-314`, refusal text: FIXED. It now says "outside the
   plain-prose lists" and "(README and the like, and Markdown under knowledge/, plans and the
   other prose directories, do not count; any other file there does)", which matches the
   behavior since 0fabcd5 (`:(exclude,glob)<dir>/**/*.md`) and the comment at line 55. A user
   refused for `knowledge/run.sh` is now told why. Lines are 91 to 95 columns.
2. `tests/merge-gate.test.sh` 17b header width: NOT FIXED, MOVED. The first three lines are
   now 81 to 87 columns, but the rewrap stopped early: line 260
   (`#      AGENTS.md) and a path on no list (fail-closed). The change lands after the
   record, so the 3d ordering check is`) is 117 columns, wider than the 106 it replaced.

## Findings

### Critical

None.

### Important

None.

### Nitpicks (code comments: to the follow-up list, not another round)

- `tests/merge-gate.test.sh:260`, 117 columns after the partial rewrap. Fix: break after
  "(fail-closed)." so the line reads `#      AGENTS.md) and a path on no list (fail-closed).`
  and continue `#      The change lands after the record, so the 3d ordering check is` on the
  next line. Cosmetic only: no project rule sets a width, and the same file already has
  other lines over 100 columns (lines 21, 30, 33 and others), so this does not merit a round.

### Accepted residuals (named, not findings)

- `docs/evals/` is excluded whole, so a non-Markdown file there after the review does not
  stale the record. Pre-branch behavior, bounded, documented in the gate's comment.
- A `.md` that is really something else (exec bit, symlink, Markdown a tool executes)
  passes as prose, by the human's decision.

## Security review

No `/security-review` needed: the change is an error message and a comment. The gate's
fail-closed behavior is unchanged from round 2.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached. The verdict is APPROVE WITH COMMENTS only because the width nitpick remains
(moved, not removed).

## Regression note

Same as round 2: 12/12 -> 12/12. One nitpick fixed (refusal text), one moved (header
width, 106 -> 117 columns on a different line). No new Important or Critical. Under the stop
rule in `docs/eval-framework.md` the loop already ended at round 2's approve; this round only
re-anchors the record to 4a83eaf, and the remaining nitpick goes to `.claude/tasks/todo.md`.

## History

- Round 1 (ccdd70e): 10/12, APPROVE WITH COMMENTS. Importants: prose directories excluded
  every file type (security); PRD/story comments vs spec-gate freshness; prose-only branch
  with REQUEST CHANGES.
- Round 2 (0fabcd5): 12/12, APPROVE WITH COMMENTS. Importants fixed and verified by probe
  and mutation; two nitpicks (stale refusal text, one header line width).
- Round 3 (4a83eaf): 12/12, APPROVE WITH COMMENTS. Re-anchor after the two nitpicks were
  applied at the human's request: refusal text fixed; header width moved to line 260
  (117 columns), carried as a nitpick. Nothing else outside docs/evals moved.
