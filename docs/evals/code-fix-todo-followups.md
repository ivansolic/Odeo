---
artifact: todo-followups
type: code
branch: fix/todo-followups
reviewed_commit: fe49a94
date: 2026-09-28
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 12/12
verdict: APPROVE
---

## Scope reviewed

`main..fe49a94`, ten commits. This is the final re-anchor, the end of the loop under the
cap. The only new commit is `fe49a94` (`git diff a0c357a..fe49a94`): `bin/install-git-guards.sh`
(how the mark is read), `tests/install-git-guards.test.sh` (a new bare-key case) and the
README count.

The change removes the whole class behind three consecutive notes (a literal `true`, a typo, a
bare key) instead of adding another spelling. `git config --bool --get` now decides. Only exit
1 (key unset) or the output `false` means off. Everything else keeps contract A on, including
exit 128 (a value git cannot parse). This follows the project's rule to eliminate a recurring
class rather than patch each instance, and I agree with it.

## Evidence run

- Full suite, all 38 `tests/*.test.sh` with `</dev/null`: rc=0, 0 FAIL lines.
- `bin/skills-lint.sh`: all invariants hold.
- `bin/docs-claims-check.sh --assertions`: rc=0, "every countable claim matches the tree".
  That covers the README count.
- Real pushes end to end. I installed the hook from `bin/install-git-guards.sh` into a fresh,
  unmarked repo and pushed to a fresh bare "public" remote each time:

  | Mark | Push |
  |---|---|
  | unset | allowed |
  | `maybe`, `TRUE`, `yes` | refused |
  | `false`, `0`, `off`, `""` | allowed |
  | bare key without `=` | refused |
  | multi-valued `false` then `true` (git takes the last) | refused |

  A plain project can still create `main` once and push a feature branch.
- Mutations, run in a scratch `git archive` copy:
  - only git's own `true` counting: the invalid-value case FAILs, as recorded;
  - the exit status ignored, so an unset key counts as on: 3 FAIL, the two plain-project cases
    and the pushed-tree mark check. The original bug comes back and the suite catches it.
- The round-1 to round-3 scenarios were reproduced end to end at 602d2cb. Since then the only
  change to the hook is how the mark is read, and that is covered above.

## Critical

None.

## Important

None.

## Named residuals (accepted, not a new round)

1. **Deliberate opt-out.** In a repo whose checkout and pushed commit both lack the list,
   `git config odeo.publishesSnapshot false` switches contract A off. It is a deliberate act
   on a local file, in the same class as `git push --no-verify`. It is not an accident path.
   In a repo that carries the list, the file sets the mark again on the next push.
2. **Tip only.** In an unmarked repo, only the pushed commit's tree is checked. A branch whose
   tip removed `docs/internal-paths.txt`, pushed from a checkout without it, is not
   recognised as publishing. Removing the list is a deliberate act.
3. **Client-side hooks** (existed before this branch): `--no-verify`, or a `core.hooksPath`
   pointing elsewhere, skips every guard. The coordinator reported one such broken
   `core.hooksPath` in this clone, which the human has since removed. Only server-side
   protection closes this.
4. **Case of the branch name** (existed before this branch): the main/master match is
   case-sensitive, so `refs/heads/Main` is not treated as main.

## Nitpicks

- `tests/install-git-guards.test.sh:166`: the recipe comment line runs past the file's wrap
  width. Cosmetic only.

## Ceiling

12/12 is reached. The residuals are deliberate-bypass or pre-existing classes, outside this
branch's scope.

## Trajectory

8/12 (REQUEST CHANGES) -> 9/12 (APPROVE WITH COMMENTS) -> 12/12 (APPROVE) -> 12/12
(re-anchor a0c357a) -> 12/12 (re-anchor fe49a94). Same as the previous record. The re-anchors
turned an open-ended list of spellings into git's own parser, which fails closed.

## History

- Round 1 at 22829a1: REQUEST CHANGES, 8/12.
  - Critical: contract A was keyed on the working tree; five checkout states leaked internal
    content to the public remote.
  - Importants: the test block sat inside an `if` condition, and no test covered those
    states.
- Round 2 at 55ffd49: APPROVE WITH COMMENTS, 9/12.
  - The mark lives in the repo config and is sticky.
  - Importants: the installer mark was untested behind a false mutation claim, and a list
    that arrived after install could still leak through an old checkout.
- Round 3 at 602d2cb: APPROVE, 12/12.
  - The hook reads the pushed commit's tree, the installer mark is tested, and the mark is
    read as a bool.
  - Nitpicks: the pushed-tree latch was untested, and an invalid mark value failed open.
- Re-anchor at a0c357a: APPROVE, 12/12. Both nitpicks were fixed; a bare-key fail-open was
  noted.
- Re-anchor at fe49a94: APPROVE, 12/12. The spelling class is eliminated: git's parser
  decides and fails closed.
- Operational, unchanged: this clone still runs the OLD, stricter pre-push hook, and no mark
  is set yet. Re-run `bin/install-git-guards.sh` after merge from a normal checkout.
