---
artifact: scripts/research-check.sh + tests/research-check.test.sh + tests/fixtures/research/ + skills/research/SKILL.md steps 3, 4b, 5b and worked example + README.md
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 43e7b0d
artifact_version: 5
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 10/12
---

## Artifact

Commit `43e7b0d` on `chore/research-one-fact-rule` (round 5, run past the three-round cap
on the human's explicit authorization), diff `eadb831..43e7b0d`. The `NOTE_LIST` comma
tail is now `(?:,\s*\D[^\d]*)?`, so a qualifier after a comma holds no digit and a
qualifier with a digit must follow `;`. The header documents the rule. Q9 is added and Q8
moves its date behind `;`. The mutation recipe is updated. Skill step 4b states the digit
rule and lists all five typographic marks, and the step 5b command is on one line. The
README count is now 1542. No plan file exists for this change. The ledger entry records
intent and is not a contract.

## Round-4 findings, verified

- Oxford-comma list read as a qualifier: FIXED, structurally for the comma path.
  `(notes 1, 2, and 9)`, `(notes 1, and 9)`, `(note 1, plus 9)` and a non-ASCII digit
  all fail closed now (probed directly). Mutating the tail back to `\D.*` reddens exactly
  Q9's two lines, as the recipe states. The older recipe entry (drop the tail -> Q2 name,
  Q8) still holds: Q8's segment `notes 1,\n  2, both read ` needs the digit-free tail.
- README count: FIXED. `tests/research-check.test.sh` prints 116 `ok:` lines (114 at
  `eadb831`, plus Q9's 2), and no other suite changed, so 1542 is consistent.
- RES-002: the output at `43e7b0d` is byte-identical to the output at `eadb831` (diffed).
  All its comma qualifiers (`this repo`, `measured`, `changelog fix`) are digit-free.
  RES-001 exits 2 identically on both commits, because it predates the Notes format.
- Q8 edit: this is not a weakened test. The human changed the grammar, so the old input is
  now a violation by design. Q8 still proves that a multi-line two-note citation with a
  qualifier verifies. It now also covers both a digit-free comma qualifier and a digit
  after `;` on the positive path.
- Skill nit (missing curly mark): FIXED. Step 4b lists „ “ ” « », which matches
  `TYPOGRAPHIC`.

## Top findings (round 5)

No Critical. No Important.

Nitpicks (new this round)
- `scripts/research-check.sh:35-38`: the class moved to `;` and was not removed there.
  `(notes 1; 9)`, `(note 1; also 9)` and `(notes 1, 2; and 9)` each cite only the notes
  before `;`, so note 9 goes unchecked. This is the bounded residual of the chosen design.
  No regex can tell a date from a note number after `;`, so do not add a cleverer
  heuristic. No writer following step 4b produces this shape, because step 4b lists the
  notes before the qualifier. Fix: add one header sentence naming the residual ("a number
  after ';' is qualifier text, so every cited note goes in the list before it"), so the
  fail-closed claim is not read as covering it.
- `scripts/research-check.sh:124-125`: this round makes the round-4 message nit sharper.
  `(note 1, read 2026-10-20)`, `(note 1, v2 docs)` and `(note 3, Q3 pricing)` are now
  violations, which is correct and fails closed. But the message tells the author to
  "write ... (note N, <qualifier>)", which is the shape they already wrote. Step 4b states
  the rule, so the 5b fix loop can recover. Fix in the follow-up the human already
  scoped: "(note N, <qualifier without digits>) or (note N; <qualifier>)".

Residual nitpicks from round 4, carried forward. The human deliberately left these out of
this round. None is Important against a guarantee the header states.
- `scripts/research-check.sh:231-233`: heading text, the H1 and the frontmatter are not
  scanned. This contradicts "every parenthesis outside the Notes list" literally, but only
  in places where nothing writes a citation.
- `scripts/research-check.sh:103`: a link target that holds parentheses leaves a stray `)`.
  An unclosed `(note 9.` is silent.
- `tests/research-check.test.sh`: three mutations survive: `rest = text`, removing the
  nested blanking, and splitting only on `;`. All three fail noisy, not silent.
- Message wording for a prose parenthesis such as `(note that ...)`. This entry merges
  with the second new nit above.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reached. Full marks are not a claim that the check is complete. The `;` path and
the round-4 nits are residuals in shapes no writer produces, so they are nits and do not
lower a dimension. The limits the header documents at the level of meaning (same fact,
independence judged by name) are out of scope for a mechanical check.

## Regression

Better: 10/12 -> 12/12. Correctness 1 -> 2: a number after a comma can no longer be read as
qualifier text in any spelling. The fix removes that class by grammar instead of guarding
each instance. Conventions 1 -> 2: the README count matches the tree. Trajectory
8 -> 9 -> 9 -> 10 -> 12.

## History

- Round 1, `25b2a85`, 8/12 REQUEST CHANGES: 1 Critical (the suite read internal
  `docs/research/RES-002`), 7 Important (silent exit 0 paths, self-match, terms satisfied
  by unchecked text, the same-source heuristic, duplicate notes, the exception exit code,
  the test-file invariant), 6 nitpicks.
- Round 2, `56ded01`, 9/12 APPROVE WITH COMMENTS: every round-1 finding was fixed for the
  inputs named. Three same-class recurrences, one header claim that does not hold and one
  untested relaxation remained Important. The loop stopped under stop condition 3, and the
  human chose the class-level fix (note parsing fails closed).
- Round 3, `053f4ef`, 9/12 APPROVE WITH COMMENTS: the class-level fix holds for note
  parsing (header grammar, typographic marks, self-match by content), and every round-2
  finding and nitpick is fixed. Remaining Important: qualified note citations are
  unparsed (same class, now in citations), nested typographic quotes are refused with
  wrong advice, and two sub-claims are not mutation-covered. The loop stops under stop
  condition 2 (three rounds). The human decides on the residual.
- Round 4, `eadb831`, 10/12 APPROVE WITH COMMENTS, run past the cap on the human's
  authorization: every round-3 finding and nitpick is fixed and mutation-proven.
  Remaining Important: an Oxford-comma list `(notes 1, 2, and 9)` is read as a qualifier
  (same class, fourth instance), and the README assertion count drifted (1514, the tree
  has 1540). The class recurred again, so the human decides between the minimal
  lookahead and the structural grammar change (qualifiers only after `;`).
- Round 5, `43e7b0d`, 12/12 APPROVE WITH COMMENTS, run past the cap on the human's
  authorization: the human chose a third structural option (a comma qualifier holds no
  digit, a digit qualifier follows `;`), which leaves RES-002 unchanged. Both round-4
  Important findings are fixed, and Q9 is mutation-proven. Residual: the `;` path can
  still hide a bare number. This is bounded and undecidable by regex, so it should be
  documented, not guarded. The round-4 nits are carried forward by the human's decision.
