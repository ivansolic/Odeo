---
artifact: skills/retro/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 2e7c7408fea086eca2ddb02b72e6ef5d01ee1ede
artifact_version: 3
date: 2026-09-17
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 8/10
---

Scope: the whole `skills/retro/SKILL.md` (102 lines) at HEAD `2e7c740`, read against
`docs/skill-authoring-standard.md` and its rubric. Cross-read for this round, because they are
what a user reads before invoking the command and they now make claims about the backup step:
`bin/ledger-backup.sh` (all 377 lines, to check the exit-code table against the actual codes
rather than trusting it), `tests/ledger-backup.test.sh` (case 21 in particular),
`bin/session-end-check.sh:44-69`, `bin/skills-lint.sh`, `install.sh:96-108`,
`project-templates/CLAUDE.md:84-96`, `docs/system-map.md:102,145`, `WORKFLOW.md:648-674`,
`BEGINNERS-GUIDE.md:241,320-332,377-379`. Form only, no runtime behavior tested. Output
language `en`, supplied at dispatch.

## Skill: retro  (explicit command)

## Scores
- trigger clarity **2**. Up from 1, and this closes the finding that survived rounds 1 and 2.
  The description (`:2`) now states both halves of what the user gets and where the second half
  writes: "routes each lesson to the right place, project-specific lessons to
  .claude/tasks/lessons.md, general rules as a proposed global CLAUDE.md update, then backs up
  the gitignored build ledger (todo.md, lessons.md) to wherever the project records, which
  writes OUTSIDE the repo", closing with when to run it ("Run before wrapping up a working
  session"). That is the standard's explicit-command form: plain what-you-get plus the moment.
  The invocation shape is trivial and shown anyway at `:75` (`> /retro`). `disable-model-invocation: true`
  is set, so lint C1 ("Use when") correctly does not apply.
- structure **2**. Unchanged. Essence (`:6-7`), numbered process (`:9-71`), worked example
  (`:73-96`), output and close-out (`:69-71`), safety rules (`:98-101`). The backup keeps its own
  numbered step between `## 4. Apply` and `## 6. Close out`, which is the only correct placement
  (`lessons.md` must be written before it is copied, and the close reports the result). 102 lines
  against the 500 limit, no supporting files, so the one-level rule is trivially satisfied. The
  table earns its place (six discrete outcomes, one line each) and there is no diagram for a
  linear step. Round 2's mechanical nit (a list item butted against `## 5.`) is gone: `:36` is
  followed by a blank line. Residual, not scoring: the body has no explicit "when NOT to" (the
  standard's element 2); it exists only as the degenerate case at `:14`.
- worked example **2**. Unchanged, and re-verified against the program at this HEAD rather than
  carried over. `:86` "ledger-backup: refreshed (todo.md lessons.md -> backup/internal-files:internal-not-in-git/)"
  is `bin/ledger-backup.sh:369` rendered with `remote=backup branch=internal-files`, character
  for character; `:92` "PUSH REFUSED to backup/internal-files, so NOTHING was backed up." is
  `:364` verbatim. Both branches are shown, and the failing one shows the hard part, what the
  agent SAYS afterwards (`:94-95` "The backup did NOT happen ... still only on this machine"),
  which is the behavior the step exists to produce. Directly imitable.
- precision **2**. Up from 1; both round-2 defects are addressed, one of them mechanically.
  - **The exit 2 row exists** (`:51`) and is accurate against the program: unknown kind (`:373`),
    missing branch (`:277`), relative path (`:176`), a target inside any git repository (`:230`),
    the project's publish remote (`:316`), an unreadable ledger (`:70`), a repository git cannot
    read (`:222`). It also carries the instruction the old gap cost most: "**Do not read this as
    'not configured'**", which is exactly what the program's own test asserts
    (`tests/ledger-backup.test.sh:187`).
  - **The exit 4 row no longer overclaims by construction.** `:53` gives the honest reason:
    "The program stages the files and moves them only if all of them copied", which matches the
    staging directory and the two-phase copy/move at `bin/ledger-backup.sh:257-269`. The claim
    is now supported by a mechanism instead of asserted.
  - **The table is drift-proofed**, which is the round-2 fix that mattered most:
    `tests/ledger-backup.test.sh:295-319` greps every `exit N` out of the script and fails if any
    reachable code has no `| N |` row, with exit 1 excluded because it is `--check`-only and the
    skill says so in words at `:57`. The prose can no longer fall behind the program silently.
  - Everything concrete is exact: the command and where it comes from (`:43`, and `install.sh:107`
    does copy every `bin/` program to `~/bin`, asserted by `tests/install-bin.test.sh:89-97`),
    the field name, the file precedence (`CLAUDE.local.md` first, matching `read_config` at
    `:79-88`), the paths. No TBDs, no vague steps.
  - Two residuals, both hedged by "Show the message" in the same rows and neither large enough
    to hold the criterion at 1; listed in Top fixes. (a) `:53` covers exit 4 as "unreachable
    remote, missing directory, a copy that failed", but exit 4 also covers a `ledger_backup:`
    line naming a remote that does not exist (`:279`, "this repo has no remote named"), which is
    a configuration mistake to fix rather than a target to retry. (b) the `dir` branch's second
    loop can fail between moves (`:267`, "could not place $f, the copy is incomplete"), so the
    row's blanket "the backup did not happen" is one word stronger than the program's own
    message in that one case.
- safety integration **2**. Unchanged, and now with the private-target clause round 2 asked for.
  The honesty rule is in the step's own voice at the point of use (`:64` "Never report a backup
  you did not see exit 0"; `:54` "do not close the session claiming a backup"), consent
  discipline is preserved (`:52` "Take a no and do not raise it again this session"), and `:52`
  now says where a private target belongs and why ("`CLAUDE.local.md` (gitignored, right place
  for a private target)"). `:59-62` adds the limit honestly, in our voice, without restating the
  publish contract: "What the program cannot decide for you: whether a remote is PUBLIC ...
  Choosing a backup target that nobody else reads stays a human decision." No guardrail is
  restated or weakened, and no collision with `bin/install-git-guards.sh` remains: the git branch
  pushes from a fresh temp clone (`bin/ledger-backup.sh:319-367`) that carries none of this
  repo's hooks. The justification at `:64-67` is evidence-based and calm, not shouted.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion here: it is an explicit command (trigger
clarity can be 2) and real guardrails are in range to reference (safety integration can be 2).
A 10 means the file meets the authoring standard, not that the step is proven in use; see
"Behavioral confirmation still owed".

