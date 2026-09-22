---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 5972c27
artifact_version: 7
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines, the only file in `skills/retro/`) at HEAD
`5972c27`, read against `docs/skill-authoring-standard.md` and its rubric. Method this round, as
instructed: a FULL CENSUS of `bin/ledger-backup.sh` (585 lines, every `exit N` site enumerated
from the file, not diffed against a description), then each site matched to a row. Also read
`tests/ledger-backup.test.sh` (cases 21, 33, 37, 42), `WORKFLOW.md:648-674`,
`BEGINNERS-GUIDE.md:241,325-332,377-379`, `docs/system-map.md:102,145`. Form only, no runtime
behavior tested. Output language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Unchanged and unaffected by the program change. `:2` states what the user
  gets, both halves, and that the second half writes outside the repo: "routes each lesson to the
  right place ... then backs up the gitignored build ledger (todo.md, lessons.md) to wherever the
  project records, which writes OUTSIDE the repo", closing with when to run it ("Run before
  wrapping up a working session"). That is the standard's explicit-command form.
  `disable-model-invocation: true` is set, so lint C1 does not apply.
- structure **2**. Unchanged: 102 lines against the 500 limit, essence (`:6-7`), numbered process
  (`:9-71`), worked example (`:73-96`), safety rules (`:98-101`). One file, so the one-level rule
  is trivially satisfied. Residual, not scoring: still no explicit "when NOT to", only the
  degenerate case at `:14`.
- worked example **2**. Re-verified against the program at THIS HEAD, not carried over; both line
  numbers moved this commit and both strings still match character for character. `:86`
  "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)" is
  `bin/ledger-backup.sh:578` rendered with `present="todo.md lessons.md" remote=backup
  branch=internal-files`; `:92` "PUSH REFUSED to backup/internal-files, so NOTHING was backed up."
  is `:573` verbatim. Both branches shown, and the failing one shows the hard part, what the agent
  SAYS afterwards (`:94-95`).
- precision **2**. Back to 2. **The exit 2 row now describes every refusal the program prints on a
  plain run, checked by census rather than by diff.** Details under "The census" below. The two
  states added at `:51` are exact against the code: the relative remote URL (`:443-448`) and the
  identity refusal (`:516-522`), the latter naming both shapes the guard's own comment names
  (`:461-467`, the project directory itself and a linked worktree sharing the object store).
  Five polish items stay open (top fixes 1-5); none of them is a state an agent would have to
  invent an explanation for, none makes the table say something the program does not do, and one
  of them (fix 1) I judged explicitly and chose not to score, with the reasoning stated there so
  the 2 is reproducible rather than generous.
- safety integration **2**. Unchanged and still accurate. The honesty rule sits at the point of
  use in the step's own voice (`:64` "Never report a backup you did not see exit 0"; `:54` "do not
  close the session claiming a backup"), consent discipline is preserved (`:30` "Do not write
  anything until they approve", `:52` "Take a no and do not raise it again this session"), and the
  private-target clause names `CLAUDE.local.md` and why. No guardrail is restated or weakened. The
  residual paragraph at `:59-62` still matches the program's own stated limit (`:488-490`,
  `:360-363`): the program cannot decide whether a remote is PUBLIC, and the skill says so in the
  same breath as the refusals, which is what keeps an agent from over-selling a green run. The
  `git` arm still pushes from a fresh temp clone (`:528-545`) carrying none of this repo's hooks,
  so no collision with `bin/install-git-guards.sh`.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion here: explicit command (trigger clarity can
be 2) and real guardrails in range (safety integration can be 2).

## The census: every exit site in the program, and the row that covers it
Enumerated from `bin/ledger-backup.sh` at this HEAD, not from the dispatch note.

**Exit 2, the question asked.** Fourteen sites reachable on a plain run:
- `:85` bad flag, `:86` two project dirs, `:91` no such project dir, `:95` unenterable project dir.
  Usage errors, unreachable from `/retro`'s invocation (`skills/retro/SKILL.md:43` runs the script
  with no arguments); the program's own header files them under "usage". Not a row's job.
- `:103` caller not in a git work tree -> covered, "a caller outside a git work tree, where no line
  is at fault".
- `:112-116` unreadable ledger DIRECTORY -> covered, "an unreadable ledger, which the program
  refuses rather than report as empty" (see fix 4 for the one-word tightening).
