---
artifact: usr-008-009-followups
type: code
branch: chore/usr-008-009-followups
reviewed_commit: a1fd31b
date: 2026-10-29
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
record_version: 1
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
previous_total: none
verdict: APPROVE WITH COMMENTS
---

## Scope reviewed

`ab35665..a1fd31b`, nine commits, fresh review (the USR-008 and USR-009 loops ended on approve).
No earlier record exists for this branch, so there is no regression comparison.

## Mutation results (each mutant applied, test run, file restored, tree verified clean)

| Mutant | Target | Result |
|---|---|---|
| C5b: closing brace mandatory | scripts/skills-lint.sh:108 | 1 FAIL, "bare $CLAUDE_PLUGIN_ROOT" case only |
| C5b: optional closing quote dropped | scripts/skills-lint.sh:108 | 1 FAIL, "quoted-root" case only |
| C5b: `.sh` suffix restored | scripts/skills-lint.sh:108 | 1 FAIL, "non-.sh program" case only |
| C12 guard back to `[[ -d agents ]]` | scripts/skills-lint.sh:184 | 1 FAIL, the new "no agents/ directory" case |
| C13 guard back to `[[ -d agents ]]` | scripts/skills-lint.sh:216 | 0 FAIL (GREEN): not covered, see Important |
| M14 RETIRED_AGENTS without code-reviewer.md | scripts/odeo-migrate-legacy.sh:57 | 2 FAIL, as the header claims |
| M15 RETIRED_BIN without boundary-check.sh | scripts/odeo-migrate-legacy.sh:59 | 2 FAIL, as the header claims |
| git-guards M10 (bin/ globs before scripts/) | scripts/install-git-guards.sh | 3 FAIL (cases 1, 2, 3), as the header claims |
| git-guards M2 (oldest first) | scripts/install-git-guards.sh | 2 FAIL (cases 2, 3), as the header claims |

Other checks: README count confirmed by `docs-claims-check.sh --assertions` (1422, includes 2 added-back
SKIPs from ledger-backup); the removed-items comment is correct (docs-claims-check only runs `tests/*.test.sh`);
the spec-gate comment now names a path that exists and carries `frontmatter_field`; the system-map row
matches `skills/guide`.

## Critical (must fix before merge)
- none

## Important (should fix)
- scripts/skills-lint.sh:216 and tests/skills-lint.test.sh:124-129, the new test comment justifies the C12
  guard as matching C13 ("as C13 does"), but C13's own guard has no test: reverting line 216 to
  `[[ -d "$ROOT/agents" ]]` leaves all 93 assertions green. The class "guard drifts from its sibling"
  is exactly what this commit fixed for C12; C13 remains the unguarded half. Fix: add one case, a root
  with no `agents/` and a repo-only agent that lacks the output-language rule, asserting `flags ... C13`;
  record its mutation in the header. Follow-up, not a blocker, since it is pre-existing and not in the diff.

## Nitpicks (optional)
- scripts/skills-lint.sh:108, the name class `[A-Za-z0-9_.-]+` plus the trailing strip handles `a.sh.`,
  `foo-` and `.py` correctly (checked: `a.sh.`->`a.sh`, `token-report.py",`->`token-report.py`,
  `scripts/*.sh` and `scripts/<name>` ->no match, `scripts/` alone ->no match, no real name ends in `.` or `-`).
  The residual: prose like `scripts/x.sh-based` yields the name `x.sh-based` and a false C5 violation.
  None in the tree today; accept, or note it in the comment.
- tests/git-guards.plugin.test.sh:29-33, "the only mutant found that turns case 1 RED" is an absence claim
  over mutants not enumerated. Narrow to "M10 is the mutant that turns case 1 RED" (M1, M2 and M3 were
  shown not to).
- .claude/skills/merge/SKILL.md:20-26, step 0 behaves correctly in both failure cases (verified in a
  scratch repo: no `main` -> first rev-parse empty; `main` without the gate -> second empty, and the
  `git archive` path would have failed with rc 127 anyway; with both present the gate ran from the
  throwaway copy, the copy was removed and the gate's rc was preserved via `(exit "$rc")`). The two
  checks cost one line each in the skill and are the right split. No change needed.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 2/2  -> total 11/12  (threshold: >=9, no zero)

## Ceiling
12/12. Testing is 1 only because the C13 half of the guard pair is not covered; one added case lifts it.

## What's good
- Every new test header carries its mutation recipe, and every claim I re-measured held exactly (counts and
  which cases go RED), including the correction that case 1 of git-guards is attributed to M10, not M1 or M2.
- The C5b rewrite removes a class (spelling of the root, program extension) rather than adding a spelling;
  each of its three axes has its own isolated test, each RED on exactly its case.
- The C12 fix also removes a dead `LOCAL_SKILL_FILES` and says why the agent array stays.
- Merge step 0 now names which of two distinct conditions failed, and cleans up its temp copy.

## History
First review of this branch; no prior record.
