---
artifact: skills/build/SKILL.md
type: skill
artifact_version: 1
date: 2026-07-24
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 2, safety_integration: 2 }
total: 9/10
verdict: PASS
---

Scope: form review of the branch `feature/model-policy-effort` change to the
"Model plan, asked before any work" step (SKILL.md lines 37-51). Round 1.

## Scores
- trigger clarity 2: `disable-model-invocation: true` + description opens "Build
  one or more ready user stories. Two modes you choose..." with an example
  invocation ("/build USR-001 USR-002 in parallel"). Correct explicit-command
  format (what-you-get + when), not a "Use when" auto-invoke.
- structure 2: Follows the body shape (essence, modes, process, worked example,
  safety rules), 221 lines (< 500), no supporting files so the one-level rule is
  not at risk. The changed step stays lean: one spoken template + one sentence on
  the per-host mechanism + one recording rule. No bloat added.
- worked example 1: Present and concrete elsewhere, but the model-plan line in
  the worked example (lines 191-193) is now STALE against the edited step. It
  shows "thinking/reviews on <session model...>, building on <builder tier...>"
  with no effort and no per-host mechanism, contradicting the new step that
  surfaces model AND effort and names `/effort`. A worked example that no longer
  matches the process it illustrates caps this at 1.
- precision 2: Exact throughout, tier + effort vocabulary ("strong tier",
  "`high` effort"), exact host mechanism (`/model`, `/effort`), exact record
  field (`model_plan:`). No placeholders in the changed step; the `<...>`
  angle-brackets are deliberate live-resolution slots, not TBDs.
- safety integration 2: References the guardrail rather than restating it, the
  step points at "the per-host adapter in AGENTS.md" and frames the sub-strong /
  sub-high flag as "a question, not a block, the choice is the user's", matching
  the human-in-command honesty rule. Consistent with AGENTS.md model policy
  (lines 49-70): speaks in tier + effort, versions never baked in.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
Max reachable this round: 9/10. Worked example is the only capped criterion and
it is fixable (not structural), so the ceiling once the example is refreshed is
10/10. Nothing here is structurally capped: this is an explicit command, so
trigger clarity is judged on the plain what-you-get format (achieved), and the
step genuinely touches a guardrail so safety integration can reach 2 (achieved).

## Findings (form gate, the focus asked)
- Within the standard: YES. The addition is concise, references AGENTS.md's
  per-host adapter instead of restating the model policy, and does not duplicate
  the tier map or the effort levels. No guardrail is weakened or copied.
- Host-neutral phrasing: UNAMBIGUOUS. "The change mechanism is per host (Claude
  Code: `/model` + `/effort`; other hosts use their equivalent from the per-host
  adapter in AGENTS.md), so the same step works everywhere" reads cleanly and
  matches AGENTS.md line 69 ("speaks abstractly (tier + effort) and points the
  user at the active host's mechanism"). Portability intent is explicit.
- No bloat: the step grew by roughly the minimum needed to carry effort + the
  host mechanism; it stays a single spoken template plus recording rule.
- One inconsistency (the only real finding): the worked example's model-plan
  line was not updated with the step. It must show effort and the host-neutral
  mechanism to stay imitable.

## Top fixes
1. Update the worked example (SKILL.md lines 191-193) to mirror the edited step:
   include effort for both roles and the per-host mechanism, e.g.
   "Model plan: thinking/reviews on <session model, resolved now> at effort
   <session effort>, building on <builder tier> at effort high. Continue, or
   change? (`/model` for model, `/effort` for effort)". This lifts worked
   example 1 -> 2 and the total to 10/10.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. First record for this
  skill. Change under review: model-plan step now surfaces model AND effort for
  both roles, offers to change both, states the per-host change mechanism, and
  records effort in `model_plan:`. Form is sound; only the worked example lags.

Note: this is a form review. The change is partly behavioral (whether the agent
actually surfaces and records effort per host at runtime); recommend an
`/improve` subagent test to confirm the behavior, the file form is otherwise clean.
