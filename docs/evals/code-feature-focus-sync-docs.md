---
artifact: focus-check-hook
type: code
branch: feature/focus-sync-docs
artifact_version: 2
date: 2026-07-19
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## What this reviews
The `/focus` session edit fence added on `feature/focus-sync-docs`:
`bin/focus-check.sh` (PreToolUse deny-only hook), `tests/focus-check.test.sh`,
the `project-templates/claude-settings.json` PreToolUse wiring,
`bin/session-end-check.sh` advisory line, and the `init-project.sh` gitignore entry.

## Verdict
APPROVE. The round-1 Important (glob-active zone comparison) and both nitpicks
(missing glob test coverage, missing relative-path comment) are resolved and
independently re-verified. The safety contract (deny-only, fail-open, path-escape
resistance, injection resistance) still holds. No remaining findings.

## Test result
`bash tests/focus-check.test.sh` -> 11/11 passed, exit 0 (was 9/9 in round 1).

## Findings

Critical: none.

Important: none. (Round-1 Important resolved, see History.)

Nitpicks: none. (Both round-1 nitpicks resolved, see History.)

## Safety verification (re-probed in round 2, not assumed)
- LITERAL COMPARE: bin/focus-check.sh:66 now uses
  `[[ "$RP" == "$ZONE" || "${RP#"$ZONE/"}" != "$RP" ]]`. Verified independently:
  - zone `src`, target `srcpoison/a.ts` (prefix collision) -> DENY (the `"$ZONE/"`
    strip requires the separator, so a sibling that merely shares the prefix is not
    treated as inside).
  - zone `a[b]c`, target inside -> neutral; sibling `abc` (a glob class `[b]` would
    match) -> DENY.
  - zone `a*c`, target inside -> neutral; sibling `aXc` (a glob `*` would match)
    -> DENY.
  - zone dir itself as target -> neutral; `srcX` (no separator) -> DENY.
- GRANT: source contains zero `allow` literals (grep confirmed 0); no allow branch
  exists. Structural deny-only property intact after the edit.
- FAIL OPEN: malformed JSON and nonexistent zone dir -> empty output, exit 0.
  Re-confirmed post-edit.
- PATH ESCAPE / INJECTION: unchanged from round 1 (`..` resolution via pwd -P,
  json.dumps for the reason, argv passing). The edit only changed the inside-zone
  comparison and did not touch resolution or the emit path.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2 -> total 12/12 (threshold: >=9, no zero).
Testing moved 1 -> 2: the two new regression tests (`a[b]c` inside neutral,
`abc` sibling denied) exercise the exact fragility that was untested in round 1
and would fail under the old `"$ZONE/"*` glob logic, so they lock the fix.

## What's good
- The fix is the minimal, root-cause change: it removes glob semantics from a
  security-adjacent boundary rather than patching around them. The quoted
  parameter expansion `"${RP#"$ZONE/"}"` is the idiomatic literal-prefix idiom.
- The regression tests are behavior tests that pin the failure mode, not the
  implementation: they would catch any future reversion to glob matching.
- Deny-only remains enforced structurally (no allow branch), and fail-open is
  applied at every guard with an inline rationale, so the safety posture stays
  auditable.
- The added line 59-60 comment removes the last reader-confusion risk by stating
  the tool-contract guarantee behind the deny-safe relative-path branch.

## History
- Round 1 (artifact_version 1): APPROVE WITH COMMENTS, 11/12, testing 1/2.
  One Important: inside-zone check used `[[ "$RP" == "$ZONE/"* ]]` with `$ZONE`
  unquoted, so glob metacharacters in the zone path became active (not
  weaponizable into a wrong-allow in probing, but fragile). Two nitpicks: no glob
  test coverage; relative-path deny branch lacked a clarifying comment.
- Round 2 (artifact_version 2): APPROVE, 12/12, testing 2/2. All three resolved:
  (1) literal prefix compare at :66; (2) two glob-metachar regression tests added
  (suite 9 -> 11); (3) tool-contract comment added at :59-60. Re-verified the
  literal compare against prefix-collision, `[]`, and `*` cases; re-confirmed
  deny-only and fail-open post-edit. Regression note: BETTER (+1 total, testing
  1 -> 2, no dimension regressed).
