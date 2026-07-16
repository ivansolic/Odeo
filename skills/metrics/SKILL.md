---
description: Define the metrics that matter, a North Star plus a small supporting set, tied to user value, not vanity. Use when setting up measurement for a product or feature, or to make an outcome in a PRD measurable. Based on North Star Metric thinking, the AARRR funnel, and the HEART framework.
disable-model-invocation: true
---

# Metrics

Measure the **value users get**, not activity that flatters you. One North Star, a few
supporting metrics, and explicit guardrails. Draws on North Star Metric practice, AARRR
(the AARRR pirate-metrics funnel) and the HEART framework.

## When to use
- Standing up measurement; making a PRD's outcome quantifiable; before `/outcome`.

## Process
1. **North Star Metric:** the single metric that best captures the core value delivered
   to users (e.g. "weekly active teams completing a build", not "signups"). It should
   rise only if users genuinely get value.
2. **Supporting metrics**, pick a small set along the funnel (AARRR: Acquisition,
   Activation, Retention, Referral, Revenue) or experience (HEART: Happiness, Engagement,
   Adoption, Retention, Task success). Choose the few that explain the North Star.
3. **Guardrail metrics:** what must NOT get worse while you chase the North Star (e.g.
   latency, error rate, churn, support load). Prevents gaming.
4. **For each:** definition, current baseline (or "not yet instrumented"), target, and
   where it's measured. No metric without a source.
5. **Call out vanity/gameable metrics** and replace them with value-based ones.

## Output
A North Star + supporting + guardrails, with baselines and sources, saved under `docs/`.
Pairs with `/okrs`; feeds the post-ship `/outcome` check.

## Quality rules
- North Star reflects **user value**, not vanity (signups, pageviews, raw usage).
- Always pair growth metrics with **guardrails** so you don't win the metric and lose the user.
- Every metric has a definition, baseline, and source; never invent numbers.
