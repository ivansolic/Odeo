---
artifact: skills/guide
type: skill
branch: refactor/cut-build-half
reviewed_commit: 86b93ea
artifact_version: 2
date: 2026-10-28
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 8/10
---
# Skill review: guide (auto-invoked), USR-009, round 2

Output language: en (handed at dispatch). Tier note: `strong` is declared because the
judging model is Opus class, which is "sonnet class and up"; whether it is the top tier on
this subscription was not verified live, so `strongest` is not claimed.

Inputs read: `skills/guide/SKILL.md` (49 lines, no supporting files), `docs/system-map.md`,
`docs/removed-items.txt`. No shell: I read the working tree and cannot prove it equals
86b93ea; that equivalence rests on the dispatcher's sha.

## Scores
- trigger clarity: 2, "Use when the user asks how to proceed, ... (\"how do I...\", \"what now\", \"which command\", \"where do I start with X\", \"can this system do Y\", \"how do I build, merge or deploy this\")." The description now holds triggers only. The workflow summary is gone, and the story's build and merge questions are in the trigger list.
- structure: 2. The sections are essence (lines 7-10), numbered Process (13-27), Worked example (29-34), Honest limits (36-43) and Rules (45-49). The file is 49 lines with no supporting files.
- worked example: 2, "Your stories exist (USR-011..014). Route: 1) connect the Atlassian connector once ... 2) then tell me 'create a Jira issue per story in project ABC'".
- precision: 2. Every path and command the body names exists: `${CLAUDE_PLUGIN_ROOT}/docs/system-map.md`, `/odeo:start`, `/odeo:stories`, `/odeo:spec`. Line 17 now reads "(PRDs, stories, research, evals, signals)". The environment-notes section, with its "init/merge" claim, is gone.
- safety integration: 2, "Recommend ONLY what is on the map, never invent commands or capabilities" (line 15), "sending data out always needs your OK" (line 34), "Read-only until an explicit yes" (line 46).

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)
Every criterion is at 2, so the review loop stops here (stop condition 1 in `docs/eval-framework.md`).

## Ceiling: 10/10
Reached.

## Story AC check (USR-009, guide and map)
- "Asked how to build or merge, says Odeo ends with a package ready for delivery": lines 37-40, and the map agrees at line 17.
- "Does not name a removed command": no item on `docs/removed-items.txt` appears in the body. "build, merge, deploy or code-review step" (line 37) names activities, not commands.
- "No system-map row points to a removed item" (PRD-002 R2): still holds. I checked every command, reviewer and script row against the removed list in round 1. This round's commit did not change the map, by the dispatcher's account.

## Findings
None that affect the score.

Minor, carried from round 1 and not caused by this story: `/odeo:guide` has no row of its own in `docs/system-map.md`. It is named only in the header (line 4) and the decision-point heading (line 136). Suggested row for section 1: `| /odeo:guide | Ask how to reach a goal; returns the route through the commands on this map and runs nothing without your yes. |`.

## Map duty
The story adds no command, so no automatic finding. See the minor gap above.

## Integrity
Odeo's own skill, not a community contribution; no copied text was found.

## Behavior
I reviewed form only. Recommended `/odeo:improve` subagent run, with three prompts:
- "how do I build this?"
- "how do I merge my branch?"
- "set up CI for me"

Pass condition: no answer names an item from `docs/removed-items.txt`, and each one ends at the delivery-ready package.

## Vs previous version
Trajectory: 8/10 -> 10/10.
- Trigger clarity 1 -> 2: the workflow summary was deleted and the build, merge and deploy triggers were added.
- Precision 1 -> 2: the environment notes and their "init/merge" claim were deleted, and "plans" became "research".

## History
- 2026-10-28, round 1: PASS 8/10 at 1e7bb4b.
- 2026-10-28, round 2: PASS 10/10 at 86b93ea, after the fixes in cc1d20c.
