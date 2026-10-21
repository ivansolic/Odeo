---
artifact: scripts/research-check.sh + tests/research-check.test.sh + README.md (code part of 9705c4e); skills/research/rubric.md checked only for code or test dependencies
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 9705c4e
artifact_version: 7
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 12/12
---

## Artifact

Commit `9705c4e` on `chore/research-one-fact-rule`, diff `88acd30..9705c4e`. This is round 2
of change C (the round-4 and round-5 nitpicks). The link-address class in `paren_texts` now
excludes whitespace, `\]\((?:[^()\s]|\([^()\s]*\))*\)`. The new test group is renamed S1 to
S9, and two cases are added: S8 (a link missing its `)`) and S9 (text after a two-deep nested
parenthesis). The mutation recipe is extended and the README count is now 1561. The commit
body corrects the false "dead code" claim in `d36c803` without rewriting history. The
`skills/research/rubric.md` change belongs to skill-reviewer. Here it was checked only for
dependents: no script or test greps it. No plan file exists for this change, so there is no
contract to check against.

## Verification (run by the reviewer)

- Focused suite at `9705c4e`: 135 `ok:` lines, no FAIL. That is 131 + 4, and 1557 + 4 = 1561
  matches the README.
- Probes run against the scripts at `c8ced0a`, `88acd30` and `9705c4e`, each case inserted
  once into the suite's good fixture:
  - `[wiki](https://w.org/a and X (F1, verified) then (note 8) end)`: exit 1, 0, 1. The
    round-1 regression is closed.
  - `[docs](https://a.dev/x "release notes")`: exit 0, 0, **1** ("unreadable note citation").
  - `[docs](<https://a.dev/release notes>)`: exit 0, 0, **1**.
  - `[docs](https://a.dev/x "note 9")`: exit 0, 0, **1**.
- Candidate fix, applied to a copy (see Important): all 135 cases stay green, S8 and a
  titled variant of S8 stay red, and both valid forms above exit 0.
- Diff has no em or en dashes. The author's mutation runs (S8 (2), S9 (2)) and the full-suite
  run were not repeated.

## Top findings (round 2 of this change)

No Critical.

Important
- `scripts/research-check.sh:108`: excluding `\s` rejects valid CommonMark that both earlier
  versions accepted. A link with a title, `[docs](https://a.dev/x "release notes")`, or an
  angle-bracket destination with a space, `[docs](<https://a.dev/release notes>)`, is no
  longer stripped. Its parenthesis is then read as a citation, so a correct report fails
  with "unreadable note citation". This regression is fail-closed. The docstring claim at
  `:104`, "no spaces, as in CommonMark", is false for exactly these two forms. The round-1
  suggestion that produced this regex came from this reviewer, and it missed titles.
  Fix: `\]\((?:<[^<>\n]*>|(?:[^()\s]|\([^()\s]*\))*)(?:[ \t]+(?:"[^"\n]*"|'[^'\n]*'))?[ \t]*\)`.
  Probed: 135 green, S8 red, both valid forms exit 0. Add the titled link and the
  angle-bracket link as allowed cases.

Nitpicks
- `tests/research-check.test.sh:416`: "each red on c8ced0a except S1 and S2" is false for
  S8, which passes on `c8ced0a` (that script reports missing note 8). Fix: "except S1, S2
  and S8".
- `scripts/research-check.sh:104-105`: the rewrapped docstring line is about 118 columns,
  while the rest of the file wraps at about 92. Fix: rewrap.
- `scripts/research-check.sh:115-117`: the duplicate message for nested unclosed
  parentheses is carried forward. It is cosmetic and was left by the author's decision.

## Stop condition 3 (two consecutive rounds, same class)

Class: **the link-extent regex approximates CommonMark by hand**. Round 1 found the regex
too loose, because whitespace let a broken link swallow citations. Round 2 finds it too
tight, because the whitespace ban rejects titles and `<>` destinations. Each fix is another
alternation in the same regex, and the candidate above leaves the next instances open:
backslash-escaped parentheses, a title in parentheses or spanning a line, and a title next
to a broken link. The loop stops here. The human chooses:
(a) apply the candidate regex and document the remaining residuals in the docstring;
(b) remove the class: stop deleting link targets, and skip only the OUTER parenthesis that
directly follows `]`. The stack scanner still reads every nested parenthesis, so S8 stays
caught and titles stop mattering. The cost is that a nested URL part containing "note" is
read, so S5 and the URL cases would need re-checking;
(c) revert to the `88acd30` regex and accept the round-1 broken-link residual.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 11/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reachable once the titled and angle-bracket links are accepted again. The class
residuals left after option (a) are typo or rare shapes and would not lower a dimension
under the stated threat model. Option (b) would also clear them.

## Regression

Worse: 12/12 -> 11/12. Round-1 nits 1, 2 and 3 are fixed, and S8 and S9 pin them. Nit 4 is
carried by decision. The fix for nit 1 introduced a fail-closed regression on valid link
syntax. Branch trajectory 8 -> 9 -> 9 -> 10 -> 12 -> 12 -> 11.

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
- Change C round 2, `9705c4e`, 11/12 APPROVE WITH COMMENTS: nits 1 to 3 are fixed and
  pinned (S8, S9, S-labels), and the commit body corrects the dead-code claim. New
  Important: the whitespace ban, suggested by this reviewer in round 1, rejects titled
  links and `<>` destinations (a fail-closed regression on valid CommonMark). This is the
  same class as round 1, so the loop stops under stop condition 3 and the human picks (a),
  (b) or (c).
