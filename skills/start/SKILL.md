---
description: Where am I and what's next? Reads the project's actual state (docs, git, evals, loop dates) and shows your position on the lifecycle map, the recommended next step, and any pending loop reminders, all in one place. Read-only. Run it at the start of a session or whenever you feel lost.
disable-model-invocation: true
---

# Start (you-are-here)

Reads the project's artifacts and tells the user where they are on the lifecycle,
what the next step is, and which recurring loops are due. Changes nothing.

## Process (read-only)
1. **Read the state**: `CLAUDE.md` (configured or placeholders?), `docs/prds/`,
   `docs/stories/`, `docs/plans/` (approved?), `docs/evals/`, `docs/signals/`
   (last date), `knowledge/` (last refresh, via git log), git (branches,
   worktrees, unmerged work), `.claude/tasks/todo.md` (active task).
2. **Place the project on the lifecycle** (`docs/system-map.md`, or the installed
   copy in `~/.claude/claude-cofounder-docs/`): what phase are they in, what is
   done, what is in progress.
3. **Recommend ONE next step** (with the exact command), based on dependency
   order and any in-progress work. If `worktree-parallel-check` matters (other
   active worktrees), mention it.
4. **Consolidate loop reminders** (max a short list, easy to ignore): signal
   memo older than a week, knowledge-refresh older than ~3 weeks, an unshipped
   `/outcome` for a feature merged ~a week ago, repeated eval drops (suggest
   `/improve`). Only show what is actually due; no nagging.
5. For an **empty/new project**: suggest the entry points instead ("1.
   /setup-project, then: idea fuzzy -> /discover, concrete -> /prototype,
   already have a PRD -> paste it + /critique").

## Output shape (keep it this tight)
```
Where you are: <project>  , phase: <lifecycle phase>
  done:        <the artifacts that exist, one line>
  in progress: <branches/worktrees/todo, one line>
  -> NEXT: <one command + why it's next>
  reminders:   <only what's due, or "none">
```

## Rules for yourself
- Read-only, always. Recommend; never run the next step without being asked.
- One primary recommendation, not a menu (the user can ask /guide for routes).
- State only what the artifacts prove; don't guess intent from thin air.
