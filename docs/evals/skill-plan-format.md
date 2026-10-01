---
artifact: docs/plan-format.md
type: skill
branch: feature/plan-human-layer
reviewed_commit: e5dbea0
artifact_version: 3
date: 2026-10-01
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

Scope: the human-layer change on `feature/plan-human-layer` at `e5dbea0`, read as the format
sources of `/odeo:build` B5 and the `architect`: `docs/plan-format.md` (Structure `:19-30`,
template `:68-203`, Rules, rubric criterion 6 `:293-299`), `global/CLAUDE.md:17` and `:29-46`,
and `AGENTS.md:196-207`. Seams read: `agents/architecture-reviewer.md:28-32`,
`skills/build/SKILL.md:141` and `:232-235`. This record REPLACES round 2's (`4f001fa`).
`effort: high` is the value declared in this agent's frontmatter, not an observed runtime
value. The suite and lint results are the dispatcher's statements; I hold no shell and did not
run them. These are format documents, not a SKILL.md with a description, so trigger clarity is
scored as "does each file say when its rule applies". This is round 3 on this artifact, the
loop's cap.

## Skill: plan-format human layer  (format source for an explicit command, /odeo:build B5)

## Scores
- trigger clarity: 2, `docs/plan-format.md:23` "A plan has two readers: the human at the
  gate ... and the builder"; `AGENTS.md:206-207` says which file shapes which plan.
- structure: 2, `:25-28` "TECHNICAL layer (Header through Risks / open questions), then
  Review Focus, VERIFICATION (the Success signal) and Out of scope, in the order of the
  template below". The template matches: Risks `:183`, Review Focus `:186`, Success signal
  `:193`, Out of scope `:200`. Both `Plan layers:` lines are identical. `:27-28` is rewrapped.
- worked example: 2, real values in every human-layer section (`:79-87`, `:92-93`,
  `:99-102`, `:190-191`, `:202`).
- precision: 1. Both round-2 slips are closed. The Review Focus example `:190-191` is now a
  failure between parts that no single task tests. The Summary `:81-82`, the Explanation
  `:101-102`, the Design decision `:118-119` and the new File map row `:147-148` now agree on
  `--overwrite`. `:86` no longer quotes output that C1 does not print.
  One more instance of the same class remains, which I missed in round 2. The Summary's "How
  we will know it works" (`:86-87`, "in a project set to German it answers that German is set
  for this project") does not match the Success signal, which is the VERIFICATION layer it
  stands for in plain words. The only row there (`:198`) is `"a newly generated PRD body is in
  German" | bash tests/localized-prose.test.sh`, a criterion and a test from a different story.
  The File map's test for this plan is `tests/language-status.test.sh` (`:145`). So the
  canonical example would score 1 on its own criterion 6 (`:294` "disagreeing with the
  technical layer").
  The new decision class (`:73-76`, "every open question in Risks, and every Design decision
  that changes what the user gets or departs from the story's wording ... A purely technical
  decision (how, not what) stays in Design decisions alone") is exact. It is defined once, and
  `agents/architecture-reviewer.md:28-31` defers to it ("as written in ... plan-format.md,
  which wins") without making it a second, competing definition.
- safety integration: 2, `:29-30` "the technical layer wins and the disagreement is a finding
  for the plan review", the session-plan copy at `global/CLAUDE.md:43-44`, and a named holder
  (`agents/architecture-reviewer.md:28-32`). No guardrail restated.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10. Nothing caps a criterion structurally; the missing point is one table row.

## Round-2 fixes, verified
1. Review Focus example: CLOSED (`:190-191`).
2. Summary/File map/quote coherence on `--overwrite`: CLOSED (`:81-87`, `:147-148`).
3. Rewraps: CLOSED (`plan-format.md:27-28`, `AGENTS.md:204-207`).
4. Decision class defined once: verified, see precision.
5. The `global/CLAUDE.md:17` "default on" decision: it now matches `AGENTS.md:203`. The
   pre-existing contradiction is gone.

## Residual (the loop stops here)
Why the ceiling is not reached: the running example's Success signal row (`:198`) belongs to
another story. So the example's human layer and its verification layer disagree, the defect
criterion 6 exists to catch.

Two of the stop conditions in `docs/eval-framework.md` hold:
- the cap: this is round 3;
- a repeated class: round 2 and round 3 both found an "example's human layer disagrees with
  its own technical layer" defect.

The residual as it stands, LOW: one table row in an illustrative template; no rule is wrong.
The fix, if wanted, is exact:
`| "shows which language is in force and where it comes from" (USR-00X) | bash tests/language-status.test.sh |`
It is not applied here. The decision is the human's:
- (a) accept the residual and merge at 9/10 PASS;
- (b) apply the one-row fix and have this reviewer regenerate the record, a confirmation pass
  outside the capped loop;
- (c) leave it for a later batch.

Trajectory: `d995419` 7/10 FAIL -> `4f001fa` 9/10 PASS -> `e5dbea0` 9/10 PASS. Over the three
rounds: the layer order was fixed, a human-layer example was added, Review Focus `none` was
reconciled, B5.3 and the plan reviewer now point at the Summary, the example was made coherent
on `--overwrite`, and the decision class is defined once.

## Behavioral follow-up
Whether `architecture-reviewer` flags a Design decision that changes what the user gets but is
missing from `What you decide`, and leaves a purely technical one alone, is behavioral. Run
`/odeo:improve` on `agents/architecture-reviewer.md` with one plan seeded with each case.

## Integrity
No sign of text copied from another project.

## Map duty
No command added; `docs/system-map.md` needs no change.

## Vs previous version
Round 2 (`4f001fa`) -> round 3 (`e5dbea0`): every criterion unchanged (2/2/2/1/2), total 9 -> 9.
Both round-2 precision slips are closed. The remaining point is a third instance of the same
class, present at `4f001fa` and missed then. No regression.

## History
- Round 1 (2026-10-01, Opus 5.5 [1M], strongest, d995419): 7/10 FAIL. The layer order did not
  match the template, the human layer had no example, Review Focus `none` conflicted across
  files, and B5.3 and the plan reviewer did not point at the Summary.
- Round 2 (2026-10-01, Opus 5.5 [1M], strongest, 4f001fa): 9/10 PASS. All six round-1 fixes
  closed. Two LOW example slips (Review Focus restated an invariant; the Summary did not match
  the technical layer on `--overwrite`).
- Round 3 (2026-10-01, Opus 5.5 [1M], strongest, e5dbea0): 9/10 PASS. Both slips closed. The
  loop stopped at the cap with one LOW residual (the Success signal row belongs to another
  story), handed to the human.
