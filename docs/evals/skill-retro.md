---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 0125901d9fbbb3bc62fd6629783e5ad69049f4c9
artifact_version: 5
date: 2026-09-18
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines) at HEAD `0125901`, read against
`docs/skill-authoring-standard.md` and its rubric. The skill file changed in this commit (the
exit 2 and exit 4 rows were rewritten) and so did the program under it, so this round is again a
row-by-row truth check of step 5's exit-code table against `bin/ledger-backup.sh` as it is at
HEAD (all 448 lines, every `exit N` site), plus `tests/ledger-backup.test.sh` (cases 21, 24, 26,
30-36), `WORKFLOW.md:648-674`, `BEGINNERS-GUIDE.md:241,325-332,377-379`,
`docs/system-map.md:102,145`, `project-templates/CLAUDE.md:86`. Form only, no runtime behavior
tested. Output language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Unchanged. `:2` still states what the user gets, both halves, and that
  the second half writes outside the repo: "routes each lesson to the right place ... then backs
  up the gitignored build ledger (todo.md, lessons.md) to wherever the project records, which
  writes OUTSIDE the repo", closing with when to run it ("Run before wrapping up a working
  session"). That is the standard's explicit-command form. `disable-model-invocation: true` is
  set, so lint C1 does not apply.
- structure **2**. Unchanged shape at 102 lines against the 500 limit: essence (`:6-7`), numbered
  process (`:9-71`), worked example (`:73-96`), safety rules (`:98-101`). No supporting files, so
  the one-level rule is trivially satisfied. The two rewritten rows added roughly 40 words and no
  new section; the backup keeps its own numbered step between `## 4. Apply` and `## 6. Close out`.
  Residual, not scoring: still no explicit "when NOT to", only the degenerate case at `:14`.
- worked example **2**. Re-verified against the program at THIS HEAD, not carried over. `:86`
  "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)"
  is `bin/ledger-backup.sh:440` rendered with `present="todo.md lessons.md" remote=backup
  branch=internal-files`, character for character; `:92` "PUSH REFUSED to backup/internal-files,
  so NOTHING was backed up." is `:435` verbatim. Both branches shown, and the failing one shows
  the hard part, what the agent SAYS afterwards (`:94-95`).
- precision **2**. Restored from 1. All three round-4 findings are closed, and no row makes a
  claim the program at HEAD does not keep. Checked site by site:
  - **Exit 2, the dead state is gone and the new behaviour is in.** `:51` no longer files "a
    repository git cannot read" under undecidable; it now lists "a target inside **any** git
    repository (a directory, or a local backup remote sitting in someone's work tree)", which is
    exactly the two call sites of the marker-walking guard: `in_work_tree`/`refuse_in_repo`
    (`bin/ledger-backup.sh:236-259`) called on the `dir` arm's parent and landing directory
    (`:286`, `:297`) and, new in this commit, on a local remote's PARENT on the `git` arm
    (`:382-388`, pinned by test case 35). The skill covers the new arm without inventing a new
    exit code for it, which is right: `refuse_in_repo` exits 2 on both arms.
  - **Exit 2, the framing no longer asserts a broken line where there is none.** The row now
    reads "Usually the `ledger_backup:` line: ... Also an unreadable ledger ... and a caller
    outside a git work tree, where no line is at fault. Show the message; offer to fix the line
    when the message names one." That matches `:98-102` (unreadable ledger directory, refused
    rather than reported empty) and `:89` (not a git work tree). The remaining exit 2 sites are
    the usage paths (`:76`, `:77`, `:82`) and `--check`'s unreadable mtime (`:170`), none of them
    reachable from the invocation this skill documents (`:43`, no arguments, run from the project
    root) or from a plain run at all. Omitting them is scope, not drift.
  - **Exit 4 no longer hides the configuration error.** `:53` now opens "**no remote of that
    name** (a line to fix, not a target to retry: the message says which)", which is
    `bin/ledger-backup.sh:330`, the round-3 finding that survived two rounds.
  - **Exit 4 no longer overclaims.** `:53` "A failed COPY places nothing, since the files are
    staged first; a failure during the final MOVES can leave an incomplete set, and the message
    distinguishes the two" is precisely the pair `:314` ("copy failed for $f, NOTHING was backed
    up", after `rm -rf "$staging"`, with the staging directory created at `:308`) and `:318`
    ("could not place $f, the copy is incomplete"). On the `git` arm the analogous copy failure
    (`:418`) writes only into a temp clone destroyed by the trap at `:391`, so "places nothing"
    holds there too. "no stamp is written" matches `stamp_now` being called only at `:321`,
    `:424` and `:439`, never on an exit 4 or 5 path.
  - Rows unchanged and still true: exit 0 (`:322`, `:440`), exit 3 both causes (`:127` and
    `:145`, and "the message says which" matches both texts), exit 5 (`:435`), exit 6 (`:192`),
    and `:57`'s "Exit 1 belongs to `--check` only" matches exit 1 appearing only at `:172` and
    `:185`.
  - The public-remote residual at `:59-62` still matches the program: name-and-normalised-URL
    refusal at `:350-368`, with the same limits stated in the script header (`:36-39`) and the
    script pointing back at this row by name (`:349`).
