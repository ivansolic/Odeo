---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 994ede8fb51522f7b6896bf7e3e07e2843892baf
artifact_version: 4
date: 2026-09-17
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines, unchanged since round 3) at HEAD `994ede8`,
read against `docs/skill-authoring-standard.md` and its rubric. The file did not move; the
program underneath it did, so this round is mainly a truth check of step 5's exit-code table
against `bin/ledger-backup.sh` as it is at HEAD (all 407 lines, row by row), plus
`tests/ledger-backup.test.sh` (cases 21, 30, 31, 32, 33), `WORKFLOW.md:648-674`,
`BEGINNERS-GUIDE.md:241,315-332,377-379`, `docs/system-map.md:102,145`. Form only, no runtime
behavior tested. Output language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Unchanged and unaffected by `994ede8`. The description (`:2`) still
  states what the user gets, both halves, and that the second half writes outside the repo:
  "routes each lesson to the right place ... then backs up the gitignored build ledger (todo.md,
  lessons.md) to wherever the project records, which writes OUTSIDE the repo", closing with the
  moment to run it ("Run before wrapping up a working session"). That is the standard's
  explicit-command form. `disable-model-invocation: true` is set, so lint C1 does not apply.
- structure **2**. Unchanged. Essence (`:6-7`), numbered process (`:9-71`), worked example
  (`:73-96`), close-out (`:69-71`), safety rules (`:98-101`). 102 lines against the 500 limit, no
  supporting files, so the one-level rule is trivially satisfied. The backup keeps its own
  numbered step between `## 4. Apply` and `## 6. Close out`, still the only correct placement.
  Residual, not scoring: no explicit "when NOT to", only the degenerate case at `:14`.
- worked example **2**. Re-verified against the program at THIS HEAD, not carried over. `:86`
  "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)"
  is `bin/ledger-backup.sh:400` rendered with `remote=backup branch=internal-files`, character
  for character; `:92` "PUSH REFUSED to backup/internal-files, so NOTHING was backed up." is
  `:395` verbatim. Both branches shown, and the failing one shows the hard part, what the agent
  SAYS afterwards (`:94-95`). Directly imitable.
- precision **1**. Down from 2. The paths, the command, the field name and the file precedence
  are all still exact; the exit-code table, which is the operative contract of step 5, no longer
  tells the truth about the program at HEAD in three places, one of them newly false.
  - **`:51` names a state that no longer exists.** The exit 2 row ends "or a state the program
    could not decide (an unreadable ledger, **a repository git cannot read**)". At HEAD the
    containment guard does not ask git and does not read its messages: `in_work_tree`
    (`bin/ledger-backup.sh:246-255`) walks ancestors for a repository marker, and
    `refuse_in_repo` (`:256-262`) prints "the target is inside a git repository". A repository
    git cannot read is therefore DECIDED now, and decided as containment, which the row already
    lists one clause earlier ("a target inside **any** git repository"). `tests/ledger-backup.test.sh:576-600`
    (case 30) pins exactly that. So the row files one state under two contradictory labels and
    teaches the agent to report "the program could not decide" about a refusal the program made
    flatly. The category itself survives (the unreadable ledger at `bin/ledger-backup.sh:79-83`
    is genuinely undecidable, as is the unreadable mtime at `:148-151`); only this member of it
    is gone. The script's own header was rewritten in the same commit and no longer lists it
    (`:32-35`), so the skill now contradicts the program's published contract.
  - **`:51` omits two reachable exit 2 states that the header names.** "usage" (`:57-58`, `:63`)
    and "the caller is not inside a git work tree" (`:70`). The second matters: the row opens
    "the `ledger_backup:` line is refused" and closes "**Do not read this as 'not configured'**:
    someone tried to set it up and the setup is broken". Run `/retro` in a directory that is not
    a git work tree and an agent following this row asserts a broken setup for a project that may
    have no `ledger_backup:` line at all. Not introduced by `994ede8` (the check predates it) and
    missed by round 3's site-by-site check; `994ede8` made it visible by enumerating the state in
    the header.
  - **The exit 4 row still labels a configuration error as unreachability.** `:53` reads "the
    target could not be used: unreachable remote, missing directory, a copy that failed", but
    `bin/ledger-backup.sh:310` returns 4 for "this repo has no remote named '$remote'", a line to
    fix rather than a target to retry. This was round 3's non-blocking finding 1; `994ede8` did
    not touch it, and `docs/system-map.md:145` carries the same "4 unreachable" shorthand.
  - **`:53`'s "this means the backup did not happen" is still one word stronger than the
    program** when the `dir` branch's move loop fails partway (`bin/ledger-backup.sh:298`, "could
    not place $f, the copy is incomplete"). Round 3 finding 2, also untouched.
  - Everything else in the table is accurate at HEAD: exit 0 (`:302`, `:400`), exit 3 both causes
    (`:108`, `:126`), exit 5 (`:397`), exit 6 (`:173`), and `:57`'s "Exit 1 belongs to `--check`
    only" matches exit 1 appearing only at `:154` and `:166`.
  - Worth naming, because it is the shape of this regression: the drift test at
    `tests/ledger-backup.test.sh:295-319` still PASSES. It derives the code set from the script
    and asserts a row per code; every code still has a row. A row's presence is mechanical,
    whether its sentence is still true is not, which is precisely what case 33's own comment says
    about the header (`:636-640`). The mechanism protects the table's shape, not its meaning.
