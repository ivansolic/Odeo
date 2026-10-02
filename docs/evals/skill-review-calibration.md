---
artifact: review-calibration
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: e52db70
artifact_version: 2
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger: 2, structure: 2, example: 2, precision: 1, safety: 2 }
total: 9/10
verdict: PASS
previous_total: 8/10
---

# Skill review: review-calibration (format doc + calibration fixtures), round 2

Scope reviewed at e52db70 (read only):
- docs/checklists/review-calibration.md, scenarios 3 and 4, the scenario format, How to run
- tests/fixtures/calibration/USR-014-export-csv.md, plan-usr-014-a.md, plan-usr-014-b.md
- docs/evals/calibration-plan-human-layer.md (results note), rechecked against the raw runs
  s3-r1..5, s4-r1..5, b53-r1..2, GRADING.md and grade_b53.py in the job scratch directory

This is a format doc plus fixtures, not a SKILL.md, so the rubric is applied as far as it
fits. The map duty does not apply because no command is added.

Model tier note: recorded as `strong`. The judge is an Opus-class model, but confirming the
strongest tier needs a live check of the current model lineup, and this reviewer has no web
access. Only the provable floor is claimed.

## Scores
- trigger clarity: 2. The opening states the purpose ("prove that our JUDGMENT-layer
  reviewers ... actually catch the defects they claim to") and when to use it ("Guards changes
  that cheapen the pipeline"). These lines are unchanged.
- structure: 2. Scenarios 3 and 4 carry every format field. The new optional field
  ("**known unplanted findings** (optional)") is defined in the format section before the
  scenarios use it. Fixtures are one level from the doc, and the doc is 130 lines.
- worked example: 2. The seeds are real, imitable plans with concrete values. The fixture
  bodies match round 1, apart from the file names.
- precision: 1. The grader rules are now exact:
  - Scenario 3: "'match the story, or keep `due_date` and name it in `What you decide`'
    passes ... FAIL ... when the only remedy is 'match the story'"; "Citing criterion 6 by
    number is not required."
  - Scenario 4 uses one scope in both places: "Summary, Why, Explanation or `What you decide`".
  Two places are still not exact:
  - How to run step 1 says "No grading rule, earlier output or this checklist may be within
    its reach". Step 2, for a reviewer changed on a branch, says "have a fresh agent follow
    the branch's agent file". It does not say where that file and the docs it cites
    (docs/plan-format.md) come from. Read in place from the branch worktree, they put this
    checklist, with every expected finding, within the agent's reach. That is exactly the
    exposure the results note now names under "Not blind". As written, step 1 cannot be
    followed in the case step 2 covers, and that case is the one this run used.
  - Scenario 3 says "(a format question, see the 2026-10-02 note)". A date is not a path; the
    note is docs/evals/calibration-plan-human-layer.md.
- safety integration: 2. "Run BLIND, per the blind scoring in `docs/eval-framework.md`"
  references the rule that a calibration run depends on. The review-loop reference ("fix the
  agent (or the rubric), then re-run, per the review loop") stays. No guardrail is restated.

## Total: 9/10
## Verdict
PASS (threshold 8/10, no criterion at 0).

## Ceiling
10/10 is reachable: fixing the two precision items above closes the gap. Nothing caps a
criterion structurally.

## Results note: claims vs evidence (rechecked)
- Scenario 3, "each remedy offered 'match the story, or keep it and name it in `What you
  decide`'": holds. Checked in s3-r1 I1, r2 I2, r3 I2, r4 I1 and r5 I2.
- Stop rule, "All 10 runs mention ...; 7 rank it Important ..., 3 as a note, and three
  scenario-4 runs called it a builder stop rule themselves": holds.
  - Important: the five s3 runs, plus s4-r1 I7(b) and s4-r5 I3.
  - Notes: s4-r2 N4, s4-r3 N6 and s4-r4 N2.
  - The three that call it a stop rule are s4-r2, r3 and r4.
- Formula count, 8/10 "counted by reading each finding": holds.
- B5.3 ordering "checked BY HAND": holds and is now labelled correctly. The line numbers are
  correct.
- The Risks conflict, "docs/plan-format.md:184 ... while :73": correct. Line 73 carries "every
  open question in Risks" and line 184 defines Risks as builder questions. The three options
  are framed as the human's decision, and the format text is unchanged. This is the right
  framing.
- The new "Not blind" limit is honest and scoped correctly: "No run output names or quotes
  them, but within reach is not blind." This matches the raw outputs.
- Residual 1: "a one-word paraphrase of one bullet in a copy of a run output made it report
  FAIL (4/5)". No paraphrased copy is kept in the scratch directory, so like the grading-rule
  ordering this claim rests on the session alone. The note labels the ordering self-attested
  but not this check. Keep the paraphrased copy, or label the check self-attested.
- Residual 2: `model: claude-opus-5-5[1m]` sits next to `scorer: the orchestrating session`,
  so it reads as the grader's model. The note does not say which model the 12 agents ran on.
  b53-r2 suggests the session model ("Opus 5.5 (per session environment)"). One line would
  settle it.
- `model_tier: strongest` in the note is the note author's claim. This reviewer cannot verify
  it live and records only `strong` for its own judgment.
- The blind re-run is open and stated as such ("a blind re-run would make these results
  stronger"). Doing it is Ivan's call, not a defect.

## Top fixes
1. How to run step 2: add "copy the branch's agent file and every doc it cites (for
   `architecture-reviewer`: agents/architecture-reviewer.md and docs/plan-format.md) into the
   scratch directory of step 1, and point the agent at those copies, never at the worktree".
2. Scenario 3: replace "see the 2026-10-02 note" with "see
   docs/evals/calibration-plan-human-layer.md".
3. Results note (optional, it does not affect this score): label the paraphrase check
   self-attested or keep the paraphrased copy, and state the model the 12 agents ran on.

## History
- Round 1 (a6cf42f): 8/10, PASS. Precision 1: the scenario 3 either/or remedy was undecided,
  there were two rule texts, scenario 4's scope did not match, the format line was stale and
  the fixture file names gave the answer away. Safety 1: blind scoring was not referenced. The
  results note undercounted the stop-rule finding (6/10, versus 10/10 mentioned and 7/10
  Important).
- Round 2 (e52db70): 9/10, PASS.
  - Precision stays at 1. All five round-1 precision items are fixed; what is left is the new
    step 1 against step 2 gap and the date-only cross-reference.
  - Safety goes from 1 to 2: blind scoring is now referenced in How to run.
  - The results note's counts, limits and framing now match the raw runs; two small
    provenance residuals remain.
