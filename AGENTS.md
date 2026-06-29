# AGENTS.md, Claude Cofounder operating baseline

The canonical rules for how this system works. Claude Code reads `AGENTS.md`
automatically (before `CLAUDE.md`), so these rules govern both this repo and any
project that carries this file. Skills and agents reference it; the safety-critical
rules are also embedded in their bodies so they hold even when this file is absent
(for example, installed purely as a marketplace plugin).

## Agent-first workflow
- **Commands/skills orchestrate; agents execute.** A skill is the entry point; it
  dispatches specialized agents (e.g. `developer`, `code-reviewer`) that do the
  heavy work in isolation and return a result. The human holds the gates.
- The lifecycle, top-down by altitude, each step explicit, nothing fires blindly:
  **`/discover` -> `/plan` (prioritize -> roadmap) -> `/spec` (prd -> critique -> stories)
  -> `/build` -> `/merge` -> `/outcome` -> `/go-to-market`** (loop back to `/plan`).
  Incremental feature: skip to `/spec`. Trivial fix: just `/build`. These orchestrators
  chain the first-party PM skills; each is also runnable standalone.
- **Two altitudes of prioritization:** `/prioritize` + `/roadmap` rank *which epics*
  (value, portfolio level); `/stories` orders *which stories within an epic* (by
  dependency). Never conflate them.
- `/build` runs human-first (Mode A) or dispatches `developer` agents in isolated
  git worktrees (Mode B, one per story, single or parallel).
- **Autonomy is a dial; the human holds the gates.** Agents can work autonomously up
  to a gate, but **merge-to-main, ship, and sending data out always require human
  approval.** Human-in-command leverage, never a zero-human autonomous loop.

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
