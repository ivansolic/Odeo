---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ bin/docs-claims-check.sh, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 15b168f
artifact_version: 12
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 9/12
verdict: APPROVE WITH COMMENTS
previous_total: 9/12
---

## Artifact

Commit `15b168f` on `feature/windows-powershell-entry`, clean tree. One commit since round 11:
`leak_in_tree` discovers by marker, case 43's in-tree target renamed `mirror`, case 45's skip
replaced by a contract-asserting `else`, and three residual bullets in the script header.

**This is the anchor round. All three round-11 comments landed, all three verified by measurement,
and none of them is wrong.** Nothing below is a change request.

## Verification of the three

### 1. `leak_in_tree` by marker: correct, and it closes exactly what it claimed

The shipped helper, extracted verbatim and run against seven planted leaks with the positive
control first (`lessons.md` 2026-08-06):

| planted shape | round 11 | `15b168f` |
|---|---|---|
| bare repo named `inside.git` (positive control) | SEEN | **SEEN** |
| bare repo nested three levels deep | SEEN | **SEEN** |
| objects PACKED rather than loose | SEEN | **SEEN** |
| bare repo named `mirror`, no `.git` suffix | **BLIND** | **SEEN** |
| a submodule of the project | **BLIND** | **SEEN** |
| linked worktree inside the tree (`.git` is a FILE) | BLIND | BLIND, out of scope |
| repo reached through a symlink inside the tree | BLIND | BLIND, out of scope |

Both false-positive controls still behave: a clean project is silent, and the base-commit trap the
case-37 comment documents cannot fire. The two remaining BLIND rows are the ones I said last round
are correctly outside this helper: the objects live outside the work tree, and case 37's
`find -name 'todo.md'` covers the checked-out file. **No widening wanted.**

### 2. Case 43's `mirror` row proves the finder as well as the guard

This is the part I most wanted to see, because a fix to an instrument needs an instrument of its
own. Running the HEAD suite against `ad00988` (the last commit where that row actually leaked):

```
FAIL - and a repo inside the work tree carries the ledger (space-inside: .../p43 with space 4/mirror)
```

The name-keyed version said nothing about that repository. The row now fails for the right
reason, names the suffix-less repo, and would have caught the round-11 blindness by itself.

### 3. Case 45's `else` branch: verified on a real case-sensitive filesystem

I did not take this one on reading. I created a case-sensitive APFS volume with `hdiutil`,
confirmed it is case-sensitive, and ran the suite with `TMP` on it:

```
ok   - a case variant of the project's path never reaches exit 0 (exit 4)
ok   - and no stamp was written (case variant)
ok   - and no backup ref exists in the project's repo (case variant)
ledger-backup: all 202 assertions passed.
```

**The else branch runs, asserts the contract, and the suite reports the SAME 202 assertions on
both filesystems.** That is strictly better than the skip it replaced: the count no longer moves
with the machine, so this case can never be read as coverage it did not provide.

**And the shared setup is load-bearing, exactly as intended.** I measured both arrangements on the
case-sensitive volume:

```
with the remote added:    exit 4, "cannot see the target of 'backup' (.../P45MIXED)"   <- fail-closed
without the remote:       exit 4, "this repo has no remote named 'backup'"             <- wrong reason
```

Both are exit 4, so `rc != 0` cannot tell them apart; what makes the case honest is that the
remote is added above the `if`. The reasoning in the commit is correct and the code matches it.

**One methodology note, because it nearly put a false claim in this record.** My first attempt set
`TMPDIR` and reported 202 green "on a case-sensitive filesystem". It was not: macOS `mktemp`
ignores `TMPDIR` (it uses the Darwin per-user temp dir), so the run never touched the volume. I
caught it only by checking WHICH branch of case 45 had executed, and it was the `if`. The result
above comes from redirecting `TMP` in a copy of the harness. Consequence worth recording for
whoever next wants to run this suite elsewhere: **`TMPDIR` will not move it on macOS.**

### 4. Header residuals

