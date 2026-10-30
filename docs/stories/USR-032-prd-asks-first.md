---
id: USR-032
title: PRD asks before it writes
prd: PRD-003
order: 4
depends_on: USR-029
covers: R5
---

# USR-032: PRD asks before it writes

**Card:** As a founder or PM, I want the PRD skill to ask for the problem, the target users
and the success measure when I have not given them, so that the PRD is built on my answers
and not on guesses.

## Acceptance criteria (observable, binary)
- When the problem, the target users or the success measure is missing from the request
  and the material given, the reply asks about the missing ones, at most three questions
  in one message, and contains no PRD.
- When all three are given, the PRD is written without these questions.
- When the user says to go ahead without answering, the PRD is written and every missing
  item is marked as an assumption in the document.
- Any number the PRD states is taken from a cited source or labelled a hypothesis.

## INVEST / size
~0.5 day.

Traceability: `R5 -> USR-032, USR-033`.
