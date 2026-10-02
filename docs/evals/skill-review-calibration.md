---
artifact: review-calibration
covers: docs/checklists/review-calibration.md docs/plan-format.md
type: skill
branch: test/plan-human-layer-behavior
reviewed_commit: 50226e7
artifact_version: 5
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { trigger: 2, structure: 2, example: 2, precision: 2, safety: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

# Skill review: review-calibration + plan-format change, final confirmation pass

Scope, read only, at 50226e7 (rebased onto main 76a72a6):
- docs/checklists/review-calibration.md: the scenario format, scenarios 3 and 4, How to run
- docs/plan-format.md: this record covers the CHANGE on this branch, not a full re-review of
  the file. It checks the `What you decide` class (lines 72 to 78), the Risks template (lines
  185 to 189), rubric criteria 5 and 6 (lines 296 to 304), and the echo in
  agents/architecture-reviewer.md (lines 28 to 35).
- docs/evals/calibration-plan-human-layer.md, checked against the archive
  docs/evals/calibration-runs/2026-10-02-blind/ (12 outputs, GRADING.md, recount.py)

Method limit: this reviewer has no shell, so recount.py was READ, not run. Its printed counts
were worked out by applying its regexes to each archived output by hand.

Model tier note: recorded as `strong`. Naming the strongest tier needs a live check of the
current model lineup, and this reviewer has no web access to do one.

## Blocking, outside the rubric: the archive breaks merge-gate for every branch
The 14 files in docs/evals/calibration-runs/2026-10-02-blind/ have no frontmatter. Examples:
r-a1-review.md opens "# Plan review: ...", GRADING.md opens "# Grading rules ...", and
recount.py opens with a Python docstring.

merge-gate.sh lists `git ls-files -z docs/evals`, which is recursive. Every listed file must
open with `---` and close a frontmatter block, or the gate refuses: "docs/evals contains
file(s) whose frontmatter does not parse". That check runs BEFORE branch matching (lines 102
to 156), so it blocks merges from EVERY branch, not just this one. docs/eval-framework.md
says it directly: "Do not put documentation in `docs/evals/`. It belongs in `docs/`."

The 39 green suites do not catch this, because merge-gate.test.sh builds temporary repos. This
finding comes from reading the code. `bash scripts/merge-gate.sh` on this branch would
confirm it.

Fix:
- Move the archive out of docs/evals/, for example to docs/calibration-runs/2026-10-02-blind/.
- Add `docs/calibration-runs/` to docs/internal-paths.txt. The raw outputs are internal
  evidence, and an unclassified path blocks the publish (fail-closed).
- Update the path in recount.py's docstring and in the note.
- Do NOT give the files frontmatter to get them past the gate. They are not records, and
  recount.py could not carry it anyway.

## Scores (docs/checklists/review-calibration.md)
- trigger clarity: 2. The opening is unchanged: it states the purpose and when to run.
- structure: 2. The new optional field "**not a finding (recorded, not graded)**" is defined
  in the Scenario format section before scenarios 3 and 4 use it, and both scenarios now use
  it as their own field. The doc is about 145 lines, and the fixtures are one level deep.
- worked example: 2. The seeds are concrete and their bodies are unchanged.
- precision: 2. The recorded measure has one text: "Counted when any finding asks for it in
  the Summary or `What you decide`". It matches GRADING.md ("to appear in `What you decide`
  or the Summary"). Scenario 4 points to the same rule: "counted by the same rule". The pass
  and fail rules are unchanged and exact.
  - Optional cleanup: scenario 3's not-a-finding field also carries "a reviewer may also note
    the item is unmarked; that is a known unplanted finding". By the format's own
    definitions, that sentence belongs in the "known unplanted findings" field. Scenario 4's
    "the same as scenario 3" then misses it. The sentence states plainly that it is not this
    count, so no grade or count depends on it.
- safety integration: 2. The blind run step and the derived copy set are unchanged since the
  last pass.

## Total: 10/10
## Verdict
PASS (threshold 8/10, no criterion at 0). The verdict covers the two files in `covers:`. It
does not clear the archive placement above, which merge-gate refuses on its own.

## Ceiling
10/10, reached.

