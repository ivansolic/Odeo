---
artifact: chore-phase1-quick-wins
type: code
branch: chore/phase1-quick-wins
reviewed_commit: 6de448d
artifact_version: 2
date: 2026-10-22
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
---

# Code review: chore/phase1-quick-wins, round 2

## Scope reviewed

`git show 6de448d` (the round-1 fix commit, 13 files) against the round-1 findings, plus a
repo-wide grep for remaining `bin/` mentions at 6de448d. Excluded as instructed: `docs/evals/`
history, legacy-layout test fixtures, `.claude/worktrees/`. Dated plans and ADRs under
`docs/plans/` and `docs/decisions/` describe the layout of their time and are history too.

Checked by running, in a scratch `git archive` of 6de448d (never in the working tree):
- `tests/session-end-check.test.sh`: 22/22 green (21 plus the new exit-0 assert), so the
  README total of 1572 (1571 + 1) is consistent with this suite's delta. The full-suite
  `--assertions` count is being run separately by the caller and was not repeated here.
- `scripts/skills-lint.sh .`: exit 0.
- `scripts/docs-claims-check.sh`: 27 programs, 39 suites, 27 own suites, all match.

## Round-1 findings, verified

1. I1 (backup claim): fixed. `scripts/session-end-check.sh:81` now says "move finished tasks
   out (what matters goes into the commit, PR or lessons.md first)", with no backup claim.
   `global/CLAUDE.md:184` now says only a configured git ledger backup keeps older versions,
   which is true for the default (no backup) and for `dir` mode. The hook's exit path did not
   change, so it still always exits 0.
2. I2 (stale "next release"): fixed. `README.md:116-117` now matches `INSTALL.md:139-141`
   word for word on the substance ("releases after 0.3.5 no longer ship ... only while an
   older Odeo copy is still in the plugin cache"). The orphaned comment in
   `docs/public-paths.txt` is gone and the path list is unchanged.
3. I3 (runnable `bin/` commands): fixed. All five references in
   `docs/checklists/language-live-check.md` now point at `scripts/`, and every target exists.
   The `scripts/merge-gate.sh:206-218` reference still lands exactly on the verdict read and
   its `case`.
4. Nitpicks: M7 and M12 now name `tests/fixtures/legacy-bin-wrapper.sh`; the six comments
   now say `scripts/`; the 150-line case asserts exit 0.

The remaining `bin/` mentions in live files (README:66,86, INSTALL:140,
`hooks/odeo-context.sh`, the legacy-layout test cases, the skills-lint C16 fixtures)
describe the 0.2.x layout or the host's refusal of a `bin/` folder. None is a runnable
reference to a removed program.

## Verdict

APPROVE. All three Important findings and all nitpicks from round 1 are fixed, and the fix
commit adds no new defect.

## Nitpicks

- `tests/git-guards.plugin.test.sh:23`: "does not forward-> 2 FAIL" is missing a space
  before the arrow. Write "does not forward -> 2 FAIL".
- `README.md:116-117`: the two edited lines run to about 140 characters while the rest of
  the paragraph wraps at about 90. Re-wrap to match. Rendering is unaffected.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

Ceiling: 12/12, reached.

## Top findings

- None blocking. Two cosmetic nits (a missing space in a mutation note, README line wrap).

## Regression note

Better than round 1 (b402a49, APPROVE WITH COMMENTS, 9/12) -> round 2 (6de448d, APPROVE,
12/12). Correctness 1 -> 2 (no backup claim without a backup), readability 1 -> 2 (stale
comments and mutation notes re-pointed), conventions 1 -> 2 (no "next release" claims left,
and the checklist commands run). Security, performance and testing stayed at 2.

## History

- Round 1 at b402a49: APPROVE WITH COMMENTS, 9/12. Important: unconditional "the ledger
  backup keeps the history" claim; stale "next release" text in README.md and
  docs/public-paths.txt; runnable `bin/` commands in docs/checklists/language-live-check.md.
- Round 2 at 6de448d: APPROVE, 12/12. All fixed by 6de448d.
