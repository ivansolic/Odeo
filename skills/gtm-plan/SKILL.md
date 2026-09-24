---
description: Build a focused go-to-market PLAN, who you're launching to, the message, the channels, the motion, and how you'll know it worked. Use ahead of a launch or a new segment push. The single GTM artifact; the /odeo:go-to-market orchestrator runs the whole launch phase around it.
disable-model-invocation: true
---

# GTM plan

A GTM plan turns a good product into reached customers. It's a **focused** plan for one
beachhead, not a blast to everyone. Pulls together `/odeo:market-segments`, `/odeo:positioning`,
`/odeo:value-proposition`, and `/odeo:metrics`. (This is the plan *artifact*; the `/odeo:go-to-market`
orchestrator sequences the full launch phase: positioning -> marketing -> this -> release-notes.)

## When to use
- Ahead of a launch, a new feature with audience impact, or entering a new segment.

## Process
1. **Target:** the specific beachhead/ICP for this launch (from `/odeo:market-segments`). Not "everyone."
2. **Message:** the positioning + value prop translated into the words this segment uses
   (from `/odeo:positioning`, `/odeo:value-proposition`). One core promise.
3. **Channels:** where this segment actually is and how you'll reach them (be honest about
   what you can execute). Prefer one or two channels done well over a scattershot.
4. **Motion:** how they discover -> evaluate -> adopt (self-serve, sales-assisted, community,
   waitlist). Match the motion to the price and complexity.
5. **Launch plan:** sequence and assets (the few that matter), with owners and dates.
6. **Pricing/packaging note** if relevant (what's free vs. paid, and why), kept simple.
7. **Success metrics + guardrails:** what "a good launch" means in numbers (links to
   `/odeo:metrics`), and the leading signals you'll watch in week 1.

## Output
A focused GTM plan saved under `docs/`. After launch, judge it with `/odeo:outcome`.

## Quality rules
- One beachhead, one core message, one or two channels done well. Focus beats spray.
- Match the motion to price/complexity (no enterprise sales motion for a $9 tool).
- Define what success looks like in numbers **before** launch; watch leading signals.