- safety integration **2**. Unchanged and still accurate at HEAD. The honesty rule sits at the
  point of use in the step's own voice (`:64` "Never report a backup you did not see exit 0";
  `:54` "do not close the session claiming a backup"), consent discipline is preserved (`:52`
  "Take a no and do not raise it again this session"), and the private-target clause names
  `CLAUDE.local.md` and why. `:59-62`'s public-remote limit still matches the program: the
  script carries the same residual in its header (`:36-39`) and its git branch points back at
  this skill by name (`:329`, "and /retro's exit-2 row says so"). No guardrail is restated or
  weakened, and the git branch still pushes from a fresh temp clone (`:350-398`) carrying none of
  this repo's hooks, so no collision with `bin/install-git-guards.sh`.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, not reached this round. Nothing structurally caps a criterion: explicit command (trigger
clarity can be 2), real guardrails in range (safety integration can be 2). Precision returns to 2
when the three table corrections below are made.

## Wording that is now false or misleading
Listed separately from the scores because the dispatcher asked for it directly.
1. `skills/retro/SKILL.md:51`, "a state the program could not decide (an unreadable ledger, **a
   repository git cannot read**)". FALSE at HEAD for the second example. That state is now
   refused as containment, with the message "the target is inside a git repository".
2. `skills/retro/SKILL.md:51`, "the `ledger_backup:` line is refused ... someone tried to set it
   up and the setup is broken". MISLEADING for the two exit 2 states the row omits (usage, and
   the caller not being in a git work tree), where no line is at fault.
3. `skills/retro/SKILL.md:53`, "unreachable remote, missing directory, a copy that failed" and
   "this means the backup did not happen". Carried from round 3, both still inaccurate against
   `bin/ledger-backup.sh:310` and `:298` respectively.
4. `docs/system-map.md:145`, "It refuses rather than guesses whenever git cannot answer". STALE
   as a description of the containment guard, which at HEAD does not ask git at all; the sentence
   describes the design `994ede8` replaced. The policy it asserts (fail closed on ignorance) is
   still true of the unreadable ledger, so this is stale framing rather than a false promise, but
   it points a reader at a mechanism that is gone. Same row still carries the "4 unreachable"
   shorthand.

## The surrounding documents, re-checked against the program at HEAD
- `WORKFLOW.md:648-674`. Still matches, `994ede8` did not disturb any of its claims.
  `CLAUDE.local.md` is read first (`bin/ledger-backup.sh:93`); the target is outside the
  repository in both kinds (the `dir` invariant at `:197-280`, the publish-remote refusal at
  `:341-348`); "the 'last backup' stamp is written only after a verified success" matches
  `stamp_now` being called only at `:301`, `:384` and `:399`, never on the exit 4 or 5 paths. The
  warning at `:673` agrees with `disable-model-invocation: true`. It quotes no exit codes, so it
  has nothing to drift.
