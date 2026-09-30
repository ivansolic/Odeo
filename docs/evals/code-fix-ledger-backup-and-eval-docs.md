---
artifact: scripts/ledger-backup.sh + tests/ledger-backup.test.sh + scripts/docs-claims-check.sh + tests/docs-claims-check.test.sh + docs/system-map.md row 146
type: code
branch: fix/ledger-backup-and-eval-docs
reviewed_commit: 88e96c7
artifact_version: 2
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

# Code review: fix/ledger-backup-and-eval-docs, round 2 (re-anchored after rebase)

## Artifact

The branch is at `88e96c7`, rebased onto local `main` `8dd9ec6`. It was reviewed in round 2 at
`6873887` on `main` `3cf2fe1`. The re-anchor was verified here, not taken on trust:

- `git range-diff 3cf2fe1..b735066 main..HEAD` shows `=` on all 8 commits (`f2a7d39`->`11dde04`,
  `830b72d`->`8dcee01`, `1695501`->`a5dab72`, `2b772ab`->`687107a`, `7e0034c`->`d2d3e80`,
  `2c789ac`->`815e1b9`, `6873887`->`f65a2ad`, `b735066`->`88e96c7`).
- `git diff 6873887 88e96c7` over every file this record judges (`scripts/ledger-backup.sh`,
  `scripts/docs-claims-check.sh`, both test files, `docs/system-map.md`, plus the out-of-scope
  wording files `AGENTS.md`, `docs/eval-framework.md`, `skills/build/SKILL.md`) is empty.
- `main` gained only `scripts/community-sync.sh`, `hooks/odeo-context.sh`,
  `tests/community-sync.test.sh`, one `knowledge/` file and one eval record, and
  `git diff 3cf2fe1 6873887` over those paths is empty, so the branch touches none of them.

Nothing below was re-judged. The content of round 2 applies unchanged to `88e96c7`. The main-side
commits belong to their own review record, not this one. The suites were not re-run here; the
author reports all 39 green at `88e96c7`.

Round 2 read the code delta `2b772ab..6873887` (`scripts/docs-claims-check.sh`,
`tests/docs-claims-check.test.sh`, `scripts/ledger-backup.sh` header). The wording in
`docs/eval-framework.md` and `skills/build/SKILL.md` is skill-reviewer's scope, and
`docs/evals/skill-build.md` is that reviewer's record; neither was judged here.

## Verdict

APPROVE. The round-1 Important is closed at its cause, pinned by a case with the correct
fixture, and every round-1 nitpick taken is correct. No new finding above nitpick.

## Round-1 findings, verified

**I1 (closed).** `scripts/docs-claims-check.sh:140-148`: when `suite_fail > 0` the assertions
claim is handed a reason, so `claim()` takes the UNVERIFIED branch (`:67-72`), which never sets
`claim_fail`. `fail` is already 1 from `:116`, so the run stays red and the footer prints only the
suite remedy. MISSING still sets `claim_fail` before the reason is consulted (`:59-63`), which is
right, because a vanished claim is a real document defect whatever the suites did. Case 6c uses
the shape round 1 measured: no skips, one broken suite, README at the HEALTHY count (4 against a
measured 3). It asserts red, the suite remedy, and no `DRIFTED` or "Fix the NUMBER". I ran
`tests/docs-claims-check.test.sh` once at `6873887`: exit 0, 29 `ok`, all three 6c rows green.
The builder reports seeing 6c RED on the old code, and the round-1 probe independently saw that
code print `DRIFTED` plus "Fix the NUMBER" for this exact shape, so the RED is corroborated. Not
re-run.

The reworded UNVERIFIED line ("Not judged: this run did not measure it completely") is correct
for both of its callers now; the old "Not a failure" would have been false next to a failed suite.
No test or document still greps the old wording (checked).

**Nitpick, footer wording (taken).** `:165` now reads "N suite(s) exited non-zero, so fix the
suite, not the document." The case-6 greps and the case-6b control follow it.

**Nitpick, NAME vs LOCATE (taken).** `scripts/ledger-backup.sh:52-53` now matches `:78` and what
the unset list actually covers.

**Nitpick, relative `$HOME` (not taken, accepted).** It predates this branch for the no-colon
spelling, it is unmeasured, and header residual 7 already states that `~` expansion uses this
process's `$HOME`. Leaving it is fine; it does not need closing on this branch.

**Carried from `code-ledger-backup.md`, still open, not claimed:** that record's I1
(`tests/ledger-backup.test.sh:1049` asserts `!= 0`, not `= 4`) and the case-40 four-spelling
regex. Tracked by the author, not a finding against this branch.

## Findings

### Critical

None.

### Important

None.

### Nitpicks

- `scripts/docs-claims-check.sh:66-67`: when a suite failed and the total happens to EQUAL the
  README, the equality test runs before the reason is consulted, so the output reads
  `SUITE FAILED ... the assertion count below is not a measurement` followed by
  `ok: assertions = N`. The run is still red and the footer is still right, so nothing misleads
  the reader about what to fix. It does contradict case 6c's comment ("not judged at all"). If
  you want the two to agree, test `suite_fail` first in the assertions call (for example print
  `UNVERIFIED` whenever a suite failed). Do not reorder `claim()` globally: that would also change
  the skip case, where a matching total is correctly reported as `ok`.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 · conventions 2/2
-> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached. Nothing structural caps this change.

## Relation to docs/evals/code-ledger-backup.md

Unchanged from round 1. That record gates `feature/windows-powershell-entry` at `15b168f`
(merge-gate enrols by exact `branch:`), so it neither gates nor blocks this branch. It stays as
its own branch's history and does not need to be regenerated. This record covers the ledger
code changed here. Its deferred items 1 and 2 are closed by this branch; its I1 and case-40 items
remain open.

## History

- Round 1 (`2b772ab`, 2026-09-30): REQUEST CHANGES, 10/12. The docs-claims-check footer still
  told the reader to "Fix the NUMBER in the document" when a suite failed on a machine with no
  skips (measured). Nitpicks: doubled footer wording, LOCATE overclaim, relative `$HOME`, and the
  carried ledger items.
- Round 2 (`6873887`, 2026-09-30): APPROVE, 12/12. The failed-suite total is withheld rather than
  judged, and it is pinned by case 6c at a healthy-count README. Both wording nitpicks were taken
  and the `$HOME` one was declined with a valid reason. Trajectory: 10/12 -> 12/12; correctness
  and testing each went from 1 to 2 on the same fix. One new nitpick (an equal total prints `ok`
  under a failed suite), non-blocking.
- Re-anchor (`88e96c7`, 2026-09-30): the branch was rebased onto local `main` `8dd9ec6`, with no
  content change. Verified by range-diff (`=` on all 8 commits), by an empty diff of every judged
  file between `6873887` and `88e96c7`, and by an empty diff of main's new paths over the
  branch's own range. Verdict and scores carried unchanged, no re-judgment.
