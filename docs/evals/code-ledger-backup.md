---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ bin/docs-claims-check.sh, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 1b3c72d
artifact_version: 10
date: 2026-09-22
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 0, performance: 2, readability: 1, testing: 1, conventions: 1 }
total: 6/12
verdict: REQUEST CHANGES
previous_total: 6/12
---

## Artifact

Commit `1b3c72d` on `feature/windows-powershell-entry`, clean tree. One commit since round 9:
the fail-closed invariant, `~` expansion, the honest disagreement comment, the exit-4 rows, and
cases 43 and 44.

## THE CLASS IS CLOSED. I could not reopen it, and I tried the way I said I would.

Measured by running it, with `ad00988` as a positive control that still leaks all four:

| arrangement | `ad00988` (control) | `1b3c72d` |
|---|---|---|
| publish remote via `%2e%2e` | exit 0, stamped, **ledger on the publish remote** | **exit 4**, no stamp, nothing |
| publish remote via `%20` | exit 0, **ledger on the publish remote** | **exit 4**, nothing |
| the project itself via `%2e%2e` | exit 0, stamped, ref in its own repo | **exit 4**, nothing |
| in-tree bare repo, project dir has a SPACE, `%20` | exit 0, stamped, ledger in the work tree | **exit 4**, nothing |
| control: plain path with `%2e%2e` | exit 4 | exit 4 |

All five round-8 leaks remain refused (re-run, exit 2, no stamp, nothing written). Suite **188
assertions green, one SKIP**. **The canary claim is exact: 13 failures against `ad00988`**, and
they are the right 13 (the four rows plus the two `~` assertions). **Only two `~` case patterns
exist in the file (`:393`, `:419`) and both are quoted** — there is no third one.

The refusal is the right shape and I want to be explicit about why, because it is the thing that
ended a seven-round loop: it does not model git. It asks a question this program can actually
decide (can I see this target?) and stops when the answer is no. An encoding nobody has thought
of now fails closed. That is the structural close, and it held against every encoding attack I
brought.

**And a different guard, in the same block, fails on this machine for a different reason.**

## Findings

### Critical

**C1. The IDENTITY question compares two paths as STRINGS, and macOS is case-insensitive, so the
project spelled in a different case is not recognised as itself: exit 0, stamp written, the
ledger becomes a REF IN THE PROJECT'S OWN REPOSITORY.** `bin/ledger-backup.sh:551`, fed by
`:547-550`.

```
project at /private/tmp/.../MyProj
remote    = /private/tmp/.../MYPROJ         (the same directory; macOS opens it fine)
  -> exit 0, "refreshed", stamp WRITTEN
  -> git -C $PROJECT rev-parse internal-files  ->  072ab3f1...  a ref in the project's own repo
```

Root cause, measured directly: **`pwd -P` preserves the case you typed** (`cd CASEDIR; pwd -P`
returns `.../CASEDIR`), so `remote_common` is `.../MYPROJ/.git` and `project_common` is
`.../MyProj/.git`. They are the same directory and a different string, and `[ "$a" = "$b" ]` says
no. Question 2 cannot save it: the target IS the project, so the ancestor walk asks about the
parent, which is not in a repository.

Three things make this worse than a platform curiosity:

- **No attacker and no exotic spelling.** Typing `/Users/me/code/ODEO` for `Odeo` is a typo macOS
  silently accepts. This is the most ordinary way to get the wrong case into a config line.
- **It is round 7's C1 harm verbatim**: the ledger committed into the project's own object store,
  readable by anyone who clones it, at exit 0 with `--check` then answering "up to date".
- **The project already knows about this hazard and tests for it, on the other arm.**
  `tests/ledger-backup.test.sh:367-377` says, in its own words: "Case-only difference, which
  matters because macOS ships a case-insensitive filesystem: the path resolves to the same
  directory while the strings differ." The `dir` arm survives it because it asks about MARKER
  EXISTENCE (`-e`, case-insensitive on this filesystem). The `git` arm's identity question was
  added two rounds later and the known concern was not carried across. That is `lessons.md`
  2026-08-10 exactly: verify the whole surface a change touches, not the site you edited.

