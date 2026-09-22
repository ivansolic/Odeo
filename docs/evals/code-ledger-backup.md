---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ bin/docs-claims-check.sh, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: b3b66f7
artifact_version: 8
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

Commit `b3b66f7` on `feature/windows-powershell-entry`, clean tree. One commit since round 7,
which replaced the `git`-arm spelling test with two questions about identity and location.

Measured here, not accepted from the commit body:

- **All 33 suites green**, 2m17s total. `tests/ledger-backup.test.sh`: **140 assertions, 21s**,
  one SKIP (SHELLOPTS readonly on bash 3.2, as stated).
- **The canary claim is exact.** The HEAD suite run against `0125901`'s script produces **13
  failures**, including `the script assigns to name(s) it unsets: GIT_DIR`. The new cases can
  fail, so their green means something.
- **`docs-claims-check.sh --assertions` green** (24 executables, 33 suites, 24 programs with
  their own suite, 1053 assertions, matching README). **`skills-lint` green.** No em or en
  dashes in any changed file.
- **Case 27 does NOT flip, as claimed.** The non-bare remote outside every repository reaches
  the push and returns exit 5; case 38 pins the legitimate clone at exit 0. The commit body's
  central design claim ("refuse by identity and location, not by shape") holds for every target
  the guard is actually given as a path.
- **The `dir` arm is untouched by the diff** and its cases (10 to 33, 35b, 36) are green.

**The two questions themselves are sound.** I attacked them from seven directions and got back
in from none: a symlink outside the project pointing at an in-tree bare repo (exit 2), a symlink
pointing at the project itself (exit 2, named as the project's own repository), a `..` path back
into the project (exit 2), a submodule of the project (exit 2), a sibling linked worktree (exit
2, correct: same common dir), a sibling worktree whose admin dir is unreadable (exit 4, the
refusal that blinds the identity question also stops the push), and a remote that borrows the
project's object store through `objects/info/alternates` (exit 0, and measured NOT a leak: the
push writes nothing into the project, and the backup still reads after the alternate is removed).

What fails is one step earlier, and it is where every leak this round lives.

## Findings

### Critical

**C1. The guard now asks the right questions about the wrong object. The URL is turned into a
path by matching spellings, that conversion is not total, and three measured spellings reach
exit 0 with the stamp written: two put the ledger inside the project's own repository, and one
PUSHES IT TO THE PUBLISH REMOTE.** `bin/ledger-backup.sh:416-423` (and `:363-369`, which has a
second, different conversion of its own).

Measured on the shipped script at HEAD, each from a clean project:

```
(a) remote = file://localhost/$PROJECT                  -> exit 0, "refreshed", stamp WRITTEN
      git -C $PROJECT rev-parse internal-files          -> a REF in the project's own repo
      the ledger blob is an OBJECT in the project's own repo
(b) remote = file://localhost/$PROJECT/inside.git       -> exit 0, stamp WRITTEN
      git -C $PROJECT status --porcelain                -> ?? inside.git/     (NOT IGNORED)
      git -C $PROJECT add -A -n                         -> add 'inside.git/HEAD' ...
      git --git-dir=$PROJECT/inside.git show internal-files:internal-not-in-git/todo.md
                                                        -> SECRET-LEDGER
(c) origin = /tmp/pub.git (the publish remote),
    backup = file://localhost/tmp/pub.git               -> exit 0, stamp WRITTEN
      the ledger is ON the publish remote. The same repository spelled as a plain path is
      correctly refused ("is this project's publish remote"), which is the control.
(d) remote = $PROJECT/a@b:c/t.git                       -> exit 0, stamp WRITTEN
      an absolute local path containing @ and a later : matches the `*@*:*` arm and is
      classed as a host transport, so the guard never runs. git uses it as a local path.
(e) remote = "b.git" (relative), run with cwd inside an UNRELATED repository R
                                                        -> exit 0, stamp WRITTEN
      the guard checked $PROJECT/b.git (absent, so it skipped); `git clone` resolved the
      same string against the CALLER's cwd and pushed into R/b.git, a bare repo inside R's
      work tree. SECRET-LEDGER readable there.
```

