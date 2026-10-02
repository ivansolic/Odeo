---
artifact: review-calibration
covers: docs/checklists/review-calibration.md docs/plan-format.md
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: 59d9183
artifact_version: 6
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger: 2, structure: 2, example: 2, precision: 2, safety: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

# Skill review: review-calibration + plan-format change, verification of the blocker fix

Scope, read only, at 59d9183:
- docs/checklists/review-calibration.md (scenarios 3 and 4)
- docs/plan-format.md: the change on this branch only, not a full re-review. That is the
  `What you decide` class, the Risks template, and criteria 5 and 6.
- docs/evals/calibration-plan-human-layer.md
- the moved archive in docs/calibration-runs/2026-10-02-blind/
- docs/internal-paths.txt

This reviewer has no shell, so neither merge-gate nor recount.py was run here. Placement and
classification were checked by reading the files. The recount figures (5/5, 0/5, 0/10, 5/10,
and B5.3 2x 5/5) were worked out by hand from the archived outputs in the previous pass, and
they match the numbers the dispatcher reports from actually running recount.py.

Model tier note: recorded as `strong`. Naming the strongest tier needs a live check of the
current model lineup, and this reviewer has no web access to do one.

## Previous blocker: resolved
- docs/evals/ now holds only frontmatter records. The 14 archive files sit in
  docs/calibration-runs/2026-10-02-blind/, and no `calibration-runs` path is left under
  docs/evals/. (The only remaining mentions in docs/evals/ were in the body of this record's
  previous version, which this regeneration replaces.)
- docs/internal-paths.txt line 29 lists `docs/calibration-runs/`, with the reason on lines 27
  and 28: "kept out of docs/evals because merge-gate requires every file there to be an eval
  record". The raw outputs stay internal, and the fail-closed publish check has nothing
  unclassified.
- recount.py line 3 and note line 19 both name the new path.

## Scores (docs/checklists/review-calibration.md)
- trigger clarity: 2. The opening is unchanged: it states the purpose and when to run.
- structure: 2. Every field is defined in the format section and used as its own field.
  Scenario 3's "known unplanted findings" now carries "the seed predates the `stop rule:` /
  `gate:` markers, so its Risks item is unmarked". Scenario 4 points to it with "the same as
  scenario 3".
- worked example: 2. The seeds are concrete and unchanged.
- precision: 2. The counting rule has one text ("Counted when any finding asks for it in the
  Summary or `What you decide`"), and it matches GRADING.md. The pass and fail rules are
  exact. No placeholders.
- safety integration: 2. The blind-run step with the copy set derived from the agent file is
  unchanged.

## Total: 10/10
## Verdict
PASS (threshold 8/10, no criterion at 0).

## Ceiling
10/10, reached.

## docs/plan-format.md (covered on this branch)
- Criterion 5 now reads "risks and open questions listed, for the builder to ask (`stop
  rule:`) or the human to decide (`gate:`), not guess". This matches the two kinds in the
  Risks template (lines 186 to 189), and criterion 6 ("leaving a gate decision ... only in the
  technical layer"). The class at lines 72 to 78 is unchanged and consistent. No residual.

## Results note
- The B5.3 heuristic sentence is now correct: "so would a correct output whose map carries
  another label ("Files touched"), since the check requires the text "file map"". This
  matches `fm >= 0` in both graders.
- The Risks rationale is now dated and scoped: "the format's reading at ff6ee09 (Risks then
  defined as the builder's questions)", and "that marker version has NOT been run against
  agents yet, so this run is evidence for the narrowed class, not for the markers". This is an
  honest limit.
- Unchanged and still holding:
  - The counts, with the named runs behind each.
  - The confound between format and blinding, which changed together.
  - n=10.
  - The three limits on run 2: contamination from the global CLAUDE.md, a simulated rather
    than dispatched agent, and the with-me test not run.

## Top fixes
None in the reviewed files. Open, and not a defect: the marker format (`stop rule:` / `gate:`)
has had no behavior run. If Ivan wants that evidence, it is calibrate-mode work for
/odeo:improve, and the note already says so.

## History
- Round 1 (a6cf42f): 8/10, PASS.
- Round 2 (e52db70): 9/10, PASS.
- Round 3 (fe31c82): 9/10, PASS. This was the cap.
- Human-approved confirmation pass 1 (e1e28d2): 9/10, PASS.
- Human-approved confirmation pass 2 (50226e7): 10/10, PASS, but with a blocker outside the
  rubric: the archive under docs/evals/ broke merge-gate's parse check for every branch.
- Blocker verification, still within Ivan's approved series (59d9183): 10/10, PASS.
  - The archive was moved and classified as internal.
  - Both inaccurate sentences in the note are corrected.
  - The optional fixes (criterion 5, and the placement of the unmarked-seed sentence) were
    taken.
  - Nothing is left open in the reviewed files.
- Trajectory: 8 -> 9 -> 9 -> 9 -> 10 -> 10.
