---
id: USR-011
title: Nothing in Odeo tells the user which model to use
prd: PRD-002
order: 5
depends_on: USR-009
covers: R12
---

# USR-011: Nothing in Odeo tells the user which model to use

**Card:** As a founder, I want Odeo to work on whatever model my session runs on without
talking about tiers, so that I am not asked to understand model policy to write a PRD.

## Acceptance criteria (observable, binary)
- No shipped agent, skill, rubric, review-record format, gate or instruction file mentions a
  model tier, a model waiver or which model to use.
- A passing review record without a model tier field is accepted by the spec gate.
- Reviewers no longer write a model tier or a waiver into the records they create.
- The lint rule about model names is gone, and the lint still passes.

**Verification note (this repo):** `spec-gate.sh` drops its tier and waiver checks (test: a
record with `verdict: PASS` and no `model_tier` passes; RED first against today's gate).
Existing records keep their fields; they are history.

## INVEST / size
~1 day.

Traceability: `R12 -> USR-011`.
