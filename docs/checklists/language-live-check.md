# Live check: generated prose follows the output language

## Purpose

AC1 of USR-005 ("with the effective language German, a newly generated PRD, memo, or
plan body is in German") and the prose half of AC3 describe behavior that only exists
when an agent RUNS. No script in this repository can assert that a body is German: the
language detector is USR-006 and is deliberately out of scope here. So this procedure
is the proof, and a human reading the result is the verdict.

Two deterministic layers already exist, and it matters what each one does and does not
prove:

- `scripts/skills-lint.sh` invariant C13 proves the WIRING is present: the five
  prose-generating skills, `skills/build/SKILL.md` and every agent definition each carry
  the token `output_language` and the pointer `Guardrails 7`. It proves the cause is in
  place. It proves nothing about the output.
- `tests/localized-prose.test.sh` proves the RESOLUTION (a non-English global default
  loses to this repo's `en` override, scope `en project` not `en default`) and proves the
  no-leak guard passes a generated-shaped German artifact and FIRES when a machine
  surface on it is mutated. It never reads prose.

Neither layer can close AC1. That is why this file exists, and why the builder reports
AC1 as "wiring proven, live check pending at the gate" and never as passed.

"Internal" for this file means stripped from the PUBLISHED snapshot. `install.sh:74-77`
still copies every `docs/checklists/*.md` into `~/.claude/odeo-docs/checklists/`
on a developer machine, exactly as it already does for `dogfood-protocol.md`.

## Preconditions

Do NOT use `ls -l` for any of the agent-file checks. `.claude/agents` is a symlinked
DIRECTORY, so `ls -l .claude/agents/architect.md` follows the link and prints an
ordinary file line with no arrow, identical whether the definition loaded is the live
repo file or a stale copy. It cannot answer the question it would be asked.

1. **The fixture resolves.** `bash scripts/language-status.sh tests/fixtures/language-de-project`
   prints exactly `de project`.

2. **Run FROM THIS REPO, the project-level definitions are LIVE.** Three commands,
   because each one catches something the others miss:
   - `git ls-files -s .claude/agents .claude/skills` prints two lines whose mode field is
     `120000`, git's mode for a symlink. A copied directory would list its files at
     `100644` instead. This reads the INDEX, so on its own it cannot see a symlink that
     was deleted and replaced with a real directory since the last `git add`.
   - `readlink .claude/agents` prints exactly `../agents`. On a real directory it prints
     nothing and exits 1. This reads the WORKTREE, which is what closes the gap above.
   - `stat -f '%i' .claude/agents/architect.md agents/architect.md` prints the SAME inode
     twice (BSD/macOS syntax; GNU is `stat -c '%i'`). This is the decisive check: two
     paths, one file, so there is no second version to go stale.
   When all three hold, a run started in this repo that loads the project-level
   definition exercises exactly the file Task 3 edited, and no `./install.sh` re-run is
   needed for it.

3. **Run from a DIFFERENT project with no project-level `.claude/agents`,** the
   user-level definition is what exists: `~/.claude/agents/architect.md`. `install.sh:35`
   copies by default (`cp -R`) and symlinks only under `--link`, and `install.sh:63-65`
   places each agent file that way, so that path is a SNAPSHOT that only a later
   `./install.sh` refreshes. Classify it:
   `test -L ~/.claude/agents/architect.md && echo symlink || echo copy`. `copy` means it
   can be stale relative to this branch.

4. **This procedure asserts NO precedence rule** between a project-level and a
   user-level definition, so verify EVERY definition the run could load rather than the
   one you assume wins. Two checks, because presence and identity are different
   questions and only the second is about wording.
   - **Presence.** For each of `.claude/agents/architect.md` and
     `~/.claude/agents/architect.md`, if the path EXISTS, `grep -c output_language <path>`
     prints 1 or more. A path that does not exist is SKIPPED, never a failure (from this
     repo the second may be absent; from another project the first is).
   - **Content identity, required for every USER-LEVEL path that exists.** The token
     cannot prove WORDING. `cmp -s ~/.claude/agents/architect.md agents/architect.md` and
     `cmp -s ~/.claude/skills/prd/SKILL.md skills/prd/SKILL.md` must each exit 0 for
     paths that exist. Byte equality is the right test because `install.sh` places both
     with an untransformed `cp -R` (`install.sh:31-36`, `:63-65` per agent, `:55-57` per
     skill directory), so a mismatch is never a formatting artifact. What a mismatch
     MEANS: the installed copy is a DIFFERENT VERSION of the very instruction under test.
     The likeliest route there is a copy refreshed after the wiring landed but BEFORE a
     later wording revision, which is exactly the loop this story defines for itself (an
     AC1 fail is remedied by a wording revision plus a fresh dispatch), so the copy still
     carries the token, passes the presence check, and the live run exercises superseded
     text while the report claims the current wording. `skills/prd/SKILL.md` is in this
     check because Procedure B runs `/prd` from a DIFFERENT project, where the user-level
     skill copy is the only definition loaded; without it, Procedure B is not
     attributable.

5. **If a path that exists fails EITHER check, STOP** and report which path failed which
   check. Then take exactly one of two recorded routes, never an improvised third.
   - **The pre-authorized refresh.** `./install.sh` is PRE-AUTHORIZED for this procedure,
     granted by the human at the gate on 2026-08-12, scoped to this one command in this
     one procedure. It overrides, here only, the standing rule that the builder never
     runs the installer unprompted, and it is an explicit authorization to write into
     `$HOME`. The reason is what makes it proportionate: a stale or divergent `$HOME` copy
     does not make the run unsafe, it makes the measurement unattributable, so refusing
     the refresh would protect nothing while degrading the only proof AC1 has. Run
     `./install.sh` from the repo root, re-run precondition 4, and RECORD in the run
     report that the installer ran, on what date, and which paths it brought into line.
     What it writes: `~/.claude-templates/`, `~/.claude/skills/`, `~/.claude/agents/`,
     `~/.claude/odeo-docs/` and `~/bin/*.sh` (`install.sh:41-86`); it never
     clobbers an existing `~/.claude/CLAUDE.md` (`install.sh:108-114`). One side effect to
     check and report if it occurs: if `~/.claude/CLAUDE.md` carries no
     `^output_language:` line yet, the non-interactive path writes `en` into it
     (`install.sh:125-144`, USR-003's ask-exactly-once behavior, not a regression), and
     that CHANGES the global default the reverse-direction step below depends on, so
     re-establish that default before running it.
   - **The recorded waiver.** The human may instead waive the user-level path in writing
     for a from-this-repo run. It is valid ONLY while precondition 2 holds, because that
     is what makes the user-level copy irrelevant to this run. Write it into the run
     report AS a waiver, naming who granted it and that precondition 2 held at the time.
     Never assume it and never infer it from silence. It cannot cover Procedure B, which
     loads the user-level skill copy by construction, so under a waiver Procedure B is
     not run rather than run and reported.
   Explicitly NOT a route: "just run the procedure from this repo" on its own. It is a
   no-op against the stop in exactly the case that raises it, since the stale
   `~/.claude/agents/architect.md` still exists, precondition 4 still fails on it, and
   Procedure B stays unattributable.

## Procedure A (required), AC1

From a session at the repo root, dispatch the `architect` agent with a prompt that:
- names the story `tests/fixtures/language-de-project/docs/stories/USR-901-login-timeout.md`
- names `tests/fixtures/language-de-project` as the TARGET PROJECT
- carries the line `output_language: de`

The fixture, not this repo, is the target project, and the handed line is authoritative
over anything the agent infers from its own working directory.

Expected: the returned plan's PROSE (Goal, Serves, design decisions, task descriptions,
risks) is GERMAN, while its frontmatter keys, `approved: no`, the `docs/plan-format.md`
field names and section headings, file paths, verify commands and commit messages are
ENGLISH.

The plan's H1 is settled here rather than left undeclared. `docs/plan-format.md:22` fixes
it as the literal `# Plan: <story id + name>`, so the `# Plan:` literal and the story ID
(`USR-901`) stay ENGLISH, because a heading that appears as a literal in a format doc
stays English. The rule that puts a localized title in an H1 governs the documents a
SKILL generates, a PRD or a story, whose H1 exists to carry a `title:` the guard forces
to ASCII; a plan has neither that field nor that need. Whether the story NAME inside the
H1 comes back translated is deliberately NOT a criterion: it is freshly composed prose
sitting inside a format literal, both readings are defensible, and this procedure must
not pass or fail a live run on it. Record what came back and move on.

The pass or fail is the human's read of the PROSE, recorded as an observation.

### Procedure A, second half: AC4 on genuinely generated output

Save the returned plan to a throwaway path OUTSIDE the repo, for example
`"$(mktemp -d)"/docs/plans/2026-08-12-usr-901-login-timeout.md`, then run:

```
bash scripts/language-guard.sh <that path> \
  --branch feature/usr-901-login-timeout \
  --commit "feat(auth): add a login timeout"
```

Expect exit 0 and `machine surfaces clean`. Do NOT commit the generated sample: it is
evidence, not a repo artifact.

### Diagnostic that decides nothing

Run the check over the saved sample and record its full field line in the
sample-evidence block of the run report. The sample lives OUTSIDE the repo, so the
project directory is named explicitly:

```
bash scripts/prose-language-check.sh tests/fixtures/language-de-project <that path>
```

It is a hint for a later reader, NOT a criterion, and neither outcome decides anything.
An `OK` does not confirm the human's read, and a `WARN` does not overturn it: a German
plan is exactly the accepted-noise case this check names, because its commit subjects and
verify lines are English by rule and can be a large share of a short prose region. Never
report a pass or a fail on its strength, and never place it where it reads as
corroboration of the verdict.

Why this replaced the byte count that used to sit here, and why it is still not a
criterion: the old recipe counted LINES CONTAINING a non-ASCII byte, which is not a
language measurement at all, so it could be wrong in both directions (correct German
prose can be entirely ASCII, correct English prose can carry non-ASCII). The new line
reports what the check actually measured, which is strictly more informative. A heuristic
still does not outrank a human reading the prose.

## Procedure B (optional), the PRD and memo wording of AC1

AC1 reads "PRD, memo, OR plan body", so Procedure A already satisfies it. For a deeper
spot-check: a human runs `/prd` inside a COPY of the fixture project and confirms the
body is German, the frontmatter `title:` is English and ASCII, the H1 carries the
localized title, and the filename slug is English. Requires precondition 4's content
identity on `~/.claude/skills/prd/SKILL.md`, since this runs from another project.

## Reverse direction, the prose half of AC3

Repeat Procedure A from THIS repo with `output_language: en` handed over and a German
GLOBAL default in place, and confirm the returned plan is English. This is what "the
public Odeo repo generates English even when the global default is German" means beyond
what the resolver already proves in `tests/localized-prose.test.sh`.

## Honesty and stop rules

An English body under a German setting is a FAIL of AC1, reported as a fail.

What a fail MEANS, decided in advance so nobody improvises it at the gate: it is a fail
of the WORDING shipped in Tasks 1 to 3, so the remedy is a wording revision plus a fresh
dispatch, NEVER a re-run of the same configuration hoping for a different sample. And
the merge WAITS on it. Note exactly why that is a human duty: gate B6 sits after
`code-reviewer` has already approved, and `merge-gate.sh` reads only the reviewer's
`verdict:` (`scripts/merge-gate.sh:206-218`), so nothing mechanical will refuse a merge on
this row. The human at the gate is the only stop.

Running the same configuration up to 3 times is allowed for ONE purpose, characterizing
non-determinism, and then EVERY outcome is reported with the count. Two German and one
English is a partial fail and still a fail. Discarding a fail and reporting the pass is
the specific dishonesty this rule exists to forbid.

Never report a pass obtained from a different configuration than the one written here.

The result goes into the gate report and, as an observation, into `code-reviewer`'s eval
record findings. It never becomes a deterministic test pass.

## Who runs it

The ORCHESTRATING session at gate B6, or the human. The `builder` agent holds no `Task`
tool (`agents/builder.md:4`), so it cannot dispatch a fresh agent: the builder's duty is
to report AC1 as "wiring proven, live check pending at the gate" and never as passed.
