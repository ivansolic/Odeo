---
covers: USR-029 USR-030 USR-031 USR-032 USR-033 USR-034 USR-035 USR-036 USR-037 USR-038 USR-039 USR-040 USR-041 USR-042 USR-043 USR-044 USR-045 USR-046 USR-047 USR-048
type: stories
prd: PRD-003
branch: docs/prd-003-pm-content-depth
reviewed_commit: 208d421
artifact_version: 4
date: 2026-11-03
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { value_slicing: 2, acceptance_criteria: 2, size_independence: 2, dependency_order: 2, ui_states: n/a }
total: 8/8
verdict: PASS
---

# PRD-003 story set eval: release 1 (USR-029 to USR-048), round 4 (freshness re-review after a human decision)

Anchor note: the 20 stories were read as COMMITTED in 208d421. The dispatcher supplied that sha;
I have no shell and did not resolve it myself. This record is uncommitted when written and must
be committed after the stories, with `docs/evals/` clean, for spec-gate to accept it. If any story
moves after 208d421, regenerate this record rather than re-dating it.

Why a fourth round is legitimate here: round 3 ended the review loop on PASS (stop conditions 1
and 2). This round is not a continuation of that loop. The maintainer changed USR-029 afterwards
by a recorded decision (PRD-003 decision log, 2026-11-03), which stales the round 3 record under
spec-gate; the round 3 record itself named this path ("that would mean a human decision, not a
fourth round by default"). It is a freshness re-review of one changed story.

Scope of what I re-read: the dispatcher reports that only `docs/stories/USR-029-depth-checklist.md`
changed between a8f82f7 and 208d421. I cannot run `git diff`, so I took that on the dispatcher's
word and spot-checked it: I read USR-029 and USR-048 in full and searched all stories for
`skill-reviewer`, "adoption reviewer" and "maintainer-only"; the only hits are USR-029 line 31 (the
new text) and USR-048 line 20 (the no-lost-rigor check, a legitimate `skill-reviewer` use that
matches PRD-003 section 2, unchanged). The other 18 stories carry their round 3 assessment on that
basis. Scope note, unchanged: by the human's decision of 2026-10-30, this set covers release 1 only.

## PRD coverage (precondition, reported apart from the score)

Release 1, by requirement id: 15 of 15 covered. USR-029's `covers: R24` is unchanged; no other
`covers:` field changed.

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

Known gap, decided by the human, not a defect of this set, unchanged: R11 to R20, R22 and the 14
remaining R21 rubrics have no story. `scripts/coverage-check.sh` (standalone) will exit 1 naming
R11 to R20 and R22, and counts R21 as covered through USR-043 and USR-044 although 14 rubrics are
still missing; that share needs a human check when releases 2 and 3 are written.

## The change, checked

USR-029, now: "Before the release ships, the maintainer's adoption reviewer (never published)
checks each saved checklist against the source skill at the recorded commit and passes or rejects
it; a rejected checklist blocks the release."

- **Fidelity to the PRD: matches.** R24 now reads "before the release ships the maintainer's
  adoption reviewer (never published) checks each one against the source skill at the read
  commit ... a checklist it rejects blocks the release", and the decision log records "2026-11-03:
  the depth checklist check (R24) moves from the public `skill-reviewer` to a maintainer-only
  reviewer that is never published". Story and requirement say the same thing in the same terms.
- **Binary: yes.** Each saved checklist has a recorded pass or reject, and the release is blocked
  or not. The R24 properties the reviewer checks (every item accounted for, reasons from the closed
  list, "adds length" naming the user decision, no person-name field) are each carried by their own
  criterion in the same story, and "A sample checklist with one source item neither present nor
  excluded is rejected" still makes the reviewer's rejection testable.
- **What, not how: holds.** The reviewer is named by what it is ("the maintainer's adoption
  reviewer"), not by a file or agent name; "never published" is a property a maintainer can check.
- **Size: unchanged.** "~1.5 days: the checklist shape, the reviewer's check, the sample that must
  be rejected" still describes the work; swapping which reviewer runs the check adds no scope.
- **Side effect: F5's first half is closed.** Rounds 1 to 3 carried, as an inherited comment,
  "USR-029 gives `skill-reviewer` a job outside its defined scope". The check no longer sits with
  `skill-reviewer`, so that half no longer applies. F5's second half (USR-048's discovery
  comparison without a pass rule) is untouched and stays a comment.

Regression check on the changed text: none found. No `order:`, `depends_on:` or `covers:` field
changed; the criterion introduces no new term that another story uses differently.

## Scores

- **Value slicing: 2.** Unchanged. No technical layer poses as a story; fourteen stories change
  what a founder or PM gets from a skill, for example USR-039: "so that I answer the need instead
  of building the loudest request". USR-029, USR-045, USR-046 and USR-048 serve the maintainer,
  whom the PRD names as an audience; USR-029's card still delivers a proof: "so that 'same depth as
  the source' is proven per skill instead of claimed".

- **Acceptance criteria: 2.** Unchanged. The changed criterion is binary (above). The test I apply,
  as in round 3: a criterion fails "binary" when deciding pass or fail needs knowledge the output
  does not show, typically what the INPUT contained, and no planted sample supplies it. Two
  borderlines remain from round 3, neither deciding and neither touched by this change: USR-030
  "states the strongest case for it before attacking it" ("strongest" is decoration, the checkable
  core is "a case is stated before the attack") and USR-039 "A request whose need is not stated is
  not counted as evidence of a need" (a mild input reading, a request either gives a reason or does
  not).

