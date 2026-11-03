---
artifact: docs-knowledge-merge-traps
type: code
branch: docs/knowledge-merge-traps
reviewed_commit: 6cf35c8
date: 2026-11-03
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: docs/knowledge-merge-traps (round 3, regenerated after a second rebase)

Scope: `git diff main...docs/knowledge-merge-traps` at 6cf35c8. Files changed vs main: the two
knowledge files and this record. Output language: en (handed at dispatch).

Why this record exists: the branch was rebased a second time because local main moved (the
follow-ups branch merged first), so the round 2 anchor (a4766aa) no longer anchors the code.
Regenerated, not re-dated. The dispatch prompt carried a literal placeholder instead of a sha,
so the sha was resolved here with `git rev-parse --short HEAD` and not taken from the prompt.

## Rebase check
- `git diff a4766aa HEAD -- knowledge/` is empty (0 lines): both knowledge files
  (`knowledge/review/claims-count-needs-assertions-flag.md`,
  `knowledge/testing/watchdog-by-pid-not-alarm.md`) are byte-identical to what round 2 approved,
  and therefore to round 1.
- `git diff main...HEAD --name-only` lists exactly three paths: the two knowledge files and
  `docs/evals/code-docs-knowledge-merge-traps.md`. Nothing else rode along.
- Working tree clean before this record was written.
- Per the dispatcher's instruction, the dependency claims (`scripts/docs-claims-check.sh`
  output strings) and the non-ASCII scan were not re-run this round; they were verified in
  round 2 and the knowledge content has not changed since. That is a scoping choice, not a
  fresh verification.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional, carried from rounds 1 and 2, still open, none blocks)
- `knowledge/testing/watchdog-by-pid-not-alarm.md:54-55`: the example loop globs
  `tests/*.test.sh` but the text says "all 40 suites FAILED". That figure was measured at the
  time and needs both globs (`tests/` plus `.claude/maintainer/tests/`); the loop as shown
  covers only the first. **Fix:** show both globs or say "all 40 suites (tests/ plus
  .claude/maintainer/tests/)".
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
change: no code ships, and the behavioral claims were verified in rounds 1 and 2.

## What's good
- Every behavioral claim points at an exact output string or a dated measurement.
- The watchdog section carries its own detection rule ("every suite failed at once means a
  broken runner") and a scoped substitute, not a bare warning.
- The claims entry states the structural point: a "skipped:" line means "not checked".

## History
- Round 1 at f34113c (2026-10-29): 12/12, APPROVE WITH COMMENTS. First review of this branch.
- Round 2 at a4766aa (2026-11-03): regenerated after the first rebase. Content verified
  unchanged by diff; scores and verdict unchanged; same three nitpicks.
- Round 3 at 6cf35c8 (2026-11-03): regenerated after the second rebase onto the new local main.
  Knowledge content verified byte-identical to a4766aa by diff; file list verified; scores and
  verdict unchanged; same three nitpicks remain open. Regression note: same.
