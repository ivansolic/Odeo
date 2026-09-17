---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ tests/install-ps1.test.sh, README counts, docs/eval-framework.md, docs/plan-format.md)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 994ede8
artifact_version: 6
date: 2026-09-17
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 1, performance: 2, readability: 1, testing: 1, conventions: 2 }
total: 8/12
verdict: REQUEST CHANGES
previous_total: 8/12
---

## Artifact

Commit `994ede8` on `feature/windows-powershell-entry`, clean tree. One commit since round 5.
It removes the class round 5 stopped on: `in_work_tree` no longer calls git, it walks the
target's resolved ancestors for a repository MARKER. It also unsets `GIT_DIR`/`GIT_WORK_TREE`,
rewrites the header's exit-2 row, and adds cases 30 to 33 (94 -> 103 assertions). No plan exists
in `docs/plans/` for this work, so the binding statements remain the program header, the guard
comments, `/retro`'s exit table and the commit bodies.

## Round 5's blocker, checked against the tree

**C1 is CLOSED, structurally, and the class is removed rather than patched.** Verified by
probe, not by reading:

| probe | result at HEAD |
|---|---|
| round-5 C1 exactly (linked worktree, `chmod 000 .git/worktrees`) | refused, exit 2, nothing written, no stamp (case 30, green) |
| `.git` file pointing at a gitdir that is gone | refused, exit 2 (case 31, green) |
| bare repository, and a target inside a `.git` directory | both refused (case 32, green); `git init --bare --ref-format=reftable` still creates `refs/`, so the HEAD+objects+refs test holds on git 2.50.1 |
| a repo whose `.git` sits in a **traversable but unreadable** ancestor (`chmod 111`) | refused. `[ -e "$p/.git" ]` needs search, not read, and every ancestor of a path that `cd`+`pwd -P` resolved has search by construction |
| symlinked ancestors, `..`, case-differing, dest-is-a-symlink | all resolved away before the walk starts (`pwd -P` on `$parent` and on the real landing dir), cases 22 and 25b green |
| `GIT_DIR`+`GIT_WORK_TREE` exported at a different repo, legitimate outside target | now backs up correctly and stamps the RIGHT repo. Round 4's carried nit is closed |

**Did dropping the "git cannot decide" exit-2 branch lose a signal?** No. I looked for a state
git calls "inside a work tree" that the walk cannot see, and every candidate is covered: dubious
ownership and an unreadable `.git/config` both still have a `.git` entry on disk; `GIT_DIR` and
`GIT_WORK_TREE` are unset, so git can no longer see a repository the disk does not show;
`GIT_CEILING_DIRECTORIES` and the filesystem-boundary rule only make git's discovery *narrower*
than the walk. The walk is strictly stricter than what it replaced, and it is now the only
mechanism, so there is nothing left for a "cannot decide" branch to decide. Marker detection is
permission- and locale-independent, which is what the round-5 finding asked for.

`/retro`'s exit-2 row (`skills/retro/SKILL.md:51`) still says exit 2 covers "a state the program
could not decide ... a repository git cannot read". After this commit that is no longer a state:
such a repository is now plainly detected and refused. Small overstatement, noted under nitpicks.

## Findings

### Critical

None. Every default-state path I probed refuses correctly, the containment invariant holds
against every disguise this branch has accumulated, and no configuration the project ships or
documents reaches the two Importants below.

### Important

**I1. The environment guard added by this very commit covers two of the four git variables that
matter, and the one it misses lets the backup DESTROY the caller's index while reporting success.**
`bin/ledger-backup.sh:45-50`. The rationale written above `unset GIT_DIR GIT_WORK_TREE` names the
scenario itself: "routine when this runs from a git hook". Measured which variables git actually
exports to hooks on 2.50.1:

```
pre-commit / prepare-commit-msg / commit-msg / post-commit -> GIT_INDEX_FILE
git commit      -> GIT_INDEX_FILE=.git/index          (relative, harmless by accident:
                                                       `git -C "$work"` re-roots it in the clone)
git commit -a   -> GIT_INDEX_FILE=/abs/.git/index.lock (absolute, and then it bites)
```

`git -C "$work" add -A` (`:380`) and the commit at `:388-391` obey an inherited `GIT_INDEX_FILE`.
Measured on the shipped script:

```
GIT_INDEX_FILE=$proj/.git/index  ledger-backup.sh $proj
  -> exit 0, "refreshed", stamp WRITTEN
  -> project index BEFORE: CLAUDE.md, src.txt
  -> project index AFTER : internal-not-in-git/lessons.md, internal-not-in-git/todo.md
  -> git status in the project: "fatal: unable to read 1f9d725a..."   (the objects lived in
     the temp clone, which the EXIT trap has already deleted)

as a real pre-commit hook, `git commit -am`:
  -> "error: invalid object ... error: Error building trees", the user's commit does NOT happen,
     their work stays uncommitted, and ledger-backup reported success and stamped it
```

Staged-only work (anything built with `git add -p`) is gone with the index; the blobs may survive
in `.git/objects`, the arrangement does not. This is the program's own signature failure, a tool
reporting a success it did not have, pointed at the user's repository instead of at the backup.

Fix, one line, and I proved it rather than proposing it:

```
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_QUARANTINE_PATH
  original script + GIT_INDEX_FILE -> project index replaced, `git status` fatal
  patched  script + GIT_INDEX_FILE -> project index byte-identical, backup still exit 0
```

And pin it: a case that sets `GIT_INDEX_FILE` to the project's index, runs the git branch, and
asserts `git -C "$p" ls-files` is unchanged. The guard this commit added currently has no test at
all, which is `lessons.md` 2026-08-03 ("a guard never observed failing is false confidence")
applied to the guard, not to the code it guards.

**I2. The containment invariant is enforced on the `dir` branch and not on the `git` branch, so
the same mistake succeeds through the other kind.** `bin/ledger-backup.sh:197-280` versus
`:305-348`. `in_work_tree` is defined INSIDE the `dir)` arm, so the `git)` arm cannot reach it and
does not ask. Measured:

```
ledger_backup: git backup internal-files, with remote `backup` = $PROJECT/inside-bare.git
  -> exit 0, "refreshed", stamp written
  -> git status in the project: `?? inside-bare.git/`
  -> git check-ignore: NOT IGNORED
  -> git add -A stages 24 files from it, including 5 loose objects that ARE todo.md and
     lessons.md verbatim
```

The `dir` branch refuses exactly this shape at exit 2 with "a backup in a repo is not a backup:
it shares the disk it protects against, and the next 'git add -A' commits the ledger you are
keeping out of git" (`:258-259`). That sentence is true of the `git` branch too, and the header's
exit-2 row (`:34`) promises the refusal for "a target inside ANY git repository" without saying
it means only the `dir` kind. Fix: hoist `in_work_tree` and `refuse_in_repo` above the `case`,
and in the `git` arm, after `url` has been through `ls-remote --get-url`, resolve a local-path URL
(`[ -d "$url" ]`, and the `file://` spelling the nitpicks below already flag) and run the same
check on it. Pin with a case that points `backup` at a bare repo inside the work tree.

**I3. The commit fixed the header's exit-2 row and left exit 4 and exit 3 drifting the same way,
and case 33 is structurally blind to it.** `bin/ledger-backup.sh:40-41`. The header says exit 4 is
"target unreachable (no such remote, clone/fetch failed, directory missing)". Exit 4 is also
returned for an unwritable destination (`:268`, `:290`), a failed copy (`:294`, `:378`), a failed
move (`:298`), no temp dir (`:350`), a failed `git init` (`:361`) and a failed commit (`:391`).
Case 24 in the suite deliberately pins exit 4 for an *unreadable ledger file*, which the header
describes as the target being unreachable. `/retro` already has the right wording
(`skills/retro/SKILL.md:53`, "unreachable remote, missing directory, **a copy that failed**"), so
the two tables this commit set out to reconcile are still apart, one row down from the one it
reconciled. Same for exit 3: `/retro:52` carries the template-placeholder state, the header
(`:40`) does not, and `:121-127` returns 3 for it. Case 33 checks that a row EXISTS, and its own
comment says it cannot catch a row that lies, so the mechanism added this round would never have
found the defect this round fixed. Fix: mirror `/retro`'s rows 3 and 4 into the header, and
delete the "a repository git cannot read" clause from `/retro`'s row 2, which stopped being a
state at this commit.

