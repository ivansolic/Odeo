---
description: Ship a reviewed, merged change to the project's platform, safely. Re-checks it is green, deploys to the target in CLAUDE.md, runs a live smoke test, and keeps a one-command rollback ready. Explicit command; PRODUCTION never auto-deploys (your explicit go), staging may. Run it when you decide to ship; it makes "actually shipped" true so /odeo:outcome can follow. Example: "/odeo:deploy" (staging) or "/odeo:deploy to production".
disable-model-invocation: true
---

# Deploy (the ship step)

Take a reviewed, merged change live on the project's platform, with the safety a
ship deserves: green first, rollback ready before the deploy runs, and a live
smoke test after. `/odeo:ci` verifies; `/odeo:deploy` ships. It closes the gap before
`/odeo:outcome` (which needs something actually shipped).

**This command NEVER ships production on its own.** Production runs only when you
say so explicitly. "Tests passed", "we just merged", "the pipeline continues" are
not permission, shipping to production is the human floor (like `/odeo:merge`).

## Preconditions
- You are on the release ref (usually `main` after `/odeo:merge`, or a ref you name),
  the working tree is clean.
- Tests + typecheck are green HERE, and CI is green if it exists (check
  `.github/workflows/`; `/odeo:ci` is what generates it). A suite that has never run
  is not green.
- A deploy target is known. Read it from `CLAUDE.md` (Stack -> `Deployment:`). If
  it is still a placeholder, ASK the platform AND the exact deploy command, and
  offer to record them in CLAUDE.md. Never guess a deploy command.

## Steps
1. **Confirm the target and the exact command.** Use the project's platform CLI or
   its `deploy` script as recorded; read or ask, never invent. State which
   environment you are about to hit.
2. **Environment.** STAGING is the default and proceeds on a plain "deploy".
   PRODUCTION requires an explicit "yes, production" from you, every time.
3. **Rollback ready FIRST.** Capture the current live version / deploy id before
   anything changes, and state the exact one-command rollback out loud, so a bad
   deploy is reversible in one step.
4. **Deploy.** Run the confirmed command; show its output.
5. **Live smoke test.** Hit the deployed URL / health endpoint (or the project's
   smoke command) and confirm it actually responds and serves the new change. If
   it FAILS, offer the rollback immediately and stop. A deploy that did not pass
   its smoke test is NOT "shipped".
6. **Record it.** Append the deploy to `docs/deploys/history.md` (date, env, ref,
   URL, platform, the rollback command with NO embedded secret or token), so
   `/odeo:start` and `/odeo:outcome` can see what shipped and when. Committed, it is the
   ship history, so it never carries a credential.
7. **Close.** Confirm what is live where. Offer `/odeo:outcome` "in about a week, once
   there is real usage data", the loop that checks the change actually worked.

## Worked example
"/odeo:deploy" (a web app whose CLAUDE.md says Deployment: Vercel)
- Preconditions: on main, clean, `pnpm test` + typecheck green, CI green.
- Target: Vercel; command from CLAUDE.md. Environment: staging (default).
- Rollback ready: current staging deploy id noted; rollback command stated.
- Deploy runs; smoke test hits the preview URL, gets 200 and the new copy.
- Recorded to `docs/deploys/history.md`. "Live on staging: <url>."
- Then "/odeo:deploy to production" -> STOPS for your explicit yes; on yes, same steps
  against production, smoke test, record, rollback ready throughout.

## Rules
- Production is the human floor: never auto-triggered, never inferred from a green
  build or a merge. Staging may be offered.
- Never call a deploy shipped until its live smoke test passes; if it fails, the
  rollback is offered immediately.
- The rollback is ready BEFORE the deploy runs, not improvised after.
- Secrets and env belong to the platform; never print them and never commit them.
- The platform and its commands are the project's (from CLAUDE.md or asked); this
  skill orchestrates and gates, it hardcodes no vendor.