Three bullets added (the header now carries nine, six frozen at round 8 plus these): `~` expanded
with this process's `$HOME` rather than git's, the planted `%2f` directory, and the `-ef` TOCTOU
window. The dispatch note said four; three shipped, and they cover the three substantive points
from round 11. The `~` wording is careful and correct: git is a child process and inherits this
`$HOME`, so the two always agree in practice, and the bullet says the equality is `$HOME`'s rather
than this program's guarantee, which is the honest form.

## Merge-gate confirmations, measured here

- **202 assertions green** on the ordinary filesystem, and **202 green** on a case-sensitive one.
- **33 suites, README at 1129 assertions**, `docs-claims-check --assertions` green: "every
  countable claim matches the tree". Unchanged, as stated: the marker and `~` changes add no
  assertions on this machine.
- **Every leak from rounds 8, 9 and 10 re-run at this commit and refused**: the five
  authority/`@:`/relative arrangements at exit 2, the four percent-encoded arrangements at exit 4,
  the plain-path control at exit 4, all with no stamp and nothing written.
- **The round-10 case attack and the six `-ef` arrangements re-run**: case variant refused, linked
  worktree, symlinked `.git`, symlinked path and the `/tmp` mount alias refused, unrelated bare
  repo and legitimate clone still exit 0.

## Findings

### Critical

None.

### Important

**I1. Exit 4 is still asserted as `!= 0`, so the documented code is not pinned by any case.**
`tests/ledger-backup.test.sh:1015`, and now also case 45's `else`. Carried from round 11,
unchanged, and slightly more load-bearing than it was: on a case-sensitive filesystem the else
branch passes for the right reason only because the setup sits above the `if`, and the assertion
itself cannot distinguish "cannot see the target" from "no remote of that name" (both exit 4,
measured). The whole premise of this file is that callers tell codes apart, and `/retro` branches
on them. One row asserting `[ "$rc" = 4 ]`, or grepping the refusal's own sentence, closes it.
**Recorded as a carried finding, not a change request for this merge.**

### Carried deferred, for one post-merge batch

Restated so the human has them together. Both are in their **sixth** round.

1. **`url_is_relative` and `local_url_path` disagree on `a/b:c` and `./a:b/c`.** Verified again at
   round 11: the set is exactly those two, both outcomes are exit-2 refusals, nothing leaks, and
   the comment at `:412-416` states it accurately. *Fix:* drop the `*/*) p="$u"` inner arm in
   `local_url_path` so those inputs yield nothing like every other relative input.
2. **`bin/ledger-backup.sh:52` still claims THE WHOLE GIT ENVIRONMENT IS DROPPED**, while
   `GIT_SSH_COMMAND`, `GIT_EXEC_PATH`, `GIT_TEMPLATE_DIR` and `GIT_AUTHOR_*` survive `:76-78`.
   Measured at round 10: an inherited `GIT_SSH_COMMAND` routes the backup and the run follows it
   at exit 0. *Fix:* narrow to "the repository-location and config-injection families" and name
   `GIT_AUTHOR_*` as deliberately kept (`:566-567` uses it).

### Nitpicks, all carried

- `bin/ledger-backup.sh:43-48`. The exit-4 header row describes 6 states against **17** `exit 4`
  sites. Carried from rounds 6 to 11.
- The exit-2 header row still does not mention that a leading `~` is now accepted. The residual
  bullet covers the `$HOME` caveat; the contract change itself is still only visible in the code.
- `tests/ledger-backup.test.sh:968-969`. Dead code in case 43's `pub-dotdot` row: `target` is
  assigned and immediately overwritten, and the `mkdir -p "$pp/sub"` beside it is unused.
- `tests/ledger-backup.test.sh:844-849`. Case 40's static check matches one of four assignment
  spellings that `set -a` exports.
