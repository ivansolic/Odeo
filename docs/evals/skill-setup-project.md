---
artifact: skills/setup-project
type: skill
branch: refactor/cut-build-half
reviewed_commit: 86b93ea
artifact_version: 2
date: 2026-10-28
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 2, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 6/10
---
# Skill review: setup-project (auto-invoked), USR-009, round 2

Output language: en (handed at dispatch). Tier note: `strong` is declared because the
judging model is Opus class, which is "sonnet class and up"; whether it is the top tier on
this subscription was not verified live, so `strongest` is not claimed.

Inputs read: `skills/setup-project/SKILL.md` (187 lines, no supporting files), and
`docs/removed-items.txt` and `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Model policy and Guardrails 3,
as in round 1. No shell: I read the working tree and cannot prove it equals 86b93ea; that
equivalence rests on the dispatcher's sha.

## Scores
- trigger clarity: 2, "Use when a project needs configuring: a new project before any building, CLAUDE.md still full of placeholders, or the user asks to set up or reconfigure the project, its stack, commands, or conventions."
- structure: 2. The Process now runs 0, 1, 2 (Interview), 3 (Fill in CLAUDE.md), 4 (Confirm), and line 38 points to "(step 2)". The other sections are essence (lines 5-7), when-not (step 0) and Safety Rules. The file is 187 lines with no supporting files.
- worked example: 1. The skill has scripted prompts (lines 13-16, 61-74, 97-105) and value formats (`dev_rigor: tdd | tdd-lite | test-after`). It still has no example run that turns real answers into the written CLAUDE.md lines.
- precision: 2. No item on `docs/removed-items.txt` is named any more:
  - line 79 now reads "(critical, whoever builds the project runs exactly these)"
  - "The architect and builder read it." is gone
  - the builder-tier aside is gone
  - the closing TDD-skill sentence is gone

  Every command, script and file it names exists: `/odeo:brainstorm`, `/odeo:prototype`, `/odeo:start`, `init-project.sh` and `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`.
- safety integration: 2. Four references, and no contradiction remains:
  - "(This choice is for judgment work; see ${CLAUDE_PLUGIN_ROOT}/AGENTS.md Model policy.)" (line 114). The "pinned" wording that contradicted Guardrails 3 is gone.
  - "This only sets the ORDER in which tests are written; it is recorded for whoever builds the project." (lines 104-105) replaces the promise that no shipped mechanism kept.
  - the security baseline (section J)
  - "Never overwrite a CLAUDE.md that's already filled without explicit confirmation" (line 186)

  Line 94 ("All three styles ALWAYS end with tests + review + the security baseline") says the same thing as the shipped AGENTS.md Guardrails 3 ("Dev rigor ... is never skipped") and does not contradict it. Whether that baseline should still apply to a product-only plugin is USR-015's question.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10, not reached in this story
The last point is a worked example. It belongs to USR-012, because the interview it would
illustrate is about to be rewritten when setup-project merges into `setup`. An example
written now would describe text that is about to change. This is why this round stops
short of 10, and it is a scope decision, not a structural cap.

## Findings
None that block. Carried to USR-012, unchanged from round 1:
1. A worked example: one short run from real answers to the written Conventions lines, for example `dev_rigor: tdd-lite`, `teach_me_as_i_go: yes`, `output_language: de`.
2. Whether a product-only plugin should still ask the build-facing groups at all: B Frontend, C Backend, D Tooling, E Architecture, F Commands, H dev rigor. The same goes for "teaching comments in built code" (lines 131-133), the map decision point at `docs/system-map.md` line 139, and "before any building" in the description.
3. The `project-templates/CLAUDE.md` design section still points to the removed `/odeo:setup-design` and `/odeo:deploy`. Step 3 does not list that section, so its placeholders survive setup. The template is outside this skill's file. Hand it to USR-012 or USR-022.

## Map duty
The story adds no command. The `/odeo:setup-project` row (`docs/system-map.md` line 23) matches the current behavior.

## Integrity
Odeo's own skill, not a community contribution; no copied text was found.

## Behavior
I reviewed form only. A short `/odeo:improve` subagent run on two cases would confirm the EXISTING path dispatches nothing:
- an empty folder
- a folder with a `package.json`

## Vs previous version
Trajectory: 6/10 -> 9/10.
- Structure 1 -> 2: the steps were renumbered.
- Precision 1 -> 2: the four sentences naming removed items were replaced or deleted.
- Safety integration 1 -> 2: the "pinned" contradiction and the unkept "nothing merges" promise are gone, and the AGENTS.md reference stays.
- Worked example unchanged at 1, deferred to USR-012.

## History
- 2026-10-28, round 1: FAIL 6/10 at 1e7bb4b.
- 2026-10-28, round 2: PASS 9/10 at 86b93ea, after the fixes in cc1d20c.
