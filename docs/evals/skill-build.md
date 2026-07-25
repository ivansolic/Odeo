---
artifact: skills/build/SKILL.md
type: skill
artifact_version: 3
date: 2026-07-25
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: form review of the foreground-default guardrail additions, prompted by a
real incident (a LONE builder dispatched in the BACKGROUND could not answer
permission prompts, was denied Read/Bash/Write, and began improvising
bash-heredoc workarounds). Two additions: a B3 dial bullet (lines 124-135) and a
Safety-rules bullet (line 232). Whole skill re-scored for consistency.

## Skill: build  (explicit command)

## Scores
- trigger clarity 2: `disable-model-invocation: true` + description opens "Build
  one or more ready user stories. Two modes you choose..." with an example
  invocation. Correct explicit-command format, untouched by this change.
- structure 2: Still follows the body shape and is lean (234 lines < 500), no
  supporting files so the one-level rule is not at risk. The new guardrail lands
  in the two right places: the decision-point (B3 dials) AND the terse Safety
  list, which is the intended layering. The B3 bullet is dense (12 lines) but
  within the file's established style; not a wall of text.
- worked example 2: Lines 199-217 remain concrete with real values
  (`docs/plans/2026-07-14-usr-012-timer.md`, `../dogfood-usr-012`, `12/12
  APPROVE`). The example is a single foreground build, so it is consistent with
  the new default; nothing to change.
- precision 2: Exact throughout. The new bullet names the exact mechanism
  ("Write/Bash actions prompt the user"), the exact ceiling ("keep to 2-4"), and
  the exact net ("worktree isolation + boundary-check + code-review + explicit
  per-story merge"). No TBDs or vague steps.
- safety integration 2: The rule strengthens, does not weaken or contradict, the
  existing guardrails. It is consistent with "Default is one story at a time
  (sequential)" (B3), "parallel = background agents" (B5 step 4, now EXPLAINED
  rather than merely asserted), "keep parallel builders to 2-4" (line 230), and
  "start with with-me or a single builder" (line 233). It does not contradict the
  mechanism fact on line 234 ("Uses built-in agents ... background"): line 234
  states a capability, line 232 states the policy governing its use.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Consistency verdict (the gating question)
CORRECT and internally consistent. The core logic holds: a lone builder
foreground is supervised (answerable prompts, interruptible); backgrounding a
lone builder is all downside with zero concurrency gain; parallel REQUIRES
background, which requires pre-arranged (broader) permissions, hence LESS
supervised by construction. No contradiction found against B3, B5, or the Safety
list. CLEAR and actionable: no ambiguity on when background is allowed (parallel
only, explicit opt-in) versus forbidden (any lone builder).

## Ceiling
Max reachable: 10/10, achieved. Nothing is structurally capped: explicit command
(trigger clarity judged on plain what-you-get, achieved) and the change genuinely
touches a guardrail (safety integration reaches 2). Full marks stand because the
one non-blocking nit below does not cross any rubric level boundary.

## Non-blocking nits (would tighten, do not lower any score)
1. Reasoning duplicated across the two bullets. B3 (124-135) and Safety (232) both
   spell out "parallel-only, opt-in, needs pre-arranged permissions, so LESS
   supervised." The standard says reference a guardrail, do not restate it. The
   Safety bullet ideally points at the B3 rationale rather than re-arguing it.
   Suggested Safety line: "Never background a LONE builder (no concurrency to gain,
   all the downside); background is the parallel-only, higher-trust opt-in in B3.
   Default = single builder, foreground." This keeps the rule, drops the second
   copy of the argument.
2. One strained clause in B3: "the SAME exposure that makes backgrounding a lone
   builder wrong, just accepted deliberately for concurrency" packs the whole
   argument into a sub-clause and then overlaps the very next sentence ("NEVER
   background a LONE builder..."). Consider cutting that clause; the following
   sentence already carries it.
3. Emphatic caps (LONE, ONLY, SAME, LESS, NEVER) are heavier than the standard's
   "never shouting" note, but match this file's existing register (ENFORCED,
   ALWAYS, STOP). Consistent with the skill, so not a defect here; worth a
   file-wide pass someday.

No em/en dashes present in the additions; English only. Confirmed.

## Map duty
No command surface added or altered (a policy dial on the existing `/build`), so
no `docs/system-map.md` delta is required. Not a finding.

## Round-by-round
- Round 1 (2026-07-25): 10/10 PASS. All five criteria held at 2; the guardrail is
  correct, consistent, and clearly placed. No criterion moved from the version-2
  baseline, and none was at risk.

## Vs previous version
Version 2 (2026-07-24) scored 10/10 on the model-plan/effort change. Version 3
adds the foreground-default guardrail. Score holds at 10/10; no regression on any
criterion. The additions raise real-world safety without harming form.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed
  to mirror the step. Gap closed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules. Correct and internally consistent with
  Mode B, B3 dials, B5, and the 2-4 / single-builder rules; no contradiction with
  the "background" mechanism note on line 234. Three non-blocking nits (reasoning
  duplicated across the two bullets, one strained clause, caps register); none
  crosses a rubric boundary, so 10/10 stands.

Note: this is a form review. The guardrail is partly behavioral (whether the
agent actually refuses to background a lone builder and pre-arranges permissions
before parallel at runtime); recommend an `/improve` subagent test to confirm the
behavior. The file form is clean and ships.
