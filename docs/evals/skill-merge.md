---
artifact: .claude/skills/merge/SKILL.md
type: skill
branch: refactor/maintainer-tools-repo-only
reviewed_commit: 52921a5
artifact_version: 5
date: 2026-10-27
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
previous_total: 8/10
---

Scope: the whole `.claude/skills/merge/SKILL.md` at `52921a5` (the sha supplied at dispatch),
the repo-only copy of the former shipped `skills/merge/SKILL.md`.

**Why this record was regenerated.** It replaces the round 4 record anchored at `7cd8bb4`. Since
then the branch gained three commits: `ce98773` and `52921a5` touch only eval records under
`docs/evals/`, and `53a7676` changes one count in `README.md` (line 239, 1517 -> 1523
assertions). None of them touches the skill. The installed plugin's older merge gate refuses
any non-evals change after a record's `reviewed_commit`, so the README edit made the round 4
anchor stale. This is a re-anchor, not a new review round. I have no shell, so I could not run
`git diff 7cd8bb4 52921a5 -- .claude/skills/merge/` myself; the dispatcher says it is empty. I
re-read the whole skill file and checked it against every line this record cites (`:2`, `:8`,
`:10-13`, `:20-31`, `:93`, `:107`, `:108`, `:111`). Each one still says what round 4 quoted, so
the scores, findings and verdict carry over unchanged. I also re-checked `docs/system-map.md`
for the map-duty finding: `/odeo:merge` is still listed (`:12-14`, `:69`) and so is
`merge-gate.sh` (`:138`), so that finding stands. I did not re-read `.claude/maintainer/merge-gate.sh`,
`CLAUDE.md` or USR-022 this time. No commit in the range touches them, so the round 4
citations into those files carry over as quoted.
I scored the form only and tested no runtime behavior. Output language `en`, supplied at dispatch.
Plugin-path rules (`${CLAUDE_PLUGIN_ROOT}`) do not apply here because the skill is repo-only
(`CLAUDE.md:15-17`).

## Skill: merge  (explicit command, `disable-model-invocation: true`, invoked as `/merge`)

## Scores

- trigger clarity **2**. The description (`:2`) starts "Integrate a finished, reviewed story
  branch into main", names both outcomes ("it integrates locally instead and says so") and says
  when to run it ("Run once per story when it is approved and ready"). For an explicit command
  the standard asks for a plain statement of what you get, and this is one. Nothing in it
  depends on the `odeo:` namespace.
- structure **2**. 138 lines in one file, with nothing nested. The body follows the standard
  shape: essence, preconditions, numbered steps, two transcripts, safety rules. Step 0 is 12
  lines (`:20-31`). That length is justified because step 0 is a real decision point: which
  copy of the gate to trust.
- worked example **1**. Both transcripts start with `> /odeo:merge` (`:93`, `:107`), but the
  skill is now `/merge`. That matters more than a typo would. The installed 0.3.5 plugin still
  ships `skills/merge/SKILL.md`, so in a session that loads it, typing the example's command
  runs the OLD skill. Its step 0 calls `"${CLAUDE_PLUGIN_ROOT}/scripts/merge-gate.sh"`, which
  bypasses the "main's copy" design this branch adds. Apart from that invocation line, the
  example is concrete and matches the process.
- precision **1**. The main path of step 0 is exact (`:22-25`), but the fallback is not.
  "use the installed plugin's `merge-gate.sh` instead" (`:26-27`) gives no path and no way to
  tell when it applies. The repo is developed with `claude --plugin-dir .` (`CLAUDE.md:11`), and
  in that mode the "installed plugin" is this clone, which on this branch no longer has a
  `scripts/merge-gate.sh`. The marketplace copy sits under a versioned cache path, and the
  installed version is 0.3.5, older than main's gate. On the one merge where the fallback
  fires, an agent has to guess which copy is meant.
