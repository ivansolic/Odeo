---
artifact: docs/plan-format.md
type: skill
branch: feature/plan-human-layer
reviewed_commit: d995419
artifact_version: 1
date: 2026-10-01
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 1, worked_example: 1, precision: 1, safety_integration: 2 }
total: 7/10
verdict: FAIL
---

Scope: the human-layer change on `feature/plan-human-layer` at `d995419`, read as the format
sources of `/odeo:build` B5 and the `architect`: `docs/plan-format.md` (Structure intro
lines 19-29, template lines 67-83 and 172-177, Rules lines 181-183, rubric criterion 6 lines
268-274), `global/CLAUDE.md` lines 29-43 (`### Plan shape (human layer first)`), and
`AGENTS.md` lines 204-206. Seams read: `skills/build/SKILL.md` B5.2-B5.3 (lines 215-241),
`agents/architect.md` lines 37-45, `agents/architecture-reviewer.md` lines 12-26,
`scripts/skills-lint.sh` C15 and C17. Standard: `docs/skill-authoring-standard.md`. No prior
record for this artifact. `effort: high` is the value declared in this agent's frontmatter,
not an observed runtime value. These are format documents, not a SKILL.md with a
description, so trigger clarity is scored as "does each file say when its rule applies".

## Scores
- trigger clarity: 2, `docs/plan-format.md:23` "A plan has two readers: the human at the
  gate ... and the builder"; `AGENTS.md:205-206` names which file shapes which plan
  ("`docs/plan-format.md` for `/odeo:build` plans and `global/CLAUDE.md` for session plans").
  The global section sits under `### Plan Mode First`, so its scope is set by placement.
- structure: 1, the stated layer order contradicts the template. `docs/plan-format.md:25-26`
  says "then the TECHNICAL layer (Header through Do-not-touch), then Review Focus,
  VERIFICATION (the Success signal) and Out of scope", and line 21 orders "Technical,
  Review Focus, Verification, Out of scope". The template puts `## Success signal` (line 156)
  BEFORE `## Do-not-touch boundaries` (163), i.e. inside "Header through Do-not-touch", and
  before Review Focus (172), not after it. `## Risks / open questions` (169) falls after
  Do-not-touch and belongs to no layer. Session plans (`global/CLAUDE.md:30`, Verification
  after Review Focus) and build plans (template, Verification before it) therefore have
  different shapes while C17 reports one list. C17 checks names, not this, so it stays green.
- worked example: 1, every other template section shows real values (`--overwrite` at
  line 99, `C1: language status line` at 106, the file map at 125-127), but the three new
  sections are angle-bracket placeholders only, e.g. line 68 "What you get: <the outcome in
  one plain sentence, no file names, no jargon>". The standard (line 27) asks for "real
  values (never abstract placeholders)", and `global/CLAUDE.md:31-41` has no example either.
- precision: 1, Review Focus is optional in one copy and mandatory in the other:
  `docs/plan-format.md:183` "Review Focus and Out of scope may be `none` with a one-line
  reason" vs `global/CLAUDE.md:39` "**Review Focus**: 3 to 5 ways this could fail" (and the
  template at `plan-format.md:173` also says "3 to 5" with no `none`). Rubric criterion 6
  at 2 (line 273-274) requires "Review Focus names failure modes", so a reasoned `none`
  is not clearly a 2. `global/CLAUDE.md:31` caps the Summary at "max 5 lines" while
  line 32-33 demands "EVERY open choice and every deviation", which can't both hold on a
  plan with several decisions.
- safety integration: 2, `docs/plan-format.md:28-29` "The human layer is NOT contract: where
  it and the technical layer disagree, the technical layer wins and the disagreement is a
  finding for the plan review" protects the builder contract without restating it;
  line 25 references `AGENTS.md` "Talking to the user" instead of copying it; line 71-73
  puts every decision in front of the human gate. No guardrail is restated or weakened.

## Total: 7/10   ## Verdict: FAIL (threshold 8/10, no zero)

## Ceiling: 10/10. Nothing structurally caps a criterion; each lost point is a small edit.

## Answers to the dispatcher's checks
- Layer lists identical: yes. `docs/plan-format.md:21` and `global/CLAUDE.md:30` are both
  `Summary, Why, Explanation, Technical, Review Focus, Verification, Out of scope`, so C17
  passes. The defect is the ORDER the template actually uses (structure, above).
- "Technical wins": stated at `docs/plan-format.md:28-29`, in the build-plan copy only.
  `global/CLAUDE.md` has no precedence line for session plans (fix 5).
