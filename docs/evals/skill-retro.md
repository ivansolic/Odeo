---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: fab5c0d   # HEAD of the branch, supplied by the dispatcher
                           # (full: fab5c0de7c35869a778a09df14973544abf83e96).
                           # The delta under review is commit d0e7696, unchanged at HEAD.
artifact_version: 1        # first record for this skill, not a claim about edit count
date: 2026-09-16
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 1, structure: 2, worked_example: 1, precision: 1, safety_integration: 1 }
total: 6/10
verdict: FAIL
previous_total: n/a        # no prior record for skills/retro/SKILL.md
---

Scope: the whole `skills/retro/SKILL.md` (68 lines), read against
`docs/skill-authoring-standard.md` and its rubric. The delta under review is the new
backup step at `:35-46` ("Then back up what git cannot"), added by commit `d0e7696`.
Whole-repo grep run for the thing that step depends on (a recorded backup location) and
for the guards a backup push would meet (`bin/install-git-guards.sh`, `bin/publish-guard.sh`).
`docs/system-map.md` checked for the map duty. Form only, no runtime behavior tested.
The branch stacks this change with several unrelated small items on purpose, one review
cycle instead of several; the skill file is unchanged between `d0e7696` and `fab5c0d`.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **1**. `disable-model-invocation: true`, and the description has the
  right shape for an explicit command, it says what you get and when to run it: "Captures
  what was learned this session and routes each lesson to the right place... Run before
  wrapping up a working session" (`:2`). But what the user gets CHANGED on this branch and
  the description did not: `/retro` can now copy the task ledger to a location outside this
  repo, or press the user to configure one. A write that leaves the repo is exactly the kind
  of thing a user should see before invoking, not discover at step 4. Format correct,
  contents now incomplete.
- structure **2**. Body shape intact: essence, numbered process, worked example, safety
  rules. 68 lines against the 500 limit, no supporting files, so the one-level-deep rule is
  trivially satisfied. The new step is 12 lines of inline prose with no new heading, no
  diagram for a linear step, and the "if nothing notable happened, say so and stop" line
  (`:14`) is a real when-NOT-to. Structure is not what is wrong here.
- worked example **1**. Present, concrete, real values ("2026-07-07, timer drifted with
  setInterval..."), directly imitable, and it ends at `:61` "Confirmed: 1 lesson saved". The
  new step is not in it at all. Neither branch is shown: not the recorded-location branch
  (what the refresh looks like, where it went), not the no-location branch (the one-time
  plain statement and the offer). The branch this review covers is the single most ambiguous
  instruction in the file and the example, which is where an agent goes for the shape, skips
  it. Present but thin for the change under review.
- precision **1**. Most of the file is exact (`.claude/tasks/lessons.md`, the dated rule
  format at `:31-32`, `~/.claude/CLAUDE.md`, `claude --continue`). The new step is not.
  `:38` reads "If the project records a backup location for them (a private mirror, a synced
  folder), refresh the copy NOW". WHERE would a project record that? Nothing in this repo
  says. A grep of the whole tree for a backup location returns this line and nothing else:
  no field in `CLAUDE.md`, no line in `AGENTS.md`, no path in `docs/`, no entry in
  `docs/internal-paths.txt`. The condition is therefore undecidable, an agent cannot tell
  which of the two branches it is in, and the action ("refresh the copy") names no command,
  no script, and no destination format. That is the standard's "vague steps are failures"
  landing on the one step this commit exists to add.
