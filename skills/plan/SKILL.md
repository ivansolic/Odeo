---
description: Planning orchestrator (portfolio altitude). Runs /prioritize then /roadmap with a gate between, choose which opportunities/epics to build and lay them on an outcome roadmap. Use after discovery/strategy, before speccing features.
disable-model-invocation: true
---

# Plan (portfolio orchestrator)

Sequences the planning layer; you approve each step. Sits above `/spec` (one feature)
and below `/discover` (the whole space).

## Flow
```
1. /prioritize   rank epics/opportunities (RICE; low confidence ok for new products)
   -> GATE: confirm the ranking (strategy/dependency can override a score, out loud)
2. /roadmap      now / next / later, outcome-based
   -> GATE: confirm the horizons
```
Output: a ranked list + outcome roadmap in `docs/`. Next: `/spec` the NOW items in order.

## Two altitudes (never confuse)
- This (`/prioritize` + `/roadmap`) = WHICH epics, in what order (product level).
- `/stories` = which stories WITHIN an epic, by dependency.

## Rules
- Human gate between steps; never auto-advance.
- Portfolio altitude only; story-ordering stays in `/stories`.

## Example
Epics from discovery: capture-time, invoicing, reminders. `/prioritize` -> capture-time
and invoicing high, reminders low. `/roadmap` -> NOW capture-time, NEXT invoicing,
LATER reminders. Then `/spec` capture-time.
