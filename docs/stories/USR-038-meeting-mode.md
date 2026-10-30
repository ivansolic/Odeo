---
id: USR-038
title: Meeting summary mode
prd: PRD-003
order: 10
depends_on: USR-037
covers: R26
---

# USR-038: Meeting summary mode

**Card:** As a founder or PM after a meeting, I want my notes turned into what was decided,
who does what and what is still open, so that decisions and actions are not lost.

## Acceptance criteria (observable, binary)
- Interview synthesis offers a meeting mode for meeting notes.
- It separates what was discussed from what was decided.
- Each decision has its date and who decided it, by role.
- Each action item has an owner role; an action without an owner is flagged.
- Open questions are listed.
- Participants appear by role; a name or contact detail in the notes does not appear in
  the saved output.
- Notes containing an instruction to the model are not obeyed, and the reply says such an
  instruction was found.
- Its depth checklist (USR-029) against the alternative's summarize-meeting skill passes.

## INVEST / size
~1 day.

Traceability: `R26 -> USR-038`.
