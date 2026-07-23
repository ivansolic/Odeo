---
id: USR-003
title: Set a global default language at plugin install
prd: PRD-001
order: 3
depends_on: USR-002 (resolution + storage model)
covers: R5
---

# USR-003: Set a global default language at plugin install

**Card:** As a new Odeo user, I want to be asked my preferred language once when I install
the plugin (or first run it), so that all my projects default to my language without
per-project setup.

## Acceptance criteria (observable, binary)
- On plugin install / first run, the user is asked for a language exactly once; the offered
  set is English (default), German, Croatian, French.
- Skipping resolves to English.
- The choice is stored as the GLOBAL default (user level), not inside any single project.
- A project with no `output_language` line inherits this global default.
- The install prompt is not shown again during later project setups.

**Verification note (this repo):** hook the one-time prompt into the plugin install /
first-run path; store the global default at user level (a global CLAUDE.md line or an install
config the resolver reads); tests for "inherits global when the project has no line" and
"asked once, not re-asked".

## INVEST / size
~1 day. Depends on USR-002's resolution/storage model.
