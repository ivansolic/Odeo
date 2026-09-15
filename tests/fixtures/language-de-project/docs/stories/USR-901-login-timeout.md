---
id: USR-901
title: Session times out after inactivity
status: ready
date: 2026-08-12
---

# USR-901: Session times out after inactivity

**Card:** As an account holder, I want my session to end by itself after a period of
inactivity, so that an unattended screen does not leave my account open to whoever
walks past it.

This story is written in ENGLISH on purpose. It is the INPUT to the live check, and a
German plan produced from a German story would prove mimicry rather than obedience to
the project's output-language setting.

## Acceptance criteria (observable, binary)
- After 15 minutes with no request, the next request is rejected and the user is sent
  to the sign-in screen.
- Any request within the window resets the countdown to a full 15 minutes.
- A session ended this way is recorded in the audit log with the reason `idle-timeout`.
