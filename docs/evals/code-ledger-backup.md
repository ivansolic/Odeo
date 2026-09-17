---
artifact: bin/ledger-backup.sh + bin/session-end-check.sh + tests/ledger-backup.test.sh + tests/session-end-check.test.sh + tests/init-project.ledger.test.sh + project-templates/CLAUDE.md + skills/retro/SKILL.md + README counts
type: code
branch: feature/windows-powershell-entry
reviewed_commit: 6f0ab87
artifact_version: 3
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

Commit `6f0ab87` on `feature/windows-powershell-entry`, round 3 and the declared cap
(`docs/eval-framework.md`, stop condition 2). It claims all five round-2 Importants plus four
nitpicks. No plan exists in `docs/plans/` for this work, so there is no contract to compare
against; the binding statements are the program header, the guard comments, the `/retro` exit
table and the commit body.

**Four of the five Importants are closed and I reproduced the builder's own mutation evidence
for each.** The fifth, the containment guard, did not converge: it closed the three shapes round
2 measured and opened three others, one of which is a **regression against the code it replaced**.
That is the same class two rounds running, which is stop condition 3 verbatim, so the cap is the
right place for this to end.

## Verification (by measurement, in a scratch clone at `6f0ab87` and a hermetic probe tree)

Mutations run by me, not accepted from the report:

| mutation | result |
|---|---|
| restore the round-2 string compare | case 22 reddens **8** assertions (the report said 6) |
| plant `exit 7` in the `-*)` one-line case arm | contract check reddens: "exit code(s) 7 are reachable but have no row" |
| revert the placeholder guard to `*'<'*|*'>'*` | case 23 reddens twice |
| strip the git branch's `cp` check | case 24 reddens with the exact lie described: `already current (backup/internal-files)` at exit 0 |
| revert the hook to `-eq 1` | session-end 4b reddens twice |

Both suites green as shipped: `ledger-backup` 60 assertions, `session-end-check` 16. I did not
re-run the other 31 suites or `docs-claims-check`; the README count (973) rests on the builder's
evidence and nothing I found depends on it.

Behaviour probes (each a real git work tree with a real ledger):

```
dest is itself a symlink into the project   -> exit 0, files in $PROJ/backups/internal-not-in-git/, STAMP WRITTEN
dest inside a nested repo ($PROJ/vendor/..) -> exit 0, files in the work tree   (old guard: exit 2)
dest inside a sibling worktree, same repo   -> exit 0, files there, `check-ignore` says NOT IGNORED
dest via a parent symlink / `..` / case     -> exit 2, nothing written, no stamp   (closed, confirmed)
project reached through a symlink           -> exit 2   (closed, confirmed)
chmod 000 on .claude/tasks, then --check    -> exit 0 "nothing to back up", hook SILENT
a failed run over a good backup             -> exit 4, previous backup intact, message truthful
```

## Findings

### Critical

None. Nothing here is reachable in a project's default state, and no path was found that makes
the stamp claim a backup that did not happen (the one round-1 Critical of that shape stays
closed, re-probed on the git branch by mutation above).

### Important

**I1. The containment guard asks git about the destination's PARENT, so it answers a question
one level away from the one it is asked. Three shapes land the ledger inside a git work tree at
exit 0 with a stamp; one of them worked before this commit and does not now.**
`bin/ledger-backup.sh:185-195`. Measured, all three:

```
a) dest IS the symlink:  ln -s $PROJ/backups $T/outside-link ; ledger_backup: dir $T/outside-link
   -> parent ($T) is outside the repo, guard passes, mkdir -p follows the link
   -> exit 0, "refreshed", $PROJ/backups/internal-not-in-git/{todo,lessons}.md, stamp written
b) nested repo:          ledger_backup: dir $PROJ/vendor/nested/backups   (vendor/nested is its own repo)
   -> dest_top = the nested repo, != proj_top, guard passes -> exit 0, ledger in the work tree
   -> the STRING COMPARE THIS REPLACED refused it (verified side by side): a REGRESSION
c) sibling worktree:     git worktree add $T/wt ; ledger_backup: dir $T/wt/backups
   -> --show-toplevel differs per worktree, guard passes -> exit 0, and `git check-ignore` in
      that worktree says NOT IGNORED, so `git add -A` publishes the ledger into the SAME repo
```

