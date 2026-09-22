---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 15b168f
artifact_version: 8
date: 2026-09-22
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines, the only file in `skills/retro/`) at HEAD
`15b168f`, read against `docs/skill-authoring-standard.md` and its rubric. Method, repeated from
round 7 because it is what caught the last two incomplete rows: a FULL CENSUS of every `exit N`
site in `bin/ledger-backup.sh` (642 lines at this HEAD), enumerated from the current file rather
than diffed against the change note, then each site matched to a row. Also read
`tests/ledger-backup.test.sh` (case 21 at `:320-348`, case 33 at `:670-679`),
`WORKFLOW.md:648-674`, `BEGINNERS-GUIDE.md:241,325-332,377-379`, `docs/system-map.md:102,145`.
Form only, no runtime behavior tested. Output language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Unchanged and unaffected by this commit. `:2` states what the user gets,
  both halves, and that the second half writes outside the repo ("... then backs up the gitignored
  build ledger (todo.md, lessons.md) to wherever the project records, which writes OUTSIDE the
  repo"), closing with when to run it. That is the standard's explicit-command form.
  `disable-model-invocation: true` is set, so lint C1 does not apply.
- structure **2**. Unchanged: 102 lines against the 500 limit, essence (`:6-7`), numbered process
  (`:9-71`), worked example (`:73-96`), safety rules (`:98-101`). One file, so the one-level rule
  is trivially satisfied. Residual, not scoring: still no explicit "when NOT to", only the
  degenerate case at `:14`.
- worked example **2**. Re-verified against the program at THIS HEAD. `:86` is
  `bin/ledger-backup.sh:634` rendered with `present="todo.md lessons.md" remote=backup
  branch=internal-files`, character for character; `:92` is `:629` verbatim. Both branches shown,
  and the failing one shows the hard part, what the agent SAYS afterwards (`:94-95`).
- precision **2**. Held at 2. The census finds **no refusal the program prints that the table does
  not describe**, including the one added this commit. `:53` now names it in the program's own
  terms: "**a local remote URL the program cannot see** (it reads as a path but nothing is there,
  so it cannot check whether the target sits inside this repository, and it stops rather than
  guess: git may still resolve the URL, since it decodes percent escapes)", which is `:546-552`
  and its reasoning at `:529-540` rendered faithfully and without overclaim. The exit 2 row is
  still complete after `~` stopped counting as relative: that change removes cases from a refusal,
  it does not add a state, and the row never called `~` relative. Six carried findings remain,
  listed below; each is imperfect-but-not-wrong, and none is a state an agent would have to
  invent an explanation for.
- safety integration **2**. Unchanged and still accurate. Honesty rule at the point of use (`:64`
  "Never report a backup you did not see exit 0"; `:54` "do not close the session claiming a
  backup"), consent discipline preserved (`:30`, `:52`), private target named with its reason
  (`CLAUDE.local.md`). No guardrail is restated or weakened, and the residual paragraph at
  `:59-62` still matches the program's own stated limit (`:498-502`). The new refusal strengthens
  the honesty posture the skill already carries: an unseeable target now fails CLOSED at exit 4
  instead of skipping the guard, and the row says the backup is not current and no stamp is
  written, which is what an agent must report. The `git` arm still pushes from a fresh temp clone
  (`:584-601`), so no collision with `bin/install-git-guards.sh`.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: explicit command (trigger clarity can be
2), real guardrails in range (safety integration can be 2).

## The census at `15b168f`: every exit site, and the row that covers it
**Exit 2, fifteen sites.** `:87`, `:88`, `:93`, `:97` are argument usage, unreachable from
`/retro`'s no-argument invocation (`skills/retro/SKILL.md:43`) and filed as "usage" by the
program's own header; not a row's job. The rest: `:105` caller not in a work tree, `:114-118`
unreadable ledger directory, `:281`/`:344`/`:638` malformed line, `:288-290` relative `dir` path,
`:302`/`:315` containment on the `dir` arm, `:439-443` publish remote, `:455-460` relative remote
URL, `:573-577` identity ("IS this project's own repository"), `:579-580` containment on the
`git` arm. All nine are named at `:51`. `:186` is exit 2 inside `--check` only, and `:57` says
where `--check` lives. **The exit 2 set is identical to round 7's**: the `~` expansion (`:393`,
`:419`) narrows which URLs reach the relative refusal, it does not create or retire a state.

