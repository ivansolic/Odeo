---
artifact: review-calibration
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: e1e28d2
artifact_version: 4
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

# Skill review: review-calibration, human-approved confirmation pass (after the round-3 cap)

Scope, read only, at e1e28d2 (rebased onto main 168ba9a):
- docs/checklists/review-calibration.md: scenarios 3 and 4, and How to run step 2 (the 1c change)
- docs/plan-format.md: the narrowed `What you decide` class (lines 72 to 78), checked against
  the Risks template (line 186) and against rubric criteria 5 and 6 (lines 293 to 301)
- docs/evals/calibration-plan-human-layer.md: the rewritten note. Its run-2 counts were
  checked against the raw blind outputs: `/tmp/odeo-blind.MjJyOW/{r-a1..5,r-b1..5}/review.md`,
  `g1/gate.md` and `g2/gate.md`, the grading rules in `grading-blind.md`, the grader
  `grade_blind_b53.py`, and the mutated copies in `gradecheck/`.

The scored artifact is review-calibration. Plan-format consistency is reported in its own
section below. It is not scored here, because docs/plan-format.md has its own record
(docs/evals/skill-plan-format.md), and that record is on `feature/plan-human-layer`, not on
this branch.

Model tier note: recorded as `strong`. Confirming the strongest tier needs a live check of the
current model lineup, and this reviewer has no web access to do one.

## Scores
- trigger clarity: 2. The opening is unchanged: it states the purpose and when to run.
- structure: 2. Every format field is present, and the fixtures are one level deep. The doc
  is 138 lines.
- worked example: 2. The seeds are concrete and their bodies are unchanged.
- precision: 1. Step 2 is now exact. It says to copy "the branch's agent file AND EVERY FILE IT
  NAMES BY PATH (a `${CLAUDE_PLUGIN_ROOT}/...` reference included)", and to "Derive the set
  from the agent file each time". The listed files are marked as an example. This closes the
  class from rounds 2 and 3. Two new imprecisions came in with the narrowing:
  - Scenario 3 adds a field, "not a finding (recorded, not graded)", that the Scenario format
    section does not define. That section defines only "known unplanted findings (optional)".
    Scenario 4 also does not give it its own field: it folds the same item into its "known
    unplanted findings" line ("the Risks stop rule is 'not a finding' here too"). The two
    scenarios record one measure two ways, under a field the format does not define.
  - The recorded measure has two texts. The checklist says "A reviewer that asks for it
    there [in `What you decide`] ... count it". grading-blind.md, which the runs were graded
    by, says "asks for the Risks stop rule ... to appear in `What you decide` or the
    Summary". A request to put it in the Summary but outside `What you decide` counts under
    one text and not under the other. Round 1 already found two texts for one rule, and the
    fix there was the same: the checklist carries the one text.
- safety integration: 2. "Run BLIND, per the blind scoring in `docs/eval-framework.md`", and
  step 2 now keeps the agent off the worktree for every cited file. No guardrail is restated.

## Total: 9/10
## Verdict
PASS (threshold 8/10, no criterion at 0).

## Ceiling
10/10 is reachable. Nothing caps a criterion structurally.

## Results note, run 2 (blind): claims vs evidence
Verified:
- Scenario 3 is "5/5 PASS (4 Important, 1 Blocking; every remedy names `What you decide`)":
  r-a1 I1, r-a2 I1, r-a3 I1 and r-a4 I1 are Important, and r-a5 B1 is Blocking. Every one
  offers "use `due date`, or keep `due_date` and add it to `What you decide`".
- Scenario 4 is "5/5 PASS (one run named it, as a strength)": no b run asks for the
  pure-function decision in the human layer. r-b1 Strengths says "The serializer is a pure
  function, so the riskiest logic is unit-tested without a server".
- Risks stop rule requested 0/10: no run asks for it in `What you decide` or the Summary. Holds.
- B5.3 is 2/2: in g1 and g2 all five bullets are verbatim, and "File map" comes after the
  Summary (g1 line 16, g2 line 16). Holds.
- The copy sets match the stated lists: the reviewer dirs hold AGENTS.md and
  docs/plan-format.md, and the build dirs add eval-framework.md and four scripts. A search
  of every copied file except plan, story and outputs for `due_date`, `USR-014`, `calibration`
  and the seed names finds nothing. Holds.

Not supported, or incomplete:
- "three runs said in so many words that it is a builder stop rule, correctly kept out".
  It is five:
  - r-a3: "The stop rule in Risks is correctly kept out of it"
  - r-a4: "a builder stop rule, correctly kept out of `What you decide`"
  - r-b2: "the Risks stop rule is correctly kept out of it"
  - r-b4: "a builder stop rule, correctly kept out of `What you decide`, and is not a finding"
  - r-b5: "a builder stop rule ..., which correctly stays out of `What you decide`"
  The undercount is conservative, but it is still not the count.
