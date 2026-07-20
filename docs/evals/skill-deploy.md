---
artifact: skill-deploy
type: skill
artifact_version: 1
date: 2026-07-20
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
---

Findings: none blocking. Explicit-command skill (`disable-model-invocation: true`),
scored against the explicit-command bar (what-you-get + when + example, NOT
"Use when...").

Per-criterion evidence:
- Trigger clarity 2: description opens "Ship a reviewed, merged change to the
  project's platform, safely." + when ("Run it when you decide to ship") + example
  ("/deploy" (staging) or "/deploy to production"). Correct explicit-command format,
  no "Use when..." (correctly avoided).
- Structure 2: essence -> Preconditions -> Steps -> Worked example -> Rules; 65
  lines, well under 500; no supporting files, so the one-level-deep rule is moot.
- Worked example 2: real values, "a web app whose CLAUDE.md says Deployment: Vercel",
  concrete `pnpm test`, preview URL 200, and the production stop-for-yes path.
- Precision 2: exact paths (`docs/deploys/history.md`, `.github/workflows/`,
  CLAUDE.md Stack -> `Deployment:`); "Never guess a deploy command"; no TBDs.
- Safety integration 2: references the guardrails without weakening them, "shipping
  to production is the human floor (like `/merge`)"; "A deploy that did not pass its
  smoke test is NOT 'shipped'"; "The rollback is ready BEFORE the deploy runs".

Map duty: PASS. `/deploy` is in `docs/system-map.md` section 6 (Build & integrate),
row present with PRODUCTION-is-your-go framing. AGENTS.md human floor (section 1)
sharpened to name it: "[I] Ship/deploy (`/deploy`): PRODUCTION never auto-triggers
(the human floor, like `/merge`); staging may be offered. A ready rollback before
the deploy runs and a passing live smoke test after, or it is not 'shipped'."

Vendor neutrality: PASS. No hardcoded vendor in logic; platform + command read from
CLAUDE.md or asked (Rules line: "it hardcodes no vendor"). Vercel appears only as a
concrete value inside the worked example, which the standard requires (real values,
no placeholders). No version-pinned model names anywhere.

Safety framing soundness: PASS. Production human floor is unambiguous (explicit "yes,
production" every time, "not permission" list mirrors `/merge`). Rollback-before-deploy
is step 3 before deploy is step 4. Smoke-test-after is step 5 and a failed smoke
explicitly is not "shipped" and offers rollback.

## History
- v1 (2026-07-20): initial review of the new `/deploy` skill on branch
  feature/deploy. PASS 10/10. No prior record.
