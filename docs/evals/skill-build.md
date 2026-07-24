---
artifact: skills/build/SKILL.md
type: skill
artifact_version: 2
date: 2026-07-24
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: form review of the branch `feature/model-policy-effort` change. Round 2,
re-review after the worked-example fix from Round 1 was applied.

## Skill: build  (explicit command)

## Scores
- trigger clarity 2: `disable-model-invocation: true` + description opens "Build
  one or more ready user stories. Two modes you choose..." with an example
  invocation ("/build USR-001 USR-002 in parallel"). Correct explicit-command
  format (what-you-get + when), unchanged since Round 1.
- structure 2: Follows the body shape (essence, modes, process, worked example,
  safety rules), 222 lines (< 500), no supporting files so the one-level rule is
  not at risk. The changed step stays lean.
- worked example 2: NOW MATCHES the edited step. Line 193-194 reads "Model plan:
  thinking/reviews on <session model, resolved now> at effort <session effort>,
  building on <builder tier> at effort high. Continue, or change? (`/model` for
  model, `/effort` for effort)". Effort is present for BOTH roles ("at effort
  <session effort>" for judgment, "at effort high" for the builder) and the
  per-host mechanism is shown (`/model` + `/effort`), mirroring the process step
  at lines 37-51. The stale contradiction that capped Round 1 is resolved.
- precision 2: Exact throughout, tier + effort vocabulary ("strong tier",
  "`high` effort"), exact host mechanism (`/model`, `/effort`), exact record
  field (`model_plan:`). The `<...>` angle-brackets are deliberate
  live-resolution slots, not TBDs.
- safety integration 2: References the guardrail rather than restating it, the
  step points at "the per-host adapter in AGENTS.md" and frames the sub-strong /
  sub-high flag as "a question, not a block, the choice is the user's", matching
  the human-in-command honesty rule.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
Max reachable: 10/10, now achieved. Nothing is structurally capped: explicit
command so trigger clarity is judged on the plain what-you-get format (achieved),
and the step genuinely touches a guardrail so safety integration reaches 2.

## Map duty
This change does not add or alter a command surface (it refreshes the worked
example only); `/build` was already catalogued. No `docs/system-map.md` delta
required by this round. Not a finding.

## Round-by-round
- Round 1 (2026-07-24): 9/10 PASS. Only gap: worked example (1) was stale, the
  model-plan line showed model with no effort and no per-host mechanism,
  contradicting the edited step.
- Round 2 (2026-07-24): 10/10 PASS. worked example 1 -> 2 (the ONLY criterion
  that moved). The line now carries effort for both roles + `/model`/`/effort`,
  matching the process. All other criteria held at 2.

## Findings
None blocking. The form is clean and the only Round 1 finding is closed.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. First record. Change:
  model-plan step now surfaces model AND effort for both roles, offers to change
  both, states the per-host mechanism, records effort in `model_plan:`. Only the
  worked example lagged.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed
  to mirror the step (effort both roles + per-host mechanism). Gap closed.

Note: this remains a form review. The change is partly behavioral (whether the
agent actually surfaces and records effort per host at runtime); recommend an
`/improve` subagent test to confirm the behavior. The file form is now clean.
