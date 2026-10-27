---
id: USR-022
title: No published file names a removed or merged item
prd: PRD-002
order: 16
depends_on: USR-009, USR-012, USR-013, USR-015, USR-021
covers: R2 R16
---

# USR-022: No published file names a removed or merged item

**Card:** As the maintainer, I want every leftover mention of a removed or merged skill,
agent or script cleaned out of the published files and then guarded by an automatic check,
so that this class of leftover cannot reach users however it slips in.

## Acceptance criteria (observable, binary)
- The check runs with the test suite and fails, naming file and line, when a published file
  names any item the cut removes or one of the two merged setup skills.
- Dated history records (review records, older PRDs, stories and plans) are exempt and the
  check says which paths it exempts.
- Run on commit 2c3f8ab (before the cut), it fails and names, among others, the install
  guide's final check, the system map, the README, the guide, language, start and brainstorm
  skills, the session baseline, the project template and the bug-report template.
- Every published file outside history that names a removed or merged item at the start of
  this story is changed: the mention now names the replacement (`setup` for the two merged
  skills) or is removed together with the sentence it belonged to; the commit lists every
  file changed.
- After those changes, the check passes on the whole published tree.
- Planting one removed name into a skill makes it fail again.

**Verification note (this repo):** the list of names is the file USR-009 writes; the failing
run on 2c3f8ab is the RED that proves the check; this story owns the cleanup, so it depends
on no other story having renamed anything; "published" means what the publish step ships.

## INVEST / size
~1.5 days (the cleanup touches AGENTS.md, several skills, scripts, templates, tests and
docs).

Traceability: `R2 -> USR-022, R16 -> USR-022`.
