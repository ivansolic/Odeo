---
description: Set Objectives and Key Results, an ambitious qualitative objective with measurable, outcome-based key results; re-running it over existing OKRs becomes a check-in (actuals vs targets, status per KR). Use for quarterly/cycle goal-setting and periodic reviews. Based on the OKR method.
disable-model-invocation: true
---

# OKRs

OKRs align effort to **outcomes**: one inspiring Objective (where we're going) with a
few measurable Key Results (how we'll know we got there). Based on the OKR method.

## When to use
- Quarterly/cycle goal-setting; connecting team work to outcomes, not output.

## Process
1. **Objective:** a qualitative, ambitious, time-boxed statement of what matters now.
   Memorable and motivating, not a metric.
2. **Key results (2 to 4):** measurable **outcomes** that prove the objective is met.
   - Outcomes (e.g. "activation rate 20% -> 35%"), not tasks ("ship feature X").
   - Each has a baseline and a target. If it can't move and be measured, it's not a KR.
3. **Set the ambition:** stretch (roughly 70% = success) vs. committed (must-hit). Say which.
4. **Sanity checks:** would hitting all KRs actually achieve the objective? Are any KRs
   really disguised tasks? Are they gameable in a way that hurts users?
5. **Name the inputs/bets** you believe will move the KRs (these link to strategy/roadmap), but keep them OUT of the KRs themselves.

## Check-in mode (re-run over existing OKRs)
If OKRs already exist in `docs/`, this run is a CHECK-IN, not a rewrite:
1. Pull current actuals for each KR (real numbers only, from `/metrics` sources
   or what the user provides; a metric without data = "not instrumented", never a guess).
2. Status per KR: on track / at risk / off track, actual vs target, plain one-liner why.
3. Recommend per KR: keep pushing, change the bet feeding it, or (rarely, explicitly) revise the KR.
4. Nothing is rewritten without the user's approval; a check-in is a report first.

## Output
1 objective + 2 to 4 outcome KRs with baselines/targets, saved under `docs/`. Pairs with `/metrics`.
Check-in mode: a status report per KR appended/updated in the same document (dated).

## Quality rules
- KRs are **outcomes, not tasks/output.** "Shipped X" is never a key result.
- Every KR has a baseline and target and is honestly measurable.
- A few that matter beat a long gameable list. Flag vanity or gameable metrics.
