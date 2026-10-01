---
artifact: docs/plan-format.md
type: skill
branch: feature/plan-human-layer
reviewed_commit: babe300
artifact_version: 4
date: 2026-10-01
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: a human-approved confirmation pass at `babe300` (Ivan chose option b after round 3 hit
the cap). It is outside the capped review loop. Per the dispatcher, `babe300` changes exactly
one line in this artifact: the Success signal example row. I verified that row at `:198`. I
re-resolved the round-3 anchors (Summary `:86-87`, File map `:144-148`, Review Focus
`:190-191`, Out of scope `:202`); all hold at their round-3 lines. I hold no shell, so I ran no
diff. Anchor matching proves the quoted lines and their positions, not every character between
them. The lint and suite results are the dispatcher's statements. This record REPLACES round
3's (`e5dbea0`). `effort: high` is the value declared in this agent's frontmatter, not an
observed runtime value. Trigger clarity is scored as "does each file say when its rule
applies", because these are format documents, not a SKILL.md with a description.

## Skill: plan-format human layer  (format source for an explicit command, /odeo:build B5)

## Scores
- trigger clarity: 2, `:23` "A plan has two readers: the human at the gate ... and the
  builder"; `AGENTS.md:206-207` says which file shapes which plan.
- structure: 2. The order stated at `:25-28` matches the template (Risks `:183`, Review Focus
  `:186`, Success signal `:193`, Out of scope `:200`). Both `Plan layers:` lines are identical.
- worked example: 2, real values in every human-layer section, and the running example is
  now coherent from Summary to Success signal.
- precision: 2. The round-3 residual is closed. `:198` now reads `| "shows which language is
  in force and where it comes from" (USR-00X) | bash tests/language-status.test.sh |`. That
  matches the Summary's "How we will know it works" (`:86-87`) and the File map's test row
  (`:145`). Every layer of the example now describes the same story. The decision class
  (`:73-76`) stays exact and defined once.
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
it should not be flagged. This is the round 2 A/B decision-completeness gap, and only a
subagent test shows the reviewer catches it.

## Integrity
No sign of text copied from another project.

## Map duty
No command added; `docs/system-map.md` needs no change.

## Vs previous version
Round 3 (`e5dbea0`) 9/10 -> confirmation pass (`babe300`) 10/10. Precision went 1 -> 2 (the
Success signal row now belongs to this plan's story). Every other criterion stayed 2. No
regression.

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
