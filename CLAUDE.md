@AGENTS.md

## Developing this repo (claude-cofounder itself)
- Stack: bash + markdown. No build step.
- Tests: `bash tests/privacy-scan.test.sh` (and any other `tests/*.test.sh`). Must be green.
- After editing anything under `skills/`, `agents/`, `bin/`, or `project-templates/`,
  re-run `./install.sh` so `~/.claude` and `~/.claude-templates` reflect the change.
- This repo dogfoods its own tools via `.claude/{agents,skills}` (symlinks to the
  canonical `agents/` and `skills/`).
- Solved, reusable problems are banked in `knowledge/` via `/learn`, one file per
  fact with YAML frontmatter (module/tags/problem_type/provenance/reuse_count/created);
  search `knowledge/` before re-solving. It is internal (denylisted from publish);
  share an individual lesson outward only via `/contribute-lesson` (sanitized, gated).
- House rule: no em dashes or en dashes (see AGENTS.md).
