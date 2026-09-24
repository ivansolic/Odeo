---
description: Map the customer's end-to-end journey, stages, actions, touchpoints, emotions, and pain points, to find where the experience breaks and where to focus. Use in discovery after personas, or when a flow feels disjointed. Based on customer-journey / service-design mapping (CX standard).
disable-model-invocation: true
---

# Customer journey map

See the experience as the user lives it, stage by stage, so you find the pains worth
fixing. Standard CX / service-design technique. Built on a persona (run `/odeo:personas` first).

## When to use
- During `/odeo:discover` after `/odeo:personas`; or when a flow feels disjointed and you need to locate the break.

## Process
For the chosen persona and a **specific scenario** (e.g. "first time tracking and billing a client"):
1. **Stages:** the phases end to end (e.g. discover -> sign up -> first use -> habit -> renew).
2. For each stage capture: **actions**, **touchpoints** (where they interact), **thoughts**, **emotions** (high/low), and **pain points**.
3. Mark the **emotional low points** and drop-off risks, these are your opportunities.
4. Note **moments of truth** (make-or-break) and what you own vs. depend on others for.

## Output
A stage-by-stage journey for one persona + scenario, pains flagged, saved to `docs/research/`. Feeds `/odeo:opportunity-solution-tree` and `/odeo:prd`.

## Example (freelancer, "bill a client for the first time")
```
Stage      Action              Emotion   Pain
sign up    connect account     hopeful   too many fields
first use  start a timer       unsure    "is this even tracking?"
invoice    turn time->invoice  anxious   manual, error-prone   <- biggest low point
get paid   send + wait         relieved  no payment status
```

## Quality rules
- Map a real persona + a **specific scenario**, not "a user in general."
- Emotions and pains are the point; a dry step list is not a journey map.
- The low points are opportunities, connect them onward, don't just describe.
