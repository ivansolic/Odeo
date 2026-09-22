---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: b3b66f71606cedb13701b1875e1b2419ca572be3
artifact_version: 6
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines) at HEAD `b3b66f7`, read against
`docs/skill-authoring-standard.md` and its rubric. The skill file is byte-identical to round 5;
`b3b66f7` changed the program under it, so this round is again a row-by-row truth check of step
5's exit-code table against `bin/ledger-backup.sh` as it is at HEAD (all 503 lines, every
`exit N` site), plus `tests/ledger-backup.test.sh` (cases 21, 33, 34, 35-38),
`WORKFLOW.md:648-674`, `BEGINNERS-GUIDE.md:241,325-332,377-379`, `docs/system-map.md:102,145`.
Form only, no runtime behavior tested. Output language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Unchanged and unaffected by the program change. `:2` states what the
  user gets, both halves, and that the second half writes outside the repo: "routes each lesson
  to the right place ... then backs up the gitignored build ledger (todo.md, lessons.md) to
  wherever the project records, which writes OUTSIDE the repo", closing with when to run it ("Run
  before wrapping up a working session"). That is the standard's explicit-command form.
  `disable-model-invocation: true` is set, so lint C1 does not apply.
- structure **2**. Unchanged: 102 lines against the 500 limit, essence (`:6-7`), numbered process
  (`:9-71`), worked example (`:73-96`), safety rules (`:98-101`). No supporting files, so the
  one-level rule is trivially satisfied. Residual, not scoring: still no explicit "when NOT to",
  only the degenerate case at `:14`.
- worked example **2**. Re-verified against the program at THIS HEAD, not carried over. `:86`
  "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)"
  is `bin/ledger-backup.sh:495` rendered with `present="todo.md lessons.md" remote=backup
  branch=internal-files`, character for character; `:92` "PUSH REFUSED to backup/internal-files,
  so NOTHING was backed up." is `:490` verbatim. Both branches shown, and the failing one shows
  the hard part, what the agent SAYS afterwards (`:94-95`).
- precision **1**. Dropped from 2, for one finding: **the exit 2 row no longer covers every
  refusal the program can print.** `b3b66f7` rewrote the `git` arm's containment guard from one
  question into two (`:383-443`), and the first of them is a state the table does not describe.
  - **The gap.** `:433-439` refuses when the remote's resolved path and the project report the
    SAME git common dir, printing "ledger-backup: '$remote' IS this project's own repository
    ($url_real)." The skill's `:51` lists, for exit 2: a malformed line, a relative path, "a
    target inside **any** git repository (a directory, or a local backup remote sitting in
    someone's work tree)", the project's own publish remote, an unreadable ledger, and a caller
    outside a work tree. The new state is none of these. It is not containment: the case that
    makes the guard worth having is a SIBLING LINKED WORKTREE (`tests/ledger-backup.test.sh:747`,
    `$TMP/sib-$i`), which sits inside no repository by markers, so the parent walk at `:440` never
    fires and the row's "sitting in someone's work tree" does not describe it. It is not the
    publish remote either: that refusal is a different site (`:374-380`) with a different message,
    and a local remote named `backup` pointing at the project's own directory matches neither the
    publish name nor the publish URL. So an agent that hits this refusal must explain, from the
    table, a message the table does not contain. That is the same defect shape scored in round 4,
    one arm over: the program grew a state and the row did not.
  - **What the rewrite got right and the row does still cover.** `file://` and relative spellings
    are now resolved to paths (`:416-422`) instead of slipping past a directory test, and a bare
    repository sitting inside the work tree still lands on `in_work_tree`/`refuse_in_repo`
    (`:440-442`, `:250-272`), which is exactly the row's "a local backup remote sitting in
    someone's work tree" (pinned by cases 35 and 37/`bare-inside`). The legitimate case a
    shape-based rule would have killed, an ordinary clone elsewhere on disk, is still allowed
    (`:409`, case 38), so nothing in the row over-refuses.
  - **The other two changes named at dispatch carry no disclosure duty, and their absence is not
    part of this finding.** The `GIT_CONFIG_*` additions (`:69-77`) produce no exit code, no
    message and no changed outcome for any state the table describes; they remove a measured
    push redirection (`:70-74`). The local rename `GIT_DIR` -> `PROJECT_GIT_DIR` (`:96-101`) is
    invisible to any caller. Both belong where they are, in the script header and the catalog row.
  - **New exit 4 site, non-blocking.** `:425` "cannot resolve the remote path $local_path" is
    reachable when the path exists but cannot be entered. The row's "an unreachable or unreadable
    remote" covers it well enough to be honest; no fix required.
  - Rows re-verified and still true at this HEAD: exit 0 (`:335`, `:495`), exit 2's remaining
    listed states (`:102` caller outside a work tree, `:111-115` unreadable ledger directory,
    `:278`/`:285` malformed and relative, `:341` missing branch, `:374-380` publish remote,
    `:499` unknown kind), exit 3 both causes (`:140`, `:158`), exit 4's staging claim (`:327` vs
    `:331`, and on the `git` arm `:470`/`:473` writing only into a temp clone destroyed by the
    trap at `:446`), exit 5 (`:490`), exit 6 (`:205`), "no stamp is written" (`stamp_now` only at
    `:334`, `:479`, `:494`), and `:57`'s "Exit 1 belongs to `--check` only" (exit 1 only at `:186`
    and `:198`). The public-remote residual at `:59-62` still matches `:359-362`.