## The seven round-2 required fixes, checked against the tree at HEAD
1. **Add the exit 2 row.** CLOSED. `:51`, contents verified against every `exit 2` site in the
   script, and enforced from now on by `tests/ledger-backup.test.sh:295-319`.
2. **Reword the exit 4 row to match the program.** CLOSED for the defect that was named (the
   staging mechanism at `bin/ledger-backup.sh:257-269` now makes the claim true for the copy
   phase, and `:53` cites it). Residual (a) and (b) above are new, narrower, and non-blocking.
3. **Update the description.** CLOSED. `:2` names the backup, the two files, and that it writes
   outside the repo. This is what moved trigger clarity 1 -> 2.
4. **Close the `:14` seam.** CLOSED. "If genuinely nothing notable happened, say so and skip to
   **step 5** ... The backup still runs: `todo.md` changes in almost every session, whether or
   not the session taught anyone anything." The one path that reaches no lesson now reaches the
   backup.
5. **One clause on the target in the exit 3 row.** CLOSED. `:52` names `CLAUDE.local.md` as
   "gitignored, right place for a private target", and `:59-62` states what the program cannot
   judge about a remote being public. Referenced, not restated.
6. **Make the table drift-proof with a test.** CLOSED, and better than asked: the assertion
   derives the code set from the script instead of hard-coding it, and its comment records why
   the first pattern under-matched (`tests/ledger-backup.test.sh:302-306`). This is the
   mechanism-at-the-point-of-use answer to a lesson that had already recurred twice.
7. **One clause on the `/retro` row of `docs/system-map.md`.** CLOSED (commit `ef829d0`,
   verified at HEAD). `:102` now reads "Then runs `ledger-backup.sh`, which copies the gitignored
   ledger (`todo.md`, `lessons.md`) to the recorded `ledger_backup:` target outside the repo and
   reports the result by exit code."

## The surrounding documents, checked against the skill and the program
In scope this round because they are what a user reads before invoking `/retro`.
- `WORKFLOW.md:648-674`. Matches. The three load-bearing claims are all true of the program:
  `CLAUDE.local.md` is read first (`bin/ledger-backup.sh:81`), the target is outside the
  repository in both kinds (the `dir` invariant at `:213-249`, the publish-remote refusal at
  `:310-317`), and "the 'last backup' stamp is written only after a verified success" matches
  `stamp_now` being called only at `:270`, `:352` and `:368`, never on the exit 4 or 5 paths.
  The warning at `:673` ("`/retro` is something you invoke") agrees with
  `disable-model-invocation: true`.
