---
description: Integrate a finished, reviewed story branch into main, safely and with a clean linear history. Rebases onto the latest main, runs tests, then merges the PR and cleans up. Run once per story when it is approved and ready. Claude does the git mechanics; you approve.
disable-model-invocation: true
---

The integration step. Brings an approved branch into main with a clean, linear
history (rebase, not merge commits). You trigger it; Claude does fetch + rebase +
tests + merge. Used by both `/build` modes when a story is approved.

## Preconditions
- The branch is built, reviewed (code-reviewer, and design-reviewer if UI), and you approve it.
- You are on the story's feature branch.

## Steps
1. `git fetch origin` (get the latest main).
2. `git rebase origin/main` , replay this branch's commits on top of the latest main.
   - **Conflict?** Read both sides, understand each change's intent (from the story and code), resolve: keep both if complementary, otherwise the version that meets the requirements/tests. If genuinely ambiguous, **ask the user.** Never weaken a test to resolve.
3. Run tests + typecheck. Must be green. If red after rebase, fix before proceeding.
4. If the branch was already pushed, update it: `git push --force-with-lease`
   (safe: only your own unshared branch; refuses if someone else changed it).
5. Merge the PR into main (squash for a clean history): `gh pr merge --squash` (or fast-forward).
6. Clean up: `git checkout main && git pull`, delete the branch local + remote.

## Parallel / multiple stories
Integrate **one at a time**, serialized. Each branch rebases onto the now-updated
main (which may already include a sibling story), so conflicts surface and resolve
one by one.

## With contributors (multiple people)
- Rebase + force-with-lease only on **your own unshared branch.** **Never rewrite a
  branch someone else is working on** (it breaks their copy). For shared branches,
  coordinate or merge instead of rebasing.

## Safety rules
- Never merge without the user's approval.
- Never force-push a shared branch; `--force-with-lease` only on your own.
- Tests must be green after rebase before merge.
- Conflicts: resolve by understanding intent + tests; ask if ambiguous; never weaken tests.
