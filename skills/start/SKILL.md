---
description: Use when the user asks "where are we", "what's next", or "what's the status", seems lost about their position in the lifecycle, or wants a session-opening overview of the project. Read-only; also invoked directly as /start.
---

# Start (you-are-here)

Reads the project's artifacts and tells the user where they are on the lifecycle,
what the next step is, and which recurring loops are due. Changes nothing.

## Process (read-only)
1. **Read the state**: `CLAUDE.md` (configured or placeholders?), `docs/prds/`,
   `docs/stories/`, `docs/plans/` (approved?), `docs/evals/`, `docs/signals/`
   (last date), `knowledge/` (last refresh, via git log), git (branches,
   worktrees, unmerged work), `.claude/tasks/todo.md` (active task).
2. **Place the project on the lifecycle** (`${CLAUDE_PLUGIN_ROOT}/docs/system-map.md`):
   what phase are they in, what is
   done, what is in progress.
3. **Recommend ONE next step** (with the exact command), based on dependency
   order and any in-progress work. If `worktree-parallel-check` matters (other
   active worktrees), mention it.
4. **Consolidate loop reminders** (max a short list, easy to ignore): signal
   memo older than a week, knowledge-refresh older than ~3 weeks, an unshipped
   `/outcome` for a feature merged ~a week ago, repeated eval drops (suggest
   `/improve`), and **stories merged since the last `/retro`** (e.g. "3 stories
   merged, no retro yet, 10 minutes of /retro now compounds into every future
   story"). Sell the value in one concrete line; a "no" is final, no nagging.
   When MORE THAN ONE epic/PRD exists and no prioritization artifact does,
   suggest `/prioritize` + `/roadmap` (value ordering is a PM decision that
   single-epic projects never needed).
   **Model preference**: if CLAUDE.md carries `session_model_preference` and
   the session's current model does not match what that preference resolves to
   TODAY, one line: "session runs on <current>, your preference means
   <resolved now>, /model to switch." Also note when a NEW top model exists,
   detectable when the preference is `strongest` and the live top tier
   (resolved now) differs from the session's current model ("your 'strongest'
   now points to <name resolved now>").
   **Active shares**: if `docs/prototypes/.shares` exists, tunnels past their
   expiry are already dead (ignore); a preview DEPLOY older than ~a week gets
   one line: "preview deploy live since <date>, still needed? (password/delete)".
5. For an **empty/new project**, the first question is whether the IDEA exists,
   before any setup:
   > "Do you already know what you're building?
   >  - not yet / several directions -> `/brainstorm` (shape the direction first;
   >    stack questions come after there IS a direction)
   >  - a concrete feature you want to feel in your hands -> `/prototype`
   >  - yes, and I can describe it -> `/setup-project`, then `/prd`
   >  - I already have a PRD -> paste it + `/critique`"

## Output shape (keep it this tight)
```
Where you are: <project>, phase: <lifecycle phase>
  done:        <the artifacts that exist, one line>
  in progress: <branches/worktrees/todo, one line>
  -> NEXT: <one command + why it's next>
  reminders:   <only what's due, or "none">
```

## Rules for yourself
- Read-only, always. Recommend; never run the next step without being asked.
- One primary recommendation, not a menu (the user can ask /guide for routes).
- State only what the artifacts prove; don't guess intent from thin air.
