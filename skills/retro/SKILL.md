---
description: End-of-session retro. Captures what was learned this session and routes each lesson to the right place, project-specific lessons to .claude/tasks/lessons.md, general rules as a proposed global CLAUDE.md update, then backs up the gitignored build ledger (todo.md, lessons.md) to wherever the project records, which writes OUTSIDE the repo. Run before wrapping up a working session.
disable-model-invocation: true
---

A short retrospective so learnings get captured while fresh, not only when a
correction happens. Keep it to a few minutes.

## 1. Gather the lessons
Look back over this session (the conversation, any corrections the user made, any
dead ends or surprises) and propose a short list of concrete lessons. Phrase each
as a **rule for next time**, not a vague observation.

If genuinely nothing notable happened, say so and skip to **step 5**, don't invent lessons.
The backup still runs: `todo.md` changes in almost every session, whether or not the session
taught anyone anything.

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

## 5. Back up what git cannot
Run this **whether or not a lesson was written**: `todo.md` changes in almost every session,
and it is gitignored, so nothing else carries it.

```bash
ledger-backup.sh              # installed in ~/bin, on PATH; repo fallback bin/ledger-backup.sh
```

Report the result by its **exit code**, never by assumption:

| Exit | Say |
|---|---|
| 0 | where the copy went (the script prints it) |
| 2 | the `ledger_backup:` line is refused: malformed (unknown kind, missing branch), a relative path, a target inside **any** git repository, the project's own publish remote, or a state the program could not decide (an unreadable ledger, a repository git cannot read). Show the message and offer to fix the line. **Do not read this as "not configured"**: someone tried to set it up and the setup is broken. |
| 3 | no location is recorded, **or** the line is still the template's `<placeholder>` (the message says which). For a placeholder, offer to fill it in rather than to add a line. Otherwise say ONCE what is at stake: `todo.md` and `lessons.md` hold the task state and every correction this project has learned, they exist nowhere else, and git does not carry them. Offer to add a `ledger_backup:` line to `CLAUDE.local.md` (gitignored, right place for a private target). Take a no and do not raise it again this session. |
| 4 | the target could not be used: unreachable remote, missing directory, a copy that failed. Show the message. The program stages the files and moves them only if all of them copied, so this means the backup did not happen. |
| 5 | the push was refused, so **nothing was backed up**. This is the case that used to pass as success: say it, and do not close the session claiming a backup. |
| 6 | there was nothing to back up (no ledger files yet). |

Exit 1 belongs to `--check` only (the backup is behind); a plain run never returns it.

**What the program cannot decide for you:** whether a remote is PUBLIC. It refuses the
project's publish remote by name and by normalised URL, which catches the obvious mistake, but
an ssh and an https spelling of the same host, a mirror under another name, or a fork are all
invisible to it. Choosing a backup target that nobody else reads stays a human decision.

Never report a backup you did not see exit 0. Measured on this system: the ledger spent weeks
claiming a repo was unprotected when it had been protected all along, and claiming a
repository did not exist after it was created. A stale or lost ledger is how a session starts
by re-deciding what was already decided.

## 6. Close out
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

Backing up the ledger (gitignored, git does not carry it):
  $ ledger-backup.sh
  ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)
```

And the same session where the backup does not work, which is the case this step exists for:
```
  $ ledger-backup.sh
  ledger-backup: PUSH REFUSED to backup/internal-files, so NOTHING was backed up.
  (exit 5)
-> "Your lesson is saved in lessons.md. The backup did NOT happen: the push was refused,
    probably expired credentials. todo.md and lessons.md are still only on this machine."
```

## Safety Rules
- Never write a lesson the user didn't approve.
- Never edit the global CLAUDE.md without explicit confirmation.
- Don't duplicate a lesson that's already recorded, check before appending.
