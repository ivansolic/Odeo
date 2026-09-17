---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: cebc0a0   # HEAD of the branch, supplied by the dispatcher.
                           # The delta under review is commit cebc0a0 itself.
artifact_version: 2        # second review round, not a claim about edit count
date: 2026-09-16
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 1, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
previous_total: 6/10
---

Scope: the whole `skills/retro/SKILL.md` (91 lines), read against
`docs/skill-authoring-standard.md` and its rubric. The delta under review is commit
`cebc0a0`: the prose backup step moved out of `## 4. Apply` into its own
`## 5. Back up what git cannot` (`:35-56`) and now calls a real program. Cross-read for this
round: `bin/ledger-backup.sh` (all 199 lines, to check the exit-code table against the actual
codes rather than trusting it), `tests/ledger-backup.test.sh`, `bin/session-end-check.sh:48-58`,
`project-templates/CLAUDE.md:84-90`, `docs/system-map.md:102,145`. Form only, no runtime
behavior tested. Output language `en`, read from `CLAUDE.md:21`.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **1**. Unchanged from round 1, and this is now the weakest line in the file.
  The description (`:2`) still reads "Captures what was learned this session and routes each
  lesson to the right place... Run before wrapping up a working session." Correct shape for an
  explicit command, but what the user gets changed again and the description did not follow:
  `/retro` now ALWAYS runs a backup (`:36` "whether or not a lesson was written") that can push
  gitignored files to a configured remote, or press the user to configure one. Round 1 flagged
  this when the write was conditional; the commit made it unconditional and left the one line a
  user reads before invoking untouched. Format right, contents incomplete.
- structure **2**. The promotion is exactly the fix that was asked for: its own numbered step
  between `## 4. Apply` and `## 6. Close out`, with its own heading, its own trigger sentence,
  a table where a table earns its place (five discrete outcomes, one line each), and no diagram
  for a linear step. 91 lines against the 500 limit, no supporting files, so the one-level rule
  is trivially satisfied. Placement is right on both sides: after `## 4. Apply` because
  `lessons.md` must be written before it is copied, before `## 6. Close out` because the close
  reports the outcome. One mechanical nit only: `:34` (a list item) is followed immediately by
  `:35 ## 5.` with no blank line.
- worked example **2**. Round 1's thin score is closed. Both branches are shown with real
  values, and the transcript strings are the program's actual output, not paraphrase:
  `:75` "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)"
  matches `bin/ledger-backup.sh:192` verbatim under `remote=backup branch=internal-files`, and
  `:81` "PUSH REFUSED to backup/internal-files, so NOTHING was backed up." matches `:187`
  verbatim. The failing branch also shows the hard part, what the agent SAYS afterwards
  (`:83-84` "The backup did NOT happen... still only on this machine"), which is the behavior
  the step exists to produce. Directly imitable.
