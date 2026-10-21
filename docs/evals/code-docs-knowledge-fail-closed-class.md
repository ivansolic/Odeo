---
artifact: docs-knowledge-fail-closed-class
type: code
branch: docs/knowledge-fail-closed-class
reviewed_commit: 02494f8
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
---

# Code review: docs/knowledge-fail-closed-class (round 3)

Scope: `git diff 00541ba 02494f8 -- knowledge/`. One commit touches the entry
(`02494f8 docs(knowledge): the note-parsing row states where the header grammar applies`).
It changes one table cell at
`knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:103`. The other file in
the range is the round-2 record (`d1db410`), and this record replaces it.

I checked the cell against `053f4ef`, the commit it cites (its body, plus
`scripts/research-check.sh` at that commit), and against the script at 02494f8. I also
probed copies of `tests/fixtures/research/report-real-shape.md` at 02494f8.

Output language: en (handed at dispatch). The model tier is `strongest`. This run is Opus
class (`claude-opus-5-5[1m]`), and the dispatcher says the session runs on the strongest
tier. I did not re-check the live lineup in this run.

## Verdict
APPROVE

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:103`: "a typographic ...
  quote mark in any note is a violation" is exact at `053f4ef`. There, `parse_notes`
  tested `any(c in body for c in TYPOGRAPHIC)` on the whole note. `eadb831` later
  narrowed that test to text outside a straight-quoted or backtick span. Probe at
  02494f8, on note 4 (no Verified finding cites it):
  - a typographic mark outside a quote gives exit 1;
  - one inside a straight quote gives exit 0.

  This narrowing does not reopen the class. A mark inside a quote still goes to the
  verbatim check, so nothing is read as clean without being checked. The row is anchored
  to its commit, so this is not a correctness finding. Still, a reader who probes the
  current code finds the narrower rule. This wording was my own round-2 suggestion, and I
  did not check what changed after the anchor. Optional fix: end the cell with "(053f4ef;
  typographic marks inside a straight quote allowed since eadb831)". That matches the
  "finished in 57daa41" pattern the link row already uses.

## Verified as stated
Each clause of the cell matches `053f4ef` and still holds at 02494f8:
- "one header grammar, required for every note a Verified finding cites": `header()` is
  enforced only in `check_verified` ("no '<source>, <locator>: ' header before its first
  quote"). `check_quotes` falls back to reading the whole note as the quote region. This
  is the scope the round-2 Important asked to state. It is now stated exactly.
- "unpaired quote mark in any note is a violation": `parse_notes` runs on every note
  ("odd number of '\"'"). At 02494f8, an unpaired quote added to note 4 gives exit 1.
- "self-match by content": `read_sources` refuses the run when any source file contains
  a note's text of 40 characters or more ("holds the text of note {n}"). It was present
  at `053f4ef` (lines 216-217 there), and the commit body says "a sources file holding a
  note's text refuses the run". This takes the round-2 nitpick.
- The instance-patch cell and the shape cell are unchanged and were verified in round 2.
- Format:
  - there are no non-ASCII bytes and no em or en dashes in the entry;
  - the cell is a table row, so line length does not apply;
  - `prose-language-check.sh`: OK, en=210, 0 warnings.
- The overclaim in the script header comment (`scripts/research-check.sh:25`, "the header
  must be") is still in the code. It is outside this diff and is recorded as an open item
  in `.claude/tasks/todo.md:1312`. So the follow-up exists and is not lost.

## Loop note
Round 3 of 3, the last under the cap in `docs/eval-framework.md`. Stop condition 1
(approve) is met, so the loop ends here. The nitpick above is optional and does not need
a fourth round.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. Security, performance and testing have no surface in a knowledge entry,
so they score clean rather than capped.

## What's good
- The fix is minimal and exact: one cell, three clauses, and each clause maps to a named
  mechanism at the cited commit.
- It states the scope limit honestly ("required for every note a Verified finding
  cites") instead of keeping the broader and more flattering claim.
- The out-of-diff overclaim in the script went to the ledger, not into this branch, so
  the branch stays a docs-only change.

## History
- Round 1 (`06bbf15`): APPROVE WITH COMMENTS, 11/12, with correctness at 1. Three
  Important accuracy findings: the round count for link addresses, three moves where
  there were four, and "the stop rule each time" where two of the four stops were the
  cap. Five nitpicks.
- Round 2 (`00541ba`): APPROVE WITH COMMENTS, 11/12, with correctness at 1. Every
  round-1 finding is fixed. One new Important, in text added by the round-1 fix: the
  note-parsing row said "anything else is a violation", but the header grammar is
  enforced only for notes that Verified findings cite. One nitpick (self-match by
  content).
- Round 3 (`02494f8`): APPROVE, 12/12. The round-2 Important and its nitpick are fixed
  with the suggested wording. One optional nitpick: the typographic-mark rule was
  narrowed after the anchor commit (`eadb831`). Regression note: better (11 -> 12,
  correctness 1 -> 2).
