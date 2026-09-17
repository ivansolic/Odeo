---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh + tests/init-project.ledger.test.sh + bin/init-project.sh gitignore + project-templates/CLAUDE.md + skills/retro/SKILL.md exit table + tests/install-ps1.test.sh snapshot + README counts
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 4558a32
artifact_version: 2
date: 2026-09-17
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 1, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 7/12
verdict: REQUEST CHANGES
---

## Artifact

Commit `4558a32` on `feature/windows-powershell-entry`, round 2 of the ledger backup. It closes
both round-1 Criticals, adds `tests/init-project.ledger.test.sh`, and claims the five round-1
Importants. No plan exists in `docs/plans/` for this work, so there is no contract to compare
against; the design intent is the one stated in the program header, the `/retro` step and the
commit body.

**Both Criticals are genuinely closed, verified independently, not accepted.** I scaffolded a
project from the real templates through `CLAUDE_TEMPLATES_DIR` and asked git and the program
directly:

```
scaffold rc=0
git ls-files .claude/tasks                  -> []            (nothing tracked)
git check-ignore -v .claude/tasks/todo.md   -> .gitignore:34
git check-ignore -v .claude/tasks/lessons.md-> .gitignore:35
ledger-backup.sh <proj>                     -> exit 3, "no backup location recorded"
ledger-backup.sh --check <proj>             -> exit 3
```

That is C1 and C2 both gone at the seam where they lived. The suite that keeps them gone asks
git rather than the `.gitignore` text, and its case 7 pins the template's first layer
independently of the program's backstop, which is the right shape.

