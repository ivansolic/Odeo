---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ session-end-check.sh, init-project.ledger, project-templates/CLAUDE.md, skills/retro, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 2e7c740
artifact_version: 5
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

Commit `2e7c740` on `feature/windows-powershell-entry`, clean tree. Two commits moved the code
since round 4: `26e69a9` closed I1, I2 and I3 from that record, and `2e7c740` added test cases
27, 28 and 29. No plan exists in `docs/plans/` for this work, so the binding statements remain
the program header, the guard comments, the `/retro` exit table and the commit bodies.

## Round 4's required fixes, checked against the tree

| round-4 finding | status at HEAD |
|---|---|
| I1, publish guard made a CLASS claim with a TEXT compare (3 spellings pushed) | **closed, the honest way.** The comparison runs through `ls-remote --get-url`, resolves a local path with `pwd -P`, and the comment now states exactly what it does and what it cannot judge. All three spellings refused, pinned by case 25. |
| I2, `mkdir -p` followed a symlink one level below the check | **closed.** The question is now asked of `$dest/internal-not-in-git` after creating it (`:244-249`); case 25b pins it. I re-ran the round-4 probe: exit 2, nothing in the work tree. |
| I3, "git could not answer" read as "not in a repository" | **half closed.** The unreadable-`.git/config` spelling now refuses (case 25c, reproduced). A repository git cannot read whose message happens to read "not a git repository" still lands the ledger inside a live work tree at exit 0. See C1 below. |
| N, `in_work_tree` is named for a question it does not ask | closed, said out loud at `:209-212`. |
| N, three assertions in the disguise loop could not fail | closed, replaced by a `find` for the harm itself (`:361`), which is shape-independent. |
| N, `/retro` exit-2 row understated | closed, the row now lists every refusal and the paragraph below states what the program cannot judge. |
| N, config docs read before choosing a target | closed for `project-templates/CLAUDE.md:93-96`; the program header still does not carry it (I2 below). |
| N, `GIT_DIR` assigned in a shell that may have inherited it exported | **still open**, and still measured: with `GIT_DIR` exported, a legitimate outside target is refused with a message naming a repository it is not in. |
| N, case 26 `chmod 444` platform note | still open. |
| carried nits (case-only assertions, `awk '{print $3}'`, unused `d`) | still open. |

## Findings

### Critical

None. No default-state path leaks, and no probe made the stamp claim a backup that never
happened **except** under C1's precondition, which is not a default state.

### Important

**C1. The containment guard now decides the safety question from git's STDERR TEXT, and a work
tree whose gitdir git cannot read is read as "no repository", so the ledger lands in it at exit
0 with a stamp.** `bin/ledger-backup.sh:213-224`. `in_work_tree` returns "not in a repo" when
the message matches `*"not a git repository"*`. git prints exactly that, with an exit of 128,
when it finds a `.git` file it cannot follow. Measured on the shipped script:

```
git worktree add $SB/wt ; mkdir $SB/wt/backups ; chmod 000 $SB/main/.git/worktrees
ledger_backup: dir $SB/wt/backups
-> exit 0, "refreshed", todo.md + lessons.md in the live work tree
-> STAMP WRITTEN, so --check then answers "up to date"
-> after permissions are restored: git status shows `?? backups/`, check-ignore says NOT IGNORED
```

