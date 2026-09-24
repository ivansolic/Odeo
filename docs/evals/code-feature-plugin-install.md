---
artifact: plugin-install
type: code
branch: feature/plugin-install
reviewed_commit: 5c8a9c1
date: 2026-09-24
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
record_version: 3
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 11/12
verdict: APPROVE
---

## Scope reviewed

`main..5c8a9c1`. Round 3 adds one commit on top of `ce18d4b`: `5c8a9c1 fix(plugin): the
migration runs only from a plugin root, and its shim never loops`. It touches five files:
`bin/odeo-migrate-legacy.sh`, `install.sh`, `tests/install-bin.test.sh`,
`tests/odeo-migrate-legacy.test.sh` and `README.md` (a suite count). I read the whole diff.

## Verification
- **Suite:** 39/39 green when run with `</dev/null`. `bin/skills-lint.sh` and `bin/docs-claims-check.sh` are green.
- **Round-2 repro re-run against 5c8a9c1.** The setup is a fake HOME with a `~/bin` copy of the script, the user's own `~/bin/my-own-backup-tool`, `~/bin/secret-scan.sh`, `~/.claude/skills/build` and `~/.claude/odeo-docs`.
  - (a) The `~/bin` copy now refuses the dry run and `--apply` (exit 2), and nothing in the home changes.
  - (b) Run from a plugin root, the migration lists and moves `~/.claude/skills/build`, the stale `~/bin/odeo-migrate-legacy.sh` and `~/bin/secret-scan.sh`. The user's own tool stays in place.
  - (c) With the plugin root removed, the shim blocks with exit 1 and a message; a PID watchdog confirms it exits. A hand-made worst case, with `fallback=` pointing at `~/bin` itself, also blocks with exit 1 instead of looping.
  - The shim bakes `fallback=` and `config_at_migration=` as `%q` values.
- **Round-3 mutation recipes reproduced** in a `git archive` copy (`/tmp/odeo-mut3`), each as recorded:
  - M6 (no plugin-root check): 3 FAIL.
  - M7 (drop `-ef`): 1 FAIL, 143 from the watchdog.
  - The unmutated copy returns ALL PASS.
- **Repo safety:** the repository was never a mutation target, and no stray processes were left.

## Findings

### Critical
- None.

### Important
- None. The round-2 Important and its four nitpicks are closed:
  - The plugin-root refusal is in place.
  - `install.sh` skips the script, and `install-bin.test.sh` names it as the one exception.
  - `run_if` skips the shim itself through `-ef`.
  - Paths are baked with `%q`, and the config dir from migration time is remembered.
  - The shim marker is matched on line 2 only.
  - `ODEO_SHIM_FALLBACK_OVERRIDE` is removed.

### Nitpicks
- None new.
- Process reminder, not a finding: `docs/evals/code-feature-plugin-install.md` and `docs/evals/skill-new-project.md` are untracked. merge-gate refuses untracked records, so commit them before /merge.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## History
- v1 (3b3b405): REQUEST CHANGES, 9/12. Four Importants:
  - the migration dropped the secret gate in pre-plugin projects;
  - `CLAUDE_CONFIG_DIR` was ignored;
  - a symlinked global warned every session;
  - the stale install.sh instruction in CLAUDE.md.
- v2 (ce18d4b): REQUEST CHANGES, 11/12. All v1 Importants closed. New Important: the migration run from a `~/bin` copy moved the user's own files, left the duplicates in place, and its shim could exec itself forever.
- v3 (5c8a9c1): APPROVE, 12/12. The v2 Important and its nitpicks are closed, verified by repro and by mutation.
- Trajectory: 9 -> 11 -> 12, better each round.
