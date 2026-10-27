---
id: USR-010
title: Old git hooks that point at removed scripts are named
prd: PRD-002
order: 4
depends_on: USR-009
covers: R8
---

# USR-010: Old git hooks that point at removed scripts are named

**Card:** As a user with an existing Odeo project, I want to be told when one of my git
hooks points at a script the new release no longer ships, so that my commits do not silently
lose a check.

## Acceptance criteria (observable, binary)
- In a project whose git hook calls a script the release removed, the session start names
  that hook and the one command that refreshes it.
- The message appears once per session and runs nothing on its own; the refresh runs only
  after the user says yes.
- In a project whose hooks are current, nothing is shown.
- After the refresh, the hook no longer points at a removed script and the secret scan on
  commit still runs.

**Verification note (this repo):** extend the existing outdated-guards check in the
session-start hook (it already names guards from older layouts) with the scripts the cut
removes; test with a fixture hook that calls `merge-gate.sh`.

## INVEST / size
~0.5 day.

Traceability: `R8 -> USR-010`.
