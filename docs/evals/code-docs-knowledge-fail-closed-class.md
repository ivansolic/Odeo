---
artifact: docs-knowledge-fail-closed-class
type: code
branch: docs/knowledge-fail-closed-class
reviewed_commit: 00541ba
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
---

# Code review: docs/knowledge-fail-closed-class (round 2)

Scope: `git diff 06bbf15 00541ba -- knowledge/`, one commit (`00541ba docs(knowledge):
correct round counts, fix count and stop conditions in the second case`), one file,
`knowledge/fixes/eliminate-the-defect-class-not-the-shape.md`. I checked the new
note-parsing row against `053f4ef` (commit body and `scripts/research-check.sh` at that
commit) and the round-2 record of change B (`2d090bb`). I checked the stop conditions
against `2d090bb`, `64d29a0`, `e4b216c`, `c8ced0a`, `f9911fc` and `d932b4f`. I probed
the current script at 00541ba with copies of `tests/fixtures/research/report-real-shape.md`.

Output language: en (handed at dispatch). The model tier is recorded as `strongest`. This
run is Opus class (`claude-opus-5-5[1m]`), the top Anthropic class, and the dispatcher
says the session runs on the strongest tier. I did not re-check the live lineup in this
run. Round 1 wrote `strong`, which is also true (sonnet class and up), but it is less
exact.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:103`: the new row says
  "one header grammar, anything else is a violation (053f4ef)". The code does not do
  that. At `053f4ef`, and still at 00541ba, the header grammar is enforced only in
  `check_verified`, so only for notes that a Verified finding cites. For every other
  note, `check_quotes` reads the whole note as the quote region and raises nothing.
  - Probe at 00541ba: I took the fixture and dropped note 4's header ("4. Widget
    changelog section 2.3.0 says ..."). Note 4 is cited only by conflict C1, and the
    check exits 0. Dropping note 2's header gives exit 1, because note 2 is cited by
    Verified F3.
  - Fail-closed holds in spirit. Reading the whole note checks more quotes, not fewer,
    so the class "read as clean" is closed. The wording still overclaims the mechanism,
    in the one entry that tells readers to probe a claim before writing it.
  - The script's own header comment (`scripts/research-check.sh:25`, "the header must
    be") makes the same overclaim. That file is outside this diff, so treat it as a
    follow-up, not a finding here.
  - Fix: write "one header grammar, required for every note a Verified finding cites; a
    typographic or unpaired quote mark in any note is a violation (053f4ef)".

## Nitpicks (optional)
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:103`: the row's structural
  fix leaves out the third part of `053f4ef`, which `2d090bb` named in the class-level
  fix: self-match by content, not by filename. Fix: add ", self-match by content". You
  can skip this if the cell would get too long.

## Verified as stated
- The note-parsing row's shape matches the round-2 Importants in `2d090bb`: a colon inside
  the first quote, and typographic quotes in one note. The instance-patch cell matches
  `2d090bb`'s "each closed in round 1 by an instance guard", and its per-finding "Fix:"
  lines really are one guard per shape. `053f4ef`'s body says the fix "closed instances,
  not the class".
- Change B covers three places, one review round each:
  - note parsing: round 2, `2d090bb`;
  - note citations, qualifier and "every section": round 3, `64d29a0`;
  - the comma qualifier: round 4, `e4b216c`.
  The structural moves are `053f4ef`, `eadb831` and `43e7b0d`. Change B ended 12/12 at
  `43e7b0d` (`c8ced0a`). The provenance's "three places, closed structurally each time"
  agrees with the body's "four moves" once the follow-up is counted.
- The follow-up spent three rounds on link addresses, `99e1e36`, `f9911fc` and `d932b4f`,
  and ended 12/12 at `57daa41` (`16c6cc5`). Point 1's "too loose, then too tight" matches
  `99e1e36` (a broken link swallowing later citations) and `f9911fc` (titled links
  refused).
- The stop conditions are right:
  - same class: `2d090bb` and `f9911fc`;
  - three-round cap: `64d29a0` and `d932b4f`;
  - rounds 4 and 5 of change B ran past the cap "on the human's explicit authorization"
    (`e4b216c`, `c8ced0a`).
  So "handed the choice to the human" holds.
- `[F1](notes, 1)` exits 0 at 00541ba, so the miss the entry claims is real. The
  "never a miss" claim is in the `57daa41` commit body (line 7), as stated.
- The quoted rule "note or notes and whitespace" matches `[ \t]*notes?\s` with re.I
  (`research-check.sh:118`).
- Format:
  - there are no non-ASCII bytes and no em or en dashes;
  - the new prose wraps at 87 columns or less (lines 97 and 125 are at 87). The longer
    lines are the table rows and lines 31 and 32, which round 1 did not touch;
  - `prose-language-check.sh`: OK, en=210.

## Loop note
Round 1 found claims that did not match the commit history. This round found one new
claim, added in round 1's fix, that does not match the code. By the operational test in
`docs/eval-framework.md` (same kind of fix) it is borderline: in both rounds the fix is to
reword a claim to match its source, but this one is a different claim. Stop condition 1
already applies, because APPROVE WITH COMMENTS clears the threshold, so the loop stops
here either way. The one-phrase fix above is the human's call.

## Scores
correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 11/12  (threshold: >=9, no zero)

## Ceiling
12/12 is reachable: the one Important finding is a single table cell, and the right wording
is given above. Security, performance and testing have no surface in a knowledge entry,
so they score clean rather than capped.

## What's good
- All three round-1 Importants are fixed accurately: the round counts, four moves with
  commit anchors per row, and both stop conditions.
- All five nitpicks are applied. The `[F1](notes, 1)` example and the reworded point 1
  ("failed open, then closed") now match the code and the records exactly.
- Every table row now carries its commit, so a reader can check each claim.

## History
- Round 1 (`06bbf15`): APPROVE WITH COMMENTS, 11/12, with correctness at 1. Three
  Important accuracy findings: the round count for link addresses, three moves where
  there were four, and "the stop rule each time" where two of the four stops were the
  cap. Five nitpicks.
- Round 2 (`00541ba`): APPROVE WITH COMMENTS, 11/12, with correctness at 1. Every
  round-1 finding is fixed. One new Important, in text added by the round-1 fix: the
  note-parsing row says "anything else is a violation", but the header grammar is
  enforced only for notes that Verified findings cite. Regression note: the same score,
  with a different and smaller defect (one cell, where round 1 had three claims).
