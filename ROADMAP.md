# Roadmap

This is a direction, not a promise. Order and scope may change. Ideas and votes
welcome, open an issue.

## Now (shipped or in progress)

- Whole-lifecycle workflow: discovery → PRD → design → `/build` → review →
  `/merge` → `/outcome` → `/learn`.
- Hybrid agentic build: human-first (Mode A) or `developer` agents in isolated
  worktrees (Mode B), with human gates.
- Compounding knowledge: `/learn`, `/knowledge-refresh`, the `knowledge/` base.
- Security baseline (OWASP/GDPR-aware) applied to all code.
- Optional design layer (tokens, `ux-design` skill, `design-reviewer`).
- Contribution layer: this roadmap, `CONTRIBUTING.md`, templates, code of conduct.
- Central learning, light: `/contribute-lesson` (opt-in, sanitized, approval-gated)
  feeding a shared community knowledge base.

## Next

- **First-party PM set** built from public frameworks (Cagan, Torres, the 3 C's,
  INVEST, RICE, ProductCompass-style PRDs), in our own words and namespace, so the
  PM layer is no longer a hard external dependency. Built in batches, after real
  usage tells us what is actually needed.
- Richer presets (more stacks) so non-developers start from a known-good config.
- Smoother `/outcome` signal ingestion (analytics connectors).

## Later / exploring

- Central learning beyond git: a curated, maintained community knowledge base that
  ships improvements back to everyone on update. (Backend deferred until there is
  real contribution volume; git PRs are the bootstrap.)
- Plugin/marketplace packaging for one-step install.
- Optional compliance helpers (SOC 2, pen-test guidance) for teams that need them.

## How to influence this

- Open a feature issue with the problem you hit.
- Contribute a lesson with `/contribute-lesson`.
- Send a PR. See `CONTRIBUTING.md`.
