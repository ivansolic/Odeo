---
artifact: gate-ignore-untracked-evals
type: code
branch: fix/gate-ignore-untracked-evals
reviewed_commit: cd5a985
date: 2026-08-06
scorer: code-reviewer
model: claude-opus-5[1m] (Opus 5, 1M context)
model_tier: strong
effort: high
record_version: 1
scores: { correctness: 0, security: 1, performance: 2, readability: 2, testing: 1, conventions: 1 }
total: 7/12
verdict: REQUEST CHANGES
previous_total: 11/12
---

## Scope reviewed

`cd5a985`, one commit closing the two fail-closed Importants left by
`docs/evals/code-fix-merge-gate-all-records.md` (v4, 11/12, `0316b7e`). Verified myself:
`git rev-parse --short HEAD` == `cd5a985`, tree clean, branch `fix/gate-ignore-untracked-evals`.
Three files: `bin/merge-gate.sh` (enumeration switched to `git ls-files`, one comment
marker, one quoting nit), `docs/eval-framework.md` (+15 lines documenting the invariant),
`tests/merge-gate.test.sh` (cases 48 to 50).

Evidence I produced myself, in throwaway repos, against the real script: the gate suite
(66/66 green at HEAD), one code mutation (`-uno` at line 56), one fixture probing the
untracked assumption under a git config, one probing non-ASCII record names, a
conflicted-index probe, a subdirectory invocation, and a side-by-side run of the
pre-change gate (`cd5a985^:bin/merge-gate.sh`) on the identical repo.

## Verdict

REQUEST CHANGES. The `.DS_Store` fix is right and the tests are honest, but the change
traded a fail-CLOSED defect for a fail-OPEN one, which is the exact pattern the parent
branch spent four rounds on. Guarantee 1 (any non-approving record refuses) now depends on
`git status --porcelain` reporting untracked files, which is client-configurable. Under
`status.showUntrackedFiles=no` an uncommitted REQUEST CHANGES record is invisible to BOTH
the clean-tree check and the enumeration, and the merge passes. The pre-change gate refused
the same repo. Fix is one flag; the guarantee should not rest on an ambient config.

## Critical

1. **`bin/merge-gate.sh:56` (and the claim at `:82-83`), guarantee 1 fails open when
   `status.showUntrackedFiles` is off.** The enumeration no longer sees untracked records,
   and the comment justifies that with "Nothing is lost: an untracked non-ignored file is
   already refused by the clean-tree check". That is true only under git's default
   untracked reporting, and line 56 does not pin it. Reproduced with post-cutoff records
   in the current flow: a committed `code-x.md` APPROVE, an uncommitted `design-x.md`
   REQUEST CHANGES (a second reviewer's record, a new filename, so no tracked file is
   modified), both anchored at HEAD, plus `git config status.showUntrackedFiles no`:
   - `cd5a985`: `merge-gate: preconditions hold ... 1 record(s) checked` , exit 0.
   - `cd5a985^` (the `find` version), identical repo: REFUSED, verdict REQUEST CHANGES,
     exit 1.
   The suite does catch the in-code form of this (mutating line 56 to
   `git status --porcelain -uno` fails case 49, 65/66), but not the ambient-config form,
   because the tests inherit the developer's git config. Fix, line 56, command line beats
   config:
   ```bash
   if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
   ```
   Stronger, and it makes the documented claim true by construction instead of by
   assumption, so I would add it as well as the flag (it also gives the accurate reason
   rather than "uncommitted changes present"):
   ```bash
   stray="$(git ls-files --others --exclude-standard docs/evals)"
   [[ -z "$stray" ]] || { echo "merge-gate: REFUSED, untracked file(s) under docs/evals:" >&2
     printf '%s\n' "$stray" | sed 's/^/  /' >&2
     echo "The gate reads TRACKED records. Commit them, or remove the stray file." >&2; exit 1; }
   ```
   Test to pin it (fixture-local config, no env plumbing in `check`): case 49 duplicated
   with `( cd "$d" && git config status.showUntrackedFiles no )` before the check, expecting 1.

## Important

