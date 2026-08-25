---
artifact: skills/build/SKILL.md
type: skill
branch: fix/build-model-effort-source
reviewed_commit: e0ce263
artifact_version: 15
date: 2026-08-25
scorer: skill-reviewer
model: claude-opus-4-8
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/build/SKILL.md` (327 lines) plus its format contract
`docs/plan-format.md`, read against `AGENTS.md:40-110` (the model policy, effort
precedence, and the "report WITH source, as CONFIGURED not confirmed" rule) and
`docs/skill-authoring-standard.md`. The delta under review is one commit
(`main..e0ce263`) closing two follow-ups the round-14 record named as next-edit
material: FU4a (the sub-high nudge on a configured value) and FU4b (the written
model-source duty + the `plan-format.md:24` overclaim). Whole-surface grep run for
a read `model_plan:` model WITHOUT its source tag (the "stale example far from the
rule" failure mode). `docs/system-map.md` checked for the map duty. Orchestrating
session, not an isolated builder, so `build_model_as_dispatched` is omitted by
construction.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` with a description that says
  what the user gets and shows the non-obvious invocation ("Name several stories to
  build them in parallel, e.g. \"/build USR-001 USR-002 in parallel\""). Untouched this
  branch; correct format for an explicit command.
- structure **2**. Body shape intact (essence, enforced spec gate, mode choice, both
  modes, worked example, after-building, safety rules); 327 lines against the 500 limit;
  no supporting files, so one-level-deep is trivially satisfied. Regression discipline:
  round 14 set a mechanical trigger for dropping this to 1, structure drops when the
  model-plan block passes 75 lines OR 25% of the file, or gains a new subsection not
  tied to a named finding. Today the block (`:37-111`) is exactly 75 lines and ~23% of
  the file, and the edits are inline responses to findings 1 and 2, so no trigger fires
  and I am not charging a point for compliance. But it is now SITTING ON the 75-line
  edge: the next inline addition to this block trips the trigger. The standing structural
  fix (lift `:37-111` into its own `## 3. Model plan`, or move the resolution mechanics
  to a supporting file) is now overdue, carried below.
- worked example **2**, and it improved. Round 14 named one omission, the example never
  showed the step-2 model branch, so the model-source label was stated but never
  demonstrated. `:299` now shows it: `model_plan: judgment <session model> (per session
  environment) effort high (configured, per CLAUDE_EFFORT)`, delivering `:66`'s promise
  concretely. Real story id, real paths, real verdict shape, directly imitable.
- precision **2**. Both round-14 Mediums are closed IN TEXT, not by interpretation.
  (1) FU4a, `:102-111`: "A CONFIGURED value below the bar counts the same as a confirmed
  one here (a read `medium` effort, or a session model below the strongest): raise it
  WITH its source so the user can confirm or correct, rather than stay silent because the
  value was read and not stated". This is exactly the fix round 14 prescribed at `:98`;
  the read-vs-ask asymmetry that split two agents on the nudge is gone. (2) FU4b,
  `:91-100`: the written duty is now IDENTICAL for both fields, "an effort READ in step 2
  is written `effort high (configured, per CLAUDE_EFFORT)`, and a judgment model READ
  from the session rather than resolved live in front of the user is written
  `judgment <model> (per session environment)`... When either was stated by the user,
  write it plain, no source tag." The provenance gap round 14 named at `:92-96` is
  closed. Exact commands/paths throughout (`spec-gate.sh`, `boundary-check.sh`,
  `git worktree add`, `code -r -g`, exact frontmatter keys); no placeholders, no TBDs.