**Exit 4, seventeen sites.** Named in the row: `:346` no remote of that name, `:592`/`:600`
unreachable remote and failed clone, `:555` cannot resolve the remote path (folded into
"unreadable remote" since round 6), `:295` missing directory, `:330`/`:612` failed copy, `:334`
failed move (distinguished, as the row claims), and **`:546-552` the new fail-closed refusal**.
Not named, carried finding 4: `:584` no temp dir, `:595` git init failed, `:625` commit failed,
plus the `dir` arm's `:300`, `:304`, `:312`, `:326`, which the head clause "the target could not
be used" reaches loosely. For all of them the row's operative contract holds: show the message,
the backup is not current, no stamp is written.

**The rest.** Exit 0 at `:339` and `:634`, plus `already current` at `:619` (carried finding 2).
Exit 3 at `:143` and `:161`, "the message says which" true. Exit 5 at `:629`. Exit 6 at `:208`.
Exit 1 only at `:189` and `:201`, both inside the `--check` block, so `:57` is true. `stamp_now`
(`:210`) is called only at `:337`, `:618`, `:633`, all after a verified success, so "no stamp is
written" holds for exits 2, 4 and 5.

**Answer: yes, every refusal the program prints on a plain run is described.**

## The three program changes, judged for disclosure duty
1. **The fail-closed exit 4 refusal** (`:546-552`) is user-visible and IS disclosed, at `:53`. The
   skill's wording is accurate on all three claims the message makes: it reads as a path, nothing
   is there, so containment cannot be asked; git may still resolve it (percent escapes); the run
   stops rather than guess. Worth recording for the history: this is the first round in this
   skill's life where the row followed the program IN THE SAME COMMIT rather than one review later.
2. **The `~` expansion** (`:393`, `:419`, residual at `:517-521`) changes an outcome without adding
   a message: `~/backup.git` is now converted instead of refused as relative. Nothing in the table
   claimed otherwise, so no disclosure is owed. A `~` target that does not exist now lands on the
   new exit 4 refusal rather than on the clone's "cannot reach", which the row covers either way.
3. **`-ef` instead of a `pwd -P` string compare** (`:563-572`) prints no new message; it makes the
   existing identity refusal fire where a capitalisation typo silently defeated it. No disclosure
   duty in the skill. It does belong in the catalog row, see below.

