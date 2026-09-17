---
artifact: bin/ledger-backup.sh + tests/ledger-backup.test.sh + bin/session-end-check.sh ledger arm + tests/session-end-check.test.sh + skills/retro/SKILL.md step 5 + project-templates/CLAUDE.md ledger_backup field + docs/system-map.md entry + README counts
type: code
branch: feature/windows-powershell-entry
reviewed_commit: cebc0a0
artifact_version: 1
date: 2026-09-16
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 0, security: 1, performance: 2, readability: 1, testing: 1, conventions: 0 }
total: 5/12
verdict: REQUEST CHANGES
---

## Artifact

Commit `cebc0a0` on `feature/windows-powershell-entry`. A new program, its suite, a new arm in
the Stop hook plus that hook's first suite, the `/retro` step that calls it, the template field
that configures it, and the catalog entry. No plan exists in `docs/plans/` for this work, so
there is no contract to compare against; the design intent I reviewed against is the one stated
in the commit body and in the program header.

The core mechanism is right and I could not break it: the stamp is written only after a verified
success, `--check` is offline and reports BEHIND identically for "never ran" and "ran and
failed", failures are distinguishable by exit code, and no path force-pushes. The two Criticals
below are both at the SEAMS, where the program meets the project template and the scaffolder,
and both make the program report the opposite of the truth in the default configuration of every
project except this one.

## Verification (by measurement)

- `bash tests/ledger-backup.test.sh` -> `all 34 assertions passed`.
- `bash tests/session-end-check.test.sh` -> `all 12 assertions passed`, on a machine that had
  dev servers listening on :3998 and :3999, so the non-hermetic arms were live during the run.
- `bash bin/docs-claims-check.sh --assertions` -> 24 executables, 32 suites, 24 of 24 programs
  with their own suite, 932 assertions. Every countable claim matches the tree.
- Scaffolded a real project with `bin/init-project.sh` pointed at `project-templates/` via
  `CLAUDE_TEMPLATES_DIR`, i.e. the state after the mandatory `./install.sh`. Results in C1/C2.
- Probed by hand: relative `dir` target, `dir` target with spaces, `dir` target that is a symlink
  to a directory, dangling symlink, `$(...)` in the config value, branch name with a space,
  missing branch field, extra fields, steady state (existing branch plus changed ledger), a
  remote branch advanced by a third party between runs, deletion of a ledger file, and
  `date -r FILE` support.
- Em/en dash scan over the commit: clean.

## Findings

### Critical

**C1. The template's own example lines ARE valid configuration, so every scaffolded project is
"configured" with a placeholder, and the Stop hook nags forever.**
`project-templates/CLAUDE.md:89-90` writes two indented example lines. `bin/ledger-backup.sh:69`
matches `^[[:space:]]*ledger_backup:[[:space:]]*`, which matches them. `bin/init-project.sh:164`
copies the template verbatim; nothing in `/setup-project` touches this field (grep: zero
mentions). Measured on a project scaffolded from the repo template:

```
$ ledger-backup.sh <proj>          -> ledger-backup: this repo has no remote named '<remote-name>'   (exit 4)
$ ledger-backup.sh --check <proj>  -> ledger-backup: the ledger has NEVER been backed up ...         (exit 1)
$ ./bin/session-end-check.sh       -> session-end check:
                                        the ledger has NEVER been backed up (no stamp), ...
```

That is the exact outcome the design says exit 3 exists to prevent, in the DEFAULT state of every
new project: "a hook which nags every session for a state that is usually fine gets ignored, and
then so does the one warning that mattered". It also makes `/retro` report exit 4, "the target
was unreachable, so nothing was backed up", to a user who never asked for a backup. The silence
invariant is not merely weakened here, it is inverted for everyone except this repo, which is
configured through `CLAUDE.local.md` and therefore never sees it.
Fix, either one closes it, both are cheap and I would take both:
1. In `read_config`, a placeholder is not configuration. After the `sed`:
   `case "$v" in *'<'*|*'>'*) continue ;; esac`
