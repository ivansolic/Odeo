---
covers: USR-029 USR-030 USR-031 USR-032 USR-033 USR-034 USR-035 USR-036 USR-037 USR-038 USR-039 USR-040 USR-041 USR-042 USR-043 USR-044 USR-045 USR-046 USR-047 USR-048
type: stories
prd: PRD-003
branch: docs/prd-003-pm-content-depth
reviewed_commit: 9716a80
artifact_version: 2
date: 2026-10-30
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { value_slicing: 2, acceptance_criteria: 1, size_independence: 2, dependency_order: 2, ui_states: n/a }
total: 7/8
verdict: PASS
---

# PRD-003 story set eval: release 1 (USR-029 to USR-048), round 2

Anchor note: the 20 stories were read as COMMITTED in 9716a80, with the round 1 fixes applied.
The dispatcher supplied that sha and reports it verified; I have no shell and did not resolve it
myself. This record is uncommitted when written and must be committed after the stories, with
`docs/evals/` clean, for spec-gate to accept it. If any story moves after 9716a80, regenerate this
record rather than re-dating it.

Scope note, unchanged from round 1: by the human's decision of 2026-10-30, this set covers release
1 only (R1 to R10, R23 to R27, and release 1's share of R21).

## PRD coverage (precondition, reported apart from the score)

Release 1, by requirement id: 15 of 15 covered.

| Requirement | Stories |
|---|---|
| R1 | USR-030, USR-031 |
| R2 | USR-036 |
| R3 | USR-039 |
| R4 | USR-034 |
| R5 | USR-032, USR-033 |
| R6 | USR-035 |
| R7 | USR-040 |
| R8 | USR-042 |
| R9 | USR-041 |
| R10 | USR-037 |
| R21, release 1 part (4 of 18 rubrics) | USR-043 (interview syntheses, request triage), USR-044 (opportunity trees, discovery plans) |
| R23 | USR-047 |
| R24 | USR-029 |
| R25 | USR-045 |
| R26 | USR-038 |
| R27 | USR-046 (release 1 share now complete, see F1 below) |
| none (section 2 release 1 metric, H1) | USR-048 |

Known gap, decided by the human, not a defect of this set: R11 to R20, R22 and the 14 remaining
R21 rubrics have no story. Everything round 1 said about what enforces that gap still holds:
spec-gate does not read PRD coverage, so it will not refuse these stories for the gap;
`scripts/coverage-check.sh` (standalone) will exit 1 naming R11 to R20 and R22; and because
USR-043 and USR-044 carry `covers: R21`, coverage-check will count R21 as covered when the remaining
14 rubrics are still missing, so that share needs a human check when releases 2 and 3 are written.
USR-048's empty `covers:` remains sound (it carries the section 2 metric and H1, no numbered
requirement); no deterministic check notices if it is deleted.

## Round 1 fixes, verified

- **F1 closed.** USR-046 now lists "interview preparation, interview synthesis with its meeting
  mode, request triage, and product signal", which is release 1's full share of R27's list (R2,
  R3, R10, R26, product-signal). USR-036 gained "Material given to it (earlier notes, a research
  brief) containing an instruction to the model is not obeyed, and the reply says such an
  instruction was found", matching USR-037, USR-038 and USR-039. Inherited and still open in the
  PRD: `research` is not on R27's list.
- **F2 closed for the stories H1 measures, partly open elsewhere.** USR-029 now marks each present
  item "whether it is shown by default or on request (the lean default)". USR-030, USR-033, USR-034
  and USR-035 each carry "Without a request for depth, only the items its checklist (USR-029) marks
  as default appear". That covers the PRD and stories skills H1 measures "on the lean default
  output", and makes USR-030's lean-default criterion checkable. Residual, see comment C1.
- **Criterion 2, round 1's four instances closed.** USR-030: "run on a sample PRD with one planted
  side claim whose failure would not change the decision, that claim is not listed". USR-035: "run
  on a sample PRD whose requirement includes recovering from a failed payment, that recovery is its
  own story" and "run on a sample requirement that depends on an outside service nobody has used
  yet, that story is flagged". USR-041: "The output states the rule that turns the two scores into
  the choice, and the chosen target is the one that rule picks; when two tie, both are shown and
  the user chooses". Each is now pass or fail on a fixed input.