- `BEGINNERS-GUIDE.md`. Matches, at all three places the dispatcher named. Step table row 11
  (`:241`) "then the gitignored ledger backed up outside the repo", output column "plus your
  backup target"; the lessons section (`:325-332`) "If you haven't set one, Claude tells you
  once and offers to add the line", which is exactly the exit 3 row's contract including the
  once; quick guide step 12 (`:377-379`). No exit codes are quoted here, which is right for the
  beginner surface: nothing to drift.
- `docs/system-map.md:145`. Accurate as an exit-code summary ("2 the line or the state is
  refused, 3 not configured, 4 unreachable, 5 push refused, 6 nothing to back up") and it names
  the two refusals that carry the design. It inherits the same "4 = unreachable" shorthand as
  the skill's row, so residual (a) should be fixed in both places or neither.
- `project-templates/CLAUDE.md:84-96`. Consistent, and it is the reason the exit 3 row's
  placeholder clause exists: the template ships both example lines commented out (`:91-92`) and
  the program treats a live `<...>` value as not-configured (`bin/ledger-backup.sh:109-115`).
  The skill's `:52` handles that case separately ("offer to fill it in rather than to add a
  line"), which is the correct distinction.
No contradiction found between what these documents promise and what
`skills/retro/SKILL.md` plus `bin/ledger-backup.sh` do.

## Map duty
Satisfied. No new command surface; `/retro` is at `docs/system-map.md:102` with the backup
clause, and `ledger-backup.sh` has its own row at `:145`.

## Lint
Clean by inspection for the checks that apply to this file: C5 (every script it names exists:
`bin/ledger-backup.sh`), C7 (no em or en dash), C9 (non-empty description), C11 (no
version-pinned model name). C1, C3, C10 and C13 do not apply to this skill.

## Still open elsewhere (carried from rounds 1 and 2, outside this skill)
`docs/eval-framework.md` still states the review loop's APPROVE exit in the code/design rubric's
numbers only (">= 9 of 12"), while the same stop condition governs skill and agent reviews at
8/10 and the plan loop, which has no numeric score. Recorded, not scored, for the third time:
fix by phrasing the exit as "clears the threshold of the rubric in force for this artifact type
(code/UI 9/12, skill and agent 8/10, plan: no open Critical), no criterion at 0".

## Integrity
No sign of text copied from another project. Voice, terminology and every reference
(`.claude/tasks/lessons.md`, the published-snapshot rationale, `claude --continue`,
`ledger-backup.sh`) are this system's own.

## Top fixes
None blocking. Three small edits, in order of value:
1. **Split the configuration case out of the exit 4 row.** After "a copy that failed", add: "If
   the message says *no remote named X*, the `ledger_backup:` line names a remote this repo does
   not have: offer to fix the line or add the remote, do not treat it as a network problem."
   Then mirror the same distinction in `docs/system-map.md:145`, which carries the identical
   "4 unreachable" shorthand.
2. **Soften the one word the program does not guarantee.** In `:53`, "so this means the backup
   did not happen" -> "so the backup did not happen; if the message says the copy is incomplete,
   say that instead, some files may have landed". Keeps the honesty direction and matches
   `bin/ledger-backup.sh:267`.
3. **Make step 6 say the backup out loud.** `:70` currently reads "Briefly confirm what was
   written and where." Make it "Briefly confirm what was written and where, including the backup
   result from step 5 (its exit code decides what you may claim)." The rows already forbid the
   lie; the close-out step should point at them rather than leave it implicit.

## Behavioral confirmation still owed
Form only, and the form now meets the standard, so everything left is behavioral: does an agent
actually run the program, and does it report a failure as a failure rather than closing on the
lesson it did write? That is an `/improve` subagent test, not a review. Matrix cases worth
running, unchanged from round 2 except the last: (a) exit 5, does the close-out claim a backup;
(b) exit 3 twice in one session, does the offer stay quiet the second time; (c) the `:14` early
stop, is the backup still attempted now that the text says "skip to step 5"; (d) exit 2 from a
placeholder-shaped typo, does the agent offer to fix the line instead of reading it as "not
configured".

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
  mechanism at `bin/ledger-backup.sh:257-269`; and `tests/ledger-backup.test.sh:295-319` derives
  the required row set from the script, so the table cannot silently fall behind the program
  again). What did not move: structure and worked example, both already at 2, re-verified against
  the program at this HEAD rather than carried over. New this round, non-blocking: the exit 4 row
  labels a missing-remote configuration error as unreachability (same shorthand in
  `docs/system-map.md:145`), and its "the backup did not happen" is one word stronger than the
  program's message when the `dir` move loop fails partway. Also new this round: WORKFLOW.md 3.5,
  the three BEGINNERS-GUIDE.md passages and both system-map rows were checked against the skill
  and the script and agree with them.
