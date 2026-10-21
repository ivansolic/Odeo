---
artifact: scripts/research-check.sh + tests/research-check.test.sh + README.md (code part of 81877e4); skills/research/SKILL.md checked only for code or test dependencies
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 81877e4
artifact_version: 8
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

## Artifact

Commit `81877e4` on `chore/research-one-fact-rule`, diff `9705c4e..81877e4`. This is round 3
of change C. The human chose option (b) from round 2: `paren_texts` no longer strips link
targets with a regex. A `(` directly after `]` is marked as a link and is not output, the
characters whose innermost open parenthesis is a link are blanked, and parentheses nested
inside a link are still output. Three cases are new: S10 (a titled link), S11 (a `<>`
address with a space) and S12 (a link address with its own parentheses inside a
citation). The round-2 nits for the S-label comment and the docstring wrap are fixed, and
the README count is now 1567. The `skills/research/SKILL.md` line 60 change belongs to
skill-reviewer. Here it was checked only for dependents, and none exist. No plan file exists
for this change, so there is no contract to check against.

## Verification (run by the reviewer)

- Probes, each inserted once into the suite's good fixture and run against `9705c4e` and
  `81877e4`:
  - `[F1](note 9).`: exit 1, then **0**. Note 9 is missing, and the miss is new.
  - `[F1](notes 1 and 9).`: exit 1, then **0**. The citation is malformed, and the miss is new.
  - `per [docs][1](note 9).`: exit 1, then **0**. The miss is new.
  - `\[F1\](note 9).`: exit 1, then **0**. The miss is new.
  - Exit 1 on both, so no change: `[d](https://a.dev)(note 9)`, an image followed by
    ` (note 9)`, `"the [new] plan"(note 9)`, `(F1, verified, note 9, see [d](...))`,
    `[d](https://a.dev/(note 9))`, a titled link with `(notes)` in the title, and an
    unclosed link followed by an unclosed `(note 9` in a later paragraph.
  - `(note 9; see [d](https://a.dev/release notes))`: exit 1 on both. At `9705c4e` it was a
    false alarm on the address, and now it reports the real missing note 9.
- S5 and Q7 were checked by reading the code and the probes. S5,
  `(F1, see [wiki](https://w.org/Foo_(bar)), note 9)`: the outer parenthesis is not a
  link, `(bar)` is read on its own and then removed by `cited_notes`, and `note 9` is still
  read, so the label holds. Q7 still reddens under its recorded mutation (keep link targets).
- Candidate fix, applied to a copy (see Important): every case stays green except R1, which
  fails the same way in an unmodified copy because it needs repo files, so the cause is the
  environment. All four probe misses are caught, and RES-002 output is unchanged.
- The diff has no em or en dashes. The author's mutation runs and the full-suite run were
  not repeated.

## Top findings (round 3 of this change)

No Critical.

Important
- `scripts/research-check.sh:115`: removing the class traded it for a narrow miss. Any `(`
  directly after `]` now counts as a link, whatever it contains. A citation written right
  after a bracket, with no space, is therefore skipped: `[F1](note 9)`,
  `[F1](notes 1 and 9)`, `[docs][1](note 9)`, `\[F1\](note 9)`. All four are caught at
  `9705c4e`, because the old regex refused an address with a space. `[x](note 9)` is not a
  CommonMark link either, so a reader sees a citation while the checker sees nothing.
  Step 4b never shows this shape, so it is rare. It is still a miss in a check documented as
  FAIL CLOSED. It is not the round-2 class: the fix decides whether a parenthesis is a link,
  not where its address ends. The round-2 option (b), written by this reviewer, did not
  name this cost. Fix: `opened.append((i, i > 0 and text[i - 1] == "]" and not
  re.match(r"[ \t]*notes?\s", text[i + 1:], re.I)))`. A link address cannot start with the
  word note followed by whitespace, so this checks one fact rather than copying the
  grammar. Its residual is fail-closed: `[x](notes "Title")` would raise a false alarm. Add
  `[F1](note 9)` as a case that must stay red. The alternative is to accept the miss and
  name it in the header comment and the docstring.

Nitpicks
- `tests/research-check.test.sh:419-422`: no mutation in the recipe reddens S5 any more.
  Under every listed link mutation it still exits 1. Its label is still true, but nothing
  records what S5 guards. Fix: name it in the comment as a lock for nested link
  parentheses.
- `tests/research-check.test.sh:416`: the corrected comment line is 112 columns, while the
  block wraps at about 92. Fix: rewrap.
- `scripts/research-check.sh:123-126`: the duplicate message for nested unclosed
  parentheses is carried forward by the author's decision.

## Stop condition 2 (three rounds on this artifact)

Change C has had three rounds: `88acd30`, `9705c4e` and `81877e4`. The loop stops here. Open
items: the Important above and the three nits. What moved between rounds: round 1 found the
regex too loose, round 2 found it too tight, and round 3 removes the regex. The removal
fixes the round-1 and round-2 shapes plus the residuals round 2 named (titles, `<>`,
parentheses nested two deep), all pinned by S8 and S10 to S12. What did not move: some
input shape still decides what counts as a link. The human chooses:
(a) apply the one-line peek above and add the red case;
(b) accept the `](note N)` miss and document it in the header comment and the docstring;
(c) merge as is, with the residual recorded only here.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 11/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reachable with option (a). The remaining residual is a fail-closed false alarm on a
relative link to a file named `note` or `notes` that has a title, which would not lower a
dimension. Option (b) keeps the miss, so it caps correctness at 1.

## Regression

Same score: 11/12 -> 11/12. Different residual: the round-2 fail-closed regression on titled
and `<>` links is gone, and both are now pinned. The new residual is a narrow miss: no space
between `]` and `(`. Change C trajectory 12 -> 11 -> 11. Branch trajectory 8 -> 9 -> 9 -> 10
-> 12 -> 12 -> 11 -> 11.

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

- Change C round 3, `81877e4`, 11/12 APPROVE WITH COMMENTS, the round the human authorized
  after choosing option (b): the link regex is gone, and S10 to S12 pin titles, `<>`
  addresses and nested link parentheses. The round-2 nits are fixed. New Important: any
  `](` counts as a link, so a citation written directly after `]` (`[F1](note 9)`) is
  skipped, a narrow miss that `9705c4e` caught. The loop stops under stop condition 2
  (three rounds), and the human picks (a), (b) or (c).