## `docs/system-map.md:145`: now INCOMPLETE, not wrong
Nothing in the row became false this commit. It is incomplete in one place, and thin in a second:
- **Missing the fail-closed refusal.** The row enumerates the design ("Three refusals carry the
  design ... a relative remote URL is refused outright") and stops there, but `15b168f` added a
  design rule of the same rank, stated in the script as "THE GUARD IS NEVER SKIPPED" (`:529-540`):
  if the conversion yields a path and no directory is there, the run stops at exit 4 rather than
  act on a target it cannot see, because four leaks (`%2e%2e`, `%20`) reached the publish remote
  and the project's own repository at exit 0 through the skipped guard. That is precisely the kind
  of measured, class-eliminating decision this row exists to carry, and a reader of the map
  currently cannot learn that exit 4 has a refusal in it at all.
- **Thin on identity.** The row says identity is "asked by git COMMON DIR", which is still true,
  but the mechanism note stops one step short of what the code now does: the comparison is `-ef`
  (device and inode), not a string, after a capitalisation typo on a case-insensitive filesystem
  made the guard answer "a different repository" about the project itself. The row already names
  the equivalent lesson for location ("MARKERS ON DISK, never by git's message"), so the omission
  is asymmetric.
- Unchanged and still accurate: the exit-code list, the stamp-only-after-success claim, both arms
  of containment, the one shared conversion, the environment drop covering the `GIT_CONFIG_*`
  family, and "`--check` is what `session-end-check.sh` reads".
Suggested edit, one sentence each: "A fourth refusal is fail-closed rather than fail-open: if the
url converts to a path and nothing is there, the run STOPS at exit 4, because a url this program
cannot see is not a url git cannot use (`%2e%2e` and `%20` were measured landing the ledger on the
publish remote and in the project itself at exit 0, with the guard skipped, not failed)." And in
the identity sentence: "... compared with `-ef` (same file, not same spelling), after a
capitalisation typo on a case-insensitive filesystem made a string compare answer 'a different
repository' about the project."

## The other documents
- `docs/system-map.md:102`. Accurate and unaffected.
- `WORKFLOW.md:648-674`. Still true and undisturbed: `CLAUDE.local.md` first
  (`bin/ledger-backup.sh:128`), "in both cases **outside this repository**", the stamp written only
  after a verified success (three sites), and `:673`'s warning agreeing with
  `disable-model-invocation: true`. Quotes no exit codes, so it has nothing to drift.
- `BEGINNERS-GUIDE.md`, all three places, accurate and correctly free of exit codes for a beginner
  surface: step table row 11 (`:241`), the lessons section (`:325-332`), quick guide step 12
  (`:377-379`).

## Map duty
Satisfied as a duty: no new command surface, `/retro` is at `docs/system-map.md:102` and
`ledger-backup.sh` has its own row at `:145`. The row's incompleteness above is a documentation
finding against the map, not against this skill, and does not affect the score.

## Lint
Clean by inspection for the checks that apply: C5 (`bin/ledger-backup.sh` exists), C7 (no em or en
dash in the skill), C9 (non-empty description), C11 (no version-pinned model name). C1, C3, C10
and C13 do not apply.

## Integrity
No sign of text copied from another project. Voice, terminology and every reference are this
system's own.

## Carried findings (imperfect, not wrong; none blocks the verdict)
1. **`:51`'s "however the URL is spelled"** claims more coverage than the identity guard has: only
   a URL that converts to a local path reaches it (`:545`, `:553`), and the program's own residual
   says so (`:498-500`). Suggested: "however a local path is spelled (an ssh or https spelling of
   the same repository is not caught; only the publish-remote refusal covers those)". Carried from
   round 7 and deliberately not scored, for the same two reasons: the clause explains a refusal
   that FIRED rather than promising coverage, and `:59-62` already bounds the reader. The script
   header carries the same phrase at `:35`; `docs/system-map.md:145` is the one that gets it right.
2. **Exit 0 has an unnamed variant** (open since round 5). `:50` covers `:339`/`:634` but not
   `already current ($remote/$branch)` (`:619`). Suggested: "where the copy went, or that it was
   already current (the script prints which)."
3. **"An unreadable ledger" should say directory** (open since round 6). An unreadable ledger FILE
   fails later in the copy at exit 4 (`:330`/`:612`); the DIRECTORY is what is refused at exit 2
   (`:114-118`).
4. **The exit 4 head clause is one word too narrow** (open since round 7, and this commit
   strengthens the case). "The target could not be used" is false for `:584`, `:595` and `:625`,
   which are local-side, and it is now also strained by the new refusal, where the target may be
   perfectly usable BY GIT and it is this program that cannot check it. The row's own parenthetical
   already says so, which is why this stays non-scoring. Suggested: "the backup could not be made:
   ..." with the list unchanged.
5. **Step 6 does not mention the backup** (open since round 3). `:70` -> "Briefly confirm what was
   written and where, including the backup result from step 5 (its exit code decides what you may
   claim)."
6. **New this round, lowest priority:** the program added a residual at `:522-525` (a directory
   that exists here may not be the one git resolves, measured with a literal `%2f` name). It prints
   no message and cannot be observed by a caller, so no disclosure is owed; noted only so a future
   round does not rediscover it as a gap in `:59-62`.