**Is this the class returning a fifth time? No, and I want to be precise, because the human's
decision turns on it.** The recurring class was *the URL-to-path conversion models git and its
failure mode is to pass*. Here the conversion is perfect: a plain absolute path converts to
itself, the path is a directory, git and this program agree completely about which directory it
is. Nothing is skipped; the guard runs and answers wrong. Different mechanism, different line,
different fix, and **it has been present since round 8 when the identity question was
introduced** (verified: `b3b66f7`, `ad00988` and `1b3c72d` all leak identically). It is not a
re-introduction after a fix. **I missed it in rounds 8 and 9**, where I attacked identity with
symlinks, worktrees, submodules and `..` paths but never with capitalisation. That is my miss,
not a regression by the builder.

What it does rhyme with is worth one sentence: it is the last comparison in this guard still done
on *representations* rather than on *identity*, which is the thing the round-8 redesign was
supposed to be about.

**Fix, one operator, measured here: `-ef` (same device and inode), which is what "is it the same
repository" actually means.**

```sh
      if [ -n "$remote_common" ] && [ -n "$project_common" ] \
         && [ "$remote_common" -ef "$project_common" ]; then
```

Measured: **188 assertions green, unchanged**; the case attack becomes exit 2; the worktree, the
symlink and the in-tree bare repo stay refused. `-ef` is in bash 3.2 (verified on the shipped
`/bin/bash`, 3.2.57). It also removes the whole family of spelling differences at once, not just
case: trailing slashes, symlinked mount aliases, hardlinked admin dirs. Pin it with the row that
already exists for the `dir` arm at `:367-377`, moved to the `git` arm (assert "does not succeed"
rather than a code, for exactly the reason that case already gives: on a case-SENSITIVE
filesystem the same line is simply a missing directory).

### Important

**I1. The fail-closed invariant has one measured hole, and it is the mirror image of the one that
was fixed: a path that IS visible here but is not the path git uses.** `:530-540`.

```
project at OUT/Proj4, bare repo at OUT/Proj4/inside4.git (inside the work tree)
a real directory literally named  OUT/Proj4%2finside4.git  exists (outside any repo)
remote = file://localhost OUT/Proj4%2finside4.git
  -> the program sees the LITERAL directory, outside every repo, and passes both questions
  -> git decodes %2f to "/" and writes to OUT/Proj4/inside4.git, INSIDE the work tree
  -> exit 0, stamp WRITTEN, SECRET-LEDGER in the in-tree bare repo
```

I am filing this Important, not Critical, and saying why plainly: **it requires someone to
pre-create a directory whose name contains a literal `%2f` next to the project.** Nothing a user
does by hand produces it, unlike `%20`, which is just a path with a space. It is not reachable by
typo. **Do not patch it by adding percent-decoding** — that is the fourth model, and the fail-
closed rule exists precisely so the next unmodelled encoding is refused rather than guessed. The
honest close is a residual, wording in the section below.

**I2. Case 43 inherits case 37's blindness, and the canary proves it on the suite's own run.**
`tests/ledger-backup.test.sh:978-999`. The `space-inside` row's target is a bare repo inside the
work tree (`$pp/in43.git`), and the row asserts ref-in-project and publish-remote-empty, neither
of which can see a nested bare repository. In the canary run against `ad00988`, that row leaked
and only two of its assertions went red: the exit code and the stamp. Both are rule and
bookkeeping checks, not the harm. So the case that ends the loop's headline class cannot see the
harm shape that class produced. Same one-line fix as round 9's I1, measured catching it:
`git -C "$pp" status --porcelain` must show nothing beyond the ledger's own paths.

**I3. Nothing pins exit 4 for the new refusal.** `tests/ledger-backup.test.sh:985` asserts
`[ "$rc" != 0 ]`. The whole premise of this file is that a caller can tell the codes apart, the
header and `/retro` both now document this refusal as 4 specifically, and a regression that
turned it into 2 or 5 would pass every row. Case 44 pins the positive side; this needs
`[ "$rc" = 4 ]` on at least one row. (The `!= 0` form is right for the `dir` arm's case-difference
row at `:374`, where the correct code genuinely differs by filesystem. It is not right here.)

