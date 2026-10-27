---
artifact: .claude/skills/merge/SKILL.md
type: skill
branch: refactor/maintainer-tools-repo-only
reviewed_commit: 7cd8bb4
artifact_version: 5
date: 2026-10-27
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `.claude/skills/merge/SKILL.md` at `7cd8bb4` (the sha supplied at dispatch),
the repo-only copy of the former shipped `skills/merge/SKILL.md`. Step 0 got the closest read,
as the dispatcher asked. Also read: `.claude/maintainer/merge-gate.sh` (all of it, to check what
step 0 runs), `CLAUDE.md:11-17`, `docs/system-map.md`, `docs/stories/USR-022-clean-leftover-names.md`,
and the installed 0.3.5 plugin's `skills/merge/SKILL.md` and `scripts/merge-gate.sh`.
I have no shell, so I could not run `git show b783368:skills/merge/SKILL.md`. I compared against
the installed 0.3.5 copy instead. Its step 0 matches what the round-3 record quotes, and every
other line of it matches the new file. `.git/refs/heads/main` reads `b783368`, so local `main` is
the parent this branch moved the skill from.
I scored the form only and tested no runtime behavior. Output language `en`, supplied at dispatch.
Plugin-path rules (`${CLAUDE_PLUGIN_ROOT}`) do not apply here because the skill is repo-only, as
the dispatcher said. `CLAUDE.md:15-17` confirms this.

## Skill: merge  (explicit command, `disable-model-invocation: true`, invoked as `/merge`)

## Scores

- trigger clarity **2**. The description is unchanged (`:2`). It starts "Integrate a finished,
  reviewed story branch into main", names both outcomes ("it integrates locally instead and
  says so") and says when to run it ("Run once per story when it is approved and ready"). It
  reads correctly when the maintainer types `/merge`, and nothing in it depends on the
  `odeo:` namespace.
- structure **2**. 138 lines, one file, nothing nested. The body follows the standard shape:
  essence, preconditions, numbered steps, two transcripts, safety rules. Step 0 grew from 6 to
  12 lines (`:20-31`). The growth is justified because it is a real decision point (which gate
  copy to trust).
- worked example **1** (was 2). Both transcripts start with `> /odeo:merge` (`:93`, `:107`), but
  this skill is now `/merge`. The mismatch matters more than a typo would. The installed 0.3.5
  plugin still ships `skills/merge/SKILL.md`. In a session that loads it, typing the example's
  command runs the OLD skill, whose step 0 is
  `"${CLAUDE_PLUGIN_ROOT}/scripts/merge-gate.sh"`. That routes around the "main's copy" design
  this branch adds. Apart from the invocation line, the example is still concrete and matches
  the process.
- precision **1** (was 2). The main path of step 0 is exact (`:22-25`), but the fallback is not:
  "use the installed plugin's `merge-gate.sh` instead" (`:26-27`) gives no path and no way to
  detect when it applies. The repo develops with `claude --plugin-dir .` (`CLAUDE.md:11`). In
  that mode the "installed plugin" is this clone, which on this branch no longer has a
  `scripts/merge-gate.sh`. The marketplace copy lives under a versioned cache path, and the one
  installed is 0.3.5, older than main's gate. An agent has to guess which copy is meant, on
  the one merge where the fallback fires.
- safety integration **2**. Step 0 keeps the gate enforced. Every failure in the one-liner
  (`:23-24`) stops the run: if `git archive` matches nothing, the exec of a missing path exits
  non-zero, and "STOP on non-zero" applies. The boundary checker comes from the same archive
  (`merge-gate.sh:339` resolves it next to `BASH_SOURCE`), so main's gate is paired with main's
  checker. That makes `:30`'s "`boundary-check.sh`, which sits next to the gate" true. The
  change is a real safety gain. Before, the plugin root under `--plugin-dir .` WAS the branch,
  so the branch judged its own gate. Now "a branch that edits the gate must not be the one that
  judges it" (`:21`) holds. The fallback does not weaken the guardrail either. The 0.3.5 gate
  still enforces every-record approval, the `reviewed_commit` cutoff, the untracked-record
  refusal and the duplicate-key refusal. It lacks the 2026-10-23 prose allowlist, which only
  makes it stricter. Two older items are still open and do not lower the score: the restated
  refusal list (`:28-31`) and the restated human floor (`:10-13`), see fixes 3 and 6.

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no criterion at 0)