## The drift mechanism, fourth time of asking
**Strengthened, not changed.** The recommendation stands: extend `tests/ledger-backup.test.sh`
case 21 from per-CODE to per-STATE.
- Case 21 (`:320-348`) and case 33 (`:670-679`) are unchanged at this HEAD and still ask only
  whether each reachable code has a row. This commit is the cleanest demonstration yet of the blind
  spot: the new refusal is an EXIT 4, a code that already had a row, so case 21 would have stayed
  green whether or not `:53` was ever updated. The row was updated because a human remembered, in
  the same commit; the test had nothing to do with it.
- That is the whole argument. Three consecutive rounds have now had the program move under the
  skill (`b3b66f7`, `5972c27`, `15b168f`). Twice the row lagged and a review caught it; once the
  author caught it himself. A mechanism converts the third outcome from "the author was paying
  attention" into "the suite refuses to go green", and the proposed keyword assertion would behave
  correctly on all three: it fails at `b3b66f7` (`own repository` absent from the skill), passes at
  `5972c27`, and passes here (`cannot see` present at `:53`).
- Refinement from round 7 still applies: curate the keyword list from the states a CALLER must tell
  apart, not from every message, or it will push `:584`/`:595`/`:625` into a table an agent reads
  aloud to a human.
- Still recommended AGAINST: generating the skill's rows from the script header. Generation makes
  the two texts agree without making either true, and they have different jobs (a caller contract
  versus what an agent SAYS). Two independently written texts are what made rounds 3, 4, 6 and 7
  findable.

## Behavioral confirmation still owed
Form only. For an `/improve` subagent test: (a) exit 5, does the close-out claim a backup; (b) exit
3 twice in one session, does the offer stay quiet the second time; (c) the `:14` early stop, is the
backup still attempted; (d) exit 2 from a placeholder-shaped typo, does the agent offer to fix the
line instead of reading it as "not configured"; (e) exit 2 from a local backup remote inside a work
tree; (f) exit 2 from a linked worktree of this project; (g) exit 2 from a relative remote URL, does
the agent propose fixing the REMOTE's url as well as the `ledger_backup:` line; (h) **new**: exit 4
from the fail-closed refusal, does the agent report "not backed up, and the reason is that the
target cannot be checked from here" rather than reading it as a transient network failure and
offering a retry.

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
- Round 8 (2026-09-22, Opus 5 [1M], strongest, `15b168f`, same branch): 10/10 PASS. Scores
  2/2/2/2/2. Regenerated because HEAD moved past round 7's commit, not re-dated; this is the anchor
  round for the merge gate. Census repeated on the current 642-line program. What moved: nothing
  in the scores, and for the first time in this skill's history the row followed the program IN THE
  SAME COMMIT. `15b168f` made the `git`-arm guard fail CLOSED (`:546-552`): a url that converts to
  a path with no directory there now stops at exit 4 instead of skipping containment, after four
  measured leaks where `%2e%2e` and `%20` put the ledger on the publish remote and into the
  project's own repository at exit 0. `skills/retro/SKILL.md:53` names that refusal accurately, on
  all three of its claims. Judged and found to owe no disclosure: the `~` expansion (`:393`,
  `:419`), which narrows the relative refusal rather than adding a state, and the `-ef` identity
  comparison (`:563-572`), which prints no new message and only makes the existing refusal fire
  where a capitalisation typo had silently defeated a string compare. The exit 2 set is identical
  to round 7's and the row is still complete. New finding outside the skill:
  `docs/system-map.md:145` is now INCOMPLETE (nothing in it became false) in one place and thin in
  a second, it does not carry the fail-closed refusal, which is a design invariant of the same rank
  as the three it does enumerate, and its identity sentence stops one step short of `-ef`;
  concrete replacement sentences are in the record. Six carried findings remain, all
  imperfect-but-not-wrong, four of them open since rounds 3-6. The drift mechanism is recommended a
  fourth time and this commit is its cleanest evidence: the new refusal is an exit 4, a code that
  already had a row, so case 21 (`:320-348`, unchanged) would have stayed green whether or not the
  row was ever updated.
