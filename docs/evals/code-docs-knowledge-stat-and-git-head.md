---
artifact: docs-knowledge-stat-and-git-head
type: code
branch: docs/knowledge-stat-and-git-head
reviewed_commit: 0058348
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

# Code review: docs/knowledge-stat-and-git-head (round 2)

Scope of round 2: the delta `afe0068..0058348`, two commits.
- 7679457 `docs(knowledge)`:
  - renames and rewrites the stat entry as
    `knowledge/testing/fallback-in-command-substitution-keeps-stdout.md`
  - narrows `knowledge/fixes/git-head-mtime-is-not-last-sync.md`
- 0058348 `fix(tests)`: comment-only corrections in `tests/config-dir.test.sh:48` and
  `tests/set-project-language.test.sh:12-14`.

Output language: en (handed at dispatch).

## Verdict
APPROVE WITH COMMENTS

## Round-1 findings: closure
1. **Closed (Critical).** The entry is now built around the mechanism the CI log shows:
   - The fallback runs, and `$(...)` captures the output of both commands.
   - The title, Problem, Symptoms, "What didn't work" and "Why it works" all say so.
   - "Why it works" states the real rule: `a` must fail AND print nothing to stdout.
   - The BSD half is measured (rc=1, 0 bytes on stdout), and it matches my round-1 run.
   - The Solution code is unchanged and correct.
   - The new Prevention bullet, "assert the whole captured value (an exact match)", is
     accurate: `assert_eq` is an exact comparison, and that is what exposed the bug.
   - The old filename is referenced nowhere outside `docs/evals`.
2. **Closed (Important).** `date -r` is dropped. The `sed -i -e` trap is named exactly as
   measured: exit 0, file edited, stray `f-e` backup. It is correctly called a "related"
   trap, not the same one.
3. **Closed (follow-up).** Both test comments now describe the stdout-capture mechanism.
   The change is comment-only: `git diff -U0` shows no changed line outside a `#` comment.
   The 08e734c commit message stays as history, which is correct.
4. **Closed (nitpick).** The FETCH_HEAD claim now names `--dry-run` and
   `--no-write-fetch-head`, the two exceptions measured in round 1.
5. **Closed (nitpick).** The order is labelled a general recommendation, and the entry
   states what Odeo ships. Checked at the 0.3.2 release commit 469b0f3:
   `hooks/odeo-context.sh:269-272` goes from the stamp to HEAD. "FETCH_HEAD is an open
   decision" matches the logged DECIDE item at `.claude/tasks/todo.md:31`.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `knowledge/testing/fallback-in-command-substitution-keeps-stdout.md:13-17`: the GNU half is
  stated as fact, but no GNU binary ran here. That is well supported, but it is an
  inference. The support:
  - GNU documents `-f` / `--file-system` as taking no argument, so `%Lp` can only be read
    as a file operand.
  - The CI log shows the report for `$f` followed by the fallback's `644`, which proves
    the non-zero exit.

  What is not observed is the per-file error for `%Lp`, which `2>/dev/null` hid. This is
  not an overclaim, but the entry marks measurements elsewhere and not here. **Fix
  (optional):** append "(GNU side read from the CI log, not run locally)" to the Problem
  paragraph, the way the git entry labels its measured claims.
- `knowledge/testing/fallback-in-command-substitution-keeps-stdout.md:5`: the `provenance:`
  line is 107 characters; every other line in both entries fits in 100. **Fix (optional):**
  wrap it as an indented continuation, which
  `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md` already does.

## Evidence checked (round 2)
- `scripts/language-guard.sh` on both knowledge files, on the branch name, and on the
  `fix(tests)` subject: clean, rc=0. On the two `.test.sh` paths it reports a filename slug
  failure. That comes from how the guard handles the `.test.sh` naming pattern, which
  every test file in the repo shares. Those files are not new and were not renamed here,
  so this is not a finding against this change.
- No em or en dashes in either entry.
- No test suite was re-run: the test change is comment-only, verified by diff, and the
  builder reports both suites pass.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, and nothing structural caps it. The verdict is APPROVE WITH COMMENTS rather than
APPROVE because of the two optional nitpicks, mainly the unlabelled GNU inference.

## What's good
- The Critical was closed by rewriting the claim to fit the evidence. The builder checked
  the log independently instead of taking the finding on trust.
- The entry now also records how the mistake was caught: an exact assertion, read to its
  end. That is a better lesson than the original one.
- The wrong explanation was fixed at the point of use as well, in the test comments, and
  kept in a separate commit. The unmeasurable GNU claim was flagged to the reviewer rather
  than hidden.

## History
- Round 1 at afe0068: 9/12, REQUEST CHANGES (correctness 0, conventions 1).
  - Critical: the stat entry said the `||` fallback never ran and `stat` exited 0. Run
    36688443398 shows the fallback's `644` at the end of both captured values.
  - Important: `date -r` did not fit "same trap". Separately, the test comments on main
    carried the same wrong explanation (follow-up).
  - Nitpicks: FETCH_HEAD exceptions; the Examples order differed from what Odeo ships.
  - Independently measured: BSD stat, date and sed behaviour on this Mac, and a git
    HEAD/FETCH_HEAD probe in a temp dir (git 2.50.1).
- Round 2 at 0058348: 12/12, APPROVE WITH COMMENTS. Every round-1 finding is closed; two
  optional nitpicks remain. Regression check: improved (9 -> 12).
