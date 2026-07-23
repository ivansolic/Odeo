---
artifact: USR-001
type: code
branch: feature/usr-001-language-guard
artifact_version: 3
date: 2026-07-23
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

# Code review, USR-001 no-leak guardrail

Round 3 (final) re-review of commit `5f76cdd` on branch
`feature/usr-001-language-guard`.

## Verdict
APPROVE

## R2 -> R3, what moved
- **R2 IMPORTANT (empty-`PATHS[@]` unbound-variable crash on the documented
  branch/commit-only usage under bash 3.2 + `set -u`): FIXED and verified at
  BOTH loop sites.** Commit `5f76cdd` changes the validation loop (now line 325)
  and the check loop (now line 344) from `for p in "${PATHS[@]}"` to
  `for p in "${PATHS[@]+"${PATHS[@]}"}"`. Verified empirically on the actual
  runner (GNU bash 3.2.57 arm64-apple-darwin, macOS default shell):
  - `bash bin/language-guard.sh --branch feature/ok` now prints
    "language-guard: machine surfaces clean." and exits 0 (previously crashed at
    the validation loop with `PATHS[@]: unbound variable`, exit 1).
  - `bash bin/language-guard.sh --commit "feat(auth): x"` exits 0 clean.
  - Revert experiment (both guards reverted to the naive form, run under bash
    3.2 + `set -u`): dies with `line 330: PATHS[@]: unbound variable`, exit 1,
    at the FIRST (validation) loop, confirming that site was the crash point and
    is now guarded. The second loop is equally guarded by the same idiom.
  correctness 1 -> 2.
- **R2 testing gap (path-less branch/commit usage untested): FIXED.** Case 19
  adds four assertions with NO path: `--branch feature/ok` -> exit 0;
  `--commit "feat(auth): x"` -> exit 0; a non-ASCII branch -> exit 1 naming
  surface "branch"; `--commit "feat(Auth): x"` -> exit 1 naming surface "scope".
  Verified these genuinely lock the fix: pointed the suite at a reverted-guard
  copy of the script and all four assertions turn RED, the two clean cases fail
  on exit 1 (crash) instead of 0, and the two bad cases fail because the crash
  in the validation loop aborts before the branch/commit checks run, so the
  expected surface string never prints. With the guard in place all four pass.
  testing 1 -> 2.

## Idiom sanity check (no regression introduced)
`"${PATHS[@]+"${PATHS[@]}"}"` word-splits identically to a plain `"${PATHS[@]}"`
when PATHS is non-empty, and expands to nothing (no empty element) when PATHS is
empty. Confirmed on the guarded script: single path clean -> 0; two paths clean
-> 0; `--branch` + path together -> 0; path containing a space handled as one
argument -> 0; nonexistent path -> 2 ("path not found"); no args at all -> 2
(usage). No legitimate single/multi-path case is mishandled.

## R1/R2 items re-confirmed closed
- **R1 CRITICAL (locale-dependent fail-open on uppercase machine tokens):
  still closed.** All range checks route through `matches_ascii_pattern`
  (`LC_ALL=C grep -qE "^(...)$"`) and `is_ascii` (`LC_ALL=C`). Suite runs the
  uppercase fixtures (`Id:`, `BadName`, `BadDir`, `Auth`) under the default
  locale plus `en_US.UTF-8` and `de_AT.UTF-8` (both installed here, loop
  exercised), all exit 1. Corpus (`docs/plans docs/evals skills bin`) exits 0.
- **R1 IMPORTANT / NITPICK:** tests-for-the-right-reason and the empty
  `--branch`/`--commit` skip comment both remain in place.
- Structural invariants intact: fail-closed non-ASCII core, top-level-key-only
  frontmatter parsing, filename prefix stripping, `model_tier`-only enum,
  prose body never read, exit codes 0/1/2, CRLF handling, `set -uo pipefail`,
  `bash -n` clean.

## Critical (must fix before merge)
- None.

## Important (should fix)
- None.

## Nitpicks (optional)
- None outstanding. The build is clean at the machine-surface contract level.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (up from 10/12).

## Ceiling
12/12, reached. No dimension below 2, no Critical, no Important. The R1 central
fail-open and the R2 bash-3.2 empty-array crash are both fixed and locked by
tests that fail on revert.

## Known context (not a finding)
Three gate tests fail on this runner due to an environment git-identity issue,
unrelated to this build; not scored against the artifact.

## What's good
- The fix is minimal and correct: the exact bash-3.2-safe idiom for empty arrays
  under `set -u`, applied uniformly to both loops with an explanatory comment.
- The added tests lock the behavior in both directions (pass and fail) and were
  proven to fail on revert, not decorative.
- The whole guard keys off machine tokens and never reads prose, honoring the
  "language-independent" contract end to end.

## History
- v1 (2026-07-23, Opus 4.8 strongest): REQUEST CHANGES, 9/12. Locale-dependent
  allowlist ranges fail open on uppercase machine tokens under UTF-8 locales;
  tests passed for the wrong reason.
- v2 (2026-07-23, Opus 4.8 strongest): REQUEST CHANGES, 10/12. R1 critical and
  both R1 minors fixed and verified. New finding: pre-existing empty-`PATHS[@]`
  unbound-variable crash on the documented branch/commit-only usage under bash
  3.2, untested. Regression vs v1: better (+1, no dimension regressed).
- v3 (2026-07-23, Opus 4.8 strongest): APPROVE, 12/12. R2 empty-array crash
  fixed at both loop sites with `"${PATHS[@]+"${PATHS[@]}"}"` and verified on
  bash 3.2.57; case 19 locks it (fails on revert). Idiom preserves single/multi/
  spaced-path handling. R1 locale critical re-confirmed closed. Regression vs
  v2: better (+2, no dimension regressed).
