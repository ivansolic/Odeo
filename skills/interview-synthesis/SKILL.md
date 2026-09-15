---
description: Turn raw user-interview or feedback notes into structured insights and opportunities (not a feature wishlist). Use after talking to users, or when you have a pile of feedback to make sense of. Based on continuous-discovery practice.
disable-model-invocation: true
---

# Interview synthesis

Raw conversations become decisions only once you extract the **opportunities** (unmet
needs, pains, desires) underneath what people literally said. Based on continuous-discovery
continuous discovery: capture interview snapshots, map opportunities, resist jumping
to features.

## When to use
- After user interviews, support tickets, sales calls, or a feedback dump.
- Paste the raw notes; this structures them.

## Process
1. **Capture verbatim signals.** Pull direct quotes and concrete moments (what they
   did, not just what they said they want). Distinguish observed behavior from stated preference.
2. **Extract opportunities.** Translate signals into unmet needs framed neutrally:
   "user struggles to X", not "user wants button Y." A feature request is a clue, not the need.
3. **Cluster** opportunities into themes; note frequency and intensity (how many, how much it hurts).
4. **Separate fact from interpretation.** Tag each insight as evidence vs. your inference.
5. **Surface contradictions and surprises**, the things that challenge your assumptions are the most valuable.
6. **Recommend next steps:** which opportunities are worth a PRD, which need more research.

## Output
A themed opportunity map + notable quotes, saved under `docs/research/`. Feeds
`/personas`, `/brainstorm`, and `/prd`.

## Quality rules
- Opportunities, not features. Never launder a feature request into "the insight."
- Never fabricate quotes or data; only what is in the notes. If thin, say so.
- Behavior over claims; what users do beats what they say they want.
