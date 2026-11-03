---
artifact: usr-010-removed-scripts-named
type: code
branch: feature/usr-010-removed-scripts-named
reviewed_commit: 56d9dd2
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

## Scope reviewed

Round 3: `git diff 9e320ca..56d9dd2` (the installer's hooks-directory guard and two new test
cases; the rest of the range is the previous eval record). Rounds 1 and 2 stand for everything
this delta does not touch; see History. I re-ran `tests/install-git-guards.test.sh` and
`tests/odeo-context.test.sh` (ALL PASS) and `docs-claims-check.sh` (clean). The known-RED
`legacy-hashes.test.sh` (USR-029, other branch) is not counted.

## Round-2 findings: closure

- Important 1 (guard passes when the parent of the hooks directory is missing): closed. The
  guard now climbs to the nearest existing ancestor and appends the missing part. Probes:
  `tools/githooks` with no `tools/` (exit 3, nothing created), `a/b/c/` with a trailing slash
  (exit 3), `newdir/../.githooks` (exit 3), a missing sibling outside the project
  `../outside-missing/hooks` (installed, as it should be).
- Nitpick 2 (Y4, sibling directory sharing the repo path prefix): closed by a test case.
- Nitpick 3 (Y5, cosmetic clause wording) and follow-ups 5, 6, 7: left open by decision.

## Mutations run (each restored byte-identical)

| id | mutation | result |
|----|----------|--------|
| Z1 | the climb replaced by `dirname` only (the round-2 bug) | 1 FAIL |
| Z2 | work-tree prefix matched without the trailing slash (Y4) | 1 FAIL |
| Z3 | the `.` and `/` stop conditions removed from the loop | 0 FAIL, equivalent (both always exist, so the loop never reaches them) |
| Z4 | missing parts appended in the wrong order | 0 FAIL, equivalent for the decision (only the prefix is compared) |

## Findings

### Nitpicks
1. `scripts/install-git-guards.sh:40`: a `core.hooksPath` that names a regular file makes
   `cd "$probe"` fail under `set -e`, so the script stops with a raw `cd: afile: Not a
   directory` and exit 1. Nothing is touched, so it is safe, but the message does not say why.
   Optional: test `[ -d "$probe" ]` and print "core.hooksPath is not a directory".
2. Open by decision from rounds 1 and 2: the window with no pre-commit between the two moves, the
   matcher duplicated in the installer and the hook, the message repeating on `/clear` and
   compaction, and the unasserted pre-push clause wording (Y5).

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold >=9, no zero)

## Ceiling

12/12, reached. No criterion is structurally capped.

## History

Round 1 (6900e5b): 10/12, APPROVE WITH COMMENTS. A core.hooksPath inside the versioned project
had its tracked hook replaced; the nudge did not warn that other checks stop.
Round 2 (9e320ca): 11/12, APPROVE WITH COMMENTS. Both closed; the new guard passed when the
parent of the hooks directory was missing.
Round 3 (56d9dd2): 12/12, APPROVE WITH COMMENTS. Trajectory 10 -> 11 -> 12; the loop ended on an
approve with only nitpicks left.