- `BEGINNERS-GUIDE.md`, all three places. Still matches: step table row 11 (`:241`), the lessons
  section (`:325-332`, "If you haven't set one, Claude tells you once and offers to add the
  line", which is the exit 3 contract including the once), quick guide step 12 (`:377-379`). No
  exit codes quoted, correct for the beginner surface.
- `docs/system-map.md:102`. Accurate and unaffected.
- `docs/system-map.md:145`. Two findings, items 3 and 4 above.
- `project-templates/CLAUDE.md:84-96`. Unchanged and still the reason the exit 3 row's
  placeholder clause exists.

## Map duty
Satisfied. No new command surface; `/retro` is at `docs/system-map.md:102` with the backup
clause, and `ledger-backup.sh` has its own row at `:145`. The `:145` defects above are accuracy
findings, not a missing-map failure.

## Lint
Clean by inspection for the checks that apply: C5 (`bin/ledger-backup.sh` exists), C7 (no em or
en dash), C9 (non-empty description), C11 (no version-pinned model name). C1, C3, C10 and C13 do
not apply.

## Integrity
No sign of text copied from another project. Voice, terminology and every reference are this
system's own.

## Top fixes
Not blocking the PASS, but fix 1 before this ships: it is the one sentence an agent would repeat
to a user as fact.
1. **Cut the dead state out of the exit 2 row.** In `:51`, replace "or a state the program could
   not decide (an unreadable ledger, a repository git cannot read)" with "or a state the program
   could not decide (an unreadable ledger). A repository git cannot read counts as **inside a
   repository**, not as undecidable: the guard walks the target's ancestors for a repository
   marker instead of asking git."
2. **Cover the two exit 2 states the row omits.** Add to `:51`: "It also covers a usage mistake
   and a project directory that is not a git work tree; in those the message names the cause and
   the `ledger_backup:` line is not at fault, so do not offer to fix a line."
3. **Split the configuration case out of the exit 4 row** (carried, unchanged). After "a copy
   that failed" in `:53`, add: "If the message says *no remote named X*, the `ledger_backup:`
   line names a remote this repo does not have: offer to fix the line or add the remote, do not
   treat it as a network problem." Then mirror it in `docs/system-map.md:145`.
4. **Soften the one word the program does not guarantee** (carried, unchanged). `:53`, "so this
   means the backup did not happen" -> "so the backup did not happen; if the message says the
   copy is incomplete, say that instead, some files may have landed".
5. **Refresh `docs/system-map.md:145`'s last sentence.** "It refuses rather than guesses whenever
   git cannot answer" -> "It refuses rather than guesses whenever a state cannot be decided (an
   unreadable ledger), and it decides containment on disk, from repository markers on the
   target's ancestors, never from git's wording."
6. **Make step 6 say the backup out loud** (carried from round 3, still open). `:70` -> "Briefly
   confirm what was written and where, including the backup result from step 5 (its exit code
   decides what you may claim)."

## The mechanism question this round raises
Round 3 closed the table's drift with `tests/ledger-backup.test.sh:295-319`, and that test did
its job and is not at fault: every code still has a row. What moved was the MEANING of a row,
which no grep-for-a-code can see. Per the standing rule that a recurring lesson needs a mechanism
rather than a fifth wording, the candidate is not more prose in the skill: it is to make the two
tables single-source, for example generating `/retro`'s rows from the script header's exit-code
block (or asserting the two texts agree state for state) so a header rewrite cannot leave the
skill behind. Recording it as a design option for the humans, not as a required fix, because it
is a build decision and outside a reviewer's remit.

## Behavioral confirmation still owed
Form only. Everything left is behavioral and belongs to an `/improve` subagent test, not a
review: (a) exit 5, does the close-out claim a backup; (b) exit 3 twice in one session, does the
offer stay quiet the second time; (c) the `:14` early stop, is the backup still attempted;
(d) exit 2 from a placeholder-shaped typo, does the agent offer to fix the line instead of
reading it as "not configured"; (e) NEW, exit 2 from a target inside an unreadable repository,
does the agent report containment or parrot "could not decide" (this case is what fix 1 exists
for, and it is worth re-running after the fix lands).

## History
- Round 1 (2026-09-16, Opus 5 [1M], strongest, `fab5c0d`, branch
  feature/windows-powershell-entry): 6/10 FAIL. Scores 1/2/1/1/1. First record for this skill.
  The pre-existing lesson-routing flow was sound; the new backup step failed on precision (no
  recorded-location convention existed to read), on its trigger (bound to lesson-writing, not to
  the session), on the missing failure branch, and on the missing example. Regenerated once,
  unchanged in scores or findings, after the dispatcher supplied the HEAD sha that was missing at
  first write.
- Round 2 (2026-09-16, Opus 5 [1M], strongest, `cebc0a0`, same branch): 8/10 PASS. Scores
  1/2/2/1/2. What moved: worked example 1 -> 2 (both branches shown, with the program's verbatim
  output), safety integration 1 -> 2 (honesty rule at the point of use, and the
  install-git-guards collision removed structurally by pushing from a temp clone). What did not
  move: precision stayed 1 (the table omitted reachable exit 2 and overstated exit 4) and trigger
  clarity stayed 1 for the same reason as round 1 (the description never mentioned the
  out-of-repo write). Seven fixes were required.
- Round 3 (2026-09-17, Opus 5 [1M], strongest, `2e7c740`, same branch): 10/10 PASS. Scores
  2/2/2/2/2. Regenerated because HEAD moved past round 2's commit, not re-dated. All seven
  required fixes are closed. What moved: trigger clarity 1 -> 2 (`:2` now names the backup, the
  two files, and the out-of-repo write, the finding that had survived two rounds) and precision
  1 -> 2 (exit 2 row added and verified site by site; exit 4's claim now rests on the staging
  mechanism; and the drift test derives the required row set from the script). What did not move:
  structure and worked example, both already at 2. New this round, non-blocking: the exit 4 row
  labels a missing-remote configuration error as unreachability (same shorthand in
  `docs/system-map.md:145`), and its "the backup did not happen" is one word stronger than the
  program's message when the `dir` move loop fails partway. Also new: WORKFLOW.md 3.5, the three
  BEGINNERS-GUIDE.md passages and both system-map rows were checked and agree.
- Round 4 (2026-09-17, Opus 5 [1M], strongest, `994ede8`, same branch): 9/10 PASS. Scores
  2/2/2/1/2. Regenerated because HEAD moved past round 3's commit, not re-dated. The skill file
  itself did not change; `994ede8` changed `bin/ledger-backup.sh` underneath it. What moved:
  precision 2 -> 1. The containment guard stopped parsing git's messages and now walks ancestors
  for a repository marker (`:246-255`, pinned by test cases 30-32), so "a repository git cannot
  read" is no longer an undecidable state, it is refused as inside a repository, and the skill's
  exit 2 row (`:51`) still lists it under "a state the program could not decide" while also
  listing the containment case one clause earlier. The same commit rewrote the script's header
  exit 2 row, which now names "usage" and "the caller is not inside a git work tree", two states
  the skill's row omits and whose framing ("someone tried to set it up and the setup is broken")
  would be false. Round 3's two non-blocking exit 4 findings are untouched and now count against
  the criterion together with the new one. What did not move: trigger clarity, structure, worked
  example and safety integration, all re-verified against the program at this HEAD (the worked
  example's two output lines are still verbatim `:400` and `:395`; the public-remote residual at
  `:59-62` still matches the script header and `:329`). Also recorded: the round-3 drift test
  passes unchanged through this regression, because it checks that each code has a row, not that
  the row is true, so the single-source option is raised for the humans.
