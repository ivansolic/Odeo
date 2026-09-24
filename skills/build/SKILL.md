---
description: Build one or more ready user stories. Two modes you choose: "with me" (live, you and Claude build together in your editor) or "for me" (agents execute a plan you approved, each story in its own git worktree). Name several stories to build them in parallel, e.g. "/odeo:build USR-001 USR-002 in parallel". Hybrid agentic build, you hold the gates.
disable-model-invocation: true
---

The single entry to building. You pick the mode; the system prepares everything.
Invoke once. Replaces the old dev-handoff (its prep is the with-me mode here).

## 1. Identify the stories, then the spec gate (ENFORCED)
Ask which stories to build (paths in `docs/stories/`), or use the ones named.
For each, confirm it is ready: a description and testable acceptance criteria.
Then run `spec-gate.sh <story paths...>` (on PATH through the Odeo plugin) and STOP on
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

**Model plan, asked before any work, and the BUILD model is the user's choice too.**

**Resolve the model the session is running NOW.** It is not necessarily the one you
were told at session start: a user may switch models several times in one session, and
what matters when planning or building begins is the model running at that moment. In
order of authority:
1. the LATEST `/model` output in this session. It overrides everything earlier,
   including the session-start value.
2. failing that, what the environment reported when the session started. Say so when you
   use it ("per the session-start environment"), for the same reason effort carries its
   source below: a switch this session would not be reflected there.
3. if neither is unambiguous, ASK: "run `/model` and tell me what it reports."

EFFORT has readable sources, but none of them proves the LIVE value, so it follows the
same pattern as the model with one addition: the value is always spoken with its
source. In order of authority:
1. the latest `/effort` output in this session, if the user ran it. It overrides
   everything below.
