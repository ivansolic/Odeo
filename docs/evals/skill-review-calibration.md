---
artifact: review-calibration
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: a6cf42f
artifact_version: 1
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger: 2, structure: 2, example: 2, precision: 1, safety: 1 }
total: 8/10
verdict: PASS
previous_total: none
---

# Skill review: review-calibration (format doc + calibration fixtures)

Scope reviewed at a6cf42f (read only):
- docs/checklists/review-calibration.md, scenarios 3 and 4
- tests/fixtures/calibration/USR-014-export-csv.md, plan-decision-missing-from-summary.md,
  plan-technical-decision-only.md
- docs/evals/calibration-plan-human-layer.md (results note), checked against the raw runs
  s3-r1..5, s4-r1..5, b53-r1..2, GRADING.md and grade_b53.py in the job scratch directory

This is a format doc plus fixtures, not a SKILL.md. The rubric is applied as far as it fits:
trigger clarity is read from the doc's opening (no description field exists), and the map
duty does not apply (no command added).

Model tier note: recorded as `strong`, not `strongest`. The judge is an Opus-class model, but
the strongest tier must be resolved live against the current lineup and this reviewer has no
web access to do that, so only the provable floor is claimed.

## Scores
- trigger clarity: 2. "Goal: prove that our JUDGMENT-layer reviewers (code-reviewer,
  design-reviewer, architecture-reviewer, pm-reviewer) actually catch the defects they claim
  to" plus "Guards changes that cheapen the pipeline". Purpose and when to run are both stated.
  The new scenario ids are kebab-case and say what they test.
- structure: 2. Scenarios 3 and 4 carry every format field (id heading, reviewer, seed,
  planted defect, expected finding, pass/fail). The fixtures are one level from the doc and
  referenced by exact path. The doc is 114 lines.
- worked example: 2. The seeds are real, imitable plans with concrete values (`due_date`
  header, `toTasksCsv(tasks: Task[]): string`, `?teamId=B`). They are not abstract
  placeholders.
