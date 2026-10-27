---
artifact: USR-008
type: code
branch: refactor/maintainer-tools-repo-only
reviewed_commit: 53a7676
date: 2026-10-27
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

# Code review: USR-008, maintainer tools move to .claude/ (round 2 record, regenerated at 53a7676)

## Why this record was regenerated
The round 2 record reviewed 7cd8bb4. Two commits landed after it: ce98773 (the eval records
only) and 53a7676, which changes one number in `README.md:239`, "38 suites, 1517 assertions"
to "38 suites, 1523 assertions". I verified the delta myself:
`git diff 7cd8bb4 53a7676 -- . ':(exclude)docs/evals'` is exactly that one line, nothing
else outside `docs/evals/`. `git grep` finds no other 1517 left in the tree.

The drift was a miss in my round 2 review. Round 1's fix (7cd8bb4) added 6 assertions to
`tests/skills-lint.test.sh` and did not update the README count. I ran
`docs-claims-check.sh` WITHOUT `--assertions` (see Verified below), so the assertion count was
never checked and I recorded "matches the tree". It did not. The mode that catches it is the
slow one, and I skipped it. Lesson for this reviewer: when a fix adds test cases, run
`docs-claims-check.sh --assertions` before recording the claims as matching.

Claims check at 53a7676, run by me: `bash scripts/docs-claims-check.sh --assertions`, rc 0,
about 5.5 minutes. Programs 25, suites 38, programs with own suite 25, assertions 1523
(2 assertions in 1 case of `tests/ledger-backup.test.sh` were skipped on this shell, which
refuses SHELLOPTS from the environment, and added back by the check). "every countable claim
matches the tree".

Effect on scores: none. The fix is correct and complete, and it is a docs number only. The
round 2 Important finding (migrator test covers 2 of 4 retired names) is untouched by this
delta and still open, so testing stays at 1. Verdict unchanged.

## Round 2 review (7cd8bb4), carried forward unchanged

Base b783368. Plan: USR-008 section of the approved plan (magical-wondering-micali).
Round 1 reviewed d3a0b46 (REQUEST CHANGES 8/12). This round reviews the fix commit 7cd8bb4
(`git diff d3a0b46 7cd8bb4`) and re-checks the branch as a whole against the plan.

Regression: better (8/12 -> 11/12; correctness, security and conventions 1 -> 2; testing
stays at 1 for a different gap, found this round).

## Round 1 findings, status

1. `skills/build/SKILL.md:275` dead `${CLAUDE_PLUGIN_ROOT}/scripts/boundary-check.sh`: FIXED.
   The planned edit is made, and the new lint C5b (`scripts/skills-lint.sh:102-109`) requires
   a plugin-path run to exist in `scripts/`. Mutation (C5b loop emptied): the new case goes RED.
2. Moved agent and skill fell out of lint: FIXED. C6, C7, C11, C12, C13 reach `.claude/agents`
   and `.claude/skills`. I re-ran all five removals as mutations: each one turns exactly its own
   `flags` case RED, and the cases assert the named rule fired, not just exit 1.
3. CI skipped the moved suites: FIXED (`.github/workflows/checks.yml:37-38`, nullglob). Not
   run on a CI runner here. A vacuous empty loop is still caught by the next step, the
   documented-counts check.