Root cause, one sentence: **`file://` is stripped as a fixed prefix, but git ignores the URL's
AUTHORITY, not just an empty one.** Measured directly against git 2.50.1: `file://localhost/p`,
`file://LOCALHOST/p`, `file://notahost/p` and `file://$(hostname)/p` all push to the local path
`/p`. The script's `${url#file://}` leaves `localhost/p`, which is relative, so `[ -d ]` is false
and the entire containment block is skipped. `file://localhost/...` is not an exotic construction;
it is the RFC 8089 spelling of a file URL and git honours it.

Two aggravating details make this the same class the loop has been about rather than a new one:

- The guard's own comment at `:399-400` claims it "answers for every way of naming the same
  repository at once, including ones nobody listed". Measured false. It answers only for the
  URLs the `case` at `:417-422` converts to a path.
- Case 37's table contains a `file-url` row and its header says "a spelling nobody thought of
  fails it the same way". The sibling spelling of that very scheme leaks. This is `lessons.md`
  2026-09-16 ("a guard's comment may name only what it verifies") landing on the mechanism that
  was added to end the class.

**Why this cannot be a documented residual.** A residual describes what the mechanism CANNOT
decide (a non-local URL is not a path; whether a remote is public). This one it decides wrongly
while reporting success: exit 0, stamp written, and `--check` then answers "up to date", so the
user stops looking. (c) is round 4's Critical (the ledger on the publish remote) reachable again
through a different spelling; (a) is round 7's C1 harm verbatim. Writing "sometimes it commits
the ledger into your repository and reports success" into the header is not a limitation, it is
the defect the program's first 17 lines say it exists to prevent. And the close costs nothing,
which I measured rather than assumed.

**Fix, measured here, costing ZERO existing cases (140 assertions green, all seven refusals above
still refuse, case 27 still 5, case 38 still 0).** One derivation, defined once above the kinds,
used by BOTH guards, because two derivations disagreeing is what let (c) through:

```sh
# ONE derivation of "what local directory does this url name", used by BOTH guards below.
local_url_path() {
  local u="$1" p=""
  case "$u" in
    file://*) p="${u#file://}"
              # file://<authority><path>: git IGNORES the authority (measured: localhost, an
              # unknown name and this host's own name all reach the same local path), so the
              # authority is DROPPED rather than matched against a list of spellings.
              case "$p" in /*) ;; *) p="/${p#*/}" ;; esac ;;
    /*) p="$u" ;;                   # an absolute path is a path, whatever punctuation it holds
    *://*|*@*:*) p="" ;;            # a transport with a host: not a path
    *) p="$PROJECT_DIR/$u" ;;       # a relative remote, rooted at the project
  esac
  printf '%s' "$p"
}
```
then `local_path="$(local_url_path "$url")"` at `:416-422`, and in `canon_url` replace
`[ -d "$u" ]` with `lp="$(local_url_path "$u")"; [ -n "$lp" ] && [ -d "$lp" ]`. Note the arm
order: `/*` moves ABOVE `*@*:*`, which is git's own rule (a local path is one with no colon
before the first slash) rather than another punctuation guess, and it closes (d) completely.

That patch closes (a) (b) (c) (d). **(e) is not closed by it** and needs one decision, see I1.

Pin it by adding two rows to case 37's existing table, which is the right mechanism and already
built: `file://localhost$pp_real` and `$pp_real/a@b:c/t.git`. Both fail at HEAD and pass on the
patch, measured.

### Important

