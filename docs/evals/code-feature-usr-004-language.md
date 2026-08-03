---
artifact: USR-004
type: code
branch: feature/usr-004-language
artifact_version: 3
date: 2026-08-03
scorer: code-reviewer
model: claude-opus-4-8
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

# Code review, USR-004 change output language at any time (round 3)

Scope of this round: FOCUSED re-verification of the fix commit `6b8233f`
("fix(language): fail on an unwritable global config, and close the guard's last
escapes") at HEAD `6b8233f`. Not a review from scratch; round 1
(artifact_version 1) covered the full diff, round 2 (artifact_version 2) verified
the previous fix commit `2bb9b7b`. Contract:
`docs/plans/2026-07-30-usr-004-change-language-anytime.md` (approved, arch_review
clean v3).

Model note: judged on Opus 4.8, the top tier available in this session, mapped to
`strongest` by the AGENTS.md tier map. The live lineup was not re-verified in this
session (no volatile claim is made about it).

## Verdict
APPROVE WITH COMMENTS

Both round-2 fixes landed cleanly, each verified independently (pre-fix scenario
reproduced at HEAD, six mutations, ok-line count, full suite), not taken from the
commit body. The single point round 2 lost (correctness, the append-branch false
success) is recovered: correctness moves 1 -> 2. No Critical. No new Important. No
regression. Two narrow guard corners remain, downgraded to nitpicks below (same
grade round 2 used for its residual arm-shape escapes); neither is the natural
"added a fifth code, forgot a file" drift the guard exists to stop, and neither
touches product code.

## Fix 1 (correctness, the round-2 point). CLOSED.
`bin/set-global-language.sh:128-131`, the APPEND branch now checks the write:
`if ! printf ... >> "$GLOBAL_CONFIG"; then echo "...could not write..." >&2; exit 1; fi`.

Reproduced the exact pre-fix scenario at HEAD (a `chmod 444` config carrying no
`output_language:` line, `CLAUDE_GLOBAL_CONFIG` pointing at it, `set-global-language.sh de`):
- rc **1** (was 0), stderr `set-global-language: could not write <path>` after the
  shell's own `Permission denied`, and the file is **byte-unchanged** (0
  `output_language:` lines). The false success is gone; the exit contract at
  `:30-33` now holds on this path.
- The absent-config path is NOT broken (the fix added no `-w` pre-check that would
  reject a not-yet-existing file): with the parent dir present and the file absent,
  rc **0**, the line is written. The comment at `:126-127` states exactly this
  reason, correctly.
- Case 19 (`tests/set-global-language.test.sh:149-156`) sits BEFORE the summary
  block and executes: `bash tests/set-global-language.test.sh | grep -c '^ok:'`
  = **61** (was 59, +2 = the two assertions case 19 adds), rc 0, `ALL PASS`. The
  last `ok:` line is `nothing was written`.
- Cases 1 to 8 are byte-unchanged: the diff to this file is a pure tail insertion
  (single hunk at the end, git-verified), and the whole suite is green.

## Fix 2 (testing / guard completeness). CLOSED for the six specified mutations.
`tests/language-allowlist-agreement.test.sh:98-107` now extracts every
`<label>) ;;` arm anywhere on a line with a wide charset (`[^ );]+`) and asserts
the `*)` default arm still exits 1. Mutations run against `bin/init-project.sh`
with `git checkout --` restore after each; working tree ends clean (`git status`
shows only this untracked record).

| Mutation to `bin/init-project.sh` | Guard rc | Failing assertion |
|---|---|---|
| none (clean tree) | 0 | GREEN |
| `pt-br) ;;` (locale tag) | 1 | accepts exactly the expected set (got `...fr pt-br`) |
| `ES) ;;` (uppercase) | 1 | accepts exactly the expected set (got `...fr ES`) |
| `en\|de\|hr\|fr) ;; es) ;;` (glued second arm) | 1 | accepts exactly the expected set (got `...fr es`) |
| `*)` arm keeps message, drops `exit 1` | 1 | default arm still exits 1 |
| `es) ;;` (original round-1 addition) | 1 | accepts exactly the expected set (got `...fr es`) |
| `en\|de\|hr) ;;` (removal direction) | 1 | accepts exactly the expected set (got `en\|de\|hr`) |

All six now FAIL the guard; the clean tree is GREEN. The four escapes round 2
flagged as a nitpick are closed.

## New findings
None at Important or Critical grade. Two residual guard corners found while probing
for a seventh escape (both proven on a sandbox mutation, tree restored clean):

1. **Non-empty accepting arm body escapes the extraction.** The extraction regex
   `[^ );]+\)[[:space:]]*;;` requires `)` to be adjacent (modulo whitespace) to
   `;;`, which only holds for empty arms (`) ;;`). An accepting arm with a command
   body slips past: `es) : ;;` and `es) echo hi ;;` both leave the guard GREEN
   (rc 0) while bash accepts `es`. Every real arm is empty, so this needs an
   unnatural edit, hence nitpick-grade, same class round 2 used for the arm-shape
   escapes it downgraded.

