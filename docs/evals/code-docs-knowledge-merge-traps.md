---
artifact: docs-knowledge-merge-traps
type: code
branch: docs/knowledge-merge-traps
reviewed_commit: f34113c
date: 2026-10-29
scorer: code-reviewer
model: claude-sonnet-5-5 (Sonnet 5.5)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: docs/knowledge-merge-traps (round 1)

Scope: `git diff main...docs/knowledge-merge-traps`, one commit (f34113c), two Markdown files:
the new `knowledge/review/claims-count-needs-assertions-flag.md` and an added section in
`knowledge/testing/watchdog-by-pid-not-alarm.md`. Output language: en (handed at dispatch).
No previous record exists for this branch.

## Verdict
APPROVE WITH COMMENTS

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `knowledge/testing/watchdog-by-pid-not-alarm.md:54-55`: the example loop globs
  `tests/*.test.sh`, which matches 38 suites in this repo, but the text says "all 40 suites
  FAILED". The 40 only adds up if the 2 suites under `.claude/maintainer/tests/` were in the
  run, and the loop shown would not have run them. A reader re-deriving the number gets 38.
  **Fix:** write the loop as it was run (both globs), or say "all 40 suites (tests/ plus
  .claude/maintainer/tests/)".
- `knowledge/review/claims-count-needs-assertions-flag.md:38-40`: the "re-stales review
  records" cost is true for the installed 0.3.5 gate (`merge-gate.sh:294` excludes only
  `docs/evals`), but this repo's own maintainer gate exempts README and Markdown under
  `knowledge/` (`.claude/maintainer/merge-gate.sh:294-313`). The entry does not say which
  gate bit at USR-008. **Fix:** one clause naming the gate the merge ran under, so a reader
  on the repo-local gate does not over-read the cost.
- `knowledge/review/claims-count-needs-assertions-flag.md:27`: "about 5 to 6 minutes" is
  not reproduced here (I did not run the full suite). It is stated as a duration, not a
  measurement. **Fix (optional):** "measured at about 5 to 6 minutes on 2026-10-27".

## Claims verified against the repo
- `scripts/docs-claims-check.sh` without the flag prints
  `skipped: assertion count (re-run with --assertions; it runs every suite)` (line 146), then
  a blank line, then `every countable claim matches the tree.` (line 175). The entry's "one
  line above the green summary" is accurate in substance. Only `--assertions` reaches the
  assertion claim (line 144).
- The drift line format `DRIFTED: <label> , README says N, the tree has M` matches line 71
  exactly, including the space before the comma.
- The plain run counts files (executables, agents, suites, programs with a suite); the
  `--assertions` run executes the suites, counts `ok` lines and adds `SKIP <n>` cases back
  (lines 94 to 135). The "Why it works" section is correct.
- README: 1517 to 1523 at 53a7676, a one-line change; the tree has 38 suites, matching the
  README.
- "1521 executed + 2 skipped in tests/ledger-backup.test.sh on this shell": I ran that suite
  (non-root). It prints one `SKIP 2 - this shell refuses SHELLOPTS from the environment...`
  line and 206 `ok` lines, so the skipped count of 2 and the file are right. The 1521 sum
  across suites I did not recompute.
- `timeout` is not installed here (`command not found`, rc 127) and
  `timeout 3 true || echo FAILED` prints FAILED, which confirms the all-red mechanism.
  `perl -e 'alarm 2; exec @ARGV' bash -c 'exit 3'` passes the exit code through (rc 3), so
  the suggested substitute works for a non-looping suite. The entry's advice is consistent
  with the existing text ("`timeout` (not on macOS by default)", the exec-restarts-the-alarm
  limit) and points to `bounded` for exec loops.

## Convention checks
- No non-ASCII bytes in either file, so no em or en dashes. No line over 100 characters.
- `language-guard.sh` on both paths, the branch name and the commit subject: "machine
  surfaces clean".
- Frontmatter has all seven sibling fields (module, tags, problem_type, provenance,
  reuse_count, created, plus the H1), and the section layout (Problem, Symptoms, What didn't
  work, Solution, Why it works, Prevention, Example) matches existing entries such as
  `flaky-is-a-hypothesis.md`. The new file sits in `knowledge/review/` beside its siblings.
- No private paths, people names, emails or secrets. `knowledge/` stays internal
  (`docs/internal-paths.txt:18`).
- The added watchdog section is placed before `## Prevention` and does not disturb the
  existing sections. It has no `reuse_count` bump, which is correct for an addition.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. The verdict is APPROVE WITH COMMENTS rather than APPROVE because of three
optional nitpicks; none would send a reader to a wrong action. Testing is scored on the
docs-only change as 2: no code ships, and the claims were checked behaviorally above.

## What's good
- Every behavioral claim carries a measurement or a pointer to the exact output string, and
  the quoted strings match the script character for character.
- The new watchdog section carries its own detection rule ("every suite failed at once means
  a broken runner") and a scoped substitute, rather than a bare warning.
- The entry names the structural point (a "skipped:" line means "not checked") instead of
  only retelling the incident.

## History
- Round 1 at f34113c: 12/12, APPROVE WITH COMMENTS. First review of this branch.
