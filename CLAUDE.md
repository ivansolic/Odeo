@AGENTS.md

## Developing this repo (claude-cofounder itself)
- Stack: bash + markdown. No build step.
- Tests: `bash tests/privacy-scan.test.sh` (and any other `tests/*.test.sh`). Must be green.
- After editing anything under `skills/`, `agents/`, `bin/`, or `project-templates/`,
  re-run `./install.sh` so `~/.claude` and `~/.claude-templates` reflect the change.
- This repo dogfoods its own tools via `.claude/{agents,skills}` (symlinks to the
  canonical `agents/` and `skills/`).
- House rule: no em dashes or en dashes (see AGENTS.md).
