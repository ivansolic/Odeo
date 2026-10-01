---
artifact: scripts/skills-lint.sh C17 (plan_layers + comparison) + tests/skills-lint.test.sh C17 cases + docs/invariants.md C17 row
type: code
branch: feature/plan-human-layer
reviewed_commit: 4f001fa
artifact_version: 2
date: 2026-10-01
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## Artifact

Branch `feature/plan-human-layer`, read at HEAD `4f001fa` (clean tree). Scope: lint C17 in
`scripts/skills-lint.sh`, its test cases and the `clean_root` fixture in
`tests/skills-lint.test.sh`, and the C17 row in `docs/invariants.md`. Round 2 reviews the delta
`d995419..4f001fa` in that scope. The prose files are out of scope.

## Round-1 findings, verified

- **Important (one line not enforced): fixed.** `plan_layers` counts with
  `grep -c '^Plan layers:'` and flags any count other than 1 (`scripts/skills-lint.sh:294-295`).
  `grep -c` prints `0` on no match, so `n` is always numeric and `-ne 1` is well formed. The
  missing file, a wrong count and an empty list each get their own `viol` and `return 1`. The
  comparison runs only when both calls returned 0, so a broken file produces one message
  instead of a misleading "differ" message on top. New test: a second, different line in
  docs/plan-format.md wants rc 1.
- **Nit (asymmetric missing wording): fixed.** Both files go through the same
  "`<path>` is missing" message.
- **Nit (empty reported as absent): fixed.** "carries an empty 'Plan layers:' line". A list of
  only whitespace reduces to empty after the sed, so it is caught too. The test asserts the
  message.
- **Nit ("whitespace aside" loose): fixed.** The row now says runs are collapsed and that
  `A,B` and `A, B` still differ.
- **Nit (row order): fixed.** The C17 row sits after C16.

## New code checked

- The function sets a global and calls `viol` itself, which is the known
  "helper that sets a variable cannot run in a command substitution" trap. Both call sites
  (`:299-300`) call it bare and read `PL_LIST`/`$?` afterwards, and the definition carries a
  comment at the point of use. The existing tests already act as a tripwire, which is the
  mechanism the global rules ask for: if someone wraps a call in `$(...)`, `fail=1` is lost in
  the subshell and "C17 flags a missing docs/plan-format.md" returns rc 0 against a wanted 1.
  If someone redirects the output, the empty-list message test fails. This is reasoned from the
  code, not run as a mutation in this round.
- `set -uo pipefail` without `-e`: `PL_LIST` is set before any early return, so `set -u` cannot
  trip at the call site. An `if` whose condition is false returns 0, so the success path
  returns 0.
- Portability is unchanged from round 1: POSIX basic regex, plus `grep -c`.
- On the worktree at 4f001fa, skills-lint reports "all invariants hold". I did not re-run the
  39 suites; the builder reports them green.

## Findings

### Critical
- None.

### Important
- None.

### Nitpicks
- `tests/skills-lint.test.sh:331-334`: the empty-list case asserts the message but not the
  exit code. `viol` sets `fail=1`, so rc 1 follows today. Capturing `rc=$?` after the
  `$( bash "$LINT" "$d" 2>&1 )` and requiring 1 as well would make that case independent of
  the message. Optional.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## Verdict

APPROVE

## History

- Round 1 (d995419): 11/12, APPROVE WITH COMMENTS. Important: `grep -m1` did not hold the
  "one line" invariant. Four nitpicks on wording and row order.
- Round 2 (4f001fa): 12/12, APPROVE. All five items fixed and verified, two new tests. One
  optional nit on the empty-list test's exit code. Regression note: better (11 -> 12).