- `:279` `dir` with no path, `:342` `git` without both fields, `:582` unknown kind -> covered,
  "malformed (unknown kind, missing branch)".
- `:286-288` relative `dir` path -> covered, "a relative path".
- `:300` and `:313` `refuse_in_repo` on the `dir` arm, `:523-524` on the `git` arm -> covered, "a
  target inside **any** git repository (a directory, or a local backup remote sitting in someone's
  work tree)".
- `:427-431` publish remote, by name or normalised URL -> covered, "the project's own publish
  remote", with the normalisation and its limit at `:59-62`.
- `:443-448` **relative remote URL** -> NEW this commit, and NOW covered: "a relative path **or a
  relative remote URL**".
- `:516-522` **the remote IS this repository** (same git common dir) -> was the round-6 finding,
  and NOW covered: "a remote that **IS this project's own repository** (the project directory
  itself, or a linked worktree of it, which shares the object store however the URL is spelled)".
- `:184` unreadable mtime is exit 2 inside `--check` only; the table is for a plain run and `:57`
  says where `--check` lives.

So: **yes, every refusal the program prints is now described.** Four distinct refusal messages
live on the `git` arm at this HEAD (publish remote `:427`, relative URL `:444`, identity `:517`,
containment via `refuse_in_repo` `:524`), plus the malformed-line refusal `:342`, and the row
names all five.

**The other codes, re-verified at this HEAD.** Exit 0: `:337`, `:578`, and the `already current`
variant `:563` (fix 3). Exit 3: `:141` and `:159`, "the message says which" is true. Exit 4:
sixteen sites; the row's list ("no remote of that name" `:344`, "an unreachable or unreadable
remote" `:536`/`:508`, "a clone that failed" `:544`, "a missing directory" `:293`, "a copy that
failed" `:328`/`:556`) is the program's own header contract (`:43-46`) rendered faithfully, and
its staging claim holds: a failed COPY places nothing (`:327` into `$staging`, `:555` into the
temp clone), a failed MOVE says "the copy is incomplete" (`:332`). Three local-side exit 4 sites
are outside the row's head clause and are noted as fix 5, not as a defect (`:528` no temp dir,
`:539` git init failed, `:569` commit failed): the row's operative contract, show the message, the
backup is not current, no stamp, is true for all three. Exit 5: `:573`. Exit 6: `:206`. Exit 1
only at `:187` and `:199`, both inside the `--check` block, so `:57` is true. "No stamp is
written" holds: `stamp_now` (`:208`) is called only at `:335`, `:562`, `:577`, all after a
verified success.

## Is the new wording accurate? (the two questions asked at dispatch)
1. **"where it points depends on the directory the program was run from"** (`:51`): **true.** It
   is the program's own printed first sentence (`:445`) and it describes what this program
   actually does: it hands the raw URL to `git ls-remote` (`:534`) and `git clone` (`:543`) with
   no `-C`, so they resolve it against the caller's directory. The sharper half of the reason, in
   the program's second sentence and in `docs/system-map.md:145`, is the DISAGREEMENT (git inside
   the project would root it at the project, so the target checked is not the target written); the
   skill keeps the "cannot root it, so it is refused instead of guessed" half. True as written,
   improvable by one clause (fix 2).
2. **The identity clause** (`:51`): accurate on its two named shapes and on the mechanism (common
   dir, `:512-516`), and correctly explains the harm an agent must relay (`:518-519`, a branch
   inside the repository the ledger is kept out of). One adverb overclaims, see fix 1.

