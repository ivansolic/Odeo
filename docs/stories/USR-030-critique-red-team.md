---
id: USR-030
title: Critique red team hands you tests
prd: PRD-003
order: 2
depends_on: USR-029
covers: R1
---

# USR-030: Critique red team hands you tests

**Card:** As a founder or PM, I want the red-team part of a critique to turn each
load-bearing claim into a test I can run this week, so that I leave with things to check,
not a list of fears.

## Acceptance criteria (observable, binary)
- The red-team part lists only the claims the plan stands on: run on a sample PRD with
  one planted side claim whose failure would not change the decision, that claim is not
  listed.
- For each claim it states the strongest case for it before attacking it.
- Each failure is written as "fails if ...".
- The claims are ranked by impact if wrong, likelihood of being wrong and cost to test,
  and the ranking shows all three per claim.
- Each claim that survives gets a kill criterion, the evidence to get this week and the
  cheapest test.
- The part ends with what holds up and what could not be judged, each as its own section.
- Two critiques of different documents show the same headings in the same order.
- Without a request for depth, only the items its checklist (USR-029) marks as default
  appear; the items marked on request appear when the user asks.
- Its depth checklist (USR-029) against the alternative's red-team skill and command
  passes.

## INVEST / size
~1 day.

Traceability: `R1 -> USR-030, USR-031`.
