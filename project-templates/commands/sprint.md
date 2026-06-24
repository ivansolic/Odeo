---
description: Build one or more ready user stories with agents. You pick single or parallel agents and how much oversight; each agent takes a story end-to-end (plan, TDD build, verify acceptance criteria, review) in its own git worktree, then presents for your approval before merge. Hybrid: agents do the work, you hold the gates.
---

Hybrid agentic build. You turn two dials, agents do the middle, you approve at the
gates. Invoke once; dispatch and the per-story pipeline run automatically.

## 1. Identify the stories
Ask which stories to build (paths in `docs/stories/`), or use the ones named.
For each, confirm it is ready: has a description and testable acceptance criteria.
If a story is not ready, stop and say what is missing.

## 2. Independence check (before parallel)
Inspect whether the chosen stories touch overlapping files/modules. If they
overlap, WARN and recommend sequential (parallel risks merge conflicts). Parallel
is only safe for independent stories.

## 2b. Propose a build order (by dependency)
Order the chosen stories by **technical dependency**: what must exist first (for
example a data model before a feature that uses it, an API before the UI that
calls it). Present the proposed order and let the user adjust. This is build
sequencing, not feature prioritization (priority/value is a PM decision, done
earlier with pm-skills). In sequential mode the order is the build queue; in
parallel mode, dependent stories must not run at the same time.

## 3. Dial 1, how many agents
Ask:
> "One agent (sequential, one story at a time) or parallel (one agent per story)?"

## 4. Dial 2, how much oversight
Ask:
> "Approve each plan before building, or run autonomous to presentation?"
Default to plan-gated when the user is unsure or the work is risky.

## 5. Dispatch
Dispatch the **`story-builder` agent**, one instance per story, each in its own
**git worktree + branch** (Claude Code's built-in agent worktree isolation; for
parallel, run them as background agents). The `story-builder` agent runs the full
per-story pipeline: read story, consult `knowledge/`, confirm a green baseline,
plan (gated or autonomous), TDD build + ux-design for UI, verify every acceptance
criterion, return a result.

Then run `code-reviewer` (and `design-reviewer` if the change has UI) on each
returned result. Fix Critical and Important findings.

(Reviewers run on each result before it is presented. Keep nesting shallow: the
story-builder builds and self-verifies, then the reviewers run on its diff.)

## 6. Present back (per story)
For each finished story, present:
- What it built (summary + diff)
- Acceptance criteria walkthrough (pass/fail each)
- Reviewer verdicts (code-reviewer, design-reviewer): Critical / Important / Nitpick
- Decisions and assumptions the agent made
- Which `knowledge/` entries it reused (if any)

## 7. Gate (your approval)
For each story: you approve, then open/merge the PR following `/commit-push` rules;
or you request changes, and the agent revises and re-presents. **Never merge without
your approval.** Respect the ask-before-push rule.

## 8. Compound
After approval, capture each non-trivial, verified solution with `/compound` (its
quality gate applies). This is how the system gets smarter per story.

## Safety rules
- Parallel only for independent stories; one story = one branch = one PR.
- Never merge without explicit approval.
- Your review is the bottleneck: N parallel agents = N presentations you approve in turn.
- While learning: start single + plan-gated (max oversight), raise to parallel + autonomous as trust grows.
- Uses built-in agents (worktree isolation, background, notifications), not a custom orchestrator.
