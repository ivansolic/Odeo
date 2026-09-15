---
description: De-risk before building, surface the riskiest assumptions behind an idea, prioritize them, and design the cheapest experiment to test each. Use when the user wants to run or design experiments, validate assumptions, or test an idea cheaply before building. Based on lean experimentation and the four product risks (value, usability, feasibility, viability).
---

# Experiments (assumption mapping + tests)

The cheapest code is the code you didn't build because a near-free test killed the idea
first. Surface assumptions, rank by risk, test the riskiest cheaply. Based on Lean
Startup thinking (build-measure-learn, validated learning) and the four product risks.

## When to use
- After a solution or `/prd` takes shape; before committing build effort, especially for new/uncertain bets.

## Process
1. **List assumptions** across the four product risks:
   - **Value** (will they want it?), usually the riskiest
   - **Usability** (can they use it?)
   - **Feasibility** (can we build it?)
   - **Viability** (does it work for the business: cost, legal, model?)
2. **Prioritize:** plot Impact x Uncertainty. High-impact + high-uncertainty assumptions get tested first.
3. **Design the cheapest test** that could *disprove* each top assumption: interview, fake door, concierge, Wizard-of-Oz, prototype, landing page. **Define the pass/fail signal BEFORE running.**
4. **Run, then decide:** persevere / pivot / kill. Record what you learned (feeds `/learn`, `/prd`).

## Output
A ranked assumption list + experiment designs (with pass/fail criteria) saved to `docs/research/`. Pairs with `/opportunity-solution-tree` and `/critique`.

## Example
```
Assumption (VALUE, high risk): "freelancers will switch tools to save invoicing time."
Test: fake door, a "one-click invoice" button that logs intent + interview the clickers.
Pass if: >= 30% of active testers click within a week. Fail -> reconsider the bet.
```

## Quality rules
- Test the **riskiest** assumption, not the easiest. Value risk usually comes first.
- Define **pass/fail before** running, otherwise you'll rationalize any result.
- The cheapest test that could prove you wrong. Never fabricate a result (same honesty rule as `/outcome`).
