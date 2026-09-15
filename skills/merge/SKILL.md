---
description: Integrate a finished, reviewed story branch into main, safely and with a clean linear history. Rebases onto the latest main, runs tests, then merges the PR and cleans up. Run once per story when it is approved and ready. Claude does the git mechanics; you approve.
disable-model-invocation: true
---

The integration step. Brings an approved branch into main with a clean, linear
history (rebase, not merge commits). You trigger it; Claude does fetch + rebase +
tests + merge. Offered by both `/build` modes when a story is approved.

**This command NEVER starts itself.** It runs only when the user invokes it or
answers an offer with an explicit yes. "The reviews passed", "the pipeline
continues", "the user merged the last one" are not permission, the merge is the
human floor.

## Preconditions
- The branch is built, reviewed (code-reviewer, and design-reviewer if UI), and you approve it.
- You are on the story's feature branch.

## Steps
0. **The gate (ENFORCED, run it first and STOP on non-zero):** `merge-gate.sh`
   (in `~/bin` or `bin/`). It refuses deterministically when: you're on main, the
   working tree is dirty, no review record exists in `docs/evals/` for this
   branch, or a DO-NOT-TOUCH boundary was violated (`boundary-check.sh`). Fix
   what it names (usually: run the reviewers so the record exists), re-run, only
   then continue.
1. `git fetch origin` (get the latest main).
2. `git rebase origin/main`, replay this branch's commits on top of the latest main.
   - **Conflict?** Read both sides, understand each change's intent (from the story and code), resolve: keep both if complementary, otherwise the version that meets the requirements/tests. If genuinely ambiguous, **ask the user.** Never weaken a test to resolve.
3. Run tests + typecheck, HERE, and see them pass. **A suite that has never been
   executed is not green.** "Deferred to CI" only counts if CI actually exists
   (check `.github/workflows/` or equivalent); if it doesn't, run the FULL suite
   locally (non-watch: `vitest run`, not bare `vitest`) and watch it pass, and
   offer once: "no CI here yet, want me to set it up so every PR gets tested
   automatically? (/ci, ~2 minutes)". If red after rebase, fix before proceeding.
4. If the branch was already pushed, update it: `git push --force-with-lease`
   (safe: only your own unshared branch; refuses if someone else changed it).
   First push to a fresh remote? Also run `git remote set-head origin -a` once,
   so tools that resolve `origin/HEAD` (e.g. the built-in /security-review) work.
5. Merge the PR into main (squash for a clean history): `gh pr merge --squash` (or fast-forward).
6. Clean up: `git checkout main && git pull`, delete the branch local + remote.
7. **Close by compounding, not by trailing off.** If this story solved anything
   non-trivial, name it and what it cost, then offer `/learn` warmly and
   concretely ("that capture-parser detour cost an hour; /learn banks it so next
   time it's free, want me to draft the entry?"). Never present it as
   skippable hygiene; it is how the system gets smarter with every story. If
   several stories merged since the last `/retro`, say so and offer it too.
   If the merged diff touched behavior the docs describe (a supported format, a
   flag, an endpoint, a default in README/docs/CLAUDE.md), offer `/sync-docs`
   once, stating why ("this changed the export format the README documents, want
   me to reconcile the docs?"), never after a decline.
   (Draft-first: the user approves anything saved. A "no" is final, no nagging.)

## Worked example
```
> /merge                          (on feature/usr-012-timer, reviewed, you approved)
merge-gate: preconditions hold (branch 'feature/usr-012-timer', 1 record(s) checked: docs/evals/code-feature-usr-012-timer.md)
fetch + rebase onto origin/main: clean
tests + typecheck: green
gh pr merge --squash: merged
cleanup: back on main, branch deleted local + remote
-> "USR-012 integrated. Next by dependency: USR-013. About a week after shipping, run /outcome."
```

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
