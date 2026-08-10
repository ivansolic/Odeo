---
artifact: skills/build/SKILL.md
type: skill
branch: fix/effort-readable-sources
reviewed_commit: 2f1c8b9b2050473425ef98dd5ee45f54ad6e04cf
artifact_version: 14
date: 2026-08-10
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: the whole file (306 lines), with the model-plan block at `skills/build/SKILL.md:37-103`
read clause by clause against `AGENTS.md:60-90` (the effort bullet, including the new
stop rule at `:72-84` and the read mechanism at `:82-83`), `docs/plan-format.md:24-49`,
and `docs/skill-authoring-standard.md`. Repo-wide sweep run for a second copy of the
source list and for the retired "first hit wins" wording. `docs/system-map.md:67,136`
checked for the map duty. Cycle 3 of 3 on this branch.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` with a description that says
  what the user gets and shows the non-obvious invocation: "Name several stories to
  build them in parallel, e.g. \"/build USR-001 USR-002 in parallel\"". Correct format
  for an explicit command; untouched this round.
- structure **2**. Body shape holds (essence, enforced spec gate, mode choice, both
  modes, worked example, after-building, safety rules); 306 lines against the 500 limit;
  no supporting files, so the one-level-deep rule is trivially satisfied. The model-plan
  block grew 64 -> 67 lines and still sits under `## 2. Pick the mode (ALWAYS ask, never
  infer)`. See "Should the structural Low block now" below: this growth is not the
  growth I warned about.
- worked example **2**. `:273` and `:278-279` carry the sourced effort on both roles
  ("effort high (configured, per CLAUDE_EFFORT)" / "builder_tier: sonnet effort high
  (plan is precise, work mechanical)"), which now also matches `:66`'s new
  `judgment:`-only source duty and `plan-format.md:35-38`'s intent-only `builder_tier:`.
  I re-checked every example line against the changed text for a repeat of round 12's
  defect (an example teaching a removed premise): nothing in it is now false. Real story
  id, real paths, real verdict shape, directly imitable. One omission, not a deduction:
  the example never shows the step-2 model branch, so the label added this round
  ("per the session-start environment") is stated but never demonstrated.
- precision **2**, up from 1. Both blockers I named for two rounds are closed, and
  closed in text, not by interpretation. (1) The stop rule: `AGENTS.md:73-74` now reads
  "READ ALL FOUR, do not stop at the first (a stop cannot detect a disagreement), then
  the HIGHEST-PRECEDENCE hit wins", and `SKILL.md:56` cites it in the same shape ("Read
  them ALL in one command and take the highest-precedence hit; stopping at the first
  would make a disagreement undetectable"). The round-13 loop is gone: the general rule
  no longer makes the exception unreachable, so "Two HITS that DISAGREE = report both by
  name and ask" (`:61-62`) is a reachable exception to a general rule, which is a valid
  structure rather than a contradiction. (2) The mechanism: `AGENTS.md:82-83` names it
  literally, "Read them with one shell command (`printenv CLAUDE_EFFORT` plus a `grep`
  for `effortLevel` across the three paths); a missing file or key is simply not a hit",
  which also settles the empty-file case that made source 3 a trap. With those closed,
  the rest of the file was already at this bar: `spec-gate.sh <story paths...>`,
  `boundary-check.sh`, `git worktree add ../<slug> -b feature/<slug>`, `code -r -g <file>`,
  `worktree-parallel-check`, and exact frontmatter keys (`approved:`, `arch_review:`,
  `builder_tier:`, `judgment:`, `build_model_as_dispatched:`). No placeholders, no TBDs.
  The two residual seams below are omissions of a labelling duty, not vagueness, and I
  am not withholding the point for defects I did not name as the blockers.
- safety integration **2**. References, never restates: `:56-57` "That list and its
  precedence are the single source; never keep a second copy of it here", and the sweep
  confirms it (the four sources appear only at `AGENTS.md:77-81`; `SKILL.md` carries a
  pointer plus spoken examples). `:64-66` ties an unsourced effort value to "the same
  fabrication the model rule above forbids", `:88` cites "`AGENTS.md` Guardrail 3, lint
  C11", `:98-99` cites the live-lineup resolution, `:229` cites `merge-gate.sh`'s
  comparison, `:9-16` refuses to work around `spec-gate.sh`, `:247` enforces
  `boundary-check.sh`. No guardrail copied or weakened.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing in this skill structurally caps a criterion: it is an explicit
command (so trigger clarity can be 2), it carries real guardrails to reference (so
safety integration can be 2), and it has a concrete worked example.

## Is precision now 2? Plainly: yes, both round-13 defects are closed
- **The contradiction is closed.** Round 13's problem was logical, not stylistic: "first
  hit wins" made the disagreement case undetectable, so the disagree clause could never
  fire and the two clauses described incompatible procedures. The new text reverses the
  order of operations (read all, THEN resolve), which makes the exception reachable.
  What survives is a redundancy, not an ambiguity: once "disagreement -> ask" fires in
  every case where two hits differ, "the highest-precedence hit wins" has work left only
  in the agreeing case, where it decides which source name you quote. The text does not
  say that out loud, but the behavior is determinate either way (disagree -> ask;
  agree -> the shared value, named by the highest-precedence source), so two agents act
  the same. One clause would make it explicit; it is not worth a point.
- **The mechanism is closed.** `printenv CLAUDE_EFFORT` plus a `grep` across three named
  paths is exactly the level of exactness the rest of the file uses, and "a missing file
  or key is simply not a hit" removes the last thing an agent had to invent.

## Did this fix open another defect? Yes, one that changes what two agents do
I tried to construct diverging pairs against each new clause. Three land, one of them
squarely on behavior.

**1. The sub-high nudge now evaluates an unproven premise (Medium, new, behavioral).**
`:98-100`: "If judgment would run below the strongest model in the CURRENT OFFICIAL
LINEUP ... OR below `high` effort, say so ... and for architecture-critical work
recommend switching up first." Before this branch the effort was ASKED, so the premise
of that conditional was always established. Now it is routinely a READ value that the
file itself insists is CONFIGURED, not confirmed (`:58-59`). The text never says whether
a configured sub-high value trips the nudge.
- Agent A reads `effortLevel: medium` in `~/.claude/settings.json`, treats the
  conditional as satisfied, and says "effort medium, configured, per
  `~/.claude/settings.json`, which is below high; for a plan I'd switch up, run
  `/effort`."
- Agent B reads the same value, reasons that a configured value does not establish that
  judgment "would run below `high`" (`:58-59` says so in as many words), and stays
  silent. It resolves the value, prints it with its source, and never raises the nudge.
Both follow the text exactly, on the same machine, and one of them withholds an
architecture-critical recommendation the block exists to make. Consequence is bounded
(a dismissible sentence either way, `:103` "If the user says it is not on their plan,
drop the point"), which is why it is a Medium and not a blocker, but it is a real
divergence and it is caused by this change: read-instead-of-ask is what turned a stated
value into a qualified one. Fix at `:98`: "a CONFIGURED value below `high` counts here
too; raise it with its source ('configured medium, per `CLAUDE_EFFORT`') so the user can
correct the source rather than the plan."

**2. Fix 4 closed the spoken asymmetry and opened a written one (Medium, new).**
`:45-47` now labels a session-start model in speech ("per the session-start
environment"). The writing duty six paragraphs later was not extended: `:92-96` requires
only that "An effort value that came from step 2 carries its source into the file as
well", and the stated reason is general, "a reader at the gate cannot otherwise tell a
read value from a confirmed one, and the plan is what a later reviewer trusts". That
reason applies verbatim to a session-start model.
- Agent A writes `judgment: <model> (per session-start environment) effort high
  (configured, per CLAUDE_EFFORT)`, reasoning by the stated rationale.
- Agent B writes `judgment: <model> effort high (configured, per CLAUDE_EFFORT)`,
  because the duty names the effort value only, and `plan-format.md:26-27` attaches the
  qualifier to a value that "was READ rather than stated by the user".
Divergence in the durable artifact the gate reads. Neither is dishonest (the harness did
report that name), so this is a provenance gap, not a fabrication path. There is a
second-order seam behind it: `plan-format.md:24` still describes `model_plan:` as
"resolved LIVE when the plan is written", which the newly blessed step-2 path does not
guarantee. Fix in one place: either extend `:92-96` to the model and say so in
`plan-format.md:24-25`, or state at `:45-47` why the model's source stays spoken-only.

**3. A step-1 effort value has no source literal (Low, new).**
`:51-52` "the value is always spoken with its source" and `:64-65` "Never print a bare
effort value with no source" cover step 1 too, but every literal template in the step
belongs to step 2 ("effort high, per `CLAUDE_EFFORT`") and carries the word CONFIGURED,
which is wrong for a value the user just produced with `/effort`. An agent must invent
the phrasing ("per your `/effort`") and infer that this one value is confirmed rather
than configured. `plan-format.md:26-27` resolves the written side; the spoken side is
inference. One parenthetical at `:53-54` closes it.

Nothing else. I checked the other four changes for collateral: the stop rule is now
identical in both files (no paired-copy drift, which was the recurring cause of the lost
point); `:66`'s naming of the `judgment:` child closes last round's Seam A against
`plan-format.md:24-29`; `AGENTS.md:72` now states that a live `/effort` outranks the
whole list, so a reader landing in the list learns step 1 exists (last round's Seam B);
and the `printenv`/`grep` mechanism introduces no permission or path hazard at this step,
because the model-plan step runs in the user's project root, where `.claude/settings*.json`
resolves unambiguously (builders never run it; they read `builder_tier:` from the plan).

## Should the structural Low block now?
**No, and this round's growth is not the growth I warned about.** Round 13 said another
round of growth in the same place costs the point. That warning targeted discretionary
padding. The 3 lines added here are the stop clause, the read pointer, the model source
label and the `judgment:` naming, i.e. Top fixes 1, 2, 4 and 5 of that same record.
Charging a point for text I required would make the rubric punish compliance, so I am
naming a mechanical trigger instead of repeating a mood:

structure drops to 1 when ANY of these is true.
1. The model-plan block passes **75 lines** or **25% of the file** (today: 67 lines, 22%).
2. The file passes **400 lines** (today: 306).
3. A new subsection lands under `## 2. Pick the mode` that is not a response to a named
   review finding.
