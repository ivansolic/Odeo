---
id: USR-005
title: Generate prose in the chosen language (mechanics stay English)
prd: PRD-001
order: 5
depends_on: USR-002 (the setting), USR-001 (guard in place first)
---

# USR-005: Generate prose in the chosen language

**Card:** As a PM/builder, I want Odeo's generated prose (PRDs, stories, memos, plans,
review explanations, nudges, chat) in my chosen language while code and machine fields stay
English, so that every artifact I read is in my language without breaking tooling.

## Acceptance criteria (observable, binary)
- With the effective language German, a newly generated PRD, memo, or plan body is in
  German.
- In the same run, code, identifiers, filenames, git branch names, conventional-commit
  type+scope, and frontmatter field names + enum values remain English.
- The public Odeo repo (its own CLAUDE.md override = `en`) generates English prose even when
  the global default is German, Croatian, or French.
- The no-leak guardrail (USR-001) passes on the generated output.

**Verification note (this repo):** add the honor-the-setting instruction to the shared
agent/skill guidance (AGENTS.md + the generating skills); set the Odeo repo's own override
to `en`; verify by generating a sample artifact under a German setting and running
`language-guard.sh`.

## INVEST / size
~1.5 to 2 days (cross-cutting instruction wiring); the largest story. Depends on USR-002.