- safety integration **2**. Unchanged and still accurate. The honesty rule sits at the point of
  use in the step's own voice (`:64` "Never report a backup you did not see exit 0"; `:54` "do not
  close the session claiming a backup"), consent discipline is preserved (`:30` "Do not write
  anything until they approve", `:52` "Take a no and do not raise it again this session"), and the
  private-target clause names `CLAUDE.local.md` and why. No guardrail is restated or weakened. The
  `git` arm still pushes from a fresh temp clone (`:445-462`) carrying none of this repo's hooks,
  so no collision with `bin/install-git-guards.sh`, and the environment drop at `:75-77` now
  removes the push-redirection hazard as well as the index one, which strengthens rather than
  disturbs this criterion.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10. Nothing structurally caps a criterion: explicit command (trigger clarity can be 2), real
guardrails in range (safety integration can be 2). The single point lost is a closable gap, one
clause in one row.

## Is any row now incomplete?
Yes, one: **exit 2**. It is incomplete, not wrong. Everything it lists is still a real exit 2
state; it is missing the identity refusal added in `b3b66f7` (`:433-439`). Every other row in the
table is complete and true at this HEAD.

## The surrounding documents, re-checked against the program at HEAD
- `docs/system-map.md:145`. **Two sentences are now stale**, both flagged at dispatch and both
  confirmed:
  1. "Two refusals carry the design: no target may sit inside **any** git repository (asked of
     the resolved landing directory on the `dir` arm and of a local remote's parent on the `git`
     arm ...), and a git target may not be the project's publish remote". There are now THREE, and
     the missing one is the one that refuses a linked worktree and the project itself.
  2. "Containment is decided by repository MARKERS ON DISK, never by git's message". Half true
     at this HEAD: the location question is still decided by markers (`:250-260`), but the new
     identity question is decided by asking git for the common dir (`:429-432`). That is not
     message parsing, which is what the sentence was written to rule out, but the sentence as
     written now claims more than the program does.
  3. The environment-drop clause ("The whole git environment (`GIT_DIR`, `GIT_INDEX_FILE` and
     family) is dropped at startup, so a run from a hook answers about the project it was given
     and cannot corrupt the caller's index") is literally true but names only the first of the two
     kinds the program now distinguishes (`:69-74`): variables that NAME a repository, and the
     `GIT_CONFIG_*` family that REWRITES one. The measured redirection (the ledger arriving at an
     injected remote at exit 0 with the stamp written) is not in the row's consequence clause.
- `docs/system-map.md:102`. Accurate and unaffected: names the backup, the two files, the
  `ledger_backup:` target, outside the repo, and reporting by exit code.
- `WORKFLOW.md:648-674`. Still true and undisturbed. `CLAUDE.local.md` first
  (`bin/ledger-backup.sh:125`); "in both cases **outside this repository**" holds on both arms and
  is now enforced against more spellings; "the 'last backup' stamp is written only after a
  verified success" matches the three `stamp_now` sites; `:673`'s warning agrees with
  `disable-model-invocation: true`. Quotes no exit codes, so it has nothing to drift.