4. The block gains a second reference-shaped list of anything (the source list is
   correctly delegated today; a second inline enumeration is the padding signal).
The structural answer remains Top fix 4 below, and it is now also the answer to the two
new seams: both are "a duty stated for one value and silent for its twin", which is what
a 67-line block spread across two topics under a third heading produces.

## Integrity
No sign of text copied from another project. The block is in this system's voice, and
every cross-reference (`AGENTS.md` Guardrail 3, lint C11, `plan-format.md`,
`agents/builder.md`, `merge-gate.sh`, `boundary-check.sh`, `spec-gate.sh`) resolves
inside this repo.

## Map duty
No command surface added or altered; `docs/system-map.md:67` carries `/build` with both
modes and `:136` carries `spec-gate.sh` as invoked by `/build`. Not a finding.

## Top fixes
1. `:98`, say that a CONFIGURED effort below `high` trips the nudge and is raised with
   its source. This is the only new finding that changes what two agents do.
2. `:92-96` + `plan-format.md:24-25`, extend the source-into-the-file duty to a
   session-start judgment model, or state why it stays spoken-only.
3. `:53-54`, give step 1 its own literal ("effort high, per your `/effort`") and say
   that this one value is confirmed, not configured.
4. Structure, the standing recommendation: lift `:37-103` into its own `## 3. Model
   plan` (renumbering below), or move the resolution mechanics to a supporting file and
   leave the spoken question in SKILL.md. 67 lines under "Pick the mode" is a section.
