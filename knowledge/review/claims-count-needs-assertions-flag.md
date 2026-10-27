---
module: docs-claims-check.sh, review loop (code-reviewer)
tags: [docs-claims, assertion-count, readme, review-round, skipped-check, drift, merge]
problem_type: bug
provenance: USR-008 merge (refactor/maintainer-tools-repo-only), README fix 53a7676, 2026-10-27
reuse_count: 0
created: 2026-10-27
---

# A fix that adds test cases needs the claims check WITH --assertions

## Problem
Review round 1 of USR-008 added 6 assertions to tests/skills-lint.test.sh. The README kept
"1517 assertions". Round 2 approved, and the drift surfaced only at merge time, which cost a
reset of local main, a README commit and two regenerated review records.

## Symptoms
`docs-claims-check.sh` (no flag) ends with "every countable claim matches the tree" while the
README number is wrong. Only `--assertions` reports `DRIFTED: assertions , README says 1517,
the tree has 1523`.

## What didn't work
Running the claims check without the flag after a fix round. It prints
`skipped: assertion count (re-run with --assertions ...)` one line above the green summary,
and that line is easy to read past: the summary speaks for the checks that ran, not for all.

## Solution
After any change that adds, removes or splits test cases, run
`bash scripts/docs-claims-check.sh --assertions` (it runs every suite, about 5 to 6 minutes)
before recording "claims match", and update the README number in the same commit as the tests.

## Why it works
The plain run counts files (programs, suites); only `--assertions` executes the suites and
counts `ok` lines, plus `SKIP <n>` cases added back, so the number is the same on every machine.

## Prevention
Treat a "skipped:" line as "not checked", never as part of a green result. In a review record,
name the flag the claims check ran with. Changing a number after review also re-stales review
records under the installed 0.3.5 merge gate (no plain-prose exemption there), so catching it
before the review ends is much cheaper than at merge.

## Example
USR-008: README 1517 -> 1523 (1521 executed + 2 skipped in tests/ledger-backup.test.sh on this
shell, added back by the check).
