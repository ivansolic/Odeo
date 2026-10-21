---
artifact: scripts/research-check.sh + tests/research-check.test.sh + tests/fixtures/research/ + skills/research/SKILL.md steps 3, 4b, 5b and worked example + README.md
type: code
branch: chore/research-one-fact-rule
reviewed_commit: eadb831
artifact_version: 4
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 1 }
total: 10/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

## Artifact

Commit `eadb831` on `chore/research-one-fact-rule` (round 4, run past the three-round cap
on the human's explicit authorization), diff `053f4ef..eadb831`: note citations parse fail
closed in every section (`paren_texts`, `cited_notes` with `NOTE_WORD` and `NOTE_LIST`,
every `## ` section outside the Notes list and the already-scanned finding bodies),
typographic marks flagged only outside straight-quoted and backtick spans, P1 looped over
all five marks, P8, Q1 to Q8, a mutation recipe in the test file, skill step 4b extended,
step 5b rewrapped. No plan file exists for this change; the ledger entry is intent, not a
contract.

## Round-3 findings, verified

Each re-checked by running the round-4 suite against the round-3 script (`053f4ef`): P8,
Q1, Q2, Q3, Q4, Q5, Q6, Q8 are red there and Q7 is green, as the test comment states.
- Qualified and out-of-section citations: FIXED. `(note 9, measured)`, `(verified, F1,
  note 9)`, a table under Findings, Question, Sources and a capitalised `Note` are all
  reported (Q1 to Q5). RES-002 shows no citation violation; its 49 parenthesised note
  citations all parse.
- Wrong typographic advice: FIXED (P8). The message and step 4b now say the source's own
  marks may stay inside a straight quote.
- Mutation gaps: FIXED. All eight mutations in the recipe were re-run here and reddened
  exactly the cases and line counts it names. The section-scope mutation reddens Q3, Q4 and
  Q5 (6 lines), and dropping `»` or `„` reddens only that mark's P1 lines.
- Nitpicks: all FIXED ("except P5", the heuristic line in the header, the rewrapped line
  in step 5b).
- The deliberate consequence, prose such as `(a note on pricing)` or `(note that ...)`
  becoming a violation, is right. The violation quotes the parenthesis, RES-002 has no
  such hit, and a false positive costs one rewording. A silent miss costs a missing note
  reaching review, which is what rounds 1 to 3 kept finding.

## Top findings (round 4)

Important
- `scripts/research-check.sh:82`: an Oxford-comma list is read as a qualifier. In
  `(notes 1, 2, and 9)` the tail `,\s*\D.*` swallows `, and 9`. Planted on F2 with
  only two notes: exit 0, no violation. On a Verified finding, `(notes 1, 1, and 2)`
  reports "Verified needs two notes, cites [1]", which is wrong advice. This is the
  round-1 to round-3 class again: input the parser does not interpret is read as clean.
  Three-note lists are a natural shape, since Verified needs at least two notes. Minimal
  fix: `(?:,\s*(?!(?:and|or|&)\s*\d)\D.*)?`, plus a Q9 case proven by mutation. The
  structural fix removes the class: after the number list a comma only ever separates
  numbers, and a qualifier comes only after `;`. That costs rewording three RES-002
  citations and step 4b, so it is the human's decision.
- `README.md:242`: the README says "1514 assertions". This round adds 26 assertions to
  `tests/research-check.test.sh` (88 at `053f4ef`, 114 now), and no other suite changed,
  so the tree has 1540. `scripts/docs-claims-check.sh --assertions` will report DRIFTED.
  Fix: update the number and confirm it with that command. I worked the number out from
  the two counts and did not run the full suite.

Nitpicks
- `scripts/research-check.sh:231-233`: three parts of a report are never scanned: the
  text of a heading line (`## Numbers (note 9)`), the H1, and the frontmatter before the
  first `## `. All three exit 0. That contradicts "every parenthesis outside the Notes
  list" (line 33). Fix: pass `m.group(0)` instead of `m.group(2)`, and scan
  `rest[:first "## "]` as `preamble`. Otherwise narrow the header claim.
- `scripts/research-check.sh:102`: a link target holding parentheses, for example
  `[w](https://e.org/Foo_(bar))`, leaves a stray `)`. That stray closes the outer
  parenthesis early, so `(F1, verified, [w](...Foo_(bar)), note 9)` exits 0. An unclosed
  `(note 9.` is also silent. Fix: match one level of balanced parentheses in the
  link-target regex, `\]\((?:[^()]|\([^()]*\))*\)`.
- `tests/research-check.test.sh`: three behaviours are not mutation-proven. Each of these
  mutations leaves the suite green: `rest = text` (the Notes list is scanned too), removing
  the nested-parenthesis blanking at line 118, and splitting only on `;` at line 120. All
  three fail noisy, not silent. Fix: add a note whose locator holds `(release notes)` and
  a citation `(notes 1, 2 (both read 2026-10-20))`, both expected exit 0.
- `skills/research/SKILL.md:52`: the list „ “ « » omits ”, which the script also refuses.
  Fix: list all five marks, or say "typographic marks such as".
- `scripts/research-check.sh:123-124`: the message tells the author only how to write a
  citation. For `(note that pricing changed)` it should also say "or reword a parenthesis
  that is not a citation".

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 1/2 -> total 10/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reachable. Nothing structurally caps this change. Correctness reaches 2 once a
number after a comma can no longer be read as qualifier text. Conventions reaches 2 when
the README count matches the tree. The meaning-level limits the header documents (same
fact or shared word, independence judged by name) are out of scope for a mechanical check
and are not scored against it.

## Regression

Better: 9/12 -> 10/12. Testing rises 1 -> 2: the recipe is accurate and every round-3
sub-claim is mutation-proven. The mutations that still survive all fail noisy, not silent.
Correctness stays 1: every round-3 instance is fixed, but the qualifier tail lets one
silent same-class shape through. Conventions stays 1, for a different reason: the header
claim now mostly holds (headings and preamble are a nit), but the README assertion count
drifted. Trajectory 8 -> 9 -> 9 -> 10.

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