## Ceiling: 10/10, reachable with text edits only (fixes 1 and 2). Nothing caps a criterion.

## Does step 0 contradict anything later in the skill?

- No contradiction with the gate's mechanics. `:30` (checker next to the gate) and the
  transcript output lines (`:94`, `:108`, "merge-gate: preconditions hold ...") match what main's
  copy prints (`merge-gate.sh:348`).
- There is mild tension inside step 0. "STOP on non-zero" (`:20`) comes first, and the fallback
  (`:26`) is triggered by a non-zero result, the archive matching nothing. The reader can only
  connect the two by reading git's error text. Fix 1 makes the condition explicit.
- `:93` and `:107` (`/odeo:merge`) and `:8` ("Offered by both `/odeo:build` modes", which offer
  `/odeo:merge`) still name the shipped command. Fix 2.
- The fallback only applies to this one branch, so once this branch is on main it describes a
  case that can never happen again. That is the time-bound text the standard warns about ("No
  time-sensitive facts ... that rot"). Fix 1 handles it.

## Top fixes

1. **Make the fallback exact and trusted by main, then retire it** (`:26-27`, score-bearing for
   precision). Main (`b783368`) still holds the pre-move gate, so use main's own copy rather
   than "the installed plugin". This keeps the trust root of `:21`, avoids version ambiguity and
   uses the newest trusted gate. Replace `:26-27` with:
   "If `git archive` says `.claude/maintainer` matched no files (only the branch that introduces
   the folder), run main's pre-move copy the same way:
   `g="$(mktemp -d)" && git archive main scripts/merge-gate.sh scripts/boundary-check.sh | tar -x -C "$g" && "$g/scripts/merge-gate.sh"`.
   Never the branch's copy."
   First confirm with `git ls-tree main scripts/merge-gate.sh scripts/boundary-check.sh` that
   both paths exist at `b783368`. I could not run it. Delete the sentence in the first commit
   after this branch lands, or add it to USR-022, so the skill does not keep a case that can no
   longer happen. Keep calling the scripts directly, not `bash <path>`. `merge-gate.sh:340`
   silently skips a checker that is not executable, so if the exec bit were lost, `bash` would
   hide that on the gate while the boundary check quietly stopped running.
2. **Name the command correctly** (`:93`, `:107`, score-bearing for worked example). Change
   `> /odeo:merge` to `> /merge` in both transcripts. In `:8`, replace "Offered by both
   `/odeo:build` modes when a story is approved" with "The maintainer runs it as `/merge`
   when a story is approved", or leave `:8` to USR-022 and say so there.
3. **(carried since round 1, still open) Stop restating the gate's refusal list** (`:28-31`).
   Step 0 was rewritten in this branch, which was the natural moment to fix this, and it did
   not happen. The list names four refusals. Main's gate also refuses on a non-approving
   record, a missing `model_tier`, a missing or stale `reviewed_commit`, duplicate keys, an
   unparseable record and an untracked file under `docs/evals/`. Replace `:28-29` with: "It
   prints exactly which precondition failed (AGENTS.md Guardrails 1 lists them); `boundary-check.sh`
   sits next to it."
4. **Name the dead end** (one sentence after `:27`). Because main's gate judges every branch, a
   branch that fixes a defect in main's gate can be refused by that same defect. Add: "If
   main's gate itself is what blocks a fix to it, stop and hand it to the human; never fall
   back to the branch's copy."