4. `/merge` ran the branch's own gate: FIXED (`.claude/skills/merge/SKILL.md:20-28`).
   Verified in a temp clone:
   - main WITH `.claude/maintainer/`, branch whose own gate is `exit 0`: main's copy ran,
     REFUSED, rc 1. The branch copy run directly returned rc 0, so the branch copy really
     was bypassed.
   - main WITHOUT the folder (this branch's situation): `fatal: pathspec`, then rc 127.
     Fails closed.
   - no local `main` (fresh clone): `fatal: not a valid object name`, then rc 127. Fails
     closed.
5. Nit `.gitignore` denylist: FIXED, allowlist. `git check-ignore` shows settings.json,
   settings.local.json, worktrees/, tasks/todo.md and tasks/lessons.md ignored. New files
   under maintainer/, agents/ and skills/ can be tracked. The 6 tracked files stay tracked.
6. Nit migrator path splitting: FIXED, it loops over names (`scripts/odeo-migrate-legacy.sh:58-70`).
   The legacy suite is green. See the new Important finding for the coverage this exposed.

## Findings (round 2)

Important:
1. `tests/odeo-migrate-legacy.test.sh:67-73,93-94`: the fixture plants only 2 of the 4
   retired names (`.claude/skills/merge`, `bin/merge-gate.sh`). In a full-tree copy I applied
   two mutations: `RETIRED_AGENTS=""` and `RETIRED_BIN="merge-gate.sh"`. The suite stays
   ALL PASS under both. So the old `~/.claude/agents/code-reviewer.md` and
   `~/bin/boundary-check.sh` copies are recognised only because the list says so, and no
   test covers it. Since `agents/code-reviewer.md` and `scripts/boundary-check.sh` left the
   tree, the RETIRED list is the ONLY thing that still catches them. Round 1 missed this
   (I recorded the list as covered). Fix: in `make_home`, add
   `echo odeo > "$h/.claude/agents/code-reviewer.md"` and
   `printf '#!/bin/sh\n' > "$h/bin/boundary-check.sh"`, and add both paths to the case 2
   moved list. Both mutations above then go RED. This is a code change, so the record must
   be regenerated after it.

Nitpicks:
- `scripts/skills-lint.sh:105`: the C5b regex catches only the braced form
  `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh`. Probed: it misses
  `$CLAUDE_PLUGIN_ROOT/scripts/merge-gate.sh`, `"${CLAUDE_PLUGIN_ROOT}"/scripts/merge-gate.sh`
  and a non-.sh program (`scripts/` ships `token-report.py`). For the first two, pass two's
  `.claude/maintainer/` fallback then accepts the bare name silently. No current instance:
  every plugin-path run in the C5 sources uses the braced form. Fix:
  `grep -oE 'CLAUDE_PLUGIN_ROOT\}?"?/scripts/[A-Za-z0-9_.-]+'`, plus one fixture per form.
- `scripts/skills-lint.sh:114,116`: `LOCAL_SKILL_FILES` is collected and never read (dead
  code). C9 (non-empty description) and C8 do not reach `.claude/skills/merge`. Fix: feed it
  into C9, or delete the variable.
- `scripts/skills-lint.sh:181` vs `:213`: C13's guard was widened to
  `-d agents || ${#LOCAL_AGENT_FILES[@]} -gt 0`, but C12's guard is still `-d agents`. Fix:
  use the same condition for both.
- `.claude/skills/merge/SKILL.md:23-27`: bsdtar exits 0 on empty input, so "no local main"
  and "main has no gate" both end in the same rc 127 "No such file". The model could take
  the plugin fallback when main merely is not checked out locally. Every path still fails
  closed. The temp dir is never removed. Fix: check first with
  `git rev-parse -q --verify main:.claude/maintainer/merge-gate.sh` and give a distinct
  message for each case, then `rm -rf "$g"` after the run.
- Named residual, same class as round 1 finding 4: the `/merge` instructions are loaded from
  the branch checkout (`.claude/skills/merge/SKILL.md`), so a branch that edits step 0 can
  point it back at its own gate. Bounded: the edit shows in the reviewed diff, and the human
  invokes `/merge`. Structural closure, if wanted: main's merge-gate refuses a branch that
  touches `.claude/maintainer/` or `.claude/skills/merge/` unless a human explicitly
  overrides.
- `scripts/spec-gate.sh:79` ("KEPT IN SYNC with scripts/merge-gate.sh") points a sync
  instruction at a path that no longer exists. Fix: `.claude/maintainer/merge-gate.sh`.
  README's tree (`README.md:205,209`) and `docs/eval-framework.md:187` still list the gate
  under `scripts/`; the plan puts docs mentions in USR-022.

## Verified (round 2, at 7cd8bb4)
- `bash scripts/skills-lint.sh`: all invariants hold, rc 0.
- `tests/skills-lint.test.sh` 94/0.
- `.claude/maintainer/tests/merge-gate.test.sh` 88/0, `boundary-check.test.sh` 4/0.
- `tests/odeo-migrate-legacy.test.sh` ALL PASS; `tests/maintainer-tools.test.sh` rc 0 (24 ok).
- `docs-claims-check.sh` (without `--assertions`) matches the tree. This was not enough: the
  assertion count had drifted (1517 documented, 1523 real). Fixed in 53a7676, see above.
- Lint mutations M1 to M6 (C5b, C6, C7, C11, C12, C13): each turned exactly its own case RED.
  The scratch copy also failed the "actual repo" self-check, but that failure was there with
  no mutation applied, because the scratch tree holds only scripts/ and tests/.
- The array idiom `"${LOCAL_AGENT_FILES[@]:+...}"` expands to separate words with 2 elements
  and to no words when empty, on bash 3.2.
- merge-gate run from the temp dir still reads the CALLER's repository
  (`cd "$(git rev-parse --show-toplevel)"`, line 47). It finds main's boundary-check through
  `dirname BASH_SOURCE`.

## History
- Round 1, d3a0b46: REQUEST CHANGES, 8/12 (correctness 1, security 1, performance 2,
  readability 2, testing 1, conventions 1). 4 Important, 2 nitpicks:
  1. `skills/build/SKILL.md:275` ran a `${CLAUDE_PLUGIN_ROOT}/scripts/boundary-check.sh` that
     no longer exists, and the widened C5 hid it.
  2. The moved agent and skill fell out of lint C6, C7, C11, C12, C13.
  3. CI did not run `.claude/maintainer/tests`.
  4. `/merge` ran the branch's own gate (cwd-relative), the class of
     `knowledge/install/guard-lookup-never-repo-relative.md`.
  Nits: `.gitignore` denylist under `.claude/`; the migrator split `$ROOT` on spaces.
- Round 2, 7cd8bb4: APPROVE WITH COMMENTS, 11/12. All six round 1 items fixed and verified
  (mutations, temp-clone gate runs). New: 1 Important (migrator test covers 2 of 4 retired
  names, mutation-proven) and 6 nitpicks.
- Record regenerated at 53a7676: APPROVE WITH COMMENTS, 11/12 (same). Delta is the README
  assertion count 1517 -> 1523, a drift my round 2 missed because I ran the claims check
  without `--assertions`. Verified with `--assertions`: rc 0, assertions = 1523. Regression:
  same.
