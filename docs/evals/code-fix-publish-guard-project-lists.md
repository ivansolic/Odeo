---
artifact: fix-publish-guard-project-lists
type: code
branch: fix/publish-guard-project-lists
reviewed_commit: 3886e41
artifact_version: 2
date: 2026-09-24
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 9/12
---

Round 2 review of `git diff main..HEAD` (47035f3, ee33ff4, 3886e41) at 3886e41. The
round-2 delta, `git diff ee33ff4..HEAD`, was read in full.

## Verdict
APPROVE. Both round-1 Important findings and both nitpicks are fixed, each one proven by a
mutation I ran myself. No new finding.

## Regression note (v1 9/12 -> v2 12/12: improved)
- Correctness 1 -> 2: publish-snapshot.sh no longer carries its own copy of the list rule.
  It asks the guard (`publish-guard.sh --print-lists`) which denylist to strip with, and
  the guard's later check runs from the same directory with the same environment, so the
  strip and the check read the same files. I re-ran the round-1 reproduction (plugin-copy
  scripts with their own lists, a project that denylists `secret/` and tracks
  secret/x.md): the result is now exit 0, and the snapshot holds README.md and the two list
  files but not secret/x.md. Round 1 gave exit 1 on this branch and a leak on main.
- Testing 1 -> 2: my surviving mutant (allowlist read from the guard root, MA) now fails
  5 cases (3b-3e). Snapshot strips with its own denylist (MB): 2 FAIL (3e). Refresh
  without keeping a copy (M11): 1 FAIL (case 15). I reproduced all three in a scratch
  copy made with `git archive`, not in the repo.
- Conventions 1 -> 2: every coverage claim in the test headers is now backed by a
  mutation that was actually run, as CLAUDE.md requires.
- Nitpicks: the guard comment now says each env override wins on its own. A shim refresh
  first moves the old shim into the same legacy folder the moved items use, so a hand
  edit is kept.

## The deviation, accepted
The builder did not export the resolved pair from publish-snapshot to the guard, because
that mutant stayed green. I agree. The guard is deterministic for a given directory and
environment, and publish-snapshot does not change directory between `--print-lists` and
the check. So `--print-lists` makes the guard the single owner of the rule, and exporting
the pair would be a mechanism no test can tell apart. What remains is small and fails
closed: if a later edit made publish-snapshot change directory before the check, the
guard would block the snapshot (an unstripped internal path) rather than let it through,
and case 3e would go red.

## Observed, out of scope (existing behaviour, fails closed)
Running publish-snapshot from a subdirectory of a project fails with exit 1 and produces
no snapshot. This is the same on main: `git archive HEAD` works relative to the current
directory, while the list entries are relative to the repo root. It is not a leak.

## Evidence
- Full suite with </dev/null: 38 suites, 1249 ok, 0 suites failed.
- skills-lint: all invariants hold. docs-claims-check --assertions: 1249, matches the README.
