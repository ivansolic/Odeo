---
artifact: scripts/skills-lint.sh C18 + tests/skills-lint.test.sh + docs/invariants.md + README.md
type: code
branch: chore/research-rubric-and-citations
reviewed_commit: eb7e7cb
artifact_version: 2
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## Artifact

Commit `eb7e7cb` on `chore/research-rubric-and-citations`, code scope only: C18 in
`scripts/skills-lint.sh`, its cases in `tests/skills-lint.test.sh`, the C18 row in
`docs/invariants.md`, and the README assertion count. Round 2, reviewed against
`c2ca2a2..eb7e7cb` plus the round 1 scope. `skills/research/SKILL.md` and `rubric.md` are
reviewed by skill-reviewer (`docs/evals/skill-research.md`).

## Verdict

APPROVE. The round 1 Important is fixed and all three nitpicks are addressed.

## Round 1 findings, rechecked

- Important (C18 passed without checking anything when there was no backtick fence): fixed.
  awk counts the fence lines and its END block prints `nofence` unless the count is exactly
  2. The loop turns that into a C18 violation, and the message renders the backticks
  literally (escaped inside double quotes).
  Probes:
  - A `~~~` rubric is now flagged; the new test case expects exit 1.
  - A rubric with two fenced blocks reports both the hit in the second block and the
    `nofence` line.
  - The real repo still passes the lint (rc 0).
- The "exactly one closed block" choice is not too strict. Adding a second code block to
  the rubric fails loudly, and the message names the cause, so whoever adds it has to
  decide how C18 should treat the new block. Failing loudly is the right default for a
  check whose silent failure mode was "checks nothing".
- Nitpick (scorer notes not checked; capitalised "Unverified" meant as "not verified" not
  caught): both are now stated in the invariants row and in the lint comment. The row and
  the code agree.
- Nitpick (no test with a language-tagged fence): added (```` ```text ````, expects 1). With
  two fence lines, the only way to exit 1 is the criterion hit, so the case tests what it
  says.
- README 1424 -> 1426 matches the two new `check` calls.

## Checked and clean

- Subshells: the loop is still fed by `< <(awk ...)`, so `viol` runs in the parent shell
  and `fail` keeps its value.
- House rules: no em or en dashes in the round 2 diff, comments in English, Conventional
  Commit subjects.
- I did not re-run the full suite: the builder reported 39/39 and docs-claims-check green,
  and I ran the lint against the real repo and three scratch fixtures.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12 reached.

## History

- Round 1 (`c2ca2a2`): APPROVE WITH COMMENTS, 11/12, correctness 1. C18 did not check
  anything when the rubric had no backtick fence (I reproduced it with `~~~`). Nitpicks:
  scorer notes outside the scope, capitalised "Unverified" allowed, no test with a
  language-tagged fence.
- Round 2 (`eb7e7cb`): APPROVE, 12/12. C18 now fails closed when there is not exactly one
  closed fence, the limits are documented, and two test cases were added. Trajectory:
  11/12 -> 12/12 (correctness 1 -> 2).
