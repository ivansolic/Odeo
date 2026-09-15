---
description: Pull the latest shared community knowledge into ~/.claude/community-knowledge so you get other contributors' curated lessons. Run when the session-start freshness nudge suggests it, or anytime. Quick; does not reinstall the system.
disable-model-invocation: true
---

# Sync community (pull shared knowledge)

Refresh the community knowledge base, the curated, sanitized lessons contributed by all
users. A quick git pull; it does NOT touch the tooling (for that, plugin users run
`/plugin update`).

## When to use
- The session-start freshness nudge says the base looks stale, or you just want the latest. Often.

## What it does
1. If `~/.claude/community-knowledge` is a git repo: `git -C ~/.claude/community-knowledge pull --ff-only`.
2. Report what's new (count + categories). If the base isn't present, tell the user to run `install.sh` once (it sets it up).
3. Suggest `/knowledge-refresh` if a new community lesson overlaps this project's local `knowledge/`.

## This vs the other commands (so it's never confusing)
- **`/sync-community`** = pull shared KNOWLEDGE (content). Everyone, often.
- **`/plugin update`** = update the TOOLING (skills/agents code). Plugin users, rarely.
- `/contribute-lesson` = send a lesson OUT · `/learn` = write LOCAL · `/knowledge-refresh` = audit LOCAL.

## Output
A short summary of pulled lessons. Read-only consume; never edits the community base.

## Worked example
```
> /sync-community
Pulled 3 new community lessons: auth/jwt-refresh-rotation, testing/flaky-timers,
api/pagination-cursors. 1 overlaps this project's knowledge/auth/, run
/knowledge-refresh to reconcile? [yes/no]
```

## Safety rules
- Pull only (`--ff-only`); never push or edit the community base here (contribute via `/contribute-lesson`).
- Don't auto-run; the user invokes it (or accepts the freshness nudge).
