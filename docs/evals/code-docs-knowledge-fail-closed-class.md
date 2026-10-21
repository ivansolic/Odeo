---
artifact: docs-knowledge-fail-closed-class
type: code
branch: docs/knowledge-fail-closed-class
reviewed_commit: 06bbf15
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
---

# Code review: docs/knowledge-fail-closed-class (round 1)

Scope: `git diff main 06bbf15`, one commit (`06bbf15 docs(knowledge): fail-closed checker
as a second case of eliminating the defect class`), one file,
`knowledge/fixes/eliminate-the-defect-class-not-the-shape.md`. It extends the frontmatter
tags and provenance and adds the section "Second case: a checker that must fail closed".
I read the whole file at 06bbf15 and checked every factual claim against the commits
`56ded01..57daa41`, their bodies, and each round's version of
`docs/evals/code-chore-research-one-fact-rule.md` (`2d090bb`, `64d29a0`, `e4b216c`,
`f9911fc`, `d932b4f`, `16c6cc5`).

Output language: en (handed at dispatch). The model tier is recorded as `strong`: Opus
class counts as sonnet class and up. I did not claim `strongest` because this agent could
not re-check the live model lineup.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:95`: "one review round
  each" is false for link addresses. That place took three rounds of the nitpick change:
  round 1 (`88acd30`/`d36c803`) found the regex too loose, round 2 (`9705c4e`) found it too
  tight, and round 3 (`81877e4`) found the `[F1](note 9)` miss. The table's own row 3,
  "too loose, then too tight", already shows two rounds. Fix: drop "one review round
  each", or write "one round each for the first three, three rounds for link addresses".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:96-97` and `:11`: "Three
  moves closed it" and "closed structurally three times" leave the first place
  unaccounted for. Note parsing was closed by a class-level move too: the round-2 record
  (`2d090bb`) names "make note parsing fail closed" as the class-level fix, the human chose
  it, `053f4ef` implemented it, and the round-3 record says "the class-level fix holds for
  note parsing". So the four places got four structural moves (`053f4ef`, `eadb831`,
  `43e7b0d`, `81877e4`), and `57daa41` finished the fourth. Fix: say "four moves", add a
  first table row (shape: a note header, a curly quote or a self-copy read as clean;
  instance patch: the round-1 instance guards; structural fix: one header grammar, curly
  quotes a violation, self-match by content), and change the provenance to "closed
  structurally four times".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:117-118`: "What stopped
  the loop each time was ... the review loop's stop rule (same class twice in a row)" is
  half wrong. Of the four stops, two were stop condition 3 (same class twice: `2d090bb`
  for change B round 2, `f9911fc` for the nitpick change round 2). The other two were stop
  condition 2, the three-round cap (`64d29a0` for change B round 3, `d932b4f` for the
  nitpick change round 3). Fix: "the review loop's stop conditions (the same class twice in
  a row, or three rounds on one artifact)". The point still holds: a rule stopped the loop,
  not a better patch.

## Nitpicks (optional)
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:115`: "still wrong for
  '(notes, 1)'" names a shape that is caught. I probed at 06bbf15, where
  `scripts/research-check.sh` is byte-identical to `57daa41`: a bare `(notes, 1)` exits 1
  ("unreadable note citation"), and `[F1](notes, 1)` exits 0, as do `[F1](notes, 9)` and
  `[F1](note:9)`. A reader who probes the quoted text will think the claim is false. Fix:
  write "[F1](notes, 1)". The location is also slightly off: "never a miss" for this cost
  is in the `57daa41` commit body. The header's "never a miss" (`research-check.sh:36`) is
  about a word "note" in a URL's own parentheses. Fix: "that claim in the 57daa41 commit
  body".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:107` and `:94`: the link
  loop is presented as the fourth instance of "input the parser does not understand is
  read as clean", and point 1 calls emulation "itself the class". The reviews named a
  different class for it. `f9911fc` says "the link-extent regex approximates CommonMark by
  hand". Its round-2 instance was a fail-CLOSED false alarm (titled links refused), not a
  read-as-clean miss, and `d932b4f` says the `](note 9)` miss "is not the round-2 class".
  Only the too-loose half, and the later miss, failed open. Fix: "Emulating someone else's
  grammar breeds the class: the hand-made copy failed open (too loose), then closed (too
  tight)".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:109-110`: the fact as
  quoted is "the word note and a space". The code checks the words note or notes, without
  case, followed by any whitespace (`[ \t]*notes?\s`, re.I), and the `57daa41` body says
  "note or notes". Fix: "does not start with the word note or notes and a space".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:9-11`: the provenance
  credits all of it to "change B ... 12/12 at 57daa41". Change B ended at 12/12 on
  `43e7b0d`. The link work and `57daa41` belong to its follow-up, which commits call "the
  nitpick change" (`d36c803..57daa41`) and the code record labels "change C". Fix: "change
  B and its nitpick follow-up ... 12/12 at 43e7b0d and at 57daa41".
- `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md:94-120`: the new prose
  wraps at about 91 columns, while the rest of the body wraps at about 82. This is
  cosmetic. Fix: rewrap to match.

## Verified as stated
- The table's patches and fixes match the records:
  - Row 1: `64d29a0` calls "adding the qualifier form to NOTE_CITE" an instance patch. The
    structural fix matches `eadb831`.
  - Row 2: `e4b216c`'s minimal fix is `(?!(?:and|or|&)\s*\d)`. The human chose a third
    option, which matches `43e7b0d`.
  - Row 3: option (a) in `f9911fc` was the fuller regex. Option (b) was taken in
    `81877e4`.
- Point 2 checks out. `9705c4e`'s too-tight regex caused a false alarm, and `81877e4`
  traded it for the `[F1](note 9)` miss, which round 3 caught (`d932b4f`).
- At 06bbf15, `[F1](note 9)` and `[F1](notes 9)` exit 1, and `[d](notes.md)` exits 0.
- 12/12 at `57daa41`: confirmed by the `16c6cc5` record.
- The dates 2026-10-20 to 2026-10-21 match the commit dates (`25b2a85` to `57daa41`).
- The placement limit is in `.claude/tasks/lessons.md` line 30.
- "This entry existed and was not looked up" is consistent with the records. No change B
  or nitpick-change record cites the entry.
- Format:
  - all six frontmatter fields are present;
  - `reuse_count: 0` is consistent with "not looked up";
  - the file has no non-ASCII bytes and no em or en dashes;
  - `language-guard.sh` (branch and commit subject): machine surfaces clean;
  - `prose-language-check.sh`: OK, en=201.
- No contradiction with the guidance above. The new section applies the existing
  guidance, and its point 2 is a concrete case of "Prose is where unproven bounds hide".

## Scores
correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 11/12  (threshold: >=9, no zero)

## Ceiling
12/12 is reachable. The three Important findings are wording corrections with the right
facts named above. Security, performance and testing have no surface in a knowledge
entry, so they score clean rather than capped.

## What's good
- Every table cell traces to a named record or commit. The "instance patch on offer"
  column is honest: it is the alternative each reviewer actually wrote down.
- Point 2 (check which way the residual points) is a real addition. It is backed by an
  actual miss, and the entry admits its own author's "never a miss" claim was wrong.
- The section is short and adds two lessons without restating the first case.

## History
- Round 1 (`06bbf15`): APPROVE WITH COMMENTS, 11/12, with correctness at 1. Three
  Important accuracy findings: the round count for link addresses, three moves where
  there were four, and the stop rule each time where two of the four stops were the cap.
  Five nitpicks. No previous record, so no regression note.
