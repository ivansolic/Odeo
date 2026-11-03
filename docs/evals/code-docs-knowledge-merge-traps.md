---
artifact: docs-knowledge-merge-traps
type: code
branch: docs/knowledge-merge-traps
reviewed_commit: a4766aa
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: docs/knowledge-merge-traps (round 2, regenerated after rebase)

Scope: `git diff main...docs/knowledge-merge-traps` at a4766aa. Two commits on top of the new
local main (67bed61 content, a4766aa the previous record). Files changed vs main: the two
knowledge files and this record. Output language: en (handed at dispatch).

Why this record exists: the branch was rebased onto the new local main, so the round 1 anchor
(f34113c) no longer exists in this history. Regenerated, not re-dated.

## Rebase check
- `git diff f34113c HEAD -- knowledge/review/claims-count-needs-assertions-flag.md
  knowledge/testing/watchdog-by-pid-not-alarm.md` is empty (0 lines): both knowledge files are
  byte-identical to what round 1 reviewed.
- `git diff main...HEAD --name-only` lists exactly three paths: the two knowledge files and
  `docs/evals/code-docs-knowledge-merge-traps.md`. Nothing else rode along. (The large
  f34113c..HEAD diff is the new main underneath, not this branch.)
- Dependencies re-checked because the rebase moved them: `scripts/docs-claims-check.sh` still
  accepts only `--assertions` (lines 15, 28), still prints `skipped: assertion count (re-run
  with --assertions; it runs every suite)` when the flag is absent (line 149, was 146), and the
  drift line format at line 71 is unchanged (`DRIFTED: <label> , README says N, the tree has
  M`). The entry's claims about these are still true. The README total moving to 1618 does not
  touch the entry: it cites only the historical USR-008 figures (1517 to 1523), which are
  labelled as such. "Counts only executable files" affects the file-counting half of the plain
  run, which the entry describes only generally ("counts files"), so it stays accurate.
- No non-ASCII bytes in either knowledge file (grep found none), so no em or en dashes.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional, carried from round 1, still open, none blocks)
- `knowledge/testing/watchdog-by-pid-not-alarm.md:54-55`: the example loop globs
  `tests/*.test.sh` but the text says "all 40 suites FAILED". That figure was measured at the
  time and needs both globs (`tests/` plus `.claude/maintainer/tests/`); the loop as shown
  covers only the first (37 suites in the tree today). **Fix:** show both globs or say "all 40
  suites (tests/ plus .claude/maintainer/tests/)".
- `knowledge/review/claims-count-needs-assertions-flag.md:38-40`: "re-stales review records
  under the installed 0.3.5 merge gate" is right for that gate, but this repo's maintainer gate
  exempts README and Markdown under `knowledge/`. **Fix:** one clause naming which gate bit at
  USR-008.
- `knowledge/review/claims-count-needs-assertions-flag.md:27`: "about 5 to 6 minutes" is a
  duration, not a dated measurement. **Fix (optional):** "measured at about 5 to 6 minutes on
  2026-10-27".

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. APPROVE WITH COMMENTS rather than APPROVE only because of the three optional
nitpicks, none of which would send a reader to a wrong action. Testing is 2 for a docs-only
change: no code ships, and the behavioral claims were verified in round 1 and re-checked above
against the dependency that moved.

## What's good
- Every behavioral claim points at an exact output string or a dated measurement, and the
  quoted strings still match the script after the rebase.
- The watchdog section carries its own detection rule ("every suite failed at once means a
  broken runner") and a scoped substitute, not a bare warning.
- The claims entry states the structural point: a "skipped:" line means "not checked".

## History
- Round 1 at f34113c (2026-10-29): 12/12, APPROVE WITH COMMENTS. First review of this branch.
- Round 2 at a4766aa (2026-11-03): regenerated after rebase onto the new local main. Content
  verified unchanged by diff; scores and verdict unchanged; same three nitpicks remain open.
  Regression note: same.
