---
id: USR-035
title: Story formats and story hygiene
prd: PRD-003
order: 7
depends_on: USR-034
covers: R6
---

# USR-035: Story formats and story hygiene

**Card:** As a founder or PM, I want to choose the story format that fits my team and have
edge cases and unknowns split out, so that each story is the right size and nothing hides
inside another.

## Acceptance criteria (observable, binary)
- The stories skill offers three formats: user stories (the default), job stories ("when
  ..., I want to ..., so I can ...") and why-what-acceptance items; asked for a format, it
  writes the whole set in it.
- Error handling or an edge case that needs its own work becomes its own story: run on a
  sample PRD whose requirement includes recovering from a failed payment, that recovery
  is its own story.
- A story whose size cannot be judged without investigation is flagged as needing a
  spike: run on a sample requirement that depends on an outside service nobody has used
  yet, that story is flagged.
- Without a request for depth, only the items its checklist (USR-029) marks as default
  appear; the items marked on request appear when the user asks.
- Its depth checklist (USR-029) against the alternative's user-stories, job-stories and
  why-what-acceptance skills passes.

## INVEST / size
~1 day.

Traceability: `R6 -> USR-035`.
