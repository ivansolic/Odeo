---
id: USR-004
title: Change output language at any time
prd: PRD-001
order: 4
depends_on: USR-002, USR-003
covers: R5
---

# USR-004: Change output language at any time

**Card:** As a PM/builder, I want to change my output language at any time from a simple
command, so that I am not locked into the setup choice and never have to hand-edit files.

## Acceptance criteria (observable, binary)
- A command (e.g. `/language`) shows the current effective language and its scope (project
  or global).
- `/language <code>` with a code in {en, de, hr, fr} sets the language; an unsupported code
  is rejected and the allowed set is listed.
- The command can target either the project override or the global default; the next
  generated artifact reflects the change.
- The change is written in the same canonical form as setup (`output_language: <code>`), so
  the resolver and the no-leak guardrail read it identically.
- Changing the language requires no manual file editing.

**Verification note (this repo):** a small `/language` command/skill that reads and writes
the same setting the resolver uses; tests for show-current, set-valid, reject-invalid, and
scope selection.

## INVEST / size
~1 day. Depends on USR-002 (resolution) and USR-003 (global store).