- `BEGINNERS-GUIDE.md`, all three places. Still accurate and correctly free of exit codes for a
  beginner surface: step table row 11 (`:241`), the lessons section (`:325-332`, "If you haven't
  set one, Claude tells you once and offers to add the line", the exit 3 contract including the
  once), quick guide step 12 (`:377-379`).

## Map duty
Satisfied as a duty: no new command surface, `/retro` is at `docs/system-map.md:102` and
`ledger-backup.sh` has its own row at `:145`. The row's accuracy findings above are separate and
non-blocking for this skill's score.

## Lint
Clean by inspection for the checks that apply: C5 (`bin/ledger-backup.sh` exists), C7 (no em or en
dash in the skill), C9 (non-empty description), C11 (no version-pinned model name). C1, C3, C10
and C13 do not apply.

## Integrity
No sign of text copied from another project. Voice, terminology and every reference are this
system's own.

## Top fixes
1. **Add the identity refusal to the exit 2 row** (the finding; one clause). `:51`, after "a
   target inside **any** git repository (a directory, or a local backup remote sitting in
   someone's work tree)", insert: ", a remote that IS this project's own repository (the project
   directory itself, or a linked worktree of it, which shares the object store however the URL is
   spelled)". Nothing else in the row needs touching; the existing "Show the message" guidance
   then lands on a state the reader recognises.
2. **Fix `docs/system-map.md:145`**: say "Three refusals carry the design", add the identity one
   ("a git target may not BE this repository, compared by git common dir, which is what refuses a
   linked worktree"), soften the containment sentence to "Location is decided by repository
   MARKERS ON DISK, never by git's message", and extend the environment clause with the second
   kind ("... and the `GIT_CONFIG_*` family, which rewrites where a push goes").
3. **Say the backup out loud in step 6** (open since round 3, still the most useful non-required
   edit). `:70` -> "Briefly confirm what was written and where, including the backup result from
   step 5 (its exit code decides what you may claim)."
4. **Name the exit 0 variant the row does not mention.** `:48`'s "where the copy went (the script
   prints it)" covers `:335`/`:495`, but not `already current ($remote/$branch)` (`:480`).
   Suggested: "where the copy went, or that it was already current (the script prints which)."
5. **Tighten "an unreadable ledger" in the exit 2 row to the directory.** An unreadable ledger
   FILE fails later, in the copy, at exit 4 (`:327`/`:473`); it is the unreadable DIRECTORY that
   is refused at exit 2 (`:111-115`).

## The drift mechanism, second time of asking
Round 5 proposed extending `tests/ledger-backup.test.sh` case 21 from per-CODE to per-STATE. It
was not built, and this round is the evidence for it. **I still recommend it, and I now raise it
from a design option to the highest-value item after fix 1.** Reasons, kept to what is measured
here:
- Case 21 (`:295-319`) checks that each reachable code has a `| N |` row, and case 33
  (`:633-646`) does the same for the script header. Both pass unchanged through this regression,
  for the second consecutive time, because a row's PRESENCE is mechanical and its TRUTH is not.
  Case 33's own comment says so.
- A per-state assertion would have failed this commit: the new message's distinguishing phrase
  (`IS this project's own repository`) appears nowhere in `skills/retro/SKILL.md`. The shape is a
  dozen lines: for each `exit N` site, require a keyword from that site's message (`no remote
  named`, `not a git work tree`, `inside a git repository`, `own repository`, `cannot be read`,
  `copy is incomplete`) to appear in row N, in both the header and the skill.
- Stated residual, so a green run is not read as more: it still cannot tell whether the guidance
  sentence around the keyword is good advice, and it will need a keyword list maintained next to
  the messages. That is cheaper than a third reviewer round finding the same shape.
- Still recommended AGAINST: generating the skill's rows from the script header. Generation makes
  the two texts agree without making either true, and the two have different jobs (a caller
  contract versus what an agent SAYS to a human). Two independently written texts are what made
  rounds 3, 4 and 6 findable.

## Behavioral confirmation still owed
Form only. What remains is behavioral and belongs to an `/improve` subagent test: (a) exit 5, does
the close-out claim a backup; (b) exit 3 twice in one session, does the offer stay quiet the
second time; (c) the `:14` early stop, is the backup still attempted; (d) exit 2 from a
placeholder-shaped typo, does the agent offer to fix the line instead of reading it as "not
configured"; (e) exit 2 from a local backup remote inside a work tree, does the agent explain
containment and propose a target outside every repository rather than retrying; (f) **new**: exit
2 from a remote that is a linked worktree of this project, does the agent explain a shared object
store or does it improvise, and does the answer change once fix 1 is applied.

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
  for a repository marker, so "a repository git cannot read" was no longer an undecidable state
  while the skill's exit 2 row still listed it as one; the same row omitted two exit 2 states the
  rewritten header named, and round 3's two exit 4 findings were untouched. Also recorded: the
  round-3 drift test passes unchanged through that regression, because it checks that each code
  has a row, not that the row is true, so single-sourcing was raised as an option for the humans.
- Round 5 (2026-09-18, Opus 5 [1M], strongest, `0125901`, same branch): 10/10 PASS. Scores
  2/2/2/2/2. Regenerated because HEAD moved past round 4's commit, not re-dated. What moved:
  precision 1 -> 2. The human rewrote the exit 2 row (the dead undecidable state removed, the
  containment case now naming both a directory and a local backup remote in someone's work tree,
  the caller-outside-a-work-tree case added with "where no line is at fault", and the offer to
  fix a line made conditional on the message naming one) and the exit 4 row (the missing remote
  named as a line to fix, and the failed COPY distinguished from a failure during the final
  MOVES), closing all three round-4 findings plus both carried from round 3;
  `docs/system-map.md:145` was rewritten and is now accurate about marker-based containment, both
  arms, the environment drop and the exit 4 label. What did not move: trigger clarity, structure,
  worked example and safety integration, all re-verified against the program at this HEAD (the
  worked example's two output lines are still verbatim `bin/ledger-backup.sh:440` and `:435`).
  New this round: the commit's two behaviour changes were judged for disclosure duty, the
  `git`-arm containment refusal is user-visible and IS disclosed in the exit 2 row, while the
  environment drop produces no observable state and correctly stays in the script header and the
  catalog row. Three optional polish items remain (step 6's close-out, the `already current`
  exit 0 variant, the unreadable-ledger-directory wording), none of them blocking. The
  single-sourcing option raised in round 4 is answered here: recommended AGAINST as generation,
  with a per-state keyword assertion in `tests/ledger-backup.test.sh` case 21 proposed instead.
- Round 6 (2026-09-22, Opus 5 [1M], strongest, `b3b66f7`, same branch): 9/10 PASS. Scores
  2/2/2/1/2. Regenerated because HEAD moved past round 5's commit, not re-dated. The skill file is
  byte-identical to round 5; `b3b66f7` changed `bin/ledger-backup.sh` underneath it again. What
  moved: precision 2 -> 1, for exactly one incomplete row. The `git` arm's containment guard
  became two questions, identity (same git common dir) and location (the parent walk), and the
  identity half prints a refusal the exit 2 row does not describe: "'<remote>' IS this project's
  own repository". Its headline case, a sibling linked worktree, is inside no repository by
  markers and is not the publish remote, so neither of the row's existing clauses reaches it. What
  did not move: trigger clarity, structure, worked example and safety integration, all re-verified
  against the program at this HEAD (the worked example's two lines are now verbatim
  `bin/ledger-backup.sh:495` and `:490`). Judged and found to owe no disclosure: the `GIT_CONFIG_*`
  additions to the environment drop (no exit code, no message, no changed state) and the
  `GIT_DIR` -> `PROJECT_GIT_DIR` local rename. New findings outside the skill:
  `docs/system-map.md:145`, rewritten last commit, is now stale in three places (it says "Two
  refusals" where there are three, claims containment is decided by markers alone where identity
  is decided by git's common dir, and its environment clause names only the naming family, not the
  config-rewriting one). The round-5 drift proposal (case 21 per-state rather than per-code) was
  not built, case 21 and case 33 both passed through this regression unchanged, and it is
  re-recommended here at higher priority with the concrete keyword it would have caught.