The comment at `:179-184` says git "answers about the repository a path is actually in". It does
not: `--show-toplevel` answers about the WORK TREE, which is why (c) walks through, and the
resolution is applied to the parent, which is why (a) walks through. This is `lessons.md`
2026-09-16 ("a guard's comment may name only what it verifies") for the third consecutive round
on the same guard, and (b) means the replacement is not a superset of what it replaced: the fix
traded three failure shapes for three others.
Fix, three parts, because no single question answers all three:
```sh
mkdir -p "$dest/internal-not-in-git" || { ... exit 4; }          # create FIRST, then ask about $dest
dest_real="$(cd "$dest" && pwd -P)"
proj_real="$(cd "$(git -C "$PROJECT_DIR" rev-parse --show-toplevel)" && pwd -P)"
case "$dest_real/" in "$proj_real"/*) refuse ;; esac             # (a) and (b): resolved prefix
dcommon="$(git -C "$dest_real" rev-parse --git-common-dir 2>/dev/null)" || dcommon=""
[ -n "$dcommon" ] && [ "$(cd "$dcommon" && pwd -P)" = "$(cd "$(git -C "$PROJECT_DIR" rev-parse --git-common-dir)" && pwd -P)" ] && refuse   # (c): one answer for every worktree of a repo
```
The resolved prefix test is the old mechanism with the resolution the new one added, so it keeps
(b) closed instead of trading it; `--git-common-dir` is what makes "the repository a path is in"
true rather than aspirational. Then add all three shapes to case 22, and narrow the comment to
what the code checks if any of them is left open on purpose.
**Class statement, for eval-framework stop condition 3:** two consecutive rounds of "the
containment guard admits a path that resolves into the repo", each closed by adding resolution
for the spellings the last round demonstrated. The next round would find a fourth spelling.
Closing it needs the OUTCOME question (does this path land in this repository), not a fourth
comparison.

**I2. `--check` still turns an invisible ledger into "nothing to back up" at exit 0, one line
above the branch this commit fixed for exactly that reason.**
`bin/ledger-backup.sh:125`. Measured: `chmod 000 .claude/tasks` then `--check` prints
`ledger-backup: nothing to back up` and exits 0, so the Stop hook says nothing, forever, about a
ledger that exists and is not backed up. The unreadable-MTIME case one line below shouts that
"silence would be a lie" (`:126-129`); the unreadable-DIRECTORY case is the same undecidable
state and returns the all-clear. The comment at `:113-116` claims the two are "counted
separately on purpose", which is true of the case that was fixed and not of the one beside it.
Fix: before the `n_present -eq 0` line, `[ -d "$LEDGER_DIR" ] && [ ! -r "$LEDGER_DIR" ] && {
echo "ledger-backup: cannot read $LEDGER_DIR, so whether the backup is current cannot be
decided" >&2; exit 2; }`, and a case with `chmod 000` (skipped as root, like case 24).

**I3. The `git` kind has no publication guard at all, so the configuration that publishes the
ledger to the project's own public remote is one word away and nothing objects.**
`bin/ledger-backup.sh:222-280`. `ledger_backup: git origin internal-files` clones the project's
own `origin`, commits `internal-not-in-git/{todo,lessons}.md` and pushes. Existing case 2 proves
the push path works for any remote name, `origin` included. The harm is strictly larger than the
one the `dir` branch refuses (a copy in the work tree is at least local; this one reaches the
public remote), and it is the harm round 1 called C2 and the standing rule "the build ledger
never ships". Pre-existing, not introduced here, named because the invariant the new guard
asserts does not hold one branch over.
Fix, minimal and honest rather than clever: compare `git -C "$PROJECT_DIR" remote get-url
"$remote"` against the URL of the project's own publish remote and refuse with exit 2 when they
match; if the same-repo case must stay possible for a private repo, say so in the header and the
`/retro` table as a documented residual instead of leaving it silent.

**I4. The repo's own post-edit step was not run, so the feature is inert on the machine that
built it.** `CLAUDE.md` (Developing this repo): "After editing anything under `skills/`,
`agents/`, `bin/`, or `project-templates/`, re-run `./install.sh`". Measured: `~/bin/` holds 20
programs and NOT `ledger-backup.sh`, and `~/.claude-templates/CLAUDE.md` predates the whole
`ledger_backup:` section. Consequence: `session-end-check.sh`'s `[[ -x "$lb" ]]` is false
everywhere it is installed, so the check this branch exists to add does nothing in any real
project, and the template that teaches the line is not the one being scaffolded from.
Fix: `./install.sh`, then re-probe one scaffolded project end to end before merge.

### Nitpicks

- `tests/ledger-backup.test.sh:333-340`. The case-difference assertions are vacuous on a
  case-SENSITIVE filesystem: the directory simply does not exist, so `rc != 0` passes without
  the guard running. I confirmed they redden under the string-compare mutation on this machine
  (case-insensitive) only. On Linux CI a regression of that bypass stays green. Fix: probe the
  filesystem (`touch x; [ -e X ]`) and `SKIP` loudly when it is case-sensitive, so the silence
  is stated rather than counted as a pass.
