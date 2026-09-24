---
description: Discovery orchestrator. Use when the user wants to run discovery on a fuzzy idea end to end, brainstorm -> personas -> journey-map -> opportunity-tree -> experiments, pausing for input at each step, producing a de-risked, evidence-seeking plan. Thin conductor; each step is also a standalone skill.
---

# Discover (discovery orchestrator)

Sequences the front-of-funnel discovery skills, with a GATE between each (you approve
before moving on). It doesn't replace them; it runs them in order so you don't have to
remember the sequence. Human-in-command.

## Flow (stop anytime; each step runs standalone too)
```
1. /odeo:brainstorm                 diverge on problem + solutions        -> GATE: pick a direction
2. /odeo:personas                   who it's for (Jobs-to-be-Done)        -> GATE
3. /odeo:customer-journey-map       map their journey, find the pains     -> GATE
4. /odeo:opportunity-solution-tree  outcome -> opportunities -> solutions -> GATE: pick target opportunity
5. /odeo:experiments                riskiest assumptions + cheap tests    -> GATE
```
Adjacent, pull in when relevant: `/odeo:research` (cited web evidence for any claim, market size, competitors, pricing), `/odeo:interview-synthesis` (if you have interview notes), `/odeo:competitor-analysis`, `/odeo:market-segments`.

## Output
A discovery packet in `docs/research/`. Next: strategy skills (`/odeo:vision`, `/odeo:strategy`), then `/odeo:plan`.

## Rules
- Human gate between every step; never auto-advance.
- This orchestrates; depth lives in the underlying skills.
- If a step says "stop and get real data," honor it.

## Example
Fuzzy idea "help freelancers get paid" -> brainstorm angles -> persona (solo designer)
-> journey-map (invoicing = the low point) -> OST (target opportunity: invoicing is a chore)
-> experiment (fake-door one-click invoice). Out: a de-risked direction for `/odeo:plan` and `/odeo:prd`.
