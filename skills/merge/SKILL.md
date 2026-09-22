---
description: Integrate a finished, reviewed story branch into main, safely and with a clean linear history. Checks that the remote really is this branch's upstream, then rebases onto the latest main, runs tests, merges the PR and cleans up; when the remote is a publication rather than an upstream, it integrates locally instead and says so. Run once per story when it is approved and ready. Claude does the git mechanics; you approve.
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
1b. **Confirm `origin/main` is this branch's upstream BEFORE rebasing onto it.** Ask about
   LINEAGE, not about how big the gap is: a gap is normal, a separate lineage is not.
   `--is-ancestor` answers with its EXIT STATUS and prints nothing, so make it speak, or you
   will be reading silence and calling it inconclusive:
   ```
   git merge-base --is-ancestor main origin/main && echo "BEHIND: rebase applies"
   git merge-base --is-ancestor origin/main main && echo "AHEAD: nothing to rebase"
   ```
   If NEITHER line prints, the two have diverged, which is still ordinary when someone else
   pushed while you worked. So ask the one question that separates the two cases: **do your
   commits ever reach that remote directly, or does this project publish through a separate
   step?** A pre-push hook that refuses the remote, a publish or snapshot script, a denylist
   of internal paths: any of those means the remote is a PUBLICATION, not your upstream, and
   its history is a different lineage that will never contain your commits.
   **Ask it on AHEAD too, not only on diverged.** A publication remote that was once seeded
   by a direct push reads as "you are ahead", and "ahead" invites steps 4, 5 and 6, which is
   the push this whole check exists to prevent. Ancestry tells you the shape of the gap; only
   that question tells you what the remote IS.
   **When the answer is "a separate step":** do NOT rebase onto
   that remote, do not push the branch there, do not `git pull` `main` from it. Integrate
   into your LOCAL `main`, publish through that step, and say so instead of improvising. Rebasing would replay your commits onto a lineage that
   never held their ancestors, and resolving those conflicts is exactly how content that
   belongs to one history gets dragged into the other.
   Do not reach for a size rule: `git rev-list --left-right --count main...origin/main`
   describes the gap, and two lineages are two lineages on the day they split, when the
   count is still tiny. `git merge-base` is not decisive here either: two lineages usually
   DO share an old root commit, so it is rarely empty. Ancestry plus the question above is
   what holds.
2. **Only once 1b says `origin` is your upstream:** `git rebase origin/main`, replay this
   branch's commits on top of the latest main. (If 1b said publication, skip to "Two
   histories" below; steps 2, 4, 5 and 6 do not apply.)
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
   (`git pull` here is the same hazard as step 2 in a second costume: it merges the remote
   line into your local `main`. Upstream-only, per 1b.)
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
upstream check: main is an ancestor of origin/main -> ordinary upstream, rebase applies
fetch + rebase onto origin/main: clean
tests + typecheck: green
gh pr merge --squash: merged
cleanup: back on main, branch deleted local + remote
-> "USR-012 integrated. Next by dependency: USR-013. About a week after shipping, run /outcome."
```

## Two histories (when 1b says the remote is a publication)
Same gate, different back half. Do not rebase, do not push the branch there, do not
`git pull` main from it.
```
> /merge                          (on docs/fix-the-thing, reviewed, you approved)
merge-gate: preconditions hold (branch 'docs/fix-the-thing', 1 record(s) checked: docs/evals/skill-merge.md)
upstream check: neither main nor origin/main is an ancestor of the other,
                and a pre-push hook refuses this remote -> PUBLICATION, not upstream
integrate: git checkout main && git merge --ff-only docs/fix-the-thing
tests: green on main after the merge
push: to the private working remote only
-> "Merged into local main and backed up. Publishing is a separate step: say the word and
    I run the project's publish script, which builds a clean tree and re-verifies it."
```
The counts are worth seeing but never deciding on: a project can read `278  3` or `6  3`
and be the same case, because two lineages are two lineages from the day they split.

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
- Never treat a remote as this branch's upstream without the step-1b ancestry check. When it is a
  publication, steps 2, 4, 5 and 6 do not apply: there is no PR to merge on that remote, pushing
  the working branch there is what the project's publish step exists to prevent, and `git pull`
  in step 6 would merge that line into your `main` just as a rebase would.
- Never force-push a shared branch; `--force-with-lease` only on your own.
- Tests must be green after rebase before merge.
- Conflicts: resolve by understanding intent + tests; ask if ambiguous; never weaken tests.
