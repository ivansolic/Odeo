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

## 3. Dial 1, how many agents
Ask:
> "One agent (sequential, one story at a time) or parallel (one agent per story)?"

## 4. Dial 2, how much oversight
Ask:
> "Approve each plan before building, or run autonomous to presentation?"
Default to plan-gated when the user is unsure or the work is risky.

## 5. Dispatch
For each story, work in an **isolated git worktree + branch** (use Claude Code's
built-in agent worktree isolation; for parallel, dispatch background agents, one
per story). Each agent runs the full per-story pipeline:
1. Read the story fully. Consult `knowledge/` (compound) for documented solutions to reuse.
2. If plan-gated: draft the implementation plan in `todo.md` and wait for approval. If autonomous: proceed.
3. Build: TDD for logic (the `test-driven-development` skill), `ux-design` skill + design tokens for UI. Follow CLAUDE.md (stack, conventions, security baseline).
4. Verify every acceptance criterion, one by one.
5. Run `code-reviewer` (and `design-reviewer` if the change has UI) on the result. Fix Critical and Important findings.

(Reviewers run on each agent's result before it is presented. Keep nesting shallow: an agent builds and self-verifies, then the reviewers run on its diff.)

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
