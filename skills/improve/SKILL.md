---
description: Use when a skill, rubric, or knowledge entry keeps underperforming (repeated eval drops on the same criterion) and you want to improve THE SYSTEM ITSELF with evidence, propose a change, test old vs new, keep or revert. You approve every applied change. Recurring loop, triggered by a nudge or by you.
disable-model-invocation: true
---

# Improve (evidence-based system improvement)

Changes a skill, rubric, or knowledge entry only when a test proves the new
version is better. Propose -> measure -> present evidence -> the human decides
keep or revert -> commit. The system may only get better, never silently worse.

## When this runs
- You invoke it ("improve the /prd skill, it feels too generic"), OR
- A nudge fires on a signal: `docs/evals/` shows ~3-5 repeated drops on the same
  criterion ("PRDs keep failing 'outcome'"), and you say yes.
- Analysis can run in the background while you work (read-only); APPLYING a
  change always waits for your gate, at a calm moment, never mid-build.

## Process
1. **Identify the artifact + the signal**: which skill/rubric/knowledge entry,
   and what evidence says it underperforms (quote the eval records).
2. **Propose ONE change**, minimal and targeted at the failing criterion. Run the
   `skill-reviewer` form gate on the changed file (must still pass the authoring
   standard).
3. **Measure, old vs new (the A/B test):**
   - Fix a test scenario (a realistic task the skill handles).
   - Fresh subagents run the scenario with the OLD version, fresh subagents with
     the NEW version. Fresh = clean context each, no memory of other runs.
   - The right domain reviewer scores ALL outputs BLIND with the same rubric
     (pm-reviewer for documents, code-reviewer for code).
   - Repetitions: 1-2 per variant for content skills; **5+ per variant for
     discipline-critical skills** (guardrails, TDD, merge, privacy), model output
     varies run to run, repetition separates signal from luck. For discipline
     rules use PRESSURE scenarios (deadline, temptation) and record the exact
     rationalizations agents use, counters go into the rule text.
4. **Present the evidence**: old avg vs new avg per criterion, what improved,
   what regressed, the diff of the change.
5. **The human decides**: KEEP (commit, versioned in git) or REVERT (discard,
   the old version stands). No evidence of improvement = recommend revert.
6. **Offer the loop-closers**: if the kept change is universal, offer
   `/contribute-lesson` (rubric/eval learnings are contributable); update the
   eval baseline.

## Worked example
Signal: last 5 PRDs scored 1/2 on "measurable outcome".
Change: add to /prd, "do not proceed until the outcome is a metric + target".
Test: "write a PRD for password reset", 2 subagents on old, 2 on new;
pm-reviewer scores all four blind. Old avg 7/10 (outcome 1/2), new avg 9/10
(outcome 2/2), nothing else dropped. Presented; you keep; committed.

## Calibrate mode (measure a reviewer, do not change it)
The sibling of the A/B loop above: instead of comparing two versions of a skill,
it MEASURES whether a reviewer still catches what it claims to. It never edits the
reviewer, it reports a catch rate. It is how you prove a gate still holds after a
change that cheapened mechanics (per-task Scrutiny, the review budget).
- **Invoke** by name, e.g. "calibrate the code-reviewer". Human-invoked.
- **Run** the planted-defect scenarios in `${CLAUDE_PLUGIN_ROOT}/docs/checklists/review-calibration.md`
  whose `reviewer:` matches the target. For each, dispatch that reviewer on the
  seed (it reviews the seed as it would any artifact), 5 reps (calibration is
  discipline-critical; lower it only for a quick smoke check, never for a gate
  decision). State the run count (scenarios x reps) upfront, these are live
  reviewer runs and cost model calls.
- **Score** per scenario: did the reviewer flag the planted defect at or above the
  scenario's expected severity? Report the catch rate (n of N). A Critical-expected
  scenario missed in ANY rep is a flagged gap; an Important-expected one is flagged
  if missed in the majority. Never fabricate a run; if the reviewer cannot be
  dispatched, say so and stop.
- **On a gap**, surface it and offer the A/B loop above to propose a check that
  closes it (the absorption loop for a recurring miss or a vendor-unique class),
  tested and human-gated like any other change. Calibrate finds the gap; the A/B
  loop, with your keep, fixes it.

Worked example: "calibrate the code-reviewer" runs the assert-nothing and IDOR
seeds x5. IDOR caught 5/5 at Critical; the assert-nothing test caught 4/5 at
Important. Reported; the 1/5 miss is noted and you are offered the A/B loop to
strengthen the testing-dimension prompt. The reviewer itself is left unchanged.

## Scope
- LOCAL: this project's knowledge, rubrics, local skill copies, applies after
  your keep.
- SHIPPED skills/rubrics (affect all users): the kept change becomes a proposal
  (PR + curation), never a silent update to what others run.

## Rules for yourself
- One change at a time; a bundle of edits can't be attributed to evidence.
- Never apply without the human's keep. Never fabricate scores.
- If the test is inconclusive, say so; inconclusive = revert by default.
