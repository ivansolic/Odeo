# Task: make Claude Cofounder a marketplace plugin (agent-first)

Reference: EveryInc compound-engineering (skill-driven orchestration). Decisions:
- Baseline delivery = HYBRID (GitHub install.sh ships global CLAUDE.md; marketplace
  ships skills/agents with discipline embedded + optional setup step).
- Migrate commands -> skills NOW (preserve /names; deliberate ones get
  disable-model-invocation: true to stay explicit).

## Plan
- [x] Add `.claude-plugin/plugin.json` manifest
- [x] CONFIRM end-state repo layout (agents/ + skills/ at root; init-project's reduced role)
- [x] Migrate `project-templates/commands/*.md` -> `skills/<name>/SKILL.md`
      (all got disable-model-invocation: true to stay explicit)
- [x] Consolidate agents to plugin root `agents/`
- [x] Update dogfood symlinks (.claude/agents -> ../agents; .claude/skills -> ../skills; commands removed)
- [x] Update `init-project.sh` (scaffolds project-specific only; plugin provides tools)
- [x] Update `install.sh` (installs skills + agents user-level; still lays baseline)
- [x] Re-test scaffolding (UI + --no-ui) and the privacy-guard tests, all pass
- [x] Embed discipline (AGENTS.md canonical + CLAUDE.md shim + rules inline in skill/agent bodies)
- [x] Update docs (README + INSTALL) for plugin-native layout + AGENTS.md baseline
- [ ] DEFERRED to the very end (after the whole product is built): marketplace listing
      (marketplace.json) + `claude --plugin-dir` smoke test + commands->skills namespacing notes in WORKFLOW/BEGINNERS

## Review
- Restructured into a plugin-native, agent-first layout: skills/ + agents/ at root,
  .claude-plugin/plugin.json, AGENTS.md as the canonical baseline, CLAUDE.md shim.
- Commands migrated to skills (explicit-only via disable-model-invocation).
- init-project scaffolds project-specific only; install.sh delivers tools globally + baseline.
- Security preserved and strengthened: baseline now in global/CLAUDE.md + AGENTS.md +
  project-templates/CLAUDE.md + embedded in skill/agent bodies. Privacy guard intact.
- Scaffolding (UI + --no-ui) and privacy tests green. Nothing pushed.

## Review
(to fill in after)