5. `:56-57`, one clause on what precedence decides once the disagree rule exists
   ("when the hits agree, quote the highest-precedence source").

## Round-by-round (this branch)
- Round 12 (sha not supplied): 8/10 PASS, record incomplete.
- Round 13 (b8f7de7): 9/10 PASS. Worked example restored; source resolvable; precision 1
  on the stop-vs-scan contradiction and the unnamed read mechanism.
- Round 14 (2f1c8b9): 10/10 PASS. Both precision blockers closed; one new behavioral
  Medium named (`:98`), one new provenance Medium (`:92-96`), one Low.

## Vs previous version
Round 13 -> round 14, per criterion: trigger clarity 2 -> 2, structure 2 -> 2, worked
example 2 -> 2, precision **1 -> 2**, safety integration 2 -> 2. Total 9 -> 10.
The point moved because the two blockers I named moved: the stop rule is now one rule
stated identically in both files, and the read is a named command. The recurring pattern
I flagged last round (every edit had to be checked against a paired copy, and one copy
kept disagreeing) did not recur this round, which is the first time on this branch.
It did not recur because the paired copies were made identical rather than because the
block was split, so the pattern's cause is still present; the new seams (a duty stated
for effort and silent for the model) are that same cause showing up in a new pair.
Three cycles is the limit, so this goes to the human with a PASS and two Mediums that
are next-edit material, not merge blockers.

