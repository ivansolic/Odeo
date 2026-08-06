---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: a2eec03
artifact_version: 7
date: 2026-08-06
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 6/10
---

Scope: re-review of the model-plan step after the round-1 fixes
(`skills/build/SKILL.md:37-82`, `:197-206`, `:236-256`), cross-checked against
`AGENTS.md:40-89`, `AGENTS.md:147-152`, `AGENTS.md:262-275`,
`agents/builder.md:15-24` and `:109-118`, `docs/plan-format.md:24-36`,
`docs/invariants.md:20`, and `bin/skills-lint.sh:90-107` (C11). Whole skill
re-scored for consistency.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` plus a description that
  opens "Build one or more ready user stories. Two modes you choose..." with an
  example invocation. Correct explicit-command format; untouched.
- structure **2** (was 1). The defect I named has been half-removed and the
  remainder is tightening, not a structural failure. The block is no longer one
  unbroken run: the resolution rule is now a 3-step ordered list of authority
  (`:43-46`), which is exactly the case the standard reserves structure for (a
  genuine decision point), and the never-invent rule sits in its own paragraph
  (`:48-53`). Body structure is fully followed, 274 lines < 500, no supporting
  files so the one-level rule is not at risk, and `/build` is an explicit command
  rather than a frequently auto-loaded skill, so the "tightest" pressure is lower.
  Two nits below (a missing `### Model plan` subheading; an 18-line closing
  paragraph still carrying six concerns) would tighten it further without moving
  the score.
- worked example **2** (was 1). `:242-248` now mirrors the step: the two-role
  question, the user answering in a tier word ("sonnet is fine", so C11 clean),
  and the choice visibly reaching the plan, "model_plan: judgment <session model>
  · builder_tier: sonnet (plan is precise, work mechanical)". Real values elsewhere
  intact (`docs/plans/2026-07-14-usr-012-timer.md`, `../dogfood-usr-012`, `12/12
  APPROVE`). Directly imitable. One nit: `builder_as_dispatched:` never appears.
- precision **1** (was 1, for a different and much smaller reason). The core
  fix is genuinely clean: `:48-51` now says "Do NOT try to enumerate which models
  this host offers: nothing in this system reports that, so any list would be
  invented", and the question template no longer contains a slot the agent cannot
  fill. But `:77-79` was left speaking the old language and now contradicts that
  paragraph: "If judgment would run below the STRONGEST model available on this
  host (resolve the current lineup live, never from a cached table)". To fire that
  flag and "name the stronger model", the agent must know what this host offers,
  which `:49` has just declared unreportable, and it may not use memory (`:48`) or
  a list (`:49`). So within the skill the only remaining path is invention, the
  failure the block exists to prevent. This is one clause and a two-line fix
  (finding 1). Second, smaller hole: the ASK at `:46` says "run `/model` and tell
  me what it reports", but the question it feeds asks for effort too (`:57` "at
  effort <as resolved>"), and `AGENTS.md:67-69` states runtime effort is "not
  reliably script-readable", so effort has no resolution path (finding 2).
  Everything else is exact: `/model`, `/effort`, `spec-gate.sh`, `builder_tier:`,
  `builder_as_dispatched:`, no TBDs, no version-pinned name.
