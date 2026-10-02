---
artifact: review-calibration
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: fe31c82
artifact_version: 3
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger: 2, structure: 2, example: 2, precision: 1, safety: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

# Skill review: review-calibration (format doc + calibration fixtures), round 3 (cap)

Scope reviewed at fe31c82 (read only):
- docs/checklists/review-calibration.md: scenario 3 and How to run, the two places changed
  since e52db70
- docs/evals/calibration-plan-human-layer.md: the Method paragraph and the `model:` line

The rest of the scope is unchanged since round 2, per the dispatcher. I re-read scenarios 3
and 4 and How to run in full. Agents/architecture-reviewer.md was read to check the "every doc
it cites" list.

Model tier note: recorded as `strong`. The judge is an Opus-class model, but naming the
strongest tier needs a live check of the current model lineup, and this reviewer has no web
access. Only the provable floor is claimed.

## Scores
- trigger clarity: 2. The purpose and when to use the doc are stated in the opening, which is
  unchanged.
- structure: 2. Every format field is present, the optional field is defined before it is
  used, and the fixtures are one level deep. The doc is 133 lines.
- worked example: 2. The seeds are concrete and imitable, and their bodies are unchanged.
- precision: 1. Both round-2 items are fixed. Scenario 3 now reads "see
  docs/evals/calibration-plan-human-layer.md". Step 2 now says to copy "the branch's agent
  file and every doc it cites ... point a fresh agent at those copies and never at the
  worktree". That closes the blindness gap. One item remains: the example that follows does
  not match the rule.
  - The step says: "(for `architecture-reviewer`: agents/architecture-reviewer.md and
    docs/plan-format.md)".
  - agents/architecture-reviewer.md also cites `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` twice:
    line 35 (Guardrails 1, the approval-scope check) and line 134 (Guardrails 7, the output
    language).
  - A runner who copies exactly the listed files gives the agent no AGENTS.md. The recorded
    runs did use it: s3-r2 and s3-r4, for example, cite "the approval-scope rule (AGENTS.md
    Guardrails 1)". A blind re-run that follows the example would therefore not match the
    conditions of the recorded runs.
  - Blindness is not affected, because AGENTS.md holds no answer key. The fix is three words
    in one list.
- safety integration: 2. Blind scoring is referenced ("Run BLIND, per the blind scoring in
  `docs/eval-framework.md`"), and step 2 now keeps the agent away from the worktree. The
  review-loop reference stays. No guardrail is restated.

## Total: 9/10
## Verdict
PASS (threshold 8/10, no criterion at 0).

## Ceiling
10/10 is reachable once AGENTS.md is added to the step 2 list. Nothing caps a criterion
structurally.

## Why the loop stops here, short of max
- This is round 3, the cap in docs/eval-framework.md.
- Separately, the residual is the SAME CLASS as round 2's precision finding: the blind-run
  copy instruction does not fully cover what the agent reads. Each fix so far has closed one
  instance of that class: first the location of the agent file, now one cited file the list
  leaves out.
- Closing the class structurally would mean saying "every doc the agent file cites, found by
  searching it for paths", and treating the parenthetical as an example rather than a list.
  That is the human's choice.

The residual, as it is: step 2's parenthetical omits AGENTS.md. The open decision is Ivan's:
- (a) Accept the residual at 9/10.
- (b) Add AGENTS.md to the list. A fix outside the loop does not certify itself, and any edit
  re-stales this record, so it would need its own regenerated record.
- (c) Reword the parenthetical as "for example", with the find-the-citations rule as the
  contract.

## Results note (the parts changed since round 2)
- "a one-word paraphrase ... made it report FAIL (4/5), so it can fail (self-attested: the
  paraphrased copy was not kept)". This is labelled honestly now.
- "model: claude-opus-5-5[1m] (the scorer, and the 12 agents, which inherited the session
  model)". The run model is now stated. b53-r2's "Opus 5.5 (per session environment)" is
  consistent with it. Inheritance itself cannot be proven from the outputs, and the line
  states it as a fact about dispatch, not as something measured. That is acceptable.
- The rest is unchanged from round 2, and all of it was verified there against the raw runs.

## Top fixes
1. How to run step 2: change the parenthetical to "(for `architecture-reviewer`:
   agents/architecture-reviewer.md, docs/plan-format.md and AGENTS.md)". Or, to close the
   class, write "every file the agent file names by path (search it for `.md`), for example
   ...".

## History
- Round 1 (a6cf42f): 8/10, PASS.
  - Precision 1: the scenario 3 either/or remedy was undecided, there were two rule texts,
    scenario 4's scope did not match, the format line was stale, and the fixture file names
    gave the answer away.
  - Safety 1: blind scoring was not referenced.
  - The results note undercounted the stop-rule finding.
- Round 2 (e52db70): 9/10, PASS.
  - Precision 1: step 1 conflicted with step 2 on agent-file location, and the cross-reference
    to the results note was a date, not a path.
  - Safety went from 1 to 2.
- Round 3 (fe31c82): 9/10, PASS.
  - Both round-2 items are fixed, and the results note's two provenance residuals are fixed.
  - Precision stays 1 on a same-class residual: AGENTS.md is missing from step 2's list.
  - The loop stops at the cap; the residual is handed to the human.
- Trajectory: 8 -> 9 -> 9.
