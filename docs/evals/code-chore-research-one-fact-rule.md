---
artifact: scripts/research-check.sh + tests/research-check.test.sh + tests/fixtures/research/ + skills/research/SKILL.md steps 3, 4b, 5b and worked example + README.md
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 053f4ef
artifact_version: 3
date: 2026-10-20
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 1, conventions: 1 }
total: 9/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

## Artifact

Commit `053f4ef` on `chore/research-one-fact-rule` (round 3, the last under stop
condition 2), diff `56ded01..053f4ef`: `scripts/research-check.sh` split into module-level
functions, note parsing made fail-closed (one header grammar, typographic quote marks are
a violation, a content-based self-match guard, `commonpath` containment, case-insensitive
`res-NNN` refusal, note citations checked outside Findings), cases P1 to P7 in
`tests/research-check.test.sh`, N12's no-op block removed, skill step 5b reworded, README
count 1514. No plan file exists for this change; the ledger entry is intent, not a contract.

## Round-2 findings, verified

Each re-checked by running the round-3 suite against the round-2 script (`56ded01`): P1,
P2, P3, P4, P6 (message assertion), P7 are red there, P5 is green there (it locks the
existing relaxation, as stated).
- Typographic quote marks in one note: FIXED (P1). All five listed marks are in
  `TYPOGRAPHIC`.
- Self-match by filename: FIXED by a content test (P2). Reproduced: disabling the guard
  turns P2 red.
- Colon inside the first quote taken as the header: FIXED (`colon > first_quote` -> None,
  P3).
- Note citations outside Findings: FIXED for the literal `(note N)` form in Answer,
  Implications, Numbers, Unverified (P4 for Unverified). See the new Important below for
  the form that is still not parsed.
- Backtick relaxation untested: FIXED (P5).
- Nitpicks: `--sources /` refused (P6), `res-` case-insensitive (P7), header states the
  parenthesis rule for finding ids, N12 no-op removed with a host comment, `main()` split.
  All FIXED.

## Top findings (round 3)

Important
- `scripts/research-check.sh:73, 90-91, 189-191`: note citations are only recognised in
  the exact form `(note N)` / `(notes N, M)`. A qualifier inside the parenthesis makes the
  citation invisible. Planted `**One source** (note 9, measured)` with two notes: exit 0,
  "quotes: 3/3 verbatim". This form is real: `docs/research/RES-002` uses
  `(note 24, measured)`, `(note 24, this repo)`, `(note 16, changelog fix)` and
  `(note 14; three pages of one vendor's docs)`. Answer `(verified, F1, note 9)`, a
  `(note 9)` in a table under Findings, in Question or in Sources: all exit 0. The header
  (line 31) says note citations "are checked in every section". Fix: scan every
  parenthesis in the report text minus the Notes list, and inside each take
  `\bnotes?\s+(\d+(?:\s*,\s*\d+)*)`. Add a case that cites a missing note with a
  qualifier.
- `scripts/research-check.sh:106-108`: a verbatim quote whose SOURCE text contains
  typographic quotes, such as `"Tool B says the “sync” job runs daily at noon"`, is a
  violation. The message tells the author to "use straight double quotes". Doing that
  produces an unpairable or non-verbatim quote. CMS-rendered web pages curl quotes by
  default, so a long verbatim quote often contains them. This fails closed, not silently,
  but the advice is wrong. Fix: flag typographic marks only outside straight double-quoted
  and backtick spans. That still catches a curly-delimited quote and lets a nested one
  through to the verbatim check. If that is not done, say "split the quote around the
  source's own quote marks" in the message and in skill step 4b.
- `tests/research-check.test.sh:298-319`: two stated sub-claims fail the mutation test.
  First, setting the note-citation sections on line 189 to `("Unverified",)` leaves all
  assertions green, so Answer, Implications and Numbers are unchecked by any test.
  Second, `TYPOGRAPHIC[:1]` (only U+201C) leaves all assertions green, so four of the five
  listed marks are untested. Fix: cover each of the five marks in P1, either with one
  mutation per mark or with a loop over them. Also add a P4 variant in Answer.

Same-class note: the first Important is the round-2 class, "an input the parser does
not interpret is read as clean", now in note CITATION parsing instead of note parsing.
Fixing it by adding the qualifier form to `NOTE_CITE` would be another instance patch.
The class-level fix is the one named above: any `note` token in a parenthesis that does
not parse as a number list is a violation.

Nitpicks
- `tests/research-check.test.sh:297`: "each red on 56ded01" covers P5, which is green on
  56ded01 by design. Say "each red on 56ded01 except P5, which locks the relaxation".
- `scripts/research-check.sh:214-217`: the self-match guard refuses only when at least one
  note of 40 or more characters is unchanged in the copy. A draft whose notes were all
  edited afterwards is not caught. The header does not mention the guard or its limit.
  Add one line saying it is a heuristic.
- `skills/research/SKILL.md:74`: the reflowed line runs to about 150 columns while its
  neighbours wrap at about 95. Rewrap it.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 1/2 -> total 9/12 (threshold: >=9, no zero)

## Ceiling

12/12 reachable. Nothing structurally caps this change. The documented meaning-level
limits (same fact or shared word, independence judged by name) are out of scope for a
mechanical check and are not scored against it.

## Regression

Same total: 9/12 -> 9/12. Readability stays 2: the split into module-level functions is
clean. Correctness stays 1: every round-2 instance is fixed and one same-class sibling
remains in citation parsing. Testing stays 1: the relaxation is now locked, but two
sub-claims are not mutation-proven. Conventions stays 1: the header again claims coverage
the code does not hold ("every section").

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
