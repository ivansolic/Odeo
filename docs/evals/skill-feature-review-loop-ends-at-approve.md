---
artifact: skills/build/SKILL.md skills/prd/SKILL.md skills/stories/SKILL.md
type: skill
branch: feature/review-loop-ends-at-approve
reviewed_commit: 0fabcd5
artifact_version: 2
date: 2026-10-23
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores_build: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
scores_prd: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 2, safety_integration: 2 }
scores_stories: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: build 10/10, prd 9/10, stories 10/10
verdict: PASS
previous_total: build 10/10, prd 7/10, stories 8/10 (round 1 of this record, ccdd70e)
---

Scope: round 2. I read the three skills changed on `feature/review-loop-ends-at-approve`
in full at `0fabcd5`. The dispatcher handed me that sha; I hold no shell and did not resolve
it. I checked them against `docs/eval-framework.md` :175-258 (stop rule, now with the spec
exception at :189-191), `AGENTS.md` :300-305 (Guardrails 3), `agents/pm-reviewer.md` :35 and
:65 (PASS | FAIL vocabulary), and `scripts/spec-gate.sh` :1-19 (stated intent). I also confirmed
that `docs/eval-framework.md` is on `docs/public-paths.txt`, so the skills' `${CLAUDE_PLUGIN_ROOT}`
reference resolves for marketplace installs. Branch verdict: PASS. All three skills clear the
threshold and none has a criterion at 0. `effort: high` is the value declared in
`agents/skill-reviewer.md`, not an observed runtime value. I did not resolve
`model_tier: strongest` live because I have no web tool; Opus is the top class on the tier map.

## Skill: build  (explicit command)
## Scores
- trigger clarity: 2. `disable-model-invocation: true` (`:3`). The plain what-you-get description spells out the parallel invocation (`:2`). Unchanged.
- structure: 2. 340 lines, under 500, no supporting files, follows the body shape. Unchanged.
- worked example: 2. `:294-322` is a concrete for-me run that ends at the merge offer. Unchanged.
- precision: 2. Round 1's Low is fixed. `:253-255` now reads "the eval record is where provenance about the run belongs; code-reviewer regenerates it". The actor is named, and "it" can only mean the record.
- safety integration: 2. Spec gate `:12-16`, Guardrail 3 + C11 `:88`, Guardrails 1 `:239-242`, Guardrails 7 `:214`, `:231`, `:262`, merge non-permissions `:283-290`. The code-loop stop clause `:267-272` matches `docs/eval-framework.md`.
## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)
## Ceiling: 10/10, reached.

## Skill: prd  (explicit command)
## Scores
- trigger clarity: 2. "Write a problem-first Product Requirements Document ... Use once an idea has shape ... Produces a structured PRD saved to docs/prds/." (`:2`), with `disable-model-invocation: true`. Unchanged.
- structure: 2. 66 lines, essence `:8-10`, when to use (and when not: "Skip for a typo or a one-line fix.") `:12-14`, process `:16-32`, output `:34-42`, gate `:44-50`, rules `:52-66`. `rubric.md` is one level deep.
- worked example: 1. Unchanged and not caused by this branch. The only example is the fragment "users who forgot their password regain access in <60s without support" (`:19`). There is no filled PRD section to imitate. It is not blocking: no criterion is at 0 and the total clears 8.
- precision: 2, `:46-50`. "FAIL = fix the named gaps and re-dispatch pm-reviewer to verify ... a PASS ends the loop" now uses pm-reviewer's own verdict words (`agents/pm-reviewer.md:35`, `:65`). "it costs one more pm-reviewer round, which counts toward the round cap" says how the extra dispatch is counted, which round 1 found missing.
- safety integration: 2. The gate now points at the source instead of copying it: "under the stop condition in `${CLAUDE_PLUGIN_ROOT}/docs/eval-framework.md`" (`:47`). The "(max 3 cycles)" partial copy is gone. The comment rule agrees with `docs/eval-framework.md:189-191` ("PRDs and stories are the exception ... one more pm-reviewer round, counted toward the three-round cap") and with `AGENTS.md:304-305` ("PRD and story comments cost one re-review"). Other references still in place: the security pre-mortem `:28-31` and `:56`, and Guardrails 7 `:62`.
## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)
## Ceiling: 10/10. Only worked example falls short. Top fix 1 lifts it.

