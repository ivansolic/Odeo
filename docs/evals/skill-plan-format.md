---
artifact: docs/plan-format.md
type: skill
branch: feature/plan-human-layer
reviewed_commit: 4f001fa
artifact_version: 2
date: 2026-10-01
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 7/10
---

Scope: the human-layer change on `feature/plan-human-layer` at `4f001fa`, read as the format
sources of `/odeo:build` B5 and the `architect`: `docs/plan-format.md` (all 299 lines),
`global/CLAUDE.md:29-46` (`### Plan shape (human layer first)`) and `AGENTS.md:204-206`.
Seams read: `skills/build/SKILL.md` B5.3 (`:232-242`), `agents/architect.md:37-44`,
`agents/architecture-reviewer.md:27-31`, `scripts/set-global-language.sh` (where the template's
running `--overwrite` example actually lives). This record REPLACES round 1's (`d995419`, 7/10
FAIL). `effort: high` is the value declared in this agent's frontmatter, not an observed
runtime value. The suite and lint results are the dispatcher's statements; I hold no shell and
did not run them. These are format documents, not a SKILL.md with a description, so trigger
clarity is scored as "does each file say when its rule applies".

## Skill: plan-format human layer  (format source for an explicit command, /odeo:build B5)

## Scores
- trigger clarity: 2, `docs/plan-format.md:23` "A plan has two readers: the human at the
  gate ... and the builder"; `AGENTS.md:205-206` says which file shapes which plan.
- structure: 2. The order the text states now matches the template. `:25-27` "then the
  TECHNICAL layer (Header through Risks / open questions), then Review Focus, VERIFICATION
  (the Success signal) and Out of scope, in the order of the template below"; the template
  runs Do-not-touch `:172`, Risks `:178`, Review Focus `:181`, Success signal `:187`, Out of
  scope `:194`. `agents/architect.md:41-42` lists the same order. Both `Plan layers:` lines
  (`plan-format.md:21`, `global/CLAUDE.md:30`) are unchanged and identical. 299 lines.
- worked example: 2. Every new section has real values from the template's own running
  example: Summary `:77-84`, Why `:89-90`, Explanation `:96-99`, Review Focus `:185`, Out of
  scope `:196`. A reader can copy them directly.
- precision: 1. The rules are now exact and agree across all three files (Review Focus may be
  `none` at `plan-format.md:183-184`, `:202`, `:293` and `global/CLAUDE.md:39-40`; "five items,
  each short" at `global/CLAUDE.md:31`). The point is lost inside the example, which breaks
  two of this file's own rules:
  (a) `:185` "An invalid project value could still be reported with scope `project`" restates
  the C1 invariant at `:136-137` ("an invalid project value reports scope `global`, never
  `project`"). An invariant in a contract is something the tasks test, and `:183` says Review
  Focus is "Not a restatement of the tasks". So the one Review Focus example is the kind of
  entry criterion 6 at 2 (`:292-293`) rules out.
  (b) The human layer does not match its own technical layer, which criterion 6 scores 1
  (`:288` "disagreeing with the technical layer"). Summary `:79` says "a new `/odeo:language`
  command; nothing else changes". But `:81-82` and Explanation `:98-99` describe a changed
  replace behavior (`--overwrite`), and the File map `:141-143` lists no file that carries it
  (in this repo it is `scripts/set-global-language.sh`). Also, `:83-84` quotes the output as
  "German, set for this project", while C1 `:125` says it prints exactly `<code> <scope>`, i.e.
  `de project`. The quotation marks make the paraphrase look like real output.
- safety integration: 2. `plan-format.md:29-30` "The human layer is NOT contract: where it
  and the technical layer disagree, the technical layer wins and the disagreement is a finding
  for the plan review". Session plans now get the same rule at `global/CLAUDE.md:43-44`. A
  named reviewer holds it (`agents/architecture-reviewer.md:27-31`). Guardrails are cited,
  not restated.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10. Nothing caps a criterion; the lost point is two example edits.

## Round-1 fixes, verified
1. Order: CLOSED (structure above).
2. Worked example: CLOSED, but with the two slips scored under precision.
3. Review Focus `none` and "five items": CLOSED in all three places, including criterion 6
   "or is `none` with a reason the story bears out" (`:293`).
4. B5.3 points at the Summary: CLOSED (`skills/build/SKILL.md:232-234`), scored in
   `docs/evals/skill-build.md`.
5. A reviewer that holds the rule, plus the session-plan precedence line: CLOSED
   (`agents/architecture-reviewer.md:27-31`, `global/CLAUDE.md:43-44`). The agent text itself is
   agent-reviewer's to score.
6. AGENTS.md summary now names "the risk, every decision you make" (`:204`): CLOSED.

## Top fixes
1. Replace the Review Focus example at `:185` with a failure no task tests, for example:
   "- Run from a subfolder, `/odeo:language` may find a different project than the document
   writer does, so both pass their own tests and still disagree."
2. Make the running example agree with itself:
   - Add a File map row: `scripts/set-global-language.sh   MODIFY: --overwrite replaces an
     existing value; without it the file is unchanged`.
   - Change Summary `:79` to "a new `/odeo:language` command, and a language you already set is
     replaced only when you ask for it".
   - Change `:83` to drop the quotation marks: "in a project set to German it reports German,
     set for this project".
   This way the canonical example passes the criterion 6 it teaches.
3. Cosmetic: `plan-format.md:27` breaks mid-sentence after "The"; `AGENTS.md:205` is unwrapped
   at about 120 characters. Rewrap both.

## Behavioral follow-up
Whether `architecture-reviewer` actually flags a story deviation left only in Design decisions
(the round 2 A/B gap) is behavioral. Run `/odeo:improve` on `agents/architecture-reviewer.md`
with a plan seeded that way.

## Not scored (pre-existing, outside this change, raised with Ivan by the dispatcher)
`global/CLAUDE.md:17` "default off" vs `AGENTS.md:203` "default on" for the technical aside.

## Integrity
No sign of text copied from another project.

## Map duty
No command added; `docs/system-map.md` needs no change.

## Vs previous version
Round 1 (`d995419`) 7/10 FAIL -> round 2 (`4f001fa`) 9/10 PASS. Structure 1 -> 2 (order fixed),
worked example 1 -> 2 (examples added), precision 1 -> 1 (the cross-file Review Focus conflict
closed, the new example's two slips opened), trigger and safety 2 -> 2. No regression.

## History
- Round 1 (2026-10-01, Opus 5.5 [1M], strongest, d995419): 7/10 FAIL. Layer order did not
  match the template, the human layer had no example, Review Focus `none` conflicted across
  files, and B5.3 and the plan reviewer did not point at the Summary.
- Round 2 (2026-10-01, Opus 5.5 [1M], strongest, 4f001fa): 9/10 PASS. All six round-1 fixes
  closed. Two LOW example slips remain (Review Focus restates an invariant; the Summary does
  not match the technical layer on `--overwrite`).
