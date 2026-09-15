---
description: Prioritize features, opportunities, or stories with a transparent, comparable method (RICE), so sequencing is a defensible decision, not a loudest-voice one. Use when you have more to do than you can do. Based on the RICE framework; notes MoSCoW and value/effort.
disable-model-invocation: true
---

# Prioritize (RICE)

Prioritization is **making the trade-offs explicit** so the order survives scrutiny. RICE
scores each item by Reach, Impact, Confidence, and Effort.

## When to use
- More candidates than capacity; sequencing a roadmap or a backlog.

## Process (RICE)
For each item, estimate:
- **Reach**, how many users/events in a period (use real numbers, not vibes).
- **Impact**, how much it moves the goal per user (a simple scale, e.g. 3 massive / 2 high / 1 medium / 0.5 low / 0.25 minimal).
- **Confidence**, how sure you are of Reach and Impact (100% high / 80% medium / 50% low). This is the honesty dial; it punishes guesses.
- **Effort**, person-time (e.g. person-weeks). The only denominator.

**Score = (Reach x Impact x Confidence) / Effort.** Rank by score.

Then sanity-check: does the ranking respect dependencies (`/stories` order) and strategy
focus (`/strategy`)? Strategy and dependencies can override a raw score, say so explicitly when they do.

## Other lenses (use when RICE doesn't fit)
- **MoSCoW** (Must / Should / Could / Won't), for release scoping and stakeholder alignment.
- **Value vs. Effort** 2x2, for a fast, rough cut.

## Output
A scored, ranked list with the estimates shown (so others can challenge the inputs),
saved under `docs/` or the backlog.

## Quality rules
- Show the **inputs**, not just the score; the value is the transparency.
- **Confidence** must do real work, low confidence should sink a flashy guess.
- A score is an input to judgment, not the decision. Dependencies and strategy can
  override it, but only out loud. Beware false precision.