- **Size & independence: 2.** Unchanged, 0.5 to 1.5 days each, author's estimates, not verifiable
  from this role. Coupling stays one-way. Comments, no points: USR-048's precondition plus
  comparison is tight for "~1 day of maintainer time"; USR-035 and USR-040 each check several source
  skills in about a day.

- **Dependency order: 2.** Unchanged: `order:` 1 to 20, every `depends_on` points to a lower order,
  USR-048 depends on USR-030 to USR-047 and so transitively on USR-029. USR-029 keeps "depends_on:
  none"; whether the maintainer's adoption reviewer already exists is a build fact, not something
  the story set must order, and the story's size includes "the reviewer's check". Comment, no
  points: USR-047 and USR-029 hold release-wide criteria in early-order stories, treated as rules
  the later stories inherit, as since round 1.

- **UI states coverage: N/A.** No story has a user interface; every surface is a skill's text reply
  or a saved document. Rescaled to /8.

## Comments (no score attached)

- USR-030 "strongest case": optional wording, "states a case for it before attacking it".
- USR-039 "need is not stated": optional planted sample, "run on a sample batch with one request
  that gives no reason, it is not counted and the output names it".
- USR-047 and USR-029 release-wide criteria in early-order stories: see Dependency order.
- USR-035, USR-040, USR-048 sizes: see Size & independence.
- F5, second half only, inherited from the PRD and closed there by the human: USR-048's discovery
  comparison ("For one idea the discovery documents release 1 changes are compared before and after
  in the same way") has no pass rule.
- Applying any of these edits a story and stales this record. My recommendation, as in round 3:
  leave them and commit this record.

## Total: 8/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, and no criterion at 0)

No criterion at 0, no Critical. Release 1 coverage complete by id; the release 2 and 3 gap is the
human's decision.

## Ceiling
8/8, reached. Nothing caps structurally.

## Stop condition (docs/eval-framework.md)
Stops on condition 1 (PASS). No defect was raised this round, so condition 3 does not apply. The
class named in rounds 2 and 3 ("a criterion that needs the reader to recognise a category in the
input, with no planted sample") has no new instance; its class-level fix remains an `/odeo:improve`
change to `skills/stories` and the human's call.

## Vs previous version
Same: 8/8 -> 8/8, no criterion moved. USR-029's reviewer criterion now names the maintainer's
adoption reviewer instead of `skill-reviewer`, matching R24 and the 2026-11-03 decision; it stays
binary. F5's first half closed as a side effect. No regression found.

## Model note
Judged on claude-opus-5-5 and recorded as `strong`, as in rounds 1 to 3 and the PRD-003 record.
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
- Round 3, v3 (committed in 626bb38, dispatcher-verified), 2026-10-30. 8/8, PASS. Acceptance
  criteria 1 -> 2: the three round 2 instances each gained a planted sample; USR-047 and USR-045
  borderlines closed; C1 closed by one criterion in USR-029. Remaining, comment-level only: USR-030
  "strongest", USR-039 "need is not stated", USR-047 and USR-029 release-wide criteria in
  early-order stories, sizes, F5. No regression. Stop: conditions 1 and 2.
- Round 4, v4 (committed in 208d421, sha supplied by the dispatcher), 2026-11-03: this record.
  Freshness re-review after the maintainer's 2026-11-03 decision moved the R24 depth checklist check
  from `skill-reviewer` to a maintainer-only adoption reviewer that is never published. Only
  USR-029 changed (dispatcher's diff claim, spot-checked by search): one acceptance criterion now
  names "the maintainer's adoption reviewer (never published)". 8/8, PASS, no criterion moved.
  Matches R24 and the decision log; binary; F5's first half closed. Remaining comments unchanged
  otherwise. No regression. Stop: condition 1. Not committed by the reviewer.
