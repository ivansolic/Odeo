---
artifact: community-fetch-head-fallback
type: code
branch: feature/community-fetch-head-fallback
reviewed_commit: d586ff3
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 12/12
verdict: APPROVE
---

# Code review: community reminder dates an unstamped copy by FETCH_HEAD (round 3, re-anchor)

## Scope reviewed

Round 3 re-anchors this record on `d586ff3`, which is `eaffbef` rebased onto local main
`0f4c6ae` after the C16 branch merged. I checked myself that the rebase changed no content:
`git range-diff b855870..eaffbef main..d586ff3` shows all six commits as `=`. The only
difference between `eaffbef` and `d586ff3` is the C16 merge, and it touched none of this
branch's files (`scripts/skills-lint.sh`, `tests/merge-gate.test.sh`,
`tests/odeo-migrate-legacy.test.sh`, `tests/skills-lint.test.sh`, and its own eval record).
On the new base I ran a live check: `tests/odeo-context.test.sh` gave ALL PASS and
`scripts/skills-lint.sh` gave "all invariants hold". The review below is round 2's,
unchanged, because the code it reviewed is unchanged.

Round 2 was anchored at `eaffbef`. It reads the fix delta `git diff 1449b61..eaffbef` (three
commits: f28bc21, 87a0d2f, eaffbef; four files: `hooks/odeo-context.sh`,
`tests/odeo-context.test.sh`, `knowledge/fixes/git-head-mtime-is-not-last-sync.md`,
`CONTRIBUTING.md`), on top of the full round-1 review of `git diff main...1449b61`. No plan
exists for this branch; the contract is the human decisions of 2026-09-30 (yes to the
FETCH_HEAD fallback, yes to a versioning line, not now to a permanent opt-out). The
`--no-write-fetch-head` option stays with the human, as round 1 asked. I did not re-run the
suites: the builder reported 39 suites and lint green, and reading the delta raised no doubt
that a run would answer.

## Findings

No Critical and no Important findings remain.

### Nitpicks (optional)

- `hooks/odeo-context.sh:39-41`: the named gap says "a fast-forward AND a re-clone that
  both fail". community-sync.sh has a second way into the same state: the "not on a branch
  that tracks the remote" arm does no fast-forward and goes straight to the re-clone. Same
  outcome and same bound, so "a fetch that succeeds but no refresh or re-clone completes"
  would cover both arms. Wording only.

## Round-1 findings, verified closed

- Critical (a failed fetch dated the copy as fresh): closed. `community_state` now uses
  HEAD by default and FETCH_HEAD only under `[ -s ]` (`hooks/odeo-context.sh:281-284`),
  which is the fix proposed in round 1. On a copy with a stamp nothing changes: `$last`
  stays the stamp. The later `[ -e "$last" ]` "cannot be dated" arm still works, because
  with no stamp and no HEAD an empty or missing FETCH_HEAD leaves `$last` at the missing
  HEAD. The builder's own end-to-end run (real community-sync.sh, unreachable origin, no
  stamp, HEAD 20 days old: reminder before, 0-byte FETCH_HEAD, no stamp, reminder after)
  is the same shape as my round-1 reproduction, now with the fixed result.
- Important (the test setup was the failure shape): closed. Both FETCH_HEAD asserts now
  write a real FETCH_HEAD line, and a third assert covers an empty FETCH_HEAD dated now
  with HEAD 15 days old, expecting the reminder. By reading it, M34 (`-s` back to `-f`)
  fails only that new assert, which matches the recorded 1 FAIL. M32 still fails both
  fetched-copy asserts. M33 is labelled "measured on d063c95", which is honest: in the new
  `if` block, swapping the two assignments makes HEAD always win, so it collapses into M32
  and has no separate form.
- Important (the knowledge file left out failed fetches): closed. It now says a failed
  fetch empties FETCH_HEAD to 0 bytes with a new date, names `[ -s ]` over `[ -f ]`, says
  that even a non-empty FETCH_HEAD dates the fetch rather than a completed sync, and
  records how the first draft was caught.
- Important (unnamed gap): closed. The hook header states it as bounded (only copies
  without a stamp, at most 14 days quiet, and the user saw the failure message in that
  session), with the nitpick above about wording.
- Nitpicks: closed. The header now says the fallback dates "approximately" and is
  reflowed. The inline comment names "every sync since failed". The versioning rule is now
  step 6 of "How to contribute", headed "Leave the version alone" and giving the merge
  conflict reason. It still matches the release history (0.3.0 minor for the bin/ to
  scripts/ move; 0.3.1 and 0.3.2 patches).

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero). PASS.

## Ceiling

12/12 reached. The bounded gap is documented, not hidden. Removing it entirely is the
`--no-write-fetch-head` decision, which is the human's: the flag sets a minimum git version
(from memory, unverified: git 2.29).

## History

- Round 1, `1449b61`, 9/12, REQUEST CHANGES. Critical: `[ -f FETCH_HEAD ]` accepted the
  0-byte file that every failed fetch leaves with a new date (measured on git 2.50.1:
  unreachable host, bad path, missing object, all rc 128). Reproduced end to end: an
  offline `community-sync.sh` run silenced the reminder on a copy without a stamp.
  Important: the test setup `: > FETCH_HEAD` was that failure shape; the knowledge file
  left out failed fetches; the remaining gap was not named. Nitpicks: header wording, the
  inline comment, and where the versioning rule sat in CONTRIBUTING.md.
- Round 2, `eaffbef`, 12/12, APPROVE. Every round-1 finding fixed as proposed; one
  optional wording nitpick left. Correctness went from 0 to 2 and testing from 1 to 2.
- Round 3, `d586ff3`, 12/12, APPROVE. Re-anchor after a rebase onto local main `0f4c6ae`
  only: range-diff shows all six commits `=`, the C16 merge touched none of this branch's
  files, and `tests/odeo-context.test.sh` plus lint pass on the new base. Findings, scores
  and verdict are unchanged.
