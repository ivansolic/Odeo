---
description: Map the competitive landscape and find your wedge, who else solves this, how, and where the gap is. Use when scoping a new product/feature, writing a PRD's context, or sharpening positioning. Grounded in competitive strategy basics (differentiation, the real alternative).
disable-model-invocation: true
---

# Competitor analysis

The point is not a feature grid; it is **where you win and why now**. The most
dangerous competitor is often "the status quo" (a spreadsheet, doing nothing).

## When to use
- Scoping a new product or feature; the Context section of a PRD; sharpening positioning.

## Process
1. **List the real alternatives**, three buckets: direct competitors, indirect
   substitutes, and the status quo (what users do today without anyone). Don't skip the last one.
2. **For each:** who it's for, the core value prop, pricing/model, and its main strength
   and weakness. Keep it to what's decision-relevant.
3. **Find the axes that matter to USERS** (not vendor feature checklists). Position the
   players on 2 to 3 real axes (e.g. simple<->powerful, cheap<->premium).
4. **Name the gap / your wedge:** the underserved segment or job nobody owns. Be honest
   if there isn't an obvious one.
5. **Why now:** what changed (tech, behavior, regulation) that makes this winnable today.
6. **Threats:** who could crush this if they noticed, and your defensibility (if any).
   For AI tooling, treat **first-party / platform absorption** as a standard threat: the
   platform you build on (the model vendor) may ship your primitive natively, so name what
   you defend that they won't build.

## Output
A short landscape + an explicit wedge and "why now", saved under `docs/research/`.
Feeds `/odeo:prd`, `/odeo:positioning`, `/odeo:strategy`.

## Example (a meeting-notes AI)
- **Alternatives:** direct: Otter, Fireflies; indirect: Notion AI, a shared doc; status quo: nobody takes notes, or one person scrambles.
- **User axes:** setup effort (zero-touch <-> configure) x trust in accuracy.
- **Gap / wedge:** zero-touch accuracy with an audit trail for regulated teams; incumbents optimize convenience, not a defensible record.
- **Why now:** real-time transcription + LLM summaries crossed the accuracy bar in 2025, at low cost.
- **Threat:** the meeting platform (Zoom/Teams) ships native notes -> platform absorption; defend on the audit trail they won't prioritize.

## Quality rules
- Include the **status quo** as a competitor; it wins more often than rivals do.
- Axes that matter to users, not feature-count grids.
- Be honest about a weak wedge; a forced differentiator is worse than naming the risk.
- Use real, verifiable claims; flag anything you are inferring vs. know.
