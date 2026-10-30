---
id: USR-041
title: Opportunity trees that pick a target
prd: PRD-003
order: 13
depends_on: USR-029
covers: R9
---

# USR-041: Opportunity trees that pick a target

**Card:** As a founder or PM in discovery, I want the opportunity tree to choose which
customer problem to work on by how much it matters and how badly it is served today, so
that the target is chosen on evidence.

## Acceptance criteria (observable, binary)
- Each opportunity is scored on importance and current satisfaction.
- The output states the rule that turns the two scores into the choice, and the chosen
  target is the one that rule picks; when two tie, both are shown and the user chooses.
- Opportunities are phrased in the customer's words ("I struggle to ...").
- Each chosen opportunity has at least three solutions.
- Its depth checklist (USR-029) against the alternative's opportunity-solution-tree skill
  passes.

## INVEST / size
~0.5 day.

Traceability: `R9 -> USR-041`.
