---
artifact: scripts/research-check.sh + tests/research-check.test.sh + README.md (code part of d36c803); skills/research/rubric.md checked only for code or test dependencies
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 88acd30
artifact_version: 6
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 12/12
---

## Artifact

Commits `d36c803` and `88acd30` on `chore/research-one-fact-rule`, diff `c8ced0a..88acd30`.
This is a new change on the branch, round 1 of it: the human asked for the round-4 and
round-5 nitpicks to be done separately. `d36c803` changes `scripts/research-check.sh`:
headings and the text above the first `## ` (reported as "Title") are scanned, a link
address may hold one level of parentheses, an unclosed parenthesis is read to the end of its
paragraph, the header states that a number after `;` is qualifier text, the violation
message names every allowed form plus rewording, and the `)` split in `cited_notes` is
removed. It also adds cases R1 to R7 with a mutation recipe and sets the README count to
1557. `88acd30` only rewords the criterion 1 anchors in `skills/research/rubric.md`. The
skill-reviewer judges that wording. Here it was checked only for dependents: no script or
test greps the rubric text. No plan file exists for this change, so there is no contract to
check against.

## Verification (run by the reviewer)

- Focused suite at `88acd30`: 131 `ok:` lines, no FAIL. That is 116 at round 5 plus 15, and
  1542 + 15 = 1557 matches the README. `docs-claims-check.sh` reports a match.
- New test file against the `c8ced0a` script, with fixtures: exactly 10 FAIL lines, all
  from R3 to R7. R1 and R2 stay green, as the commit states.
- All seven recipe mutations applied to a copy, with full FAIL lines printed. Each reddens
  exactly the case and the count the recipe names: R1 (2), R2 (1), R3 (2), R4 (2), R5 (2),
  R6 (2), R7 (1). Every mutant was asserted to differ from the source.
- RES-002 output is byte-identical at `c8ced0a` and `88acd30`. RES-001 exits 2 on both.
- Diff has no em or en dashes.

## Top findings (round 1 of this change)

No Critical. No Important.

Nitpicks
- `scripts/research-check.sh:108`: the link class `[^()]` still admits whitespace and
  newlines, so a link missing its `)` swallows the balanced citations after it, up to any
  later stray `)`. Probe: `[wiki](https://w.org/a and X (F1, note 9) then (note 8) end)`.
  At `c8ced0a` this reported missing note 8. At `88acd30` it exits 0. This is a narrow
  regression on a typo shape. A CommonMark destination cannot hold a space unless it is in
  `<>`. Fix: `\]\((?:[^()\s]|\([^()\s]*\))*\)`. Probed: it reports notes 8 and 9, keeps all
  131 cases green and leaves RES-002 unchanged. Add the probe as R8.
- `d36c803` commit body: "The ')' split in cited_notes was dead code" is false. With two
  levels of nesting, one-level blanking leaves a `)`. `(F1, note 1, a (b (c) d) e 9)` exits 0
  at `c8ced0a` (the split cut the segment before `e 9`) and exits 1 at `88acd30`. The removal
  closed a fail-open path, so the code is better than claimed. But nothing pins it:
  restoring the `[;)]` split reddens 0 cases. Fix: add that input as a case, note it in the
  recipe ("restore the ) split -> R9 (2)"), and correct the claim in the next commit body.
  Do not rewrite history.
- `tests/research-check.test.sh:184` and `:424`: two different cases are labelled "R1"
  (the real-shaped report and the Notes-list parenthesis). R2 also shares the prefix. The
  full assertion text tells them apart, but the recipe reads "-> R1 (2)", which is
  ambiguous. Fix: rename the new group (for example S1 to S7) and update the recipe.
- `scripts/research-check.sh:115-117`: nested unclosed parentheses such as `(F1 (see note x.`
  print the same violation twice, once for each open paren. This is cosmetic.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reached. The nitpicks are on shapes no writer following SKILL.md step 4b produces
(a malformed link next to a stray `)`, or two levels of nesting with a digit), so they do
not lower a dimension under the stated threat model. Full marks are not a claim that the
parser is complete: the `;` residual is documented in the header and stays by design.

## Regression

Same: 12/12 -> 12/12. Every carried round-4 and round-5 nit that this change targets is
fixed and mutation-proven: headings, title and frontmatter are scanned, link addresses
with parentheses are handled, unclosed parentheses are read, the message names all forms,
the `;` residual is documented, and the three mutations that previously survived (`rest =
text`, no nested blanking, split only on `;`) are now pinned or turned into a stricter
behaviour. One new narrow regression (the broken-link shape above) is a nit. Branch
trajectory 8 -> 9 -> 9 -> 10 -> 12 -> 12.

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
- Change C round 1, `88acd30`, 12/12 APPROVE WITH COMMENTS: this change closes the round-4
  and round-5 nits. All 7 recipe mutations redden exactly as stated, and RES-002 is
  unchanged. New nits: the link class admits whitespace (a broken link hides later
  citations, a narrow regression against `c8ced0a`), the commit calls a live `)` split
  "dead" (its removal is a stricter, unpinned behaviour), a duplicate R1 label, and a
  duplicate message for nested unclosed parentheses.
