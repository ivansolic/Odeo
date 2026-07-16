---
artifact: code
type: code
branch: main
scope: bin/spec-gate.sh + tests/spec-gate.test.sh (commit 6d14192)
date: 2026-07-16
scorer: code-reviewer
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 10/12
verdict: APPROVE
---

# Code review: spec-gate.sh (the /build entry gate), final re-review (round 3)

Test suite: 22/22 green (all 7 suites in tests/ green). Both round-2 claimed
fixes verified by independent live probes, not just by the new tests.
Regression note vs. previous round: BETTER (10/12 APPROVE WITH COMMENTS ->
12/12 APPROVE).

## Verified this round (independent probes)

1. Gitignored-artifact vacuous pass (round-2 Important): the original exploit
   (committed .gitignore covering docs/stories/, never-committed artifact,
   committed PASS record for its id) now REFUSES with the dedicated
   no-commit-history message (bin/spec-gate.sh:147-152, exit 1). Test 18
   covers it.
2. The same guard also closes adjacent no-history paths, probed: an artifact
   inside a NESTED inner git repo (gitlink-style, invisible to the outer
   repo's log) refuses with the same message.
3. Symlink artifacts (round-2 nitpick): refused at argument resolution with
   exit 2 (bin/spec-gate.sh:33-34). Probed: committed symlink whose
   out-of-repo target drifted after review; also a relative symlink path from
   a subdirectory. Test 19 covers it. A regular file under a symlinked parent
   directory pointing outside the repo is caught by the physical-path
   containment check (exit 2), probed.
4. rel stripping now anchors on "$TOP" (bin/spec-gate.sh:92), single source of
   truth with the containment check.
5. Regression spot-checks all hold: dirty-record bypass refuses (exit 1),
   out-of-repo artifact fails closed (exit 2), XUSR-001 does not cover
   USR-001, newest-record-wins, body-only covers ignored.
6. Installed copy (~/bin/spec-gate.sh) is byte-identical to the repo copy,
   per the repo's install-sync convention.

## Critical (must fix before merge)

None.

## Important (should fix)

None.

## Nitpicks (optional)

- bin/spec-gate.sh:67, tokenizer splits on whitespace only; `covers: USR-001,
  USR-002` leaves the token `USR-001,` unmatched and refuses a covered id.
  Fails closed, and docs/eval-framework.md prescribes space-separated ids, so
  acceptable as-is; consider stripping `,` `"` `'` `[` `]` in the tr, or state
  the format requirement in the header comment. (Carried from round 2,
  intentionally not blocking.)

## Testing

22 assertions, hermetic, fast. Every finding from all three rounds now has a
regression test, including the two added this round (gitignored
never-committed artifact; symlink artifact).

## What's good

The no-commit-history guard is the right shape: one refusal closes the whole
class (gitignored files, never-committed files, nested-repo gitlinks) instead
of patching the single reproduced case. Symlink refusal at argument resolution
keeps the fail-closed logic in one early place. The gate is now consistently
deny-by-default across every probe angle tried over three rounds.

## History

- Round 1 (commit 680a5ce): REQUEST CHANGES, 7/12. Criticals: uncommitted
  record edits flipped the gate (verdict/coverage read from the working copy
  while freshness read commits); fail-open on artifacts outside the repo.
  Importants: no left token boundary; artifact:/covers: matched anywhere in
  the file; unescaped id injected into the ERE; empty $record reaching awk;
  test gaps (12 assertions, happy-path heavy).
- Round 2 (commit ebdad14): APPROVE WITH COMMENTS, 10/12. All round-1
  findings verified fixed by independent probes; matching rebuilt as
  frontmatter-only awk parse plus exact string equality. One new Important
  (gitignored artifact passed vacuously via empty art_time) and two edge
  nitpicks (symlink artifacts, pwd vs TOP anchoring).
- Round 3 (commit 6d14192, this record): APPROVE, 12/12. Both round-2 fixes
  verified by independent probes, no new findings, review loop closed at the
  3-round cap.
