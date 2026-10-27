---
id: USR-026
title: Prove the package on three real handoffs
prd: PRD-002
order: 20
depends_on: USR-025
covers: R1
---

# USR-026: Prove the package on three real handoffs

**Card:** As the maintainer, I want three real handoffs from idea to build, so that I know
whether the package is enough for a builder to start.

## Acceptance criteria (observable, binary)
- Three real ideas go from idea to package in Odeo; at least one idea comes from a person
  who is not the maintainer.
- The packages go to at least two different build setups (for example one developer and one
  build tool).
- The transcript of each Odeo session is kept, and a transcript or notes of each build.
- For each handoff, the builder's first questions are compared with the package and each is
  marked "left open by the package" or "already decided by it"; the builder's own summary is
  compared with the package's problem, outcome and scope.
- In the transcripts, no skill started without the user's request or yes.
- The result is written down with the three comparisons and whether the primary metric (3 of
  3) held.

## INVEST / size
Elapsed time depends on the pilots; Odeo work ~1 day.

Traceability: `R1 -> USR-026`.
