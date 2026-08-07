---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: 0fcc65b
artifact_version: 10
date: 2026-08-07
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: record regeneration at `0fcc65b`. Three wording changes since `995fde4`,
each verified in place; no scored criterion moved. Re-checked against
`agents/builder.md:15-27`, `docs/plan-format.md:22-40`,
`docs/eval-framework.md:55-79`, `agents/code-reviewer.md:136-142`,
`AGENTS.md:262-279`. Regenerated rather than re-dated because
`skills/build/SKILL.md` moved after the last reviewed commit.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Untouched.
- structure **2**. Untouched. The `### Model plan` subheading and the three-way
  paragraph split remain deliberately undone; recorded as carried, not as a defect,
  for the reason in round 3 (its scored symptoms were fixed; the split is
  maintainability advice for the next edit).
- worked example **2**. `:267` now reads "build_model_as_dispatched: <the model it
  was dispatched on>", matching the field's defined semantics in
  `docs/plan-format.md:36-38`, `docs/eval-framework.md:73-76` and
  `AGENTS.md:275-279`. This was the nit most worth doing: the example is the line a
  reader copies, so the old "ran on" gloss was the one path by which the overclaim
  could have re-entered past three files that carefully refuse it.
- precision **2**. `:62` now prints "at effort <as the user just told you>",
  retiring the last echo of the removed premise; the slot now describes its only
  legitimate source, which is what `:48-51` requires.
- safety integration **2**. `:198-200` now names all three contract preconditions
  (`approved: yes`, an `arch_review:` line that is not pending, and a `builder_tier:`
  line in `model_plan:`) and points at `agents/builder.md` as the authoritative
  list. Verified that the pointer resolves: `agents/builder.md:17-24` carries all
  three, including "the resolved model NAME ... its absence here is never a missing
  precondition and never a reason to refuse". One enumeration plus a reference is
  the pattern the standard asks for, so this stays a reference, not a second copy.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## New in these three lines?
Nothing that blocks, and nothing that scores. One cosmetic observation, explicitly
not a finding: `:62` is now about 106 characters, longer than its sibling lines in
the quoted question. It is a single quoted line, not the edit collision that made
line length worth mentioning in round 3, and the file already carries longer
pre-existing lines. Leave it or wrap it, either is fine.

## Ceiling
10/10, reached and held. Nothing structurally capped.

## Round-by-round (this branch)
- Round 1 (5b46abd): 6/10 FAIL. Four blocking findings.
- Round 2 (a2eec03): 9/10 PASS. All four closed; one residual contradiction.
- Round 3 (76188a6): 9/10 PASS. Contradiction closed; effort fix on the wrong
  sentence, stale duplicate, one ambiguous phrase.
- Round 4 (995fde4): 10/10 PASS. All three closed; precision 1 -> 2.
- Round 5 (0fcc65b): 10/10 PASS, regeneration. Three wordings; score holds.
  Trajectory 6 -> 9 -> 9 -> 10 -> 10, moved only by fixing files.

## Is it clean?
Yes. Nothing blocks. Every criterion is at 2, no instruction in the model-plan
block requires a value the agent cannot obtain, no two instructions disagree with
each other or with `AGENTS.md`, `docs/plan-format.md`, `docs/eval-framework.md`,
`agents/builder.md` or `agents/code-reviewer.md`, and no gate is touched or
weakened. Ready for the human gate as-is.

What this record is NOT, for the human: form verification, not behavioral. The
design rests on an agent at runtime walking the order of authority and asking,
instead of trusting the session-start model and a plausible-looking effort level
visible in its own context. Only an `/improve` subagent test (baseline without the
step, variant with it) can show that behavior holds, and it belongs after the
merge.

## Vs previous version
Version 9 (995fde4) scored 10/10 with three optional nits. Version 10 applies all
three: the example gloss now says "dispatched on" rather than "ran on", the effort
slot names its only legitimate source, and B5.3 enumerates the three contract
preconditions once and defers to `agents/builder.md`. No criterion moved, because
none of the three was holding a score down; the file is tighter at the same score.

## Map duty
No command surface added or altered (`docs/system-map.md:67` already carries
`/build` with both modes), so no map delta is required. Not a finding.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Strongest-model-available
  resolution added.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL. Build model became
  the user's choice; four blocking form defects (unobtainable enumeration,
  self-assessed ASK trigger, stale example, AGENTS.md not carrying the rule).
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS. All four closed;
  one residual contradiction inside the block.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS. Contradiction
  closed; provenance field moved from the plan to the code eval record coherently
  across five files. Precision held at 1 (effort fix on the wrong sentence).
- Round 9 (2026-08-07, Opus 5, strongest, 995fde4): 10/10 PASS. Effort fixed at the
  premise, duplicate deleted with its collided line, plan-write phrase
  disambiguated, provenance handover made loop-safe and explicitly best-effort.
  Precision 1 -> 2.
- Round 10 (2026-08-07, Opus 5, strongest, 0fcc65b): 10/10 PASS, regeneration only.
  Example gloss "ran on" -> "dispatched on" (closing the copy-paste path by which
  the overclaim could have re-entered), effort slot -> "<as the user just told
  you>", B5.3 enumerating all three contract preconditions with a pointer to
  `agents/builder.md`. No criterion moved. Clean for the human gate; behavioral
  confirmation still owed to `/improve`.
