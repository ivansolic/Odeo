---
artifact: scripts/research-check.sh + tests/research-check.test.sh + tests/fixtures/research/ + skills/research/SKILL.md steps 3, 4b, 5b and worked example + README.md
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 56ded01
artifact_version: 2
date: 2026-10-20
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 1, conventions: 1 }
total: 9/12
verdict: APPROVE WITH COMMENTS
previous_total: 8/12
---

## Artifact

Commit `56ded01` on `chore/research-one-fact-rule` (round 2), diff `25b2a85..56ded01`:
`scripts/research-check.sh` rewritten into `main()` + `check_sources()` with exit-2 guards,
14 new N cases in `tests/research-check.test.sh`, a public real-shaped fixture under
`tests/fixtures/research/`, research skill steps 3, 4b, 5b and the worked example, README
assertion count. No plan file exists for this change; the ledger entry is intent, not a
contract.

## Round-1 findings, verified

- Critical R1 (suite read internal RES-002): FIXED. R1 reads
  `tests/fixtures/research/report-real-shape.md` and its `sources/`; nothing under
  `docs/research/` is read by the suite.
- Silent exit 0 on zero findings, `--sources ""`, all quotes typographic: FIXED for those
  inputs (N1, N2, N4).
- Self-match: FIXED for the report itself and `RES-*.md` names (N3, N3b).
- Terms in locators, terms straddling quotes, short term quotes unchecked, odd `"`: FIXED
  for those inputs (N5 to N8).
- Same source without a comma, case and whitespace: FIXED (N9, N10).
- Duplicate notes, exception exit code, conflict listing, citation outside parentheses:
  FIXED (N11 to N14).
- Invariant (M4b, I2, I4 assert a message): FIXED.
- Worked example: every quote of length 12 or more is verbatim in RES-002 and the example
  passes the checker (wrapped as a report, exit 0).

## Top findings (round 2)

Important (each reproduced on 56ded01 with a planted input)
- `scripts/research-check.sh:111-112, 219-225`: a note whose quote uses typographic marks
  is invisible to the quote check while other notes use straight ones. Planted note 3
  `Acme blog, acme.dev/blog: "Tool B runs job Y hourly and invented text here"` in curly
  quotes, cited by a One source finding: exit 0, "quotes: 2/2 verbatim (0 short or code
  quotes not checked)". The fabricated quote is checked nowhere and the tally says nothing
  was skipped. N4 closed only the all-notes case. Fix: report any of the typographic
  quote marks (U+201C, U+201D, U+201E, U+00AB, U+00BB) inside a note as a violation.
- `scripts/research-check.sh:205-206`: self-match is still a filename denylist. A copy of
  the report saved as `draft.md` in the sources dir verifies a falsified note 2 against
  itself, exit 0. Fix: a content test instead of a name test: refuse (exit 2) any sources
  file whose normalised text contains the normalised body of any note of the report.
- `scripts/research-check.sh:102-109`: `header()` accepts a `: ` that sits inside the first
  quote. `1. Acme docs, page "Plans: overview" says feature X on every plan "Tool A ships".`
  makes the region start mid-quote, so ` says feature X on every plan ` becomes the
  "quote" and satisfies both key terms: exit 0 without `--sources`. The quote count is even,
  so N8 does not fire. Fix: return None when `colon > first_quote`.
- `scripts/research-check.sh:6` claims the check finds "a reference to a ... note that does
  not exist", but only finding citations inside `## Findings` are checked. Unverified
  `- F2: one source (note 7).` with three notes: exit 0. Fix: run the `\(notes? ...\)`
  extraction over Answer, Unverified, Numbers and Implications too, or narrow the sentence.
- `tests/research-check.test.sh`: the deliberate relaxation (a backtick inside a note's
  source name) has no case. Mutation: putting the backtick back into `first_quote` leaves
  all 74 assertions green. Fix: add a case with a source such as ``Google `agy` docs,`` that
  must pass, with a message assertion.

Same-class note: the first three are recurrences of round-1 classes (an input the parser
does not interpret is passed as clean; a filename denylist; a quote-pairing inversion),
each closed in round 1 by an instance guard. Per `docs/eval-framework.md` stop condition 3,
this loop stops here and the human decides. The class-level fix is to make note parsing
fail closed: one header grammar with the colon before any quote mark, no typographic
quote marks, and a content-based self-match test.

Nitpicks
- `scripts/research-check.sh:195`: `--sources /` makes `root + os.sep` equal `//`, so the
  containment test never matches and the whole filesystem is walked. Use
  `os.path.commonpath([root, os.path.realpath(report)]) == root`.
- `scripts/research-check.sh:205`: the `RES-` match is case-sensitive.
- `scripts/research-check.sh:171-177`: Answer references outside parentheses are no longer
  checked; the header does not say so.
- `tests/research-check.test.sh:278-282`: the second python block is a no-op. N12 only
  exercises a narrow encoding where `en_US.ISO8859-1` exists. Most Linux images do not have
  it, so Python's C-locale UTF-8 coercion makes the case pass there without testing
  anything. Delete the no-op block and say in a comment which hosts the case covers.
- `scripts/research-check.sh:75-190`: `main()` is about 115 lines, and `check_sources`
  takes two closures as parameters. Split it into `parse_notes`, `parse_findings`,
  `check_finding` and `check_citations` at module level.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 1/2 -> total 9/12 (threshold: >=9, no zero)

## Ceiling

12/12 reachable. Nothing structurally caps this change. The documented meaning-level
limits (same fact or shared word, independence judged by name) are out of scope for a
mechanical check and are not scored against it.

## Regression

Improved: 8/12 -> 9/12. Testing 0 -> 1 (the Critical is fixed, the relaxation is
untested). Correctness stays at 1 (round-1 instances fixed, three same-class siblings
found). Conventions stays at 1 (the header claim on note references is not held).

## History

- Round 1, `25b2a85`, 8/12 REQUEST CHANGES: 1 Critical (the suite read internal
  `docs/research/RES-002`), 7 Important (silent exit 0 paths, self-match, terms satisfied
  by unchecked text, the same-source heuristic, duplicate notes, the exception exit code,
  the test-file invariant), 6 nitpicks.
- Round 2, `56ded01`, 9/12 APPROVE WITH COMMENTS: every round-1 finding was fixed for the
  inputs named. Three same-class recurrences, one header claim that does not hold and one
  untested relaxation remain Important. The loop stops under stop condition 3.
