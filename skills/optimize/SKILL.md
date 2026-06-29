---
description: Improve measured performance (speed, bundle size, cost) in a grounded loop, profile -> find the hotspot -> make one change -> re-measure -> keep only if it actually helped -> repeat to the target. Use when something is measurably slow or heavy, not by default. Never optimize without measuring.
disable-model-invocation: true
---

# Optimize (performance loop)

Make it faster or leaner, grounded in **real measurement**, not guesses. The loop:
measure -> change -> measure again -> keep only if it helped. (This is the closed
feedback-loop pattern, propose -> test -> measure -> refine.) The benchmark is the
verifier; the target (or diminishing returns) is the stop.

## When to use
- Something is **measurably** slow or heavy: slow page/endpoint, big bundle, expensive
  query, high cost. Often flagged by `/outcome`. Not part of every build, reach for it
  when performance is a real problem.

## Process
1. **Baseline first.** Measure the real number (profile, benchmark, bundle size, query
   time). No measurement, no optimizing, never guess where the time goes.
2. **Set the target + stop:** e.g. "under 1s" or "until improvements get small". This is
   the loop's done-signal.
3. **Find the biggest hotspot** (the one change with the most impact). One at a time.
4. **Make ONE change, then re-measure.** Did it actually help, and are tests still green?
   - Helped + green -> keep. Didn't help / broke something -> revert.
5. **Repeat** on the next hotspot until the target is hit or gains get small, then **stop
   and report**. A loop that can't stop is just expensive.

## What you return (plain language)
- **Before -> after numbers** and what changed, in plain words; if "teach me as I go" is
  on, add the technical term as a short aside: "dashboard loads in 0.9s instead of 1.9s,
  fixed how it loads data (technical: removed an N+1 query)."
- What you tried that did **not** help (and reverted).
- Changes land via `/merge` with your approval, like any build (human-gated).

## Quality rules
- **Never optimize without measuring.** No guessing, no premature optimization.
- One change at a time, measured; keep only what the benchmark proves faster.
- Don't trade correctness for speed, tests stay green; never weaken a test.
- Stop at diminishing returns.
- Report in plain language (`ux-writing`); name the technical fix only as a labeled aside.
