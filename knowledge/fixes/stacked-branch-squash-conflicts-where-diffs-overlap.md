---
module: skills/merge (step 5 squash), stacked branches in any repo
tags: [git, squash, stacked-branches, rebase, rebase-onto, merge, review-fix, conflict]
problem_type: pattern
provenance: Odeo-personal PR #2 (2026-10-13); measured 2026-10-13 in throwaway repos with
  `git merge --squash` (not GitHub's own squash), git 2.50.1 (Apple Git-155); every
  table cell run by code-reviewer or the author and the shared cells by both
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
- Measured. Setup: one file; A adds one line; B, cut from A, adds one line elsewhere; then
  the extra edit in the row; A is squashed into main first. Columns: what happens to B.
  `old-A-tip` is the A commit B was cut from (`git merge-base A B` while A exists, or
  record its sha before A is deleted).

  | # | Extra edit | squash B | `rebase --onto main old-A-tip B` | `rebase main` |
  |---|---|---|---|---|
  | 1 | none | clean | clean | clean |
  | 2 | A edits its own line after the cut (review fix) | CONFLICT | clean | CONFLICT |
  | 3 | B edits A's line | CONFLICT | clean | clean |
  | 4 | B adds a line right next to A's line | CONFLICT | clean | clean |
  | 5 | rows 2 and 4 together | CONFLICT | CONFLICT | CONFLICT |
  | 6 | A edits a line far from both after the cut | clean | clean | clean |
  | 7 | rows 2 and 3 together (both edit A's line) | CONFLICT | CONFLICT | CONFLICT |

  Every clean result kept A's latest lines and all of B's lines, and A's line appeared once.
- Rule: use `git rebase --onto main old-A-tip B`, then squash B. It is clean in rows 1 to
  4 and 6, and conflicts only when A revised its lines after the cut AND B changed the
  same or adjacent lines (rows 5 and 7).
- Rows 5 and 7 are a human judgment call: both branches changed the same lines, so no
  route and no side is right. Write the combined lines by hand (B's intent on top of A's
  revision) or ask the authors; never take either side wholesale, since one side holds
  A's review fix and the other holds B's work.
- Do not resolve a squash conflict by picking a side in rows 2 to 4 either: there the
  right result is main's version of A's lines plus everything in
  `git diff old-A-tip B`. The `--onto` route produces exactly that with no conflict, so
  prefer it. Ours/theirs swap meaning between a merge and a rebase.
- Scope: measured on one-line edits in one file. The rule follows from git's three-way
  merge, but re-check against the table rather than extend it by analogy.
- Avoiding the question: merge the stack as ONE PR with rebase-merge, so no second
  squash happens.

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
