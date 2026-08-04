---
description: Build one or more ready user stories. Two modes you choose: "with me" (live, you and Claude build together in your editor) or "for me" (agents execute a plan you approved, each story in its own git worktree). Name several stories to build them in parallel, e.g. "/build USR-001 USR-002 in parallel". Hybrid agentic build, you hold the gates.
disable-model-invocation: true
---

The single entry to building. You pick the mode; the system prepares everything.
Invoke once. Replaces the old dev-handoff (its prep is the with-me mode here).

## 1. Identify the stories, then the spec gate (ENFORCED)
Ask which stories to build (paths in `docs/stories/`), or use the ones named.
For each, confirm it is ready: a description and testable acceptance criteria.
Then run `spec-gate.sh <story paths...>` (in `~/bin` or `bin/`) and STOP on
non-zero: it refuses stories with no eval record, a non-passing verdict, or a
record OLDER than the story (spec edited after review). The only way through
is the review loop: fix -> pm-reviewer re-verifies -> fresh PASS. Never work
around it; if the gate is wrong, that is a bug to report, not to bypass.

## 2. Pick the mode (ALWAYS ask, never infer)
The two modes are **with me** and **for me** ("Mode A"/"Mode B" work as aliases).
Ask EVERY time, even when you are confident which one fits, even when the user
chose the same mode for the last five stories. Concluding "that's what you've
been after" and proceeding is a gate violation, the choice is the user's.

Ask a plain diagnostic and recommend, so a non-expert can choose well:
> "How do you want to build this?
>  - **with me**, live: we build together in your editor, file by file, you steer
>    and can interrupt any moment. Best when the work is still fuzzy or you want
>    to watch and learn.
>  - **for me**, delegated: the architect writes a plan, YOU approve it, then a
>    builder agent builds to that plan's contract in its own worktree and presents
>    the result for your review. Best when the story is clearly defined.
>  Is this work clearly defined (clear acceptance criteria), or still fuzzy?
>  Clear -> I'd recommend *for me*. Fuzzy or you want to steer -> *with me*."

The user picks (or names the mode when invoking); default toward with-me while learning.

