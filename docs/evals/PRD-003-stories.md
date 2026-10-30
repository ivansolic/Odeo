---
covers: USR-029 USR-030 USR-031 USR-032 USR-033 USR-034 USR-035 USR-036 USR-037 USR-038 USR-039 USR-040 USR-041 USR-042 USR-043 USR-044 USR-045 USR-046 USR-047 USR-048
type: stories
prd: PRD-003
branch: docs/prd-003-pm-content-depth
reviewed_commit: 626bb38
artifact_version: 3
date: 2026-10-30
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { value_slicing: 2, acceptance_criteria: 2, size_independence: 2, dependency_order: 2, ui_states: n/a }
total: 8/8
verdict: PASS
---

# PRD-003 story set eval: release 1 (USR-029 to USR-048), round 3 (final under the cap)

Anchor note: the 20 stories were read as COMMITTED in 626bb38, with the round 2 fixes applied.
The dispatcher supplied that sha and reports it verified; I have no shell and did not resolve it
myself. This record is uncommitted when written and must be committed after the stories, with
`docs/evals/` clean, for spec-gate to accept it. If any story moves after 626bb38, regenerate this
record rather than re-dating it; under the three-round cap that would mean a human decision, not a
fourth round by default.

Scope note, unchanged from rounds 1 and 2: by the human's decision of 2026-10-30, this set covers
release 1 only (R1 to R10, R23 to R27, and release 1's share of R21).

## PRD coverage (precondition, reported apart from the score)

Release 1, by requirement id: 15 of 15 covered. No `covers:` field changed since round 2.

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
| R27 | USR-046 |
| none (section 2 release 1 metric, H1) | USR-048 |

Known gap, decided by the human, not a defect of this set: R11 to R20, R22 and the 14 remaining
R21 rubrics have no story. Unchanged from round 1: spec-gate does not read PRD coverage;
`scripts/coverage-check.sh` (standalone) will exit 1 naming R11 to R20 and R22; because USR-043 and
USR-044 carry `covers: R21`, coverage-check counts R21 as covered while 14 rubrics are still
missing, so that share needs a human check when releases 2 and 3 are written. USR-048's empty
`covers:` remains sound.

## Round 2 fixes, verified

- **USR-039, grouping by need: closed.** "Requests are grouped into themes by the underlying need,
  not by the feature asked for: run on a sample batch where requests for two different features
  state the same need, both land in one theme." The input fixes the answer; pass or fail.
- **USR-039, contradictions: closed.** "Requests that contradict each other are flagged: run on a
  sample batch with two requests that contradict each other, both are flagged."
- **USR-037, within-interview contradiction: closed.** "A contradiction within one interview is
  flagged: run on sample notes where a participant says one thing and later the opposite, the
  contradiction is flagged."
- **USR-047, "plain words": closed.** "each entry names the skill by the command a user types and
  says what the user now gets; no entry names a file path or an internal rule number." Two of the
  three parts are mechanical checks; "says what the user now gets" is a light reading call at the
  same level as "states why it is asked" in USR-036, not a quality adjective.
- **USR-045, nearest neighbours: closed.** "A written list of sample requests exists that names,
  for each skill, its two nearest neighbours ... the two new skills name interview synthesis and
  product signal among theirs." Now checkable against the list itself, and it matches R25's
  example ("the two new skills against `interview-synthesis` and `product-signal`").
- **C1: closed.** USR-029: "Every adopted skill, asked without a request for depth, shows only the
  items its checklist marks as default; the items marked on request appear when the user asks."
  This reaches USR-031 and USR-036 to USR-042, which had no lean-default line, and every skill a
  later release adopts. The per-story lines in USR-030, USR-033, USR-034 and USR-035 now repeat it
  in identical wording; redundant, not contradictory.

Not applied, as reported by the dispatcher: USR-030 "strongest case", USR-047 `depends_on`, size
comments, F5. Each is restated under Comments below.

Regression check on the changed text: none found. The new USR-029 criterion uses the same phrase
("without a request for depth", "marks as default", "on request") as the four per-story lines, so
there is one meaning, not two. USR-045's new wording narrows, it adds no requirement outside R25.
USR-047's definition adds no dependency. No `order:`, `depends_on:` or `covers:` field changed.

## Scores

- **Value slicing: 2.** Unchanged. No technical layer poses as a story; fourteen stories change
  what a founder or PM gets from a skill, for example USR-039: "so that I answer the need instead
  of building the loudest request". USR-029, USR-045, USR-046 and USR-048 serve the maintainer,
  whom the PRD names as an audience, and each delivers a decision or a proof: "so that release 1
  ships only if the deeper skills are actually better, not just longer" (USR-048).

- **Acceptance criteria: 2.** Moved from 1. The three score-bearing instances of round 2 now each
  carry a planted sample (above), and I re-read every criterion of all 20 stories again. The test I
  applied, stated so the human can check it: a criterion fails "binary" when deciding pass or fail
  needs knowledge the output does not show, typically what the INPUT contained (is there a
  contradiction, do two features share a need), and no planted sample supplies it. Criteria that
  ask about a property visible in Odeo's own output pass, for example USR-036 "Every question asks
  about past behaviour; none asks about a hypothetical future or an opinion of the idea" and
  USR-034 "Scenarios say what the user does and sees; none names how it is built". USR-043's
  "criteria reward evidence and decisions over filled sections" is made binary by the next line,
  "the strong one passes and the hollow one fails". Two borderlines remain, neither deciding:
  1. USR-030: "states the strongest case for it before attacking it". The checkable core is "a case
     for each claim is stated before the attack"; "strongest" cannot be failed by any observation,
     so it is decoration, not interpretation that decides the outcome. Same call as round 2.
  2. USR-039: "A request whose need is not stated is not counted as evidence of a need, and the
     output says so." Whether a request states its need is a reading of the input, the same class
     as round 2's instances, but a mild one: a request either gives a reason or does not. I did not
     list it in round 2, where I called that list complete; I name it now for accuracy, not as a
     new defect, since the text is unchanged since round 1.

- **Size & independence: 2.** Estimates unchanged, 0.5 to 1.5 days each, author's estimates, not
  verifiable from this role. Coupling stays one-way: adopted-skill stories depend on USR-029, the
  chained pairs touch the same skill. Comments, no points at stake, unchanged: USR-048's
  precondition plus comparison is tight for "~1 day of maintainer time" and its fail branch holds
  unsized rework; USR-035 and USR-040 each check several source skills in about a day.

- **Dependency order: 2.** Rechecked: `order:` 1 to 20, every `depends_on` points to a lower
  order, USR-048 depends on USR-030 to USR-047 and so transitively on USR-029. Comment, no points:
  USR-047 "depends_on: none" while "Each skill change of this release is recorded there" can pass
  only after every change story. The new USR-029 criterion has the same shape ("Every adopted
  skill ... shows only the items its checklist marks as default" can fully pass only after the
  adopted-skill stories land), as did USR-029's existing release-level lines; it is a rule the
  later stories inherit and verify one by one, so I do not score it down, consistent with how
  USR-047 has been treated since round 1.

- **UI states coverage: N/A.** No story has a user interface; every surface is a skill's text reply
  or a saved document. Rescaled to /8.

## Comments (no score attached; reported, not chased, per the cap)

- USR-030 "strongest case": optional wording, "states a case for it before attacking it".
- USR-039 "need is not stated": optional planted sample, "run on a sample batch with one request
  that gives no reason, it is not counted and the output names it".
- USR-047 and USR-029 `depends_on` / release-wide criteria: see Dependency order.
- USR-035, USR-040, USR-048 sizes: see Size & independence.
- F5, inherited from the PRD and closed there by the human: USR-029 gives `skill-reviewer` a job
  outside its defined scope; USR-048's discovery comparison has no pass rule.
- Applying any of these edits a story, which stales this record under spec-gate and would need a
  fourth round, which the cap forbids by default. My recommendation: leave them, commit this record.

## Total: 8/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, and no criterion at 0)

No criterion at 0, no Critical. Release 1 coverage complete by id; the release 2 and 3 gap is the
human's decision.

## Ceiling
8/8, reached. Nothing caps structurally.

## Stop condition (docs/eval-framework.md)
The loop stops on condition 1 (PASS) and condition 2 (third round on this artifact) at once; no
fourth round. Condition 3, named in round 2, still describes the history: the class "a criterion
that needs the reader to recognise a category in the input, with no planted sample fixing the
answer" produced findings in rounds 1 and 2, and its last mild instance (USR-039 "need is not
stated") is noted above. This round closed the score-bearing instances, not the class. The
class-level fix sits outside this set: a quality rule in `skills/stories`, "a criterion that asks
the skill to recognise a category in its input carries a planted sample". That is an
`/odeo:improve` change and the human's call.

## Vs previous version
Better: 7/8 -> 8/8, on acceptance criteria (1 -> 2). The other criteria did not move. C1 closed
(one lean-default criterion in USR-029 covering every adopted skill). No regression found.

## Model note
Judged on claude-opus-5-5 and recorded as `strong`, as in rounds 1 and 2 and the PRD-003 record.
This role read no current model lineup and has no web access, so `strongest` is not a claim I can
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
- Round 2, v2 (committed in 9716a80, dispatcher-verified), 2026-10-30. 7/8, PASS, no criterion
  moved. F1, F3, F4 and round 1's four criterion-2 instances verified closed; F2 closed where H1
  measures, residue C1 (lean default not in every adopted skill); three criterion-2 instances of
  the same class found that round 1 missed (USR-039 grouping by need, USR-039 contradictions,
  USR-037 within-interview contradiction); borderlines USR-047 "plain words", USR-030 "strongest
  case", USR-045 "two nearest neighbours". Stop: condition 1 (PASS); condition 3 named for the
  human. Not committed by the reviewer.
- Round 3, v3 (committed in 626bb38, dispatcher-verified), 2026-10-30: this record. 8/8, PASS.
  Acceptance criteria 1 -> 2: the three round 2 instances each gained a planted sample; USR-047 and
  USR-045 borderlines closed; C1 closed by one criterion in USR-029. Remaining, comment-level only:
  USR-030 "strongest", USR-039 "need is not stated" (unchanged text, named now for accuracy),
  USR-047 and USR-029 release-wide criteria in early-order stories, sizes, F5. No regression. Stop:
  conditions 1 and 2. To be committed after this round, per the dispatcher.