- safety integration **2** (was 1). The serious half of the round-1 finding is
  closed, and closed better than asked. `AGENTS.md:52-59` now separates a
  rebuttable DEFAULT from a pin and says outright "What is ENFORCED is only the
  file's default value (lint C11); the run model is the human's call";
  `AGENTS.md:262-266` splits it as `[E]` on the file value and `[I]` on the per-run
  choice with "do not read 'pinned' into it"; `docs/invariants.md:20` says the same
  for C11. So the rule now exists in the authority file and the skill is no longer
  ahead of it. The posture is also stronger than version 5 was: the choice is
  recorded in the plan (`builder_tier:`, a tier word, present before the gate) so
  it is approved at gate 1 instead of living in a chat, and `builder_as_dispatched:`
  is deliberately named for what can be verified rather than claiming what
  executed (`docs/plan-format.md:30-36`), which is the never-fabricate rule applied
  honestly. `:204-205` adds the right refusal: "If the dispatch REJECTS the named
  model, stop and ask; never fall back silently and never record a model the
  dispatch did not accept." No gate is weakened (spec gate, plan gate,
  `boundary-check.sh`, merge gate all untouched).

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Answer to the open question about the C11 rationale (`:66-70`)
It no longer costs the point on its own, so cutting it is optional, not blocking.
My round-1 score of 1 rested on two things and named the second as the more
serious: the restatement, and AGENTS.md not carrying the rule. The second is now
fixed thoroughly, which is what was holding the criterion down. The restatement
remains a mild violation of `AGENTS.md:150-151` ("Skills and agents REFERENCE
these rules; they do not restate them"), because the reason and the incident now
live durably in `AGENTS.md:52-59`, `AGENTS.md:262-266` and
`docs/invariants.md:20`, three places that will be maintained. Two copies drift;
the pointer does not. So the recommendation stands as a nit (finding 4), with the
exact replacement text given, and the judgment is yours.

## Findings

1. **`skills/build/SKILL.md:77-79`, the one blocking fix (blocks 10/10, not the
   PASS).** The clause asks for the host's offering that `:49` just declared
   unreportable. Replace with a check the agent can actually run:
   > If judgment would run below the STRONGEST model in the current official
   >   lineup (resolved live per AGENTS.md, never from a cached table; that tells
   >   you what EXISTS, not what this account has) OR below `high` effort, say so
   >   in the same breath, name the stronger model and how to switch (`/model`),
   >   and for architecture-critical work (plans, security, reviews) recommend
   >   switching up first (question, not a block). If the user says that model is
   >   not on their plan, drop the point, do not press.
   That keeps the guardrail, removes the contradiction, and closes the last path
   where an agent could name a model it invented.

2. **`skills/build/SKILL.md:46`, effort has no resolution path (non-blocking).**
   Extend the ASK to cover what the question asks for: "run `/model` and `/effort`
   and tell me what they report." Optionally add one clause acknowledging
   `AGENTS.md:67-69`: session effort is not machine-readable, so if the user does
   not check, say the judgment effort was not resolved rather than stating a level.

3. **`skills/build/SKILL.md:58` and `:76-77`, mark the build line for-me only
   (non-blocking).** The caveat "In with-me mode there IS no builder agent and no
   dispatch, so do not offer a build model there" arrives 18 lines after the
   template that offers it. Put the scope on the line itself: "Build (executes the
   plan, for-me mode only): the same model, or a different one?"

4. **`skills/build/SKILL.md:66-70`, reference instead of restating (nit, your
   call).** If you cut it: "The user's build choice is passed AT DISPATCH, per
   run, and is never written into `agents/builder.md` or any other file (AGENTS.md
   model policy, lint C11: a version baked into a file goes stale)."

5. **`skills/build/SKILL.md:247-253`, one token in the example (nit).** The
   example's `model_plan:` shows judgment + `builder_tier:` but never
   `builder_as_dispatched:`, which `:200-201` requires the orchestrator to write
   after dispatch. Add it on the dispatch line, e.g. "(dispatched; recorded
   model_plan.builder_as_dispatched)", so the full contract shape is imitable.

6. **`skills/build/SKILL.md:65-82`, split the closing paragraph (nit).** It
   carries six concerns in one run: dispatch-not-file, the C11 why, the per-host
   mechanism, the `model_plan:` write rule, with-me has no builder, and the
   strongest-available flag. Three short paragraphs (the dispatch rule / what gets
   written where / the switch-up flag) plus a `### Model plan` subheading over
   `:37` would make the 46-line block scannable and stop it reading as an appendix
   to a step titled "Pick the mode".

## House style
No em or en dashes in the new text; English only. The middle dot at `:248`
matches existing house usage (`AGENTS.md:121`). No version-pinned model name
anywhere (C11 grep pattern `(opus|sonnet|haiku|fable)[- ][0-9]` clean: `sonnet`
appears only as a tier word). No time-sensitive external fact asserted.

