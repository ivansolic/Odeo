---
description: Analyze cohorts, group users by when they started (or a shared trait) and track retention/engagement over time, to see if the product actually keeps people. Use post-launch or when judging retention/growth health. Based on cohort/retention analysis (standard growth practice).
disable-model-invocation: true
---

# Cohort analysis

Averages lie; cohorts tell the truth about retention. Group users by start period (or
trait) and watch how each behaves over time. Standard growth/retention practice.

## When to use
- Post-launch; judging retention, activation, or whether growth is real or churn-masked. Pairs with `/odeo:metrics` and `/odeo:outcome`.

## Process
1. **Cohort axis:** usually signup week/month; or a trait (channel, plan, feature used).
2. **Retained action:** the action that counts as active, tied to your **value metric** (`/odeo:metrics`).
3. **Retention curve** per cohort over periods (week 1, 2, 3...). Look for the curve **flattening** (a flat tail = real retention) vs. decaying to zero.
4. **Compare cohorts:** are newer cohorts retaining better (product improving) or worse?
5. **Segment** to find who retains (best-fit users) and who churns fast.

## Output
Retention curves by cohort + the read (does it flatten? improving? who retains?), saved to `docs/`. Feeds `/odeo:outcome` and `/odeo:strategy`.

## Example
```
Signup-month cohorts, "active = logged time that week":
M1 cohort: 100% -> 42 -> 38 -> 37%   (flattens ~37%: real retention)
M3 cohort: flattens ~48%             -> product improving for newer users
```

## Quality rules
- "Retained" must map to real **value** (your value metric), not a vanity ping.
- A flat tail = retention; decay-to-zero = no product/market fit, say so honestly.
- Real data only; if it isn't instrumented, say what to track first (no invented curves).
