---
artifact: skills/research
type: skill
branch: chore/research-rubric-and-citations
reviewed_commit: eb7e7cb
artifact_version: 5
date: 2026-10-02
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Round 5, at eb7e7cb: a re-anchor plus the one-sentence fix named in round 4's Ceiling.
**Like round 4, this ran past the three-round cap of `docs/eval-framework.md`**, under the
human's round 4 decision. The dispatcher reports that it will tell the human this re-anchor
happened. Why the round exists: a code-review fix to `scripts/skills-lint.sh` (C18 now
fails closed) moved the branch past c2ca2a2, which made the round 4 record stale whatever
the skill said.

I cannot run git, so I did not take "only one sentence changed in `skills/`" on trust. I
re-read both files in full at this commit. `skills/research/rubric.md` (121 lines) is
identical to what round 4 read. `skills/research/SKILL.md` (119 lines) differs only at
lines 90-92. The lint change is `code-reviewer`'s to judge and is not scored here. Model
tier: Opus class recorded as strongest; the live lineup could not be re-checked from this
agent (no web access).

Calibration status: the rubric was calibrated at f947223. This record judges the files as
written and does not rely on any recalibration result.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2 "Use when the user wants market or web research
  with sources, ...".
- structure: 2, unchanged. SKILL.md:9-11 names the rubric's Definitions as the one source of
  the terms; step 5b dispatches the rubric; the rubric is one level deep.
- worked example: 2, unchanged. SKILL.md:83-88: an Answer clause with "(one source, note
  2)", a note with page and verbatim quote, and an Unverified line that labels the
  inference. The quote and page were verified against RES-002 note 2 in round 4.
- precision: 2 (was 1). The round 4 residual is closed. SKILL.md:90-92 now reads "the
  sources behind most of its table cells were not kept, so those cells could not be traced
  to anything". That matches RES-002:39-41, "the agent reports that held its sources were
  not kept ... so its source cannot be named here", and its table, where most capability
  cells outside the Claude Code column are "? reported". The uncited threshold claim is
  gone. No term-meaning drift was found in either file; lint C18 guards the one word that
  kept drifting. Paths, names and commands are exact throughout.
- safety integration: 2, unchanged. Step 5b, SKILL.md:59-62, commits "on a branch (on
  `main`, ask the human to create one first: Git discipline in
  `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`)" and references Guardrails 1, 3 and 7. The honesty
  rule stays at SKILL.md:107-108. The rubric restates nothing.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. No criterion caps for this skill.

## Checks
- Dashes: none in either file.
- C16: the rubric names no program; SKILL.md:112 uses the plugin-root form. Clean.
- AGENTS.md: nothing restated.
- Threshold and fall-through line: unchanged, unambiguous.
- Map duty: no new command; `/odeo:research` is on `docs/system-map.md`.

## Loop status
At max, so the loop stops on condition 1 with nothing left in form. Not covered by this
gate and still owed:
- Behavioural evidence: 7d8de9e (step 1, the step 5 shape, step 5b) and the rewording of
  the contract and Rules lines were never in the A/B. Per the standard's testing duties
  they belong to `/odeo:improve` subagent testing.
- The rubric's calibration (two scorer pairs agreeing) was done on f947223. Its anchors
  have since been clarified in 914009a, 213733b and c2ca2a2, so a recalibration result on
  the current text is what would back the agreement claim now.

## History
- 2026-10-02 (v1, Round 1, f947223): first record. 8/10 PASS. Structure 1 (SKILL.md did
  not name or dispatch the rubric, the shapes diverged), precision 1 (undefined boundary
  terms, anchors that left some cases unscored).
- 2026-10-02 (v2, Round 2, 914009a): 8/10 PASS. Structure 1 -> 2. Worked example 2 -> 1 (the
  unchanged example broke the new Answer rule). Precision 1 -> 1 with new conflicts, three
  introduced by the round 1 fixes; the class was named and a structural fix proposed.
- 2026-10-02 (v3, Round 3, 213733b): 7/10 FAIL. The structural fix landed. Safety 2 -> 1
  (step 5b's commit named no branch, from round 2 Top fix 8). Worked example stayed 1.
  Precision stayed 1 (criteria 2 and 7 used the old broad "unverified"; criteria 2 and 5
  disagreed on where the confidence word goes). This was the last round under the cap.
- 2026-10-02 (v4, Round 4, c2ca2a2, past the cap on the human's explicit decision): 9/10
  PASS. Worked example 1 -> 2 (real RES-002 excerpt, verified verbatim). Safety 1 -> 2.
  Precision stayed 1 on two closing statements about RES-002, one inaccurate and one uncited.
- 2026-10-02 (v5, Round 5, eb7e7cb, re-anchor past the cap under the round 4 decision):
  10/10 PASS, previous 9/10. Precision 1 -> 2: the closing sentence now matches RES-002 and
  the uncited threshold claim is dropped. Nothing else in `skills/research/` changed;
  confirmed by re-reading both files, since this reviewer cannot run git. The branch moved
  for a lint fix (C18 fails closed) outside this record's scope.
  Trajectory: 8 -> 8 -> 7 -> 9 -> 10.
