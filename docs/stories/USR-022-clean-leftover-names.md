---
id: USR-022
title: Clean leftover mentions of removed items
prd: PRD-002
order: 16
depends_on: USR-009, USR-012, USR-013, USR-015, USR-021
covers: R2 R16
---

# USR-022: Clean leftover mentions of removed items

**Card:** As a founder reading Odeo's instructions, skills and docs, I want no mention of a
skill, agent or script that no longer exists, so that I am never sent to a step Odeo cannot
take.

## Acceptance criteria (observable, binary)
- At the start of the story, a count is taken and kept with the change: every published file
  outside the exemptions of USR-028 that holds a reference (as USR-028 defines it) to an
  item on the removed list or to one of the two merged setup skills, with the number of
  references per file.
- Every reference in that count is changed: it now names the replacement (`setup` for the
  two merged skills) or is removed together with the sentence it belonged to; the commit
  lists every file changed.
- A text that is about the build phase as a whole (for example the code and design reviewer
  scenarios in the review calibration checklist, the build half of the evaluation framework)
  is removed, not reworded, and is kept in the archive.
- Afterwards, the same count returns zero references.
- The rules AGENTS.md keeps for Odeo's own maintenance are still in AGENTS.md or in the
  repository-only tooling of USR-008, and no published file loses a privacy or honesty rule.

**Verification note (this repo):** measured at bb3122f: 437 references in 55 published
files, the most in WORKFLOW.md, AGENTS.md, README.md and docs/system-map.md; the guides, the
session baseline and the project template are rewritten by USR-021, USR-015 and USR-012
first, so this story counts after them. Maintainer decision 2026-10-27: everything that
belongs to the build phase leaves.

## INVEST / size
~2 days (measured count above; split by folder if the count at the start is above 300).

Traceability: `R2 -> USR-022, R16 -> USR-022`.
