---
artifact: scripts/ledger-backup.sh + tests/ledger-backup.test.sh + scripts/docs-claims-check.sh + tests/docs-claims-check.test.sh + docs/system-map.md row 146
type: code
branch: fix/ledger-backup-and-eval-docs
reviewed_commit: 2b772ab
artifact_version: 1
date: 2026-09-30
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 10/12
verdict: REQUEST CHANGES
---

# Code review: fix/ledger-backup-and-eval-docs

## Artifact

Commits `f2a7d39`, `830b72d`, `1695501` at `2b772ab`, against local `main` `3cf2fe1`. Commit
`2b772ab` itself (AGENTS.md, docs/eval-framework.md, skills/build/SKILL.md) is skill-reviewer's
scope; glanced at for claims about code only, none wrong.

These commits close the carried-deferred items of `docs/evals/code-ledger-backup.md` (branch
`feature/windows-powershell-entry`, `15b168f`) and two docs-claims-check findings.

## Verdict

REQUEST CHANGES. The rubric total clears the threshold (10/12, no zero), but the one Important
finding falsifies the headline claim of `1695501` ("the footer names the cause that occurred") in
the shape a machine with zero skips produces, the fix is a few lines plus one test, and an APPROVE
would end the review loop with it open.

## Findings

### Critical

None.

### Important

**I1. `scripts/docs-claims-check.sh:59-77,116,154-163`: a broken suite on a machine with no skips
still ends on "Fix the NUMBER in the document", next to "fix the suite, not the document".**
When a suite exits non-zero it reports fewer `ok` lines, so the assertions total no longer matches
the README. With no SKIP lines the mismatch is not excused as unverified, `claim()` prints DRIFTED
and sets `claim_fail=1`, and the footer prints BOTH remedies, contradicting each other and the
script's own `SUITE FAILED ... the assertion count below is not a measurement` line. Measured at
`2b772ab` from a script file (README correct at the healthy count of 3, one suite printing one `ok`
then `exit 1`, no skips):

```
SUITE FAILED: tests/broken.test.sh exited 1, so the assertion count below is not a measurement.
DRIFTED: assertions , README says 3, the tree has 2
docs-claims-check: 1 suite(s) failed; a suite failed to run, so fix the suite, not the document.
docs-claims-check: a documented claim no longer matches the tree.
Fix the NUMBER in the document, never this check, unless the check is what is wrong.
```

Case 6 misses this because its README already matches the broken total (2), and its skip would
excuse the mismatch anyway. The zero-skip shape is the ordinary one off this machine (the recorded
skip causes are running as root and bash 3.2). *Fix:* when `suite_fail > 0`, do not judge the
assertions claim at all. Pass `claim()` a reason ("a suite failed, so this total is not a
measurement") so it takes the UNVERIFIED branch (which never sets `claim_fail`), and `fail` stays
1 through the suite. Add a case 6c: no skips, one broken suite, README at the healthy count. It
must show "a suite failed to run" and must not show "Fix the NUMBER". Watch it fail at `2b772ab`
first.

### Nitpicks

- `scripts/docs-claims-check.sh:157`: "failed; a suite failed to run" says the same thing twice,
  and "failed to run" is wrong for a suite that ran and had a failing assertion. Suggest
  "$suite_fail suite(s) exited non-zero, so fix the suite, not the document." (update the case-6
  grep with it).
- `scripts/ledger-backup.sh:52-53`: "the variables that LOCATE a repository" are said to be
  dropped, yet `GIT_CEILING_DIRECTORIES` and `GIT_DISCOVERY_ACROSS_FILESYSTEM`, both part of
  repository discovery, are kept. Not exploitable here: LOCATION is decided by on-disk markers,
  and git's discovery from the remote's own directory checks that directory whatever the ceiling
  says. Say "NAME a repository" (the wording `:78` already uses), or add both to the KEPT list.
- `scripts/ledger-backup.sh:394-411`: with a RELATIVE `$HOME`, `~/x/y:z` now converts to nothing
  (before, to `rel/x/y:z`, which failed closed at exit 4), and `url_is_relative` calls it
  absolute, so the containment guard is skipped. `~/x` with no colon already behaved this way
  before this branch, and header residual 7 covers `$HOME`. Exotic and unmeasured (the probe was
  refused by the worktree sandbox). If you care, have `url_is_relative` treat a `~` whose
  expansion is not absolute as relative.
- Still open from the `code-ledger-backup.md` batch and not claimed by this branch: I1 there
  (`tests/ledger-backup.test.sh:1049` asserts `!= 0`, not `= 4`) and case 40's four-spelling
  regex. Track them so they are not lost with that record.

## Verification of the claimed closes

1. **`local_url_path` arm dropped (f2a7d39):** correct. The removed arm matched only inputs that
   `url_is_relative` classifies as relative (no scheme, no leading `/`, slash before the first
   colon; a `~` is expanded to an absolute `$HOME` before the case). The relative refusal at
   `:458` runs before the only other call site (`:548`), so no input reaching `:548` could have
   used the arm. Test 42b's arrangement (a symlink from the caller's directory to the publish
   remote) is exactly the one that made the old arm's `pwd -P` resolve to the publish remote. The
   RED is consistent with the code as read; not re-run.
2. **Header narrowed (830b72d):** accurate apart from the LOCATE nitpick. **Keeping
   `GIT_SSH_COMMAND`: agreed.** The dropped families are ones git itself exports to hooks
   (`GIT_INDEX_FILE`, `GIT_CONFIG_PARAMETERS`); `GIT_SSH_COMMAND` comes from the caller's own
   shell, like `core.sshCommand` in their config, which unsetting would not touch. Dropping it
   would not close record residual 1 either: `git@localhost:<in-tree bare>` over a real sshd lands
   the same way. It would break real key and proxy setups for no closed hole.
3. **Footer split (1695501):** holds in the shapes tested; fails in the zero-skip shape (I1).
4. **Skip note dedup + causes pinned:** correct. `skip_reason` is now the single source for both
   the note and `claim()`.
5. **system-map row:** the fourth refusal matches `:548-555` (exit 4 only when a path converts and
   is not a directory, nothing-converts is not refused, as stated), `-ef` matches `:575`, and the
   env sentence matches the header.

No em or en dashes in added lines (checked with a planted positive control first). skills-lint and
the suites were not re-run here; the author reports 39 green at `2b772ab`.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 1/2 · conventions 2/2
-> total 10/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reachable. Correctness and testing each lose a point to I1 alone; the nitpicks do not cap
anything.

## Relation to docs/evals/code-ledger-backup.md

That record gates branch `feature/windows-powershell-entry` at `15b168f` (merge-gate enrols by
exact `branch:` match), so it neither gates nor blocks this branch. It can stay as the history of
its own branch; it does not need to be regenerated. Its "must be regenerated at the new head"
note was meant to stop anyone passing it off as covering new ledger code, and this record is what
covers that code for this branch. Its carried-deferred items 1 and 2 are closed here, see above.
Its I1 and case-40 items remain open.

## History

- Round 1 (`2b772ab`, 2026-09-30): REQUEST CHANGES, 10/12. First record for this branch, so there
  is no regression baseline. Compared to the last ledger record (9/12 at `15b168f`), readability
  and conventions go from 1 to 2 because the two deferred comment edits landed. Correctness drops
  to 1 on a new docs-claims-check defect in this branch's own footer fix.
