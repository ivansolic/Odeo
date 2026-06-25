---
description: Build one or more ready user stories. Two modes you choose: build it yourself (human-first, Claude prepares the branch and you drive), or dispatch agents (each story end-to-end in its own git worktree, you approve before merge). Hybrid agentic build, you hold the gates.
---

The single entry to building. You pick the mode; the system prepares everything.
Invoke once. Replaces the old dev-handoff (its prep is the human-first mode here).

## 1. Identify the stories
Ask which stories to build (paths in `docs/stories/`), or use the ones named.
For each, confirm it is ready: a description and testable acceptance criteria.
If a story is not ready, stop and say what is missing.

## 2. Pick the mode
Ask:
> "How do you want to build?
>  - **Myself (human-first):** I prepare the branch + todo and open the editor; you and I build it together, step by step.
>  - **Agents:** I dispatch a developer agent per story (each in its own worktree); they build end-to-end and present for your approval."

---

## MODE A: human-first (you build, hands-on)
For one story at a time. The safest mode and the right default while learning.
1. Verify the spec is ready (problem, outcome/acceptance criteria, scope). If gaps, say so and ask to fill or proceed.
2. `git checkout main && git pull`, then `git checkout -b feature/<slug>`.
3. Seed `.claude/tasks/todo.md` with the task, context, and key decisions.
4. Open the editor: `code .` (if `code` is missing, say so and skip).
5. Enter plan mode (Shift+Tab twice), draft the implementation plan, you approve, then build together (TDD for logic, ux-design for UI, follow CLAUDE.md + security baseline).
6. Verify every acceptance criterion. Then `code-reviewer` (and `design-reviewer` if UI).
7. Integrate with `/merge` (rebase onto main, tests, merge PR, cleanup).

---

## MODE B: agents (dispatch, you approve)
For one or several stories.

### B1. Independence check (before parallel)
Inspect whether the chosen stories touch overlapping files/modules. If they
overlap, WARN and recommend sequential (parallel risks merge conflicts). Parallel
is only safe for independent stories. Scope by module, not by task.

### B2. Propose a build order (by dependency)
Order the stories by technical dependency (data model before the feature that
uses it, API before its UI). Present it; the user adjusts. This is build
sequencing, not feature prioritization (priority is a PM decision).

### B3. Dials (state the default, make parallel easy to ask for)
Present these as a clear choice, and say what happens if the user just says "go":
- **Sequential vs parallel.** Default is **one story at a time (sequential)**, the
  safe choice. Offer parallel explicitly only when 2+ chosen stories passed the B1
  independence check:
  > "These N stories are independent, so I can build them in parallel (one agent
  >  per story, each in its own worktree) instead of one at a time. Default is one
  >  at a time. Want parallel? Just say 'parallel' (or say 'go' for one at a time)."
  The user triggers parallel by saying so here, or up front when invoking (e.g.
  "/build USR-001 USR-002 in parallel"). If the stories overlap (B1), don't offer
  parallel; explain why and stay sequential.
- **Oversight.** "Approve each plan before building, or autonomous to presentation?" (default plan-gated if unsure or risky)

### B4. Watch in the editor? (optional)
Offer: "Open the worktree(s) in your editor to watch changes live? A multi-root
VS Code window shows all parallel branches as one view; you still control here in
the terminal." If yes, open the worktree folders with `code`.

### B5. Dispatch
Dispatch the **`developer` agent**, one instance per story, each in its own git
worktree + branch (built-in agent worktree isolation; parallel = background
agents). Each `developer` runs the full pipeline: read story, consult `knowledge/`,
confirm a green baseline, plan (gated or autonomous), TDD + ux-design build,
verify acceptance criteria, return a result. Then run `code-reviewer` (plus
`design-reviewer` if UI) on each result.

### B6. Present per story
Summary + diff, acceptance-criteria walkthrough, reviewer verdicts (Critical /
Important / Nitpick), decisions and assumptions, `knowledge/` entries reused.

### B7. Gate + integrate
You approve each, or request changes (the agent revises and re-presents). On
approval, integrate with `/merge` (rebase onto main, tests, merge, cleanup),
serialized so each branch rebases onto the up-to-date main. Never merge without
your approval.

---

## After building
Offer `/learn` to capture non-trivial verified solutions into `knowledge/`.

## Safety rules
- Parallel only for independent stories; one story = one branch = one PR.
- Never merge without explicit approval. Your review is the bottleneck: keep parallel agents to 2-4.
- While learning: start with MODE A or single-agent + plan-gated; raise autonomy as trust grows.
- Uses built-in agents (worktree isolation, background), not a custom orchestrator.
