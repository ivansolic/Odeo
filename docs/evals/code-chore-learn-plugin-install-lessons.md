---
artifact: knowledge/claude-code/hook-output-cap-split-into-parts.md, knowledge/testing/watchdog-by-pid-not-alarm.md, knowledge/testing/fixture-must-differ-from-the-default.md, knowledge/review/flaky-is-a-hypothesis.md, tests/odeo-migrate-legacy.test.sh (bounded helper)
type: code
branch: chore/learn-plugin-install-lessons
reviewed_commit: 7cc6d04
artifact_version: 2
date: 2026-09-26
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

## Artifact

Range `main..HEAD` (2 commits: 715fce8, 7cc6d04) on `chore/learn-plugin-install-lessons`.
Round 2 reviewed `git diff 715fce8..7cc6d04`: the four knowledge entries and the `bounded`
helper plus its comment in tests/odeo-migrate-legacy.test.sh. The round 1 checks still apply to
the unchanged text. Threat model: false or overstated claims in a knowledge base that future
sessions trust.

## Verification run (round 2)

- Watchdog mechanism: the entry and the test comment now state the measured behaviour. The
  alarm survives exec (50 self-execs, rc 142), and on macOS each execve restarts the countdown
  (5.4s with the exec vs 3.0s without; Darwin 25, bash 3.2; other OSes not checked). This
  matches my round 1 measurements (5.5s / 3.1s, and 2s after 50 self-execs). The claim is
  scoped to what was measured.
- Watchdog snippet: `>/dev/null 2>&1` is on the watchdog subshell in both the entry and the
  test. In round 1 I measured this form: a captured echo takes 0s and a real `exec "$0"` loop
  still gets rc 143.
- tests/odeo-migrate-legacy.test.sh re-run at 7cc6d04: ALL PASS, 60 ok, rc 0, 22s.
- Flaky entry example: case 13 pipes `docs/plans/x.md\0README.md\0`, which is 26 bytes. The
  550-byte figure matches the M9 note at line 23. Case 14 asserts that an internal path is
  refused (rc 1). "Why it works" is correct: exec keeps fds, `3<&-` closes the listing.
- Fixture entry example: a mutation in a clean `git archive` copy. The baseline case passes;
  with `cp -p` changed to `cp` it fails with "expected '644', got '600'", exactly as stated.
- Hook cap wording: "each string on its own" is quoted verbatim from the raw hooks.md (line
  941, fetched in round 1). The Example names cases 1 and 7, which exist and do what is claimed.
- Frontmatter: all six fields are present in all four files. No em or en dashes.

## Findings

None open. Both round 1 Importants and all nitpicks are resolved.

## History

- v1 (715fce8): REQUEST CHANGES 10/12. Important: a false alarm mechanism ("bash drops the
  inherited alarm across exec"), and the watchdog snippet held a command-substitution pipe
  open for 10s. Nitpicks: missing SKILL.md body sections, "per hook" wording.
- v2 (7cc6d04): APPROVE 12/12, improved (+2). The mechanism was replaced with measured, scoped
  behaviour in both the entry and the test comment. The watchdog output is redirected, and the
  missing sections, wording and test pointer were added.