**I1. The relative-URL comment describes git, not this program, and the gap between them is
measured leak (e).** `:411-412`, `:421`. The claim "a relative URL is rooted at the PROJECT,
matching what git itself does with them" is half true, and I checked the half: git DOES resolve a
configured remote's relative URL against the repository root (verified from a subdirectory and
through `git -C` from outside). But this program never uses the URL through the project
repository. It hands the raw string to `git ls-remote` and `git clone` from wherever the caller
started it (`:451`, `:460`), and to `git -C "$work" remote add origin` (`:457`), whose pushes
resolve against the TEMP CLONE. So the directory the guard checks and the directory the run
writes are two different places whenever cwd is not the project.

Measured both ways: a relative remote works through the clone path (branch already exists) and
fails at exit 5 through the orphan path, so this is not dead configuration; and with cwd inside
an unrelated repository the run lands the ledger in that repository at exit 0 with a stamp.

**One decision, and I recommend the first:** refuse a relative remote URL the way the `dir` arm
already refuses a relative path, for the reason the `dir` arm already gives at `:279-282`. Patch
measured, 140 assertions green, leak (e) becomes exit 2 with nothing written and no stamp:

```sh
    *:*) : ;;    # a transport, an scp-style host, or a remote helper
    *)  echo "ledger-backup: '$remote' is a relative path ('$url'), which this program will" >&2
        echo "  not act on: a relative remote resolves against whatever directory the caller" >&2
        echo "  happens to be in, so the target that is checked is not the target that is" >&2
        echo "  written. Use an absolute path or a real remote url." >&2
        exit 2 ;;
```
The alternative is to keep it and write the residual below into the header. Do not keep it AND
keep the current comment: the comment is the part that is false.

**I2. Case 40 asserts a class with a regex that covers one of four assignment spellings, and the
other three are exported under `set -a` exactly like the one it catches.** `tests/ledger-backup.test.sh:827-834`.
The rule is right ("no name this script unsets may be a name it assigns"); the mechanism is
`grep -E "^[[:space:]]*$n="`. Measured in bash 3.2 under `set -a`: `export GIT_DIR=x`,
`local GIT_DIR=x` inside a function, and `declare GIT_DIR=x` each produce an EXPORTED `GIT_DIR`
(count=1 each), and the grep matches none of them. So the guard written to stop round-7's defect
returning in another spelling is itself one spelling wide, which is this loop's own class
relocated into the instrument. Fix, one line:
`grep -qE "^[[:space:]]*(export|declare|typeset|local|readonly)[[:space:]]+$n=|^[[:space:]]*$n=" "$SCRIPT"`.

**I3. Case 37's three "THE HARM" assertions cannot see the harm in the shape round 6 named.**
`tests/ledger-backup.test.sh:762-777`. Measured with the case's own three checks copied verbatim
against leak (b): ref-in-project `no`, ledger-object-in-project `no`, copy-in-worktree `no`, while
the ledger was sitting in `$PROJECT/inside.git`, untracked and unignored. A bare repo nested in
the work tree holds compressed objects that neither `cat-file --batch-all-objects` on the project
nor `find -name todo.md` reaches. What catches that row today is the exit code and the stamp,
which are rule and bookkeeping assertions, so the case's claim to assert the harm rather than the
rule is wider than its mechanism. Add one outcome assertion that covers it:
`git -C "$pp" status --porcelain` must show nothing beyond the ledger's own paths.

**I4. The exit-4 header row is in its FOURTH consecutive round of describing fewer states than
the code returns.** `:42-45` and `skills/retro/SKILL.md:53`. 16 `exit 4` sites; the row names 5.
Still undescribed: an unwritable destination, an unresolvable landing dir, an unresolvable remote
path, no temp dir, `git init` failed, an unwritable clone directory, a failed commit. Round 6 and
round 7 both asked for a mechanism rather than a fourth wording. Minimum honest close, one clause
on both rows: "or the program could not write or resolve something it needed". The mechanism that
would end it is case 33 comparing clause counts per code between the header and `/retro`, not just
row presence.