What I found instead is one class, repeated five times in the NEW code: **a guard whose comment
names a class while the mechanism covers instances.** That is verbatim this project's own
newest lesson (`.claude/tasks/lessons.md`, 2026-09-16, "Name above a guard only what the guard
actually covers"), and the commit body's own framing ("a MECHANISM rather than a third wording")
is what raises the bar it then misses. Every finding below is measured, not argued.

## Verification (by measurement)

- Real scaffold from the real templates: C1 and C2 closed, as above.
- Three containment bypasses planted and confirmed to write the ledger into the work tree with
  exit 0 and a stamp (I1).
- The `--check` unreadable-mtime path driven with a `date` shim on PATH, then run through the
  Stop hook (I2).
- Case 21's extractor mutated twice, both new codes invisible (I3).
- The stale `bin/ledger-backup.sh` path grepped across the shipped tree (I4).
- A legitimate `dir` target containing `>` planted (nitpick 1); a normal `dir` run inspected for
  staging residue (nitpick 2).
- I did NOT re-run the 33 suites; the builder reported them green and nothing I found depends on
  that count. I did not push to the private remote: the real-remote evidence below is attested
  by the owner and the commit body, not reproduced by me.

## Findings

### Critical

None. Both round-1 Criticals are closed and verified end to end.

### Important

**I1. The "never inside the project" guard is a raw string prefix compare, and three separate
inputs walk past it into the work tree, with exit 0 and a stamp.**
`bin/ledger-backup.sh:169-173` compares `"$dest/"` against `"$PROJECT_DIR"/*` without
canonicalising either side. Measured, all three, each ending with the ledger inside the repo and
`ledger-backup: refreshed ... exit 0`:

```
symlink : dir $T/link          (a symlink to $T/a/inside)    -> wrote $T/a/inside/internal-not-in-git/todo.md, stamp written
..      : dir $T/elsewhere/../b/backups                      -> wrote $T/b/backups/internal-not-in-git/todo.md
case    : dir $T/proj/backups  (PROJECT_DIR=$T/Proj)         -> wrote $T/Proj/backups/internal-not-in-git/todo.md
```

The third needs no symlink and no traversal, only a path typed in the wrong case on the
case-insensitive filesystem that is the default on the platform this repo is developed on. And
the landing spot is not covered by the .gitignore lines this very commit added (they name
`.claude/tasks/*` only), so the next `git add -A` commits it: this is exactly round-1 I1's harm,
through a guard written to end it. Trailing slashes and `dest == PROJECT_DIR` I also probed;
those the guard does catch.
Fix, one mechanism that removes the class instead of the three instances, since git already
answers the question authoritatively:
```sh
top="$(git -C "$PROJECT_DIR" rev-parse --show-toplevel)" && top="$(cd "$top" && pwd -P)"
mkdir -p "$dest/internal-not-in-git" || { ... exit 4; }
dtop="$(git -C "$dest" rev-parse --show-toplevel 2>/dev/null)" || dtop=""
[ -n "$dtop" ] && [ "$(cd "$dtop" && pwd -P)" = "$top" ] && {
  echo "ledger-backup: the target resolves inside the project ($dest)" >&2; exit 2; }
```
That resolves symlinks, `..` and case in one step, and it also fixes the narrower bug that the
current check uses `$PROJECT_DIR` rather than the work-tree ROOT, so a dest inside the repo but
outside a subdirectory `PROJECT_DIR` passes today. Then add the three probes above as cases;
without them the comment on line 167 stays wider than the code.

**I2. The `--check` fix moved the silence from the program into the hook, which is the only
automatic caller. Measured: the program says "silence would be a lie", and the session ends in
silence.**
`bin/ledger-backup.sh:123-126` now exits 2 when an mtime cannot be read, instead of folding it
into "nothing to back up". But `bin/session-end-check.sh:55-59` reacts to `lb_rc -eq 1` only and
discards stderr with `2>/dev/null`. With a `date` shim that fails on `-r`:

```
$ ledger-backup.sh --check .   -> exit 2, "cannot read the modification time of: todo.md
                                   so whether the backup is current cannot be decided, and silence would be a lie."
$ session-end-check.sh         -> exit 0, output: "session-end check:
                                     dev server still listening: node on :3998 ..."   (nothing about the ledger)
```

From the user's seat the behaviour is bit-for-bit what it was before the fix: a backup whose
state cannot be decided reports nothing, forever. Round 1 called this latent, and it still is,
but it is now latent behind a comment asserting it is closed.
Fix: handle it where it is observed. In `session-end-check.sh`, treat `lb_rc` 1 **or** 2 as
speech, with wording of the hook's own (`"the ledger backup cannot be checked (exit $lb_rc); run
ledger-backup.sh --check to see why"`), keeping the program's stderr out of the transcript for
the reason in round 1's nitpick. Add a case to `tests/session-end-check.test.sh` with a stub
`ledger-backup.sh` that exits 2, asserting the hook speaks and still exits 0.

**I3. Case 21, the contract mechanism this commit headlines, cannot see two of the `exit` forms
already present in the file it scans. Proven by mutation.**
`tests/ledger-backup.test.sh:291-292`:
```sh
grep -oE '^[[:space:]]*(\}; )?exit [0-9]+|exit [0-9]+;' "$SCRIPT"
```
Alternative 1 needs start-of-line; alternative 2 needs a semicolon glued to the digits. Neither
sees `bin/ledger-backup.sh:45` (`-*) echo ...; exit 2 ;;`) or `:55` (`... || exit 2`). It is
green today only because 2 also appears in a form it does see. Mutated:

```
line 45 -> exit 7 :  extractor reports 0 1 2 3 4 5 6   (7 invisible, table check stays GREEN)
new     || exit 8 :  extractor reports 0 1 2 3 4 5 6   (8 invisible, table check stays GREEN)
```

So a future code added as a `case` arm or after `||`, which is how five of the program's existing
exits are written, gets no row in `/retro` and nothing notices. The header claim "every `exit N`
the program can produce" is the exact class `lessons.md` 2026-09-16 forbids, and the mutation
that was run proved the ROW side (a missing row is caught), never the EXTRACTION side.
Fix: drop the anchors, scan for the statement and exclude comments:
```sh
for code in $(grep -vE '^[[:space:]]*#' "$SCRIPT" | grep -oE '\bexit ([0-9]+)' | grep -oE '[0-9]+' | sort -un); do
```
and prove the new extractor by planting `exit 7` in the `-*)` arm and watching case 21 go RED
before the claim is rewritten.

**I4. Round-1 I2 was fixed in the skill and not swept: two places still tell a scaffolded project
to run a path that exists only in this repo.**
`bin/session-end-check.sh:58` prints `... run /retro, or bin/ledger-backup.sh`, and
`project-templates/CLAUDE.md:86` ships `` `/retro` and `bin/ledger-backup.sh` read it `` into
every new project. `install.sh` puts the program in `~/bin`; `project-templates/` ships no
`bin/`. The hook itself locates the program correctly (`dirname "$0"`), so this is advice that
fails, not a broken call, but it is advice printed at the exact moment the user is being told
their backup is behind. This is `lessons.md` 2026-08-10 ("grep the ENTIRE repository for the old
premise, not the file I was pointed at") one round later.
Fix: use the form `skills/retro/SKILL.md:43` now uses, `ledger-backup.sh` (installed in `~/bin`,
repo fallback `bin/ledger-backup.sh`), in both places.

**I5. The git branch still copies unchecked, so the atomicity reasoning applied to the `dir`
branch stops at the case boundary.**
`bin/ledger-backup.sh:226-227`: `mkdir -p "$work/internal-not-in-git"` and
`for f in $present; do cp ... ; done`, neither checked. If a `cp` fails (ENOSPC, EIO on the temp
filesystem), `git add -A` stages whatever landed, the previous backup's copy of the missed file
survives in the shallow clone, and the run reports `refreshed (todo.md lessons.md -> ...)` and
stamps success over a backup that is stale in one file. That is the sentence at lines 180-183
explaining why the `dir` branch was made atomic, unapplied to the branch next to it. Probability
is low; the consequence is the one thing the program exists to prevent.
Fix: `cp ... || { echo "ledger-backup: copy failed for $f, NOTHING was backed up" >&2; exit 4; }`,
same wording as line 189, and check the `mkdir`.

### Nitpicks

- `bin/ledger-backup.sh:96-102`. The placeholder guard fires on `<` **or** `>` anywhere in the
  value, and a false positive lands on exit 3, the silent one. Measured with a real directory:
  `ledger_backup: dir $T/out>put` -> exit 3, "still holds the template placeholder", and the Stop
  hook then says nothing forever. Both characters are legal in paths and in git ref names.
  Narrow it to an actual pair, `*'<'*'>'*`, which still catches every shape the template ships.
- `bin/ledger-backup.sh:184-195`. The staging dir has no trap: only `cp`/`mv` failures clean it,
  so an interrupted run leaves `$dest/internal-not-in-git/.staging.<pid>/` holding a full copy of
  the ledger, and no later run sweeps it (each `rm -rf`s only its own PID). In the recommended
  `dir ~/Dropbox/...` setup that is stale ledger copies accumulating in a synced folder with no
  retention. The PID name also collides across hosts on a shared destination, where run A's
  opening `rm -rf` can delete run B's staging mid-copy (result is a false exit 4, loud, so
  bounded). Fix: `staging="$(mktemp -d "$dest/internal-not-in-git/.staging.XXXXXX")"`, a
  `trap 'rm -rf "$staging"' EXIT` for the `dir` branch, and sweep `.staging.*` on entry.
- `bin/ledger-backup.sh:110-126` has no test. The branch is reachable with a five-line `date`
  shim on PATH (I used one), and this repo's own rule is that a guard never seen failing is false
  confidence.
- `skills/retro/SKILL.md:52`. Row 3 says "no location is recorded ... offer to add a
  `ledger_backup:` line", which is wrong advice for the placeholder case that now also returns 3:
  a line exists. Add "or the line still holds the template placeholder; show the message".
- `tests/init-project.ledger.test.sh:93-96` matches `*ledger*|*backup*` against the hook's WHOLE
  output, which carries `pgrep`/`lsof` results from the developer's machine; my run of that hook
  printed `dev server still listening: node on :3998`. A process or port containing "backup"
  flips it red for unrelated reasons. This is round 1's unfixed nitpick on
  `tests/session-end-check.test.sh:55`, copied into new code. Anchor on the hook's own wording
  (`*NEVER*`, `*BEHIND*`).
- `bin/ledger-backup.sh:201-203` still takes `awk '{print $3}'` for the branch, so
  `git backup my branch` backs up to a branch named `my` at exit 0 (round-1 nitpick, unfixed).
- `tests/ledger-backup.test.sh:148` `d="$TMP/localwins"` is still assigned and never used.

### Still sound, re-probed or carried forward

- No force push; a third party's commit survives (now covered by case 17, and my round-1 manual
  probe agreed).