- safety integration **1**. It honors the file's consent discipline, "Offer to set a
  location; take a no and do not raise it again this session" (`:42`), and its justification
  is evidence-based rather than shouted (`:43-46`). But it is silent on the guardrails it
  stands directly next to. It explains correctly WHY the files are gitignored ("so the build
  ledger never reaches a published snapshot", `:35-36`), which is the publish contract, and
  then tells an agent to push or copy those exact files somewhere, without referencing
  contract A, `bin/publish-guard.sh`, or the pre-push hook. Silent where a guardrail
  applies, which is a 1, not a 0: it contradicts nothing and restates nothing.

## Total: 6/10   ## Verdict: FAIL (threshold 8/10, no zero)

## Ceiling
10/10, reachable. Nothing structurally caps a criterion here: explicit command (trigger
clarity can be 2), real guardrails in range to reference (safety integration can be 2), and
the step is perfectly demonstrable in the existing worked example.

## The questions this review was asked, answered against the text
1. **Is the new step triggerable?** Only conditionally, and the condition is the wrong one.
   It fires inside `## 4. Apply`, justified by "and you just wrote to one of them" (`:37`).
   So a retro where the user approves NO lesson (the worked example's own `#2` path, and the
   `:14` "nothing notable happened" stop) skips the refresh, even though `.claude/tasks/todo.md`
   changed all session long. The duty is bound to lesson-writing; the risk is bound to the
   session. Those are not the same trigger.
2. **Is it unambiguous?** No, see precision. Two of its three moving parts are undefined:
   where the location is recorded, and how the copy is made.
3. **Does it fail safe?** It is not stated. The no-location branch is handled well (`:40-42`:
   say it once, plainly, offer, take a no). The FAILING-copy branch does not exist: nothing
   says what to do when the mirror is unreachable, the remote is missing, or the push is
   refused. The step's only stated outcome is success ("refresh the copy NOW and say where it
   went"), so a silent failure is reported to the user as a completed backup, which is worse
   than no backup because it retires the worry.
4. **Does it assume repo state a user might not have?** In its text, no, and that is a
   deliberate strength: it names no private repo and no `internal-files` branch, only "a
   private mirror, a synced folder". The portability is real. The cost is that it assumes a
   CONVENTION that does not exist anywhere in the system, which is the precision finding
   above. It also collides with state a user in THIS system probably does have: the guards
   from `bin/install-git-guards.sh` refuse a direct push to main/master on ANY remote, and
   refuse any push to the public remote without `CLAUDE_PUBLISH_SNAPSHOT=1` (`:26-31` of that
   script). The obvious improvisation, `git push <backup> main`, is refused by the user's own
   hook, and the skill gives the agent nothing to make of that refusal.

## The placement problem (the structural fix, not a wording one)
The step's own evidence paragraph (`:43-46`) argues that this must not depend on someone
remembering, and then implements it as prose that depends on an agent remembering. The
standard already names the remedy for critical operations: "a critical operation lives in a
deterministic script in `bin/`, not in agent improvisation" (the `privacy-scan.sh`
principle). The mechanism slot also already exists: `bin/session-end-check.sh` is an
advisory Stop hook that always exits 0 and today warns about live tunnels, dev servers,
extra worktrees, and a stale `/focus` fence. "The ledger backup is older than
`.claude/tasks/todo.md`" belongs in that list. A tripwire that fires on schedule beats a
paragraph that fires on attention.

## Integrity
No sign of text copied from another project. Voice, terminology, and every reference
(`.claude/tasks/lessons.md`, the published-snapshot rationale, `claude --continue`) are this
system's own.

## Map duty
No command surface added or altered, so the standard's automatic finding does not apply:
`/retro` is already on `docs/system-map.md:102`. Advisory only, that map line now
under-describes the command ("End-of-session lessons, routed to lessons.md / CLAUDE.md with
your approval") since `/retro` may also write outside the repo. Worth one clause when the
step is fixed.

## Top fixes
1. **Name where the location is recorded, exactly.** Pick one home and write it into the
   step, e.g. a `ledger_backup: <path-or-remote>` line in the project's `CLAUDE.md`, and say
   "read `ledger_backup:` from this project's `CLAUDE.md`; absent = the no-location branch".
   That single edit turns an undecidable condition into a lookup.
2. **Ship the copy as a script and report its exit code.** Add `bin/ledger-backup.sh` (copy
   `.claude/tasks/todo.md` and `lessons.md` to the recorded location, exit non-zero with a
   named reason: no location configured, destination unreachable, push refused), have the
   step run it, and state both outcomes: on success say where it went, on non-zero say the
   backup did NOT happen and why, never report success on a failed copy.
3. **Give the step its own trigger.** Lift it out of `## 4. Apply` into `## 5. Back up what
   git cannot`, and state that it runs whether or not a lesson was approved, including after
   the `:14` early stop, because `todo.md` changes without any lesson being written.
4. **Extend the worked example by three lines** so both branches are visible, e.g.
   `ledger-backup.sh -> copied todo.md + lessons.md to ~/Sync/odeo-ledger (2 files)` and the
   no-location variant with the one-time offer.
5. **Reference the guardrail you are standing on.** One clause pointing at the publish
   contract and `bin/install-git-guards.sh`, so an agent that meets a refused push knows it
   met a guard on purpose and stops rather than improvising around it. Reference it, do not
   restate it.
6. **Then make it a mechanism**: add the staleness warning to `bin/session-end-check.sh`, per
   the placement note above.

## Behavioral confirmation still owed
Form only. Whether an agent actually performs the refresh, and what it does when the copy
fails, is an `/improve` subagent test once fixes 1 to 3 land. The matrix case worth running
is the one this text cannot currently answer: no location recorded anywhere, user declines
the offer, second `/retro` in the same session (the step must stay quiet, per `:42`).

## History
- Round 1 (2026-09-16, Opus 5 [1M], strongest, fab5c0d, branch
  feature/windows-powershell-entry): 6/10 FAIL. First record for this skill. The pre-existing
  lesson-routing flow is sound; the new backup step at `:35-46` fails on precision (no
  recorded-location convention exists to read), on its trigger (bound to lesson-writing, not
  to the session), on the missing failure branch, and on the missing example. Ceiling 10/10,
  nothing structural blocks a clean pass. Regenerated once, unchanged in scores or findings,
  after the dispatcher supplied the HEAD sha that was missing at first write.
