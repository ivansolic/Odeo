# Roadmap

This is a direction, not a promise. Order and scope may change. Ideas and votes
welcome, open an issue.

## Now (shipped or in progress)

- Whole-lifecycle workflow: discovery → PRD → design → `/odeo:build` → review →
  `/odeo:merge` → `/odeo:outcome` → `/odeo:learn`.
- Hybrid agentic build: human-first (Mode A) or a plan-first pipeline (architect plans, you approve, builders execute) in isolated
  worktrees (Mode B), with human gates.
- Compounding knowledge: `/odeo:learn`, `/odeo:knowledge-refresh`, the `knowledge/` base.
- Security baseline (OWASP/GDPR-aware) applied to all code.
- Optional design layer (tokens, `ux-design` skill, `design-reviewer`).
- Contribution layer: this roadmap, `CONTRIBUTING.md`, templates, code of conduct.
- Central learning, light: `/odeo:contribute-lesson` (opt-in, sanitized, approval-gated)
  feeding a shared community knowledge base.
- **Output language**: choose the language the system writes human-facing prose in
  (English default, plus German, Croatian, French), as a global default with a
  per-project override, while code and every machine-read surface stay English.
  Shipped: `/odeo:language` plus a guardrail that keeps commit subjects, identifiers and
  file paths English, and an advisory check that warns when a generated document's
  prose does not read as the configured language.

## Next

- **First-party PM set** built from public frameworks (Cagan, Torres, the 3 C's,
  INVEST, RICE, ProductCompass-style PRDs), in our own words and namespace, so the
  PM layer is no longer a hard external dependency. Built in batches, after real
  usage tells us what is actually needed.
- Richer presets (more stacks) so non-developers start from a known-good config.
- Smoother `/odeo:outcome` signal ingestion (analytics connectors).

## Later / exploring

- **Skill evolution from lessons**: (1) a curated pipeline where community lessons
  and rubric improvements feed `/odeo:improve` into shipped skills; (2) an opt-in
  community *skills* repo with `skill-reviewer` scoring, privacy scan, provenance,
  and isolation before anything installs. Deliberately human-gated, no
  self-rewriting skills. (Next feature after output language.)
- Central learning beyond git: a curated, maintained community knowledge base that
  ships improvements back to everyone on update. (Backend deferred until there is
  real contribution volume; git PRs are the bootstrap.)
- Plugin/marketplace packaging for one-step install.
- Optional compliance helpers (SOC 2, pen-test guidance) for teams that need them.

## How to influence this

- Open a feature issue with the problem you hit.
- Contribute a lesson with `/odeo:contribute-lesson`.
- Send a PR. See `CONTRIBUTING.md`.
