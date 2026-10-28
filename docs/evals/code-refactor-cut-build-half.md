---
artifact: USR-009
type: code
branch: refactor/cut-build-half
reviewed_commit: 86b93ea
date: 2026-10-28
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 10/12
---

# Code review: USR-009, the build half leaves the plugin (round 2, at 86b93ea)

Round 2 reviews the delta `1e7bb4b..86b93ea` (d0e7b53, 9e13d12, cc1d20c, 24ab63f, 86b93ea)
against the round 1 findings, the approved plan (`magical-wondering-micali.md`), story USR-009
and PRD-002 R2/R4/R11. Round 1 findings on code outside this delta still hold. Output language:
en (handed at dispatch).

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
- none

## Important (should fix)
- none

## Nitpicks (optional)
- `tests/git-guards.plugin.test.sh:14-17`: the header says "case 1 is attributed by M2, not
  M1", but the re-measured line under it says M2 fails only cases 2 and 3. I measured M2
  (`ls -1td` -> `ls -1trd` in `scripts/install-git-guards.sh`) in a scratch clone: 2 FAIL,
  cases 2 and 3; case 1 stays green. So no recorded mutant now attributes case 1, and the
  header asserts a coverage claim no mutation backs (project rule: coverage claims are proven
  by mutation). Fix: either name and measure a mutant that turns case 1 RED (for example,
  search `bin/` before `scripts/`), or write that case 1 has no attributing mutant.
- `.claude/maintainer/tests/removed-items.test.sh:10-11`: the comment says
  `docs-claims-check.sh` adds the SKIP back into the assertion total. That script counts only
  `tests/*.test.sh` (line 80), and this suite now lives in `.claude/maintainer/tests/`, so the
  sentence is stale. Fix: drop the docs-claims clause and keep "prints SKIP <n>".
- `hooks/odeo-context.sh:234-235`: the new pre-push message is correct, but a user who
  deliberately keeps the old hook (to keep their main protection) is told about it at every
  session start, since `run_legacy` keeps no reminded-state. The lead sentence also still says
  "offer to refresh them" while this clause says there is nothing to refresh. Natural owner:
  USR-010 (it extends this exact check), as a remind-once state or a wording split.
- Carried from round 1, still open by decision: `scripts/odeo-migrate-legacy.sh:54-59` matches
  retired names by name only (follow-up, not a regression).

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12 reached. The nitpicks are comment accuracy and a USR-010 follow-up; none rises to
Important.

## What's good
- Round 1 Important 1 is fixed at the root. `guards_nudge` now splits `hook:pre-commit`
  (refresh through the shipped installer, which names only pre-commit) from `hook:pre-push`
  (no longer installed, the user may move it aside, the agent must not). My round 1
  reproduction now gets the new message: a version-1 pre-push hook, then the shipped
  installer, then `odeo-context.sh legacy SessionStart`. `pre-push-lookup.test.sh` now asserts:
  - the new text;
  - that an old pre-push is NOT sent to the installer;
  - that pre-commit advice never mentions pre-push.
- Round 1 Important 2 is fixed. Every non-hook entry must have existed at `dev-phase-archive`,
  every hook must have been in the archived `hooks.json`, and files (7) and hooks (2) are
  counted. I ran M5 (typo), M6 (invented extra line) and M7 (dropped hook line) in a scratch
  clone. They go RED with exactly the counts the header states (1, 2, 1). With the tag deleted,
  the suite prints `SKIP 40` instead of passing silently.
- Round 1 Important 3 is fixed for the whole class, not one instance. Both suites that read
  internal files (`removed-items`, `maintainer-tools`) moved to `.claude/maintainer/tests/`, and
  the published `tests/` now holds 35 suites, matching the README.
- The setup-project renumbering is consistent (1, 2, 3, 4, with the in-text pointer
  "step 2"). The setup-project and guide prose edits drop build-phase claims; the
  skill-reviewer judges their wording.
- No added line carries an em or en dash.

## Verified (by me, on 86b93ea)
- `git diff 1e7bb4b 86b93ea` read in full.
- Scratch clone: removed-items baseline exit 0 (86 ok). M5, M6, M7 RED as stated. No-tag
  path: exit 0 with `SKIP 40`. Clone reset after each mutant; the working repo was not touched.
- Measured M2 on `tests/git-guards.plugin.test.sh`: 2 FAIL (cases 2, 3), basis of nitpick 1.
- Ran `.claude/maintainer/tests/pre-push-lookup.test.sh` and `tests/odeo-context.test.sh`:
  both exit 0.
- Not re-run: the full suite (the dispatcher ran it green on 24ab63f; 86b93ea changes comments
  only, which I confirmed in the diff).

## History
- Round 1 (1e7bb4b): APPROVE WITH COMMENTS, 10/12 (correctness 1, testing 1). Three Important
  findings:
  - the stale guards nudge, which sent an old pre-push to an installer that no longer writes it;
  - the removed-items test did not enforce "nothing else" (typo, extra line and dropped
    file/hook lines survived);
  - that suite was red in the published snapshot.
- Round 2 (86b93ea): all three fixed and verified. 12/12, better than round 1 (+2). Remaining
  items are nitpicks.
