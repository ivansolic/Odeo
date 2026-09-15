---
description: Fence this session's edits to one directory, a lightweight "work only here for now" boundary. "/focus <dir>" limits Edit/Write to that folder (a PreToolUse hook refuses edits elsewhere); "/focus off" lifts it. Explicit command; use it to keep yourself or a for-me agent on one module during a focused session, on top of the permanent DO-NOT-TOUCH boundaries. Example: "/focus apps/api" then "/focus off".
disable-model-invocation: true
---

# Focus (session edit fence)

Limit this session's edits to one directory until you lift it. It is the ephemeral
complement to the permanent DO-NOT-TOUCH boundaries: those protect forever, `/focus`
keeps the work on one module for now. Enforced by the `focus-check.sh` PreToolUse
hook (the `[E]` guardrail in AGENTS.md); it only ever refuses, never grants, and it
fails open, so it can never trap you.

## When to use (and when not)
- You (or a for-me agent) should touch only one module this session and you want
  accidental edits elsewhere REFUSED, not just discouraged.
- `/build` with-me may offer it once on a brownfield module ("lock edits to this
  module?"); otherwise human-invoked. Never after a decline.
- Not a security boundary: the permanent DO-NOT-TOUCH `boundary-check` is the hard
  guard; `/focus` is a focus aid. Enforced on Claude Code; advisory on hosts
  without PreToolUse hooks (portability backlog).

## Process
**Set the fence, `/focus <dir>`:**
1. Repo root: `root="$(git rev-parse --show-toplevel)"`.
2. Resolve the target to an absolute physical path (so the hook matches reliably):
   `zone="$(cd "<dir>" && pwd -P)"`. If the directory does not exist, say so and stop.
3. Write it: `mkdir -p "$root/.claude" && printf '%s\n' "$zone" > "$root/.claude/focus-zone"`.
4. Announce: "Focus on `<zone>`. Edits outside it are refused until `/focus off`."

**Lift the fence, `/focus off`:**
1. `rm -f "$(git rev-parse --show-toplevel)/.claude/focus-zone"`.
2. Announce: "Focus lifted; edits are unrestricted again (DO-NOT-TOUCH boundaries still apply)."

**Status (no argument):** if `.claude/focus-zone` exists, report the active zone;
otherwise say focus is off.

## Worked example
"/focus apps/api"
- `zone="$(cd apps/api && pwd -P)"` resolves to `/Users/.../myapp/apps/api`,
  written to `.claude/focus-zone`, announced.
- An Edit to `apps/web/App.tsx` is now refused by the hook: "focus is on
  .../apps/api; this edit targets .../apps/web/App.tsx outside it. Run /focus off
  to edit elsewhere." An Edit to `apps/api/routes.ts` goes through normally.
- "/focus off" clears `.claude/focus-zone`; edits are unrestricted again.

## Rules
- The fence is enforced by `focus-check.sh` (referenced, not restated): it fails
  open and only ever refuses, so it never overrides normal permissions.
- The state file `.claude/focus-zone` is gitignored and session-scoped; `/focus
  off` clears it, and `session-end-check.sh` warns if one is still active at
  session end. It sits UNDER the permanent DO-NOT-TOUCH boundaries, never replaces them.
