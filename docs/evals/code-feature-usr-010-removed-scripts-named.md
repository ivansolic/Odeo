---
artifact: usr-010-removed-scripts-named
type: code
branch: feature/usr-010-removed-scripts-named
reviewed_commit: 6900e5b
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 2, security: 1, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 10/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

`git diff ae7bd4e..6900e5b` (9 files, stacked on feature/migrate-legacy-hash-match; only the
delta). Story USR-010 (PRD-002 R8) and the approved plan. Changed code read in full:
`scripts/install-git-guards.sh`, `hooks/odeo-context.sh`, `scripts/odeo-removed-scripts.txt`,
the four test files, README and INSTALL changes. I re-ran the four suites this branch touches
(all ALL PASS), `docs-claims-check.sh` (clean) and `skills-lint.sh` (clean). The known-RED
`legacy-hashes.test.sh` (USR-029, other branch) is not counted.

## Probes run by hand (fresh temp repos)

- core.hooksPath to a versioned `.githooks`: the tracked `pre-commit` is overwritten (git
  status `M`) and an untracked `pre-commit.odeo-old-*` appears beside it (`??`). Finding 1.
- Relative core.hooksPath run from a subdirectory: resolved correctly (`../.githooks`).
- Dangling symlink pre-commit: kept as a link, new file regular. Pre-commit that is a directory:
  moved aside whole. Unwritable hooks dir: fails before touching the old hook.
- Symlinked pre-push mentioning `merge-gate.sh`, path with a space: pre-push moved aside as the
  link, session-start silent afterwards, a planted AWS-shaped key is still refused on commit.
- Session start before the refresh names both hooks in one emission; hooks are only read.

## Mutations run (each RED or reported, then restored byte-identical)

| id | mutation | result |
|----|----------|--------|
| X3 | only the first removed name reported | 9 FAIL |
| X6 | stamp without pid | 8 FAIL |
| X7 | move_aside copies instead of moves | 4 FAIL |
| M1 | a name removed from the list (maintainer test) | 1 FAIL |
| M3 | extra `script` line in removed-items.txt | 1 FAIL |
| X1 | EXIT trap that removes the temp hook removed | 0 FAIL, survives (only matters on a failed run) |
| X2 | pre-push existence test `-e/-L` narrowed to `-f` | 0 FAIL, survives (near-equivalent: a dangling link has nothing to grep) |
| X4 | " Separately: " lead replaced by "Odeo: " | 0 FAIL, survives (cosmetic) |
| X5 | the "a comment that mentions it counts too" caveat deleted from the message | 0 FAIL, survives (finding 3) |

Author-declared survivors M31 and I15 reviewed and accepted as stated.

## Findings

### Important
1. `scripts/install-git-guards.sh:133-137` and `tests/install-git-guards.test.sh` ("core.hooksPath
   inside the repo"): with core.hooksPath pointing into the versioned project, the refresh
   replaces the team's tracked hook with a personal one carrying baked-in absolute paths and
   leaves an untracked backup that `git add .` will commit. The plan named this as Review Focus
   1 and as a stop-and-ask condition; the test instead asserts the behaviour as correct. Fix:
   detect a hooks directory inside the work tree (`git ls-files --error-unmatch` on the hook,
   or a path-prefix check against `git rev-parse --show-toplevel`) and refuse with an explanation,
   or write the aside file outside the work tree, and turn the test into the matching assertion.
2. `hooks/odeo-context.sh:295`: the refresh replaces the whole pre-commit. A user hook that
   mentions `merge-gate.sh` on one line and runs `npm run lint` on the next loses the lint
   until merged by hand; the installer prints that, the nudge to Claude does not. The story says
   the user must not silently lose a check. Fix: add one sentence to the nudge telling the user
   that every other check in the replaced hook stops until they merge it back from the kept copy.

### Nitpicks
3. Test gap: no assertion that the "comment counts too" caveat reaches the message (X5 survives),
   though the plan's Review Focus 2 requires it to be visible. Add an `assert_contains` in case 4g.
4. `hooks/odeo-context.sh:314`: the `hook:pre-commit` clause still says "it rewrites
   .git/hooks/pre-commit" and does not mention the kept copy; the `hook:pre-push` clause says
   "do not move it yourself" while a `removed:pre-push` clause in the same message says the
   installer moves it. Rare combination (no old Odeo installer wrote such a hook) but
   contradictory. Align the wording.
5. `scripts/install-git-guards.sh:133-137`: between moving the old pre-commit aside and the
   final `mv` of the new one there is a window with no pre-commit; if that `mv` fails, the secret
   scan is gone and only the stderr line says so. Keep the old file in place (hard link or `cp -P`
   to the aside name) and let the final `mv` replace it atomically.
6. The whole-token regex and the list reader are copied into the installer and the hook; only
   a comment ties them. Tests cover both, so drift is caught, but one sourced helper would
   remove the class.
7. "Once per session": SessionStart matches `startup|resume|clear|compact`
   (`hooks/hooks.json:4`), so the message repeats on `/clear` and compaction. One emission per
   event is true and tested; say so in the story's verification note or accept as a follow-up.
8. README (line ~119) still says the refresh "rewrites `.git/hooks/pre-commit` and `pre-push`",
   a pre-existing inaccuracy this branch's wording now sits next to.

## Contract check against the plan

Held: list file shape (4 names, sorted, non-executable, data, validated per line); hook reads
and never runs hooks; whole-token match; one emission; silence for current hooks; installer
keeps and never deletes; symlinks; pid-suffixed names; secret scan still blocks after refresh
(proved end to end by the test and by my probe); maintainer comparison with
`docs/removed-items.txt` goes RED on drift both ways. Not held: the plan's stop-and-ask
trigger for core.hooksPath into the project (finding 1).

## Scores

correctness 2/2 · security 1/2 · performance 2/2 · readability 2/2 · testing 1/2 ·
conventions 2/2 -> total 10/12 (threshold >=9, no zero)

## Ceiling

12/12 reachable. Security is held at 1 by finding 1; testing at 1 by the test that enshrines
it and the unasserted caveat (finding 3).

## History

Round 1, no previous record for this branch.