- precision **1**. The undecidable condition is gone: `:40` names one command, `:48` names one
  field and one file, and `project-templates/CLAUDE.md:84-90` plus `docs/system-map.md:145`
  document `ledger_backup:` in both accepted forms. What holds this at 1 is the exit-code
  table itself, checked against the script rather than taken on trust:
  - **Exit 2 is missing from the table and is reachable from the plain invocation the skill
    prescribes.** `bin/ledger-backup.sh` exits 2 for "not a git work tree" (`:54`), `'dir' needs
    a path` (`:129`), `'git' needs <remote> <branch>` (`:147`), and `unknown ledger_backup kind`
    (`:196`). The last one is a typo in the config line, and the project's own tests treat it as
    important enough to assert (`tests/ledger-backup.test.sh:183-185`, "An unknown kind is a
    usage error, not a silent skip"). An agent that meets exit 2 has no row to read, in a step
    whose whole premise is `:43` "Report the result by its exit code, never by assumption".
  - **The exit 4 row claims more than the program does.** `:49` says "the target was
    unreachable, so **nothing was backed up**". Exit 4 also covers `cannot write to $dest`
    (`:135`), `copy failed for $f` (`:138`), `no temp dir`, `git init failed`, and `commit
    failed` (`:183`). In the `dir` case the copy loop is per file, so `todo.md` can land and
    `lessons.md` fail, giving exit 4 with a partial copy present; the skill instructs the agent
    to say nothing was backed up. Understating is the safe direction, but it is still a claim
    the program does not support, in the one step written against unsupported claims. ("show
    the message" in the same row limits the damage.)
  - Exits 0, 3, 5 and 6 are accurate, and exit 1 is correctly absent (it is `--check`-only,
    unreachable from `bin/ledger-backup.sh` with no flag).
  Everything else is exact: paths, the command and where to run it from, the field name, the
  file precedence (`CLAUDE.local.md` first, matching `read_config` at `:65-74`). No TBDs.
- safety integration **2**. Up from 1. The step now carries the honesty rule in its own voice,
  at the point of use, and references rather than restates: `:53` "Never report a backup you did
  not see exit 0", `:50` "do not close the session claiming a backup", and the exit-3 row keeps
  the file's consent discipline ("Take a no and do not raise it again this session"). The
  round-1 collision with `bin/install-git-guards.sh` is gone, and gone structurally rather than
  by wording: the skill no longer tells anyone to improvise `git push`, and the program pushes
  from a fresh temp clone (`:151-184`), which carries none of this repo's hooks, so a backup
  push cannot trip the guard that refuses direct pushes to main. The justification at `:53-56`
  is evidence-based and calm, not shouted. Residual, one clause, listed in Top fixes: the
  exit-3 row asks the agent to OFFER a `ledger_backup:` target without saying the target must
  be private, and the gitignore rationale it stands on is the publish contract.

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reachable. Nothing structurally caps a criterion: explicit command (trigger clarity can
be 2), real guardrails in range to reference (safety integration is already 2), and both
remaining deductions are one-edit fixes. This is a narrow pass, not a comfortable one: two
criteria at 1, and one of them is the same unfixed finding as round 1.

## The four round-1 findings, checked against the text
1. **"The condition cannot be decided"** — CLOSED. `:48` names `ledger_backup:` and
   `CLAUDE.local.md`; the field exists in `project-templates/CLAUDE.md:89-90` and
   `docs/system-map.md:145`; `bin/ledger-backup.sh:76-83` exits 3 printing the file and both
   accepted forms. The condition is now a lookup the program performs, not a judgment the agent
   makes, which is the stronger version of the fix that was asked for.
2. **"Bound to lesson-writing, not the session"** — MOSTLY CLOSED, one seam left. `:36` "Run
   this **whether or not a lesson was written**" covers the approve-nothing path. It does not
   cover the other exit: `:14` says "If genuinely nothing notable happened, say so and **stop**",
   and an agent that obeys `stop` at step 1 never reaches step 5. Round 1 asked for this case by
   name. One clause at `:14` closes it.
3. **"No failing branch"** — CLOSED as a design, incomplete as a table. Exit codes, a table, the
   never-report-without-exit-0 rule, and the refusal written into the worked example. The gap is
   coverage of the table (exit 2), not the presence of the branch.
4. **"Collides with install-git-guards.sh"** — CLOSED, see safety integration. The temp-clone
   push means the refusal case in the example is credential/protection failure, which is what
   `:84` says ("probably expired credentials"), consistent with `bin/ledger-backup.sh:188`.

## Does anything in the step still claim more than the program does?
Yes, one thing, the exit-4 "nothing was backed up" (see precision). Everything else is at or
below what the program guarantees. Notably `:44-51` does NOT claim the stamp, the `--check`
mode, or the session-end warning, all of which exist (`bin/session-end-check.sh:48-58`); leaving
them out of a skill body is correct restraint, not an omission.

## Map duty
Satisfied. No command surface added, `/retro` is already at `docs/system-map.md:102`, and the
new program has its own row at `:145` naming the exit codes. Advisory, unchanged from round 1
and now more warranted: the `/retro` row still reads "End-of-session lessons, routed to
lessons.md / CLAUDE.md with your approval" and does not mention that `/retro` also runs the
ledger backup every session. One clause.

## Still open elsewhere (carried from round 1, not fixed at this HEAD)
`docs/eval-framework.md:180` (was `:179` at `fab5c0d`, the file shifted by one line; text
unchanged) states the review loop's APPROVE exit as "The verdict clears the threshold (>= 9 of
12, no criterion at 0)". That is the code/design rubric only. The same stop condition governs
the plan loop, which has no numeric score at all, and skill and agent reviews, whose threshold
is 8/10 with no criterion at 0, as applied in this very record. A loop whose declared stop
names one rubric's numbers cannot be evaluated by the other two loops it governs. Outside this
skill, so it is recorded, not scored: fix by phrasing the exit as "clears the threshold of the
rubric in force for this artifact type (code/UI 9/12, skill and agent 8/10, plan: no open
Critical), no criterion at 0".

## Integrity
No sign of text copied from another project. Voice, terminology and every reference
(`.claude/tasks/lessons.md`, the published-snapshot rationale, `claude --continue`,
`bin/ledger-backup.sh`) are this system's own.

## Top fixes
1. **Add the exit 2 row.** `| 2 | the configuration line or the working directory is wrong (a
   typo in \`ledger_backup:\`, or not a git work tree). Nothing was backed up: show the message
   and offer to fix the line. |` This is the reachable code the table omits, and the one a first
   configuration attempt hits.
2. **Reword the exit 4 row so it matches the program.** "the backup did not complete (target
   unreachable, or the copy or commit failed), so it cannot be counted; with a `dir` target a
   partial copy may exist. Say that plainly and show the message." Keeps the honesty direction
   without asserting what the script does not guarantee.
