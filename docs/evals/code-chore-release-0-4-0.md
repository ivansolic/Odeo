---
artifact: release-0.4.0
type: code
branch: chore/release-0.4.0
reviewed_commit: fc89405
artifact_version: 2
date: 2026-10-22
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
---

# Code review: chore/release-0.4.0, round 2

## Scope reviewed

- `git rev-parse --short HEAD` is fc89405. New since round 1 (d44afb4): one commit,
  fc89405, touching README.md (2 hunks) and INSTALL.md (1 hunk), 5 lines in, 5 out.
- Round 1's checks on d44afb4 (version bump, "releases after 0.3.5" claims against history,
  affected users, snapshot equals d44afb4 minus the denylist) are unaffected by fc89405 and
  not repeated. The public snapshot is rebuilt from the merged commit by the orchestrator;
  only fc89405 itself was checked for internal-path references.
- Tests not re-run: the change is prose only, no script or test touched.

## Checks

1. **Round-1 Important fixed.** README.md:113 and INSTALL.md:137 now read "Projects set up
   before 0.3.1, whatever Odeo version you run now", so the scope is project age, not the
   version updated from. A 0.3.5 user with 0.2.x-era projects is now addressed. The body
   sentences still parse after the retitle ("refresh their git guards once. Their hooks
   ...").
2. **No stale copy left.** `grep` for "0.3.0 or earlier" / "Updating from 0.3" in tracked
   README/INSTALL/hooks/scripts: no hits outside eval records (historical, correct as
   history) and an unrelated worktree under `.claude/worktrees/` (another branch, not this
   tree).
3. **Round-1 nitpick fixed.** README.md:228 tree comment now reads "stale backup, long
   todo.md", which matches scripts/session-end-check.sh:73-81 (todo.md line count against
   `LEDGER_MAX_LINES`).
4. **Nothing new.** fc89405 adds no file path, no internal-path reference, no em or en
   dash (checked on the diff), and no claim beyond the round-1 scope. Commit message is
   Conventional Commits and English.

## Findings

### Critical

None.

### Important

None.

### Nitpicks

- **README.md:114-115**, the retitle lengthened line 114 past the paragraph's wrap width
  (line 116-117 were already long before this commit). Cosmetic in rendered Markdown;
  rewrap the paragraph if you touch it again.
- Round-1 PR-body nitpick (lead the 0.4.0 release note with the bin/ removal and the guard
  refresh) is carried by the public PR body per the dispatcher; not verifiable here.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## Verdict

APPROVE. The upgrade note now addresses the readers the 0.4.0 bin/ removal affects, the
tree comment matches the script, and fc89405 introduces nothing new.

## History

- Round 1 (d44afb4): 11/12, APPROVE WITH COMMENTS. One Important (upgrade heading scoped
  to the version updated from, not to project age), two nitpicks.
- Round 2 (fc89405): 12/12, APPROVE. Regression note: better (+1, correctness 1 -> 2). The
  Important and the README tree nitpick are fixed; the PR-body nitpick moves to the public
  PR body.
- Previous release record (`code-chore-release-0-3-5.md`) was 11/12; this release ends one
  higher.