**I5. Two headline comments still claim more than they verify, and one doc now describes the
previous design.** `:49` still says THE WHOLE GIT ENVIRONMENT IS DROPPED while `GIT_SSH_COMMAND`,
`GIT_EXEC_PATH`, `GIT_TEMPLATE_DIR` and `GIT_AUTHOR_*` remain, some deliberately; round 7 asked
for the sentence to be made true or narrowed, and only the list grew (correctly: the
`GIT_CONFIG_*` addition is right and case 39 proves it). Narrow it to "the repository-location
and config-injection families" and name what is kept and why. And `docs/system-map.md:145` still
says the `git` arm asks "of a local remote's parent", which this commit replaced with two
questions; that line drifted in the commit that changed the design.

### Nitpicks

- `bin/ledger-backup.sh:256`. The ancestor walk still terminates on the literal `[ "$p" = "/" ]`.
  `dirname //` returns `/` here so it terminates; the fixpoint version costs the same and assumes
  nothing. Carried from rounds 5, 6, 7.
- `tests/ledger-backup.test.sh:633-647`. Case 33 still greps `exit [0-9]+` over the whole file,
  comments included (`:428` is a comment and counts). Its honest "what it cannot catch" paragraph
  still does not mention that trade. Carried.
- `tests/ledger-backup.test.sh:468-487`. Case 25c's comment still frames itself as "a git that
  CANNOT ANSWER is not a git that said no repository", an axis the `dir` arm's mechanism no longer
  has. It is, however, exactly the axis the NEW identity question has (`remote_common=""` falls
  through), so the sentence is now worth re-pointing rather than deleting. Carried, changed
  meaning.
- `canon_url` at `:363-369` is dead weight after C1's fix if the shared helper lands: `pwd -P`
  plus a suffix strip in two places is what let (c) through. Carried from rounds 5 to 7, now with
  a measured consequence rather than a style objection.
- `tests/ledger-backup.test.sh:537`, `:561`. Cases 28 and 29 still restore permissions inline with
  no trap, so an abort between `chmod` and restore leaves a `chmod 000` directory the suite's own
  cleanup cannot remove. Carried.
- `AGENTS.md:285-291` still quotes the deleted stop-condition rule verbatim inside a normative
  rules file. Carried.
- The refusal message at `:434` says "IS this project's own repository" for a plain directory
  inside the project too, because `git rev-parse --git-common-dir` from any subdirectory answers
  with the project's. Correct refusal, slightly wrong sentence.
- `bin/docs-claims-check.sh:97-100`: the note now names three causes and still does not say which
  one fired. Better than one false cause, weaker than counting them.

## Residuals to freeze into the header

If the human takes the freeze after fixing C1, these are the exact words to add. The first block
extends the existing `KNOWN RESIDUALS` comment at `:244`; the rest belong beside the two-question
guard at `:415`. Every one of them was measured in this round, none is assumed.

```
# KNOWN RESIDUALS OF THE CONTAINMENT INVARIANT ON THE `git` ARM, stated so a green run is not
# read as more than it is. Each was measured, not assumed.
#   - A NON-LOCAL URL CANNOT BE CONTAINED. ssh, https and git:// targets are not paths, so
#     neither question can be asked of them. The publish-remote refusal is all that covers
#     them, and it knows one repository, not the class of public ones.
#   - WHETHER A REMOTE IS PUBLIC IS NOT DECIDABLE HERE. An ssh spelling of the publish remote,
#     a mirror, a fork: all invisible. Choosing a private target stays the human's call.
#   - IDENTITY IS ASKED OF GIT, AND GIT CAN REFUSE TO ANSWER. A repository git will not open
#     (an unreadable worktree admin directory, dubious ownership on a shared mount) yields no
#     common dir, and the run falls back to the location question alone. Measured on the
#     unreadable case: the same refusal also stops the push, so it ends at exit 4, not in a
#     leak. That is an observation about git, not a guarantee this program enforces.
#   - A REMOTE THAT BORROWS THE PROJECT'S OBJECT STORE (objects/info/alternates) IS ACCEPTED.
#     Measured: the push writes nothing into the project, and the backup still reads after the
#     alternate is removed, so containment does not fail here. It is simply not asked about.
#   - A WINDOWS DRIVE-LETTER TARGET (C:/backup.git) IS NOT RECOGNISED AS A LOCAL PATH. The
#     `git` arm treats it as a remote url and does not walk it; the `dir` arm refuses it as
#     non-absolute. Stated rather than claimed: not tested on Windows.
#   - EXIT 0 AGAINST A REAL NETWORK REMOTE IS NOT PROVEN BY THE SUITE. Every remote under test
#     is a local repository. Exits 4 and 5 are proven against git's own refusals; a green run
#     against a live remote is owner attestation.
```