- safety integration **2**. Step 0 keeps the gate enforced. Every failure in the one-liner
  (`:23-24`) stops the run: if `git archive` matches nothing, running the missing path exits
  non-zero, and "STOP on non-zero" applies. The boundary checker comes from the same archive,
  so main's gate runs with main's checker, which makes `:30` ("`boundary-check.sh`, which sits
  next to the gate") true. "A branch that edits the gate must not be the one that judges it"
  (`:21`) is a real safety gain over the old plugin-root call, where under `--plugin-dir .` the
  branch judged its own gate. The fallback does not weaken the guardrail either, because the
  0.3.5 gate is only stricter. Two older items are still open and do not lower the score: the
  restated refusal list (`:28-31`) and the restated human floor (`:10-13`), see fixes 3 and 6.

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no criterion at 0)

## Ceiling: 10/10, reachable with text edits only (fixes 1 and 2). Nothing caps a criterion.

## Does step 0 contradict anything later in the skill?

- Nothing contradicts how the gate works. `:30` (the checker sits next to the gate) and the
  transcript output lines (`:94`, `:108`, "merge-gate: preconditions hold ...") match what
  main's copy prints.
- There is mild tension inside step 0. "STOP on non-zero" (`:20`) comes first, yet the fallback
  (`:26`) is triggered by a non-zero result: the archive matching nothing. A reader can only
  connect the two through git's error text. Fix 1 makes the condition explicit.
- `:93` and `:107` (`/odeo:merge`) and `:8` ("Offered by both `/odeo:build` modes") still name
  the shipped command. Fix 2.
- The fallback only applies to this one branch. Once the branch is on main, it describes a case
  that can never happen again. That is the time-bound text the standard warns about. Fix 1
  handles it.

## Top fixes

1. **Make the fallback exact and anchored to main, then retire it** (`:26-27`, raises
   precision). Main still holds the gate from before the move, so use main's own copy instead of
   "the installed plugin". That keeps `:21` true (main judges the branch), removes the version
   ambiguity and uses the newest gate main trusts. Replace `:26-27` with:
   "If `git archive` says `.claude/maintainer` matched no files (only the branch that introduces
   the folder), run main's pre-move copy the same way:
   `g="$(mktemp -d)" && git archive main scripts/merge-gate.sh scripts/boundary-check.sh | tar -x -C "$g" && "$g/scripts/merge-gate.sh"`.
   Never the branch's copy."
   First run `git ls-tree main scripts/merge-gate.sh scripts/boundary-check.sh` to confirm both
   paths exist on main. I could not run it. Delete the sentence in the first commit after this
   branch lands, or add it to USR-022. Keep calling the scripts directly, not as `bash <path>`:
   the gate silently skips a checker that is not executable, so if the executable bit were
   lost, `bash` would hide it for the gate while the boundary check quietly stopped running.
2. **Name the command correctly** (`:93`, `:107`, raises worked example). Change
   `> /odeo:merge` to `> /merge` in both transcripts. In `:8`, replace "Offered by both
   `/odeo:build` modes when a story is approved" with "The maintainer runs it as `/merge`
   when a story is approved", or leave `:8` to USR-022 and say so there.
3. **(carried since round 1, still open) Stop restating the gate's refusal list** (`:28-31`).
   The list names four refusals. Main's gate also refuses on a non-approving record, a missing
   `model_tier`, a missing or stale `reviewed_commit`, duplicate keys, an unparseable record and
   an untracked file under `docs/evals/`. Replace `:28-29` with: "It prints exactly which
   precondition failed (AGENTS.md Guardrails 1 lists them); `boundary-check.sh` sits next to it."
4. **Name the dead end** (one sentence after `:27`). Main's gate judges every branch, so a
   branch that fixes a defect in main's gate can be refused by that same defect. Add: "If
   main's gate itself is what blocks a fix to it, stop and hand it to the human; never fall
   back to the branch's copy."
5. **(cosmetic)** `mktemp -d` leaves one directory per run. Optionally, save the exit code,
   remove `$g`, then exit with the saved code. Skip this if it makes the line harder to read.
6. **(observation, not scored)** `:10-13` restates Guardrails 1 (`/odeo:merge` never starts
   itself). It was copied in so the rule would hold on a marketplace install without AGENTS.md.
   A repo-only skill always runs with AGENTS.md loaded (`CLAUDE.md:1`), so that reason no longer
   applies and a reference would be enough.