2. **`bin/merge-gate.sh:122`, `git ls-files` C-quotes unusual paths, so a valid record can
   block every merge with a wrong diagnosis.** `core.quotePath` defaults to true, so a
   record named `docs/evals/code-café.md` is emitted as
   `"docs/evals/code-caf\303\251.md"`, quotes and escapes included. Reproduced against the
   real gate: the path cannot be opened, awk fails, and the gate prints
   `REFUSED, docs/evals contains file(s) whose frontmatter does not parse` and lists the
   quoted string. `find` handed over raw bytes and had no such failure. Same for a path
   containing `"` or `\`. It is fail-closed, so no bad merge passes, but it is the same
   class of defect this branch exists to remove, and the advice in the message ("re-run
   the reviewer") is wrong for it. Fix, line 122, NUL-delimited, no quoting at all, and it
   also removes the newline-in-filename hazard:
   ```bash
   done < <(git ls-files -z docs/evals 2>/dev/null | LC_ALL=C sort -z)
   ```
   with `while IFS= read -r -d '' r; do` at line 84. Minimal alternative if `-z` is
   unwanted: `git -c core.quotePath=false ls-files docs/evals`. Add a fixture with a
   non-ASCII record filename expecting 0.

3. **The fix is not installed, so `/merge` on this machine still runs the pre-change
   gate.** `~/bin/merge-gate.sh` is md5 `d6de6918...`, which is `cd5a985^`; the repo copy
   is `07905803...`. `skills/merge/SKILL.md:20` names `~/bin` FIRST, and AGENTS.md requires
   re-running `./install.sh` after editing anything under `bin/`. Net effect: the
   `.DS_Store` block this branch fixes is still live where the gate actually runs, and the
   parent branch's v1 raised this identical omission once already. Fix: `./install.sh`,
   then verify `md5 -q ~/bin/merge-gate.sh` equals `md5 -q bin/merge-gate.sh`.

## What I checked and found sound

- **Guarantee 3 survives.** Case 50's tracked unparseable record refuses; the tracked
  symlinked record (test line 472) and the tracked `.txt` record (line 543) are still
  enumerated, because `git ls-files` lists both, which a `-name '*.md'` filter would not.
- **Cases 48 to 50 are real, not vacuous.** 48 goes RED on reverting to `find`. 49 goes RED
  on `-uno` at line 56, so it is genuinely pinning the clean-tree path it claims, within
  the limit noted in Critical 1. 50 goes RED if the tripwire is dropped. `named_record`
  uses `PRE_CUTOFF_DATE`, so case 48's `.gitignore` commit does not trip the anchor, which
  is why the case passes for the right reason rather than by accident.
- **Mutations the suite does catch:** `find` restored (48 RED), `-uno` (49 RED),
  a re-added `*.md` pathspec (the `.txt` case RED).
- **Index-versus-worktree cases all stay refused, ahead of the enumeration:** a tracked
  record with uncommitted modifications, a staged-but-never-committed record, and a
  worktree-deleted-but-tracked record are all reported by `git status --porcelain`
  regardless of untracked configuration, so they refuse at step 2. A tracked path that is
  absent from disk (skip-worktree, sparse checkout, assume-unchanged) lands in the
  unparseable list, so it refuses too.
- **Subdirectory invocation is correct.** `cd "$(git rev-parse --show-toplevel)"` at line
  47 precedes the enumeration at line 122, and `git ls-files docs/evals` is a cwd-relative
  pathspec, so it resolves identically. Verified by running the gate from `docs/evals/`.
- **`docs/evals` is deliberately not gitignored** in this repo (an explicit NOTE at the end
  of `.gitignore`), so the "records invisible because the whole directory is ignored"
  failure does not exist here. In a downstream project that ignored `docs/evals/`, the gate
  would refuse with "no review record", fail-closed.
- **Submodule or nested repo under `docs/evals`:** `ls-files` does not descend into a
  gitlink, and the gitlink path itself lands in the unparseable list, so it refuses.
- **Performance is better,** one `git ls-files` process instead of a filesystem walk.
- **The documented invariant matches the code** ("EVERY tracked file under `docs/evals/`
  must be a parseable record"), with one wording defect, see nits.

## Nitpicks

- `docs/eval-framework.md:87` says an unparseable tracked file "refuses every merge on that
  branch". The tripwire runs before any branch matching, so it refuses merges from EVERY
  branch. Say so, it is the stronger and more useful warning.
- `docs/eval-framework.md:93-95` states the untracked-file consequence unconditionally.
  After Critical 1 is fixed it becomes true; until then it should not be asserted.
- `bin/merge-gate.sh:122`, `git ls-files` prints a conflicted path once per stage (verified:
  three times during a merge conflict), so the unparseable list would repeat it. Cosmetic
  only, since the clean-tree check refuses a conflicted tree first. `--deduplicate` or
  `sort -u` if you want it tidy.
- `bin/merge-gate.sh:97-104`, an index entry that cannot be read on disk is reported as
  "frontmatter does not parse", which misdiagnoses sparse checkout and skip-worktree. A
  `[[ -r "$r" ]]` branch with its own message costs two lines. Fail-closed either way.
- `bin/merge-gate.sh:94-96`, the KEPT IN SYNC marker is the right call and is accurate
  (the opening-frontmatter test now has four copies here and three in `bin/spec-gate.sh`),
  but a comment is documentation, not a mechanism, and lessons.md 2026-08-03 is precisely
  about claims wider than mechanisms. A shared `frontmatter_opens() { awk ... }` helper, or
  a lint asserting the copies are byte-identical, would enforce what the marker asks for.
- `bin/merge-gate.sh:122`, the `2>/dev/null` is now dead weight: `git ls-files` on a
  missing path exits 0 silently. Harmless, but it hides a real git error.
- The quoted `printf ... | sed 's/^/ /'` fix at line 128 is correct: a path with spaces no
  longer splits and a `*` no longer globs.

## Scores

correctness 0/2 (Critical 1: a reproduced fail-open regression of guarantee 1, with the
pre-change gate refusing the identical repo; plus Important 2, a valid record turned into a
permanent block) · security 1/2 (no injection, secret or authz surface, and the tier floor,
duplicate-key and anchor checks are untouched and still hold; docked because the floor of
guarantee 1 now rests on client git configuration rather than on the gate itself, counted
once here rather than twice) · performance 2/2 (one process replaces a filesystem walk) ·
readability 2/2 (the enumeration comment carries the real history and the change makes the
code shorter; the false clause inside it is counted under correctness, not again here) ·
testing 1/2 (48 to 50 are real, mutation-proven and pass for the right reasons, and the
suite catches the in-code form of Critical 1; but it cannot catch the ambient-config form,
it inherits the runner's git config, and there is no fixture for an unusual record
filename) · conventions 1/2 (`install.sh` not re-run, so the shipped fix is absent from the
path `skills/merge/SKILL.md` names first, a repeat of the parent branch's v1 finding;
everything else conforms: conventional commit, mutation discipline, no dashes, RED-first
cases)

**total 7/12** (threshold: >=9, no zero) -> FAIL

## Ceiling

12/12 is reachable. Critical 1 is one flag plus an eight-line explicit check, Important 2
is one flag or `-z`, Important 3 is running `./install.sh`, and the two new fixtures are
copies of case 49 and case 48. Nothing here is structural.

## Regression note vs the parent branch (v4, 11/12, `0316b7e`)

Worse, 11/12 -> 7/12, and worse for an instructive reason. Both Importants v4 raised are
genuinely closed: the `.DS_Store` block is gone (case 48 proves it, and reverting to `find`
proves the test), and the records-only invariant is documented. But v4's recommendation
carried an assumption in its own text, "step 2 already refuses on untracked non-ignored
files", and this branch implemented the recommendation together with the assumption without
testing it. It does not hold under `status.showUntrackedFiles=no`. So the sequence continues
the pattern the parent record described: each round removes the demonstrated instance and
inherits the undemonstrated claim attached to it. The lesson from 2026-08-03 applies to a
reviewer's suggested fix exactly as it applies to a builder's guard: the clause "nothing is
lost" is a coverage claim, and it needed a mutation before it was written into the code as a
comment, into `docs/eval-framework.md` as documentation, and into the commit message as a
conclusion.
