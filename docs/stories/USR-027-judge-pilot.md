---
id: USR-027
title: Judge the pilot
prd: PRD-002
order: 21
depends_on: USR-026
covers: R1
---

# USR-027: Judge the pilot

**Card:** As the maintainer, I want the three pilot handoffs judged against the primary
metric, so that I decide on facts whether the package is ready for delivery and what the
brief must hold.

## Acceptance criteria (observable, binary)
- Three handoff records exist (USR-026), at least one from an idea of a person who is not
  the maintainer.
- The three used at least two different build setups.
- The result states, per handoff, whether the builder's first questions were only about
  things the package leaves open, and whether the metric held in 3 of 3.
- The questions builders asked that the package should have answered are listed, as input
  for open question 1 (what the brief holds).

## INVEST / size
~0.5 day after the three handoffs.

Traceability: `R1 -> USR-027`.
