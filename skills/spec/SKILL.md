---
description: Specification orchestrator (feature altitude). Turns ONE chosen epic/slice into buildable work, /prd -> /critique -> /stories, with a gate between. Use after /plan picks the next epic, before /build. Stories inherit everything upstream.
disable-model-invocation: true
---

# Spec (specification orchestrator)

Turns ONE chosen epic/slice into critiqued, buildable, dependency-ordered stories. You
approve each step. Context flows down (discovery -> PRD -> stories), so stories aren't
written from scratch, they inherit the problem, outcome, and personas already established.

## Flow
```
1. /prd       problem-first PRD for this slice (absorbs discovery + strategy)
   -> pm-reviewer scores it against the PRD rubric (eval record; fix gaps below threshold)
   -> GATE: approve the PRD
2. /critique  red-team + pre-mortem (incl. security pre-mortem if sensitive)
   -> GATE: revise the PRD per findings
3. /stories   break the critiqued PRD into INVEST stories, ORDERED BY DEPENDENCY
   -> pm-reviewer scores the set against the stories rubric (eval record)
   -> GATE: approve the story set
```
Output: `docs/prds/PRD-NNN` + `docs/stories/USR-NNN`. Next: `/build` each story in order, then `/merge`.

## Altitudes / scope (so it's not confused)
- `/spec` works on ONE feature/slice. Choosing WHICH feature + sequencing across features is `/plan`.
- Within `/spec`, stories are ordered by **dependency** (not RICE); that lives in `/stories`.

## Rules
- Human gate between steps; never auto-advance.
- One feature/slice per run; never a mega-PRD for a whole product.

## Example
NOW epic "capture time" -> `/prd` (outcome: log time in <5s) -> `/critique` ->
`/stories` (USR-001 data model -> 002 timer -> 003 tagging -> ...). Next: `/build` USR-001.
