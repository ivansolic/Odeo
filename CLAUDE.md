@AGENTS.md

## Developing this repo (Odeo itself)
- Stack: bash + markdown. No build step.
- Tests: `bash tests/privacy-scan.test.sh` (and any other `tests/*.test.sh`). Must be green.
- Coverage claims are proven by mutation, not asserted. When a test or guard is described
  as catching a class of failure, break the target and watch it go RED before writing the
  claim. RED-first applies to invariant guards too: the mutation IS the RED. A guard never
  seen failing is false confidence.
- Develop with the plugin loaded from this clone: `claude --plugin-dir .` from the repo
  root. Edits under `skills/`, `agents/`, `bin/`, `hooks/` or `project-templates/` apply
  at the next session or `/reload-plugins`, with no version bump. Do not re-run
  `./install.sh`: its home-folder copies load everything a second time.
- This repo still dogfoods through `.claude/{agents,skills}` (symlinks to the canonical
  `agents/` and `skills/`); that pre-plugin path goes away together with `install.sh`.
- Solved, reusable problems are banked in `knowledge/` via `/learn`, one file per
  fact with YAML frontmatter (module/tags/problem_type/provenance/reuse_count/created);
  search `knowledge/` before re-solving. It is internal (denylisted from publish);
  share an individual lesson outward only via `/contribute-lesson` (sanitized, gated).
- House rule: no em dashes or en dashes (see AGENTS.md).

Odeo's own artifacts stay English whatever the user's global default is (PRD-001 R4), so this override is deliberate and not a leftover.
output_language: en