### Nitpicks

- `tests/ledger-backup.test.sh:968-969`. Dead code in the `pub-dotdot` row: `target` is assigned
  and then immediately overwritten on the next line, and the `mkdir -p "$pp/sub"` on `:968` is
  unused (the row uses `sub43` in the parent). Delete both.
- `:535-538`. The refusal message says "git may still resolve it (it decodes percent escapes, for
  one)", which is true for an encoded URL and misleading for the commonest case that reaches this
  branch: an absolute path on an external drive that is not mounted. One clause: "or the path is
  simply not there right now".
- `bin/ledger-backup.sh:43-48`. The exit-4 header row now names the new refusal, which is the
  round-9 ask half-answered. It still describes 6 states against **17** `exit 4` sites in code.
  Carried from rounds 6, 7, 8, 9. One clause closes it honestly: "or the program could not write
  or resolve something it needed".
- `bin/ledger-backup.sh:254-259`. The ancestor walk still terminates on the literal `"/"`.
  `dirname //a` is `/` here so it terminates, but POSIX leaves `//` implementation-defined.
  Carried from rounds 5 to 9.
- `tests/ledger-backup.test.sh:640-642` (case 33 greps `exit [0-9]+` over comments too),
  `:488-492` (case 25c's comment), `:494/497` and `:587/590` (chmod restored inline, no trap),
  `AGENTS.md:285-291` (quotes the deleted stop-condition rule verbatim in a normative file),
  `:552` (the refusal says "IS this project's own repository" for a plain directory inside it
  too). All carried, all unchanged.

## The three deferred findings, restated for a batch decision

Each with its exact one-line fix, and whether I would block a merge on it.

1. **`url_is_relative` vs `local_url_path` disagree on `a/b:c` and `./a:b/c`.**
   *Fix:* in `local_url_path:395-398`, drop the `*/*) p="$u"` inner arm so those inputs yield
   nothing like every other relative input.
   **I would NOT block.** I verified the new comment at `:412-416` rather than accepting it:
   the disagreement set is exactly the two inputs it names (differential over 32 URL shapes,
   including the new `~` forms, which add no disagreement), and both outcomes are exit 2 with
   nothing written and no stamp (measured from two different cwds: one gives the relative
   message, one gives the publish message). **The claim is true, not comfortable, and the
   human's deferral was made on correct information.** It is a wrong-message bug, not a leak.

2. **Case 37's harm assertions are blind to a bare repo nested in the work tree** (and case 43
   now inherits it, see I2).
   *Fix:* one assertion per row, `git -C "$pp" status --porcelain` shows nothing beyond the
   ledger's own paths.
   **I WOULD block on this one if it were my call.** Not for what it lets through today, but for
   what it will let through next: it is the reason a green 188-assertion suite has now twice been
   green across a live leak, and `lessons.md` 2026-09-16 is explicit that a class claim needs an
   OUTCOME assertion. The case's own header says it asserts the harm. It does not. One line.

3. **`:52` still claims THE WHOLE GIT ENVIRONMENT IS DROPPED** while `GIT_SSH_COMMAND`,
   `GIT_EXEC_PATH`, `GIT_TEMPLATE_DIR` and `GIT_AUTHOR_*` survive `:76-78`.
   *Fix:* narrow the sentence to "the repository-location and config-injection families", and
   name `GIT_AUTHOR_*` as deliberately kept (`:566-567` uses it).
   **I would NOT block, but I would not carry it a fifth round either.** I re-measured it this
   round: an inherited `GIT_SSH_COMMAND` still routes the backup, and the run followed it to a
   bare repo inside the work tree at exit 0. The behaviour is defensible (it is the caller's own
   environment, and residual 1 already says a non-local URL cannot be contained); the SENTENCE is
   false, and it is the one a future reader will rely on. It is a comment edit, so its cost is
   zero and its half-life in this file is now four rounds.

## The six frozen residuals, re-checked against this conversion