- "a file map moved above the Summary". The mutated copy, gradecheck/g2/gate.md, does not
  move the file map. It prepends one line, "File map first.", and leaves the map in place
  (now line 17). The grader takes the FIRST "file map" string anywhere in the output
  (`out.lower().find("file map")`), so the mutation proves the string check reacts to that
  string. This has two consequences the note does not state:
  - A gate text that says "see the file map below" above the Summary would FAIL a correct
    presentation.
  - A file map rendered under a different label (for example "Files touched:") FAILS on
    `fm >= 0`.
  The check is a string heuristic and should be named as one (Guardrails 6). The paraphrase
  mutation (gradecheck/g1, "one button" changed to "a button") is as described.
- The run-2 section leaves out three limits that still apply. They appear only under run 1,
  which is labelled "superseded":
  - The global CLAUDE.md contamination still applies. The runs were in the same session.
    Blinding the directory does not remove instructions the session itself carries.
  - The runs did not use the dispatched agent: they were fresh agents given copied
    instructions. The checklist's own step 2 requires the run to "record that it was not the
    dispatched agent".
  - The with-me test was still not run.
- "The narrowing removed the false request entirely ..., which is the evidence for keeping
  it." Run 2 changed two things at once: the format (ff6ee09) and the blind setup. The drop
  from 7/10 to 0/10 is consistent with the narrowing, which addresses that exact class. Still,
  this run does not isolate it, and the sentence should say so. It is also 10 runs.
- Run 1 history still ends "A format decision, recorded here, not changed", and cites
  ":184", which is now :186. As history this is acceptable. Adding one line, "since decided:
  ff6ee09 narrowed :73", would stop a reader taking it as current.

## docs/plan-format.md: the narrowed class (not scored here)
- Consistent with the rubric. Criterion 6 says "leaving a gate decision or story deviation
  only in the technical layer", and a builder stop rule is not a gate decision. Criterion 5
  says "risks and open questions listed for the builder to ask, not guess", which still fits
  stop rules living in Risks. agents/architecture-reviewer.md lines 29 to 34 echo the same
  class. agents/architect.md and skills/build/SKILL.md carry no copy of the class, so no echo
  is stale.
- One tension. Line 73 now names "every open question in Risks that the HUMAN answers", but
  the Risks template at line 186 still defines the section as only "anything ambiguous the
  builder must ASK about rather than decide alone". By the template, Risks holds no human
  questions, so the subclass in line 73 has no stated home. An architect following line 186
  would never write one. Suggested template: "<builder stop rules: anything ambiguous the
  builder must ASK about rather than decide alone ("if X, stop and ask"); and open questions
  the human answers at the gate, each also named under `What you decide`>".
- Coverage. The only skill-reviewer record for plan-format.md is on another branch. Nothing
  on this branch scores the file that changed. Whether this record should cover it, or
  skill-plan-format.md should be regenerated on this branch, is for the human to decide.

## Top fixes
1. Scenario format: define the field, for example "**not a finding (recorded, not graded)**
   (optional): something a reviewer might raise that the format says is NOT a finding;
   count how often it is raised". In scenario 4, move the stop-rule sentence out of "known
   unplanted findings" into that field.
2. Give the recorded measure one text, in the checklist: "counted when any finding asks for
   it in the Summary or `What you decide`". This matches grading-blind.md.
3. Results note (regenerate it, do not patch it by hand):
   - Change "three runs" to five, naming r-a3, r-a4, r-b2, r-b4 and r-b5.
   - Describe the ordering mutation as it was, and name the grader's ordering check as a
     heuristic (first "file map" string).
   - Restate under run 2 the limits still in force: the global CLAUDE.md, the agent was not
     the dispatched one, and the with-me test was not run.
   - Say that run 2 changed the format and the blinding together.
4. docs/plan-format.md line 186: admit the human-answered subclass, as worded above. Decide
   which record covers plan-format.md on this branch.

## History
- Round 1 (a6cf42f): 8/10, PASS.
- Round 2 (e52db70): 9/10, PASS.
- Round 3 (fe31c82): 9/10, PASS. This was the cap. The loop stopped on a same-class residual:
  the blind-run copy list left out AGENTS.md.
- Human-approved confirmation pass (e1e28d2), outside the capped loop. Ivan chose option
  1c, plus the format narrowing and a blind re-run. Result 9/10, PASS.
  - The round-3 residual is closed: the copy set is now derived from the agent file.
  - Precision stays at 1 on two new items introduced with the narrowing: the "not a
    finding" field is undefined and used inconsistently, and the recorded measure has two
    texts.
  - The run-2 counts hold, except "three runs", which is five. The note leaves out
    still-applicable limits and describes the ordering mutation inaccurately.
  - One plan-format tension (line 73 against line 186) is reported but not scored here.
- Trajectory: 8 -> 9 -> 9 -> 9.
