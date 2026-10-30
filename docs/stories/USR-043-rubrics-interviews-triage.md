---
id: USR-043
title: Rubrics for interview syntheses and request triage
prd: PRD-003
order: 15
depends_on: USR-037, USR-039
covers: R21
---

# USR-043: Rubrics for interview syntheses and request triage

**Card:** As a founder or PM, I want interview syntheses and triage results scored by a
rubric like PRDs are, so that their quality is checked on evidence, not on how full the
sections look.

## Acceptance criteria (observable, binary)
- The reviewer's scope names request triage results as a document type.
- Interview syntheses and request triage results each have their own rubric, scored 0 to
  2 per criterion, whose criteria reward evidence and decisions over filled sections.
- Each rubric is calibrated on one strong and one deliberately hollow document (every
  section present, no evidence); the strong one passes and the hollow one fails.
- Reviewing either document type no longer reports a missing rubric.

## INVEST / size
~1.5 days. Release 1's share of R21; the rest follows in releases 2 and 3.

Traceability: `R21 (part) -> USR-043, USR-044`.