And, only if the human chooses to KEEP relative remote URLs instead of refusing them (I1):

```
#   - A RELATIVE REMOTE URL IS CHECKED AGAINST THE PROJECT AND USED AGAINST THE CALLER'S
#     DIRECTORY. git roots a configured remote at the repository root, but this program hands
#     the raw url to `git clone` and `git ls-remote` from wherever it was started, so when the
#     two differ the directory that was checked is not the directory that is written. Measured:
#     with the caller's cwd inside an unrelated repository, the ledger landed in that
#     repository at exit 0. Use an absolute url or a real remote url.
```

I do not recommend freezing that last one. It documents a live exit-0 leak, and the refusal that
removes it is four lines already measured green.

## Scores

correctness 1/2, the two questions are correct and I could not get back in through any of seven
routes that previous rounds needed individual patches for, the rename is right, the unset is
right, and both claims in the commit body that I could check (case 27 does not flip; 13 canary
failures) are exact. Docked hard for the conversion step in front of the questions: three
spellings of a local URL reach exit 0 with the stamp, and a fourth (relative) writes somewhere
other than the place that was checked.

security 0/2, a Critical lands here, and this round it reaches further than the last: besides
committing the ledger into the project's own repository (round 7's harm, through a new spelling),
one spelling pushes it to the PUBLISH REMOTE, which is the harm round 4 scored Critical and the
one the whole file exists to prevent. Exit 0, stamp written, `--check` then reports up to date.
Hygiene elsewhere is good and improved: the config-injection family is now dropped and case 39
proves it, quoting is sound throughout, no `eval`, no ledger content on stdout, the stamp stays
under the git dir.

performance 2/2, unchanged and verified. The two questions add at most two `cd`+`pwd -P` and two
`git rev-parse` calls per run; the suite is 21s, still dominated by three deliberate `sleep 1`s.

readability 1/2, the guard's rationale is the clearest it has been (it states the question, why,
and what it deliberately keeps), the refusal messages name the right thing, and the commit body
is again the best on this branch. Docked for three sentences that are measurably wider than their
mechanism in the most load-bearing places (`:399-400`, `:411`, `:49`) and for `docs/system-map.md`
now describing the previous design.

testing 1/2, the structural ask from round 7 was delivered: case 37 is a table over spellings with
outcome assertions, case 38 pins what the refusal must not cost, and the canary is real and
reproduces exactly. Docked because the table missed the sibling spelling of its own `file-url`
row, its three harm assertions are blind to the nested-bare-repo shape (I3), and case 40 asserts a
class with a one-spelling regex (I2). 140 green, re-run here, plus all 33 suites.

conventions 1/2, verified: conventional commit, feature branch, English comments, no em or en
dashes, README counts matching, `docs-claims-check --assertions` and `skills-lint` green, no
secrets. Docked one for the documented convention in `lessons.md` 2026-09-16, "to claim a class
the mechanism must assert an OUTCOME, because text checks are evaded by the next spelling", which
is the exact shape of C1, I2 and I3.