**I4. The refusal message names the target and throws away the only fact the user needs, which
ancestor carried the marker.** `bin/ledger-backup.sh:256-262`, called with `$landing_real` at
`:266` and `:279`. Measured: with a repository three levels up, the message is "the target is
inside a git repository (/.../hid/repo/sub/target)" and never mentions `/.../hid/repo`. This
matters more after this rewrite than before it, because the guard now fires on a pure disk rule
with no exceptions: a user whose `$HOME` is a dotfiles repo gets every target under `$HOME`
refused, including `~/Dropbox/odeo-ledger`, which is the header's own documented example at `:26`.
The walk already knows the answer and discards it. Fix: have `in_work_tree` print the marker path
it stopped at, and have `refuse_in_repo` name both ("the target `<x>` is inside the repository at
`<y>`"). One extra sentence when the marker is at `$HOME` would pay for itself.

### Nitpicks

- `bin/ledger-backup.sh:251-252`. The loop terminates on `[ "$p" = "/" ]`. Measured on this
  platform `pwd -P` can return `//` (POSIX permits it) and `dirname //` returns `/`, so it
  terminates here; on a platform whose `dirname //` returns `//` this hangs forever. Make it a
  fixpoint instead of a literal: `np="$(dirname "$p")"; [ "$np" = "$p" ] && break; p="$np"`. Same
  cost, no platform assumption.
- `bin/ledger-backup.sh:243-245`. The stated residual names only the "`.git` entry that is not a
  repository" false positive. The second marker shape has one too: any directory holding a file
  `HEAD` plus directories `objects/` and `refs/` is refused. Fail-closed and fine, but the comment
  should carry both shapes since it carries one.
- `bin/ledger-backup.sh:50` and `:69`. `GIT_DIR` is unset at 50 and then re-used at 69 as the
  script's own variable. It is safe only because `unset` strips the export attribute; one `export`
  or one `set -a` re-arms the exact bug just fixed, in a variable whose name is a git control
  variable. Rename to `PROJECT_GIT_DIR`. That is `lessons.md`'s "mechanism at the point of use": a
  name that cannot collide beats a comment explaining why the collision is currently harmless.
- `tests/ledger-backup.test.sh:468-487`. Case 25c's comment still frames itself as "a git that
  CANNOT ANSWER is not a git that said no repository". Nothing asks git any more, so the case now
  duplicates case 22's plain-repo detection and no longer pins a distinct axis. The version that
  pins what the new comment actually claims ("an unreadable one is still visible") is
  `chmod 000 "$broken/.git"` rather than `.git/config`: the marker test needs search on `$broken`
  only, so it must still refuse. Restate the comment to match the mechanism, per `lessons.md`
  2026-09-16.
- `tests/ledger-backup.test.sh:633-644`. Case 33 greps `exit [0-9]+` over the whole file, comments
  included, so a comment mentioning "exit 7" would demand a header row for a code the program
  cannot return. Case 21 accepted that trade explicitly; worth one clause in case 33's comment so
  the next reader does not rediscover it.
- Carried from round 5, re-measured at HEAD and unchanged: `canon_url` (`:330-336`) resolves a
  local URL against the CALLER's cwd while git resolves it against the repository, so a relative
  remote URL misses the publish compare and the run then dies at exit 4 with a false "offline"
  message; `origin = $SB/pub.git` versus `alias = file://$SB/pub.git` still pushes at exit 0 and
  the residual text should say `file://` is a local path the `pwd -P` step does not settle;
  `awk '{print $3}'` (`:307`) truncates `ledger_backup: git backup my branch` to branch `my`;
  the case-only assertions at `tests/ledger-backup.test.sh:371-377` are vacuous on a
  case-sensitive filesystem; `tests/ledger-backup.test.sh:147` still assigns an unused `d`;
  cases 28 and 29 still `chmod` without a per-case restore trap (case 30 got this right,
  restoring before its assertions, which is the pattern the other two should copy); case 26 still
  has no note that `chmod 444` rests on this platform's `ls`.
- Not re-scored here, flagged as the other record's finding: `tests/install-ps1.test.sh:339-352`
  adds a one-time HOME warm-up. It does not touch ledger-backup and I did not re-run that suite.

## Scores

correctness 1/2, the blocker is genuinely gone and I could not find a way back into it: the
containment guard now holds against unreadable gitdirs, dangling `.git` pointers, bare repos,
`.git` directories, unreadable-but-traversable ancestors, symlinks and `..`, and it holds without
reading a message from anything. Docked, not raised to 0, for two measured wrong outcomes at
exit 0 with a stamp: I1 replaces the caller's git index, I2 lets the git branch accept a target
the dir branch refuses by name. Both need a configuration this project neither ships nor
documents, and every default path I probed refuses correctly, which is why these are Important
and not Critical. A reader who thinks "the tool corrupts the user's index" is Critical regardless
of precondition will reach 7/12 and the same verdict; the facts are the same either way.

security 1/2, the confidentiality path that docked round 5 is closed and independently
reproduced: the ledger no longer reaches a live work tree through any containment disguise I
could construct, and the publish-remote guard still refuses all three spellings. The new dock is
I2: the ledger's content ends up inside the work tree as loose objects, untracked and NOT
ignored, so the next `git add -A` stages it, which is precisely what gitignoring these files was
for. Hygiene remains good: quoting throughout, no `eval`, no ledger content on stdout, stamp
under the git dir, `--check` offline, `ls-remote --get-url` contacts nothing.

performance 2/2, the rewrite removed a git process from the hot path and replaced it with a
handful of `test` calls plus one `dirname` fork per ancestor. The suite runs in 16.3s, still
dominated by three deliberate `sleep 1`s that the mtime assertions need.

readability 1/2, the code got much simpler (nine lines, no subprocess, no message parsing) and
the comment states its own residual instead of implying none. Docked for I3 (the header's exit-4
and exit-3 rows describe a program that has not existed for several commits, while `/retro` is
correct), I4 (a refusal that names the wrong path), and the `GIT_DIR` name re-use at `:69`.
The guard now carries roughly 25 lines of historical narrative over 9 lines of code; that
history earned its place across five rounds, but it is at the point where a one-line statement of
the rule plus a pointer to this record would read better than the third retelling.

testing 1/2, cases 30 and 31 are the right mechanism for the right reason: they reproduce the
measured blocker, they were verified failing before the fix, and 31 needs no permission trick so
it runs as root too. Case 32 pins what a rewrite could silently have dropped, which is the
discipline `lessons.md` 2026-08-18 asks for. 103 assertions green, re-run here. Docked because
the same commit shipped a second guard, `unset GIT_DIR GIT_WORK_TREE`, with zero coverage, and
that is where I1 lives: no case would notice the variable list being wrong, short, or deleted.
Also case 25c now claims an axis its mechanism no longer has.

conventions 2/2, verified rather than accepted: `docs-claims-check.sh --assertions` green with
24 executables, 33 suites, 24 programs with their own suite and 1016 assertions, matching README.
Conventional commit with a body that states what was measured and what was derived, feature
branch, no secrets, English comments, no em or en dashes in any changed file. The headline
`lessons.md` rule for this branch, eliminate a recurring class structurally rather than write a
fourth pattern, was followed exactly, including declining to re-word the lesson.

total 8/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 is reachable and closer than the unchanged total suggests. I1 is one line, proven here to
fix it, plus one case. I2 is hoisting two functions above the `case` and one `[ -d "$url" ]`
check. I3 is copying two rows `/retro` already has. I4 is returning the marker path the walk
already computed. The remote-side residual is unchanged from rounds 2 to 6 and is worth stating
rather than scoring: exits 4 and 5 are proven against git's own refusals, exit 0 against a real
network remote remains owner attestation I did not reproduce.

## Loop position

**This is round 6 on this artifact, against a cap of three** (`docs/eval-framework.md`, stop
condition 2). The loop ran this long only because the human took the escalation twice, after
rounds 3 and 5, which is the intended use of the cap rather than a breach of it.

**The class that stopped round 5 did not recur, it was removed.** That class was "a safety
decision keyed on TEXT" (round 3's containment spellings, round 4's publish-remote compare,
round 5's stderr match). At HEAD nothing in the containment guard reads a string produced by
another program, so the next instance of that class is not available to be found, and stop
condition 3 does not fire. I checked that operationally rather than by name: none of I1 to I4
would be closed by the same kind of fix as any round-3-to-5 finding.

The four findings are three different classes, each raised for the first time: an incomplete
environment isolation (I1), an invariant enforced on one of two code paths (I2), and a contract
document lagging the code it documents (I3, I4). None is a repetition. But I3 is the second
consecutive round in which the header's exit table has drifted from `/retro`, so if a round 7
happens and the header drifts again, that IS a class and the answer is a test that compares the
two tables to each other rather than each to the code.

**Recommended next step, which is the human's call and not an automatic round 7:** apply I1 and
I2 (both narrow, both with a proven fix and a named test), decide whether I3 and I4 are fixed or
recorded as residuals, then re-run this reviewer ONCE to re-anchor the record at the new head. If
that round produces a fifth first-time class, the evidence is about the surface area of this
program, not about any one fix, and the honest move is to freeze the containment contract and
document the residuals rather than to buy an eighth opinion.

## Does this cover HEAD for the merge gate?

The record describes `994ede8` exactly, with a clean tree. It does NOT clear the gate: the verdict
is REQUEST CHANGES, on I1 and I2, both measured, both at exit 0 with a stamp written. Do not
re-date this record; regenerate it at the new head after the fixes.

## What's good

- The fix is the structural one, not a fourth pattern, and it is smaller than what it replaced.
  Nine lines of `test` that read the disk beat a subprocess whose answer had to be parsed out of
  prose, and the property that closes the class is stated in one sentence: a marker does not move
  with git's locale, version or phrasing, and an unreadable marker is visible rather than absent.
  That is "eliminate the class" done properly, and it is the first fix on this branch whose
  failure mode I could not extend.
- Case 32 is the discipline that makes rewrites safe: the author asked what the OLD mechanism
  caught that the new one might silently lose (bare repos and `.git` directories have no `.git`
  child), and pinned both before anyone could rediscover them as a leak. Most rewrites do not get
  that question asked at all.
- Case 31 deliberately reproduces the blocker with no permission trick so it runs as root, which
  means the regression guard for the most expensive finding on this branch is the one case that
  never skips.
- Case 33's comment says out loud what the mechanism cannot catch, in the same breath as adding
  it. That is exactly the honesty `lessons.md` 2026-09-16 asks for, and it is why I3 is a finding
  about the rows and not about the test.
- The commit body reports what was measured, names which numbers moved, and separates the folded
  fixes from the blocker. Someone reading this history in a year will be able to reconstruct the
  reasoning without the eval records.

## History

- **Round 1** (`cebc0a0`, 2026-09-16): REQUEST CHANGES, 5/12. Two Criticals: the template's example
  lines read as live configuration in every scaffolded project; `init-project.sh` wrote no
  `.gitignore` entry for the ledger and then committed it.
- **Round 2** (`4558a32`, 2026-09-17): REQUEST CHANGES, 7/12. Better: both Criticals closed. Five
  Importants, all one class, a guard or comment wider than its mechanism.
- **Round 3** (`6f0ab87`, 2026-09-17): REQUEST CHANGES, 7/12. Mixed: four Importants closed and
  mutation-proven, the containment guard traded three failure shapes for three others and regressed
  one the previous version caught. Two consecutive rounds of the same class triggered
  `docs/eval-framework.md` stop condition 3; the tradeoff went to the human instead of to a round 4
  of the same loop.
- **Round 4** (`0046a92`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **better, and the
  loop is genuinely broken.** The human's structural choice is verified: the containment class is
  closed against every route tried here, including three that no previous round tested, and I4
  (install) and I2 (invisible ledger) from round 3 are closed and independently mutation-proven.
  What blocks the merge is not that class: it is the publish-remote guard added this round, which
  makes a class claim with a text compare and which I bypassed with a trailing slash, pushing the
  ledger to the publish remote at exit 0. One finding, one decision, no fourth spelling.
- **Round 5** (`2e7c740`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **same total,
  different composition, and the class is the story.** Closed: round-4 I1 (the publish guard took
  the honest close, claim narrowed and residual published, three spellings pinned) and I2 (the
  landing directory, not its parent, is now the argument), plus four of the six nits, plus the
  first real proofs of exit 5 against git's own refusal and of exit 4 from the clone path. Open:
  I3 only half closed, and the half that remains is a NEW measured fail-open of the SAME class,
  a safety decision read off git's stderr text, which lands the ledger in a live work tree at
  exit 0 with a stamp. Three consecutive rounds of that class means the next step is the
  structural version (measured here) or a documented residual chosen by the human, not another
  pattern.
- **Round 6** (`994ede8`, 2026-09-17): REQUEST CHANGES, 8/12. Regression note: **same total,
  materially better artifact, and the loop's own class is gone.** The human chose the structural
  option and it holds: C1 is closed, and I attacked it from seven directions (unreadable
  worktree gitdir, dangling `.git` pointer, bare repo, `.git` directory, unreadable-but-traversable
  ancestor, symlinked and `..` ancestors, reftable layout) without getting back in. The
  text-keyed-safety-decision class is removed, not patched, so stop condition 3 does not fire for
  a fourth time. Round 4's exported-`GIT_DIR` nit is closed. What blocks the merge is four
  first-time findings in three new classes: the same commit's environment guard covers two of the
  four git variables that matter and the missing one (`GIT_INDEX_FILE`) makes the backup replace
  the caller's index at exit 0 with a stamp (I1, fix proven here); the containment invariant is
  enforced on the `dir` branch only, so a `git` target inside the work tree lands the ledger's
  objects untracked and unignored (I2); and the header's exit-4 and exit-3 rows drift from
  `/retro` exactly as exit-2 did, in the commit that fixed exit 2 and added a mechanism that
  cannot see it (I3, I4). Total unchanged because two measured exit-0-with-a-stamp paths remain;
  composition much improved, and every remaining fix is narrow.
