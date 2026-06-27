---
description: Adversarially stress-test a PRD or product direction before you commit, attack the assumptions (red-team), then run a pre-mortem (it failed in 6 months, why?). Use after drafting a PRD/strategy, before building. Includes a security pre-mortem for sensitive features.
disable-model-invocation: true
---

# Critique (red-team + pre-mortem)

Find the holes while they're cheap. Two passes: a **red-team** that attacks the logic,
and a **pre-mortem** that imagines failure and works backward. Pre-mortem technique is
from Gary Klein (popularized by Kahneman).

## When to use
- After a `/prd` or `/strategy` draft, before committing to build.
- Re-run if the revisions are large.

## Pass 1, Red-team (attack it)
Challenge, specifically and without mercy:
- **The problem:** is it real, urgent, and worth solving? Whose evidence, or just a guess?
- **The assumptions:** which single assumption, if wrong, collapses the whole thing?
- **The outcome/metric:** is it truly measurable? Gameable? A vanity metric?
- **Scope:** is the "MVP" actually minimal, or a wishlist? What can be cut and still test the bet?
- **The alternative:** why won't users just keep doing what they do today?

## Pass 2, Pre-mortem (assume failure)
> "It's 6 months later and this shipped and failed. What happened?"
List the **top 3 failure modes** ranked by likelihood, and for each: the **leading signal**
you'd see early, and the cheapest way to test it now.

## Security pre-mortem (required for sensitive features)
If it touches auth, PII, payments, uploads, or anything private:
> "It's 6 months later and we had a breach/leak through this. What was the hole? Where
> does the data live, who can reach it, what's the worst path in?"
List the top 3 attack/leak scenarios and what the design must include to close them.

## Output
Findings + ranked failure modes + leading signals, in chat. Revise the PRD; capture
security findings as requirements. Re-run if changes were large.

## Quality rules
- Be genuinely adversarial; a soft critique is useless. Attack the strongest version, not a strawman.
- Name the **one assumption** that would sink it; that's where to focus.
- Every failure mode gets a **leading signal** you could detect early.