- `bin/ledger-backup.sh:254-259` (the `//` ancestor walk), `:535-538` (the refusal says "git may
  still resolve it" for an unmounted drive too), `:552` (says "IS this project's own repository"
  for a plain directory inside it), `tests/ledger-backup.test.sh:640-642` (case 33 greps
  `exit [0-9]+` over comments), `:488-492` (case 25c's comment), `:494/497` and `:587/590` (chmod
  restored inline, no trap), `AGENTS.md:285-291` (quotes the deleted stop-condition rule verbatim
  in a normative file).

## Accepted residuals

What an APPROVE here means. Nine are now in the script header where a reader of the code will find
them, which is the right place; this record adds nothing new.

1. **A non-local URL cannot be contained.** Verified reachable: with a locally-landing
   `GIT_SSH_COMMAND`, `git@localhost:<in-tree bare>` leaks at exit 0. Inherent to an on-disk walk.
2. **Whether a remote is PUBLIC is not decidable here.**
3. **Identity is asked of git, and git can refuse to answer.**
4. **A remote borrowing the object store via alternates is accepted.**
5. **A Windows drive-letter target is not recognised as a local path.** Re-checked against the
   current conversion.
6. **Exit 0 against a real network remote is not proven by the suite.** Permanent.
7. **A leading `~` is expanded with this process's `$HOME`, not git's.** They always agree in
   practice (git inherits it); the bullet is honest that the equality is not this program's.
8. **A directory that exists here may still not be git's.** Re-measured at this commit: the
   planted `%2f` directory still reaches exit 0. Needs an attacker who can create a directory
   beside the project.
9. **The identity test has a microsecond TOCTOU window.** Measured: `[ "$gone" = "$gone" ]` is
   true while `[ "$gone" -ef "$gone" ]` is false.

Plus one about the tests rather than the program: **`leak_in_tree` does not follow symlinks and
does not read a linked worktree's `.git` file.** Deliberate, and case 37's work-tree assertion
covers the shape that matters.

## Scores

correctness 2/2, all three changes do what they claim and I verified each by measurement rather
than by reading, including building a case-sensitive filesystem for the one that could not be
checked otherwise. Every leak from four previous rounds re-run and refused; `-ef` re-swept across
six arrangements; 202 assertions green on two different filesystems.

security 2/2, no Critical, no new attack surface, and the residual set moved out of a review
record and into the header where the next reader of the code will find it. Everything that can
still reach exit 0 requires an attacker who could read the ledger directly.

performance 2/2, unchanged. `leak_in_tree` now walks every directory under a fixture instead of a
name-filtered set; the suite is still about 30s and the marker test short-circuits on the first
missing entry.

readability 1/2, the new comments are up to this file's standard: case 43's row says why it is
named `mirror`, case 45's else says why it is not a skip and what it can and cannot prove, and the
`~` residual distinguishes "they agree" from "this program guarantees it". Docked for the same two
items as round 11, both unchanged and both in the deferred batch: `:52` is false in its sixth
round, and the exit-4 row describes 6 states against 17 sites.

testing 1/2, the round-11 finding is closed and proven twice over: the helper sees `mirror` and a
submodule, and the suite's own canary names that repository where the name-keyed version was
silent. Case 45 now asserts on both filesystems with a stable assertion count, and the shared
setup is load-bearing for the right reason, measured. Docked because exit 4 is still pinned by no
case (I1) and case 40's static check is still one spelling wide.

conventions 1/2, verified: conventional commit, feature branch, English comments, no em or en
dashes in changed files, README 1129 measured correct, `docs-claims-check --assertions` green
across 33 suites, no secrets. The `lessons.md` 2026-09-16 violation in the test helper is closed;
docked only for `:52`, the same rule, deferred.

total 9/12 (threshold >= 9, no zero) -> APPROVE WITH COMMENTS.

**Same total as round 11, and the composition is why.** Three of the seven items behind the three
docks closed this round; the four that remain are two deferred comment edits and two test-precision
items, and they sit in dimensions the other items still hold at 1. Nothing regressed.

## Ceiling

**11/12, unchanged, and 10 of it is the deferred batch.** Readability and conventions both lift
the moment `:52` is narrowed; testing reaches 2 with I1 and case 40's regex. 12/12 is not
reachable for this artifact and should not be chased: residuals 1 and 6 are inherent, and an
artifact whose contract includes permanent residuals should not score as though it had none.