**Model plan, asked before any work.** Resolve LIVE what the harness is
actually running, model AND effort, for both roles (session model + effort for
judgment; the builder's tier + declared `high` effort for execution), AND the
STRONGEST model available on this host right now (resolve from the current
official lineup live, never from a cached table, the lineup changes often). Put it
as a question. Never bake model names into this file; speak in tier + effort:
> "Model plan: thinking/reviews on <session model as resolved now> at effort
>  <session effort as resolved now>, building on <builder tier> at effort high.
>  Continue, or change? (on this host: `/model` for model, `/effort` for effort;
>  or say a change for this run.)"
The change mechanism is per host (Claude Code: `/model` + `/effort`; other hosts
use their equivalent from the per-host adapter in AGENTS.md), so the same step
works everywhere. In for-me mode, write the answer into the plan file as
`model_plan:` including the effort for each role (the builder's contract requires
it); in with-me mode the spoken question is the announcement. If judgment would
run below the STRONGEST model available on this host (resolve the current lineup
live, never from a cached table) OR below `high` effort, say so in the same breath,
name the stronger model and how to switch (`/model`), and for architecture-critical
work (plans, security, reviews) recommend switching up first (question, not a block,
the choice is the user's).

**Plan-first is the default in BOTH modes, and in for-me it is enforced by the
pipeline.** With me: you enter plan mode and approve before building. For me: the
`architect` writes the plan document (`docs/plans/`, per `docs/plan-format.md`),
you approve it, and only then is a `builder` dispatched, a builder without an
approved plan does not build, by design. Skipping the plan is only sensible for a
trivial fix (which skips `/build` entirely).

**Editor (both modes, one rule): reuse, never multiply.** Reveal and open with
`code -r` / `code --add` so everything lands in the user's EXISTING editor
window, never a new instance (no second dock icon). If `code` is not on PATH,
try `cursor` (same flags); if neither exists, skip opening, and once per project
mention that installing VS Code or Cursor unlocks the live view. With-me opens
the editor by default (you watch and steer live); for-me does NOT open the editor
(delegated, you review the result at the gate), see B4.

---

## WITH ME (Mode A): you and Claude build together, live
For one story at a time. The safest mode and the right default while learning.
1. Verify the spec is ready (problem, outcome/acceptance criteria, scope). If gaps, say so and ask to fill or proceed.
2. **Set up the workspace.** Run `git worktree list`. If OTHER active worktrees exist (you're working in parallel with another session), ask:
   > "Build in a separate worktree (isolated, recommended when you're working in parallel) or here in the current folder?"
   - separate -> `git worktree add ../<slug> -b feature/<slug>` and work there (own folder + branch).
   - here, or no other worktrees -> `git checkout main && git pull`, then `git checkout -b feature/<slug>`.
   (If other worktrees exist, also run `worktree-parallel-check` first so this story doesn't clash with in-progress work.)
3. Seed `.claude/tasks/todo.md` with the task, context, and key decisions.
4. Open the editor: `code -r .` (fallback `cursor -r .`; if neither exists, say so once and skip). As you build, reveal each file you just finished with `code -r -g <file>` so the user watches the story take shape; note that VS Code's Source Control panel marks changed lines in the gutter automatically. If the user says it's noisy, ease off.
5. **Agree the success-signal (the loop's stop condition):** what "done" means here, every acceptance criterion + tests/lint/typecheck green + any quality targets (in plain language: "loads fast", "works for keyboard/screen-reader users"). Default is just the acceptance criteria + tests; add targets only if they matter.
6. **Plan first, I prompt you and I wait.** Offer once: *"want the `architect` agent to draft the plan for us to review, or shall I draft it here?"* Either way: tell the user on screen: *"press Shift+Tab twice (plan mode), I'll present the steps and wait for your OK before writing any code."* In plan mode, present the step-by-step plan; **write no code until the user approves.** Approving the plan exits plan mode automatically and building starts (if they want changes, revise and re-present). Then build together (TDD for logic, ux-design + ux-writing for UI, follow AGENTS.md/CLAUDE.md + security baseline), looping build -> check the success-signal -> fix; stop and report if stuck after a few tries.
7. Verify every success-signal item. Then `code-reviewer` (and `design-reviewer` if UI). If the change touches auth, input handling, uploads, payments, or data access, run the built-in `/security-review` too (note: it needs `origin/HEAD`; if the repo's remote is new, run `git remote set-head origin -a` once first).
8. When the user says so, integrate with `/merge` (rebase onto main, tests, merge PR, cleanup). Offer it; never start it on your own.

---

## FOR ME (Mode B): agents execute the plan you approved
For one or several stories. The pipeline, always in this order:
```
architect (plans ALL chosen stories, read-only)
  -> architecture-reviewer checks each plan (read-only, independent)
  -> YOU approve the plan(s)                      [gate 1: the contract]
  -> builder per story (own worktree, holds the plan's contract exactly:
     signatures, behavior, invariants, tests, verify, boundaries; the
     implementation within it is the builder's)
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
- **Foreground vs background (a supervision tradeoff, not a free win).**
  Foreground = supervised: the builder's Write/Bash actions prompt the user, who
  can interrupt any moment. A LONE builder ALWAYS runs foreground. Background is the
  ONLY way to run builders in PARALLEL (you cannot run many foreground, blocking
  agents at once), but a background agent CANNOT answer permission prompts, so
  parallel builds need permissions pre-arranged (a broader allow-list) and are
  therefore LESS supervised by construction.
  So: default to single foreground builds; treat parallel as a higher-trust,
  EXPLICIT opt-in (trust the plan, keep to 2-4, lean on worktree isolation +
  boundary-check + code-review + explicit per-story merge as the net). NEVER
  background a LONE builder: no concurrency to gain, all of the downside.

### B4. Orientation (for-me does NOT open the editor)
The builder works headless in its own worktree, a DIFFERENT folder from the one
the user has open, so nothing changes in their editor by design. Do NOT offer to
add the worktree to the editor: for-me is delegated, the user reviews the RESULT
at the gate (B6: diff + reviewer verdicts), not keystroke-by-keystroke. Say this
once so a still editor is not mistaken for a stall. Live watching is with-me (Mode A).

### B5. Plan (architect), review the plan, then gate, then dispatch (builders)
1. **Dispatch the `architect`** with the chosen stories (+ the overlap-check
   findings from B1 as binding input). It returns one plan per story in the
   `docs/plan-format.md` format; save each to `docs/plans/<date>-<slug>.md` with
   `approved: no`. If the architect escalates (a story would change product-level
   architecture), stop and resolve that with the user first (ADR).
2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:
   dispatch `architecture-reviewer` on each plan (read-only): does it fit the
   inherited architecture, respect boundaries, hide no risky ambiguity? Real
   findings go back to the `architect` for a revision, then the SAME reviewer
   re-verifies, repeat until clean or 3 cycles (then stop: present the
   disagreement, the human arbitrates). The reviewer cannot write files; YOU
   record the outcome in the plan's frontmatter as
   `arch_review: clean (v<N>, <date>)` plus a short findings-and-resolutions
   section in the plan body. Present the trajectory at the gate ("v1: 2
   blocking findings -> v2: 1 -> v3: clean").
3. **Present the plans for approval**: approach, file map, riskiest part, open
   questions, + the plan-review trajectory. The user approves (flip
   `approved: yes`), asks for changes (back to the architect), or rejects.
   **No builder runs without an approved plan that carries an `arch_review:`
   line**, both are the builder's contract preconditions.
4. **Dispatch one `builder` per approved story**, each in its own git worktree +
   branch (built-in isolation; parallel = background agents). Each builder
   executes its plan as a contract: success-signal, green baseline, tasks in
   order (dev-rigor style from CLAUDE.md), loop to the signal, stop-and-ask on
   any plan conflict. Then run `code-reviewer` (plus `design-reviewer` if UI) on
   each result; the builder verifies findings before fixing (evidence-based
   pushback allowed, you arbitrate). The review LOOPS until clean: fix ->
   same reviewer re-verifies and regenerates the record -> repeat (max 3
   cycles, per the AGENTS.md review-loop rule); the user sees first -> final
   score, not two separate asks.

### B6. Present per story
Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED): if
the builder touched a DO-NOT-TOUCH path, the result is blocked and goes back to
the builder, it never reaches you dirty. Then present: summary + diff,
success-signal checklist (pass/fail each), contract adherence (any deviations
from the plan), reviewer verdicts + scores, decisions and assumptions,
`knowledge/` entries reused.

### B7. Gate + integrate (the merge is the user's move, full stop)
You approve each, or request changes (the agent revises and re-presents). On
approval, /build's job ENDS with the offer: "approved and ready, run /merge when
you want it integrated (or say 'merge it')." `/merge` starts ONLY when the user
invokes it or answers that offer with an explicit yes. Reviews passing is not
permission; "the pipeline naturally continues" is not permission; having merged
the previous story is not permission. When several stories are approved, merge
serialized (each branch rebases onto the up-to-date main), each one on an
explicit user go.

---

## Worked example
```
> /build USR-012
"USR-012 (session timer) is ready: clear ACs. How do you want to build this?
 with me (live, in your editor) or for me (agents on a plan you approve)?"
> for me
"Model plan: thinking/reviews on <session model, resolved now> at effort <session
 effort>, building on <builder tier> at effort high. Continue, or change?
 (`/model` for model, `/effort` for effort)"
> continue
worktree-parallel-check: only USR-012 chosen, nothing overlaps -> proceed
architect -> docs/plans/2026-07-14-usr-012-timer.md (approved: no, model_plan: recorded)
architecture-reviewer on the plan: fits inherited architecture, 1 note (shown)
"Plan + independent check above. Approve, change, or reject?"
> approve                                   (flips approved: yes)
(builder runs headless in its worktree; nothing changes in your editor, you review at the gate)
builder in ../dogfood-usr-012 -> success-signal checklist all pass
code-reviewer 12/12 APPROVE -> docs/evals/code-USR-012.md (branch: field set)
"Approved and ready. Run /merge when you want it integrated."   <- ENDS here
```

## After building
If anything non-trivial got solved, don't let it evaporate: say what the
reusable finding is and what it cost to figure out, then offer `/learn`, e.g.
"that JSON-LD fallback cost us an hour; /learn banks it in knowledge/ so next
time it's free. Two minutes, want me to draft it?" (Draft-first, the user
approves what gets saved. If they decline, drop it, no nagging.)

## Safety rules
- Parallel only for independent stories; one story = one branch = one PR.
- The mode is ASKED, never inferred, every /build invocation, no exceptions.
- `/merge` is never self-triggered: user invocation or an explicit yes, only.
- Never merge without explicit approval. Your review is the bottleneck: keep parallel builders to 2-4.
- **No builder without an approved plan**, the plan gate is structural, not advisory.
- **Never background a LONE builder** (no concurrency to gain, all the downside); background is the parallel-only, higher-trust opt-in described in B3. Default = single builder, foreground.
- While learning: start with with-me or a single builder; raise parallelism as trust grows.
- Uses built-in agents (worktree isolation, background), not a custom orchestrator.