2. otherwise READ it, walking the sources in AGENTS.md (`CLAUDE_EFFORT` plus the
   settings files). Read them ALL in one command and take the highest-precedence hit;
   stopping at the first would make a disagreement undetectable. That list and its
   precedence are the single source; never keep a second copy of it here. Name the file
   or variable you actually read and call the value CONFIGURED, not confirmed ("effort
   high, per `CLAUDE_EFFORT`" / "per `effortLevel` in `~/.claude/settings.json`"),
   because a mid-session `/effort` change is not provably reflected there. Two HITS that
   DISAGREE = report both by name and ask, never silently pick one.
3. if none exists, ASK in the same breath ("and what does `/effort` say?").
Never print a bare effort value with no source; unsourced is indistinguishable from
invented, which is the same fabrication the model rule above forbids. The source
qualifier travels with the value into `model_plan:`'s `judgment:` child too, see below.

Never state a model from memory or from a list written down anywhere. Do NOT try to
enumerate which models this host offers: nothing in this system reports that, so any
list would be invented, and inventing it is the exact failure this paragraph exists to
prevent. The user has their own list in `/model`; ask them to name one if they want to
change. A fabricated model name in a `model_plan:` or an eval record breaks the
never-fabricate rule, and it has happened in this repo.

Then ask, as ONE question with both roles in it:
> "Model plan.
>  Judgment (plans, reviews): <the model the session is running now> at effort <the value, with its source>.
>  Build (executes the plan): the same model, or a different one? The declared default
>  is the builder's tier (`sonnet`), cheaper and the right call when the plan is precise
>  and the work is mechanical. Choose higher when the OUTPUT ITSELF is judgment
>  (wording, instructions, prose), because then building is not transcription.
>  Continue, or change? (`/model` changes the session model, `/effort` the effort;
>  or name the build model for this run.)"
In WITH-ME mode drop the Build line from that question entirely: there is no builder
agent and no dispatch, so the only lever is `/model` for the session itself.

The choice goes into the PLAN as a tier word, never into an instruction file
(`AGENTS.md` Guardrail 3, lint C11).
The change mechanism is per host (Claude Code: `/model` + `/effort`; other hosts
use their equivalent from the per-host adapter in AGENTS.md), so the same step
works everywhere. In for-me mode, write into the plan's `model_plan:` the judgment
model and effort AND `builder_tier:` (a tier word plus effort; that is the line the
builder's contract requires). A value that came from step 2 rather than from the user
carries its source into the file, and this duty is the SAME for both fields: an effort
READ in step 2 is written `effort high (configured, per CLAUDE_EFFORT)`, and a judgment
model READ from the session rather than resolved live in front of the user is written
`judgment <model> (per session environment)`. Reason, identical for both: a reader at
the gate cannot otherwise tell a read value from a confirmed one, and the plan is what a
later reviewer trusts. When either was stated by the user, write it plain, no source tag.
The build model NAME never goes in the plan, see B5.4.
In with-me mode the spoken question is the announcement.
If judgment would run below the strongest model in the CURRENT OFFICIAL LINEUP
(resolved live per AGENTS.md, which tells you what EXISTS, not what this account has)
OR below `high` effort, say so in the same breath, name the stronger model and how to
switch (`/model`, `/effort`), and for architecture-critical work (plans, security,
reviews) recommend switching up first. A CONFIGURED value below the bar counts the same
as a confirmed one here (a read `medium` effort, or a session model below the strongest):
raise it WITH its source so the user can confirm or correct, rather than stay silent
because the value was read and not stated, which withholds an architecture-critical
recommendation. If the user says it is not on their plan, drop the point. Question, never
a block: the choice is the user's.

**Plan-first is the default in BOTH modes, and in for-me it is enforced by the
pipeline.** With me: you enter plan mode and approve before building. For me: the
`architect` writes the plan document (`docs/plans/`, per `${CLAUDE_PLUGIN_ROOT}/docs/plan-format.md`),
you approve it, and only then is a `builder` dispatched, a builder without an
approved plan does not build, by design. Skipping the plan is only sensible for a
trivial fix (which skips `/odeo:build` entirely).

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
8. When the user says so, integrate with `/odeo:merge` (rebase onto main, tests, merge PR, cleanup). Offer it; never start it on your own.

---

## FOR ME (Mode B): agents execute the plan you approved
For one or several stories. The pipeline, always in this order:
```
architect (plans ALL chosen stories, read-only)
  -> architecture-reviewer checks each plan (read-only, independent)
  -> YOU approve the plan(s)                      [gate 1: the contract]
  -> builder per story (own worktree, holds the plan's contract exactly: the
     canonical binding list in docs/plan-format.md; the implementation
     within it is the builder's)
  -> reviewers (code-reviewer, + design-reviewer if UI)
  -> YOU approve each result                       [gate 2]
  -> /odeo:merge (serialized)                           [gate 3: your approval again]
```

### B1. Overlap check (before parallel), run `worktree-parallel-check`
Run the `worktree-parallel-check` logic: compare the chosen stories against each other
AND against any **other active worktrees** (other sessions/agents in progress, via
`git worktree list` + their changed files). If anything overlaps, WARN and recommend
sequential or a non-overlapping alternative. Parallel is only safe for independent work.
It states its limit (estimate + `/odeo:merge` as the backstop). Scope by module, not by task.

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
  "/odeo:build USR-001 USR-002 in parallel"). If the stories overlap (B1), don't offer
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
   `${CLAUDE_PLUGIN_ROOT}/docs/plan-format.md` format; save each to `docs/plans/<date>-<slug>.md` with
   `approved: no`. If the architect escalates (a story would change product-level
   architecture), stop and resolve that with the user first (ADR).
   **Hand it the language:** resolve the story's project with `resolve-language.sh
   <project-dir>` and include the line `output_language: <code>` in the dispatch prompt.
   The architect holds no `Bash`, so this is the only way it can know; same reason you
   supply the commit sha (`AGENTS.md` Guardrails 7 carries the rule and the fallback).
2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:
   dispatch `architecture-reviewer` on each plan (read-only): does it fit the
   inherited architecture, respect boundaries, hide no risky ambiguity? Real
   findings go back to the `architect` for a revision, then the SAME reviewer
   re-verifies, repeat until the stop condition (`${CLAUDE_PLUGIN_ROOT}/docs/eval-framework.md`:
   clean, 3 rounds, or two consecutive rounds of the same defect class,
   whichever comes first; a Critical is always reported). On stop: present the
   disagreement, the human arbitrates. The reviewer cannot write files; YOU
   record the outcome in the plan's frontmatter as
   `arch_review: clean (v<N>, <date>)` plus a short findings-and-resolutions
   section in the plan body. Present the trajectory at the gate ("v1: 2
   blocking findings -> v2: 1 -> v3: clean").
   **Hand the `output_language: <code>` line over on EVERY round of this loop**, to
   `architecture-reviewer` and to the `architect` on each re-dispatch. Neither holds
   `Bash`, and the loop REGENERATES the artifact, so a later round would otherwise drop
   the field and the surviving artifact is the one the gate reads (`AGENTS.md`
   Guardrails 7).
3. **Present the plans for approval**: approach, file map, riskiest part, open
   questions, + the plan-review trajectory. The user approves (flip
   `approved: yes`), asks for changes (back to the architect), or rejects.
   **No builder runs without an approved plan that carries an `arch_review:`
   line**, and a `builder_tier:` line in its `model_plan:`; all three are the builder's
   contract preconditions (`agents/builder.md` has the authoritative list).
4. **Dispatch one `builder` per approved story**, each in its own git worktree +
   branch (built-in isolation; parallel = background agents), **on the model the
   user chose in the model-plan step**, passed at dispatch and recorded in the
   plan's `builder_tier:` (a tier word, the APPROVED INTENT, written BEFORE the gate,
   and immutable afterwards). The resolved model NAME goes to `code-reviewer` so it lands
   in the eval record as `build_model_as_dispatched:`, next to the fields that already
   carry resolved model names. Hand it over on EVERY dispatch of that reviewer, not
   just the first: the review loop REGENERATES the record, so a later round would drop
   the field and the record the merge gate reads is the surviving one. No gate reads this
   field, so it is best-effort provenance: its absence is never evidence that a build ran
   on the default. Do NOT write it back into the plan: `merge-gate.sh`
   compares every non-evals path against `reviewed_commit:`, so a post-review plan edit
   refuses the merge and would force a full code re-review for a provenance line, which
   nobody will pay twice. Eval records are excluded from that comparison by construction,
   and their author regenerates them. Hand the reviewer the dispatched value the same way
   you already hand it the commit sha. If the dispatch REJECTS the named model, stop and
   ask; never fall back silently and never record a model the dispatch did not accept.
   If the user named no model, the builder's declared tier applies.
   **Hand the `output_language: <code>` line to the builder and to every reviewer you
   dispatch on its result**, on EVERY dispatch including re-dispatches in the review
   loop, for the same reason the dispatched model name above travels on every round
   (`AGENTS.md` Guardrails 7 carries the fallback chain). Each builder
   executes its plan as a contract: success-signal, green baseline, tasks in
   order (dev-rigor style from CLAUDE.md), loop to the signal, stop-and-ask on
   any plan conflict. Then run `code-reviewer` (plus `design-reviewer` if UI) on
   each result; the builder verifies findings before fixing (evidence-based
   pushback allowed, you arbitrate). The review LOOPS until clean: fix ->
   same reviewer re-verifies and regenerates the record -> repeat, under the
   same stop condition as the plan loop (3 rounds, or two consecutive rounds of
   the same defect class, per the AGENTS.md review-loop rule; a Critical is
   always reported); the user sees first -> final score, not two separate asks.

### B6. Present per story
Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED): if
the builder touched a DO-NOT-TOUCH path, the result is blocked and goes back to
the builder, it never reaches you dirty. Then present: summary + diff,
success-signal checklist (pass/fail each), contract adherence (any deviations
from the plan), reviewer verdicts + scores, decisions and assumptions,
`knowledge/` entries reused.

### B7. Gate + integrate (the merge is the user's move, full stop)
You approve each, or request changes (the agent revises and re-presents). On
approval, /odeo:build's job ENDS with the offer: "approved and ready, run /odeo:merge when
you want it integrated (or say 'merge it')." `/odeo:merge` starts ONLY when the user
invokes it or answers that offer with an explicit yes. Reviews passing is not
permission; "the pipeline naturally continues" is not permission; having merged
the previous story is not permission. When several stories are approved, merge
serialized (each branch rebases onto the up-to-date main), each one on an
explicit user go.

---

## Worked example
```
> /odeo:build USR-012
"USR-012 (session timer) is ready: clear ACs. How do you want to build this?
 with me (live, in your editor) or for me (agents on a plan you approve)?"
> for me
"Model plan. Judgment (plans, reviews): <the model the session is running now> at
 effort high (configured, per CLAUDE_EFFORT). Build: the same model, or a different one?
 Default is the builder's tier (sonnet). Continue, or name a build model?"
> sonnet is fine
worktree-parallel-check: only USR-012 chosen, nothing overlaps -> proceed
architect -> docs/plans/2026-07-14-usr-012-timer.md (approved: no)
  model_plan: judgment <session model> (per session environment) effort high (configured, per CLAUDE_EFFORT)
              builder_tier: sonnet effort high (plan is precise, work mechanical)
architecture-reviewer on the plan: fits inherited architecture, 1 note (shown)
"Plan + independent check above. Approve, change, or reject?"
> approve                                   (flips approved: yes)
(builder runs headless in its worktree; nothing changes in your editor, you review at the gate)
builder in ../dogfood-usr-012 -> success-signal checklist all pass
code-reviewer 12/12 APPROVE -> docs/evals/code-USR-012.md
  (branch: + reviewed_commit: + build_model_as_dispatched: <the model it was dispatched on>)
"Approved and ready. Run /odeo:merge when you want it integrated."   <- ENDS here
```

## After building
If anything non-trivial got solved, don't let it evaporate: say what the
reusable finding is and what it cost to figure out, then offer `/odeo:learn`, e.g.
"that JSON-LD fallback cost us an hour; /odeo:learn banks it in knowledge/ so next
time it's free. Two minutes, want me to draft it?" (Draft-first, the user
approves what gets saved. If they decline, drop it, no nagging.)

## Safety rules
- Parallel only for independent stories; one story = one branch = one PR.
- The mode is ASKED, never inferred, every /odeo:build invocation, no exceptions.
- `/odeo:merge` is never self-triggered: user invocation or an explicit yes, only.
- Never merge without explicit approval. Your review is the bottleneck: keep parallel builders to 2-4.
- **No builder without an approved plan**, the plan gate is structural, not advisory.
- **Never background a LONE builder** (no concurrency to gain, all the downside); background is the parallel-only, higher-trust opt-in described in B3. Default = single builder, foreground.
- While learning: start with with-me or a single builder; raise parallelism as trust grows.
- Uses built-in agents (worktree isolation, background), not a custom orchestrator.