## Loop position

**Closed.** Twelve rounds, one recurring class that ran from round 3 to round 10, and it ended
structurally rather than by patch: the conversion fails closed instead of modelling git, identity
is device+inode instead of a path string, location is markers on disk instead of git's prose. The
three belief tests written at round 10 all hold, and round 12 added the fourth that mattered most
to me: **the instrument that proves the harm has now itself been proven**, by a row that fails
against a real previous commit and names a repository the previous instrument could not see.

Stop condition 3 does not fire. Nothing here recommends narrowing or removing the `git` arm.

**After the merge, as one batch:** the two deferred comment edits, I1's exit-4 assertion, case
40's four-spelling regex, and the nit list. None of it needs a review round; if any of it changes
`bin/` or `tests/`, this record must be regenerated at the new head rather than re-dated.

## Does this cover HEAD for the merge gate?

**Yes. This record can be merged.** It describes `15b168f` exactly, clean tree, everything
re-measured today: 202 assertions on two filesystems, 33 suites, README 1129, all prior leaks
re-run and refused, all three round-11 comments verified by measurement. Verdict APPROVE WITH
COMMENTS at 9/12, above the threshold with no dimension at zero and no Critical open.

## What's good

- **Two of the three changes were proved, not asserted.** Renaming the in-tree target to `mirror`
  so the row exercises the finder is the move that matters: it means the next person who weakens
  `leak_in_tree` gets a red line instead of a silent gap. That is the difference between a fix and
  a fix you can rely on.
- **Case 45 became better than the thing it replaced.** It now asserts on every filesystem, its
  assertion count does not move with the machine, and it explains both what it proves and what is
  unreproducible elsewhere. The shared setup above the `if` is a small detail that prevents a test
  passing for the wrong reason, and it was reasoned about rather than stumbled into.
- **The residuals went into the header, not the record.** Nine of them, where a reader of the code
  will find them. A review record is read once; a comment beside the guard is read every time
  someone changes it.
- **Twelve rounds without a single test weakened to make something pass.** Every round the suite
  grew and the canary reproduced exactly. That is the property that made this loop converge
  instead of oscillating.

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
- **Round 12** (`15b168f`, 2026-09-22): **APPROVE WITH COMMENTS, 9/12. The anchor.** Regression
  note: **same total, better composition, and nothing regressed.** All three round-11 comments
  landed and all three were verified by measurement rather than reading, and none is wrong.
  `leak_in_tree` now discovers by marker: `mirror` and a submodule went from BLIND to SEEN, the
  four already-seen shapes stay seen, both false-positive controls still behave, and the two
  remaining blind shapes are the ones I said belong outside it. Case 43's row renamed to `mirror`
  proves the finder as well as the guard, confirmed by running the HEAD suite against `ad00988`,
  where it names that repository and the name-keyed version was silent. Case 45's else branch was
  checked on a real case-sensitive APFS volume created for the purpose: it runs, asserts the
  contract at exit 4, and the suite reports the SAME 202 assertions on both filesystems, so its
  count no longer moves with the machine; the shared setup is load-bearing and correct, measured
  both ways (with the remote, "cannot see the target"; without it, "no remote named 'backup'", both
  exit 4). One methodology note recorded because it nearly produced a false claim here: macOS
  `mktemp` ignores `TMPDIR`, so a first attempt to redirect the suite never touched the volume and
  was caught only by checking which branch had run. Three residual bullets are in the header, nine
  in total, including the honest `~`-and-`$HOME` wording. All prior leaks re-run and refused; 33
  suites, README 1129 verified. What remains is one carried Important (exit 4 pinned by no case,
  now slightly more load-bearing), two deferred comment edits in their sixth round, and the nit
  list. The loop is closed: twelve rounds, one recurring class ended structurally at round 10, and
  round 12 added the test that mattered most, the instrument that proves the harm has now itself
  been proven against a real previous commit.
