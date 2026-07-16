---
artifact: code
type: code
branch: main
scope: bin/spec-gate.sh + tests/spec-gate.test.sh (commit 680a5ce)
date: 2026-07-16
scorer: code-reviewer
scores: { correctness: 1, security: 0, performance: 2, readability: 1, testing: 1, conventions: 2 }
total: 7/12
verdict: REQUEST CHANGES
---

# Code review: spec-gate.sh (the /build entry gate)

Test suite: 12/12 green. All findings below were reproduced live in scratch repos.

## Critical (must fix before merge)

1. **Uncommitted record edits flip the gate** (bin/spec-gate.sh:67, 82 vs 77).
   Coverage (`grep`) and verdict (`frontmatter_verdict`) read the WORKING COPY of
   the record, while freshness reads the record's last COMMIT time. Reproduced:
   commit a record with `verdict: REQUEST CHANGES`, hand-edit the file to
   `verdict: PASS` without committing, gate exits 0. This defeats the gate's
   entire purpose ("never edit the record by hand"). Same hole lets a dirty edit
   add `covers: USR-001` to an unrelated committed record. merge-gate does not
   have this hole only because it demands a fully clean tree.
   Fix: before the artifact loop, refuse if `git status --porcelain -- docs/evals`
   is non-empty (also cleans up the untracked-record path, see Important 4).
   Alternative: read record content via `git show HEAD:$r` so content and
   timestamp come from the same source.

2. **Fail-open on artifacts outside the repo** (bin/spec-gate.sh:30-37, 60, 95).
   Point the gate at an artifact file outside the current repo: `git status`
   prints a fatal to stderr but the command substitution captures empty stdout,
   so check 1 "passes"; `git log ... || echo 0` makes art_time 0, so check 4
   "passes"; coverage matches by id against the gate repo's records. Reproduced:
   exit 0 with a visible `fatal:` above it. An enforced guardrail consumed by
   /build via exit code must fail closed.
   Fix: resolve with `pwd -P`, then after `cd "$top"` verify
   `case "$abs" in "$top"/*) ;; *) exit 2;; esac`.

## Important (should fix)

3. **No left token boundary in the coverage regex** (bin/spec-gate.sh:67).
   `artifact: XUSR-001` matches id USR-001 (reproduced). The right boundary
   `([^0-9-]|$)` exists, the left one does not.

4. **`artifact:`/`covers:` matched anywhere in the file, not frontmatter-only**
   (bin/spec-gate.sh:67). A body line `covers: USR-001` in an unrelated PASS
   record gates USR-001 through (reproduced). This contradicts the script's own
   header (lines 7-8: "frontmatter `artifact:` or `covers:`") and the
   verdict-parsing philosophy (body prose must never flip the gate). A History
   section quoting old frontmatter is a realistic trigger.

5. **Fallback id is injected into the ERE unescaped** (bin/spec-gate.sh:57, 67).
   `spec.one.md` matched a record saying `artifact: specXone` (reproduced, `.`
   is a wildcard). Parens change grouping; `[` makes the pattern invalid.

   Unified fix for 3-5: parse frontmatter `artifact:`/`covers:` values with awk
   (mirror `frontmatter_verdict`), split values into whitespace/comma tokens,
   compare with string equality against the id. No regex, no boundary hacks,
   frontmatter-only by construction.

6. **Empty `$record` reaches awk** (bin/spec-gate.sh:75-79, 82, 86). When all
   matching records are untracked, `record` stays empty; the refusal message
   prints `($record)` as `()`. Deny holds, message misleads. Guard
   `[[ -z "$record" ]]` explicitly (subsumed by fix 1).

## Nitpicks

7. `frontmatter_verdict` (bin/spec-gate.sh:39-49) duplicates
   bin/merge-gate.sh:65-72. Two enforcement scripts claim "the same contract"
   but keep it in sync by copy-paste. Extract a shared helper or add explicit
   "keep in sync with" comments on both sides.
8. Timestamp tie between two matching records (same commit) picks grep order
   arbitrarily; harmless today, worth a comment.
9. tests/spec-gate.test.sh:18: `record()` hardcodes `rec.md`, so
   multiple-records scenarios cannot be expressed; add a filename parameter.

## Testing gaps

The 12 assertions cover happy paths and the id-set edge (4b), but miss:
dirty-record bypass (the Critical), out-of-repo artifact, subdir invocation
(the exact lesson the path-resolution code exists for, works but is untested),
newest-record-wins (newer FAIL must beat older PASS), left-boundary
(XUSR-001), REQUEST CHANGES and missing-verdict records, RES- ids.
Verified manually: subdir invocation, symlinked cwd, USR-0012 vs USR-001, and
lowercase `verdict: pass` all behave correctly.

## What's good

Small, readable, well-commented; deny-by-default vocabulary matches merge-gate
exactly; the right-boundary `([^0-9-]|$)` and digit handling are correct
(USR-0012 does not cover USR-001 and vice versa); path resolution before cd
genuinely fixes subdir and symlinked-cwd invocation; failures accumulate
per-artifact as specified; test suite is fast, hermetic, and green.
