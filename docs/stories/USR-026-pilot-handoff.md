---
id: USR-026
title: Run one pilot handoff
prd: PRD-002
order: 20
depends_on: USR-025
covers: R1 R15
---

# USR-026: Run one pilot handoff

**Card:** As the maintainer, I want to take one real idea through Odeo to a package and hand
it to a builder, so that I see whether the package is enough for the builder to start.

## Acceptance criteria (observable, binary)
- One real idea goes from idea to package in Odeo, and the transcript of that Odeo session
  is kept.
- The package goes to one builder (a developer or a build tool), and a transcript or notes
  of the build are kept.
- The builder starts from the package alone; the transcript shows the user did not copy
  content into the conversation or re-explain anything the package states.
- Each of the builder's first questions is marked either "left open by the package" or
  "already decided by it".
- The builder's own summary of the work is compared with the package's problem, outcome and
  in-scope items, and any scope the package does not contain is listed.
- In the Odeo transcript, no skill started without the user's request or yes.

**Verification note (this repo):** run three times, one record per handoff; the three are
judged together in USR-027.

## INVEST / size
~1 day of Odeo work per handoff; elapsed time depends on the builder.

Traceability: `R1 -> USR-026, R15 -> USR-026`.