7. **(carried)** `main` is hardcoded, now also in the archive command; that is fine for this
   repo. `1b.` still breaks the rendered list. In the Two histories transcript, `--ff-only` is
   used without stating its precondition, and the record name is inconsistent (`:108`, `:111`).

## Map duty

The branch adds no published command, so the "adds a command" duty does not apply. The
repo-only `/merge` is documented where it belongs (`CLAUDE.md:15-17`) and must NOT go on the
published map. The reverse IS a finding, re-checked at `52921a5`: `docs/system-map.md` still
lists `/odeo:merge` (`:12-14`, `:69`) and `merge-gate.sh` (`:138`, "Invoked by `/odeo:merge`")
as shipped, and neither ships after this branch. Guardrails 6 says `/odeo:guide` recommends
only what is on the map, so it would recommend a command that does not exist. USR-022 already
owns this cleanup and names `docs/system-map.md` explicitly. The finding is recorded and
deferred. It does not block this skill, but it must not be dropped from USR-022.

## Behavior note

The form question is settled above. The open question is about behavior: will an agent on
THIS branch read the archive failure as the fallback condition, rather than as a STOP or as a
reason to run the branch's copy? This merge is the first and only real run of that path.
Before it, the dispatcher should run step 0's command by hand and confirm three things: it
fails at `git archive`, the fallback path exists on main, and the gate prints its verdict.
`/odeo:improve` A/B testing is not worth it for a path that runs only once.

**Integrity:** the file was moved with git, so its history is intact. Nothing in it reads as
copied from another project.

## Vs previous version

8/10 vs 8/10, no change. The artifact did not change between `7cd8bb4` and `52921a5`, so this
is a re-anchor, not a re-score. Against the last version before the move (10/10 at `f8a0aa3`
and `1cd2927`), the regression of 2 from round 4 remains, and both lost points still come from
the move: worked example 2 -> 1 (the invocation line names another skill), precision 2 -> 1
(the fallback names no exact gate copy).

## History

- **Round 1, 2026-09-22, 8/10 PASS** (uncommitted tree, no anchor). First scoring. Worked example
  and precision scored 1. Raised the restated refusal list in step 0, which is still open (fix 3).
- **Round 2, 2026-09-22, `86ad820`, 10/10 PASS.** Upstream check added to the transcripts; size
  threshold replaced by ancestry plus one question.
- **Round 3, 2026-09-22, `f8a0aa3`, 10/10 PASS.** Exit-status wording and the AHEAD question.
  Loop stopped (eval-framework conditions 2 and 3). The round 3 recommendation on a declared
  `remote.<name>.role = publication` key and a `pre-rebase` hook is still in that record's
  git history (`git show 1cd2927:docs/evals/skill-merge.md`) and is not repeated here.
- **Re-anchor, 2026-09-22, `1cd2927`.** Not a round. "whatever the ancestry said" deleted.
- **Round 4 (new artifact path), 2026-10-27, `7cd8bb4`, 8/10 PASS** (previous 10/10, down 2).
  Branch `refactor/maintainer-tools-repo-only`. The skill moved to
  `.claude/skills/merge/SKILL.md` (repo-only). Plugin-root paths became repo paths, and step 0
  now runs main's archived gate. Graded hardest on step 0: it is enforced and fails closed, but
  its fallback is imprecise (fix 1). The transcripts still invoke `/odeo:merge` (fix 2). Map
  cleanup is deferred to USR-022.
- **Re-anchor, 2026-10-27, `52921a5`, 8/10 PASS** (previous 8/10, unchanged). Not a new round.
  The record was regenerated because `53a7676` changed one count in `README.md`, a non-evals
  file, after the round 4 anchor, which makes the older installed gate refuse. The skill file
  is unchanged (re-read in full; the dispatcher states the git diff over the skill folder is
  empty). Scores, findings and fixes carried over. The map-duty finding was re-checked and still
  stands.
