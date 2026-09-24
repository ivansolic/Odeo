---
description: Sequence prioritized opportunities/epics into an outcome-based roadmap (now / next / later), so the product has direction over time, not a dated feature list. Use after /odeo:prioritize, at the portfolio altitude (above individual features). Based on outcome-based roadmapping (Melissa Perri; now/next/later popularized by ProdPad).
disable-model-invocation: true
---

# Roadmap

Lays prioritized work onto horizons of OUTCOMES, not dated feature promises. Portfolio
altitude: it sequences epics; `/odeo:stories` orders work WITHIN an epic (by dependency).
Based on outcome-based roadmapping (Melissa Perri, Escaping the Build Trap) and the
now/next/later format.

## When to use
- After `/odeo:prioritize`, for a product or multi-epic effort. Skip for a single feature.

## Process
1. Pull the ranked epics/opportunities from `/odeo:prioritize`.
2. Group by confidence + dependency into **NOW** (committed, in build) / **NEXT** (likely, being shaped) / **LATER** (directional bets).
3. Frame each as an **outcome** ("freelancers invoice in one click"), not a feature.
4. A dependency that unblocks others moves earlier even if lower value.
5. Note the **leading signal** that would move an item between horizons (links to `/odeo:outcome`).

## Two altitudes (never confuse)
- Roadmap / `/odeo:prioritize` = WHICH epics, in what order (product level).
- `/odeo:stories` = which stories, WITHIN one epic, by dependency.

## Output
A now/next/later outcome roadmap saved to `docs/`. Revisited after each `/odeo:outcome` as confidence rises.

## Example (freelancer time-tracker)
```
NOW    capture billable time effortlessly      (the MVP)
NEXT   invoice in one click
LATER  auto-catch unbilled tasks
```

## Quality rules
- Outcomes, not dated features. Horizons, not deadlines you'll miss.
- New product = low confidence: lean on strategy + dependency, not false RICE precision.
- Revisit after real signal (`/odeo:outcome`); a roadmap is a living hypothesis.
