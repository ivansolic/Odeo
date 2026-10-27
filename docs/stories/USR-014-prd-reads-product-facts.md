---
id: USR-014
title: A PRD's security pre-mortem starts from the product's facts
prd: PRD-002
order: 8
depends_on: USR-012
covers: R16
---

# USR-014: A PRD's security pre-mortem starts from the product's facts

**Card:** As a founder writing a PRD, I want the security pre-mortem to start from the data
facts I gave at setup, so that I am not asked them again and the pre-mortem matches my
product.

## Acceptance criteria (observable, binary)
- When the project instruction file holds the product's security and data facts, the PRD's
  security pre-mortem names them (for example the personal data and the login method)
  without asking the user again.
- The PRD's document shape and rubric are unchanged.

## INVEST / size
~0.5 day.

Traceability: `R16 -> USR-014`.
