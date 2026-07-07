---
description: Build one or more ready user stories. Two modes you choose: build it yourself (human-first, Claude prepares the branch and you drive), or dispatch agents (each story end-to-end in its own git worktree, you approve before merge). Name several stories to build them in parallel, e.g. "/build USR-001 USR-002 in parallel". Hybrid agentic build, you hold the gates.
disable-model-invocation: true
---

The single entry to building. You pick the mode; the system prepares everything.
Invoke once. Replaces the old dev-handoff (its prep is the human-first mode here).

## 1. Identify the stories
Ask which stories to build (paths in `docs/stories/`), or use the ones named.
For each, confirm it is ready: a description and testable acceptance criteria.
If a story is not ready, stop and say what is missing.

## 2. Pick the mode (guided, the user need not know the modes)
First ask a plain diagnostic and recommend, so a non-expert can choose well:
> "Is this work clearly defined (clear acceptance criteria, you know what's needed), or
>  still fuzzy / exploratory (not sure yet how it should look)?
>  - **Clear + independent** -> I recommend **Agents (Mode B)**: an agent builds it, you review the result. Faster, parallelizable.
>  - **Fuzzy / you want to steer** -> I recommend **Myself (Mode A)**: we build together, you correct as we go.
>  (Why: fuzzy work goes better when you steer live, you catch a wrong turn early.)"

Then the modes themselves:
> "  - **Myself (human-first):** I prepare the branch + todo and open the editor; you and I build it together, step by step.
>  - **Agents:** the architect plans your stories, you approve the plan, then a builder per story executes it in its own worktree and presents for your approval."

The user picks (or names the mode directly); default toward Mode A while learning.

**Plan-first is the default in BOTH modes, and in Mode B it is enforced by the
pipeline.** Mode A: you enter plan mode and approve before building. Mode B: the
`architect` writes the plan document (`docs/plans/`, per `docs/plan-format.md`),
you approve it, and only then is a `builder` dispatched, a builder without an
approved plan does not build, by design. Skipping the plan is only sensible for a
trivial fix (which skips `/build` entirely).

**Editor:** Mode A opens the editor by default (you watch and steer live). Mode B opens
the worktree(s) only if you ask (you mainly review the finished result), see B4.

---

## MODE A: human-first (you build, hands-on)
For one story at a time. The safest mode and the right default while learning.
1. Verify the spec is ready (problem, outcome/acceptance criteria, scope). If gaps, say so and ask to fill or proceed.
2. **Set up the workspace.** Run `git worktree list`. If OTHER active worktrees exist (you're working in parallel with another session), ask:
   > "Build in a separate worktree (isolated, recommended when you're working in parallel) or here in the current folder?"
   - separate -> `git worktree add ../<slug> -b feature/<slug>` and work there (own folder + branch).
   - here, or no other worktrees -> `git checkout main && git pull`, then `git checkout -b feature/<slug>`.
   (If other worktrees exist, also run `worktree-parallel-check` first so this story doesn't clash with in-progress work.)
3. Seed `.claude/tasks/todo.md` with the task, context, and key decisions.
4. Open the editor: `code .` (if `code` is missing, say so and skip).
5. **Agree the success-signal (the loop's stop condition):** what "done" means here, every acceptance criterion + tests/lint/typecheck green + any quality targets (in plain language: "loads fast", "works for keyboard/screen-reader users"). Default is just the acceptance criteria + tests; add targets only if they matter.
6. **Plan first, I prompt you and I wait.** Tell the user on screen: *"press Shift+Tab twice (plan mode), I'll draft the steps and wait for your OK before writing any code."* In plan mode, draft the step-by-step plan and present it; **write no code until the user approves.** Approving the plan exits plan mode automatically and building starts (if they want changes, revise and re-present). Then build together (TDD for logic, ux-design + ux-writing for UI, follow AGENTS.md/CLAUDE.md + security baseline), looping build -> check the success-signal -> fix; stop and report if stuck after a few tries.
7. Verify every success-signal item. Then `code-reviewer` (and `design-reviewer` if UI).
8. Integrate with `/merge` (rebase onto main, tests, merge PR, cleanup).

---

## MODE B: agents (architect plans, you approve, builders execute)
For one or several stories. The pipeline, always in this order:
```
architect (plans ALL chosen stories, read-only)
  -> YOU approve the plan(s)                      [gate 1: the contract]
  -> builder per story (own worktree, executes the plan exactly)
  -> reviewers (code-reviewer, + design-reviewer if UI)
  -> YOU approve each result                       [gate 2]
  -> /merge (serialized)                           [gate 3: your approval again]
```

### B1. Overlap check (before parallel), run `worktree-parallel-check`
Run the `worktree-parallel-check` logic: compare the chosen stories against each other
AND against any **other active worktrees** (other sessions/agents in progress, via
`git worktree list` + their changed files). If anything overlaps, WARN and recommend
sequential or a non-overlapping alternative. Parallel is only safe for independent work.
It states its limit (estimate + `/merge` as the backstop). Scope by module, not by task.

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
- **Oversight is structural:** the plan gate is not optional in Mode B. The
  architect's plan is what you approve; builders only run against an approved plan.

### B4. Watch in the editor? (optional)
Offer: "Open the worktree(s) in your editor to watch changes live? A multi-root
VS Code window shows all parallel branches as one view; you still control here in
the terminal." If yes, open the worktree folders with `code`.

### B5. Plan (architect), then gate, then dispatch (builders)
1. **Dispatch the `architect`** with the chosen stories (+ the overlap-check
   findings from B1 as binding input). It returns one plan per story in the
   `docs/plan-format.md` format; save each to `docs/plans/<date>-<slug>.md` with
   `approved: no`. If the architect escalates (a story would change product-level
   architecture), stop and resolve that with the user first (ADR).
2. **Present the plans for approval**: approach, file map, riskiest part, open
   questions. The user approves (flip `approved: yes`), asks for changes (back to
   the architect), or rejects. **No builder runs without an approved plan file.**
3. **Dispatch one `builder` per approved story**, each in its own git worktree +
   branch (built-in isolation; parallel = background agents). Each builder
   executes its plan as a contract: success-signal, green baseline, tasks in
   order (dev-rigor style from CLAUDE.md), loop to the signal, stop-and-ask on
   any plan conflict. Then run `code-reviewer` (plus `design-reviewer` if UI) on
   each result; the builder verifies findings before fixing (evidence-based
   pushback allowed, you arbitrate).

### B6. Present per story
Summary + diff, success-signal checklist (pass/fail each), contract adherence
(any deviations from the plan), reviewer verdicts + scores, decisions and
assumptions, `knowledge/` entries reused.

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
- Never merge without explicit approval. Your review is the bottleneck: keep parallel builders to 2-4.
- **No builder without an approved plan**, the plan gate is structural, not advisory.
- While learning: start with MODE A or a single builder; raise parallelism as trust grows.
- Uses built-in agents (worktree isolation, background), not a custom orchestrator.