- No injection: every config-derived value is quoted, nothing is `eval`ed.
- `--check` remains offline and precedes the `case "$KIND"`, so the Stop hook does no network.
- The stamp still lives in `$GIT_DIR` and cannot be committed; no ledger CONTENT reaches stdout
  on any path.
- Cases 16-20 are well chosen: the steady state asserts remote CONTENT and a commit count, the
  in-project case asserts the message explains itself, and case 18 asserts "nothing written" in
  both directories plus "no stamp", which is the right triple for a refusal.
- `tests/install-ps1.test.sh` mode canary: `before` is re-taken after case 9b has consumed it and
  `mode-probe` is removed at the end, so the added shape does not perturb the real comparison.

### Residual, stated rather than scored

The real-remote gap is closed by owner-attested evidence I did not reproduce: exit 0, branch
`483b8af` -> `c3cbd30`, one file changed. I take exit 0 and the clone -> commit -> push path as
proven; exits 4 and 5 remain proven against local fixtures only, so "push refused" is still shape,
not cause.

## Scores

correctness 1/2 - the two Criticals are closed at the seam and verified independently, and the
mechanism's core (stamp only after verified success, failure classes distinguishable) held every
probe. Docked, not zeroed, because three of the five fixes are narrower than their comments in
ways I could measure: the containment guard admits a symlink, a `..` and a case-differing prefix
straight into the work tree at exit 0 (I1); the `--check` fix is invisible in the only automatic
caller (I2); and the git branch's unchecked `cp` can still report a backup it did not make (I5).
None inverts default behaviour the way C1 did, which is the difference between 1 and 0.