2. In the template, move the two examples inside a fenced block or comment them
   (`# ledger_backup: git <remote-name> <branch>`) so they cannot match.
And add the test that makes it stay fixed: scaffold a project from `project-templates/CLAUDE.md`
verbatim, assert `ledger-backup.sh` exits 3 and `session-end-check.sh` prints nothing about the
ledger. Without that test, the next machine-read field added to the template repeats this.

**C2. "They are gitignored, so git does not carry them" is FALSE in every scaffolded project, and
the ledger is committed into the project's first commit.**
`bin/init-project.sh:208-245` writes a `.gitignore` that ignores `CLAUDE.local.md` but not
`.claude/tasks/todo.md` or `.claude/tasks/lessons.md`; lines 165-166 copy both files in, and the
scaffolder then runs `git add -A && git commit`. Measured on a scaffolded project:

```
$ git ls-files | grep tasks
.claude/tasks/lessons.md
.claude/tasks/todo.md
$ git check-ignore -v .claude/tasks/todo.md   -> NOT IGNORED
```

This commit is the first artifact to state the invariant out loud, and it states it as already
true, in five new places: `project-templates/CLAUDE.md:84-85` ("gitignored so the build ledger
never reaches a published snapshot, which also means git does not carry them: this line is the
only thing that does"), `bin/session-end-check.sh:58`, `skills/retro/SKILL.md:36-37`,
`bin/ledger-backup.sh:5-8`, `docs/system-map.md:145`. Two harms, not one: the program's stated
reason for existing is false where it ships, and if a scaffolded project is ever pushed to a
public remote the ledger goes with it, while the text most likely to be read at that moment is
the template line telling the owner it cannot. That is this repo's own standing rule ("the build
ledger never ships; gitignored") asserted rather than enforced.
Fix: add `.claude/tasks/todo.md` and `.claude/tasks/lessons.md` to the heredoc in
`init-project.sh`, decide explicitly whether the seeded copies should be committed at all, and
add an assertion to the init-project suite that `git check-ignore` succeeds for both in a fresh
scaffold. If the intended answer is the opposite, that scaffolded projects DO track their ledger,
then all five sentences must be narrowed to "in this repo" and the program's rationale changes
with them.

### Important

**I1. A relative `dir` target resolves against the CALLER's cwd, not the project, and reports
success.**
`bin/ledger-backup.sh:127-142`. Measured with `ledger_backup: dir backupdir`, invoked from
`$T/elsewhere` against `$T/proj`:

```
ledger-backup: refreshed (todo.md -> backupdir/internal-not-in-git/)   (exit 0, stamp written)
-> $T/elsewhere/backupdir/internal-not-in-git/todo.md
```

Two consequences. First, this is the same lie the `dir` branch explicitly refuses for a mistyped
ABSOLUTE path at lines 130-133 ("backing up into a folder nobody syncs reads as success and
protects nothing"), left open for the relative case, and the stamp then makes `--check` say "up
to date". Second, run from the project root (which is what `/retro` instructs), it writes the
ledger INTO the work tree, where nothing gitignores `backupdir/`: the program puts the content it
exists to keep out of git into git. Note this is the one path in the code itself that can leak
the ledger's content, independently of C2.
Fix: after `~` expansion, require an absolute path, and refuse a destination inside
`$PROJECT_DIR`:
```sh
case "$dest" in /*) ;; *) echo "ledger-backup: 'dir' needs an absolute path (got '$dest')" >&2; exit 2 ;; esac
case "$dest/" in "$PROJECT_DIR"/*) echo "ledger-backup: the target is inside the project; a copy in the work tree is not a backup" >&2; exit 2 ;; esac
```
plus a case in the suite planting a relative target and asserting exit 2 with nothing written.

**I2. `/retro` tells the agent to run a path that does not exist in any project but this one.**
`skills/retro/SKILL.md:40` says `bin/ledger-backup.sh          # from the project root`, and the
two worked examples at lines 74 and 80 repeat it. `install.sh:96-108` installs every program in
`bin/` into `~/bin/`, and `project-templates/` ships no `bin/`. So in a scaffolded project the
command is `command not found` and the step that this whole commit exists to make reliable cannot
run. Every other skill in the repo states the convention correctly, for example
`skills/prototype/SKILL.md:58`: "it is installed in `~/bin`, on PATH; repo fallback
`bin/privacy-scan.sh`". The harm is bounded by the step's own rule ("Never report a backup you
did not see exit 0"), so it fails loudly rather than falsely, but it fails.
Fix: use `ledger-backup.sh` with the repo fallback named, in the same words the prototype and
second-opinion skills already use, and update both example prompts.

**I3. The exit-code table omits 2, which is the code a config typo actually produces.**
`skills/retro/SKILL.md:44-52` documents 0, 3, 4, 5, 6 under the rule "Report the result by its
exit code, never by assumption", and exit 2 is reachable from three ordinary mistakes. Measured:
`ledger_backup: github ivan/x` -> 2; `ledger_backup: git backup` (no branch) -> 2; running outside
a work tree -> 2. Exit 2 and exit 3 both mean "nothing was written", which is precisely why an
agent with no row for 2 is likely to read it as the silent case.
Fix: add a row for 2 ("the `ledger_backup:` line is malformed or this is not a git work tree;
show the message and offer to fix the line, do not treat it as 'not configured'") and say that 1
belongs to `--check` only.

**I4. The steady-state path is never tested: an existing branch whose content changed.**
`tests/ledger-backup.test.sh`. Case 2 and case 9 create the branch through the ORPHAN path. Case
4 reaches the clone path but exits at "already current" before any push. So clone -> commit ->
push, the branch every run after the first takes and the only one that pushes from a `--depth 1`
shallow clone, has no coverage. I ran it by hand and it works (two commits on the branch, content
`v2-changed`, `--check` then up to date), so this is a coverage gap rather than a defect, but it
is the path a real remote is most likely to reject.
Fix: between the first backup and the second, change `todo.md` and assert both the remote content
and a commit count of 2; then advance the remote branch from a third clone and assert the next
run still succeeds by fast-forward (measured: it does, and the third party's file survives).

**I5. `--check`'s newest-mtime read fails OPEN, into silence.**
`bin/ledger-backup.sh:94-99`. `t="$(date -r "$LEDGER_DIR/$f" +%s 2>/dev/null || echo 0)"`. If the
mtime cannot be read, every file contributes 0, `newest` stays 0, and line 99 prints "nothing to
back up" and exits 0, so the Stop hook goes silent and `--check` reports fine forever. That is
the same silent-failure shape the program exists to eliminate, in the code that does the
eliminating. The stamp read at line 104 uses the identical idiom and fails CLOSED, so the
asymmetry is unintentional rather than a decision. `date -r FILE` works here and on GNU
coreutils, so this is latent, not live.
Fix: separate "no ledger files" from "could not read a timestamp". Count the present files first;
if any present file yields no timestamp, report behind (or exit 2) instead of nothing-to-back-up.

### Nitpicks

- `bin/ledger-backup.sh:145-146`. `awk '{print $3}'` silently truncates. Measured:
  `ledger_backup: git backup my branch` backs up to a branch literally named `my`, exit 0; a
  fourth field is ignored entirely. Reject a `git` line that does not have exactly three fields.
- Sub-second window: `stamp_now` runs after the copy, so an edit landing between the `cp` and the
  stamp in the same second makes `--check` report "up to date" for content that was not copied.
  The suite's two `sleep 1` calls show the shape is already understood. Record the newest ledger
  mtime BEFORE copying and `touch -d` the stamp to it, and the window closes.
- `--check` cannot notice that a `dir` destination was deleted (the synced folder was removed):
  it compares mtimes only, so it says "up to date" until the next real run. Offline is the right
  trade for a Stop hook; say so on the `--check` line of the header, since it is the one way a
  configured backup can be broken and still report current.
- `tests/session-end-check.test.sh:55,99` match `*ledger*|*backup*` against the hook's WHOLE
  output, which also carries `pgrep` and `lsof` results from the developer's machine. During my
  run the output really did contain "dev server still listening: node on :3998"; a process or
  port whose name contains "backup" would flip case 1 red for reasons unrelated to the change.
  Anchor on the hook's own wording (`*NEVER*`, `*BEHIND*`, `gitignored`).
- `bin/session-end-check.sh:57` echoes `${lb_out#ledger-backup: }` verbatim. Safe today, but the
  stamp file holds `target: <config>`, and if the `--check` message ever grows the target a
  private backup URL is printed into every session transcript. Keep the hook's wording
  independent of the program's output.
- `tests/ledger-backup.test.sh:148`: `d="$TMP/localwins"` is assigned and never used.
- `tests/ledger-backup.test.sh:198-207` is titled "`--check` NEVER writes" but only checks the
  stamp; a `--check` that created `$LEDGER_DIR` or left a temp dir would pass. Snapshot the
  project tree around the call, the way `tests/install-ps1.test.sh` now does.

### Explicitly probed and found SOUND

Recording these so the next round does not re-litigate them:

- **No force push, and the orphan path cannot clobber.** Neither push uses `--force`. I advanced
  the remote branch from a third clone between runs; the next backup cloned the new tip,
  committed on top, and fast-forwarded, leaving the third party's file intact. A branch created
  between `ls-remote` and the orphan push would be rejected as non-fast-forward, which is exit 5,
  the loud path.
- **No injection.** `ledger_backup: dir /tmp/$(touch .../PWNED)/x` produced exit 4 and no file.
  Every config-derived value is quoted at every use, and nothing is `eval`ed.
- **Spaces and symlinks in a `dir` target.** A path containing spaces works; a symlink to a
  directory is followed and written through; a dangling symlink exits 4.
- **`--check` touches no network and is cheap.** The check block at lines 92-115 precedes the
  `case "$KIND"` entirely, so a `git` target performs no remote operation. About eight processes
  per session end.
- **No ledger CONTENT reaches stdout.** The program prints file names, the destination path and
  the remote/branch, never file contents; the stamp lives inside `$GIT_DIR` and cannot be
  committed. The only content-exposure paths are C2 and I1.
- **Deletions are not mirrored destructively.** Deleting `lessons.md` locally left it on the
  backup branch, because `$work` is a fresh clone and `present` only drives copies.

### Residual, stated rather than scored

The git path has only ever run against a local bare repo. "Push refused" is simulated with a
`pre-receive` hook, and expired credentials, branch protection and a diverged remote with a real
auth layer have never been exercised. Neither Critical depends on that gap (both reproduce
locally), so it does not change the verdict, but it does mean exit 4 and exit 5 are proven for
shape, not for cause, and that a shallow `--depth 1` push has never met a server that refuses
one. The owner has also not yet been asked whether this may push to his private backup repo; that
permission should be obtained before `/retro` starts reporting exit 0 as truth on a real remote.

## Scores

correctness 0/2 - C1 inverts the program's own load-bearing behavior rule (silent when nothing is
configured) in the default state of every scaffolded project, measured end to end. I1 makes a
misconfigured run report success and stamp it, which is the failure class the program was written
to eliminate. I5 turns a failed timestamp read into permanent silence. I2 makes the calling step
unable to run at all outside this repo. The logic inside each branch is careful and correct; what
is wrong is what the program believes about its environment.

security 1/2 - genuinely good hygiene: no injection under a hostile config value, everything
quoted, nothing `eval`ed, no force push and a verified fast-forward-only story, no network on the
Stop hook path, no content in stdout, the private target kept in a gitignored file read before
the public one, and the stamp placed where it cannot be committed. Docked for I1, the one path in
this code that writes ledger content into a git work tree, silently and with a success message.
C2's exposure is scored under conventions because the missing gitignore line lives outside this
diff and what this diff contributes is the claim that the protection exists.

performance 2/2 - `--check` is offline by construction and costs about eight processes; the
network work sits behind the `--check` early return; `--depth 1 --single-branch` is the right
clone for this job; no loop is quadratic and nothing is unbounded.

readability 1/2 - the prose is the best thing here: every non-obvious decision carries its reason
at the point of use (why the stamp is in the git dir, why `CLAUDE.local.md` is read first, why a
mistyped directory is refused, why exit 3 stays silent), functions are small and named for what
they do, and the exit-code table sits at the top of the file where a caller looks. Docked because
five of those sentences state a protective property that does not hold where the code ships (C2),
and the `/retro` table that the skill's own rule points at is missing a reachable code (I3).

testing 1/2 - a strong suite by this repo's standards: hermetic, 34 plus 12 assertions, canaries
on the invariant that matters (no stamp after a refused push), mutation-proven with the failure
counts written into the commit, and it gives the Stop hook its first coverage. Docked for what it
does not reach: no case runs the program against a project scaffolded from the template, which is
the single test that would have caught C1; the steady-state clone-then-push path is untested
(I4); a relative `dir` target is untested (I1); and the "`--check` never writes" case checks only
the stamp. Two of the three claims in the header ("every failure is distinguishable", "a failure
never leaves a stamp") are well covered; the third, that the whole thing stays quiet when nothing
is configured, is covered only for a project the test itself configured.

conventions 0/2 - C2 puts this at zero: the repo's own standing rule is that the build ledger
never ships and is gitignored, and this commit asserts that property in five places while the
scaffolder it ships with tracks and commits both files. It is also the recurring lesson from
`lessons.md` (2026-09-16, "name above a guard only what the guard actually covers") one level up,
applied to a claim about the environment rather than about a guard. Everything else conforms: no
em or en dashes, English comments, the exec bit set, the header shape matching
`session-end-check.sh`, and every countable README claim verified against the tree.

total 5/12 (threshold >= 9, no zero) -> REQUEST CHANGES.

## Ceiling

12/12 is reachable, and the distance is smaller than the score suggests. C1 is two lines plus one
test. C2 is two lines in a heredoc plus one assertion, or a decision to narrow five sentences. I1,
I3 and I5 are a few lines each, I2 is a wording change, and I4 is one more test case. Nothing
here is structural: the program's mechanism, which is the hard part, is sound and I could not
make the stamp lie by any path except I1's. The real-remote gap is a residual to state, not a cap.

## What's good

- The mechanism is correctly chosen. Making `--check` compare the stamp to the LEDGER FILES,
  rather than to "did someone run the command", is what makes a backup that silently stopped
  working indistinguishable from one that never ran, and that is the failure a habit cannot
  notice. It works: the refused-push case leaves no stamp, and `--check` keeps saying behind.
- Ordering the stamp after the push, and writing down at the point of the failure branch WHY
  ("the copy exists locally, in a temp dir about to be deleted"), is the difference between a
  program that reports and one that reassures.
- Probing the remote branch with `ls-remote` before deciding between clone and orphan, instead of
  inferring it from a clone failure that also means "offline" and "no access", is the right call
  and is exactly why exits 4 and 5 can be told apart at all.
- "Already current" moving the stamp is a small decision with a good reason attached: without it
  a quiet week accumulates into a warning that trains the user to ignore the one that matters.
- The `session-end-check.sh` suite leads with the two invariants rather than with the output
  (always exit 0, silent when there is nothing to say), and case 4 proves the first one by
  replacing the called program with `exit 99`. That is the right level to assert a hook at.
- The commit body reports failure counts per mutation rather than claiming coverage, and every
  countable claim in it checks out against `docs-claims-check.sh`.