## Skill: stories  (explicit command)
## Scores
- trigger clarity: 2, unchanged (`:2-3`).
- structure: 2. 97 lines, follows the body shape. `rubric.md` and `coverage-check.sh` are referenced, not inlined.
- worked example: 2. USR-021 `:44-59`, unchanged.
- precision: 2, `:76-81`. Same wording as prd: PASS/FAIL vocabulary, and the extra round "counts toward the round cap".
- safety integration: 2, `:77-80`. Points at the stop condition in `docs/eval-framework.md` and agrees with `:189-191` there and with `AGENTS.md:304-305`. The "max 3 cycles" copy is gone.
## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)
## Ceiling: 10/10, reached.

## Top fixes
1. prd, not blocking, deferred to Phase 3 by the human: add a worked example to `skills/prd/SKILL.md` before `## Output`. Use one short PRD excerpt with real values, carrying the password-reset outcome on `:19` through Problem, Outcome and metric, Scope in/out with one non-goal, and one Risk line with its pre-mortem answer. This moves worked example to 2 and the prd total to 10/10.
2. Low, prd `:48` and stories `:78`: "Its remaining comments" could refer to the PASS or to pm-reviewer. Optionally write "pm-reviewer's remaining comments". No score depends on this.

## Residuals outside skill scope (for the human and code-reviewer, not scored here)
- The commit-order path from round 1 is still open in the mechanism. `spec-gate.sh` compares the record's last commit time with the document's last commit time. `docs/eval-framework.md:255-258` keeps the record uncommitted until the loop ends. So if someone commits an edited spec and then the old, uncommitted record, spec-gate passes without a re-review. Under option (A) the skills and both sources now FORBID that path in their instructions, so the rule is [I] and not [E] for this case. Closing it is `scripts/spec-gate.sh`, which is code-reviewer's scope.
- The prd gate says "spec-gate then needs a fresh review". `/odeo:build` step 1 passes only story paths to `spec-gate.sh` (`skills/build/SKILL.md:12`), so a PRD is gated only when someone passes it explicitly. The skill instruction is correct as policy, and this predates the branch.

## Integrity
These are first-party skills. I found no sign of text copied from another project.

## Map duty
Satisfied. No command was added or renamed.

## Behavioral confirmation still owed
These scores cover form only. An `/odeo:improve` subagent test should still check this: a session that gets a PASS with comments in round 3 reports the comments and does not dispatch a fourth round, and a session that gets a PASS in round 1 or 2 and applies a comment does re-dispatch pm-reviewer.

## Vs previous version
- build: 10/10 -> 10/10. No regression. The Low wording fix landed.
- prd: 7/10 -> 9/10. Precision 1 -> 2 and safety integration 1 -> 2, decided by the rewritten gate `:46-50` and the source edits at `docs/eval-framework.md:189-191` and `AGENTS.md:304-305`. Worked example is still 1, as before the branch.
- stories: 8/10 -> 10/10. Back to the `skill-stories.md` level (10/10, 2026-07-21), so the round 1 regression is gone.

## History
- Round 1 (2026-10-23, claude-opus-5-5, strongest, ccdd70e, feature/review-loop-ends-at-approve): build 10/10 PASS, prd 7/10 FAIL, stories 8/10 PASS. Branch verdict FAIL. Findings: the skills and the sources disagreed about whether spec comments are re-reviewed, the skills used verdict words pm-reviewer never emits, "max 3 cycles" was a partial copy of the stop condition, and the build gate had an unclear antecedent.
- Round 2 (2026-10-23, claude-opus-5-5, strongest, 0fabcd5, feature/review-loop-ends-at-approve): build 10/10 PASS, prd 9/10 PASS, stories 10/10 PASS. Branch verdict PASS. The human chose option (A), the sources now carve out PRDs and stories, and both skill gates reference the stop condition in pm-reviewer's vocabulary. The prd worked example is still thin; it predates the branch and is not blocking.