- safety integration **2**. References, never restates. `:56-57` delegates the source
  list to AGENTS.md ("never keep a second copy of it here"); the FU4a clause is
  consistent with `AGENTS.md:88` ("reported WITH its source and as CONFIGURED, never as
  confirmed") and `:50-51` (name the stronger model when the session is not strongest);
  `:88` cites Guardrail 3 / lint C11; `:246` cites `merge-gate.sh`'s comparison; the spec
  gate is enforced and never worked around. No guardrail copied or weakened.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: explicit command (trigger
clarity can be 2), real guardrails to reference (safety integration can be 2), concrete
worked example present.

## The four verification points (checked, not taken on faith)
1. **`:66` promise delivered, whole surface clean.** The new duty (`:91-100`) and the
   worked example (`:299`) now carry the model's source tag into `model_plan:`'s
   `judgment:` child. Grep of both files for `judgment`/`model_plan`/`per session`/
   `configured`: every `judgment:` value that is a READ carries `(per session
   environment)` (SKILL `:299`; plan-format `:25`, `:31`); none appears untagged. No
   stale example 200 lines from the rule. Delivered.
2. **FU4a consistent with AGENTS.md.** "Configured value below the bar counts, raised
   with source" neither touches nor contradicts the effort read-order/precedence
   (`AGENTS.md:74-90`) and matches the "as CONFIGURED not confirmed" rule (`:88`) and the
   sub-strongest model-nudge duty (`:50-51`). Consistent.
3. **`plan-format.md:24` correction accurate.** `SKILL.md:44-48` shows step 2 READS the
   model from the session-start environment (source 2 of the model order), so "resolved
   LIVE when the plan is written" was an overclaim; "AS OF when the plan is written" is
   accurate, and `SKILL.md:96` mirrors it verbatim in spirit ("READ from the session
   rather than resolved live in front of the user"). The two docs agree; the judgment
   child in plan-format (`:25-31`) states the SAME both-fields duty with both example
   tags.
4. **No new divergence; the old one is removed.** For a read model + read effort, a
   stated model + stated effort, and both mixed cases, the per-field duty at `:92-98`
   ("this duty is the SAME for both fields... When either was stated by the user, write
   it plain") makes two agents write the identical block. I tried to construct a
   diverging pair against each new clause and could not land one on the written artifact.
   The fix DELETES the round-14 nudge divergence rather than opening a new one.

## Minor seams (none block; none move a score)
- **Spoken vs written wording for the model source.** The spoken qualifier is "per the
  session-start environment" (`:48-49`); the written tag is "(per session environment)"
  (`:97`, `:299`, `plan-format.md:31`), dropping "start". Both are given as literal
  templates, so no agent has to invent and the written block does not diverge, but a
  reader could wonder if they are the same source (they are: model-order source 2). One
  word aligns them.
- **The worked example's spoken line omits the model source.** `:293` speaks
  "<the model the session is running now>" with no qualifier, while its own written block
  at `:299` tags the model. For a read model the spoken side should also carry the
  qualifier per `:48-49`. A teaching looseness inside one example, not a divergence.
- **Carried-forward Low (not this branch's job, not a regression).** Round 14's finding 3
  stands: step 1 of the effort order (a live `/effort` value) still has no spoken literal
  of its own and every template in the block is a step-2 "configured" one, so an agent
  must infer "per your `/effort`" / confirmed-not-configured. This branch scoped FU4a and
  FU4b only; the Low was Low before and remains Low.

## Integrity
No sign of text copied from another project. Voice is this system's; every cross-reference
(`AGENTS.md` Guardrail 3, lint C11, `plan-format.md`, `merge-gate.sh`, `spec-gate.sh`,
`boundary-check.sh`) resolves inside this repo.

## Map duty
No command surface added or altered; `/build` and `spec-gate.sh` already sit on
`docs/system-map.md`. Not a finding.

## Top fixes (all next-edit polish, none a blocker)
1. Structure (overdue): lift `:37-111` into its own `## 3. Model plan`, or move the
   resolution mechanics to a supporting file. The block is now exactly on the 75-line
   trigger; the next inline edit costs the point.
2. Align the spoken model qualifier with the written tag (`:48-49` "session-start
   environment" vs `:97`/`:299` "session environment"), one word.
3. Show the model source qualifier on the worked example's SPOKEN line (`:293`) so the
   example is internally consistent for a read model.
4. Carried Low: give step-1 effort its own spoken literal ("effort high, per your
   `/effort`", confirmed not configured) at `:53-54`.

## Behavioral confirmation still owed
Form verification only. Whether an agent actually raises the nudge on a configured
sub-high value, and writes the model tag only for a session-read model (plain for a
`/model`-set one), is an `/improve` subagent test. The form is good enough to test; the
matrix case worth running is the exact round-14 split (`CLAUDE_EFFORT` unset,
`effortLevel: medium` in the user file, session model below strongest), where both agents
should now converge on raising the point with its source.

## Vs previous version
Round 14 (2f1c8b9, fix/effort-readable-sources) -> this round (e0ce263,
fix/build-model-effort-source), per criterion: trigger clarity 2 -> 2, structure 2 -> 2,
worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total 10 -> 10.
The score held at the ceiling, but the two Mediums round 14 handed forward as next-edit
material are now CLOSED in text: FU4a (`:102-111`) removes the nudge divergence, FU4b
(`:91-100` + `plan-format.md:24`) removes the written provenance asymmetry and corrects
the "resolved LIVE" overclaim. The recurring cause round 14 flagged ("a duty stated for
one value and silent for its twin") is resolved this round by making the duty explicitly
per-field for BOTH the model and the effort, rather than by splitting the block, so the
structural pressure it warned about is now the leading open item (Top fix 1). Nothing
blocks merge.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL.
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS.
- Round 9 (2026-08-07, Opus 5, strongest, 995fde4): 10/10 PASS.
- Round 10 (2026-08-07, Opus 5, strongest, 0fcc65b): 10/10 PASS, regeneration.
- Round 11 (2026-08-07, Opus 5, strongest, 895b667): 10/10 PASS, regeneration.
- Round 12 (2026-08-10, Opus 5, strongest, sha NOT SUPPLIED): 8/10 PASS, incomplete record.
- Round 13 (2026-08-10, Opus 5, strongest, b8f7de7): 9/10 PASS.
- Round 14 (2026-08-10, Opus 5, strongest, 2f1c8b9): 10/10 PASS. Two Mediums handed
  forward: a configured sub-high effort not clearly tripping the nudge (`:98`), and the
  model's source spoken but not written into `model_plan:` (`:92-96`).
- Round 15 (2026-08-25, Opus 4.8, strongest, e0ce263, branch fix/build-model-effort-source):
  10/10 PASS. This record REPLACES round 14's. Both round-14 Mediums CLOSED: FU4a
  (`:102-111`, configured value below the bar trips the nudge, raised with source) and
  FU4b (`:91-100` per-field written duty + `plan-format.md:24` "resolved LIVE" -> "AS OF
  when the plan is written", + worked example `:299` now shows the model tag). No new
  divergence introduced; the four verification points all pass. Residuals are polish
  (structure on the 75-line edge, spoken/written wording, one carried Low). Nothing
  blocks merge.