- safety integration **2**. Unchanged and still accurate. The honesty rule sits at the point of
  use in the step's own voice (`:64` "Never report a backup you did not see exit 0"; `:54` "do
  not close the session claiming a backup"), consent discipline is preserved (`:30` "Do not write
  anything until they approve", `:52` "Take a no and do not raise it again this session"), and
  the private-target clause names `CLAUDE.local.md` and why. No guardrail is restated or
  weakened. The `git` arm still pushes from a fresh temp clone (`:390-407`) carrying none of this
  repo's hooks, so no collision with `bin/install-git-guards.sh`; and the environment drop at
  `:48-69` removes, rather than documents, the hook-context hazard.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: explicit command (trigger clarity can be
2), real guardrails in range (safety integration can be 2).

## The two new behaviours in `0125901`, judged for disclosure duty
- **The git-arm containment refusal: disclosed, correctly.** It is user-visible (a target that
  worked yesterday is refused today, at exit 2), so the skill owes the agent a sentence, and
  `:51` gives it one in the right row: "a local backup remote sitting in someone's work tree".
  Nothing further is owed; the message itself names the containing repository (`:254`).
- **The environment drop (`unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE ...`, `:68-69`): no
  disclosure owed, and its absence is not a gap.** It produces no exit code, no message and no
  changed outcome for any state the table describes; it removes a corruption of the CALLER's
  index that could occur when the program ran from a git hook (measured, `:54-62`, pinned by test
  case 34). Putting it in the skill would be restating an implementation property the agent can
  neither observe nor report. It belongs where it now is, in the script header and in the
  catalog row `docs/system-map.md:145`, both of which carry it.

## The surrounding documents, re-checked against the program at HEAD
- `docs/system-map.md:145`. **Both round-4 findings closed.** The stale "It refuses rather than
  guesses whenever git cannot answer" is gone; the row now says "Containment is decided by
  repository MARKERS ON DISK, never by git's message", names both arms ("asked of the resolved
  landing directory on the `dir` arm and of a local remote's parent on the `git` arm"), and
  carries the environment drop. The exit list reads "4 the target could not be used", so the "4
  unreachable" shorthand is gone too. Accurate at HEAD.
- `docs/system-map.md:102`. Accurate and unaffected: names the backup, the two files, the
  `ledger_backup:` target, outside the repo, and reporting by exit code.
- `WORKFLOW.md:648-674`. Still true, nothing in `0125901` disturbs it. `CLAUDE.local.md` first
  (`bin/ledger-backup.sh:112`); "in both cases **outside this repository**" now holds on both
  arms rather than only on `dir`, so this sentence became MORE true this commit; "the 'last
  backup' stamp is written only after a verified success" matches the three `stamp_now` sites;
  `:673`'s warning agrees with `disable-model-invocation: true`. Quotes no exit codes, so it has
  nothing to drift.