5. **(cosmetic)** `mktemp -d` leaves one directory per run. Optional: capture the exit code,
   remove `$g`, then exit with the captured code. Not worth it if it makes the line harder to
   read.
6. **(observation, not scored)** `:10-13` restates Guardrails 1 (`/odeo:merge` never starts
   itself). The reason for embedding it was a marketplace install without AGENTS.md. A
   repo-only skill always runs with AGENTS.md loaded (`CLAUDE.md:1`), so that reason is gone and
   a reference would do.
7. **(carried)** `main` is hardcoded (now also in the archive command); fine for this repo.
   `1b.` still breaks the rendered list. In the Two histories transcript, `--ff-only` is
   assumed without its precondition, and the record name is inconsistent (`:108`, `:111`).

## Map duty

No new published command is added, so the "adds a command" duty does not apply. The repo-only
`/merge` is documented where it belongs (`CLAUDE.md:15-17`) and must NOT go on the published map.
The other side of the duty IS a finding. `docs/system-map.md` still lists `/odeo:merge`
(`:12-14`, `:69`) and `merge-gate.sh` (`:138`, "Invoked by `/odeo:merge`") as shipped, and
neither ships after this branch. Guardrails 6 has `/odeo:guide` recommend only what is on the
map, so it would recommend a command that does not exist. An existing story already owns this
cleanup: `docs/stories/USR-022-clean-leftover-names.md:31-32` counts the leftover references and
names `docs/system-map.md` explicitly. So the finding is recorded and deferred, and it does not
block this skill. It must not be dropped from USR-022.

## Behavior note

The form question is settled above. What is still open is behavioral and specific: will an
agent on THIS branch read the archive failure as the fallback condition, rather than as a STOP
or a reason to run the branch's copy? This merge is the first and only real run of that path.
Before it, the dispatcher should run step 0's command by hand and confirm three things: it
fails at `git archive`, the fallback path exists on main, and the gate prints its verdict.
`/odeo:improve` A/B testing is not worth it for a branch that can only happen once.

**Integrity:** the file was moved with git (history intact). Nothing in it reads as copied from
another project.

## Vs previous version

8/10 vs 10/10, a regression of 2. Both lost points come from the move, not from step 1b or the
transcripts' content. Worked example went 2 -> 1 because the invocation line now names another
skill. Precision went 2 -> 1 because the fallback names no exact gate copy. Safety held at 2,
and its substance improved: the gate is no longer chosen by the branch it judges.

## History

- **Round 1, 2026-09-22, 8/10 PASS** (uncommitted tree, no anchor). First scoring. Worked example
  and precision 1. Raised the step 0 refusal-list restatement, which is still open (fix 3).
- **Round 2, 2026-09-22, `86ad820`, 10/10 PASS.** Upstream check added to the transcripts; size
  threshold replaced by ancestry plus one question.
- **Round 3, 2026-09-22, `f8a0aa3`, 10/10 PASS.** Exit-status wording and the AHEAD question.
  Loop stopped (eval-framework conditions 2 and 3). The round-3 recommendation on a declared
  `remote.<name>.role = publication` key and a `pre-rebase` hook is still on that record's
  git history (`git show 1cd2927:docs/evals/skill-merge.md`) and is not repeated here.
- **Re-anchor, 2026-09-22, `1cd2927`.** Not a round. "whatever the ancestry said" deleted.
- **Round 4 (new artifact path), 2026-10-27, `7cd8bb4`, 8/10 PASS** (previous 10/10, regressed
  2). Branch `refactor/maintainer-tools-repo-only`. The skill moved to
  `.claude/skills/merge/SKILL.md` (repo-only). Plugin-root paths became repo paths, and step 0
  now runs main's archived gate. Graded hardest on step 0: it is enforced and fail-closed, but
  its fallback is imprecise (fix 1). The transcripts still invoke `/odeo:merge` (fix 2). Map
  cleanup is deferred to USR-022.
