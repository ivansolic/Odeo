---
covers: USR-029 USR-030 USR-031 USR-032 USR-033 USR-034 USR-035 USR-036 USR-037 USR-038 USR-039 USR-040 USR-041 USR-042 USR-043 USR-044 USR-045 USR-046 USR-047 USR-048
type: stories
prd: PRD-003
branch: docs/prd-003-pm-content-depth
reviewed_commit: e8c3a25
artifact_version: 4
date: 2026-11-04
scorer: pm-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { value_slicing: 2, acceptance_criteria: 2, size_independence: 2, dependency_order: 2, ui_states: n/a }
total: 8/8
verdict: PASS
previous_total: 8/8
---

# PRD-003 story set eval: release 1 (USR-029 to USR-048), round 5 (fresh re-review after rebase)

Anchor note: the dispatcher supplied `e8c3a25` as the commit to record. I have no shell and did
not resolve it myself. The session's git snapshot reported this branch clean with `e8c3a25` as
HEAD, so the files I read in the worktree are taken to be that commit. If any story or PRD-003
moves after `e8c3a25`, regenerate this record; do not re-date it.

Why this round: the branch was rebased onto `main`, so the round 4 record's anchor (`208d421`)
no longer exists on the branch. This is a fresh review: all 20 stories and PRD-003 were read in
full and scored again from scratch, not carried over. I cannot run `git diff`, so I cannot prove
that the story text is unchanged since round 4. Spot-check: the round 4 quotes from USR-029,
USR-030 and USR-039 match the current text word for word. `artifact_version` therefore stays 4.

## PRD coverage (precondition, reported apart from the score)

I worked this out by hand because I have no shell. It follows `scripts/coverage-check.sh`: the
requirement ids are the `- **R<n>` list items in PRD-003 (27 ids), and coverage is the union of
the `covers:` fields of stories with `prd: PRD-003`.

| Requirement | Release | Stories |
|---|---|---|
| R1 | 1 | USR-030, USR-031 |
| R2 | 1 | USR-036 |
| R3 | 1 | USR-039 |
| R4 | 1 | USR-034 |
| R5 | 1 | USR-032, USR-033 |
| R6 | 1 | USR-035 |
| R7 | 1 | USR-040 |
| R8 | 1 | USR-042 |
| R9 | 1 | USR-041 |
| R10 | 1 | USR-037 |
| R21, release 1 share (4 of 18 rubrics) | 1 to 3 | USR-043 (interview syntheses, request triage), USR-044 (opportunity trees, discovery plans) |
| R23 | 1 | USR-047 |
| R24 | 1 | USR-029 |
| R25 | 1 | USR-045 |
| R26 | 1 | USR-038 |
| R27 | 1 | USR-046 |
| R11 to R19 | 2 | none |
| R20, R22 | 3 | none |
| no R id (section 2 release 1 metric, H1, no-lost-rigor guardrail, open question 1) | 1 | USR-048 (`covers:` empty, correct) |

- **Release 1 (section 5: "R1 to R10 and R23 to R27", plus four R21 rubrics): 15 of 15 covered.**
  Every one of the 15 has at least one covering story, and R21's release 1 share names exactly
  the four rubrics section 5 lists.
- **Full PRD: COVERAGE FAIL by the script's rule.** Run against the whole PRD,
  `coverage-check.sh` exits 1 on R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R22. It also
  counts R21 as covered, although 14 of its 18 rubrics have no story.
- **Why the verdict still stands:** these 11 requirements belong to releases 2 and 3, which
  PRD-003 section 5 calls "each one shippable on its own" and which may only start after the
  release 1 comparison passes (section 2). The round 4 record says the human limited this set to
  release 1 on 2026-10-30. **I could not find that decision written down anywhere except my own
  earlier record.** It is not in PRD-003's decision log or in the stories, and a reviewer's
  record is not where a human decision should live. Note also that `coverage-check.sh` is a
  standalone tool: neither `spec-gate.sh` nor the build skill calls it, so nothing machine-run
  will stop a build on this gap. The fix belongs to the human: write the release 1 scope of this
  set into PRD-003's decision log. Do not weaken the coverage rule, and do not add placeholder
  stories.

PRD fidelity, checked requirement by requirement against the section 6 wording. Each element
of R1 to R10 and R23 to R27 appears in a criterion of the covering story; nothing was narrowed.
- R1 red team: claims the plan stands on, the strongest case for each, "fails if", three
  ranking factors, kill criterion, evidence this week, cheapest test, what holds up, what could
  not be judged. Pre-mortem: three groups, three timing buckets, mitigation and owner role.
  Fixed shape: "Two critiques of different documents show the same headings in the same order".
- R27 in release 1: R2, R3, R10, R26 and `product-signal` are all named in USR-046. R17 and R18
  are release 2 and correctly left out.
