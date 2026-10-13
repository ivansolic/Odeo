---
module: skills/merge (step 5 squash), stacked branches in any repo
tags: [git, squash, stacked-branches, rebase, merge, review-fix, conflict]
problem_type: pattern
provenance: Odeo-personal PR #2 (2026-10-13); measured 2026-10-13 in a throwaway repo,
  git 2.50.1 (Apple Git-155)
reuse_count: 0
created: 2026-10-13
---

# Squash-merging stacked branches one by one conflicts only if the lower branch changed after the upper one was cut

## Context
Branch B is created on top of branch A (B contains A's commits). Both should reach main,
and the merge method is squash. The tempting belief is that squashing A and then B
"duplicates A's change", so the stack must be merged as one PR.

## Guidance
- The belief is false in the plain case. Measured: A adds a line, B (cut from A) adds
  another line elsewhere in the same file; squash A into main, then squash B. Clean
  result, A's line appears once. A three-way merge recognizes the identical change.
- The real trap: A changes AFTER B was cut (typically a review fix on A). Measured: same
  setup, then A's line is edited on A, A is squashed, then B is squashed. CONFLICT on
  A's line: main holds the reviewed version, B holds the original. A squash never makes
  A an ancestor of main, so git compares against the old base and sees two different
  edits of one line.
- Resolving that conflict toward B ("theirs") silently reverts the review fix. Resolve
  toward main's side for every hunk that belongs to A.
- Simplest ways around it: rebase B onto main after A is merged (drop A's original
  commits), or merge the stack as ONE PR with rebase-merge so each commit stays separate.

## Why it matters
The wrong belief makes people (and agents) restructure PRs for no reason; the real trap
loses a reviewed fix without any test failing, because the conflict looks like ordinary
noise.

## When to apply
Any time a branch was cut from another unmerged branch and the project squash-merges
(`/odeo:merge` step 5 defaults to squash).

## Examples
Odeo-personal PR #2: `docs/story-rules` was cut from `chore/plan-shape-human-layer`. I
first claimed two squashes would duplicate the plan-shape change and merged one combined
PR with `--rebase`. Measuring afterwards showed the two-step squash would have been clean
there, since the review fixes landed on the UPPER branch, not the lower one. The combined
PR was simpler, not required.
