---
id: USR-017
title: Get a package that is ready for delivery
prd: PRD-002
order: 11
depends_on: USR-009
covers: R1
---

# USR-017: Get a package that is ready for delivery

**Card:** As a founder whose stories have passed review, I want one package I can hand to
whoever builds it, so that a developer or any build tool can start without me copying or
re-explaining anything.

## Acceptance criteria (observable, binary)
- After the stories pass review, the user is offered the package step; on yes, one package
  is created in the project and the user is told it is ready for delivery and where it is.
- The package states the problem, the outcome and its metric, the scope with non-goals,
  every story with its acceptance criteria, and a list of what is decided and what is still
  open.
- The package is not created while the PRD or any story lacks a fresh passing review, and
  the user is told which one and what to run.
- The package is not created while any PRD requirement has no story, and the user is told
  which requirement.
- The package names no build tool.

**Verification note (this repo):** assembled only after `spec-gate.sh` and
`coverage-check.sh` both exit 0 (test: one stale record and one uncovered requirement each
block it).

## INVEST / size
~1.5 days.

Traceability: `R1 -> USR-017`.
