---
description: Specification orchestrator (feature altitude). Turns ONE chosen epic/slice into buildable work, /odeo:prd -> /odeo:critique -> /odeo:stories, with a gate between. Use after /odeo:plan picks the next epic, before /odeo:build. Stories inherit everything upstream.
disable-model-invocation: true
---

# Spec (specification orchestrator)

Turns ONE chosen epic/slice into critiqued, buildable, dependency-ordered stories. You
approve each step. Context flows down (discovery -> PRD -> stories), so stories aren't
written from scratch, they inherit the problem, outcome, and personas already established.

## Flow
```
1. /odeo:prd       problem-first PRD for this slice (absorbs discovery + strategy)
   -> pm-reviewer scores it against the PRD rubric (eval record; fix gaps below threshold)
   -> GATE: approve the PRD
2. /odeo:critique  red-team + pre-mortem (incl. security pre-mortem if sensitive)
   -> GATE: revise the PRD per findings
3. /odeo:stories   break the critiqued PRD into INVEST stories, ORDERED BY DEPENDENCY
   -> pm-reviewer scores the set against the stories rubric (eval record)
   -> GATE: approve the story set
```
Output: `docs/prds/PRD-NNN` + `docs/stories/USR-NNN`. Next: `/odeo:build` each story in order, then `/odeo:merge`.

## Altitudes / scope (so it's not confused)
- `/odeo:spec` works on ONE feature/slice. Choosing WHICH feature + sequencing across features is `/odeo:plan`.
- Within `/odeo:spec`, stories are ordered by **dependency** (not RICE); that lives in `/odeo:stories`.

## Rules
- Human gate between steps; never auto-advance.
- One feature/slice per run; never a mega-PRD for a whole product.

## Example
NOW epic "capture time" -> `/odeo:prd` (outcome: log time in <5s) -> `/odeo:critique` ->
`/odeo:stories` (USR-001 data model -> 002 timer -> 003 tagging -> ...). Next: `/odeo:build` USR-001.
