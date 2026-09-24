---
description: Before building (especially in parallel), check what's safe to work on right now. Reads your dependency-ordered stories + the active git worktrees, recommends the next story to build, and warns if a story would clash with work already in progress. Read-only, it recommends, never branches or builds. Run it when deciding what to pick up; /odeo:build also runs it before parallel work.
disable-model-invocation: true
---

# Worktree parallel check

Answers one question: **"what's safe to build next, right now?"** It reads the plan
(dependency order) and what's already in progress (git worktrees), then recommends,
**without touching anything**. Read-only.

## When to use
- When deciding which story to pick up next, especially if you or agents already have other work in progress in another worktree/session.
- `/odeo:build` also runs this automatically before dispatching parallel work.

## Process (read-only)
1. **Read the order:** `docs/stories/` (the `USR-NNN` dependency order from `/odeo:stories`) + the roadmap in `docs/` (from `/odeo:plan`). What's unblocked, what comes first.
2. **Read what's in progress:** `git worktree list` for other active worktrees; for each, the files it already touches (`git -C <wt> diff --name-only main...HEAD` + uncommitted via `git -C <wt> status`).
3. **Estimate the candidate story's files** from the story text + a quick search of the codebase for the relevant module. (Heuristic, not exact.)
4. **Compare + recommend, in plain language:**
   - clear -> "USR-7 (search) is next in order and doesn't overlap anything in progress, safe to build, and safe to parallelize."
   - overlap -> "USR-9 touches `src/user.ts`, which feature/auth (in progress) is already changing. Do it after that merges, or build USR-11 (settings) now instead."
5. **State the limit honestly:** "based on the files touched so far plus an estimate, not a guarantee; `/odeo:merge` is the final safety net (it surfaces any real conflict)."
6. **If parallel, remind the runtime setup:** "each worktree needs its own install + `.env`; if you run the app, use a different port (e.g. 3000 vs 3001)."

## Output
A recommendation + the reasoning, in chat. It does **not** branch, edit, or build. You decide, then run `/odeo:build`.

## Rules for yourself
- **Read-only.** Never create branches/worktrees, never edit files, never build.
- Plain language; lead with the recommendation, not git jargon (name the technical term as a short aside only if "teach me as I go" is on).
- Always state the heuristic limit + that `/odeo:merge` is the backstop.
- Recommend by **dependency order first**, then by what avoids overlap with in-progress work.
- Does not modify any PM skill or its output; it only reads what already exists.
