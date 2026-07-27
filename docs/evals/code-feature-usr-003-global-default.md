---
artifact: USR-003
type: code
branch: feature/usr-003-global-default
artifact_version: 2
date: 2026-07-27
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
---

# Code review, USR-003 global default language at install

Re-review at HEAD `bb539d1` on `feature/usr-003-global-default`. The v1 review
(APPROVE 12/12) covered three commits (`84a4138` helper, `db8c9f3` install.sh,
`06571c0` integration test). This v2 re-verifies the single follow-up commit
`bb539d1`, which closes both v1 nitpicks in `install.sh`. Diff reviewed:
`git diff 06571c0..HEAD`.

## Verdict
APPROVE

## Scope reviewed (v2 delta)
`bb539d1` touches only `install.sh`, two lines:
- **Nit-1 (line 27):** the arg-parse `*)` case changed from `shift` (silent
  swallow) to `echo "install: unknown option: $1 ..." >&2; exit 1`.
- **Nit-2 (line 140):** the interactive language write gained
  `|| { echo "    ! could not set language '$_code'"; exit 1; }`, matching the
  `--lang` path's guard (line 128).

Nothing else changed. All v1 conclusions on the helper, the idempotence gate,
the symlink guard, the writer/reader format contract, and the tests carry
forward unchanged (those files are byte-identical to v1).

## Adversarial re-checks on the delta, all cleared with evidence

**Nit-1, unknown-flag guard is safe and pre-filesystem.** The parse loop is at
`install.sh:22-29`, ABOVE every filesystem action (first mutation is
`rm -rf ~/.claude-templates` at line 43). So an unknown option aborts before any
copy/symlink/write, no partial install. Verified empirically in a sandbox:
`--lnag de` -> rc=1 with `install: unknown option: --lnag ...` on stderr, and
`~/.claude`, `~/.claude-templates`, `~/bin` are all absent afterward (zero FS
mutation). Critically, the pre-fix silent-`shift` bug (a typo'd `--lnag de`
would drop `--lnag`, treat `de` as another unknown flag, and install silently as
English) is now impossible: the typo errors loudly instead of installing the
wrong language.

**No regression across the full arg matrix** (each run in a fresh temp HOME,
`</dev/null`, `COMMUNITY_KNOWLEDGE_REPO=/nonexistent`):
- `--link` -> rc=0, writes `en` (non-interactive default)
- `--lang de` -> rc=0, writes `de`
- `--lang de --link` -> rc=0, writes `de`
- `--link --lang de` -> rc=0, writes `de` (both orders)
- `--lang fr` -> rc=0, writes `fr`
- bare -> rc=0, writes `en`
- `--lang` (no value) -> rc=1, nothing written (pre-existing guard intact)
- `--lnag de` (typo) -> rc=1, nothing written (new guard)

**Nit-2, interactive write guard is `set -e`-safe and happy-path-neutral.** Under
`set -euo pipefail`, `cmd || { ...; exit 1; }` consumes the non-zero status, so
`set -e` never fires spuriously; on failure it prints one line and `exit 1`
cleanly rather than a bare `-e` abort. On success the helper returns 0 and the
`||` branch is skipped, so the happy path is byte-for-byte the prior behavior,
confirmed: sandboxed `--lang de` install still rc=0 and still writes
`output_language: de`. `_code` is always one of en/de/hr/fr (the `case` default
is `en`), so this branch cannot fail today; the guard is defensive and brings the
interactive path into consistency with the `--lang` path. No new failure mode
introduced.

**Error paths do not corrupt a partial install.** The `--lang` guard (line 128)
and the interactive guard (line 140) both live in step 4a, which runs after the
file copies; but each is a deliberate, messaged `exit 1` on a language-write
failure, not a silent mid-write. Since `set-global-language.sh` is itself
idempotent and validates before writing (v1 finding 1, unchanged), a failed
write leaves the global config untouched, not half-written.

## Verification run (v2)
- Full suite: **19/19 test files pass** (`bash tests/*.test.sh`, all rc=0).
- `bin/skills-lint.sh`: **clean** ("all invariants hold", rc=0).
- Sandboxed install `HOME=$(mktemp -d) COMMUNITY_KNOWLEDGE_REPO=/nonexistent
  bash install.sh --lang de </dev/null`: **rc=0**, global file contains
  `output_language: de`.

## Critical (must fix before merge)
- None.

## Important (should fix)
- None.

## Nitpicks (optional)
- None. Both v1 nitpicks are closed by `bb539d1`.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. The idempotence heart remains correct and locked by a
line-count assertion; the two real correctness edges (`--link` symlink into a
tracked file, non-interactive hang) remain guarded and verified; `set -euo
pipefail` handling is `-u`-safe and `-e`-safe on every branch, including the two
new/tightened error paths. Conventions is, if anything, cleaner post-fix: the CLI
now fails loud on unknown flags (matches the "never silently swallow" house rule)
and the two write sites share one guard shape.

## What's good
- The unknown-flag guard converts a silent-wrong-language failure mode into a
  loud rc=1, and it sits before any filesystem action, so a typo cannot leave a
  half-installed or mis-configured machine.
- The interactive write guard now mirrors the `--lang` path exactly, so both
  human and flag entry points fail the same visible way.
- Delta is minimal (two lines), touches nothing outside the flagged nitpicks, and
  leaves every v1 invariant (idempotence, symlink guard, writer/reader contract,
  hermetic tests) intact.

## History
- v1 (2026-07-27, Opus 4.8 strongest [1m]): APPROVE, 12/12. First review of the
  three-commit build; two stylistic nitpicks raised (silent unknown-flag swallow;
  interactive write missing an `|| exit` guard), neither dimension-capping.
- v2 (2026-07-27, Opus 4.8 strongest [1m]): APPROVE, 12/12. Re-review at HEAD
  `bb539d1`, which closes both v1 nitpicks in `install.sh`. Regression vs v1:
  **SAME score (12/12), nitpicks closed.** No new issue introduced by the fixes;
  full suite 19/19, skills-lint clean, sandboxed `--lang de` install rc=0 writing
  `output_language: de`. Record regenerated at HEAD so the merge-gate sees a
  non-stale artifact.
