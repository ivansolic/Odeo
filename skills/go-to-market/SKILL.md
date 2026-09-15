---
description: Launch orchestrator (go-to-market phase). Runs /positioning -> /marketing -> /gtm-plan -> /release-notes with a gate between, to take a built feature/product to MARKET. This is market launch, NOT code deploy (that's /build -> /merge).
disable-model-invocation: true
---

# Go-to-market (launch orchestrator)

Sequences the launch phase, framing -> reach -> plan -> announce, you approve each step.
This is taking it to **market**, distinct from shipping code (`/merge`).

## Flow
```
1. /positioning    how we're framed, for whom, vs the alternative   -> GATE
2. /marketing      channels + campaigns to reach the segment         -> GATE
3. /gtm-plan       the focused launch plan (motion, metrics, assets) -> GATE
4. /release-notes  the user-facing announcement                      -> GATE
```
Adjacent, when relevant: `/growth-loops` (sustainable growth), `/battlecard` (vs a named rival), `/stakeholder-map`.

## Output
A launch packet in `docs/`. After launch, judge it with `/outcome`.

## Rules
- Human gate between steps; never auto-advance.
- **Market launch, not code deploy.** Code ships via `/build` -> `/merge`.

## Example
Built the invoicing feature -> `/positioning` ("get paid for all your time") ->
`/marketing` (freelancer communities) -> `/gtm-plan` (launch sequence + metric) ->
`/release-notes`. Then `/outcome` a week later.