1. **A non-local URL cannot be contained.** TRUE, and verified reachable again this round:
   `git@localhost:<in-tree bare>` with a locally-landing `GIT_SSH_COMMAND` leaks at exit 0. The
   program and git AGREE it is not a path; the harm is in the transport. Correctly scoped.
2. **Whether a remote is public is not decidable here.** TRUE, unchanged.
3. **Identity is asked of git, and git can refuse to answer.** TRUE, unchanged, and untouched by
   C1: C1 is git answering correctly and this program comparing the answers wrongly. Do not merge
   the two ideas in the header.
4. **A remote borrowing the object store via alternates is accepted.** TRUE, unchanged.
5. **A Windows drive-letter target is not recognised as a local path.** TRUE, re-checked against
   the `~`-augmented conversion: `C:/backup.git` and `C:\backup.git` still yield no path
   (differential: `path=<none>`), so the new fail-closed branch does not fire on them and they
   are treated as remote, exactly as the residual says. Wording needs no change.
6. **Exit 0 against a real network remote is not proven by the suite.** TRUE, unchanged.

**One residual to ADD, for I1** (the only hole I found in the new invariant, and the one that
cannot be closed without re-entering the modelling business):

```
#   - THE TARGET THIS PROGRAM SEES IS THE TARGET IT CHECKS, WHICH IS NOT ALWAYS THE ONE GIT
#     OPENS. The rule above refuses what cannot be seen; it cannot detect a path that IS a
#     directory here and a DIFFERENT directory to git. Measured: with a real directory literally
#     named `Proj%2finside.git` beside the project, git decodes `%2f` and writes inside the work
#     tree while this program checks the literal one and passes. It needs a directory nobody
#     creates by hand, which is why it is written here rather than closed by decoding: decoding
#     would be a fourth model of git's url grammar, and the previous three were each correct
#     about what was known at the time.
```

And the `~` addition deserves one line in the header's exit-2 row, since `~/backup.git` is now
accepted where it used to be refused as relative: that is a behaviour change a reader of the
contract should not have to discover from the code.

## Scores

correctness 1/2, the fail-closed invariant is correct, decidable, and held against every encoding
attack I built; `~` is expanded with the same idiom as the `dir` arm and the quoting trap is
documented where the next person will hit it; the disagreement comment is true; the canary is
exact at 13. Docked for C1, where the identity comparison answers wrong for the project itself,
and for I1, the one measured hole in the new invariant.

security 0/2, a Critical lands here: the ledger committed into the project's own repository at
exit 0 with the stamp written, reachable by typing a path in the wrong case on the platform this
is developed on. The four percent-encoding leaks from round 9 are closed and verified against a
control that still leaks them, which is real and substantial progress in this dimension; the
rubric still scores the Critical.

performance 2/2, unchanged and verified. The new check is one `[ -d ]` on a path already computed;
the suite is 188 assertions in about 30s, still dominated by three deliberate `sleep 1`s.

readability 1/2, the best comments on this branch: the fail-closed block says what it refuses to
do and why not doing it is the point, the `~` quoting trap is written down at the line that would
reintroduce it, and `:412-416` replaced a false "cannot drift" claim with a true statement of a
known disagreement, which is the honest close and the harder one to write. Docked because `:52`
is still measurably false and now for the fourth round, and because the exit-4 row still describes
6 states against 17 sites.

testing 1/2, case 43 is well built and its fresh-remote-per-row reasoning is exactly right (a
shared remote would have made row 1's leak fail row 3, and a test that blames the wrong row is
worse than none); case 44 pins what the refusal must not cost; 188 green and the canary
reproduces at 13. Docked because case 43 inherits case 37's blind harm assertions (proven on the
canary run), nothing pins exit 4, case 40's regex is still one spelling, and no case on the `git`
arm covers path case, which is how C1 survived two of my own rounds while the `dir` arm has had
that case since round 3.

conventions 1/2, verified: conventional commit, feature branch, English comments, no em or en
dashes in the changed files, README count updated to 1115, no secrets. Docked for `lessons.md`
2026-08-10 ("verify the whole surface a change touches"), which is C1's exact shape: a hazard the
suite documents on one arm, not carried to the new guard on the other.

