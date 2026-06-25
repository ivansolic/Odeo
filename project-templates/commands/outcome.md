---
description: Post-ship outcome check for a shipped feature. Reads the PRD success criteria, gathers REAL available signals (analytics, errors, qualitative), compares actual vs intended, and gives a verdict (keep / iterate / kill / need-more-data). Run about a week after shipping, when there is real data. Closes the build loop. Never fabricates data.
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
6. **Feed the loop (with your approval):** capture the outcome as a `/learn` entry (e.g. "approach X worked / failed in production for problem Y"), and promote or demote related `knowledge/` entries based on the real result. This is the outcome to knowledge link: knowledge is judged by real outcomes, not just code-match.

## Safety rules
- Never fabricate or estimate data; only real sources.
- Run only on real shipped features.
- Writing to `knowledge/` needs your confirmation.
- If there is genuinely no data, the honest output is "need-more-data, here is what to instrument."
