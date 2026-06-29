---
description: Design pricing grounded in customer value, not cost-plus or guesswork, covering value metric, model, tiers, and willingness-to-pay. Use when monetizing a product or feature. Based on value-based pricing (Madhavan Ramanujam, "Monetizing Innovation").
disable-model-invocation: true
---

# Pricing

Price on the **value the customer gets**, not your costs, and decide *how* you charge
before *how much*. Based on value-based pricing (Ramanujam, Monetizing Innovation):
talk willingness-to-pay early, design around a value metric.

## When to use
- Monetizing a product/feature; fixing a model that isn't converting or is leaving money on the table.

## Process
1. **Value metric:** the unit you charge by that scales with value received (per active client, per invoice, per seat). The single most important choice.
2. **Willingness-to-pay:** which segments pay, and how much (research/interviews; for a new product this is a **hypothesis to test**, not a fact).
3. **Model:** subscription / usage / per-seat / freemium / one-time, matched to how value accrues and to the buying motion (`/gtm-plan`).
4. **Tiers / packaging:** good-better-best aligned to segments; put the must-have value where you want people to land. No feature soup.
5. **Price points + fences:** the anchor, and the logic for moving between tiers.
6. **Guardrails:** discounting policy; what should be paid vs. free.

## Output
A pricing proposal (value metric, model, tiers, rationale) saved to `docs/`. Pairs with `/business-model` and `/gtm-plan`.

## Example (freelancer tool)
```
Value metric: active clients billed / month
Model: subscription, freemium (1 client free)
Tiers: Free (1 client) | Solo $12 (unlimited + invoicing) | Pro $29 (+ reminders, reports)
```

## Quality rules
- Choose the **value metric** first; price scales with value, not arbitrary usage.
- New-product willingness-to-pay is a hypothesis -> test it (`/experiments`), don't assert it.
- Good-better-best with a clear reason to upgrade; no feature soup.