total 6/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

**Third round at 6, and for the first time the flat number is not the same finding.** Rounds 8
and 9 were held at 6 by one class that kept coming back through the conversion. That class is
closed, and I could not reopen it. What holds the number now is a narrower, older defect in a
different line, with a one-operator fix and zero cost.

## Ceiling

**11/12 is the honest ceiling for a round 11, not 12.** C1 is one operator, I2 and I3 are one line
each, the deferred three are one line each, so correctness, security, readability and conventions
can all reach 2. Testing caps at 1 until the harm assertions in cases 37 and 43 can see a bare
repo in the work tree and case 40 asserts its class rather than one spelling. Two residuals are
permanent and belong in the header rather than in a score: a non-local URL cannot be contained by
any on-disk walk (verified reachable again this round), and exit 0 against a live network remote
is owner attestation the suite cannot reproduce.

## Loop position, and what would make me believe the class is closed

**The class that drove rounds 3 to 9 is closed, and stop condition 3 does NOT fire for it.** I am
not proposing a fifth fix for it, because C1 is not it: the conversion is exact here, nothing is
skipped, and the defect predates the fix by two commits. The git arm's containment is worth its
complexity at this point, and I am not recommending narrowing or removing it.

**What I would need to believe it is closed rather than merely not-yet-broken**, stated so it can
be checked rather than felt:

1. **No path is compared as a string anywhere in the guard.** After the `-ef` fix, identity is
   device+inode, location is marker existence on disk, and conversion is fail-closed. That is
   three questions, none of which can be answered differently by two spellings of one directory.
   C1 is the last string compare; while it is there, the property is not true.
2. **The suite can SEE the harm, not just the refusal.** Today a leak into a nested bare repo
   shows up only as a wrong exit code. Until I2 lands, a green suite is evidence about rules, not
   about outcomes, and that is precisely the gap the last two Criticals lived in.
3. **The remaining holes are written down and each needs an attacker.** After I1's residual, every
   way I know to defeat this guard requires someone who can already create directories beside the
   project or set the caller's `GIT_SSH_COMMAND` — and anyone who can do either can read the
   ledger directly. That is a defensible resting point; "no known holes" is not.

**Recommendation, in order:** C1's `-ef` (measured: 188 green, the attack refused). Then I2 and
I3, which are the reason a green suite did not catch either of the last two Criticals. Then the
three deferred items as one comment-only commit. Then freeze.

## Does this cover HEAD for the merge gate?

The record describes `1b3c72d` exactly, clean tree, everything re-measured today. It does NOT
clear the gate: REQUEST CHANGES on C1. Do not re-date this record; regenerate it at the new head
after the fix.

## What's good

- **The structural close worked, and it worked for the stated reason.** Refusing what cannot be
  seen, instead of modelling what git does, ended a class that survived four patches. I attacked
  it with uppercase schemes, ports, userinfo, backslashes, one-slash and no-slash `file:`,
  `%2e%2e`, `%20`, symlinks and a case-insensitive filesystem, and the only way through needed a
  planted directory with `%2f` in its name. The commit did not add percent-decoding when it would
  have been the obvious thing to do, and the comment says why. That is the discipline the rule
  asks for, applied against the tempting option.
- **The disagreement was documented instead of papered over, and the documentation is true.** I
  tried to break the claim and could not: the set is exactly the two inputs named, and both
  outcomes are refusals. A comment that states a known gap accurately is worth more than a fix
  that hides it, and this is the first round where a claim in this file survived being attacked
  rather than being narrowed afterwards.
- **The `~` quoting trap is written down at the line that would reintroduce it.** That is
  `lessons.md`'s own rule about placement: a mechanism at the point of use rather than a fifth
  phrasing of a rule in a file read hours earlier.
- **Case 43's fresh-remote-per-row note.** Finding that a shared publish remote let one row's
  leak fail another row's assertion, fixing it, and writing down why a test that blames the wrong
  row is worse than no test, is the kind of thing that usually goes unrecorded.
- **The canary is exact for the third round running**: 13 failures against `ad00988`, and the
  failing lines are the right ones.

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
