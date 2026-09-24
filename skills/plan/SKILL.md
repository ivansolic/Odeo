---
description: Planning orchestrator (portfolio altitude). Runs /odeo:prioritize then /odeo:roadmap with a gate between, choose which opportunities/epics to build and lay them on an outcome roadmap. Use after discovery/strategy, before speccing features.
disable-model-invocation: true
---

# Plan (portfolio orchestrator)

Sequences the planning layer; you approve each step. Sits above `/odeo:spec` (one feature)
and below `/odeo:discover` (the whole space).

## Flow
```
1. /odeo:prioritize   rank epics/opportunities (RICE; low confidence ok for new products)
   -> GATE: confirm the ranking (strategy/dependency can override a score, out loud)
2. /odeo:roadmap      now / next / later, outcome-based
   -> GATE: confirm the horizons
```
Output: a ranked list + outcome roadmap in `docs/`. Next: `/odeo:spec` the NOW items in order.

## Two altitudes (never confuse)
- This (`/odeo:prioritize` + `/odeo:roadmap`) = WHICH epics, in what order (product level).
- `/odeo:stories` = which stories WITHIN an epic, by dependency.

## Rules
- Human gate between steps; never auto-advance.
- Portfolio altitude only; story-ordering stays in `/odeo:stories`.

## Example
Epics from discovery: capture-time, invoicing, reminders. `/odeo:prioritize` -> capture-time
and invoicing high, reminders low. `/odeo:roadmap` -> NOW capture-time, NEXT invoicing,
LATER reminders. Then `/odeo:spec` capture-time.
