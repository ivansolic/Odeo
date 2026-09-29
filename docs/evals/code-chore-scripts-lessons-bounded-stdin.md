---
artifact: chore-scripts-lessons-bounded-stdin
type: code
branch: chore/scripts-lessons-bounded-stdin
reviewed_commit: 7a42472
date: 2026-09-29
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

# Code review: chore/scripts-lessons-bounded-stdin (round 2)

Scope of round 2: the delta `9294b9e..7a42472`, one commit, `knowledge/` only
(`knowledge/install/guard-lookup-never-repo-relative.md`,
`knowledge/testing/watchdog-by-pid-not-alarm.md`). No code moved, so the round-1 review
and measurements of `tests/odeo-migrate-legacy.test.sh` still describe the code at 7a42472;
they are summarized under History. Output language: en.

## Verdict
APPROVE WITH COMMENTS

## Round-1 findings: closure
1. **Closed (Important).** The guard-lookup entry now claims impossibility only for
   repo-relative and cwd-relative substitution. It names PATH as an open residual,
   citing `odeo_tool`'s `command -v` (`scripts/install-git-guards.sh:52`), the
   merge-gate fallback (`scripts/merge-gate.sh:322`), and how a project gets onto PATH
   (direnv `PATH_add`, `node_modules/.bin`, `.`). It also applies its own Prevention
   question to PATH and answers yes. The claim now matches the mechanism
   (`lessons.md:28`).
2. **Closed (nitpick).** Prevention now says per test what each one asserts.
   git-guards case 10 checks that the script did not run and that the warning prints.
   The last merge-gate case checks that the real check still refuses (rc 1). Both match
   the tests.
3. **Closed (nitpick).** The watchdog entry's long lines are wrapped. The `tags:` flow
   sequence now spans two lines. That is valid YAML, and the repo already does it
   (`knowledge/fixes/eliminate-the-defect-class-not-the-shape.md`). The remaining
   99-char line 14 predates this branch.
4. **Deferred, logged (pre-existing nitpick).** Two items are recorded as an open
   FOLLOW-UP at `.claude/tasks/todo.md:71-74` and not changed on this branch: the PATH
   ordering itself, and the fact that migrate cases 8 and 8b do not unset
   `CLAUDE_CONFIG_DIR`. That is appropriate: neither was introduced here, and the PATH
   ordering is a code change to a guard. (`todo.md` is gitignored and local.)

The delta contains no em or en dashes.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `knowledge/install/guard-lookup-never-repo-relative.md:36`: "PATH is looked up first
  (odeo_tool's `command -v`, merge-gate's fallback)" reads as if PATH also comes first in
  merge-gate, where it is the LAST lookup, after the sibling checker. **Fix:** "PATH is
  looked up (first in odeo_tool, as the fallback in merge-gate)".
- `knowledge/install/guard-lookup-never-repo-relative.md:28`: the Solution list still
  omits PATH. The residual is now stated one section later, which is honest, but a reader
  who skims only Solution misses it. **Fix (optional):** append "(PATH too; see the
  residual below)".

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12. Nothing structural caps this change. It stays APPROVE WITH COMMENTS, not a clean
APPROVE, because of the two wording nitpicks and the logged follow-up: the PATH-first
lookup in `odeo_tool` is a known, documented residual of the guard, not a closed hole.

## What's good
- Each round-1 finding was closed by narrowing the claim, not by widening the
  mechanism. `lessons.md:28` prescribes exactly that direction for an overclaiming
  comment.
- The larger issue is not hidden. The PATH ordering is named in the entry, and it is
  logged as a follow-up rather than silently dropped or crammed into a docs branch.
- Round 1 still holds for the code: `bounded()` hands the caller's stdin on (measured: 0
  bytes before, 3 after), and the watchdog still bounds the self-exec loop at 143/10s.
  M13 and M7 both reproduce, and the suite passes.

## History
- Round 1 at 9294b9e: 11/12, APPROVE WITH COMMENTS (correctness 1).
  - Important: the guard-lookup entry claimed substitution was "impossible" while PATH
    stays the first lookup in `odeo_tool` and the fallback in merge-gate.
  - Nitpicks: Prevention attributed "not run + warning" to both tests; a 135-char line
    in the watchdog entry; migrate cases 8 and 8b do not unset `CLAUDE_CONFIG_DIR`
    (pre-existing).
  - Independently measured in a scratch copy:
    - `printf abc | bounded wc -c`: 0 before the fix, 3 after.
    - An `exec "$0"` loop still ends with rc=143 after 10s.
    - M13 gives exactly 1 FAIL (case 16).
    - M7 fails case 8b with 143.
    - The suite passes.
  - No bounded() caller relies on an empty stdin.
- Round 2 at 7a42472: 12/12, APPROVE WITH COMMENTS. The Important and both text
  nitpicks are closed; the pre-existing items are deferred to a logged follow-up.
  Regression check: improved (11 -> 12).