- `BEGINNERS-GUIDE.md`, all three places. Still accurate, and correctly free of exit codes for a
  beginner surface: step table row 11 (`:241`, "then the gitignored ledger backed up outside the
  repo"), the lessons section (`:325-332`, "If you haven't set one, Claude tells you once and
  offers to add the line", which is the exit 3 contract including the once), quick guide step 12
  (`:377-379`).
- `project-templates/CLAUDE.md:86`. Unchanged; still both the reason the exit 3 placeholder
  clause exists and the source of the skill's "installed in `~/bin`" note at `:43`.

## Map duty
Satisfied. No new command surface. `/retro` is at `docs/system-map.md:102` and
`ledger-backup.sh` has its own row at `:145`, both accurate at this commit.

## Lint
Clean by inspection for the checks that apply: C5 (`bin/ledger-backup.sh` exists), C7 (no em or
en dash in the skill or in the rewritten rows), C9 (non-empty description), C11 (no
version-pinned model name). C1, C3, C10 and C13 do not apply.

## Integrity
No sign of text copied from another project. Voice, terminology and every reference are this
system's own.

## Top fixes
None blocking; the file passes at ceiling. Three optional polish items, in descending value:
1. **Say the backup out loud in step 6** (open since round 3, still the most useful edit). `:70`
   -> "Briefly confirm what was written and where, including the backup result from step 5 (its
   exit code decides what you may claim)." Today the honesty rule lives only inside step 5, and
   the close-out is where a session's summary is actually composed.
2. **Name the exit 0 variant the row does not mention.** `:48`'s "where the copy went (the script
   prints it)" covers `:322`/`:440`, but not `already current ($remote/$branch)` (`:425`), where
   nothing was copied this run and the backup is nonetheless verified current. Suggested: "where
   the copy went, or that it was already current (the script prints which)."
3. **Tighten "an unreadable ledger" in the exit 2 row to the directory.** An unreadable ledger
   FILE fails later, in the copy, at exit 4 (`:314`/`:418`, test case 24); it is the unreadable
   DIRECTORY that is refused at exit 2 (`:98-102`). The row's "rather than report as empty"
   already points at the directory case, and one word ("an unreadable ledger directory") removes
   the ambiguity.

## The mechanism question, answered
Round 4 raised single-sourcing /retro's rows from the script header as a design option. Having
now watched a fourth cycle, my answer is: **not generation, and not required.** Two reasons and
one cheaper alternative.
- Generation makes the two texts AGREE; it does not make either TRUE. The evidence is in this
  commit's own residual: both the header (`:42-45`) and the skill (`:53`) introduce exit 4 as
  "the target could not be used", while three of its sites are local failures, not target
  failures (`:390` no temp dir, `:401` git init failed, `:431` commit failed). A generator would
  have propagated that framing to both files, and this review would have had nothing to compare
  against. Two independently written texts are what made rounds 3 and 4 findable.
- The two texts also have different jobs. The header is a CALLER CONTRACT; the skill's row is
  what the agent SAYS to a human ("offer to fix the line when the message names one", "do not
  close the session claiming a backup", "Take a no and do not raise it again this session").
  Generating one from the other either drops that guidance or pushes user-facing coaching into a
  program's comment block. Cost, if built anyway: a generator, a marked do-not-edit region inside
  SKILL.md, and a CI check, against a skill file whose whole value is that a reviewer reads it as
  prose.
- The cheaper mechanism that fits the actual failure: extend `tests/ledger-backup.test.sh` case
  21 from per-CODE to per-STATE. For each `exit N` site, require a distinguishing keyword from
  that site's message (`no remote named`, `not a git work tree`, `inside a git repository`,
  `cannot be read`, `copy is incomplete`) to appear in the row for N, in both the header and the
  skill. That is a dozen lines, it fails loudly in the commit that changes a message, and it
  would have caught round 4's regression. Stated residual, so a green run is not read as more: it
  still cannot tell whether the guidance sentence around the keyword is good advice. Recorded as
  a design option for the humans, not as a required fix.

## Behavioral confirmation still owed
Form only. What remains is behavioral and belongs to an `/improve` subagent test: (a) exit 5,
does the close-out claim a backup; (b) exit 3 twice in one session, does the offer stay quiet the
second time; (c) the `:14` early stop, is the backup still attempted; (d) exit 2 from a
placeholder-shaped typo, does the agent offer to fix the line instead of reading it as "not
configured"; (e) exit 2 from a local backup remote inside a work tree (the new `git`-arm
refusal), does the agent explain containment and propose a target outside every repository rather
than retrying; (f) exit 2 from a target inside an unreadable repository, does the agent report
containment now that the "could not decide" wording is gone.

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