## `docs/system-map.md:145`, the three round-6 findings
All three are fixed, and the rewrite introduced nothing false that I can find.
1. "Three refusals carry the design" now enumerates containment, identity ("a local remote may not
   BE this repository, asked by git COMMON DIR, which is what refuses a linked worktree") and the
   publish remote. Correct. Note the count sentence says three while the row then names a fourth
   refusal in its own sentence ("a relative remote URL is refused outright"); the row is COMPLETE,
   the count is just a design framing. Optional: "Three invariants carry the design", or say four.
2. Location and identity are now separated exactly as the code separates them: "LOCATION is
   decided by repository MARKERS ON DISK, never by git's message" (`:251-261`) and "IDENTITY is
   the one question git itself is asked, because a shared object store is not visible on disk"
   (`:512-516`). Both true.
3. The environment clause now names both kinds and the measured consequence of the second ("the
   `GIT_CONFIG_*` ones that REWRITE it (a measured `insteadOf` redirection sent the ledger to an
   injected remote at exit 0)"), which matches `:70-78`. True.
Also checked in the rewrite and true: the shared conversion claim ("Both read the URL through ONE
shared conversion, after two conversions disagreed and pushed the ledger to the publish remote
spelled as a `file://` URL") matches `:364-371`; "asked of the resolved landing directory on the
`dir` arm and of a local remote's parent on the `git` arm" matches `:309-313` and `:523`;
"`--check` is what `session-end-check.sh` reads" matches an existing `bin/session-end-check.sh`.
Worth recording: the map row's identity sentence is bounded to "a local remote", which is tighter
and more accurate than the skill's unqualified "however the URL is spelled" (fix 1).

## The surrounding documents
- `docs/system-map.md:102`. Accurate and unaffected: names the backup, the two files, the
  `ledger_backup:` target, outside the repo, and reporting by exit code.
- `WORKFLOW.md:648-674`. Still true and undisturbed. `CLAUDE.local.md` first
  (`bin/ledger-backup.sh:126`); "in both cases **outside this repository**" holds on both arms and
  is now enforced against more spellings; "the 'last backup' stamp is written only after a
  verified success" matches the three `stamp_now` sites; `:673`'s warning agrees with
  `disable-model-invocation: true`. Quotes no exit codes, so it has nothing to drift.
- `BEGINNERS-GUIDE.md`, all three places, re-read and accurate, and correctly free of exit codes
  for a beginner surface: step table row 11 (`:241`), the lessons section (`:325-332`, including
  the exit 3 contract with its "tells you once"), quick guide step 12 (`:377-379`).

## Map duty
Satisfied: no new command surface this round, `/retro` is at `docs/system-map.md:102` and
`ledger-backup.sh` has its own row at `:145`, now accurate.

## Lint
Clean by inspection for the checks that apply: C5 (`bin/ledger-backup.sh` exists), C7 (no em or en
dash in the skill, grepped), C9 (non-empty description), C11 (no version-pinned model name). C1,
C3, C10 and C13 do not apply.

## Integrity
No sign of text copied from another project. Voice, terminology and every reference are this
system's own.

## Top fixes (all optional; none blocks the verdict)
1. **Bound the identity clause to local paths.** `:51` says the identity refusal catches the
   project "however the URL is spelled", but only a URL that converts to a local path reaches that
   question (`:505-506`); the program's own residual says so (`:486-488`, "A NON-LOCAL URL CANNOT
   BE CONTAINED"), and an `ssh://` spelling of this very repository is not caught. Suggested:
   "... which shares the object store however a local path is spelled (an ssh or https spelling of
   the same repository is not caught; only the publish-remote refusal covers those)". Not scored,
   for two stated reasons: the clause describes a refusal that FIRED rather than promising
   coverage, and the residual paragraph three lines below (`:59-62`) already tells the reader that
   ssh and https spellings are invisible to the program. `docs/system-map.md:145` already says
   "local remote"; this aligns the skill with the map.
2. **Add the disagreement half to the relative-URL reason.** `:51` -> "... (git would root it at
   the project, this program at the caller's directory, so the target checked is not the one git
   writes to)". That is `:434-439` and the map row's phrasing, and it is what lets an agent answer
   "then just fix it for me".
3. **Name the exit 0 variant** (open since round 5). `:48`'s "where the copy went (the script
   prints it)" covers `:337`/`:578` but not `already current ($remote/$branch)` (`:563`).
   Suggested: "where the copy went, or that it was already current (the script prints which)."
4. **Tighten "an unreadable ledger" to the directory** (open since round 6). An unreadable ledger
   FILE fails later, in the copy, at exit 4 (`:328`/`:556`); it is the unreadable DIRECTORY that is
   refused at exit 2 (`:112-116`).
5. **Soften the exit 4 head clause by one word.** "the target could not be used" is false for
   `:528` (no temp dir), `:539` (git init failed) and `:569` (commit failed), which are local-side.
   Suggested: "the backup could not be made: ..." with the existing list unchanged. The row's
   contract (show the message, not current, no stamp) is already true for all three.
6. **Say the backup out loud in step 6** (open since round 3). `:70` -> "Briefly confirm what was
   written and where, including the backup result from step 5 (its exit code decides what you may
   claim)."