2. **The `*)`-exit-1 assertion is a text-presence check and can false-positive.**
   `grep -qE '^[[:space:]]*\*\).*exit 1'` matches the literal string "exit 1"
   anywhere on the default-arm line, not the structural fact that the arm exits.
   Proven: a default arm that keeps `(allowed: en de hr fr)` AND the words
   "...normally we exit 1 here" in its message but DROPS the real `; exit 1` leaves
   the whole guard GREEN (rc 0) while the scaffolder no longer refuses unknown
   codes. It does catch the realistic drift (a clean deletion of `; exit 1`, the M4
   mutation above, RED), so this is a corner, not false confidence in the
   file's own sense; nitpick-grade. No false-NEGATIVE against the clean tree (GREEN,
   verified); a multi-line default arm would fail the line-based grep, which errs
   toward RED (safe).

## Nitpicks (optional)
- `tests/language-allowlist-agreement.test.sh:99-101`, harden the arm extraction so
  a command-bearing arm cannot escape: assert the case body has exactly two arm
  terminators, e.g.
  `assert_eq "exactly two case arms" 2 "$(printf '%s' "$case_body" | grep -oc ';;')"`
  (adding `es) : ;;` makes it 3). Closes finding 1.
- `tests/language-allowlist-agreement.test.sh:107`, make the exit-1 assertion
  structural: require `exit 1` immediately before the arm's `;;`, e.g. grep
  `'^[[:space:]]*\*\).*exit 1[[:space:]]*;;'`. The message-collision mutation in
  finding 2 has `exit 1` followed by ` here" >&2 ;;`, so it no longer matches, while
  the real `... >&2; exit 1 ;;` still does. Closes finding 2.
- The three round-2 nitpicks that were not tied to this fix commit (the exit-code
  doc list at `set-global-language.sh:30-33` now also covering not-writable, the
  "unchanged for every non-symlink input" wording at `:25`, the symlink-target tests
  not asserting `-L`) still stand as optional; not re-verified this focused round.

## Independent verification performed this round
- Full suite 23/23 files rc 0 (the two writers and the guard are driven by several
  test files; re-run to confirm no regression, not to confirm the builder's report).
- Pre-fix scenario reproduced at HEAD on a `chmod 444` no-line config: rc 1, nothing
  written; absent-config path still rc 0 and writes.
- Case 19 executes before the summary block; `grep -c '^ok:'` = 61 (was 59).
- Six guard mutations on `bin/init-project.sh` (the four round-2 escapes plus the
  original `es) ;;` and an `en|de|hr` removal), each restored with `git checkout --`;
  all six RED, clean tree GREEN.
- Seventh-escape probe: two residual corners found (findings above), both proven on
  sandbox mutations and restored.
- Working tree ends clean apart from this record (`git status --porcelain` shows
  only this untracked file).

## Scores
correctness 2/2 . security 2/2 . performance 2/2 . readability 2/2 .
testing 2/2 . conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

- correctness 2, moved off 1: the append-branch false success is fixed and I proved
  it at HEAD (rc 1, nothing written), the absent-config path is not broken, and the
  exit contract now holds on the path `/language <code> --global` reaches.
- security 2: unchanged. Sensitive `--link` symlink write still refused before any
  write on both paths; codes allowlisted before `awk -v`; refusals leave fixtures
  byte-identical; no secrets, no PII.
- performance 2: the guard adds one `sed | grep | sed | tr` pipeline over one file
  at test time; runtime path unchanged.
- readability 2: the new `set-global-language.sh` comment says WHY the write is
  checked and WHY a `-w` pre-check cannot replace it; the guard comment explains the
  wide charset and why the default arm is asserted separately.
- testing 2: both round-2 fixes verified independently; six mutations RED where the
  arm-shape ones were GREEN, ok-line count 59 -> 61, suite 23/23. The two residual
  guard corners are nitpick-grade (unnatural edits, product code correct), matching
  round 2's own calibration for the escapes it downgraded.
- conventions 2: Conventional Commit subject, English comments, no dashes,
  skills-lint clean (unchanged this round), init-project.sh product code untouched
  by the branch.

## Ceiling
12/12, reached. Nothing structurally caps this change (deterministic shell, mature
harness, no UI or external dependency). The two open nitpicks are guard hardening,
not score-bearing findings; taking them would make the meta-test stricter but does
not raise a ceiling that is already met.

## History
- **v1 (2026-07-31, 10/12, APPROVE WITH COMMENTS).** Full-diff review, 6 commits.
  Four Important: guard caught a REMOVED code but not an ADDED one; symlink+no-line
  untested and mis-described; README implied language fixed at install; uppercase
  codes dead-ended. Deductions: testing 1, conventions 1.
- **v2 (2026-07-31, 11/12, APPROVE WITH COMMENTS, at 2bb9b7b).** All four CLOSED and
  re-verified; six nitpicks taken. testing 1 -> 2, conventions 1 -> 2. correctness
  2 -> 1 for a NEW Important: `set-global-language.sh`'s APPEND branch reported a
  false success on an unwritable config. Net better (10 -> 11), one cheap fix left.
- **v3 (this record, 12/12, APPROVE WITH COMMENTS, at 6b8233f).** Both v2 items
  fixed. correctness 1 -> 2: the append branch now checks its write (verified: rc 1,
  nothing written; absent-config path intact; case 19 pins it, ok-count 59 -> 61).
  The guard's four add-direction escapes are closed (six mutations RED, clean tree
  GREEN). Regression note vs v2: **better** (11 -> 12), no regression in any
  dimension. Two new residual guard corners (non-empty arm body escapes; exit-1
  assertion is a text check that can false-positive) are logged as nitpicks with
  concrete fixes; both need unnatural edits and neither touches product code, so
  they do not move a score.
