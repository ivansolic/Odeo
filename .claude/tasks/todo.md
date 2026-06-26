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
- [ ] Embed the security/workflow discipline into skill/agent bodies (hybrid baseline for marketplace users)
- [ ] Update docs (README/WORKFLOW/BEGINNERS/INSTALL) for plugin install + /namespacing + new structure
- [ ] Add a marketplace.json / marketplace listing + test `claude --plugin-dir`
- [ ] Dash-check docs; commit locally (no push)

## Review
(to fill in after)
