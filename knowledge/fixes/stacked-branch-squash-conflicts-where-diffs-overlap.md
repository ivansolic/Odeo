---
module: skills/merge (step 5 squash), stacked branches in any repo
tags: [git, squash, stacked-branches, rebase, rebase-onto, merge, review-fix, conflict]
problem_type: pattern
provenance: Odeo-personal PR #2 (2026-10-13); measured 2026-10-13 in throwaway repos with
  `git merge --squash` (not GitHub's own squash), git 2.50.1 (Apple Git-155), 8 cases
  reproduced independently by code-reviewer and the author
reuse_count: 0
created: 2026-10-13
---

# Squashing stacked branches in turn conflicts where the two diffs overlap

## Context
Branch B is cut from branch A (B contains A's commits). Both should reach main, and the
merge method is squash. Two tempting beliefs: "squashing A and then B duplicates A's
change", and "it only breaks if A changed after B was cut". Both are wrong.

## Guidance
- Why it can conflict at all: a squash never makes A an ancestor of main, so the second
  squash merges B against the OLD base. B's side still carries A's original changes, and
  git compares them with main's version of A. It conflicts wherever those two diffs
  overlap or touch adjacent lines; elsewhere it is clean, and A's change is not duplicated.
- Measured (A adds a line, B cut from A adds a line elsewhere, squash A, then squash B):
  - plain stack, nothing else changed: clean, A's line appears once;
  - A edits its own line after B was cut (typically a review fix): CONFLICT;
  - A unchanged, B edits A's line: CONFLICT;
  - A unchanged, B adds a line right next to A's line: CONFLICT;
  - A changes a line far from both branches' edits after the cut: clean.
- Safe route, no manual resolution: before squashing B, note the A commit B was cut from
  (`git merge-base A B` while A still exists, or record its sha), squash A, then
  `git rebase --onto main <old-A-tip> B` and squash B. Measured clean, and both A's review
  fix and B's work survive. A plain `git rebase main` on B still conflicts (measured).
- If you resolve by hand, the correct result is main's version of A's lines PLUS every
  change B made itself, i.e. everything in `git diff <old-A-tip> B`, including B lines
  that sit inside a hunk touching A's lines. Taking B's side wholesale reverts A's review
  fix; taking main's side wholesale drops B's own edits. Mind that ours/theirs swap
  meaning between a merge and a rebase.
- Simplest of all: merge the stack as ONE PR with rebase-merge, so each commit stays
  separate and no second squash happens.

## Why it matters
The conflict looks like ordinary noise, and either "pick one side" reflex silently loses
reviewed work in one direction or the other, with no test failing.

## When to apply
Any time a branch was cut from another unmerged branch and the project squash-merges
(`/odeo:merge` step 5 defaults to squash).

## Examples
Odeo-personal PR #2: `docs/story-rules` was cut from `chore/plan-shape-human-layer`. I
first claimed two squashes would duplicate the plan-shape change and merged one combined
PR with `--rebase`. Measuring afterwards: at decision time the two-step squash would have
been clean (no overlapping edits), but the review fixes then committed on the upper branch
(`8c5d29e` on main) edited plan-shape lines, the "B edits A's line" case, so after them it would
have conflicted. The one-PR route avoided that by construction. The first draft of this
entry then over-corrected ("only if the lower branch changed") and told the reader to
resolve toward main, which would drop B's own edits; review reproduced 8 cases and
caught both.
