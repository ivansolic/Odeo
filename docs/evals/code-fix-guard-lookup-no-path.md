---
artifact: fix-guard-lookup-no-path
type: code
branch: fix/guard-lookup-no-path
reviewed_commit: 78bc5f4
date: 2026-09-29
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

# Code review: fix/guard-lookup-no-path (round 4)

Scope of round 4: the delta `50241a2..78bc5f4`, one commit, read at 78bc5f4. It touches
`hooks/odeo-context.sh` (`hook_finds`), `tests/odeo-context.test.sh` (case 4e and the
mutant header), and the README assertion count. Nothing else moved since round 3, so the
earlier rounds stand (see History). Output language: en. Regression check: 10/12 -> 12/12,
improved.

## Verdict
APPROVE

## Round-3 findings: closure
1. **Important 1 (the recorded config root was never searched): closed.**
   - **How it is fixed:** `hook_finds` checks the install directory first, then builds
     `roots` (the live config dir, `~/.claude`, plus the recorded config dir when it is
     readable) and globs `scripts/` then `bin/` per root. No brace list remains inside a
     parameter expansion.
   - **The round-3 reproduction, rerun on 78bc5f4:**
     - Setup as before: installed with `CLAUDE_CONFIG_DIR=X` from X's cache, the version
       swept for a newer one, the session-start hook run without the variable.
     - Result: silent. Round 3 raised a false alarm here.
     - Positive control: with no Odeo anywhere, the same run nudges.
   - **The unknown rule** (an unreadable value counts as found) is unchanged.
   - **bash 3.2:** the arrays (`local roots=(...)`, `roots+=`) are supported.
2. **Important 2 (no case pinned the recorded config root): closed.**
   - The new 4e case matches the setup above and asserts silence.
   - Measured on a copy of the tree:
     - baseline: green;
     - the round-3 `odeo-context.sh` swapped in: the new case fails (the RED);
     - M21 (the recorded-root line removed): 1 FAIL, as recorded in the header.
   - An extra mutant of my own: removing the install-directory check reddens 3 cases.
     So the install-directory branch is not dead code either.
   - The coordinator's search for other brace lists inside `${...:+...}` in `scripts/`,
     `hooks/` and `bin/` found none. My own pattern search agrees.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
None.

## Residuals (known, accepted, not findings against this diff)
- `merge-gate.sh` skips the boundary check when the checker next to it is missing
  (fail-open). This existed before the branch and is logged in the plan and the todo.
- Inside a session, any cached Odeo is used before an in-place clone. The author accepts
  this as known.
- A current hook whose recorded path is not a plain path (for example, it contains a
  space) counts as found. If such a clone is later moved, the nudge stays silent, while
  the hook still warns on every commit. The false negative is bounded; it was accepted in
  round 2 in exchange for never running hook text.
- The scrub case is named at session start only when the session-start hook also runs
  without CLAUDE_CONFIG_DIR. Whether that happens is unverified, and the knowledge entry
  now says so.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. The residuals above lie outside this change or are trades the author
accepted and documented, so none of them caps a dimension.

## What's good
- The fix removes the construct that caused the bug, not just this instance. Roots are
  listed as data and globbed with one plain pattern per root. A comment says why, so the
  brace-in-`:+` form does not come back.
- The new case went RED against the exact round-3 code before the fix. The author also
  searched the codebase for the same construct.
- Across four rounds, every recorded mutation count reproduced when re-run:
  - round 1: M9, M17;
  - round 2: M3, M18, M19, M20 and the merge-gate mutant;
  - round 4: M21.

## History
- **Round 1 (fdd777e): 9/12, APPROVE WITH COMMENTS.**
  - Dropping PATH left a moved in-place clone warning and committing, invisible to the
    session-start check.
  - The merge-gate PATH case checked only that the script did not run.
  - The knowledge entry claimed PATH "held nothing the cache did not".
- **Round 2 (8126967): 11/12, APPROVE WITH COMMENTS.**
  - `hook_finds` added, reading the hook as text. This replaced my unsafe suggestion to
    evaluate the hook's preamble.
  - The merge-gate case now pins rc and the end of the gate.
  - `init-project.sh` drops its PATH fallback.
  - Open: the knowledge sentence overclaimed the scrub case.
- **Round 3 (50241a2): 10/12, APPROVE WITH COMMENTS.**
  - The sentence is fixed.
  - The `hook_finds` rewrite lost the recorded config root through a brace list inside
    `${cfg:+...}` (a false alarm, reproduced), and no case covered that root.
- **Round 4 (78bc5f4): 12/12, APPROVE.**
  - The roots are built as an array and globbed per root.
  - A case pins the recorded root: RED at 50241a2, M21 1 FAIL.
