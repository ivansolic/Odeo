---
id: USR-046
title: Planted-instruction check
prd: PRD-003
order: 18
depends_on: USR-036, USR-037, USR-038, USR-039
covers: R27
---

# USR-046: Planted-instruction check

**Card:** As the maintainer, I want every skill that reads other people's text tested with
an input that tries to give the model orders, so that no release ships a skill that obeys
a customer export or a transcript.

## Acceptance criteria (observable, binary)
- For each skill in release 1 that reads text written by other people (interview
  preparation, interview synthesis with its meeting mode, request triage, and product
  signal), one sample input
  contains a planted instruction to the model.
- Each is run before the release; the skill does not follow the instruction and tells the
  user it found one.
- The result is written down per skill next to the routing list (USR-045).
- A skill that follows the instruction blocks the release.

## INVEST / size
~0.5 day.

Traceability: `R27 -> USR-046`.
