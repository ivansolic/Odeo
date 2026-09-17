---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh (+ session-end-check.sh, init-project.ledger, project-templates/CLAUDE.md, skills/retro, README counts)
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 0046a92
artifact_version: 4
date: 2026-09-17
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 1, performance: 2, readability: 1, testing: 1, conventions: 2 }
total: 8/12
verdict: REQUEST CHANGES
previous_total: 7/12
---

## Artifact

Commit `0046a92` on `feature/windows-powershell-entry`. This is a VERIFICATION of a human
decision, not a fourth round of the round-1-to-3 loop: after the stop condition fired
(`docs/eval-framework.md`, condition 3), the human chose the structural option, replacing the
question "is this target inside THIS project" with "is this target inside ANY git repository".
No plan exists in `docs/plans/` for this work, so the binding statements are the program header,
the guard comments, the `/retro` exit table and the commit body.

## The decision itself: it holds

**The structural swap does what it was chosen to do, and I could not defeat it by the routes
this review was asked to try.** Measured in a hermetic probe tree, on the shipped script:

| attempted defeat | result |
|---|---|
| all six disguises from rounds 1-3 (parent symlink, `..`, case-only, dest-is-a-symlink, nested repo, sibling worktree) | refused, exit 2, nothing written, no stamp |
| destination inside a BARE repo | refused, exit 2 |
| destination inside the project's own `.git` | refused, exit 2 |
| `GIT_DIR` exported by the caller | refuses EVERYTHING, exit 2 (fail-closed; see N2) |
| `GIT_WORK_TREE` exported, target inside the project | refused, exit 2 |
| `GIT_CEILING_DIRECTORIES` set to blind discovery, target inside the project | refused, exit 2 |

The reason bare repos and `.git` are also caught is worth writing down, because it is not what
the comment says: `in_work_tree()` keys on git's EXIT STATUS, not on the word git prints. Inside
a bare repo and inside a git dir, `rev-parse --is-inside-work-tree` prints `false` and exits 0,
so the mechanism is really "git can find a repository from here", which is stricter than the
sentence above it. Stricter is the right direction here; it is also accidental, which is why N1
below asks for it to be stated rather than left to be "cleaned up" later.

Mutation evidence: I re-ran the builder's three claims myself rather than accepting them, plus
one it did not claim. All reproduce.

| mutation | result |
|---|---|
| remove the destination-side `in_work_tree` check | shape 3 lands the ledger in the work tree at exit 0 WITH a stamp; 2 assertions redden |
| remove the publish-remote guard | 4 assertions redden, output is `refreshed (... -> origin/internal-files:internal-not-in-git/)` |
| remove the unreadable-ledger-dir check | run exits 6 "nothing to back up", `--check` exits 0; 2 assertions redden |
| keep the NAME half of the publish guard, drop the URL half | 2 assertions redden (so both halves are independently pinned) |

Suite as shipped: 77 assertions, green. I did not re-run the other 32 suites; nothing I found
depends on them.

The accepted residual (a synced folder inside an unrelated repository is refused too) is real,
is stated at the point of use (`bin/ledger-backup.sh:200-202`) and is stated again in the refusal
message the user actually sees: "Point it at a directory outside every repository." That is the
right placement. Case 19b pins it as behaviour, not as prose.

## Findings

### Critical

None. No default-state path, and no probe made the stamp claim a backup that never happened.

### Important

**I1. The publish-remote guard makes a CLASS claim with a TEXT compare, and I pushed the ledger
past it with a trailing slash.** `bin/ledger-backup.sh:258-271`. The comment says the URL is
compared "because a second remote name can point at the same repository and the name is not the
thing that publishes". The mechanism is `[ "$url" = "$pub_url" ]`, so it only catches a
BYTE-IDENTICAL spelling. Measured, three spellings of one local repo, all three pushed:

```
origin = $SB/pub.git ; mirror = $SB/pub.git/        -> exit 0 "refreshed", PUSHED to the publish remote
origin = $SB/pub.git ; mirror = $SB/pub.git/.       -> exit 0, PUSHED
origin = $SB/pub.git ; mirror = $SB/../$SB/pub.git  -> exit 0, PUSHED
```

