---
description: Post-ship outcome check for a shipped feature. Reads the PRD success criteria, gathers REAL available signals (analytics, errors, qualitative), compares actual vs intended, and gives a verdict (keep / iterate / kill / need-more-data). Run about a week after shipping, when there is real data. Closes the build loop. Never fabricates data.
disable-model-invocation: true
---

The loop most teams skip: did the thing we shipped actually solve the problem?
This check reads the PRD's intended outcome and compares it against reality.

## Preconditions (do not fake)
- The feature is **actually shipped** and some time has passed (enough for data).
- If it is not shipped, or there is no real data yet, **say so and stop.** Do NOT
  invent numbers and do NOT write fabricated lessons to `knowledge/`. An outcome
  check on fake data is worse than none (it poisons the knowledge base).

## Steps
1. **Identify** the feature and its PRD (`docs/prds/`) + success criteria / metrics + the story acceptance criteria.
2. **Gather signals from REAL sources only:**
   - Analytics: a file/export you provide, or an analytics connector (MCP/API) if configured.
   - Errors: error logs or an error tracker (Sentry, etc.) if available.
   - Qualitative: your own observations / user feedback.
   If a source is missing, note it and run a **qualitative-only** check; suggest wiring basic analytics. Never substitute invented data.
3. **Compare** actual vs the PRD's intended outcome and metrics. Look at leading signals (week 1 vs week 4 if available).
4. **Report:** did it solve the problem? hit the metric? what broke? what surprised us?
5. **Verdict:** keep / iterate / kill / need-more-data.
6. **Close the loop automatically (with your approval):** don't wait to be asked,
   - **Draft a `/learn` entry** from the result ("approach X worked / failed in production for problem Y") and show it; write to `knowledge/` only after the user approves.
   - **Propose promoting or demoting** related `knowledge/` entries based on the real outcome (knowledge is judged by real results, not just code-match).
   - **If the verdict surfaces a fixable problem, suggest the next step**, e.g. slow -> "want me to run `/optimize`?"; missed the metric -> "iterate via `/spec`?". You suggest; the user decides and triggers it (nothing auto-runs across the gate).
   - **Roadmap-drift check:** if the verdict changes the priority picture (a kill, a surprise win, a bigger problem revealed), offer: "this changes what's worth building next, want to revisit `/roadmap` (or `/plan`)?" Offer only; the user decides.

## Safety rules
- Never fabricate or estimate data; only real sources.
- Run only on real shipped features.
- Writing to `knowledge/` needs your confirmation.
- If there is genuinely no data, the honest output is "need-more-data, here is what to instrument."