security 1/2 - hygiene stays good: quoting, no `eval`, no force push, no network on the hook
path, no content on stdout, stamp outside the work tree, and C2's actual publication risk is now
enforced by git rather than asserted. Docked for I1, which is still a measured path where ledger
content lands inside a git work tree under a success message, in a directory none of the new
.gitignore lines cover.

performance 2/2 - staging adds one extra copy plus a rename of two small files; `--check` is
unchanged and offline; the clone stays `--depth 1 --single-branch`. Nothing here is hot.

readability 1/2 - the new comments are the best documentation in the commit and each carries its
reason at the point of use. Docked because three of them assert more than the code does
("never inside the project" at :167, "silence would be a lie" at :125, "every `exit N` the
program can produce" at test :283), which is the failure the project's own newest lesson names.

testing 1/2 - a real improvement: the scaffold suite asks git instead of the .gitignore text,
its instrument check at :51 aborts loudly so it cannot pass vacuously, case 7 pins the template
layer independently of the backstop, and the steady state plus the third-party push are finally
covered. Docked because the round-2 fixes went in with the same coverage shape as the round-1
defects: no case for the containment guard's bypasses, none for the unreadable mtime, none for
the hook seeing exit 2, and case 21's mutation proof covers the row side of the mechanism but
never the extraction side, which is the half that is broken.

conventions 1/2 - up from zero: the standing rule "the build ledger never ships" is now enforced
where it ships, by a suite that asks git. Docked because two recorded lessons repeated inside
this commit: 2026-09-16 (a guard's comment may name only what it verifies) three times, and
2026-08-10 (grep the whole repository for the old premise) in I4. No em or en dashes; English
comments; exec bits and header shape conform.

total 7/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 is reachable and the remaining work is small. I1 is one `git rev-parse --show-toplevel`
comparison plus three cases; I2 is one `-eq 2` arm in the hook plus one stub case; I3 is a
simpler grep plus one planted mutation; I4 is two strings; I5 is one `||` clause. Nothing is
structural: the program's mechanism is sound and I could not make the stamp lie by any path
except I1's. The remote-side gap (exits 4 and 5 against a real server) is a residual to state,
not a cap.

## What's good

- The two Criticals were fixed where they lived rather than where they were noticed, and the
  suite that keeps them fixed interrogates git and a real scaffold instead of the text that was
  wrong. Case 7 in particular, pinning the template layer independently so the comment cannot
  quietly start depending on the program's backstop, is the correct structure for a two-layer
  fix and is rarer than it should be.
- Case 18 asserts a refusal by its three outcomes (exit code, nothing written in either
  candidate directory, no stamp) rather than by its message, which is what makes it a guard
  instead of a spelling test.
- Case 17 (a third party advances the branch, our backup must fast-forward and their file must
  survive) tests the property, not the implementation, and would survive a rewrite of the git
  branch.
- Reaching for a mechanism instead of a third wording for the exit-code table is the right
  instinct, and the right lesson drawn from round 1. The instinct is correct; only the regex is
  short of it.
- The staging-then-move design makes the exit-4 message true rather than approximately true, and
  says so at the point of use.

## History

- **Round 1** (`cebc0a0`, 2026-09-16): REQUEST CHANGES, 5/12
  (correctness 0, security 1, performance 2, readability 1, testing 1, conventions 0).
  C1: the template's own example lines read as live configuration, so every scaffolded project
  shipped a placeholder target and the Stop hook nagged every session. C2: `init-project.sh`
  wrote no .gitignore entry for the ledger and then committed it, while five new sentences
  claimed the opposite. Importants: a relative `dir` target resolving against the caller's cwd
  and reporting success; `/retro` pointing at `bin/ledger-backup.sh`; no row for exit 2; no
  coverage of the steady-state clone-commit-push; `--check`'s mtime read failing open into
  silence.
- **Round 2** (`4558a32`, 2026-09-17): REQUEST CHANGES, 7/12. Regression note: **better.**
  Both Criticals verified closed against a real scaffold, conventions and correctness each up
  one, and the testing surface genuinely widened. Five Importants remain, all one class (a guard
  or comment wider than its mechanism), three of them inside the round-1 fixes themselves.