3. **Update the description (`:2`).** Add one clause: "Also backs up the gitignored task ledger
   (`todo.md`, `lessons.md`) to the location recorded in `ledger_backup:`, which may be a
   remote." This is the only fix that moves trigger clarity to 2, and it has now been asked for
   twice.
4. **Close the `:14` seam.** Make it "say so and stop the lesson pass, then go to step 5", so
   the one path that reaches no lesson still reaches the backup.
5. **One clause on the target in the exit-3 row.** After the offer, "the target must be private:
   these files are gitignored so the ledger never reaches a published snapshot" plus a pointer
   to the publish contract. Reference it, do not restate it.
6. **Make the table drift-proof.** Add an assertion to `tests/ledger-backup.test.sh` that every
   exit code the script can return (grep `exit [0-9]`) has a row in `skills/retro/SKILL.md`.
   Round 1's defect was "the prose promises what nothing implements"; round 2's is "the prose
   describes the implementation incompletely". Same shape, one level up. A test is the mechanism
   that stops round 3 from finding the third spelling of it.
7. **One clause on the `/retro` row of `docs/system-map.md:102`** mentioning the ledger backup.

## Behavioral confirmation still owed
Form only, and the form is now good enough that the open question is behavioral: does an agent
actually run the program, and does it report exit 5 as a failure rather than closing the session
on the lesson it did write? That is an `/improve` subagent test. The matrix cases worth running:
(a) exit 5, does the close-out claim a backup; (b) exit 3 twice in one session, does the offer
stay quiet the second time per `:48`; (c) the `:14` early stop, is the backup still attempted.

## History
- Round 1 (2026-09-16, Opus 5 [1M], strongest, `fab5c0d`, branch
  feature/windows-powershell-entry): 6/10 FAIL. Scores 1/2/1/1/1. First record for this skill.
  The pre-existing lesson-routing flow was sound; the new backup step at `:35-46` failed on
  precision (no recorded-location convention existed to read), on its trigger (bound to
  lesson-writing, not to the session), on the missing failure branch, and on the missing
  example. Regenerated once, unchanged in scores or findings, after the dispatcher supplied the
  HEAD sha that was missing at first write.
- Round 2 (2026-09-16, Opus 5 [1M], strongest, `cebc0a0`, same branch): 8/10 PASS. Scores
  1/2/2/1/2. What moved: worked example 1 -> 2 (both branches now shown, with the program's
  verbatim output), safety integration 1 -> 2 (honesty rule at the point of use, and the
  install-git-guards collision removed structurally by pushing from a temp clone). What did not
  move: precision stays 1, for a different reason than round 1 (the undecidable condition is
  gone; the exit-code table now omits reachable exit 2 and overstates exit 4), and trigger
  clarity stays 1 for the SAME reason as round 1 (the description never mentions the
  out-of-repo write, which this commit made unconditional). The round-1 recommendation to make
  it a mechanism was also taken beyond what was asked: `bin/session-end-check.sh:48-58` now
  reads `ledger-backup.sh --check`.
