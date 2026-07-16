---
artifact: code
type: code
branch: main
scope: bin/spec-gate.sh + tests/spec-gate.test.sh (commit ebdad14)
date: 2026-07-16
scorer: code-reviewer
scores: { correctness: 2, security: 1, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 10/12
verdict: APPROVE WITH COMMENTS
---

# Code review: spec-gate.sh (the /build entry gate), re-review after ebdad14

Test suite: 20/20 green (all 7 suites in tests/ green). All six prior findings
(2 Critical, 4 Important) confirmed RESOLVED by independent live probes, not
just by the new tests. Regression note vs. previous round: BETTER (7/12
REQUEST CHANGES -> 10/12 APPROVE WITH COMMENTS).

## Resolved (verified independently)

1. Dirty-record bypass (prior Critical 1): docs/evals must be fully clean
   before the artifact loop (bin/spec-gate.sh:53-57); porcelain catches
   modified, staged, and untracked records. Test 10 reproduces the original
   exploit and refuses.
2. Out-of-repo fail-open (prior Critical 2): physical-path containment,
   pwd -P on both sides (bin/spec-gate.sh:31-49), exit 2. Test 11 passes on
   macOS where mktemp lives under the /var -> /private/var symlink.
3. Left boundary, body-line matching, ERE injection (prior Important 3-5):
   matching rebuilt as frontmatter-only awk parse plus exact string equality
   per token (record_tokens/covers_id, bin/spec-gate.sh:60-74). No regex in
   matching; the only regex left is the fixed-pattern id extraction on the
   basename (line 94), which takes no record input. Probed: XUSR-001,
   body-only `covers:`, comma/bracket/quoted YAML variants all refuse.
4. Empty $record guard (prior Important 6): line 123, and it is reachable,
   a gitignored record in docs/evals is invisible to porcelain but has no
   commit time; probed, refuses with the correct message.
5. Keep-in-sync comments both directions, tie-resolution comment, record()
   filename parameter (exercised by test 13): all present.

## Critical (must fix before merge)

None.

## Important (should fix)

- bin/spec-gate.sh:97,143, a GITIGNORED artifact passes the gate (reproduced:
  .gitignore covering docs/stories/, artifact never committed, committed PASS
  record for its id, exit 0). Root cause: porcelain is blind to ignored files,
  so check 1 passes, and `git log -1` prints empty for them, so art_time is
  empty and `[[ rec_time -lt "" ]]` is false, freshness passes vacuously.
  Fix: after computing art_time, refuse when it is empty or 0
  ("artifact has no commit history in this repo"). One guard closes the whole
  no-commit-history class (also nested-repo gitlink paths). Precondition is
  unusual (a gitignore rule matching spec dirs), hence Important, not Critical.

## Nitpicks (optional)

- bin/spec-gate.sh:33-38, a COMMITTED SYMLINK artifact whose target lives
  outside the repo passes even after the target changes post-review
  (reproduced). Git tracks the link, not the target content. Fix: refuse
  symlink artifacts, `[[ -L "$abs" ]]` -> exit 2.
- bin/spec-gate.sh:90, prefix-strip uses `$(pwd)` while containment used
  `$TOP` (pwd -P). Behavior is currently correct either way (git accepts
  absolute in-repo paths), but use "$TOP" so both checks share one source.
- bin/spec-gate.sh:65, tokenizer splits on whitespace only; `covers: USR-001,
  USR-002` leaves the token `USR-001,` unmatched and refuses a covered id.
  Fails closed, and docs/eval-framework.md prescribes space-separated ids, so
  acceptable; consider stripping `,` `"` `'` `[` `]` in the tr, or state the
  format requirement in the header comment.

## Testing

20 assertions, hermetic, fast, and they now include every previously missed
scenario (dirty bypass, out-of-repo, subdir, newest-wins, left boundary, body
covers, missing verdict, RES ids). Remaining gap: the gitignored-artifact case
above shipped untested; add it alongside the fix.

## What's good

The unified string-equality rewrite is exactly right: it removed three holes
and all regex from matching in one move, and the code got SHORTER and clearer.
Fail-closed discipline is now consistent (odd YAML token formats refuse rather
than guess). The empty-record guard turned out to be live defense, not dead
code. Installed copy in ~/bin is in sync per the repo convention.

## History

- Round 1 (commit 680a5ce, record dated 2026-07-16): REQUEST CHANGES, 7/12.
  Criticals: uncommitted record edits flipped the gate (verdict/coverage read
  from the working copy while freshness read commits); fail-open on artifacts
  outside the repo. Importants: no left token boundary; artifact:/covers:
  matched anywhere in the file; unescaped id injected into the ERE; empty
  $record reaching awk; test gaps (12 assertions, happy-path heavy).
- Round 2 (commit ebdad14, this record): all round-1 findings verified fixed
  by independent probes; one new Important (gitignored artifact, empty
  art_time) and two edge nitpicks found. 10/12, no zeros, threshold met.