total 6/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

**Same total, materially better artifact, and the defect moved one step earlier.** The decision
logic is no longer the weak part: it is structural and it held against every shape I could build.
What leaks is the input to it. Round 7's C1 was "the guard asks the wrong question"; round 8's C1
is "the guard asks the right question about the wrong object". That is progress in design and no
progress in outcome, which is why the number does not move.

## Ceiling

**11/12 is the honest ceiling for a round 9, not 12.** C1 has a fix proven here at zero cost to
existing cases, I1 has a decision plus a proven patch, I2, I3, I4 and I5 are one line each, so
correctness, security, readability and conventions can all reach 2. Testing caps at 1 until the
spelling table and the static check both assert their class rather than an instance, and even
then one residual is permanent and belongs in the header rather than in a score: a non-local URL
cannot be contained by any on-disk walk, and exit 0 against a live network remote is owner
attestation the suite cannot reproduce.

## Loop position

**This is round 8, dispatched as the last one, and I am not handing back a list.** The single
blocking item is C1, with a patch measured in this review; I1 is one decision with a patch also
measured; I2 to I5 are one line each and could ship in the same commit without further review.
Everything else I found is written above as residual wording ready to paste.

**Stop condition 3 fires once more, and the phrase has narrowed, which matters.** Rounds 3 to 7
were "a containment guard that recognises one spelling of its target". Round 8 is strictly
smaller: *the decision is structural, the parsing in front of it is not.* The remaining class is
confined to one function's worth of code, it has one fix that serves both guards, and unlike the
previous rounds the fix costs no existing case and requires no contract change.

**Recommendation, in order:**
1. Apply C1's shared `local_url_path` helper to both guards (measured: 140 green, every attack
   in this round refused, case 27 and case 38 unchanged).
2. Take the I1 decision. Refuse relative remote URLs, which is what the `dir` arm already does
   for the same reason.
3. Add the two rows to case 37's table, the `status --porcelain` assertion (I3), the four-spelling
   regex in case 40 (I2), the exit-4 clause (I4), and the two comment narrowings plus the
   `system-map.md` line (I5).
4. Paste the residual block above into the header and FREEZE the contract.
5. If a round 9 is run at all, it is a re-anchor of this record at the new head, not a new
   review. If it finds another instance of URL parsing, the product answer is the narrow one
   already named in round 7: accept only an absolute path to a bare repository outside every
   work tree, or a non-local URL, and refuse every other spelling by default.

## Does this cover HEAD for the merge gate?

The record describes `b3b66f7` exactly, clean tree, everything re-measured today. It does NOT
clear the gate: REQUEST CHANGES on C1. Do not re-date this record; regenerate it at the new head
after the fixes.

## What's good

- **The design change is the right one and it works.** Comparing git COMMON DIR is an identity
  test, not a path test, and it answered correctly for a sibling worktree, a symlinked project, a
  submodule, a `..` path and a self-reference without a line of code per shape. Four rounds of
  spelling patches on the `dir` arm are what that replaces.
- **Case 38 exists.** Alongside the case that pins the new refusal sits the case that pins what
  the refusal must not cost, and the commit body states the legitimate configuration it protects.
  That pair is why I could measure my own proposed patch as costing zero cases instead of
  guessing.
- **The canary is honest and reproducible.** 13 failures against the previous commit, exactly as
  claimed, including the static name check. Very few commit bodies on any branch survive that
  check unchanged.
- **Case 40's comment says why the outcome test cannot be the assertion on this machine, and the
  SKIP is reported rather than passed off as green.** Then it followed the consequence one file
  further and fixed the false "an optional tool is missing" note in `docs-claims-check.sh`. That
  is the discipline `lessons.md` asks for, applied without being asked.
- **The `GIT_CONFIG_*` fix went for the family, not the reported variable**, and case 39 asserts
  the outcome on both remotes (the intended one received it, the injected one did not).

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
