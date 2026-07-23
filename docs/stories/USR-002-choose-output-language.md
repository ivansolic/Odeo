---
id: USR-002
title: Choose output language at setup
prd: PRD-001
order: 2
depends_on: none (pairs with USR-001 as the safety net before USR-005)
covers: R1 R5
---

# USR-002: Choose output language at setup

**Card:** As a PM/builder, I want to pick my output language when I set up a project
(default English), so that Odeo writes what I read in my language without fiddling per
artifact.

## Acceptance criteria (observable, binary)
- `setup-project` / `init-project` asks for the language exactly once; the offered set is
  English (default), German, Croatian, French.
- Skipping the question resolves to English.
- The choice is written as one line in the project's CLAUDE.md in the exact form
  `output_language: <code>`, where `<code>` is one of `en`, `de`, `hr`, `fr`.
- A global default can be set once and is used when a project has no line.
- The effective language resolves by precedence: the project line, else the global default,
  else English.
- Editing the CLAUDE.md line (or re-running setup) changes the effective language on the
  next generation.

**Verification note (this repo):** wire the prompt in `bin/init-project.sh` /
`skills/setup-project`; a resolution helper plus tests covering the three precedence cases
and the skip-defaults-to-English case.

## INVEST / size
~1 to 1.5 days. Independent of USR-001; both precede USR-003.
