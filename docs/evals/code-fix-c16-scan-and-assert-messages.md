---
artifact: fix-c16-scan-and-assert-messages
type: code
branch: fix/c16-scan-and-assert-messages
reviewed_commit: c5db129
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

`git diff main...HEAD` (main 0308528, HEAD c5db129), two commits, four files:
`scripts/skills-lint.sh`, `tests/skills-lint.test.sh`, `tests/merge-gate.test.sh`,
`tests/odeo-migrate-legacy.test.sh`. There is no plan for this branch. The contract is the
three round-2 nitpicks in `docs/evals/code-refactor-scripts-dir.md`. I checked each one
against the code:

1. C16 supporting-file detection is anchored at `ROOT/skills/`. `SKILLS_DIR="$ROOT/skills/"`
   is passed through the environment, and the test is `index($ARGV, SKILLS_DIR) == 0`. Body
   mode builds every file path from the same literal `$ROOT`, through
   `"$ROOT"/skills/*/*.md` and `"$ROOT"/agents/*.md`. So the prefix comparison holds for
   trailing slashes and relative roots, and it cannot match a `skills/` segment above ROOT.
   The nested-checkout test does reproduce the old bug: the old regex matched
   `/skills/nest/` in `<b>/skills/nest/odeo/agents/debugger.md`. Closed.
2. The merge-gate and case-16 assertions now match the real refusal strings, which I found
   in the source. `scripts/merge-gate.sh:325` prints "do-not-touch boundary violated", and
   the shim heredoc prints "cannot run and BLOCKS". In case 16, `2>&1 >/dev/null` inside
   `$(...)` captures stderr only, and `unset` stays scoped to that substitution. Closed.
3. The `command -v perl` branch is exercised. The PATH mirror leaves out `perl*` and keeps
   PATH precedence through `! -e`. The test asserts rc 1, "perl not found", and no
   "command not found". The author's mutation, `viol` replaced by `:` giving rc 0, shows the
   mirror is complete enough for the lint to otherwise pass. Closed.

I ran one focused check: `bash tests/skills-lint.test.sh` gave 76 passed, 0 failed, in
69s. I ran it to measure the cost of the PATH mirror, which is about 1,300 `ln` forks on
this machine. The cost is acceptable. I did not re-run the full suite.

I agree that no /security-review is needed. The change is one lint check plus tests, with
no input boundary, no auth, no upload and no data access.

## Critical (must fix before merge)

None.

## Important (should fix)

None.

## Nitpicks

- `tests/skills-lint.test.sh`, the PATH mirror loop: an empty PATH element (`a::b`, or a
  leading or trailing colon) makes `"$pdir"/*` expand to `/*`. A relative element such as
  `.` or `bin` creates symlinks that are relative to `$noperl`, so they dangle. Neither
  applies to the current PATH, and the loop fails loudly rather than open: a missing tool
  shows up as "command not found", which the test rejects. Fix: start the outer loop with
  `[[ $pdir == /* ]] || continue`.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached. The one nitpick is test hardening for PATH shapes this environment does not
have.

## What's good

- Each fix is the minimal one that the finding asked for.
- Every new assertion names the mutation that was seen RED, which is the repo's coverage
  rule.
- The no-perl test rules out the obvious false pass, where some other tool is missing, by
  also asserting the absence of "command not found".

## History

- No previous record exists for this branch. It closes the three round-2 nitpicks of
  `docs/evals/code-refactor-scripts-dir.md` (branch refactor/scripts-dir, 12/12 APPROVE WITH
  COMMENTS). All three are verified closed. The status is the same, 12/12, with one new
  nitpick in the added test.