- Cross-cutting AC: sourced numbers (USR-032, USR-040, and the USR-048 precondition); lint and
  no person credit (USR-048 precondition); text by others treated as data (USR-036, USR-037,
  USR-038, USR-039, checked by USR-046).
- Stories that go further than the PRD, and are allowed to: USR-031 "An overblown worry states
  why it is overblown"; USR-036 "at least one follow-up probe" per question; USR-045 "the request
  passes on a re-run". None of these contradicts the PRD.

## Scores

- **Value slicing: 2.** No story is a technical layer posing as a story. Fifteen of them change
  what a founder or PM gets from a skill, for example USR-039: "so that I answer the need instead
  of building the loudest request", and USR-047 serves Odeo's users: "so that an update never
  surprises me". USR-029, USR-045, USR-046 and USR-048 serve the maintainer, whom PRD-003 section
  1 names as someone affected ("observed, the maintainer"). Each of the four delivers something
  that maintainer can see, for example USR-046: "so that no release ships a skill that obeys a
  customer export or a transcript". USR-043 and USR-044 reach the user through the reviewer:
  "so that a tree that picks no target or a plan without decision rules does not pass".

- **Acceptance criteria: 2.** My test: a criterion is binary when two careful checkers, given the
  same output and any sample the story names, would reach the same pass or fail. The criteria
  that depend on spotting a category in the input carry a test sample:
  - USR-030: "run on a sample PRD with one planted side claim"
  - USR-035: "recovering from a failed payment" and "an outside service nobody has used yet"
  - USR-037: "a participant says one thing and later the opposite"
  - USR-039: two different features with one stated need, and two contradicting requests
  - USR-029: "A sample checklist with one source item neither present nor excluded is rejected"
  - USR-047: "run on a deliberately mismatched pair, it fails"

  The planted-instruction criteria in USR-036 to USR-039 become binary through USR-046's sample
  inputs. I found four borderline criteria. Each has a binary core and none decides the score:
  - USR-030 "states the strongest case for it before attacking it": "strongest" cannot be
    checked, but "a case comes before the attack" can.
  - USR-039 "A request whose need is not stated is not counted as evidence of a need": deciding
    needs a judgement about the input, and no sample is named.
  - USR-047 "says what the user now gets": mildly interpretive. Its negative half ("no entry
    names a file path or an internal rule number") is binary.
  - USR-043 and USR-044 "whose criteria reward evidence and decisions over filled sections": as
    a description this needs interpretation. The calibration criterion right after it ("the
    strong one passes and the hollow one fails") is binary and does the checking.

  No criterion is vague in the rubric's 0 sense ("user-friendly", "works well").

- **Size & independence: 2.** The size estimates run from "~0.5 day" (USR-032, USR-041, USR-046,
  USR-047) to "~1.5 days" (USR-029, USR-036, USR-039, USR-043, USR-044), within the rubric's 0.5
  to 2 days. They are the author's estimates and I cannot verify them from this role. Coupling
  runs one way, towards USR-029's shared checklist standard, and each adopted-skill story owns
  its own check ("Its depth checklist (USR-029) against ... passes"). Comments, no points
  deducted:
  - USR-048's "~1 day of maintainer time" has to cover the precondition run, 3 ideas x 3 arms x
    3 documents, the discovery comparison, length and score measurement, and the install
    procedure. That is tight.
  - USR-035 and USR-040 each check several source skills in about a day.
  - USR-029's release-wide criteria ("Every adopted skill, asked without a request for depth,
    shows only the items its checklist marks as default") hold trivially at order 1, because no
    adopted skill exists yet. They become binding one story at a time as later stories add
    adopted skills. This works, but USR-029 cannot be signed off as finished until the release.

- **Dependency order: 2.** Every story has an `order:` from 1 to 20, and I checked that every
  `depends_on` points to a lower order:
  - USR-031 -> USR-030: same skill, red team first.
  - USR-033 -> USR-032 and USR-035 -> USR-034: same skill, one after the other.
  - USR-038 -> USR-037: the meeting mode is added to interview synthesis.
  - USR-042 -> USR-040, USR-041: the discovery plan uses the experiments and the tree.
  - USR-043 -> USR-037, USR-039 and USR-044 -> USR-041, USR-042: each rubric comes after the
    skill whose document it scores.
  - USR-045 -> USR-036, USR-039: the new skills exist before routing is checked.
  - USR-046 -> USR-036 to USR-039.
  - USR-048 -> USR-030 to USR-047, and so through them on USR-029.

  USR-047 has "depends_on: none" at order 19, so the changelog can collect the release's changes
  after nearly all of them are built. That is sound.

- **UI states coverage: N/A.** No story has a user interface. Every surface is a skill's text
  reply or a saved document. The total is rescaled to /8.

## Total: 8/8   ## Verdict: PASS  (threshold: >= 6/8 with criterion 5 N/A, and no criterion at 0)

No criterion is at 0 and nothing is Critical. Release 1 coverage is complete. Full-PRD coverage
fails on R11 to R20 and R22 (reported above, apart from the score). That release 2 and 3 gap
needs the human's scope decision written into PRD-003.

## Ceiling
8/8, reached. Nothing caps a criterion for this set.

## Comments (no score attached)
1. **The release 1 scope of this set is recorded only in a reviewer record.** Add a decision-log
   line to PRD-003 ("stories cover release 1 only; releases 2 and 3 are decomposed when they
   start"), dated and by the maintainer. That turns the coverage gap above from unexplained into
   decided. It edits the PRD, not the stories.
2. **New this round: the leading-signal baseline has no home.** PRD-003 section 2 says "cloners
   are read for the 14 days before release 1", and the GitHub API keeps only 14 days of clone
   data. If nobody reads it before release 1 ships, the baseline is lost for good. It has no R id,
   so this is not a coverage failure, and no story or criterion schedules it. A one-line
   criterion in USR-048 ("before release 1 ships, stars and the last 14 days of unique cloners
   of the public repository are read and written down") would close it. That edits a story and
   costs one more review round, so it is the human's call.
3. USR-030 "strongest case": an optional rewording is "states a case for it before attacking it".
4. USR-039 "need is not stated": an optional planted sample is "run on a sample batch with one
   request that gives no reason, it is not counted and the output names it".
5. The lean-default criterion is repeated in USR-030, USR-033, USR-034 and USR-035 but not in
   USR-031 or USR-036 to USR-042. USR-029's set-wide criterion covers all of them, so this is
   only inconsistent wording, not a gap.
6. USR-048's discovery comparison ("For one idea the discovery documents release 1 changes are
   compared before and after in the same way") has no pass rule. The PRD has none either, so the
   story is faithful to its source.
7. USR-048 and USR-035 sizes, and USR-029's release-wide criteria: see Size & independence.

Applying comment 2, 3 or 4 edits a story and stales this record (spec-gate). Comment 1 edits only
the PRD, and a PRD change also stales the PRD's own record. My recommendation: apply comment 1,
and decide comment 2 on its merits, because losing the baseline cannot be undone later.
Comments 3 to 7 can stay.

## Stop condition (docs/eval-framework.md)
This round stops on condition 1 (PASS). It is not a continuation of the round 1 to 3 loop. The
rebase made the old anchor stale, and spec-gate needs a record anchored to the current commit.
No defect class repeats from round 4: comment 2 is a new observation, and it is about the PRD
not being fully carried into the stories, not about whether a criterion is binary.

## Vs previous version
**Same: 8/8 -> 8/8, no criterion moved.** Scored independently, I reached the same four scores
as round 4. Differences in findings:
- New: comment 2, the leading-signal baseline with no story.
- New: the USR-043/USR-044 and USR-047 borderlines are named explicitly.
- New: the observation that the release 1 scope decision is recorded only in a reviewer record,
  and that `coverage-check.sh` is called by no gate.

No regression found.

## Model note
Judged on claude-opus-5-5 and recorded as `strong`, as in rounds 1 to 4. This role read no
current model lineup and has no web access, so I cannot justify claiming `strongest`. The effort
value is the agent's declared `high`, as configured, not independently verified. The output
language was handed at dispatch (`output_language: en`).

## History
- Round 1, v1 (20 uncommitted new files on top of b785230), 2026-10-30. 7/8, PASS. Acceptance
  criteria 1: four non-binary criteria. Fidelity findings F1 to F5. Release 1 coverage 15 of 15.
- Round 2, v2 (committed in 9716a80), 2026-10-30. 7/8, PASS. F1, F3, F4 closed. Three more
  criteria of the "category in the input, no planted sample" class found.
- Round 3, v3 (committed in 626bb38), 2026-10-30. 8/8, PASS. Acceptance criteria 1 -> 2: planted
  samples added. Stop: conditions 1 and 2.
- Round 4, v4 (committed in 208d421), 2026-11-03. 8/8, PASS. Freshness re-review after the
  maintainer moved the R24 checklist check to a maintainer-only adoption reviewer. Only USR-029
  changed.
- Round 5, v4 content after the rebase onto `main` (anchor `e8c3a25`, sha supplied by the
  dispatcher), 2026-11-04: this record. A fresh full re-read and re-score of all 20 stories and
  coverage. 8/8, PASS, no criterion moved. Release 1 coverage 15 of 15. Full-PRD coverage fails
  on R11 to R20 and R22: the human's release scope, which is not yet written into the PRD. New
  comment: the leading-signal baseline read before release 1 has no story. Not committed by the
  reviewer.
