---
id: USR-033
title: PRD carries a value proposition per segment
prd: PRD-003
order: 5
depends_on: USR-032
covers: R5
---

# USR-033: PRD carries a value proposition per segment

**Card:** As a founder or PM, I want each PRD to say, per segment, how the job is done
today and what changes after, so that the requirements and the success metrics measure the
same promise.

## Acceptance criteria (observable, binary)
- For each segment the PRD has a value proposition with six parts: who; the job and the
  obstacle; how it is done today; how the solution does it; the outcome after; the
  alternatives and why this one.
- Each requirement names which "how the solution does it" part it delivers; a requirement
  that delivers none is flagged in the PRD.
- Each success metric names which "outcome after" it measures.
- After saving, the reply names in one line what was left out on purpose.
- Without a request for depth, only the items its checklist (USR-029) marks as default
  appear; the items marked on request appear when the user asks.
- Its depth checklist (USR-029) against the alternative's PRD skill passes.

## INVEST / size
~1 day.

Traceability: `R5 -> USR-032, USR-033`.