- `bin/ledger-backup.sh:121-129` still has no test in its own suite. Round 2's nitpick was
  answered with a STUB inside `tests/session-end-check.test.sh:100-110`, which proves the hook
  reacts to exit 2 and never executes the program's branch that produces it. Fix: the five-line
  `date` shim on PATH, as round 2 described.
- `bin/ledger-backup.sh:208`. The trap does not re-raise, so SIGINT deletes the staging dir and
  the script CONTINUES (reproduced standalone: `kill -INT $$` under the same trap, script ran on
  to `exit 0`). Depending on when it lands, an interrupted run can finish at exit 0 with a stamp,
  or exit 4. Nothing is deleted that should not be, the destination files are already moved out,
  but a Ctrl-C should end the program. Fix: `trap 'rm -rf "$staging"; exit 130' INT TERM` plus
  the plain `EXIT` trap.
- `bin/ledger-backup.sh:205`. Still `$$`-named with no sweep, so the round-2 nitpick is half
  closed: the trap covers the interrupted-run case, and a SIGKILL, a power loss or a cross-host
  PID collision on a shared Dropbox target still leaves or deletes a full ledger copy. Fix:
  `mktemp -d "$dest/internal-not-in-git/.staging.XXXXXX"` and sweep `.staging.*` on entry.
- `tests/session-end-check.test.sh:100`. Matches `*ledger*|*backup*` against the hook's WHOLE
  output, which is the exact machine-dependence fixed this round in
  `tests/init-project.ledger.test.sh`. My run of the suite printed the hook's other arms in the
  captured output. Fix: same treatment, grep the ledger lines first.
- `bin/ledger-backup.sh:100`. `*'<'*'>'*` still false-positives on a real path such as
  `/tmp/a<b>c`, and the false positive lands on the SILENT exit 3. Much narrower than before.
  Fix: require a placeholder-shaped word, `*'<'[a-z][a-z-]*'>'*`.
- `bin/ledger-backup.sh:224`. `awk '{print $3}'` unfixed for the third round: `ledger_backup: git
  backup my branch` backs up to a branch named `my` at exit 0.
- `tests/ledger-backup.test.sh:148`. `d="$TMP/localwins"` still assigned and never used.
- `tests/ledger-backup.test.sh:311`. The new extractor also matches `exit 0` inside the comment
  at `bin/ledger-backup.sh:181`. Harmless (0 has a row) and the test comment says so; noted only
  so nobody "fixes" it by re-adding anchors.

### Still sound, re-probed rather than carried

- The `dir` branch is atomic where it claims to be: a failed run over an existing backup leaves
  the previous copy byte-intact and says `NOTHING was backed up` (measured).
- The parent-symlink, `..` and case-only bypasses round 2 measured are genuinely closed
  (measured, all three exit 2, nothing written, no stamp).
- A project reached through a symlinked path still refuses an in-project target (measured).
- The round-1 Criticals stay closed: the template's example lines do not read as configuration,
  and the scaffolded `.gitignore` covers the ledger. Neither was touched this round.
- The stale `bin/ledger-backup.sh` advice is swept completely: the only remaining hits are this
  repo's own `CLAUDE.local.md` (correct here) and `skills/retro/SKILL.md:43`, which labels it a
  repo fallback.
- The hook names an undecidable check UNKNOWN rather than as a lag, keeps exit 3 silent, and
  still exits 0 on every path.
- No em or en dashes, English comments, exec bits intact, no secrets, nothing `eval`ed, every
  config-derived value quoted.

## Scores

correctness 1/2, four of five round-2 Importants verified closed by my own mutations, including
the git branch's `cp`, whose removal reproduces the "already current" lie exactly as described.
Docked because the containment fix is a trade rather than a repair: it closes three shapes,
opens three, and one of those (a nested repo or submodule inside the project) was refused by the
code it replaced, which makes it a regression; and because `--check` still answers "nothing to
back up" at exit 0 for a ledger it cannot see. Not 0: nothing is reachable in a default project,
and no probe made the stamp claim a backup that did not happen.

security 1/2, hygiene unchanged and good (quoting, no `eval`, no force push, no network on the
hook path, no ledger content on stdout, stamp outside the work tree). Docked because ledger
content still reaches a git work tree at exit 0 under a success message by three measured paths,
one of them a work tree of the SAME repository where nothing ignores it, and because the `git`
kind will push the ledger to the project's own remote without a word.

