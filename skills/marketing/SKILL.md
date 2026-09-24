---
description: Brainstorm cost-effective marketing, the channels, messaging, and campaigns to reach your target segment, prioritized by fit and effort. Use around launch or growth, after positioning. Based on segment-channel-message fit (STP) and the acquisition stage of AARRR.
disable-model-invocation: true
---

# Marketing

Reach the right people, with the right message, in the right place, cheaply. Built on
STP (segment -> target -> position) and acquisition thinking (AARRR). Uses `/odeo:positioning`
and `/odeo:value-proposition` as inputs.

## When to use
- Around launch or a growth push; after `/odeo:positioning` and (ideally) `/odeo:market-segments`.

## Process
1. **Target:** the specific segment/ICP for this push (from `/odeo:market-segments`). Not everyone.
2. **Message:** positioning + value prop in the **segment's words** (from `/odeo:positioning`, `/odeo:value-proposition`). One core promise.
3. **Channels:** brainstorm where this segment actually is (communities, content/SEO, social, partnerships, outbound, ads). Rank by **fit x effort/cost**. Prefer one or two done well.
4. **Campaign ideas:** 2 to 3 concrete plays per chosen channel (what, hook, call to action).
5. **Measurement:** the acquisition metric per channel + a **cheap test before scaling spend**.

## Output
A prioritized channel + campaign plan saved to `docs/`. Pairs with `/odeo:gtm-plan` and `/odeo:growth-loops`.

## Example (freelancer tool)
```
Target: solo designers.
Channel (fit high / effort low): freelance-design communities + a "invoice in 1 click" demo clip.
Test: post the demo, measure signups BEFORE any ad spend.
```

## Quality rules
- One or two channels done well beat scattershot. Rank by fit x effort.
- Message in the **segment's words**, not internal jargon.
- Test a channel cheaply before scaling spend; measure acquisition honestly.