- "Never none" vs the small-story `none` rule: no contradiction inside `plan-format.md`.
  Line 181-183 is the specific rule, and line 184-188 allows `none` only for "sections that
  genuinely do not apply", which the human layer by rule never is. The contradiction is
  across files, on Review Focus (precision, above).
- B5.3 vs the Summary: not a literal contradiction, but it invites one. B5.3
  (`skills/build/SKILL.md:232-233`) has the orchestrator assemble "approach, file map,
  riskiest part, open questions" itself, so the gate gets a second risk statement and a
  second decision list in other words, and "open questions" drawn from Risks can drop a
  story deviation the Summary carries from Design decisions. That is exactly the
  decision-completeness failure the round 2 A/B found. Yes, B5.3 should point at the
  Summary (fix 4).
- House style: no em or en dashes in any of the three files. C15 (`scripts/skills-lint.sh:221-231`)
  covers only `skills/*/*.md` and agents. The bare `AGENTS.md` at `plan-format.md:25`
  matches that file's existing raw-read citations (lines 42, 113) and is correct for a
  supporting doc where `${CLAUDE_PLUGIN_ROOT}` is not substituted. `AGENTS.md:205-206` cites
  plugin-root-relative paths, also correct.

## Top fixes
1. Make the template follow the layer order. Move the `## Success signal` block
   (`docs/plan-format.md:156-161`) to sit between `## Review Focus` and `## Out of scope`, and
   change line 25-26 to "then the TECHNICAL layer (Header through Risks / open questions),
   then Review Focus, VERIFICATION (the Success signal) and Out of scope". Update the
   section list in `agents/architect.md:39-43` to the same order. Neither `Plan layers:`
   line changes, so C17 stays green.
2. Fill the human layer with real values, reusing the template's own running example
   (`language-status.sh`, C1), e.g. under `## Summary for humans`: "What you get: one command
   tells you which language Odeo writes in and where that setting came from. / What changes
   for users: a new `/odeo:language` status line, nothing else. / Biggest risk: it reports
   a different language than the one documents are actually written in. / What you decide:
   approve, plus: an invalid project value reports `global`, not an error (Design
   decision). / How we will know it works: the status line matches `resolve-language.sh`
   in all three scopes." Add one `## Explanation` line in the before -> after -> who
   benefits form. Keep it to one example (standard line 37).
3. Reconcile Review Focus in all three places. `global/CLAUDE.md:39`: "3 to 5 ways this could
   fail that the tasks do not test (on a small task, `none` and why)". `plan-format.md:173`:
   append "or `none` plus one line of why". Criterion 6 at 2 (line 273-274): "Review Focus
   names failure modes the tasks do not already test, or a reasoned `none`". In
   `global/CLAUDE.md:31`, replace "max 5 lines" with "five items, each short", so the
   EVERY-decision rule cannot conflict with a line cap.
4. Point B5.3 at the Summary (`skills/build/SKILL.md:232-233`): "Present the plans for
   approval: lead with each plan's `## Summary for humans` as written (its Biggest risk and
   What you decide ARE the riskiest part and the open questions; do not restate them), then
   the file map and the plan-review trajectory." This edits the build skill, so it needs its
   own skill-reviewer pass on `skills/build/SKILL.md`.
5. Give "technical wins" a holder that is told about it. `agents/architecture-reviewer.md:17-26`
   (plan-review mode) directs the reviewer to rubric criterion 3 only. `plan-format.md:238`
   says the reviewer applies the whole rubric, but the one defect the round 2 A/B found (a
   story deviation only in the technical part) is criterion 6, and the reviewer's own body
   never mentions it. Add one line: "and criterion 6: every Design decision and story
   deviation also appears under `What you decide`, and the human layer does not disagree
   with the technical one". For session plans, add to `global/CLAUDE.md` after line 41: "If
   the Summary and the Technical part disagree, fix the Summary before I approve; the
   Technical part is what you will do."
6. Minor: `AGENTS.md:204-205` says the format "is not restated here" but glosses part of it
   and leaves out the part that matters most ("what you decide"). Either drop the
   parenthetical or make it "(what you get, why, every decision you make, and per change
   before and after)".

## Behavioral follow-up
Fix 5's claim (that the plan review catches a deviation left only in the technical layer)
is behavioral. After fixes 1-5, run `/odeo:improve` on `agents/architecture-reviewer.md` with
a seeded plan that keeps a story deviation only in Design decisions, and check the reviewer
flags it under criterion 6.

## Not scored (pre-existing, outside this change)
`global/CLAUDE.md:17` says the technical aside is "default off", while `AGENTS.md:203`
says "default on, professionals turn it off". One of them is wrong.

## Map duty
No command added, so `docs/system-map.md` needs no change.

## History
- v1 (this record, `d995419`): first review of the human-layer change. 7/10 FAIL.
