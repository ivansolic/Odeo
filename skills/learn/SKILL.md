---
description: Capture a solved, verified, non-trivial problem into the project knowledge base (knowledge/) so it can be reused. Run after solving something worth preserving. Quality-gated.
disable-model-invocation: true
---

Turn a solved problem into reusable knowledge. The goal: first time costs research,
every next time is a quick lookup. Only quality entries go in, so the base stays trustworthy.

## Quality gate (ALL must hold, else do not write)
1. **Verified working**, tests / acceptance criteria / review passed. Never store unproven solutions.
2. **Non-trivial**, not a typo or an obvious one-line fix.
3. **Reusable**, a pattern likely to recur, not a one-off.
If any fails, say so and stop.

## Steps
1. **Check for duplicates**, search `knowledge/` first. If an entry overlaps, update or consolidate instead of adding a second.
2. **Classify the track:**
   - **Bug track**, a problem that was debugged and fixed.
   - **Knowledge track**, guidance / a pattern / a decision worth reusing.
3. **Write** to `knowledge/[category]/[slug].md` with YAML frontmatter:
   ```yaml
   ---
   module: [area of the codebase]
   tags: [searchable, keywords]
   problem_type: [bug | pattern | decision]
   provenance: [story/PR/incident it came from]
   reuse_count: 0
   created: [YYYY-MM-DD]
   ---
   ```
4. **Body by track:**
   - **Bug:** Problem · Symptoms · What didn't work · Solution (minimal before/after code) · Why it works · Prevention.
   - **Knowledge:** Context · Guidance · Why it matters · When to apply · Examples.
5. Keep code examples **minimal and clear**.
6. **Show the drafted entry to the user and write it to `knowledge/` only after approval.** Do not write silently.
7. Make sure `CLAUDE.md` surfaces `knowledge/` (category layout + frontmatter fields) so future work searches it.

## Safety rules
- Never store unverified or trivial solutions (garbage in, garbage out).
- Show the draft and get approval before writing; never write silently.
- Don't duplicate; check first, consolidate overlaps.
- `reuse_count` and `provenance` exist so `/odeo:knowledge-refresh` can later prune dead weight and so reuse becomes measurable.
