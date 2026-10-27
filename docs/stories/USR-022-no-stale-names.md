---
id: USR-022
title: No published file names a removed or merged item
prd: PRD-002
order: 16
depends_on: USR-009, USR-012, USR-015, USR-021
covers: R2 R16
---

# USR-022: No published file names a removed or merged item

**Card:** As the maintainer, I want an automatic check that fails when any published file
still names a removed or merged skill, agent or script, so that this class of leftover
cannot reach users however it slips in.

## Acceptance criteria (observable, binary)
- The check runs with the test suite and fails, naming file and line, when a published file
  names any item the cut removes or one of the two merged setup skills.
- Dated history records (review records, older PRDs, stories and plans) are exempt and the
  check says which paths it exempts.
- Run on today's tree before the cut, it fails and names, among others, the install guide's
  final check, the system map, the README, the guide, language, start and brainstorm skills,
  the session baseline, the project template and the bug-report template.
- After the cut, setup merge and guide stories, it passes.
- Planting one removed name into a skill makes it fail again.

**Verification note (this repo):** the list of names lives in one file the cut story owns;
RED first on today's tree is the mutation that proves it; "published" means what the publish
step ships.

## INVEST / size
~0.5 day.

Traceability: `R2 -> USR-022, R16 -> USR-022`.