performance 2/2, unchanged: two small file copies plus a rename, `--check` offline, the clone
still `--depth 1 --single-branch`. Two extra `git rev-parse` calls on the `dir` path, invisible.

readability 1/2, the new comments carry their reason at the point of use and the hook's exit-2
comment is exact. Docked for `:179-184`, which asserts in three sentences a property the code
does not have, on the third round of the recorded lesson that forbids exactly that.

testing 1/2, a genuine step up in discipline: every mutation claimed in the commit body
reproduces, and case 24 reproduces the failure it guards rather than the code shape. Docked
because the coverage again follows the fix instead of the risk: no case for the three shapes
that still pass, the case-difference pair is vacuous on a case-sensitive filesystem, and the
program's own unreadable-mtime branch is still never executed by any suite (the stub tests the
hook, not the branch).

conventions 1/2, the mutation-proof rule was followed this time and the stale-path sweep was
done across the whole tree. Docked because `./install.sh` was not re-run, which `CLAUDE.md`
requires and which leaves the feature inert in `~/bin` and `~/.claude-templates`, and because
`lessons.md` 2026-09-16 repeated for a third round on the same guard.

total 7/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 is still structurally reachable; nothing about this design caps it. What blocks full marks
today is one guard and one missing command: I1 needs the outcome question (resolved prefix plus
`--git-common-dir`) instead of a fourth spelling comparison, I2 is three lines, I3 is a URL
comparison or an honest paragraph, I4 is `./install.sh`. The remote-side residual is unchanged
from round 2: exits 4 and 5 are proven against local fixtures, and exit 0 against a real remote
by owner attestation I did not reproduce. That residual is worth stating, not scoring.

## What's good

- Every mutation the commit body claims, I ran, and every one reproduced, including one the
  report undercounted (8 reddened assertions, not 6). A build report whose evidence survives an
  adversary re-running it is rarer than it should be, and it is what let this round spend its
  attention on the shapes nobody had tested instead of on re-checking the claims.
- Case 24 is the right shape for a guard: it does not assert that a check exists, it makes the
  copy fail and pins the exit code and the sentence, and with the check removed it prints the
  exact false success ("already current") that the comment predicts.
- The hook's split between "behind" and "cannot decide" is the correct distinction and is worded
  so a user can act on it, and exit 3 still buys silence for people who never asked for a backup.
- The `dir` branch's staging really does keep its promise: a failed copy leaves the previous
  backup intact, so the exit-4 message is true rather than approximately true.
- The stale-path sweep was done across the entire tree this time, which is the 2026-08-10 lesson
  applied rather than quoted.

## History

- **Round 1** (`cebc0a0`, 2026-09-16): REQUEST CHANGES, 5/12
  (correctness 0, security 1, performance 2, readability 1, testing 1, conventions 0).
  C1: the template's example lines read as live configuration, so every scaffolded project
  shipped a placeholder target and the Stop hook nagged every session. C2: `init-project.sh`
  wrote no .gitignore entry for the ledger and then committed it. Importants: a relative `dir`
  target resolving against the caller's cwd and reporting success; `/retro` pointing at
  `bin/ledger-backup.sh`; no row for exit 2; no coverage of the steady-state clone-commit-push;
  `--check`'s mtime read failing open into silence.
- **Round 2** (`4558a32`, 2026-09-17): REQUEST CHANGES, 7/12. Regression note: **better.** Both
  Criticals verified closed against a real scaffold; correctness and conventions each up one.
  Five Importants, all one class (a guard or comment wider than its mechanism), three of them
  inside the round-1 fixes themselves.
- **Round 3** (`6f0ab87`, 2026-09-17): REQUEST CHANGES, 7/12. Regression note: **mixed, and the
  score not moving is the finding.** Four of the five Importants are closed and independently
  mutation-proven (hook exit 2, the exit-code extractor, the stale-path sweep, the git branch's
  unchecked `cp`), which is real progress no score records because the dimensions they sit in
  are still docked by the fifth. The containment guard did not converge: three shapes closed,
  three opened, one of them a regression against the string compare it replaced. That is two
  consecutive rounds of the same class, so `docs/eval-framework.md` stop condition 3 applies as
  well as the three-round cap. **Open for the human:** I1 (containment, with a regression), I2
  (invisible ledger reads as "nothing to back up"), I3 (the `git` kind can publish to the
  project's own remote), I4 (`./install.sh` not re-run, so the feature is inert as installed).
  No round 4 is dispatched; the branch stays blocked by the gate until a fix round is reviewed
  or the human accepts the residual deliberately.