- **F3 closed.** USR-029: "The recorded commit is `07b34f6`, the commit PRD-003 was written from, or
  a newer commit read in full before it is recorded"; USR-045: "(USR-029: `07b34f6`, or a newer
  commit read in full first)". Both match R25's wording and close pre-mortem item 5's hole.
- **F4 closed.** USR-048 now opens with "the no-lost-rigor check of PRD-003 section 2 passes: the
  lint and all test suites are green, no skill asks for a number without a source or a hypothesis
  label, no skill names a person or a third-party plugin, and no `skill-reviewer` score is lower
  than before". I checked it against section 2's guardrail clause by clause: all four parts
  present. It also carries section 6's sourcing and lint parts at release level, and it closes
  round 1's minor note on USR-041 (importance and satisfaction scores are numbers a skill asks for,
  so they now need a source or a hypothesis label before release 1 ships).
- **F5 not applied, as reported by the dispatcher:** inherited from the PRD, closed there by the
  human. Still true of the stories: USR-029 gives `skill-reviewer` a job outside its defined scope,
  and USR-048's discovery comparison has no pass rule.

New inconsistencies introduced by the fixes: none found. The commit wording agrees between USR-029
and USR-045; USR-046's list matches its `depends_on`; USR-048's new precondition adds no dependency
outside its existing `depends_on`; H1 (section 4) measures "PRD or stories", which matches USR-048.

## Scores

- **Value slicing: 2.** Unchanged by the fixes. No technical layer poses as a story; fourteen
  stories change what a founder or PM gets from a skill, for example USR-039: "so that I answer the
  need instead of building the loudest request". USR-029, USR-045, USR-046 and USR-048 serve the
  maintainer, whom the PRD names as an audience, and each delivers a decision or a proof: "so that
  release 1 ships only if the deeper skills are actually better, not just longer" (USR-048).

- **Acceptance criteria: 1.** The four round 1 instances are fixed (above), and the set is now
  overwhelmingly binary. It still falls short of "every criterion observable and binary (no
  interpretation needed)". These criteria are the same kind round 1 flagged and **I missed them in
  round 1**. That was a reviewer miss, not an author regression: round 1's "8/8 reachable with
  fixes 2 and 3" was wrong, and I correct it here. I re-read every criterion of all 20 stories
  against round 1's standard, so this list is complete for criterion 2 on the text at 9716a80:
  1. USR-039: "Requests are grouped into themes by the underlying need, not by the feature asked
     for." Whether a theme is a need or a feature is the reader's call, and no sample fixes it. This
     is the story's core value, so it decides the score.
  2. USR-039: "Requests that contradict each other are flagged." and USR-037: "A contradiction
     within one interview is flagged." Neither can be tested unless the input is known to contain a
     contradiction, and whether one exists is interpretation unless it is planted.
  Borderline, not deciding on their own: USR-047's "recorded there in plain words" ("plain" is a
  quality word, the binary core is "recorded"); USR-030's "states the strongest case for it" (the
  binary core is "states a case before attacking it"); USR-045's "its two nearest neighbours" (the
  list does not have to name them, so nobody can check it against them).
  These inherit R3's and R10's wording, as round 1's instances inherited R1, R6 and R9; the rubric
  scores the stories regardless.

- **Size & independence: 2.** Estimates unchanged, 0.5 to 1.5 days each, author's estimates, not
  verifiable from this role. Coupling stays one-way: adopted-skill stories depend on USR-029, and the
  chained pairs touch the same skill. Comments, no points at stake: USR-048's new precondition
  (lint, all suites, a source-label sweep of every skill, a `skill-reviewer` pass to compare
  scores) makes "~1 day of maintainer time" tighter; its fail branch still holds unsized rework;
  USR-035 and USR-040 still check several source skills each in about a day.

- **Dependency order: 2.** Unchanged and rechecked: every story has `order:` 1 to 20, and every
  `depends_on` points to a lower order. USR-046's `depends_on: USR-036, USR-037, USR-038, USR-039`
  matches its list now that interview preparation is on it. Comment, not applied by choice and
  reported again only: USR-047 says "depends_on: none" while "Each skill change of this release is
  recorded there" can pass only after every change story.

- **UI states coverage: N/A.** No story has a user interface; every surface is a skill's text reply
  or a saved document. Rescaled to /8.

## Comments (no score attached)

