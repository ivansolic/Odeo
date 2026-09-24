---
description: Evaluate an A/B test honestly, sample size, statistical significance, and a ship/iterate/stop call, without fooling yourself. Use to plan a test (how many users, how long) or to read a finished one. Based on controlled-experiment practice (Kohavi et al., "Trustworthy Online Controlled Experiments"); pairs with /odeo:experiments.
disable-model-invocation: true
---

# A/B test analysis

Turn a test into an honest decision, not a cherry-picked win. Based on controlled-
experiment best practice (Ron Kohavi et al., Trustworthy Online Controlled Experiments).

## When to use
- Planning a test (how big, how long), or interpreting a completed one. `/odeo:experiments` designs the test; this judges it.

## Process
**Planning:**
1. One **primary metric** + hypothesis, defined before running. Add **guardrail** metrics that must not regress.
2. Compute **minimum sample size / duration** for an effect worth caring about. Set the horizon up front; don't peek-and-stop.

**Interpreting:**
3. Validity check: random assignment, no sample-ratio mismatch, ran full duration, no mid-test changes.
4. Report **effect size + confidence/significance + practical significance** (is the lift worth shipping, not just "significant?").
5. Confirm guardrails didn't regress.
6. Decision: **SHIP / ITERATE / STOP**, with the assumptions and what could still be wrong.

## Output
A readout (validity, effect, significance, guardrails, decision) saved to `docs/`. Feeds `/odeo:outcome` and `/odeo:learn`.

## Example
```
Primary: signup -> activation.  Variant +3.1pp (95% CI 1.2-5.0), p=0.004, guardrails flat.
Decision: SHIP (statistically AND practically significant).
```

## Quality rules
- Decide metric, sample size, and duration **before** running. No peeking-and-stopping.
- **Practical** significance, not just statistical; a 0.1% "significant" lift may not be worth it.
- No p-hacking / post-hoc segment cherry-picking; label any exploration as exploratory.
- Real data only (same honesty rule as `/odeo:outcome`); never invent numbers.