## Behavioral confirmation still owed
This is form verification only. Whether an agent actually reads all four sources in one
call, names the file, labels the value CONFIGURED, asks instead of picking when two
disagree, and raises the sub-high nudge on a configured value, is an `/improve` subagent
test. The form is now good enough to test, and finding 1 is the case worth putting in
the test matrix: a machine with `CLAUDE_EFFORT` unset and `effortLevel: medium` in the
user file, where the two constructed agents above split.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL.
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS.
- Round 9 (2026-08-07, Opus 5, strongest, 995fde4): 10/10 PASS.
- Round 10 (2026-08-07, Opus 5, strongest, 0fcc65b): 10/10 PASS, regeneration.
- Round 11 (2026-08-07, Opus 5, strongest, 895b667): 10/10 PASS, regeneration.
- Round 12 (2026-08-10, Opus 5, strongest, sha NOT SUPPLIED): 8/10 PASS, incomplete
  record (no `reviewed_commit:` supplied and I would not invent one).
- Round 13 (2026-08-10, Opus 5, strongest, b8f7de7): 9/10 PASS. Both High findings
  closed; precision held at 1 on a new stop-vs-scan contradiction plus the unnamed read
  mechanism.
- Round 14 (2026-08-10, Opus 5, strongest, 2f1c8b9): 10/10 PASS. This record REPLACES
  round 13's. Precision 1 -> 2: the stop rule is now "read all four, then the
  highest-precedence hit wins" in `AGENTS.md:73-74` and cited in `SKILL.md:56`, and the
  mechanism is named (`printenv CLAUDE_EFFORT` + `grep`, `AGENTS.md:82-83`). Fixes 3
  (`AGENTS.md:72`, live `/effort` outranks the list), 4 (`SKILL.md:45-47`, model carries
  its source in speech) and 5 (`:66`, `judgment:` named) verified; last round's Seams A
  and B are closed. New: one behavioral Medium at `:98` (a CONFIGURED sub-high effort
  does not clearly trip the switch-up nudge) and one provenance Medium at `:92-96` (the
  model's source is spoken but not written into `model_plan:`). Structural Low does not
  block; a mechanical trigger for when it would is recorded above. Cycle 3 of 3: the
  remaining items go to the human, not to a fourth loop.