The same message, and the same acceptance, for a `.git` file pointing at a gitdir that no longer
exists (a moved main repo, a submodule copied without `.git/modules`). This is the exact shape
`26e69a9` says it closed ("Now three answers: in a repo, not in a repo, and cannot tell, which
refuses"): the third answer exists, but which answer you get is decided by a string, so one
spelling of "cannot tell" is still classified as "no repository". It also means the guard's
behaviour depends on git's locale: a translated "not a git repository" would fail the match and
refuse every legitimate target (fail-closed, unverified here, this macOS git ships no
translations).

**This is the same CLASS as round 3's containment spellings and round 4's I1, which is three
consecutive rounds, so `docs/eval-framework.md` stop condition 3 applies and I am not proposing a
fourth string pattern.** The decidable, message-free version exists and I measured it against the
fixtures that matter before writing it here:

```
p="$landing_real"; while :; do [ -e "$p/.git" ] && refuse; [ "$p" = / ] && break; p="$(dirname "$p")"; done
  C1's unreadable worktree gitdir -> refused
  case 25c's unreadable .git/config -> refused
  an ordinary outside target       -> accepted (no false positive)
  a target under a $HOME that is a repo -> refused (the residual already accepted, unchanged)
```

Combined with `git rev-parse` exiting 0 (which keeps the bare-repo and `.git`-dir strictness) and
with `unset GIT_DIR GIT_WORK_TREE` at the top of the program (the still-open round-4 nit, which
closes the one case a filesystem walk cannot see), the stderr text stops being load-bearing for
safety and is left to choose wording only. If the human prefers not to take that, the other
honest close is the one this branch already used for the publish guard: state in the header, the
guard comment and `/retro` that a repository git cannot READ is not always detected, and this
becomes a documented residual instead of a falsified invariant. What must not happen is a fifth
phrasing of the lesson at `lessons.md` 2026-09-16; the global rule for a recurring lesson is a
mechanism at the point of use, and a test that plants an unreadable gitdir is that mechanism.

**I2. The header's exit-code table, which the program itself calls the caller contract, still
describes exit 2 as it was three rounds ago.** `bin/ledger-backup.sh:30-37` says "2 usage, or not
inside a git work tree". Exit 2 today also means: the target is inside any git repository, git
could not decide that question, the ledger directory or an mtime is unreadable, the target is the
publish remote, the kind is unknown, and `dir` got a relative path. `/retro`'s row was rewritten
in the same commit that widened the code; the header was not. Case 21 only checks that each
`exit N` has a row in `skills/retro/SKILL.md`, so this drift is invisible to the suite that was
built to prevent exactly it. Fix: mirror the `/retro` wording into the header, and extend case 21
to require each code to appear in the header's table as well, so the two cannot separate again.

### Nitpicks

- `tests/ledger-backup.test.sh:436-437` and the body of `26e69a9` both say the publish-remote
  residual "is stated in the program header". It is not: `grep -n 'ssh\|public' bin/ledger-backup.sh`
  puts it in the guard comment (`:295-298`), and it is also in `/retro`, the project template and
  the system map. Point at the guard comment, or add the sentence to the header.
- `bin/ledger-backup.sh:299-305`. `canon_url` tests `[ -d "$u" ]` against the CALLER's cwd, while
  git resolves a relative remote URL against the repository. Measured: with `alias = ../pub.git`
  and cwd `/tmp`, the publish compare misses. No leak follows, because the later bare
  `git ls-remote "$url"` uses the same wrong base and the run dies at exit 4, but the message it
  prints then ("offline, or no access") is false. Fix: resolve inside `$PROJECT_DIR`.
- Measured, inside the stated residual but worth one clause: `origin = $SB/pub.git`,
  `alias = file://$SB/pub.git` -> exit 0, ledger PUSHED to the publish remote. The comment says a
  URL that is a local path is settled by `pwd -P` "at once"; a `file://` URL is a local path with
  a scheme and is not. Say so where the residual is written, do not add another comparison.
- `bin/ledger-backup.sh:57`, carried from round 4 and re-measured at HEAD: `GIT_DIR` exported by
  the caller makes every `git -C` in the program obey it, and a legitimate outside target is
  refused with a message naming a repository it is not in. Fail-closed, message false. Fixing it
  is also half of C1's fix.
- `tests/ledger-backup.test.sh:529-575`. Cases 28 (`:536-538`) and 29 (`:561-563`) `chmod` the fixture,
  run, restore, and only then check for root and skip; if an assertion aborts the suite between
  the chmod and the restore, the `trap rm -rf "$TMP"` hits a read-only tree. Put the restore in a
  per-case subshell trap. Case 29 restores `objects` to 755 rather than git's 444, which is
  harmless in `$TMP` but reads as an accident.
- Carried, unchanged and still true: `awk '{print $3}'` at `:276` silently truncates
  `ledger_backup: git backup my branch` to branch `my` (measured: exit 4, no mention of the
  branch name); the case-only assertions at `tests/ledger-backup.test.sh:371-377` are vacuous on
  a case-sensitive filesystem; `tests/ledger-backup.test.sh:148` still assigns an unused `d`; case
  26 tests `chmod 000` only, with no note that `444` rests on this platform's `ls`.

## Scores

correctness 1/2, two of round 4's three Importants are closed and independently reproduced here
(the leaf-symlink landing dir, the three publish spellings), exits 4 and 5 are now proven against
git's own refusals rather than a fixture hook, and 94 assertions are green. Docked for C1: a
measured path still puts the ledger in a live work tree at exit 0 with a stamp, and for the
cwd-relative URL resolution. Not 0: the precondition is an unreadable or missing gitdir, not a
default state, and every default path I probed refuses correctly.

security 1/2, the round-4 security dock is closed, the publish guard no longer overclaims and the
three spellings that pushed the ledger to the publish remote are refused and pinned. The new dock
is C1's confidentiality path: `todo.md` and `lessons.md` are gitignored precisely so they cannot
be committed, and under C1 they land untracked and unignored in a work tree while `--check`
reports "up to date". Hygiene stays good: quoting, no `eval`, no ledger content on stdout, stamp
under `.git`, no network on `--check`, `ls-remote --get-url` contacts nothing.

performance 2/2, the added calls are local config reads. The suite runs in 16s, dominated by
three deliberate `sleep 1`s that the mtime assertions need.

readability 1/2, the guard comments are now accurate about their own mechanism, which is what
round 4 asked for, and the publish comment states its residual in the same breath as its claim.
Docked for I2: the header's exit-code table, which the file itself calls the thing "a caller must
be able to tell apart", describes a version of exit 2 that stopped being true two commits ago,
and for the test comment that sends a reader to the header for a residual the header does not
carry.

testing 1/2, the real step up this round: cases 27, 28 and 29 replace a hook we wrote with git's
own refusals (`receive.denyCurrentBranch`, a read-only remote) and reach the clone branch's exit
4 for the first time, each asserting the absent stamp, which is the property that keeps `--check`
honest. The three assertions that could not fail are gone, replaced by a search for the harm.
Docked because coverage still follows the fix rather than the risk: 25c pins one spelling of "git
cannot answer" and C1 is the spelling nobody wrote a case for, and nothing pins the header's exit
table the way case 21 pins `/retro`'s.

conventions 2/2, verified rather than accepted: `docs-claims-check.sh --assertions` is green with
24 executables, 33 suites and 1007 assertions, matching README. Conventional commits, feature
branch, no secrets, English comments, no em or en dashes in any changed file.

total 8/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 stays structurally reachable and is now one decision away. C1 is decidable without another
heuristic (the ancestor walk above, measured on four fixtures, plus unsetting git's environment
variables), and I2 is a wording change plus one extra loop in case 21. The remote-side residual is
unchanged from rounds 2 to 5: exits 4 and 5 are now proven against git's own refusals, and exit 0
against a real network remote remains proven by owner attestation I did not reproduce. That
residual is worth stating, not scoring.

## Does this cover HEAD for the merge gate?

The record describes `2e7c740` exactly, with a clean tree. It does NOT clear the gate: the verdict
is REQUEST CHANGES on C1, with I2 as a should-fix that would not block by itself. Round 5 is where
the review loop's stop condition matters more than the finding: three consecutive rounds have
raised a fail-open in the same class (a safety decision keyed on text), so the next move is a
structural elimination or a documented residual chosen by the human, not a sixth round of the same
loop. Whichever is chosen, re-run this reviewer at the new head; do not re-date this record.

## What's good

- Cases 27 and 28 are the right kind of test: exit 5 was previously proven only against a
  `pre-receive` hook this suite writes, which shows the program reads a non-zero push and nothing
  more. Pointing the backup at an ordinary non-bare clone and letting git's own
  `receive.denyCurrentBranch` refuse it proves the same code against a refusal nobody in this repo
  authored, and the mistake it models (backup target is a working clone, not a bare repo) is one a
  real user makes.
- Case 29 found the branch nothing had executed: the reachability probe and the clone used to fail
  together, so the clone's own exit 4 had never run. Splitting readable refs from unreadable
  objects is a precise way to reach it.
- The publish guard took the honest close offered in round 4 rather than inventing a third
  comparison: the claim was narrowed to what the mechanism does (one trailing `/`, one `.git`,
  local paths through `pwd -P`) and the residual was published in four places a user actually
  reads. That is `lessons.md` 2026-09-16 applied correctly, in the same file where C1 shows it
  recurring.
- The vacuous-assertion fix is the right generalisation: searching the whole work tree for a copy
  of the ledger asserts the HARM, so it stays valid for shapes nobody has thought of yet.
- Every count the docs publish was re-measured green, and the commit body that admitted one count
  was derived rather than measured is exactly the honesty this system asks for.

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
