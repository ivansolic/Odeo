---
artifact: skills/build/SKILL.md
type: skill
artifact_version: 5
date: 2026-07-30
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: form review of the strongest-model-available change to the "Model plan,
asked before any work" step. Two coordinated edits in the Model-plan step
(lines 37-56): the opening sentence now also requires resolving the STRONGEST
model available on the host LIVE (from the current official lineup, never a
cached table) alongside the session model; the closing sentence changed from
"below the strong tier OR below high effort" to "below the STRONGEST model
available on this host (resolve the current lineup live, never from a cached
table) OR below `high` effort", and now also requires naming the stronger model
+ how to switch (`/model`) and, for architecture-critical work, recommending a
switch-up first (question, not a block). Whole skill re-scored for consistency,
and cross-checked against the parallel AGENTS.md model-policy update.

## Skill: build  (explicit command)

## Scores
- trigger clarity 2: `disable-model-invocation: true` + description opens "Build
  one or more ready user stories. Two modes you choose..." with an example
  invocation ("/build USR-001 USR-002 in parallel"). Correct explicit-command
  format; untouched by this change.
- structure 2: Follows the body shape and stays lean (237 lines < 500); no
  supporting files, so the one-level rule is not at risk. The edited step reads
  as two long sentences but stays inside the existing Model-plan paragraph and
  adds no new section. No wall of text.
- worked example 2: Lines 200-218 remain concrete with real values
  (`docs/plans/2026-07-14-usr-012-timer.md`, `../dogfood-usr-012`, `12/12
  APPROVE`). The example shows the happy path where the session model IS the
  strongest available (user answers "continue"), so the new conditional flag
  correctly does not fire there. The example does not lag the edited step: the
  step's spoken Model-plan question (lines 43-46) still matches lines 206-208
  verbatim in shape, and the strongest-available obligation is a CONDITIONAL
  branch (only when the session model is not the strongest), which a single
  linear example is not obligated to exercise. See the non-blocking nit for the
  optional variant line. Score holds at 2.
- precision 2: Exact throughout. The step names the exact mechanism (`/model`),
  the exact roles (session model + effort for judgment; builder tier + `high`
  effort for execution), the exact architecture-critical set ("plans, security,
  reviews"), and the exact live-resolution rule ("resolve the current lineup
  live, never from a cached table"). No model version is baked in; no TBDs.
- safety integration 2: The change STRENGTHENS the judgment-model policy and
  weakens no gate. It references guardrails without restating them and stays a
  question, not a block ("recommend switching up first (question, not a block,
  the choice is the user's)"), which is the correct posture, human-in-command.
  The spec gate (section 1), the plan gate (B5.3), the ENFORCED
  `boundary-check.sh` (B6), and the merge gate (B7) are all untouched.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Consistency verdict (the gating question)
CORRECT and internally consistent, and consistent with AGENTS.md.
- Internal: the opening sentence (lines 37-42) introduces the strongest-available
  resolution and the closing sentence (lines 52-56) acts on it; the two halves
  agree. The "never bake model names into this file; speak in tier + effort"
  instruction (lines 41-42) is not contradicted by the new text, which speaks in
  "the STRONGEST model available on this host" and points at `/model`, not at a
  named model.
- AGENTS.md: matches the parallel policy exactly. AGENTS.md lines 46-51 ("'The
  strongest you have' is resolved LIVE against the CURRENT official model
  lineup ... never from memory or a cached model table ... If the SESSION model
  is not the strongest available, say so before running judgment and name the
  stronger model + how to switch (`/model`), especially for architecture-critical
  work") and the tier-map line 71-72 ("strongest = the top tier available on the
  user's actual subscription, resolved LIVE from the current official lineup
  (never asserted from memory or a cached table)") are the same rule the skill
  now enforces at the point of use. No contradiction.
- Host-neutral: the change speaks in tier + "the strongest available", points at
  `/model` as the Claude Code mechanism (with the per-host adapter caveat already
  present at lines 47-48), and does NOT hardcode any model name. The motivating
  incident (Opus 4.8 vs Opus 5 / Fable 5) is correctly kept out of the file.
- Actionable/unambiguous: WHEN to flag = "if judgment would run below the
  strongest model available OR below `high` effort"; WHAT to say = name the
  stronger model + how to switch (`/model`), and for architecture-critical work
  recommend switching up first. Both the condition and the required utterance are
  specified.

## Ceiling
Max reachable: 10/10, achieved. Explicit command (trigger clarity judged on plain
what-you-get, achieved); the change is guardrail-adjacent (judgment-model policy),
so safety integration can reach 2 and does. Nothing is structurally capped.

## Non-blocking nits (would tighten, do not lower any score)
1. The Model-plan step is now the longest paragraph in the skill and states the
   live-resolution rule twice (opening sentence and closing sentence). This is a
   deliberate belt-and-suspenders on a high-risk judgment point, defensible, but
   the closing sentence could shorten to "below the STRONGEST model available
   (resolved live, per the opening) OR below `high` effort" and let the opening
   own the "never cached" qualifier once.
2. The worked example only shows the happy path (session model already strongest,
   user says "continue"). A one-line variant showing the flag firing, e.g.
   `"Heads-up: <session model> is not the strongest available; <stronger> is.
   For this architecture work I'd switch up, /model. Continue as-is or switch?"`
   would make the new conditional directly imitable. Not required (a single
   linear example need not cover every branch, and the prose is exact), so
   worked example stays at 2; adding it would be a strict improvement.

No em/en dashes present; English only. Confirmed.

## Map duty
No command surface added or altered (a model-policy tightening on the existing
`/build`), so no `docs/system-map.md` delta is required. Not a finding.

## Round-by-round
- Round 1 (2026-07-30): 10/10 PASS. All five criteria held at 2. The
  strongest-model-available change is internally consistent (opening and closing
  sentences agree), matches the parallel AGENTS.md model policy verbatim in rule,
  stays host-neutral (no baked model name, points at `/model`), is actionable
  (condition + required utterance both specified), and touches no gate, it
  strengthens the judgment-model policy.

## Vs previous version
Version 4 (2026-07-27) scored 10/10 after removing the for-me editor-open offer.
Version 5 tightens the Model-plan step to require resolving the strongest model
available on the host LIVE (never cached) in addition to the session model, and
to flag + recommend a switch-up for architecture-critical work when judgment
would run below it. Score holds at 10/10; no regression on any criterion. The
change hardens a guardrail-adjacent judgment point and adds no enforcement risk.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed
  to mirror the step. Gap closed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules. Correct and internally consistent.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed; Mode A editor step intact; no gate touched.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Model-plan step now
  resolves the STRONGEST model available on the host live (never cached) as well
  as the session model, and names the stronger model + `/model` and recommends a
  switch-up for architecture-critical work when judgment would run below it.
  Consistent with the parallel AGENTS.md model-policy update (lines 46-51 and the
  tier-map line 71-72); host-neutral (no baked model name); actionable and
  unambiguous; strengthens, does not weaken, the judgment-model policy. Two
  non-blocking nits (rule stated twice; example shows only the happy path);
  neither crosses a rubric boundary, so 10/10 stands.

Note: this is a form review. The delta is partly behavioral (whether the agent
actually resolves the strongest available model live and fires the switch-up
flag rather than treating the session model as "strongest"). Recommend an
`/improve` subagent test to confirm the runtime behavior. The file form is clean
and ships.
