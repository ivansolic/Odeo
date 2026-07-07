---
description: End-of-session retro. Captures what was learned this session and routes each lesson to the right place, project-specific lessons to .claude/tasks/lessons.md, general rules as a proposed global CLAUDE.md update. Run before wrapping up a working session.
disable-model-invocation: true
---

A short retrospective so learnings get captured while fresh, not only when a
correction happens. Keep it to a few minutes.

## 1. Gather the lessons
Look back over this session (the conversation, any corrections the user made, any
dead ends or surprises) and propose a short list of concrete lessons. Phrase each
as a **rule for next time**, not a vague observation.

If genuinely nothing notable happened, say so and stop, don't invent lessons.

## 2. Categorize each lesson by scope
For each lesson, decide where it belongs:

- **Project-specific** (only matters in this codebase/product) → `.claude/tasks/lessons.md`
- **General** (applies to all the user's work, any project) → propose a global
  `~/.claude/CLAUDE.md` update
- **A durable project rule** (a convention worth always loading here) → propose
  adding it to this project's `CLAUDE.md` → Corrections section

## 3. Show the user before writing
Present the proposed lessons grouped by destination. Ask the user to confirm,
edit, or drop any. **Do not write anything until they approve**, especially the
global CLAUDE.md, which affects every project.

## 4. Apply
- Append approved project lessons to `.claude/tasks/lessons.md`, dated, each
  phrased as a rule: `- YYYY-MM-DD, [what happened]. Rule: [what to do next time].`
- Append approved durable rules to this project's `CLAUDE.md` → Corrections.
- For approved global rules, edit `~/.claude/CLAUDE.md`.

## 5. Close out
Briefly confirm what was written and where. Remind the user they can resume this
session later with `claude --continue`.

## Worked example
```
> /retro
Session review: built USR-012 (timer), 2 corrections happened.
Proposed lessons:
1. PROJECT: "2026-07-07, timer drifted with setInterval. Rule: use timestamp
   deltas, not interval ticks, for elapsed time."     -> lessons.md?  [yes/no]
2. GLOBAL candidate: "always run worktree-parallel-check before parallel builds"
   -> propose for global CLAUDE.md?                    [yes/no]
You approve #1, decline #2 -> only #1 is written. Confirmed: 1 lesson saved.
```

## Safety Rules
- Never write a lesson the user didn't approve.
- Never edit the global CLAUDE.md without explicit confirmation.
- Don't duplicate a lesson that's already recorded, check before appending.