## Consistency verdict
CORRECT and internally consistent except for finding 1.
- `AGENTS.md`: aligned in both directions now. The skill's per-run choice is
  written in the authority file (`:52-59`, `:262-266`) with the `[E]`/`[I]` split,
  and `docs/invariants.md:20` matches, so `AGENTS.md:152` ("a rule that is not
  written here does not exist") is satisfied.
- `agents/builder.md:109-118`: consistent and correctly scoped. "you were
  dispatched with a model and you never change it", "running above your declared
  tier is legitimate and is NOT a deviation to report", and "you neither write nor
  verify that line" line up with `SKILL.md:200-203` and with
  `docs/plan-format.md:30-36`. WHEN to raise it is delegated to AGENTS.md rather
  than re-argued, which is the right direction of reference.
- `docs/plan-format.md:24-36`: consistent, and it sanctions the post-approval
  write of `builder_as_dispatched:` explicitly, so `SKILL.md:200-201` is not a
  gate-1 violation of "a plan approval covers only the plan as approved"
  (`AGENTS.md:176-181`): the approved intent is `builder_tier:`, present before the
  gate; the added line is disclosure, not a contract clause.
- Internal: only finding 1. `:48-51` and `:77-79` disagree about whether the
  host's offering is knowable.

## Ceiling
Max reachable: 10/10, and it is one two-line edit away (finding 1, with finding 2
as the tidy-up). Nothing is structurally capped. The example's model slots must
stay in `<...>` form rather than naming a model, because a named version would
trip lint C11, so "real values" there means real SHAPE; that does not cap the
criterion and it scores 2.

## Round-by-round (this branch)
- Round 1 (2026-08-06, commit 5b46abd): 6/10 FAIL. Four blocking findings:
  unobtainable model enumeration, a self-assessed ASK trigger, an example still
  speaking the pre-change single-role phrasing, and AGENTS.md still calling the
  builder's tier pinned.
- Round 2 (2026-08-06, commit a2eec03): 9/10 PASS. All four closed. Structure
  1 -> 2, worked example 1 -> 2, safety integration 1 -> 2, precision held at 1 for
  a narrower residual (`:77-79` contradicts `:48-51`). Trajectory 6/10 -> 9/10.
  One actionable fix remains, so per the AGENTS.md review-loop rule the loop
  should run once more rather than stop here: apply finding 1 (and 2), then
  re-dispatch this reviewer for a fresh record at the new commit.

## Vs previous version
Version 6 (commit 5b46abd) introduced the build-model choice with four form
defects. Version 7 fixes all four. The model resolution is now followable in the
common case: a stated order of authority where the latest `/model` output in the
session overrides the session-start value, the session-start value is a demoted
fallback rather than a trusted source, and ASK is the terminal step, with
enumeration explicitly forbidden and the reason given. The choice also stopped
living only in conversation: `builder_tier:` carries the approved intent through
the gate and `builder_as_dispatched:` discloses what was passed without claiming
what executed. Against version 5's 10/10, the only thing standing between this
file and the same score is one leftover clause.

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
  removed; no gate touched.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Model-plan step resolves
  the strongest model available live and recommends a switch-up for
  architecture-critical work. Nits recorded: rule stated twice; example showed
  only the happy path.
- Round 6 (2026-08-06, Opus 5, strongest, commit 5b46abd): 6/10 FAIL. The build
  model became the user's choice; four blocking form defects (see Round 1 above).
- Round 7 (2026-08-06, Opus 5, strongest, commit a2eec03): 9/10 PASS. All four
  blocking findings closed; AGENTS.md, `docs/invariants.md`, `docs/plan-format.md`
  and `agents/builder.md` now carry the rule coherently with an `[E]`/`[I]` split.
  What changed in this record versus version 6: structure 2, worked example 2,
  safety integration 2, precision held at 1, verdict FAIL -> PASS. Residual: one
  clause (`:77-79`) still asks for the host's model list that the same block
  declares unreportable.

Note: this is a form review. The behavioral question stays open by construction,
whether an agent at runtime actually walks the order of authority and ASKS rather
than trusting the session-start value it can see in its own context. That is what
an `/improve` subagent test measures; the form now supports the right behavior,
and finding 1 is the last place in the file that still invites the wrong one.
