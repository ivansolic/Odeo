---
artifact: usr-008-009-followups
type: code
branch: chore/usr-008-009-followups
reviewed_commit: 55cfd48
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
previous_total: 11/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

Re-review after the branch was rebased onto the new local main (69cef9e: hash-list migration and USR-010).
The first record (reviewed_commit a1fd31b) no longer anchors to this history, so it is regenerated at
`55cfd48`. Only what is new was reviewed: (1) the rebase conflict resolution in
`tests/odeo-migrate-legacy.test.sh`, (2) the README assertion total. The unchanged commits keep the
findings of record 1 (re-measured where noted).

Regression note: same (11/12 before, 11/12 now). The one Important from record 1 is still open.

## Mutation results (each mutant applied, suite run, file restored, `git status` verified clean)

| Mutant | Target | Result |
|---|---|---|
| M28 RETIRED_AGENTS without code-reviewer.md | scripts/odeo-migrate-legacy.sh:115 | 2 FAIL (case 2: moved, kept in legacy), as the header claims |
| M29 RETIRED_BIN without boundary-check.sh | scripts/odeo-migrate-legacy.sh:117 | 2 FAIL (case 2: moved, kept in legacy), as the header claims |
| fixture hash list without `agent code-reviewer <hash of 'odeo'>` | tests/odeo-migrate-legacy.test.sh (fixture_list) | 2 FAIL (case 2): the added fixture line is load-bearing, not decoration |
| C13 guard back to `[[ -d agents ]]` | scripts/skills-lint.sh:216 | 0 FAIL (GREEN): still not covered, see Important |

Suites re-run on this commit, all green: `tests/odeo-migrate-legacy.test.sh` (123 ok),
`tests/skills-lint.test.sh` (93 ok), `tests/git-guards.plugin.test.sh` (19 ok),
`.claude/maintainer/tests/removed-items.test.sh` (86 ok).
`docs-claims-check.sh --assertions` reports 1618, matching the README. Not run, known and not caused
here: `.claude/maintainer/tests/legacy-hashes.test.sh` is RED because branch docs/prd-003-pm-content-depth
added a skill-reviewer version (USR-029).

## Critical (must fix before merge)
- none

## Important (should fix)
- scripts/skills-lint.sh:216 and tests/skills-lint.test.sh:125, carried over from record 1 and re-measured:
  the C12 comment justifies its guard as matching C13 ("as C13 does"), but C13's own guard has no test.
  Reverting line 216 to `[[ -d "$ROOT/agents" ]]` leaves all 93 assertions green. Fix: add one case, a root
  with no `agents/` and a repo-only agent that has `effort:` but lacks the output-language rule, asserting
  `flags ... C13`; record its mutation in the header. Follow-up, not a merge blocker (pre-existing guard).

## Nitpicks (optional)
- tests/odeo-migrate-legacy.test.sh:50, the M28/M29 block is headed "Observed failing (2026-10-29)" but sits
  after the 2026-10-30 block (M25-M27). Order or date reads backwards. Re-date it to the day the mutants were
  run on the rebased code, or move it above the 2026-10-30 block.
- Record 1 nitpicks still stand: scripts/skills-lint.sh:108 `x.sh-based` residual (no instance in the
  tree), and tests/git-guards.plugin.test.sh:29-33 absence claim "the only mutant found" (narrow to
  "M10 is the mutant that turns case 1 RED").

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 2/2  -> total 11/12  (threshold: >=9, no zero)

## Ceiling
12/12. Testing is 1 only because the C13 half of the guard pair is uncovered; one added case lifts it.

## What's good
- The rebase resolution is correct: since agents now move only on a hash match, case 2 needed the
  `code-reviewer` entry in the fixture list, and removing it turns exactly case 2 RED, so the fixture and
  the RETIRED_AGENTS/RETIRED_BIN claims are both proven by mutation, not asserted.
- Renumbering to M28/M29 avoids the collision with main's M14-M27, and both claimed counts (2 FAIL each)
  reproduced exactly.
- The README total 1618 matches the measured count, and the tree was clean after every mutation.

## History
- Round 1 (a1fd31b): 11/12 APPROVE WITH COMMENTS; C13 guard coverage gap found.
- Round 2 (55cfd48, this record): regenerated after rebase onto 69cef9e; rebase resolution verified, same
  score, the C13 gap is unchanged.
