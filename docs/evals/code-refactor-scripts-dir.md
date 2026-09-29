---
artifact: refactor-scripts-dir
type: code
branch: refactor/scripts-dir
reviewed_commit: 0f02744
date: 2026-09-29
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

## Scope reviewed

Round 2 covers `git diff 0abbffb..0f02744`, one commit (`fix(scripts): guards never use a
project's own scripts, C16 strict and loud`), 15 files, plus whether each round-1 finding
is closed. The round-1 review of 850262f and 0abbffb (`git diff main...refactor/scripts-dir`)
stands for everything this delta does not touch; its findings are summarized under History.

I re-ran three suites because the delta changed them and I wanted to see them myself:
`tests/skills-lint.test.sh` (72 passed), `tests/odeo-migrate-legacy.test.sh` (ALL PASS,
including the three case-16 lines) and `tests/bin-wrappers.test.sh` (ALL PASS).
`scripts/skills-lint.sh .` is clean on the real repo. I did not re-run the full 39.

## Round-1 findings: closure

1. **Closed.** Hooks and merge-gate no longer fall back to a project's own `scripts/` or
   `bin/`.
   - `scripts/install-git-guards.sh:64`: `odeo_tool` now ends at `$ODEO_BIN_AT_INSTALL`,
     with no path relative to the repo, and the comment says why.
   - Case 10 in `tests/git-guards.plugin.test.sh` covers both `scripts/` and `bin/`.
     Each asserts that the project script did NOT run (empty LOG) AND that the warning
     still prints.
   - `scripts/merge-gate.sh:321-322`: the sibling checker is tried first, then PATH, and
     the cwd lookup is gone.
   - I checked the new merge-gate case for specificity. On the fixed gate its rc 1 is the
     boundary refusal ("do-not-touch boundary violated"). A mutant with the cwd lookup
     restored first returns rc 0 ("preconditions hold"). So the case detects exactly this
     regression and does not pass by accident.
2. **Closed.** `c16_scan` accepts a program name only right after the exact prefix
   `${CLAUDE_PLUGIN_ROOT}/scripts/`, or after `~/bin/` or `$HOME/bin/`.
   - Probed: `scripts/x`, `./x`, `$ROOT/scripts/x`, `/opt/odeo/scripts/x`,
     `$CLAUDE_PLUGIN_ROOT/scripts/x` (no braces) and `${CLAUDE_PLUGIN_ROOT}/bin/x` are all
     flagged.
   - `"${CLAUDE_PLUGIN_ROOT}/scripts/x"` passes.
   - Longer names (`my-x.sh`, `old.x.sh`, `x.sh.bak`, `tests/x.test.sh`) are left alone.
3. **Closed.** `command -v perl` is checked first, and perl's exit status is captured;
   a nonzero exit is a `viol C16`. The fake-perl case (exit 127) expects rc 1 on an
   otherwise clean root, and perl is the only thing that differs, so the case is specific.
4. **Closed.** AGENTS.md now says the plugin root is the directory that holds AGENTS.md and
   that the variable is not set in the shell. The C16 row in `docs/invariants.md` and the
   lint agree that supporting files are read raw and name no program. A supporting-file
   case written in the plugin-root form is RED.
5. **Closed.** Case 16 in `tests/odeo-migrate-legacy.test.sh` is the old shim.
   - I diffed its body against the `SHIM` heredoc in `main:bin/odeo-migrate-legacy.sh`,
     and it is byte-identical.
   - HOME is the fake home and CLAUDE_CONFIG_DIR is unset, so the leak that tripped my
     round-1 probe cannot recur.
   - It proves that stdin (5 bytes) and exit 5 go through the wrapper, and that it blocks
     once `bin/` is removed.
   - The builder's note on `bounded()` is correct. The helper backgrounds the command, and
     a background job reads `/dev/null` as stdin. Its timeout would give 143, not 1, so
     the rc-1 block assertion is not satisfied by the watchdog.

Nitpicks from round 1: all closed except the one the builder left open on purpose.
- `with_root` now uses `ENVIRON`, and case 1a places a root containing a literal `\t`.
- The nudge names both outcomes.
- `bin/token-report.py` is now a Python `os.execv` wrapper that follows symlinks through
  `realpath`.
- `INSTALL.md` has the 0.2.x note and the path form.
- The installer comment documents the downgrade ordering.
- Left open: the 0.1.0-template hooks are still not detected. That is accepted: the damage
  is bounded, because their failure is a visible WARNING.

## Critical (must fix before merge)

None.

## Important (should fix)

None.

## Nitpicks

- `scripts/skills-lint.sh`, `c16_scan`: a supporting file is detected by testing
  `$ARGV =~ m{/skills/[^/]+/}` against the absolute path. So when the plugin root sits
  under any `.../skills/<x>/` directory, every agent file counts as a supporting file.
  Reproduced: a clean root moved to `<tmp>/skills/odeo/` turned an agent's correct
  `${CLAUDE_PLUGIN_ROOT}/scripts/privacy-scan.sh` into a C16 violation. It fails loudly
  (a false RED), never open, and plugin cache paths do not contain that segment. A clone
  at `~/code/skills/odeo` would trip it. Fix: pass `ROOT` in the environment and test
  `index($ARGV, "$ENV{ROOT}/skills/") == 0`.
- The new tests check only the exit code. That covers the merge-gate case in
  `tests/merge-gate.test.sh` (rc 1) and case 16's block in
  `tests/odeo-migrate-legacy.test.sh` (rc 1). I confirmed that both 1s are the intended
  refusals, but adding an assertion on the message ("do-not-touch boundary violated",
  "cannot run and BLOCKS") would keep them specific if another refusal is added later.
- The `command -v perl` branch of C16 is not exercised; only the nonzero-exit branch is. It
  is a one-line branch; a case with a PATH that lacks perl would cover it.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold >=9, no zero)

## Ceiling

12/12, reached. The nitpicks are hardening only: none is a wrong result that fails open,
and the one that misfires does so loudly.

## History

- Round 1 at 0abbffb: 9/12, REQUEST CHANGES (correctness 1, security 1, testing 1).
  Findings:
  - The hook and merge-gate fallbacks relative to the repo let a project's own script
    stand in for Odeo's gate.
  - C16 accepted relative and other path forms.
  - C16 passed silently when perl failed.
  - The literal `${CLAUDE_PLUGIN_ROOT}` in AGENTS.md and in supporting files (both read
    raw) did not resolve.
  - There was no test of a verbatim 0.2.2 `~/bin` shim against the new layout.
- Round 2 at 0f02744: 12/12, APPROVE WITH COMMENTS. All five round-1 findings closed, each
  with a test the builder recorded as seen failing first; I independently reproduced that
  for the merge-gate case. Regression check: improved (9 -> 12).
