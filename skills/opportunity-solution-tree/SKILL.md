---
description: Build an Opportunity Solution Tree, a visual map from a desired OUTCOME down to opportunities (unmet needs), candidate solutions, then experiments. Keeps discovery outcome-driven and stops solution-jumping. Use during discovery once you have a target outcome and some user signal. Based on the continuous-discovery school.
disable-model-invocation: true
---

# Opportunity Solution Tree (OST)

Make discovery visual and outcome-driven: one OUTCOME at the top, the OPPORTUNITIES
(unmet needs/pains/desires) beneath it, candidate SOLUTIONS under those, and
EXPERIMENTS to test them. Based on the continuous-discovery school. It
forces every idea to connect back to the outcome.

## When to use
- During `/odeo:discover`, once you have a target outcome and some real user signal (from `/odeo:interview-synthesis`, `/odeo:personas`).

## Process
1. **Outcome (root):** one measurable outcome (from `/odeo:strategy` or `/odeo:metrics`), e.g. "more freelancers invoice within a day of finishing work."
2. **Opportunities:** the unmet needs/pains that, addressed, drive that outcome. Source from real signal, not imagination. Frame as **needs, not features**.
3. **Structure + dedupe** (group, parent/child); pick the **target opportunity** to pursue now. (This is a discovery-level choice, distinct from `/odeo:prioritize` at the epic level.)
4. **Solutions:** 2 to 3 candidate solutions for the target opportunity (diverge; `/odeo:brainstorm` helps).
5. **Experiments:** the cheapest test of the riskiest assumption behind the chosen solution (hand to `/odeo:experiments`).

## Output
A tree (outcome -> opportunities -> solutions -> experiments) saved to `docs/research/`. Feeds `/odeo:prd` (the chosen solution) and `/odeo:experiments`.

## Example
```
OUTCOME: freelancers invoice within 1 day of finishing
├─ OPP invoicing feels like a chore   -> SOL one-click invoice from tracked time -> EXP fake-door button
├─ OPP they forget small tasks        -> SOL auto-suggest unbilled entries        -> EXP concierge test
└─ OPP unsure what to charge          -> SOL rate templates                       -> EXP interview 5 users
```

## Quality rules
- Every node connects upward to the outcome; cut orphan ideas.
- Opportunities are **needs**, not solutions in disguise.
- Source opportunities from real signal; mark assumptions as assumptions.
