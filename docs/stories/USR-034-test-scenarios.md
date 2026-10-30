---
id: USR-034
title: Test scenarios from acceptance criteria
prd: PRD-003
order: 6
depends_on: USR-029
covers: R4
---

# USR-034: Test scenarios from acceptance criteria

**Card:** As a founder or PM handing stories to whoever builds them, I want each story to
come with the scenarios that prove its acceptance criteria, including what happens when
things go wrong, so that the builder does not have to ask about edge cases.

## Acceptance criteria (observable, binary)
- The stories skill offers a scenarios step after the stories are written.
- Every acceptance criterion has at least one scenario.
- Every story has at least one negative scenario: invalid input, missing permission or an
  empty state.
- Scenarios say what the user does and sees; none names how it is built.
- A coverage table maps each criterion to its scenarios and lists the criteria with none.
- Without a request for depth, only the items its checklist (USR-029) marks as default
  appear; the items marked on request appear when the user asks.
- Its depth checklist (USR-029) against the alternative's test-scenarios skill passes.

## INVEST / size
~1 day.

Traceability: `R4 -> USR-034`.
