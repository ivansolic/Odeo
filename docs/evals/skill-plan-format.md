---
artifact: docs/plan-format.md
type: skill
branch: feature/plan-human-layer
reviewed_commit: 2859827
artifact_version: 4
date: 2026-10-01
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: a RE-ANCHOR at `2859827`, not a new review round. Per the dispatcher, the branch was
rebased onto the released main `95d17e3` (0.3.3: a plugin.json bump, README wording, two eval
records). None of those touches `docs/plan-format.md`, `global/CLAUDE.md`, `AGENTS.md` or
`skills/build/SKILL.md`, and `git range-diff` shows "=" on all 11 branch commits. This record
REPLACES the confirmation pass's (`babe300`).

Checked, with its limit: I hold no shell, so I cannot run `git range-diff` or a diff. Instead I
re-resolved the confirmation-pass anchors in this worktree, and every one holds at its
`babe300` line:
- `docs/plan-format.md`: `Plan layers:` `:21`, the layer-order prose `:25-28`, "technical layer
  wins" `:29-30`, `## Summary for humans` `:68`, the decision class `:73-76`, "How we will
  know it works" `:86-87`, the File map test row `:145`, Risks `:183`, Review Focus `:186` with
  the subfolder example `:190-191`, Success signal `:193` with the fixed row `:198`, Out of
  scope `:200`, criterion 6 `:293`.
- `global/CLAUDE.md`: `Plan layers:` `:30` (identical to `plan-format.md:21`), "five items"
  `:31`, Review Focus `none` `:39`, the precedence line `:43`, "default on" `:17`.
- `AGENTS.md`: "default on" `:203`, the plans bullet `:204-207`.
- `agents/architecture-reviewer.md`: the criterion-6 paragraph `:28-32`.

This proves the quoted lines and their positions, not every character between them. Together
with the dispatcher's `range-diff` result, it is a strong equivalence argument. Scores and
findings are carried unchanged from the confirmation pass. The lint and suite results are the
dispatcher's statements. `effort: high` is the value declared in this agent's frontmatter, not
an observed runtime value. Trigger clarity is scored as "does each file say when its rule
applies", because these are format documents, not a SKILL.md with a description.

## Skill: plan-format human layer  (format source for an explicit command, /odeo:build B5)

## Scores
- trigger clarity: 2, `:23` "A plan has two readers: the human at the gate ... and the
  builder"; `AGENTS.md:206-207` says which file shapes which plan.
- structure: 2. The order stated at `:25-28` matches the template (Risks `:183`, Review Focus
  `:186`, Success signal `:193`, Out of scope `:200`). Both `Plan layers:` lines are identical.
- worked example: 2, real values in every human-layer section, and the running example is
  coherent from Summary to Success signal.
- precision: 2, `:198` `| "shows which language is in force and where it comes from"
  (USR-00X) | bash tests/language-status.test.sh |`. That matches the Summary `:86-87` and the
  File map `:145`. The decision class (`:73-76`) is exact and defined once.
- safety integration: 2, `:29-30` "the technical layer wins and the disagreement is a finding
  for the plan review"; the session-plan copy at `global/CLAUDE.md:43-44`; the named holder at
  `agents/architecture-reviewer.md:28-32`. No guardrail restated.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10, reached.

## Findings
None open.

## Behavioral follow-up
Form only. Run `/odeo:improve` on `agents/architecture-reviewer.md` with two seeded plans. In
one, a Design decision changes what the user gets but is missing from `What you decide`; it
should be flagged. In the other, a purely technical decision stays in Design decisions alone;
it should not be flagged.

## Integrity
No sign of text copied from another project.

## Map duty
No command added; `docs/system-map.md` needs no change.

## Vs previous version
Confirmation pass (`babe300`) -> re-anchor (`2859827`): every criterion 2 -> 2, total 10 -> 10.
The artifact reads as it did at `babe300`. No regression.

## History
- Round 1 (2026-10-01, Opus 5.5 [1M], strongest, d995419): 7/10 FAIL. The layer order did not
  match the template, the human layer had no example, Review Focus `none` conflicted across
  files, and B5.3 and the plan reviewer did not point at the Summary.
- Round 2 (2026-10-01, Opus 5.5 [1M], strongest, 4f001fa): 9/10 PASS. All six round-1 fixes
  closed. Two LOW example slips.
- Round 3 (2026-10-01, Opus 5.5 [1M], strongest, e5dbea0): 9/10 PASS. Both slips closed. The
  loop stopped at the cap and on a repeated class, with one LOW residual (the Success signal
  row belonged to another story), handed to the human.
- Confirmation pass (2026-10-01, Opus 5.5 [1M], strongest, babe300): 10/10 PASS. This was a
  human-approved confirmation pass outside the capped loop (Ivan, option b). It applied the
  residual's exact one-row fix and verified it. Trajectory: 7 -> 9 -> 9 -> 10.
- Re-anchor (2026-10-01, Opus 5.5 [1M], strongest, 2859827): 10/10 PASS, unchanged. This was
  a re-anchor after the rebase onto the released main `95d17e3` (0.3.3), not a review round.
  Every anchor holds by reading; `range-diff` "=" on 11 commits is the dispatcher's statement.
