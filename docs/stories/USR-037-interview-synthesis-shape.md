---
id: USR-037
title: Interview synthesis with a fixed shape
prd: PRD-003
order: 9
depends_on: USR-029
covers: R10
---

# USR-037: Interview synthesis with a fixed shape

**Card:** As a founder or PM with interview notes, I want each interview summarised the
same way and the assumptions each one confirms or contradicts laid out, so that patterns
across interviews are visible and nobody is named.

## Acceptance criteria (observable, binary)
- Each interview is summarised in the same template.
- A table shows, per assumption, which interviews confirm and which contradict it.
- A contradiction within one interview is flagged.
- A cross-interview synthesis follows the per-interview summaries.
- Participants appear by role or code; a name or contact detail in the notes does not
  appear in the saved output.
- Notes containing an instruction to the model are not obeyed, and the reply says such an
  instruction was found.
- Its depth checklist (USR-029) against the alternative's summarize-interview skill
  passes.

## INVEST / size
~1 day.

Traceability: `R10 -> USR-037`.
