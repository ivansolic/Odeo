---
description: Launch orchestrator (go-to-market phase). Runs /odeo:positioning -> /odeo:marketing -> /odeo:gtm-plan -> /odeo:release-notes with a gate between, to take a built feature/product to MARKET. This is market launch, NOT code deploy (that's /odeo:build -> /odeo:merge).
disable-model-invocation: true
---

# Go-to-market (launch orchestrator)

Sequences the launch phase, framing -> reach -> plan -> announce, you approve each step.
This is taking it to **market**, distinct from shipping code (`/odeo:merge`).

## Flow
```
1. /odeo:positioning    how we're framed, for whom, vs the alternative   -> GATE
2. /odeo:marketing      channels + campaigns to reach the segment         -> GATE
3. /odeo:gtm-plan       the focused launch plan (motion, metrics, assets) -> GATE
4. /odeo:release-notes  the user-facing announcement                      -> GATE
```
Adjacent, when relevant: `/odeo:growth-loops` (sustainable growth), `/odeo:battlecard` (vs a named rival), `/odeo:stakeholder-map`.

## Output
A launch packet in `docs/`. After launch, judge it with `/odeo:outcome`.

## Rules
- Human gate between steps; never auto-advance.
- **Market launch, not code deploy.** Code ships via `/odeo:build` -> `/odeo:merge`.

## Example
Built the invoicing feature -> `/odeo:positioning` ("get paid for all your time") ->
`/odeo:marketing` (freelancer communities) -> `/odeo:gtm-plan` (launch sequence + metric) ->
`/odeo:release-notes`. Then `/odeo:outcome` a week later.
