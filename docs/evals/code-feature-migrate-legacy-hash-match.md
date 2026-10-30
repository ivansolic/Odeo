---
artifact: migrate-legacy-hash-match
type: code
branch: feature/migrate-legacy-hash-match
reviewed_commit: a26d1dc
artifact_version: 2
date: 2026-10-30
scorer: code-reviewer
model: claude-sonnet-5-5
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 10/12
verdict: APPROVE
---

# Code review: feature/migrate-legacy-hash-match, round 2

## Scope reviewed

- Delta `git diff 9a67e35..a26d1dc` (two files, one line each): `tests/odeo-migrate-legacy.test.sh`
  (case 23 else-branch) and `.claude/maintainer/tests/legacy-hashes.test.sh` (last block).
- Round 1 findings and its 15 mutation results stand and were not redone (per dispatch).

## Regression note

Better: 10/12 -> 12/12. The single Important finding (lowercase `skip:` breaking the
`SKIP <n> - <reason>` contract of `scripts/docs-claims-check.sh`, which CI would hit because it has
no `dev-phase-archive` tag) is closed. The round 1 nitpick (same form in the maintainer suite) is
closed too. No new findings.

## Verification of the fix, by mutation

Throwaway clone outside the repo: `git clone --no-tags`, branch tip a26d1dc checked out, `git tag`
returns nothing (no `dev-phase-archive`, so the else branch is taken).

| State | `bash scripts/docs-claims-check.sh --assertions` | Result |
|---|---|---|
| as shipped (`SKIP 1 - no dev-phase-archive tag ...`) | accepts: notes "3 assertion(s) in 2 skipped case(s) were added back", `ok: assertions = 1525`, exit 0 | GREEN |
| mutant: line changed back to `skip: no dev-phase-archive ...` | `UNCOUNTED SKIP: tests/odeo-migrate-legacy.test.sh prints a skip line without a valid count`, total measured 1524 vs README 1525 reported UNVERIFIED, exit 1 | RED |

The fixed form returns the README total (1525) on a machine without the tag; the old form is
refused. The mutant was reverted in the clone with `git checkout`.

Maintainer suite: `bash .claude/maintainer/tests/legacy-hashes.test.sh` still ends `ALL PASS`
(its skip block is the not-taken branch here; docs-claims does not read that suite, so the change
is consistency only, as the round 1 nitpick said).

Real tree: clean except this record.

## Critical

None.

## Important

None.

## Nitpicks

None new. The round 1 note on the per-call grep of `$KNOWN` in `scripts/odeo-migrate-legacy.sh`
stands as "no action".

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling

12/12. Nothing structural caps this change.

## What's good

- The fix is minimal and exact: one line per file, same form the checker documents and tests.
- The RED/GREEN was provable in a tagless clone, which is the CI condition, not only the
  maintainer's clone where the tag masks the problem.

## History

- Round 1 (9a67e35): REQUEST CHANGES 10/12. One Important: lowercase `skip:` in case 23 would
  make the CI assertion count check exit 1. Mutation results: 15 mutants, all RED.
- Round 2 (a26d1dc): finding closed, APPROVE 12/12.
