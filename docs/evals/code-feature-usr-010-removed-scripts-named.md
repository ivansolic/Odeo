---
artifact: usr-010-removed-scripts-named
type: code
branch: feature/usr-010-removed-scripts-named
reviewed_commit: 9e320ca
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 10/12
---

## Scope reviewed

Round 2: `git diff 6900e5b..9e320ca` (installer, session-start hook, two test files, README,
INSTALL) plus whether each round-1 finding is closed. Round 1 (the delta ae7bd4e..6900e5b)
stands for everything this delta does not touch; see History. I re-ran the four suites this
branch touches (ALL PASS) and `docs-claims-check.sh` (clean). The known-RED
`legacy-hashes.test.sh` (USR-029, other branch) is not counted.

## Round-1 findings: closure

- Important 1 (hooksPath into the versioned project): closed. `scripts/install-git-guards.sh`
  now exits 3 before anything is created or moved when the hooks directory lies inside the work
  tree and outside the common git dir. Probes: `.githooks` existing, `.githooks` missing, a
  relative path run from a subdirectory, a symlink in the tree, and a linked worktree (hooks go to
  the main `.git/hooks`, installed normally). One hole remains, see Important 1 below.
- Important 2 (user's other checks stop): closed in the nudge, README and INSTALL; asserted.
- Nitpick 3 (caveat asserted), 4 (stale clauses aligned), 8 (README wording): closed.
- Nitpicks 5, 6, 7: left as follow-ups by decision; unchanged, not re-scored.

## Mutations run (each restored byte-identical)

| id | mutation | result |
|----|----------|--------|
| Y1 | the `.git`-dir exemption removed (default hooks dir would count as inside the tree) | 24 FAIL |
| Y2 | `pwd -P` replaced by `pwd` (symlinked tmp paths) | 4 FAIL |
| Y3 | refusal exits 0 instead of 3 | 1 FAIL |
| Y4 | work-tree prefix match without the trailing slash (`/x/proj-hooks` counts as inside `/x/proj`) | 0 FAIL, survives (finding 2) |
| Y5 | the pre-push "unless it also mentions a removed script" clause deleted | 0 FAIL, survives (wording only) |

The author's I16, I17 and M37-M39 were not re-run; Y1 and Y3 cover the same refusal paths and
the new message assertions are present in the diff.

## Findings

### Important
1. `scripts/install-git-guards.sh:36`: the guard resolves the hooks directory through
   `cd "$(dirname "$hooks_dir")"`. When the PARENT does not exist, that `cd` fails, the result
   becomes `/<basename>`, and the guard passes. Probe: `core.hooksPath = tools/githooks` in a
   project with no `tools/` directory: exit 0, `tools/githooks/pre-commit` created inside the
   project. The documented promise is "nothing touched or created". Nothing of the team's is
   replaced in this case (the directory did not exist), so the harm is a new untracked hook
   directory, but the guard does not hold its stated invariant. Fix: climb to the nearest existing
   ancestor (`d=$hooks_dir; while [ ! -e "$d" ]; do d=$(dirname "$d"); done`), resolve that with
   `pwd -P`, and append the remainder; add a case with a missing parent to the test.

### Nitpicks
2. Y4 survives: no test has a hooks directory whose name shares the work-tree path as a prefix
   (`<repo>-hooks` beside `<repo>`). The shipped `"$work_top"/*` is correct; the mutant would
   refuse a legitimate sibling directory. Add one case.
3. Y5 survives: the pre-push clause wording is not asserted. Cosmetic.
4. Follow-ups 5, 6 and 7 from round 1 remain open as agreed (window without a pre-commit between
   the two moves; duplicated matcher in two files; message repeats on `/clear` and compaction).

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 11/12 (threshold >=9, no zero)

## Ceiling

12/12 reachable. Correctness is held at 1 by Important 1.

## History

Round 1 (6900e5b): 10/12, APPROVE WITH COMMENTS. Important: a core.hooksPath inside the
versioned project had its tracked hook replaced and an untracked copy left; the nudge did not tell
the user that other checks in a replaced pre-commit stop. Nitpicks: unasserted caveat, stale
nudge clauses, window without a pre-commit, duplicated matcher, repeat on clear and compact,
README wording. Trajectory: 10/12 -> 11/12; both Importants closed, one narrower hole found in
the new guard.
