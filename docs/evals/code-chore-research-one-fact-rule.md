---
artifact: scripts/research-check.sh + tests/research-check.test.sh + README.md (code part of 57daa41)
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 57daa41
artifact_version: 9
date: 2026-10-21
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

## Artifact

Commit `57daa41` on `chore/research-one-fact-rule`, code diff `81877e4..57daa41` (the commit
between them, `d932b4f`, holds only eval records). This is round 4 of change C, run past the
three-round cap because the human authorized it after choosing round-3 option (a). In
`paren_texts`, a `(` directly after `]` is a link only if `re.match(r"[ \t]*notes?\s", ...,
re.I)` does not match the text after it. The header comment and the docstring state the
rule. S13 `[F1](note 9)` and S14 `[F1](Notes 1 and 9)` are new red cases. The round-3 nits
are handled: the S group header is rewritten, S5 is named a regression lock and the long
line is rewrapped. The duplicate message for nested unclosed parentheses stays, by the
human's decision. The README count is now 1571. No plan file exists for this change, so
there is no contract to check against.

## Verification (run by the reviewer)

- The four round-3 probes, each inserted once into the suite's good fixture and run against
  `81877e4` and `57daa41`:
  - `[F1](note 9).`: exit 0, then **1**, "cites missing note 9".
  - `[F1](notes 1 and 9).`: exit 0, then **1**, "unreadable note citation".
  - `per [docs][1](note 9).`: exit 0, then **1**, "cites missing note 9".
  - `\[F1\](note 9).`: exit 0, then **1**, "cites missing note 9".
- Exit 1 on both commits, so no change: `[d](https://a.dev)(note 9)`, an image followed by
  ` (note 9)`, `"the [new] plan"(note 9)`, `(F1, verified, note 9, see [d](...))`,
  `[d](https://a.dev/(note 9))`, a titled link with `(notes)` in the title, and
  `(note 9; see [d](https://a.dev/release notes))`.
- New shapes, caught at `57daa41`: `[F1]( note 9)`, `[F1](NOTE 9)`,
  `[F1](note 9, see [d](https://a.dev))`, `[F1](note` followed by a line break and `9)`, an
  unclosed `[F1](note 9`, and `[F1](note 9)` in a heading.
- Stays allowed: `[d](notes.md)` and `[g](note-taking.md)` both exit 0. The named
  residual `[d](notes "Title")` raises a false alarm (exit 1), which is fail-closed, as the
  commit body says.
- Still skipped after `]`, while the same parenthesis without the bracket is flagged:
  `[F1](notes, 1)` (caught at `9705c4e`), `[F1](` followed by a line break and `note 9)`
  (caught at `9705c4e`), and `[F1](note:9)` (also skipped at `9705c4e`). See the nit.
- The S group header's claim "each case is red on `c8ced0a` except S1, S2 and S8 to S12"
  holds for S13 and S14: both shapes exit 0 at `c8ced0a`.
- The research suite gives 145 ok and no FAIL. The author's mutation run (S13 and S14
  redden, 4 assertions) matches the probe deltas above and was not repeated. The full
  40-suite run was not repeated. The diff has no em or en dashes.

## Top findings (round 4 of this change)

No Critical. No Important.

Nitpicks
- `scripts/research-check.sh:118`: the peek wants whitespace right after the note word, and
  only spaces or tabs before it. So `[F1](notes, 1)` and `[F1](` followed by a line break
  and `note 9)` are still read as link addresses. Both are malformed or unusual citations,
  and the header comment states the exact rule. Still, the commit body's "never a miss" is
  not true for them, and `9705c4e` caught both. Fix:
  `re.match(r"\s*notes?(?=[\s,;:])", text[i + 1:], re.I)`. This keeps `notes.md` and
  `note-taking.md` as links, and the only new false alarm is an address like `notes,x`. Add
  `[F1](notes, 1)` as a red case. The alternative is to accept these shapes as the bounded
  residual, which is what the header already describes. Checked on a copy: with this
  regex, all 145 research-suite assertions pass, the six caught shapes above stay caught,
  the three skipped shapes are caught, and `notes.md` and `note-taking.md` stay at exit 0.
- `scripts/research-check.sh:123-126`: the duplicate message for nested unclosed
  parentheses is carried forward by the human's decision.

## Stop condition

Approve. The verdict is APPROVE WITH COMMENTS at the maximum score, so the loop stops. The
nit above does not lower a dimension.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached. The residual shapes are malformed citations the documented rule names, so
they stay a nit, not a correctness cap.

## Regression

Better: 11/12 -> 12/12. The round-3 Important (any `](` counted as a link) is fixed and
pinned by S13 and S14. Change C trajectory 12 -> 11 -> 11 -> 12. Branch trajectory 8 -> 9
-> 9 -> 10 -> 12 -> 12 -> 11 -> 11 -> 12.

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
- Change C round 4, `57daa41`, 12/12 APPROVE WITH COMMENTS, run past the cap on the human's
  authorization after choosing option (a): a `(` after `]` is read as a citation when it
  starts with the word note or notes and whitespace. All four round-3 probe misses are
  caught, S13 and S14 pin them, and the three round-3 nits are fixed or carried by the
  human's decision. Residual nit: two malformed shapes after `]` (`(notes, 1)` and a line
  break right after `(`) are still skipped, which the commit body's "never a miss"
  overstates.