- precision: 1. The format text and the scenarios no longer agree in places, and the
  scenario 3 rule leaves the case the runs actually produced undecided:
  - Scenario 3 requires "WITH the remedy that the human decides it". All five s3 runs
    offered an either/or ("use `due date` as the story says, or keep `due_date` and list it
    in `What you decide`"). The rule does not say whether that passes. GRADING.md's (b)
    reads slightly differently ("says it must be surfaced to the human"). Two graders could
    disagree on exactly the shape every run produced.
  - Scenario 3 says "flagged under criterion 6", but GRADING.md does not require the
    criterion to be cited. That gives two rule texts for one scenario.
  - Scenario 4's expected finding says "in the human layer", while its pass/fail says "in
    the Summary or `What you decide`". A finding asking to put the decision in Explanation
    fails one text and passes the other.
  - Scenario 4 says "planted defect: none for criterion 6". The seed carries an unplanted
    criterion-6 defect (the formula guard changes titles), which all 5 s4 runs flagged. The
    scenario does not say so, so a future grader cannot tell an expected extra finding from
    noise.
  - The format line "Inline here for now; extract to a fixtures directory under `tests/`
    when `/odeo:improve` calibrate mode automates the runs" is now contradicted by scenarios
    3 and 4, which use fixtures, and by the Boundary section, which says calibrate mode
    already automates the runs.
  - The fixture filenames `plan-decision-missing-from-summary.md` and
    `plan-technical-decision-only.md` name the answer. The seed BODIES are clean (no comment
    or wording points at the planted defect, and the header rationale reads as ordinary plan
    prose). These runs avoided the problem by copying the seeds as plan-s3.md and plan-s4.md.
    The doc's "How to run" does not tell the next runner to do the same.
- safety integration: 1. The doc references the review loop ("fix the agent (or the
  rubric), then re-run, per the review loop") and the eval framework for records. It does
  not reference the blind-scoring rule in docs/eval-framework.md ("they can score BLIND"),
  which is the property a calibration run depends on. In this run, GRADING.md and the
  sibling run outputs sat in the same directory as the seeds the agents were given, and the
  branch worktree they were told to read holds this doc with every expected finding. No run
  output shows that an agent read them. The exposure is still real, and neither the doc nor
  the note names it.

## Total: 8/10
## Verdict
PASS (threshold 8/10, no criterion at 0).

## Ceiling
10/10 is reachable. Nothing caps a criterion structurally: blind scoring applies directly,
so safety integration can reach 2.

## Results note: claims vs evidence
Verified against the raw runs:
- Scenario 3 is 5/5 PASS, all Important and all tied to `What you decide`: s3-r1 I1, s3-r2
  I2, s3-r3 I2, s3-r4 I2, s3-r5 I1. Holds.
- Scenario 4 is 5/5 PASS: no run asks for the pure-function decision in the human layer, and
  s4-r2 praises it as "a clean seam". Holds.
- B5.3 is 2/2: all five bullets appear verbatim in both runs. The Summary starts at line 4
  and line 3, and the file map at line 16 and line 15. Holds.
- "Formula guard changes titles, 8 of 10": s3-r1 B1, s3-r2 I1 and s3-r3 I5, plus all five s4
  runs (s4-r1 I7(a), r2 I1, r3 I1, r4 I1, r5 I2). s3-r4 and s3-r5 raise only the ambiguity
  of the invariant, not the title change. Holds at 8/10.

Not supported by the evidence:
- "A builder stop rule read as a human decision. 6 of 10 runs (all five on scenario 3, one as
  a note on scenario 4)." The scenario 3 part holds. The scenario 4 part is an undercount:
  - Two s4 runs flag it at Important, inside a finding headed by something else. s4-r1
    I7(b) says "The open question in Risks ... is not in `What you decide` either". s4-r5 I3
    says "The stop-and-ask Risk is also an open question that does not appear in `What you
    decide` (criterion 6, letter of the rule)".
  - Three s4 runs raise it as a note or observation: s4-r2 N4, s4-r4 N2, s4-r3 N6
    ("observation, no change needed").
  - In total, every one of the 10 runs mentions it, and 7 of 10 rank it Important.
  - Counting "by heading" causes the miss: only s4-r2 N4 has a heading that names it. The
    method was not applied consistently either, because a heading count of the formula
    finding would give 7, not 8 (s4-r1's heading is "Human layer: two gate items").
  - The note also leaves out evidence that bears on the decision it hands the human. Three
    s4 runs drew the distinction themselves: s4-r2 says "a stop condition for the builder
    rather than a choice for the gate, so leaving it out of `What you decide` is
    defensible", and s4-r3 and s4-r4 say the same. s4-r1 proposes "recast it as a builder
    stop rule outside Risks".
- "Graded by a script: each of the five Summary bullets must appear verbatim ..., and the
  Summary must come before the file map." grade_b53.py checks only the verbatim part. The
  ordering was checked by hand (the line numbers given are correct). "The script was shown to
  FAIL on a paraphrase" has no artifact in the scratch directory, so it cannot be verified.
- "Grading rules were written BEFORE any run": this rests on GRADING.md's own header only.
  The note should call it self-attested.
- Frontmatter: the note gives `model_tier: strongest` but no `model:`, no `scorer:` and no
  `artifact:`, although docs/eval-framework.md's record shape includes them. Nobody can tell
  which model ran the 12 agents, or who graded them. The gate is not affected: the note has
  no `branch:`, so merge-gate only parse-checks it.

Stated limits that are honest:
- The simulated reviewer: verified that the 0.3.2 agents/architecture-reviewer.md has no
  criterion 6 and no `What you decide`. The difference in tools and system prompt is stated.
- The global CLAUDE.md contamination: the global file does carry "What I decide names EVERY
  open choice and every deviation". This is stated plainly.
- The with-me test was not run, and this is said with the reason.
- Undisclosed: the answer key (GRADING.md, the earlier run outputs, and this checklist on the
  branch) was within the reviewer agents' reach.

## The second finding's framing
It is correctly framed as a format decision for the human and is not silently fixed:
docs/plan-format.md lines 72 to 76 and agents/architecture-reviewer.md line 29 still say
"every open question in Risks". The analysis is incomplete, though. docs/plan-format.md
line 184 defines the Risks section as "anything ambiguous the builder must ASK about rather
than decide alone", so the format itself places builder stop rules in Risks. The tension sits
inside the format (line 73 against line 184), not in architect habit. The second option, "architects keep
builder stop rules out of Risks", would mean redefining the Risks section, not just applying
discipline. The note should name that. It should also offer the third option two runs
proposed: a one-line Summary mention such as "one thing may come back to you during the
build".

## Top fixes
1. Scenario 3 pass/fail: add "A remedy of the form 'match the story, or keep it and name it in
   `What you decide`' passes; a remedy that only says to match the story fails. Citing
   criterion 6 by number is not required." Then delete the divergent wording, so that the doc
   holds the one rule text the grader uses.
2. Scenario 4: make the expected finding and pass/fail use the same scope. Either use
   "Summary or `What you decide`" in both, or use "the human layer (Summary, Why,
   Explanation)" in both.
3. Scenarios 3 and 4: add a line "known unplanted findings: the formula prefix changes
   titles starting with `-`, `+`, `@` (criterion 4 vs 5), and the Risks stop rule under the
   literal criterion 6; neither affects the grade". The alternative is to fix both seeds and
   re-run.
4. Scenario format: replace "Inline here for now; extract to a fixtures directory under
   `tests/` when `/odeo:improve` calibrate mode automates the runs" with "Inline when it fits
   in a few lines; otherwise under `tests/fixtures/calibration/`".
5. Blind runs: rename the two plan fixtures to neutral names (for example
   `plan-usr-014-a.md`, `plan-usr-014-b.md`), and add a "How to run" step: "Give the reviewer
   only the seed and the story, under neutral names, in a directory that holds no grading
   rules, expected findings or earlier outputs (blind scoring, docs/eval-framework.md)."
6. Results note (regenerate it, do not patch the counts by hand): change the stop-rule count
   to "all 10 runs mention it, 7 of 10 at Important (all five on scenario 3, plus s4-r1 and
   s4-r5); three scenario-4 runs themselves call it a builder stop rule". Say the B5.3 ordering
   was checked by hand. Mark the pre-run grading rules as self-attested. Add `model:`,
   `scorer:` and `artifact:`. Add the answer-key exposure to the limits. In the second
   finding, cite plan-format.md line 184 against line 73.

Behavioral note: the form fixes above do not need a new behavioral test. Rerunning the
scenarios after fix 5 under a blind setup would make the 12/12 claim stronger. That belongs to
/odeo:improve calibrate mode, not to this review.

Integrity: these are first-party files, not a community contribution, so no copied-text check
was needed.

## History
- Round 1 (a6cf42f): 8/10, PASS. No prior record.
