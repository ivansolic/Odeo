---
id: USR-018
title: The package carries no private data
prd: PRD-002
order: 12
depends_on: USR-017
covers: R7 R9
---

# USR-018: The package carries no private data

**Card:** As a founder handing my package to someone else, I want it checked for private
data first, so that keys, e-mail addresses and interviewees' names never travel with it.

## Acceptance criteria (observable, binary)
- Before the package is handed over, the privacy scan runs on it; a planted e-mail address
  produces a warning the user must answer before the package is called ready.
- A planted key produces the same warning.
- The package refers to raw interview notes by their path and never copies their content.
- A package built from an interview synthesis with planted interviewee names contains none
  of those names; its findings describe people by role (for example "a solo founder").

## INVEST / size
~1 day.

Traceability: `R7 -> USR-018, R9 -> USR-018`.
