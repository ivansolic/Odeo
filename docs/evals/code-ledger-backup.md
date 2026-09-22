---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ bin/docs-claims-check.sh, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 853d03a
artifact_version: 11
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 9/12
verdict: APPROVE WITH COMMENTS
previous_total: 6/12
---

## Artifact

Commit `853d03a` on `feature/windows-powershell-entry`, clean tree. One commit since round 10:
the `-ef` identity fix, the `leak_in_tree` harm helper wired into cases 37 and 43, and case 45.
**202 assertions green** (was 188), one SKIP, and `docs-claims-check --assertions` is green with
README at **1129 assertions across 33 suites**, measured here rather than taken from the commit.

**This is the first round with no Critical since round 6, and the first where I could not
construct a leak the program does not refuse.**

## 1. C1 is closed, and `-ef` did not cost what the string compare was doing

Case attack, run against `1b3c72d` as a positive control:

| | `1b3c72d` (control) | `853d03a` |
|---|---|---|
| project spelled `MYPROJ` for `MyProj` | exit 0, stamped, **ref in the project's own repo** | **exit 2**, no stamp, no ref |

Then I attacked `-ef` itself on the two axes you named, plus four more. **It is strictly better
than the string compare in every arrangement I could build, and worse in none.**

| arrangement | expected | measured |
|---|---|---|
| unrelated bare repo outside every tree | accept | exit 0 |
| a legitimate clone elsewhere (case 38's config) | accept | exit 0 |
| linked worktree (same common dir) | refuse | exit 2 |
| project whose `.git` is a SYMLINK to a dir elsewhere | refuse | exit 2 |
| project reached through a symlinked path | refuse | exit 2 |
| `/tmp` vs `/private/tmp`, a real macOS mount alias | refuse | exit 2 |

**Can two DIFFERENT repositories share one device+inode?** Not by any route I can reach.
Directories cannot be hard-linked; two directories on one filesystem have distinct inodes; across
filesystems `st_dev` differs, and `-ef` requires BOTH to match, so an inode number recycled on
another volume cannot collide. A bind mount of the same directory (which I cannot create without
root on this machine) would compare EQUAL, and that is the correct answer: it is the same
repository, and the `/tmp` alias row above is the same phenomenon measured for real.

**Does a symlinked common dir behave differently than before?** No, and I checked both directions:
`pwd -P` already resolved symlinks, so both operands were canonical under the old code too. `-ef`
adds robustness rather than changing behaviour there, which is why rows 4 and 5 above are refused
exactly as they were at round 8.

**One asymmetry, worth a residual line and nothing more.** If a common dir stops existing between
the `pwd -P` that produced the string and the test, the string compare said SAME (refuse) and
`-ef` says DIFFERENT (proceed). Measured: `[ "$gone" = "$gone" ]` is true, `[ "$gone" -ef "$gone" ]`
is false. The window is microseconds, both operands were just `cd`-ed into successfully, and
anyone who can delete the project's git dir mid-run can read the ledger directly. It is the same
check-then-push race the guard has always had, not a new class.

## 2. `leak_in_tree` does what it was built for, and it is name-keyed

**The claim is verified, not accepted.** Running the HEAD suite against `ad00988` (the last commit
where those rows actually leaked), the new assertions fire on exactly the two rows that were
leaking invisibly, and on no others:

```
FAIL - and a repo inside the work tree carries the ledger (self-dotdot: .../p43-3/.git)
FAIL - and a repo inside the work tree carries the ledger (space-inside: .../p43 with space 4/in43.git)
```

Then I tested the helper itself, copied verbatim, against seven planted leaks, with the shape it
was built for as the positive control first (`lessons.md` 2026-08-06):

| planted shape | seen? |
|---|---|
| bare repo named `inside.git` (positive control) | **SEEN** |
| bare repo nested three levels deep | **SEEN** |
| objects PACKED rather than loose | **SEEN** |
| bare repo named `mirror`, no `.git` suffix | **BLIND** |
| a submodule of the project | **BLIND** |
| linked worktree inside the tree (`.git` is a FILE) | BLIND, but see below |
| repo reached through a symlink inside the tree | BLIND, but see below |

Two false-positive controls both behave: a clean project is silent, and the trap the case-37
comment documents (the base commit's own copy) cannot fire because the canary is written after
that commit.

**Packing is not a blind spot** (`--batch-all-objects` reads packs), which was the one I most
expected to fail. The last two rows are out of this helper's scope rather than blind: in both, the
OBJECTS live outside the work tree, so "a repository inside the work tree carries the ledger" is
literally false; what is inside is a checked-out file, and case 37's existing
`find -name 'todo.md'` assertion covers exactly that. I would not widen the helper for them.

The first two are one root cause, and it is a finding: see I1.

## 3. Case 45's SKIP: my answer is that it should not exist, and this file already contains the better mechanism

You asked whether a test that cannot run on Linux is acceptable here. Two parts.

**On the principle: a loud skip is honest, and it is not what is wrong here.** The project's
position is already correct and consistent (case 40 skips loudly, the README says a skipped case
takes its assertions with it, `docs-claims-check` reports UNVERIFIED rather than DRIFTED). A case
that passes while testing nothing is decoration; one that says so is not. There is also no CI in
this repo today (no `.github/workflows`), so the skip currently costs nothing at all.

**On this case specifically: the skip is avoidable, and the file disagrees with itself.** Case 20,
650 lines up, pins the identical hazard for the `dir` arm and does NOT skip. It asserts
`rc != 0` and explains why that is right on both filesystems: "on a case-SENSITIVE filesystem the
same line is simply a missing directory, and both answers are correct refusals." That reasoning
transfers exactly, and I verified the consequence: on a case-sensitive filesystem the uppercase
path does not exist, so the new fail-closed rule returns exit 4 (measured on an absent absolute
path), and `rc != 0` holds while testing something real.

So the concrete recommendation is not a second mechanism, it is the one already in the file:
keep the strict `exit 2` + no-stamp + no-ref assertions inside the `if [ -d "$p45_upper" ]`
branch, and replace the bare `echo "SKIP"` with an `else` branch that asserts `rc != 0`, no stamp,
and no ref. The case then always asserts something, everywhere, and the file stops having two
treatments of one hazard.

**I checked for a portable way to reproduce the underlying condition and there is none**, which
is why I am not asking for one: two different strings naming one directory requires a
case-insensitive filesystem or a bind mount. Symlinks, trailing slashes, `//` and `/./` are all
normalised away by `pwd -P`, so none of them would have failed at `1b3c72d` — I verified the
symlink row passes on both commits. A text check that the comparison uses `-ef` would be the
"claim a class with a text check" pattern `lessons.md` 2026-09-16 rules out.

## Findings

### Critical

None. Every leak from rounds 8, 9 and 10 was re-run at this HEAD and is refused: the five
`file://`/authority/`@:`/relative arrangements at exit 2, the four percent-encoded arrangements at
exit 4, all with no stamp and nothing written, and the plain-path control unchanged at exit 4.

### Important

**I1. The harm helper discovers repositories by NAME, so it is blind to a bare repo whose
directory is not called `*.git`.** `tests/ledger-backup.test.sh:82-84`
(`find "$pp" -type d \( -name '*.git' -o -name '.git' \)`).

Measured: a leak into `$pp/mirror` (an ordinary `git init --bare mirror`) is reported clean, and
so is one into a submodule's `.git/modules/<name>`. This is the instrument built to close
"assert the outcome, not the name" being keyed on a name, which is `lessons.md` 2026-09-16 one
level out. It is coverage, not a live defect: the program refuses that shape today, so producing
it needs a regression first. That is why it is Important and not a blocker.

**Fix, one line, measured: use the same rule the program itself uses.** `in_work_tree` at
`bin/ledger-backup.sh:254-259` recognises a repository by its MARKER, never by its name. Apply
that here:

```sh
  done <<EOF
$(find "$pp" -type d 2>/dev/null)
EOF
```
with, at the top of the outer loop:
```sh
    # A repository is recognised by its MARKER, the same rule the program uses (in_work_tree),
    # never by the directory's NAME: a bare repo called `mirror` holds the ledger exactly as
    # well as one called `mirror.git`. Measured blind before this line.
    [ -e "$r/HEAD" ] && [ -d "$r/objects" ] && [ -d "$r/refs" ] || continue
```
Measured on all seven planted shapes: `mirror` and the submodule become SEEN, the four already
seen stay seen, and both false-positive controls stay silent.

**I2. Nothing pins exit 4 for the fail-closed refusal.** `tests/ledger-backup.test.sh:1015` still
asserts `[ "$rc" != 0 ]`. Carried from round 10. The premise of this file is that a caller can
tell the codes apart; the header and `/retro` both document this refusal as 4 specifically; a
regression turning it into 2 or 5 would pass every row. One row should assert `[ "$rc" = 4 ]`.
(The `!= 0` form is correct at `:400` and would be correct in case 45's proposed `else` branch,
where the right code genuinely differs by filesystem. It is not correct here.)

### Carried forward, deferred by the human as a post-merge batch

Recorded so they are not lost, not re-argued:

1. **`url_is_relative` and `local_url_path` disagree on `a/b:c` and `./a:b/c`.** Verified again
   this round at the function level; both outcomes remain exit-2 refusals, so nothing leaks
   through the gap and the comment at `:412-416` states it accurately. *Fix:* drop the
   `*/*) p="$u"` inner arm in `local_url_path` so those inputs yield nothing like every other
   relative input.
2. **`bin/ledger-backup.sh:52` still claims THE WHOLE GIT ENVIRONMENT IS DROPPED**, while
   `GIT_SSH_COMMAND`, `GIT_EXEC_PATH`, `GIT_TEMPLATE_DIR` and `GIT_AUTHOR_*` survive `:76-78`.
   Re-measured at round 10: an inherited `GIT_SSH_COMMAND` routes the backup and the run follows
   it at exit 0. The behaviour is defensible; the sentence is false. *Fix:* narrow to "the
   repository-location and config-injection families" and name `GIT_AUTHOR_*` as deliberately
   kept (`:566-567` uses it). Fifth round carrying this.

### Nitpicks

- `bin/ledger-backup.sh:43-48`. The exit-4 header row describes 6 states against **17** `exit 4`
  sites. Carried from rounds 6 to 10. One clause closes it honestly: "or the program could not
  write or resolve something it needed".
- `tests/ledger-backup.test.sh:968-969`. Dead code in case 43's `pub-dotdot` row: `target` is
  assigned and immediately overwritten, and the `mkdir -p "$pp/sub"` beside it is unused. Carried.
- `bin/ledger-backup.sh:535-538`. The refusal says "git may still resolve it (it decodes percent
  escapes, for one)", which is right for an encoded URL and misleading for the commonest case
  that reaches this branch, an external drive that is not mounted. One clause: "or the path is
  simply not there right now".
- `bin/ledger-backup.sh:254-259`. The ancestor walk still terminates on the literal `"/"`.
  Carried from rounds 5 to 10.
- `tests/ledger-backup.test.sh:640-642` (case 33 greps `exit [0-9]+` over comments too),
  `:488-492` (case 25c's comment), `:494/497` and `:587/590` (chmod restored inline, no trap),
  `:844-849` (case 40's one-spelling regex), `AGENTS.md:285-291` (quotes the deleted
  stop-condition rule verbatim in a normative file), `bin/ledger-backup.sh:552` (the refusal says
  "IS this project's own repository" for a plain directory inside it too). All carried, unchanged.

## Accepted residuals

These are what an APPROVE here means, stated so nobody reads the verdict as "no holes". The first
six are frozen in the script header and were re-checked against this commit; the last three are
new wording this record recommends adding.

1. **A non-local URL cannot be contained.** ssh, https and `git://` are not paths, so neither
   question can be asked. Verified reachable again: with a locally-landing `GIT_SSH_COMMAND`,
   `git@localhost:<in-tree bare>` leaks at exit 0. Inherent, correctly scoped, and it needs
   someone who controls the caller's environment.
2. **Whether a remote is PUBLIC is not decidable here.** Unchanged.
3. **Identity is asked of git, and git can refuse to answer.** Unchanged, and untouched by the
   `-ef` fix: that was git answering correctly and this program comparing wrongly.
4. **A remote borrowing the object store via alternates is accepted.** Unchanged.
5. **A Windows drive-letter target is not recognised as a local path.** Re-checked against the
   `~`-augmented conversion: `C:/backup.git` still yields no path, so the fail-closed branch does
   not fire and it is treated as remote, exactly as written.
6. **Exit 0 against a real network remote is not proven by the suite.** Unchanged, permanent.
7. **NEW, from round 10 (I1 there), still unwritten:** the target this program SEES is not always
   the one git OPENS. The fail-closed rule refuses what cannot be seen; it cannot detect a path
   that is a directory here and a different directory to git. Measured with a real directory
   literally named `Proj%2finside.git` beside the project. Needs a planted directory, which is
   why it is a residual rather than a decoding patch.
8. **NEW, from this round:** identity is decided on device+inode read at check time. If the common
   dir ceases to exist between the check and the push, `-ef` answers "different" where the old
   string compare answered "same". A microsecond TOCTOU window requiring local write access.
9. **`~` is now accepted** where it used to be refused as relative. That is a contract change a
   reader of the exit-2 row should not have to discover from the code; one clause in the header.

## Scores

correctness 2/2, C1 is closed and I could not reopen it: the case variant is refused, `-ef` is
correct on six arrangements including a real mount alias and a symlinked git dir, it does not
over-refuse the two legitimate configurations, and every leak from rounds 8, 9 and 10 stays
refused at this HEAD. The one asymmetry I found (a deleted common dir) is a documented
microsecond race, not a defect. 202 assertions green, measured here.

security 2/2, no Critical for the first time since round 6. The three guards now answer three
different questions with three different mechanisms, none of them a comparison of spellings:
identity by device+inode, location by markers on disk, conversion fail-closed. Every attack I
built this round was refused, and what remains is residuals 1 and 7 above, each requiring an
attacker who could read the ledger directly. Hygiene unchanged and good: quoting sound, no `eval`,
no ledger content on stdout, stamp under the git dir.

performance 2/2, unchanged. `-ef` is one stat pair; `leak_in_tree` walks only test fixtures. The
suite is 202 assertions in about 30s, still dominated by three deliberate `sleep 1`s.

readability 1/2, the `-ef` comment is exactly right: it names the platform fact, the measured
harm, and the sibling case that already knew. Docked because `:52` is still measurably false in
its fifth round (deferred, and I am recording rather than re-arguing it) and the exit-4 row still
describes 6 states against 17 sites.

testing 1/2, the round-10 blocker was taken seriously and the result works: `leak_in_tree` fires
on exactly the two rows that were leaking invisibly, sees packed objects and deep nesting, and has
two honest false-positive controls. Case 45 pins the new Critical and the canary is exact. Docked
because the helper discovers by name and is blind to a bare repo not called `*.git` (I1), exit 4
is still unpinned (I2), case 40's regex is still one spelling, and case 45 skips where case 20
shows it does not have to.

conventions 1/2, verified: conventional commit, feature branch, English comments, no em or en
dashes in changed files, README at 1129 measured correct, `docs-claims-check --assertions` green
across 33 suites, no secrets. Docked for `lessons.md` 2026-09-16 ("to claim a class the mechanism
must assert an OUTCOME... text checks are evaded by the next spelling"), which the name-keyed
helper and `:52` both land on.

total 9/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

**Three rounds at 6, then 9.** The number moved because the thing holding it down was one class,
and the class is gone rather than patched.

## Ceiling

**11/12 remains the honest ceiling, and 10 of it is one line away.** I1 is one line and lifts
testing to 2 only in combination with I2 and case 40's regex; readability reaches 2 the moment the
two deferred comment edits land; conventions follows them. 12/12 is not reachable for this
artifact at all: residuals 1 and 6 are inherent (a non-local URL cannot be contained by any
on-disk walk, and exit 0 against a live network remote is owner attestation no hermetic suite can
reproduce), and an artifact whose contract includes permanent residuals should not score as though
it had none.

## Loop position

**The class that drove rounds 3 to 10 is closed, and this is the round that tested the belief
rather than asserting it.** Round 10 wrote down what would have to be true; all three now hold:

1. **No path is compared as a string anywhere in the guard.** `-ef` was the last one. Verified by
   reading `:505-560` and by the six arrangements above.
2. **The suite asserts the harm, not only the refusal.** `leak_in_tree` is real and fires on the
   shapes that were invisible, proven against `ad00988`. I1 narrows where it does not reach.
3. **Every remaining hole needs an attacker who could read the ledger anyway.** Residuals 1, 7 and
   8 each require control of the caller's environment, the ability to plant a directory beside the
   project, or local write access mid-run.

Stop condition 3 does not fire. The `git` arm's containment is worth its complexity and I am not
recommending narrowing or removing it.

**Recommended before merge (none blocking):** I1 and I2 in one test commit, the case 45 `else`
branch, then the two deferred comment edits and residual wording 7, 8 and 9 into the header as a
single docs commit. If any of that changes `bin/` or `tests/`, this record must be regenerated at
the new head rather than re-dated.

## Does this cover HEAD for the merge gate?

Yes. The record describes `853d03a` exactly, clean tree, everything re-measured today:
202 assertions, 33 suites, README 1129, all prior leaks re-run and refused, C1's fix attacked from
six directions and the new test helper attacked from seven. Verdict APPROVE WITH COMMENTS at
9/12, above the threshold with no dimension at zero.

## What's good

- **The fix was the one-operator version, not a workaround.** `-ef` asks the filesystem the
  question the line always meant to ask, and it removed a family (case, mount aliases, symlinked
  admin dirs) rather than the instance that was demonstrated. It also cost nothing: 202 green,
  and the two legitimate configurations still exit 0.
- **The comment on it names the sibling case that already knew.** Pointing at case 20 turns a
  bug fix into a record of why the arms diverged, which is what stops the third arm repeating it.
- **The test finding was taken as a finding about the tests.** `leak_in_tree`'s header says
  plainly that a 188-assertion suite ran green across a live leak and that a test which cannot
  see the harm it names is worse than no test. That is the hardest kind of comment to write about
  your own work, and it is why the helper exists at all.
- **Case 43's fresh-remote-per-row reasoning and case 45's skip both explain themselves.** Even
  where I disagree with the skip, it states its own limitation rather than passing quietly, which
  is the standard this file has held since round 5.
- **The canary is exact for the fourth round running**, and the two new assertions fire on exactly
  the rows they were written for, which is the check that stops a green suite from being decoration.

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
- **Round 7** (`0125901`, 2026-09-18): REQUEST CHANGES, 6/12. Regression note: **worse total, better
  artifact, and the class round 6 declared gone is back one arm over.** All four round-6 Importants
  were applied; I1 (environment) and I4 (name the marker) are closed and outcome-pinned, I2 and I3
  are half closed. The total fell because round 6 scored the open `git`-arm hole on the only shape
  it measured, and the three shapes measured here are worse: a `file://` spelling, a sibling
  worktree of the project, and the project itself as the remote all pass at exit 0 with the stamp
  written, and two of them leave the ledger as a COMMITTED branch in the project's own repository
  (C1, fix proven here, costing exactly one existing case). Two Importants are the same class one
  level out: "the whole git environment is dropped" misses `GIT_CONFIG_COUNT`/`GIT_CONFIG_PARAMETERS`,
  which redirect the entire backup to an unnamed repository at exit 0 (I1, and git exports the
  latter to hooks, inside the set the comment claims), and the local `GIT_DIR` name that round 6
  filed as a nitpick is now measured corrupting the caller's index under `SHELLOPTS=allexport`
  (I2). Stop condition 3 fires on a recurring class, stated in one phrase: a containment guard
  that recognises one spelling of its target, or asks about one level of it, while its comment
  claims the class. The recommendation is not an eighth opinion: apply the three proven fixes,
  add ONE table-driven outcome case over the spellings, take the single decision about case 27,
  then freeze the contract with the residuals written into the header.
- **Round 8** (`b3b66f7`, 2026-09-22): REQUEST CHANGES, 6/12. Regression note: **same total,
  materially better artifact, and the defect moved one step earlier in the pipeline.** The human
  took the structural option again and the DECISION logic is now sound: identity by git common dir
  plus the existing ancestor walk refused every one of seven attack shapes (symlink to an in-tree
  bare repo, symlink to the project, `..` path, submodule, sibling worktree, worktree with an
  unreadable admin dir, and correctly ACCEPTED an alternates-borrowing remote and an ordinary
  outside clone). Round-7 I1 (config injection) and I2 (the `GIT_DIR` name) are closed and pinned
  by cases 39 and 40, the canary reproduces exactly (13 failures at `0125901`), case 27 does not
  flip as claimed, and all 33 suites are green at 140 assertions here. What blocks the merge is
  the step in FRONT of the two questions: the URL is turned into a path by matching spellings, and
  the conversion is not total. Measured at exit 0 with the stamp written, `file://localhost/...`
  (git ignores the authority, not just an empty one) puts the ledger into the project's own
  repository as a ref, into an untracked in-tree bare repo, and ONTO THE PUBLISH REMOTE, which is
  round 4's Critical returning through a different spelling; an absolute path containing `@` and
  `:` is misfiled as a host transport; and a relative url is checked against the project while the
  run resolves it against the caller's cwd, which landed the ledger in an unrelated repository.
  One shared `local_url_path` helper used by both guards closes all but the last, measured at zero
  cost to the 140 existing assertions, and the relative case has a four-line refusal mirroring the
  `dir` arm. The class phrase narrows to: the decision is structural, the parsing in front of it is
  not. Residual wording for the freeze is written into this record, ready to paste.
- **Round 9** (`ad00988`, artifact unchanged since `5972c27`, 2026-09-22): REQUEST CHANGES, 6/12.
  Regression note: **the round-8 Critical is CLOSED and verified by running it, and the same class
  returns one transformation over, at the same harm.** All five round-8 leaks were replayed with
  `b3b66f7` as a positive control that still leaks all five: `file://localhost` to the project, to
  an in-tree bare repo and to the publish remote, the `@`-and-`:` absolute path, and the relative
  URL all now exit 2 with no stamp and nothing written. One shared conversion for both guards was
  the right structure and it delivered what it claimed; relative URLs were refused rather than
  documented, which was the harder and better of the two options; the canary is exact at 17
  failures; case 38 and the `dir` arm are untouched and the suite is green at 169. What blocks the
  merge is that the conversion still MODELS git's URL handling and does not know git
  percent-decodes a file URL's path, so the program's path is not a directory, the containment
  block is SKIPPED rather than refused, and four arrangements reach exit 0 with the stamp: the
  ledger onto the PUBLISH REMOTE via `%2e%2e` and via `%20`, into the project's own repository, and
  into an in-tree bare repo when the project directory merely contains a SPACE. A plain path with
  the same `%2e%2e` exits 4, so the program and git agree everywhere except where the modelling is.
  Two helper functions added this round to agree do disagree on `a/b:c` (contained at exit 2, so
  Important), and case 37's harm assertions are blind to the nested-bare-repo shape, demonstrated
  against the suite's own canary run, which is why 169 green did not see the Critical. The
  eliminating fix is four lines and measured at zero cost: refuse when the converted path is not a
  directory (exit 4, the code that configuration already returned), so every future unmodelled git
  transformation becomes a refusal instead of a silent pass. Class phrase for round 10: one
  conversion, no disagreement, still a model of git whose failure mode is to pass.
- **Round 10** (`1b3c72d`, 2026-09-22): REQUEST CHANGES, 6/12. Regression note: **the seven-round
  class is CLOSED, verified by attack rather than by reading, and what blocks the merge is a
  different and older defect.** The fail-closed rule shipped as recommended and it holds: all four
  percent-encoded arrangements are refused at exit 4 with no stamp and nothing written, against an
  `ad00988` control that still leaks all four; all five round-8 leaks stay refused; 188 assertions
  green and the canary is exact at 13. Percent-decoding was deliberately NOT added, which was the
  right call, and the `~` expansion, the quoted-pattern trap and the honest disagreement comment
  are all correct — I verified the disagreement claim rather than accepting it: the set is exactly
  `a/b:c` and `./a:b/c`, both outcomes are exit-2 refusals, so the human's deferral was made on
  correct information. I could reopen the class only with a directory literally named with `%2f`
  planted beside the project, which needs an attacker and is filed as a residual, not a patch.
  What blocks the merge is C1: the IDENTITY question compares two `pwd -P` strings, `pwd -P`
  preserves the case you type, and macOS is case-insensitive, so the project spelled `MYPROJ`
  instead of `MyProj` is not recognised as itself and the ledger is committed into the project's
  own repository at exit 0 with the stamp. It needs no attacker, only a typo. It is NOT the
  recurring class returning: the conversion is exact, nothing is skipped, and it has been present
  since round 8 when the identity question was added — I missed it in two of my own rounds while
  attacking identity with symlinks and worktrees but never with capitalisation. The project's own
  suite documents this hazard for the `dir` arm at `:367-377` and it was not carried to the `git`
  arm. Fix is one operator, `-ef` (same device and inode), measured at 188 green with the attack
  refused. Stop condition 3 does not fire; the git arm's containment is worth its complexity, and
  the belief test for "closed rather than not-yet-broken" is written into this record: no path
  compared as a string anywhere in the guard, a suite that asserts the harm and not only the
  refusal, and every remaining hole requiring an attacker who could read the ledger anyway.
- **Round 11** (`853d03a`, 2026-09-22): **APPROVE WITH COMMENTS, 9/12.** Regression note: **better,
  and the first round in five with no Critical and no leak I could construct.** Both asks landed
  and both were verified by attack rather than by reading. `-ef` closes the case-variant hole
  (control at `1b3c72d` still leaks it) and is correct on six arrangements: it does not over-refuse
  an unrelated bare repo or a legitimate clone, and it still refuses a linked worktree, a symlinked
  `.git`, a symlinked path and the real `/tmp` vs `/private/tmp` mount alias; two different
  repositories cannot share a device+inode by any route reachable here. `leak_in_tree` fires on
  exactly the two rows that were leaking invisibly at `ad00988`, and it sees packed objects and
  deep nesting, with two honest false-positive controls. Every leak from rounds 8, 9 and 10 was
  re-run and stays refused; 202 assertions, 33 suites, README 1129, all measured here. The three
  belief tests round 10 wrote down now hold: no path is compared as a string anywhere in the guard,
  the suite asserts the harm and not only the refusal, and every remaining hole needs an attacker
  who could read the ledger anyway. What remains is one Important (the harm helper discovers
  repositories by NAME and is blind to a bare repo not called `*.git`, one line, measured), exit 4
  still unpinned, two comment edits the human deferred, and nine accepted residuals written into
  this record. On the skip question: case 45's SKIP is honest but avoidable, because case 20 in the
  same file pins the identical hazard without one, and no portable mechanism can reproduce "two
  spellings, one directory" since `pwd -P` normalises symlinks and slashes.