- **C1, F2's residue: the lean default lives in four stories, not in every adopted skill.**
  Section 2: "Each adopted skill keeps a lean default". USR-031 (pre-mortem, the other half of the
  critique) and the adopted discovery skills USR-036 to USR-042 have depth checklists that now mark
  items default or on request, but no criterion that only the default items appear. Round 1's fix
  said "at least USR-033, USR-034, USR-035", so this is the scope I asked for, not a miss by the
  author. The structural fix is ONE criterion in USR-029, "for every adopted skill, without a
  request for depth only the items marked default appear", which covers all of them, including
  skills added in later releases, instead of a line per story.

## Total: 7/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, and no criterion at 0)

No criterion at 0, no Critical. Release 1 coverage complete by id; the release 2 and 3 gap is the
human's decision.

## Ceiling
8/8 reachable. Nothing caps structurally; criterion 2 reaches 2 when the three criteria in its list
get a planted sample (top fix 1).

## Stop condition (docs/eval-framework.md)
The loop stops here on condition 1: PASS. Condition 3 also applies, and I state it so the human can
judge it: rounds 1 and 2 both raised the same class, **"a criterion that needs the reader to
recognise a category, with no planted sample fixing the answer"**. Closing these three by another
patch would leave the next such criterion possible. So: do not buy a round 3 for criterion 2 alone.
If the human wants 8/8, apply top fix 1 to all three in one pass; that round would be the third
and last under the cap. The class-level fix sits outside this set: a quality rule in the stories
skill, "a criterion that asks the skill to recognise a category carries a planted sample". That is
an `/odeo:improve` change to `skills/stories`, and it is the human's call.

## Top fixes
1. Criterion 2 (score-bearing, one pass, all three):
   - USR-039: "run on a sample batch where requests for two different features state the same
     need, both land in one theme";
   - USR-039: "run on a sample batch with two requests that contradict each other, both are
     flagged";
   - USR-037: "run on sample notes where a participant says one thing and later the opposite, the
     contradiction is flagged".
   Optional in the same pass: USR-047 "in plain words" -> "naming the skill and what the user sees
   change, with no file or field names"; USR-045 "the list names each skill's two nearest
   neighbours".
2. C1: one lean-default criterion in USR-029 for every adopted skill, instead of per-story lines.
3. Not applied by choice, reported only: USR-047's `depends_on`; USR-048's size and fail-branch
   rework.

## Vs previous version
Same: 7/8 PASS in both rounds; no criterion moved. Inside criterion 2, round 1's four instances are
closed and three of the same kind remain, which round 1 missed. Fidelity: F1, F3 and F4 closed; F2
closed for the PRD and stories skills H1 measures, residue in C1; F5 unchanged (PRD-level, human
closed). No regression.

## Model note
Judged on claude-opus-5-5 and recorded as `strong`, as in round 1 and the PRD-003 record. This
role read no current model lineup and has no web access, so `strongest` is not a claim I can
justify. The effort value is the agent's declared `high`, as configured, not independently
verified. Output language handed at dispatch (`output_language: en`).

## History
- Round 1, v1 (20 uncommitted new files on top of b785230, dispatcher-verified), 2026-10-30.
  7/8, PASS. Value slicing 2, acceptance criteria 1, size 2, order 2, UI N/A. Criterion 2 lost on
  four criteria: USR-030 lean default pointing at a record no story created; USR-030 "a claim whose
  failure would not change the decision is not listed"; USR-035 "needs its own work" and "cannot be
  judged without investigation"; USR-041 "the scores decide the target" with no rule. Fidelity
  findings: F1 R27 narrowed (interview preparation missing from USR-046, no planted-instruction
  criterion in USR-036); F2 lean default in one story of thirteen; F3 install commit lost "read in
  full first"; F4 lint, no-person-credit and no-lost-rigor guardrail in no story; F5 inherited from
  the PRD (`skill-reviewer` scope, discovery comparison without pass rule). Comments: USR-047
  `depends_on`, USR-035/USR-040/USR-048 sizes. Release 1 coverage 15 of 15 plus R21's four rubrics.
  Not committed by the reviewer.
- Round 2, v2 (committed in 9716a80, dispatcher-verified), 2026-10-30: this record. 7/8, PASS, no
  criterion moved. F1, F3, F4 and round 1's four criterion-2 instances verified closed; F2 closed
  where H1 measures, residue C1; three criterion-2 instances of the same class found that round 1
  missed (USR-039 x2, USR-037). Stop: condition 1 (PASS); condition 3 named for the human. Not
  committed by the reviewer.