## The drift mechanism, third time of asking
Assessment **unchanged and now better evidenced: still the highest-value item, and it is the only
top-fix candidate here that is a MECHANISM rather than a wording.**
- `tests/ledger-backup.test.sh` case 21 (`:295-319`) is byte-unchanged and still per-CODE: it
  greps `^\| $code \|` for every `exit N` the script can produce. Case 33 (`:633`) does the same
  for the script header. Both passed green through `b3b66f7`, when the row was incomplete, and
  both would pass green today. Case 33's own comment already says this is what it cannot catch.
- The row has now lagged the program in rounds 4 and 6, and was corrected by hand each time, only
  after a reviewer round. This round it is complete, which is evidence FOR the mechanism rather
  than against it: it is complete because a human patched exactly what was reported, not because
  anything prevents the next drift. The proposed per-state keyword assertion would have failed at
  `b3b66f7` on the literal string (`own repository` appeared nowhere in the skill) and passes
  today (`:51` carries both `own repository` and `relative`).
- Refinement learned from this round's census, so the mechanism is not built too wide: derive the
  keyword list from the states a CALLER must tell apart, not from every message. `:528`, `:539`
  and `:569` are local-side exit 4 failures that the row deliberately summarises; a naive
  every-message rule would push three degenerate internal errors into a table an agent reads aloud
  to a human. A curated list next to the messages (`no remote named`, `not a git work tree`,
  `inside a git repository`, `own repository`, `relative URL`, `cannot be read`, `copy is
  incomplete`, `already current`) is roughly a dozen lines and stays honest about what it proves.
- Still recommended AGAINST: generating the skill's rows from the script header. Generation makes
  the two texts agree without making either true, and they have different jobs (a caller contract
  versus what an agent SAYS to a human). Two independently written texts are what made rounds 3,
  4 and 6 findable.

## Behavioral confirmation still owed
Form only. What remains is behavioral and belongs to an `/improve` subagent test: (a) exit 5, does
the close-out claim a backup; (b) exit 3 twice in one session, does the offer stay quiet the
second time; (c) the `:14` early stop, is the backup still attempted; (d) exit 2 from a
placeholder-shaped typo, does the agent offer to fix the line instead of reading it as "not
configured"; (e) exit 2 from a local backup remote inside a work tree, does the agent explain
containment and propose a target outside every repository rather than retrying; (f) exit 2 from a
remote that is a linked worktree of this project, does the agent now explain the shared object
store from the row instead of improvising; (g) **new**: exit 2 from a relative remote URL, does the
agent propose fixing the REMOTE's url as well as the `ledger_backup:` line, since the row's "offer
to fix the line" is only one of the two valid remedies for that state.

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
- Round 7 (2026-09-22, Opus 5 [1M], strongest, `5972c27`, same branch): 10/10 PASS. Scores
  2/2/2/2/2. Regenerated because HEAD moved past round 6's commit, not re-dated. Method changed on
  instruction: a full census of every `exit N` site in `bin/ledger-backup.sh`, rather than a diff
  against what changed, because this was the third consecutive round in which a row lagged the
  program. What moved: precision 1 -> 2. The human applied round 6's fix 1 AND the program grew a
  third `git`-arm refusal in the same commit (a relative remote URL, `:443-448`, previously rooted
  at the project and acted on); the rewritten `:51` names both, so the census finds no printed
  refusal the table does not describe. `docs/system-map.md:145` is fixed in all three places
  flagged in round 6 (three refusals enumerated, identity separated from location and attributed
  to git's common dir, the environment clause extended to the `GIT_CONFIG_*` family with its
  measured consequence), and the rewrite introduced nothing false; its identity sentence is in
  fact tighter than the skill's. What did not move: trigger clarity, structure, worked example and
  safety integration, all re-verified at this HEAD (the worked example's two lines are now
  verbatim `bin/ledger-backup.sh:578` and `:573`). New, non-blocking and stated so the 10 is not
  read as "nothing left": `:51`'s "however the URL is spelled" claims more coverage than the
  identity guard has, since only a URL that converts to a local path reaches it (`:486-488`);
  judged and deliberately not scored, because the clause explains a refusal that fired and the
  residual paragraph at `:59-62` already bounds the reader's expectation. Also new: three
  local-side exit 4 sites (`:528`, `:539`, `:569`) sit outside the exit 4 row's head clause,
  faithful to the program's own header contract but improvable by one word. The drift mechanism is
  re-recommended a third time, unchanged in substance, with one refinement: derive its keyword list
  from the states a caller must tell apart, not from every message.
