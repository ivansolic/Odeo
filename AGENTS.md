# AGENTS.md, Claude Cofounder operating baseline

The canonical rules for how this system works. Claude Code reads `AGENTS.md`
automatically (before `CLAUDE.md`), so these rules govern both this repo and any
project that carries this file. Skills and agents reference it; the safety-critical
rules are also embedded in their bodies so they hold even when this file is absent
(for example, installed purely as a marketplace plugin).

## Agent-first workflow
- **Commands/skills orchestrate; agents execute.** A skill is the entry point; it
  dispatches specialized agents (e.g. `architect`, `builder`, `code-reviewer`)
  that do the heavy work in isolation and return a result. The human holds the gates.
- The lifecycle, top-down by altitude, each step explicit, nothing fires blindly:
  **`/discover` -> `/plan` (prioritize -> roadmap) -> `/spec` (prd -> critique -> stories)
  -> `/build` -> `/merge` -> `/outcome` -> `/go-to-market`** (loop back to `/plan`).
  Incremental feature: skip to `/spec`. Trivial fix: just `/build`. These orchestrators
  chain the first-party PM skills; each is also runnable standalone.
- **Two altitudes of prioritization:** `/prioritize` + `/roadmap` rank *which epics*
  (value, portfolio level); `/stories` orders *which stories within an epic* (by
  dependency). Never conflate them.
- `/build` runs human-first (Mode A) or, in Mode B, a fixed pipeline: the
  `architect` (structurally read-only) writes each story's plan as a contract
  (`docs/plans/`, per the plan format), the human approves it, then `builder`
  agents execute it exactly in isolated git worktrees (one per story, single or
  parallel). **A builder never runs without an approved plan.** Plan conflicts =
  stop and ask, never improvise. Story-level planning inherits product-level
  architecture; changing that is a human/ADR decision.
- **Autonomy is a dial; the human holds the gates.** Agents can work autonomously up
  to a gate, but **merge-to-main, ship, and sending data out always require human
  approval.** Human-in-command leverage, never a zero-human autonomous loop.
- **Every loop has a verifier and a stop condition.** Any autonomous loop (build,
  optimize, fix) must pair its action with a verifier (tests, reviewer, acceptance
  criteria, a measured signal) and an explicit stop: a clear done-signal plus a max
  number of iterations, after which it stops and reports rather than spinning. A loop
  that can't stop itself isn't autonomous, it's just expensive. Define the done-signal
  before starting; broaden it beyond "compiles" to the criteria that matter (acceptance
  criteria, and where relevant plain-language quality targets like "loads fast",
  "works for keyboard/screen-reader users").

## Security baseline (applies to ALL code, non-negotiable)
- Validate all input at the boundary; allowlist over blocklist.
- Parameterized queries only; never build queries by string concatenation.
- Encode output for its context (prevent XSS); never bypass framework escaping
  without justification. Never pass user input to shell/eval/paths unchecked.
- Never roll your own auth or crypto. Authorize on the server, every endpoint,
  deny by default; check object-level access (IDOR). Rate-limit auth + expensive
  endpoints.
- Secrets never in code, logs, errors, or commits. If one leaks, rotate it.
- Classify and minimize PII; encrypt in transit (TLS) and sensitive data at rest;
  hash passwords (bcrypt/argon2). No PII or secrets in logs.
- Never expose stack traces or internals to users. Set security headers; enable CSRF
  for cookie sessions. Validate uploads by content, size-limit, store outside webroot.
- For changes touching auth, input, uploads, payments, or data access: run
  `/security-review` before committing, in addition to `code-reviewer`.

## Testing (TDD-lite)
- For logic with clear rules (backend, API, services, validation, calculations, bug
  fixes): write the test from the acceptance criterion first, watch it fail, then
  implement (RED, GREEN, REFACTOR). The `test-driven-development` skill auto-applies.
- Skip test-first for UI layout, visual exploration, prototypes, trivial fixes; add
  tests after instead.
- **Never weaken or edit a test just to make it pass; fix the implementation.**

## Git discipline
- Never commit or push directly to `main`/`master`; use a branch.
- Conventional Commits (`type(scope): description`). One logical change per commit.
- **Integrate with rebase, not merge commits.** Rebase onto latest `origin/main`,
  resolve conflicts by intent + tests (never weaken a test), then merge. Rebase only
  your own unshared branch. `/merge` automates this.
- Never commit secrets, `.env`, credentials, or large binaries.

## Knowledge (local + community)
- Before non-trivial work, search the project's `knowledge/` (and
  `~/.claude/community-knowledge/` if present) and reuse a documented solution.
- The knowledge family: **`/learn`** (write a verified lesson to local `knowledge/`,
  shows the draft first) · **`/knowledge-refresh`** (audit/prune local) ·
  **`/contribute-lesson`** (send a sanitized lesson OUT, opt-in, privacy-scanned,
  approval-gated) · **`/sync-community`** (pull the shared base IN; read-only).
- `~/.claude/community-knowledge/` is read-only here; only `/contribute-lesson` writes
  to it (via PR + maintainer curation). What's private vs shared: your memory and local
  `knowledge/` stay on your machine; only an approved, sanitized lesson ever leaves.

## Privacy
- Nothing private leaves the machine without explicit approval. `/contribute-lesson`
  sanitizes, then runs `privacy-scan.sh` as a hard gate (emails, secrets, tokens,
  local paths, deny-list terms) before any PR. Block and redact or override per item.

## Style
- Strict typing; small single-purpose functions; never silently swallow errors.
- **No em dashes or en dashes in any text.** Use commas, colons, periods.
- Comments in code: English only.

## Talking to the user (plain language)
- All user-facing output, skill questions, reports, and replies, leads with **plain
  language**; say what the user gets, not jargon. The audience includes non-developers.
  This is the `ux-writing` standard applied to how the system communicates, not just UI copy.
- When a technical term matters, give the **plain meaning first**, then optionally the
  term in a short labeled aside: "loads in 0.9s now, fixed how it fetches data
  (technical: removed an N+1 query)." Showing the aside is a per-project preference
  ("teach me as I go"), set in `/setup-project`; default off.
