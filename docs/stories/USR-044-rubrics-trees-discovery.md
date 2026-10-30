---
id: USR-044
title: Rubrics for opportunity trees and discovery plans
prd: PRD-003
order: 16
depends_on: USR-041, USR-042
covers: R21
---

# USR-044: Rubrics for opportunity trees and discovery plans

**Card:** As a founder or PM, I want opportunity trees and discovery plans scored by a
rubric, so that a tree that picks no target or a plan without decision rules does not
pass.

## Acceptance criteria (observable, binary)
- The reviewer's scope names discovery plans as a document type.
- Opportunity trees and discovery plans each have their own rubric, scored 0 to 2 per
  criterion, whose criteria reward evidence and decisions over filled sections.
- Each rubric is calibrated on one strong and one deliberately hollow document; the strong
  one passes and the hollow one fails.
- Reviewing either document type no longer reports a missing rubric.

## INVEST / size
~1.5 days. Release 1's share of R21.

Traceability: `R21 (part) -> USR-043, USR-044`.
