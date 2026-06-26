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
- The lifecycle: discovery, PRD, design, `/build`, review, `/merge`, `/outcome`,
  `/learn`. Each step is explicit; nothing fires blindly.
- `/build` runs human-first (Mode A) or dispatches `developer` agents in isolated
  git worktrees (Mode B, one per story, single or parallel). You approve every gate.

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
- Capture verified, non-trivial, reusable solutions with `/learn` (shows the draft
  before writing); maintain with `/knowledge-refresh`.
- `~/.claude/community-knowledge/` is read-only; contribute only via
  `/contribute-lesson` (opt-in, sanitized, approval-gated).

## Privacy
- Nothing private leaves the machine without explicit approval. `/contribute-lesson`
  sanitizes, then runs `privacy-scan.sh` as a hard gate (emails, secrets, tokens,
  local paths, deny-list terms) before any PR. Block and redact or override per item.

## Style
- Strict typing; small single-purpose functions; never silently swallow errors.
- **No em dashes or en dashes in any text.** Use commas, colons, periods.
- Comments in code: English only.