## docs/plan-format.md (covered here on this branch)
- Consistent. The class at lines 72 to 78 ("every open question in Risks that the HUMAN
  answers"; "A purely technical decision ... and a builder stop rule in Risks ... stay in the
  technical layer alone") matches the Risks template at lines 186 to 189. Both kinds are
  marked: "`stop rule:` ... it stays here. `gate:` ... it is also named under `What you
  decide`". The earlier tension (line 73 against line 186) is resolved.
- The template slip is fixed: both technical kinds now "stay in the technical layer alone".
- Criterion 6 ("leaving a gate decision or story deviation only in the technical layer")
  matches the `gate:` kind exactly. agents/architecture-reviewer.md lines 29 to 35 carry the
  same class and name the `gate:` marker. agents/architect.md and skills/build/SKILL.md hold
  no copy of the class that could go stale.
- Optional: criterion 5 still reads "risks and open questions listed for the builder to ask".
  Since Risks now also holds `gate:` items for the human, "listed for the builder to ask or
  the human to decide" would match the two kinds. Nothing breaks without this.

## Results note vs the archive and recount.py
Holds. These counts were worked out by applying recount.py's rules to the archived files:
- S3: 5/5. r-a1 to r-a4 rank it Important ("### I1 ..."), r-a5 ranks it Blocking ("### B1
  ..."), and each output names `What you decide`.
- S4: 0/5 asked. r-b1's "The serializer is a pure function ..." matches no `summary` or
  `what you decide` term.
- Stop rule asked: 0/10.
- Stop rule said to be correctly outside: 5/10. The runs are r-a3, r-a4, r-b2, r-b4 and r-b5,
  the same five the last pass found by reading.
- B5.3: g1 and g2 have 5/5 bullets verbatim, and the first "file map" text comes after the
  Summary.
- The three run-2 limits, the confound ("changed the format AND the blinding together"),
  n=10 and the self-attested mutation are all stated now.

Not supported:
- "a map under another label ("Files touched") would pass unchecked." This is the opposite of
  what both graders do. grade_blind_b53.py requires `fm >= 0` (`ok = not missing and before
  and fm >= 0`), and recount.py sets `before = fm >= 0 and ...`. A map under another label
  therefore FAILS, a false negative, just like the "see the file map below" case. The
  sentence should read "would fail a correct output as well".
- "The narrowing is kept ... on the format's own reading (Risks is defined as the builder's
  questions)". This was true at ff6ee09, but it is stale at 50226e7: the Risks template now
  defines two kinds, including `gate:` questions for the human. Cite the current two-kind
  definition instead.
- Untested-surface line, missing: run 2 tested the format at ff6ee09, which had no `stop
  rule:` / `gate:` markers. The marker version that ships now has no behavior run behind it.
  The note gives the commit, so this is not hidden, but one sentence would make it explicit.
- recount.py is labelled a heuristic and prints the runs behind each count, which is the right
  framing. Two of its checks are narrower than the rules they recount:
  - The S3 check accepts "what you decide" anywhere in the output, not inside the header
    finding's remedy.
  - The S4 check recognises only "Summary" or "What you decide", while the scenario rule
    covers the whole human layer, Why and Explanation included.
  Both are acceptable for a recount whose printed run names a human opens. Saying so in the
  docstring would keep the next reader from treating them as the rule.

## Top fixes
1. BLOCKING: move docs/evals/calibration-runs/ to docs/calibration-runs/, add it to
   docs/internal-paths.txt, and update recount.py and the note to the new path. Then confirm
   with `bash scripts/merge-gate.sh` that docs/evals parses.
2. Note, B5.3 paragraph: "a map under another label ... would fail a correct output as well"
   (not "pass unchecked").
3. Note: replace "(Risks is defined as the builder's questions)" with the current two-kind
   definition. Add "the marker format (`stop rule:` / `gate:`) has not been behavior-tested".
4. Optional: in scenarios 3 and 4, move the unmarked-item sentence into "known unplanted
   findings". In plan-format.md criterion 5, write "for the builder to ask or the human to
   decide".

## History
- Round 1 (a6cf42f): 8/10, PASS.
- Round 2 (e52db70): 9/10, PASS.
- Round 3 (fe31c82): 9/10, PASS. This was the cap. The loop stopped on a same-class residual.
- Human-approved confirmation pass 1 (e1e28d2), outside the capped loop: 9/10, PASS.
  Precision stayed at 1, because the "not a finding" field was undefined and the counting
  rule had two texts.
- Human-approved confirmation pass 2, final (50226e7), still within Ivan's approved series:
  10/10, PASS.
  - Both precision items are fixed.
  - This record now also covers docs/plan-format.md on this branch, and plan-format's
    line 73 against line 186 tension is resolved.
  - New and outside the rubric: the archive under docs/evals/ breaks merge-gate's parse
    tripwire for every branch.
  - The note's B5.3 heuristic sentence reverses what the grader does, and one rationale
    sentence is stale.
- Trajectory: 8 -> 9 -> 9 -> 9 -> 10.
