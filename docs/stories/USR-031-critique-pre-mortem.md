---
id: USR-031
title: Critique pre-mortem sorts the risks
prd: PRD-003
order: 3
depends_on: USR-030
covers: R1
---

# USR-031: Critique pre-mortem sorts the risks

**Card:** As a founder or PM, I want the pre-mortem part of a critique to separate real
threats from overblown and unspoken worries and say when each must be fixed, so that I
know what blocks a launch and what can wait.

## Acceptance criteria (observable, binary)
- Every risk is placed in exactly one of three groups: real threat, overblown worry,
  unspoken worry.
- Every real threat is placed in exactly one of: must fix before launch, fix within 30
  days, watch.
- Every must-fix threat has a mitigation and an owner given as a role, never a person's
  name.
- An overblown worry states why it is overblown.
- Two critiques of different documents show the same headings in the same order.
- Its depth checklist (USR-029) against the alternative's pre-mortem skill passes.

## INVEST / size
~1 day.

Traceability: `R1 -> USR-030, USR-031`.
