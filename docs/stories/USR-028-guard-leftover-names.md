---
id: USR-028
title: Guard against leftover mentions
prd: PRD-002
order: 17
depends_on: USR-022
covers: R2 R16
---

# USR-028: Guard against leftover mentions

**Card:** As the maintainer, I want an automatic check that fails when a published file
refers to a removed or merged item, so that this class of leftover cannot reach users
however it slips in later.

## Acceptance criteria (observable, binary)
- A reference is one of these forms, for an item on the removed list or one of the two
  merged setup skills: a command (`/odeo:build`), an agent call (`odeo:code-reviewer`), a
  skill folder (`skills/build/`), an agent file (`agents/builder.md`) or a script file
  (`merge-gate.sh`). Ordinary words are not references: the README sentence "ready for
  delivery to any builder" passes.
- The check runs with the test suite and fails, naming file and line, for every reference
  outside the exemptions.
- The exemptions are named in one place and the check prints them: dated history records
  (review records, PRDs, stories, plans, research, release notes of earlier releases), the
  removed-items list itself (USR-009), the session-start detector for removed scripts and
  its test (USR-010), the replay fixture of USR-019, this check's own test, and this
  release's notes (USR-025).
- Run on commit 2c3f8ab (before the cut), it fails.
- On the tree after USR-022, it passes.
- Planting `/odeo:build` into a remaining skill makes it fail; planting it into an exempt
  file does not.
- The check states its known limit: a mention written without one of these forms (for
  example "the code reviewer") is not found.

**Verification note (this repo):** "published" means what the publish step ships; the
failing run on 2c3f8ab is the RED that proves the check.

## INVEST / size
~0.5 day.

Traceability: `R2 -> USR-028, R16 -> USR-028`.