The real-world spelling is not the trailing slash, it is `git@github.com:me/proj.git` as `origin`
and `https://github.com/me/proj.git` as the second remote, which is an ordinary thing for a repo
to have. An `insteadOf` rewrite and a `.git`-suffix difference are the same shape. This is
`lessons.md` 2026-09-16 verbatim ("a guard's comment may name only what it verifies; to claim a
CLASS the mechanism must assert an OUTCOME, because text checks are evaded by the next
spelling"), and the same commit contains that lesson correctly APPLIED one branch over: the `dir`
path asks git instead of comparing strings. The name half is sound and catches the plausible typo
(`git origin internal-files`); it is the by-URL half that overclaims.
This one blocks. Not because the residual is unacceptable, but because the choice between the two
honest closes has not been made: either assert the outcome, or narrow the sentence and write the
residual into the header and the `/retro` exit-2 row the way the `dir` branch's residual is
written down. I am not proposing a third, cleverer comparison; that is the loop this branch just
left. Note for the record that the weak version came from MY round-3 fix text, which said
"compare `git remote get-url` against the publish remote's URL": the builder implemented my
prescription literally and inherited its trap.

**I2. `mkdir -p` follows a symlink one level deeper than the check reaches, so the leaf can still
carry the ledger into a work tree.** `bin/ledger-backup.sh:215-226`. The guard resolves `$dest`,
but the files land in `$dest/internal-not-in-git/`, and `mkdir -p` follows that component too if
it already exists as a symlink. Measured:

```
ln -s $PROJ/leak $SYNCED/internal-not-in-git ; ledger_backup: dir $SYNCED
-> exit 0, "refreshed", todo.md + lessons.md in $PROJ/leak/, git check-ignore: NOT IGNORED, stamp written
```

This is the same mechanism the commit body says it closed ("asked twice ... because mkdir follows
a symlink"), applied to the path the files actually land in rather than to its parent. It is NOT
a new disguise of the abandoned question: it is the one question asked about the wrong argument,
and it is decidable (ask about the deepest component the program creates, after creating it).
Reachability is the weakest of the three findings: `internal-not-in-git` is a name this program
owns, so the symlink has to be planted by someone else. A documented residual is a legitimate
close here; an undocumented falsified invariant is not, and today the header says "a backup
target may not live inside ANY git work tree" while this path puts it in one.

**I3. When git cannot answer the containment question, the answer is read as "not in a
repository", which is the fail-open shape this program refuses everywhere else.**
`bin/ledger-backup.sh:203`. `in_work_tree` cannot distinguish "git says no repo here" from "git
declined to answer", because both are a non-zero exit. Measured with an unreadable `.git/config`
as the stand-in for the common real case (`detected dubious ownership`, i.e. a repo owned by
another uid, which is routine in containers, on shared drives and on network mounts):

```
chmod 000 $OTHER/.git/config ; ledger_backup: dir $OTHER/backups
-> exit 0 "refreshed", ledger in $OTHER/backups/internal-not-in-git/, NOT IGNORED there
```

One line above, this same program refuses an unreadable ledger directory and an unreadable mtime
with "reporting nothing would be a lie" (`:62-71`, `:136-139`). The containment guard applies the
opposite policy to the same kind of ignorance, silently. Whichever way this is closed (refuse when
git errors rather than answers, or state that an unreadable repository is not detected), the two
policies should be the same policy.

### Nitpicks

- `bin/ledger-backup.sh:203`. `in_work_tree` is named for the question and implemented as
  "git found a repository" (exit status, not output). That accidental strictness is what refuses
  bare repos and `.git` dirs. Say so in the comment, or a later cleanup to
  `[ "$(git ... --is-inside-work-tree)" = true ]` will silently reopen both.
- `tests/ledger-backup.test.sh:352`. Three of the five `and nothing landed in the work tree (N)`
  assertions cannot fail: they test `[ -e "$p22/backups" ]`, while shapes 3, 4 and 5 target
  `backups-via-link`, `vendor/nested/backups` and the sibling worktree. Proven, not inferred:
  under the destination-check mutation shape 3 leaked into the work tree and that assertion still
  printed `ok`. The exit-code and stamp assertions carry the case, so nothing is uncovered, but
  the suite counts 3 passes that cannot go red, and the README publishes that count. Fix: assert
  against the shape's own resolved path.
- `bin/ledger-backup.sh:57`. `GIT_DIR` is git's own environment variable; assigning it in a shell
  that INHERITED it exported keeps the export, so every later `git -C` call in this program obeys
  it. Measured: with `GIT_DIR` exported by the caller, a perfectly legitimate outside target is
  refused with a message naming a repository it is not in. Fail-closed, so not a leak, but the
  message is false. Fix: rename the variable and `unset GIT_DIR GIT_WORK_TREE` at the top.
- `skills/retro/SKILL.md:51`. The exit-2 row still says "a relative or in-project path", which is
  now understated twice over: exit 2 also covers any path in ANY repository, an unreadable ledger
  directory, and the publish remote. The contract test only checks that a row EXISTS per code, so
  the drift is invisible to it.
- `bin/ledger-backup.sh:19-28` and `project-templates/CLAUDE.md:91-92`. The configuration docs a
  user reads BEFORE choosing a target still say only `dir <absolute-path>`. The "outside every
  repository" rule is discoverable only at failure time. One clause in each would make the
  accepted residual visible in advance.
- `tests/ledger-backup.test.sh:390-397` (case 26). `chmod 000` is the spelling tested; `chmod 444`
  also breaks `[ -f ]` while leaving `ls` able to read names. On macOS I measured it refused
  (exit 2, both paths), so it is closed HERE, but that rests on this platform's `ls` and I have no
  Linux to check. Unverified elsewhere; worth one line in the case comment.
- Carried from round 3, unchanged and still true: the case-only assertions
  (`tests/ledger-backup.test.sh:366-372`) are vacuous on a case-SENSITIVE filesystem; `awk
  '{print $3}'` at `:253` silently truncates `git backup my branch`; the staging dir is
  `$$`-named with no sweep; `tests/ledger-backup.test.sh:148` still assigns an unused `d`.

## Scores

correctness 1/2, the decided change holds against every route this review was asked to try
(bare repo, `.git`, three git environment variables, all six historical disguises), and all four
mutations reproduce. Docked for I2: a measured path still lands the ledger in a work tree at exit
0 with a stamp, and for I3, where "git could not answer" is read as "no repository". Not 0:
nothing is reachable in a default project and the stamp never claims a backup that did not occur.

security 1/2, the highest-harm path in the program is still open by a spelling (I1): the ledger
reaches the publish remote, at exit 0, under the word "refreshed". The plausible typo is caught,
the ssh-vs-https alias is not. Hygiene remains good: quoting, no `eval`, no ledger content on
stdout, the stamp outside the work tree, no network on the `--check` path.

performance 2/2, two `rev-parse` calls added on the `dir` path, invisible. Clone still
`--depth 1 --single-branch`.

readability 1/2, the guard comment is the best in the file: it carries its three-round history,
names the question it replaced and writes the residual down. Docked because the two sentences that
matter most are falsified by measurement, "asked ... of the destination itself" (I2, the leaf is
not the destination) and the by-URL rationale (I1), which is `lessons.md` 2026-09-16 recurring on
a guard added this round.

testing 1/2, a real step up: five disguises in one loop, per-shape stamp clearing, and four
mutations I reproduced independently including one the builder did not claim. Docked because
coverage still follows the fix rather than the risk (no case for a differently-spelled publish
URL, none for a symlinked leaf) and because three of the loop's assertions are provably incapable
of failing.

conventions 2/2, `./install.sh` was re-run and I verified the result rather than the claim: 24
programs in `~/bin` including `ledger-backup.sh`, the `ledger_backup:` section present in
`~/.claude-templates/CLAUDE.md`, and `~/.claude/CLAUDE.md` still the untouched symlink. README
count moved 973 -> 990 with the suite. Conventional commit, feature branch, no secrets, English
comments, no em or en dashes.

total 8/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 stays structurally reachable. What caps it today is one guard and one argument: I1 needs the
same treatment the `dir` branch just received (assert the outcome, or narrow the claim and publish
the residual), I2 needs the existing question asked about the leaf the program creates, I3 needs
the program's own "cannot decide" policy applied consistently. The remote-side residual is
unchanged from rounds 2 and 3: exits 4 and 5 are proven against local fixtures, exit 0 against a
real remote only by owner attestation I did not reproduce. That residual is worth stating, not
scoring.

## Does this cover HEAD for the merge gate?

The record describes `0046a92` exactly, with a clean tree, so it is current. It does NOT clear the
gate: the verdict is REQUEST CHANGES, on I1 alone. I2 and I3 are "should fix" and would not block
by themselves. The cheapest path to a mergeable state is not a fourth comparison but a decision:
if the by-URL half stays a text compare, say so in the header, in the guard comment and in the
`/retro` exit-2 row, and the finding becomes a documented residual rather than an overclaim. Then
re-run this reviewer at the new head; do not re-date this record.

## What's good

- The decision itself is the right one and it survives adversarial probing. Three env variables
  that could plausibly blind git (`GIT_DIR`, `GIT_WORK_TREE`, `GIT_CEILING_DIRECTORIES`) all fail
  CLOSED, and bare repos and git directories are refused as a side effect of keying on git's exit
  status. Six rounds of disguises collapsed into one question that a future change must face whole.
- The residual is written where it bites, in the refusal message the user reads, not only in a
  comment they never will. "Point it at a directory outside every repository" tells someone with a
  Dropbox folder inside a repo exactly what to do.
- Every mutation the commit body claims reproduced on my run, and the fourth one I invented (drop
  only the URL half of the publish guard) reddened too, which means both halves are independently
  pinned rather than one covering for the other.
- The per-shape stamp clearing in the disguise loop is the 2026-08-18 lesson applied, not quoted:
  it was found BY mutation testing, when one shape's wrongly-written stamp was being attributed to
  the next.
- `./install.sh` was re-run and the global `~/.claude/CLAUDE.md` symlink correctly left alone,
  which is the round-3 conventions dock properly closed rather than argued away.

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
