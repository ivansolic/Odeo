---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 994ede8fb51522f7b6896bf7e3e07e2843892baf
artifact_version: 18
date: 2026-09-17
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/build/SKILL.md` (330 lines, no supporting files), read at branch
HEAD `994ede8` against `docs/skill-authoring-standard.md`. This record REPLACES round 17's
(`2e7c740`). Focus beyond the full rubric pass: verifying the two cross-document fixes
`994ede8` applied in answer to round 17 (the `eval-framework.md` pointer, the
`plan-format.md` "Scored by" heading), and whether either created a new contradiction, in
particular with the `Threshold: total >= 8/10` line still sitting inside that same rubric
block.

## Did the artifact change since round 17? No.

Stated with its method, because I hold no shell and cannot run
`git diff 2e7c740..HEAD -- skills/build/SKILL.md`. What I did instead is stronger than
round 17's sampling: I read all 330 lines this round and compared them against every line
anchor and quotation the round-17 record made.

| Anchor quoted in round 17 | Text at that line at `994ede8` | Match |
|---|---|---|
| `:37` model-plan block opens | "**Model plan, asked before any work, and the BUILD model is the user's choice too.**" | yes |
| `:111` block closes | "a block: the choice is the user's." | yes, still exactly 75 lines |
| `:215` B5.2 heading | "2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:" | yes |
| `:219-221` plan-loop stop condition | "(`docs/eval-framework.md`: / clean, 3 rounds, or two consecutive rounds of the same defect class, / whichever comes first; a Critical is always reported)" | yes |
| `:264-268` code-loop stop condition | "The review LOOPS until clean: fix -> ... under the / same stop condition as the plan loop (3 rounds, or two consecutive rounds of / the same defect class, per the AGENTS.md review-loop rule...)" | yes |
| `:271` `boundary-check.sh` | "Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED)" | yes |
| `:278` B7 heading | "### B7. Gate + integrate (the merge is the user's move, full stop)" | yes |
| file length | last numbered line 330 | yes |

Every anchor resolves at the same line number with the same text, top, middle and end, and
the length is unchanged; an insertion or deletion anywhere would have shifted everything
below it. This remains an equivalence argument, not a git fact: only a diff proves a
no-op, and I could not run one. **This round therefore re-confirms an unchanged artifact
at a new commit.** The scores below are re-derived from the current text, not copied; the
cross-document verification is new work.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` with the description form the
  standard requires for explicit commands: what the user gets ("Build one or more ready
  user stories. Two modes you choose..."), plus the non-obvious invocation spelled out
  ("Name several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in
  parallel\""). No "Use when..." is wanted here; that form is for auto-invoked skills.
- structure **2**, and the trigger round 15 set still did not fire. That trigger: structure
  drops when the model-plan block passes 75 lines OR 25% of the file, or gains a subsection
  not tied to a named finding. Measured today: `:37-111` is exactly 75 lines of a 330-line
  file, 22.7%, identical to rounds 16 and 17. Body order follows the standard (essence
  `:6-7`, gates and mode choice, process per mode, worked example `:290-312`, output `:314`,
  safety rules `:321-329`). 330 of the 500-line limit, no supporting files, so the
  one-level-deep rule is satisfied trivially. The block sits ON the edge, so Top fix 1
  carries into a fourth round.
- worked example **2**. `:291-312` runs one real invocation end to end with real values: a
  story id (`USR-012`), a real plan path (`docs/plans/2026-07-14-usr-012-timer.md`), real
  frontmatter keys (`approved: no` -> `approved: yes`, `model_plan:`, `builder_tier: sonnet`),
  a real worktree path (`../dogfood-usr-012`), a real verdict shape ("code-reviewer 12/12
  APPROVE -> docs/evals/code-USR-012.md") and the explicit end of the skill's authority
  ("Run /merge when you want it integrated." `<- ENDS here`). Directly imitable. Restated so
  a future reviewer does not mis-flag it: `<session model>` at `:302` is NOT a placeholder
  failure under the standard's no-placeholders rule. It is the deliberate consequence of the
  never-fabricate-a-model rule at `:70-73` and `AGENTS.md:311-315`; a concrete model name
  there would be the defect.
- precision **2**. Exact paths, scripts and field names throughout, no TBDs and no "add X
  here": `spec-gate.sh <story paths...>` `:12`, `boundary-check.sh` `:271`,
  `worktree-parallel-check` `:161`, `resolve-language.sh <project-dir>` `:211`,
  `git worktree add ../<slug> -b feature/<slug>` `:135`, `code -r -g <file>` `:139`,
  `docs/plans/<date>-<slug>.md` `:208`, `arch_review: clean (v<N>, <date>)` `:224`,
  `builder_tier:` `:241`, `build_model_as_dispatched:` `:243`. Cross-references resolve in
  the direction they claim: `:236-237` says the builder's precondition list is authoritative
  in `agents/builder.md`, and `agents/builder.md` says exactly that of itself. The
  "LOOPS until clean" wording at `:265` is discussed under finding 2 below; after this
  round's reading it is an INHERITED ambiguity (the skill matches the file it cites) rather
  than a local inexactness, so it does not pull this criterion to "mostly exact".
- safety integration **2**. Guardrails are referenced, not restated or weakened:
  `AGENTS.md` Guardrail 3 + lint C11 for the no-model-names-in-files rule `:88`,
  `AGENTS.md` Guardrails 7 for the language handover `:213-214, :227-231, :256-259`,
  `docs/eval-framework.md` for the loop stop condition `:219-221`, `docs/plan-format.md` for
  the contract binding list `:154-155`. Enforced gates are named as enforced and as
  non-bypassable: `spec-gate.sh` "STOP on non-zero... Never work around it; if the gate is
  wrong, that is a bug to report, not to bypass" `:12-16`; `boundary-check.sh` "(ENFORCED)"
  `:271`; the plan gate "structural, not advisory" `:326`; the merge rule as a closed list of
  non-permissions `:282-284`. The partial embedding of the stop condition in the body is
  sanctioned by `AGENTS.md`'s embed-safety-critical-rules provision (so it holds when that
  file is absent, e.g. a marketplace install), not a violation of "never restate a guardrail".
  One coverage gap is recorded as finding 3 below; the criterion's 1 is "silent", and this
  file is emphatically not silent about guardrails, so the gap is a Top fix, not a score move.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: it is an explicit command (trigger
clarity can reach 2 on the what-you-get form), real guardrails and enforced scripts exist to
reference (safety integration can reach 2), and a concrete end-to-end example is present.

## Verification of the two fixes in `994ede8`

**Both landed, both are correct, and one of them leaves a residual that the same edit
should have closed.**

1. **Fix 1 landed.** `docs/eval-framework.md:200-201` now reads "recorded by the
   orchestrator as `arch_review: clean (v<N>, <date>)` in the plan's frontmatter, per
   `skills/build/SKILL.md`, mode B5 step 2". The anchor now lands: `skills/build/SKILL.md:205`
   is "### B5. Plan (architect), review the plan, then gate, then dispatch (builders)" and its
   step 2 at `:215` is the plan-review loop. The recorded format still matches the skill
   character for character (`:223-224`) and `docs/plan-format.md:53-55`. Round 17's Top fix 6
   is CLOSED. Two cosmetic leftovers of the edit, neither a finding: the line was not re-wrapped
   (`:201` runs ~99 chars where the paragraph wraps at ~88), and "mode B5 step 2" would read
   more plainly as "Mode B, section B5, step 2".
2. **Fix 2 landed, and went further than asked.** `docs/plan-format.md:199-206` no longer says
   "Scored by": it says "Applied by `architecture-reviewer` during plan review", and adds the
   paragraph "It is a checklist here, not a published score: that reviewer writes no eval
   record, and the plan loop stops on **clean**, not on a total (`docs/eval-framework.md`, the
   stop condition). The criteria below say what 'clean' has to cover; the numbers are for the
   reviewer's own reasoning and for a human reading the plan, and nothing reads them as a gate."
   That agrees with `docs/eval-framework.md:198-203` and with `agents/architecture-reviewer.md:16`
   ("findings ranked blocking / important / note, or state 'clean' explicitly") and `:38-39`
   ("You cannot write files; the orchestrating session records your verdict"). Round 17's Top
   fix 7 is CLOSED. **The residual is finding 1 below.**
3. **No new contradiction with the skill.** The skill is on the correct side of both edits
   already: `:222-224` says the reviewer "cannot write files" and has the orchestrator record
   `clean`, never a score, and `:215` names the loop's exit as clean. Nothing in the skill
   needed to move for either fix, and nothing in the skill now disagrees with either file.

## Findings

**1. New, cross-document, medium: `docs/plan-format.md:230` still says `Threshold: total >= 8/10 AND no criterion at 0.` inside the block the new prose just declared not to be a gate.**
The prose at `:202-206` and the fence at `:230` are four lines apart and say opposite things.
This matters more than a wording clash because "Threshold:" is a token with a fixed meaning
across this repo: `docs/skill-authoring-standard.md:99` and `agents/agent-rubric.md:37` use the
identical line to declare a real loop-stopping gate. So the same token means "gate" in two files
and "not a gate" in this one, and it is the fenced block, the extractable and skimmable unit,
that carries the wrong meaning while the correction sits in prose above it. It is also exactly
where a reader is SENT: `docs/eval-framework.md:189-195` routes "the threshold declared by the
rubric for THAT artifact type" to "`docs/plan-format.md`, the plan rubric", and the note that
overrides it is three lines further down. Fix inside the fence, where it will be read:
replace `:230` with "Clearing bar: **clean**, no blocking findings left. The 0-2 scores are the
reviewer's reasoning aid; no loop and no script reads a plan total (`docs/eval-framework.md`,
the stop condition, exit 1)." And make the table row at `docs/eval-framework.md:195` say
"no number, clears on **clean** (see the note below)" instead of pointing at a rubric that
declares a number it does not use.

**2. New, cross-document, medium: `AGENTS.md` states the review-loop exit TWICE, incompatibly, and `skills/build/SKILL.md:266` cites it by name.**
`AGENTS.md:39-41`: "approve, or three rounds on one artifact, or two consecutive rounds of the
same defect class, whichever comes first, with a Critical always overriding the cap".
`AGENTS.md:285-287`: "Stop conditions (a loop needs a stop): max score reached, or the reviewer
says no actionable fixes remain..., or 3 cycles." Those are different policies, not different
phrasings: at an APPROVE of 10/12 the first stops and the second continues. `docs/eval-framework.md:180-182`
is a third wording ("clears the threshold declared by the rubric for THAT artifact type").
This REFRAMES round 17's finding about `skills/build/SKILL.md:265` ("The review LOOPS until
clean" on a scored loop): the skill is faithful to the file it cites at `:266`, which sets the
bar at max score. So the fix is not a one-word edit in the skill first. Decide the policy once
(is the code loop's exit the rubric threshold, or max score?), write it in
`docs/eval-framework.md` only, reduce `AGENTS.md:285-287` to a pointer, and then word `:265`
to match. Rewording the skill alone would move the skill off the file it cites and onto a file
it does not, which is how this drift started.

**3. New, low, coverage: Guardrails 1's holder half is assigned to `/build`'s orchestrator and has no step in this skill.**
`AGENTS.md:229-234`: "A plan approval covers only the plan as approved... revising a declaring
plan after approval invalidates its consumers' approval and they return to the gate. Holder:
the orchestrating session at gate 1". `agents/architecture-reviewer.md:27-32` hands the same
half over explicitly ("Whether a declaring plan was revised after approval is a git fact you
cannot see; that half stays with the holder, the orchestrating session"). The orchestrating
session at gate 1 is this skill, and `skills/build/SKILL.md` contains no occurrence of "batch"
and no such step: B5.3 (`:232-237`) covers approve / change / reject without saying what a
post-approval revision does to the other plans in the batch. The path is reachable through
the skill's headline feature (several stories at once, `:2`, B3 `:173-183`). One sentence in
B5.3 closes it.

## Seams carried from round 17 (none block, none move a score)
- **Carried, fourth round: the model-plan block sits exactly on the 75-line structure
  trigger** (`:37-111`). The next inline addition costs the structure point.
- **Carried: two pointers for one rule inside one file.** `:219` cites
  `docs/eval-framework.md` (canonical); `:266` cites "the AGENTS.md review-loop rule", which
  finding 2 now shows is not one rule but two. Second hop, two places to keep true.
- **Carried: the two copies are not verbatim.** `:266` omits "whichever comes first", and its
  clearing exit lives in the lead-in prose rather than in the parenthesis, so `:266` reads as
  two exits where `:219-221` reads as three.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`). The full condition is
  one line below, so nobody is misled in context, but the heading is the skimmable line.
- **Carried: B5.4 does not say what to hand the human on stop.** The plan loop does (`:221-222`,
  "present the disagreement, the human arbitrates"); B5.4 ends at "the user sees first ->
  final score". `docs/eval-framework.md:208-211` asks for "what is still open, what moved
  between rounds, and what did not", and `:221-222` asks for the class in one phrase.
- **Carried, low: the `arch_review: waived (human)` path has no step in this skill.**
  `agents/builder.md` and `docs/plan-format.md:54-55` both allow a waiver for a human-supplied
  standalone plan; `:235-236` says only "an `arch_review:` line", which is compatible with the
  waiver. A coverage gap in the orchestrator's narrative, not a contradiction.
- **Context, not a finding: historical plan records model the old practice.**
  `docs/plans/2026-08-13-usr-006-prose-language-warning.md:337, :363, :434` record plan reviews
  as "`architecture-reviewer`, 8/10", and its frontmatter carries "8/10 -> 9/10 -> 9/10". Those
  records are history and are never re-dated, but anyone imitating a past plan will reproduce a
  scored plan review that `994ede8` just declared does not exist. If this proves confusing, the
  place to say so is `docs/plan-format.md`, one line, not the old records.

## Integrity
No sign of text copied from another project. The voice is this system's throughout, and every
cross-reference resolves inside this repo (`docs/eval-framework.md`, `AGENTS.md`,
`docs/plan-format.md`, `agents/builder.md`, `agents/architecture-reviewer.md`, `merge-gate.sh`,
`spec-gate.sh`, `boundary-check.sh`, `resolve-language.sh`, `worktree-parallel-check`).
Verified by opening the cited files, not by pattern.

## Map duty
Satisfied, nothing to update: no command surface was added or altered this round. `/build` is
catalogued at `docs/system-map.md:67` with both modes, its scripts at `:135-136`
(`coverage-check.sh`, `spec-gate.sh`), the overlap check at `:75`, and the flows at `:12-14`.
Not a finding.

## Top fixes
1. **Outside this skill, close the residual of this commit**: `docs/plan-format.md:230`,
   replace "Threshold: total >= 8/10 AND no criterion at 0." with "Clearing bar: **clean**, no
   blocking findings left. The 0-2 scores are the reviewer's reasoning aid; no loop and no
   script reads a plan total." and change `docs/eval-framework.md:195`'s row to "no number,
   clears on **clean** (see the note below)".
2. **Outside this skill, settle the review-loop exit once** (finding 2): one statement in
   `docs/eval-framework.md`, `AGENTS.md:285-287` reduced to a pointer, and only THEN reword
   `skills/build/SKILL.md:265` to name that exit instead of "clean".
3. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan`
   section, or move the resolution mechanics (model precedence, effort precedence, the
   source-tagging duty) into a supporting file one level deep. The block is exactly on the
   75-line trigger, fourth round.
4. **Add the batch sentence to B5.3** (finding 3): "If you revise a plan after it was
   approved, every plan in the batch that references its contracts returns to the gate
   (`AGENTS.md` Guardrails 1); you hold that half, the reviewer cannot see it."
5. **Add the stop handoff to B5.4**: "On stop, present what is still open, what moved between
   rounds and what did not, and name the class in one phrase; the human arbitrates."
6. **Make the two stop-condition parentheses verbatim identical, both citing the canonical
   file** (after fix 2 lands): use at `:266` the exact text already at `:219-221`.
7. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the line
   people skim carries the whole rule.
8. **Still the structural fix, still unbuilt: a `skills-lint.sh` C-rule** failing any skill or
   agent file that states a review round cap ("max 3", "3 rounds") without the
   same-defect-class clause in the same paragraph. Finding 2 shows the condition now lives in
   five written places with two different exit-1 policies, and nothing fails when one drifts.
   The repo's own Core Principle (eliminate the class, do not restate it) applied to the rule
   about loops.
9. **Optional, teaches the harder case**: one line in the worked example showing a STOPPED
   loop, e.g. "architecture-reviewer v2: same class as v1 (missing precondition on the same
   contract) -> loop stopped, presented for arbitration".

## Behavioral confirmation still owed
Form only, as always. Whether an agent stops at round two on a repeated class, names the class
in one phrase, and still reports a Critical found after the cap is an `/improve` subagent test.
The matrix case worth running is unchanged: round 2 raises a finding closed by the same kind of
fix as round 1, score still below threshold; the agent should stop AND say why rather than
spend round 3 because the cap allows it. Finding 2 adds a second case worth running once the
policy is settled: a code review that APPROVES below max score, where `AGENTS.md:285` and
`docs/eval-framework.md:180` currently disagree about whether the loop continues.

## Vs previous version
Round 17 (`2e7c740`) -> round 18 (`994ede8`), per criterion: trigger clarity 2 -> 2,
structure 2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total
10 -> 10. The ARTIFACT did not move (see the anchor table); the record moved because the branch
did. What moved around it is `994ede8`, which closed both of round 17's external Top fixes
(6 and 7): the framework's pointer now lands on B5 step 2, and the plan rubric no longer claims
to be scored. Both landed correctly and neither contradicts the skill. Three findings this
round, all outside the artifact: the `Threshold: total >= 8/10` line that survived inside the
de-scored rubric block, the two incompatible review-loop exits inside `AGENTS.md`, and the
unheld half of Guardrails 1 that two files assign to this skill's actor. Round 17's internal
`:265` seam is not resolved but is reclassified: it is inherited from `AGENTS.md`, so the fix
is upstream first. Round 15's structure fix carries into a fourth round. Nothing blocks merge.

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
- Round 12 (2026-08-10, Opus 5, strongest, sha NOT SUPPLIED): 8/10 PASS, incomplete record.
- Round 13 (2026-08-10, Opus 5, strongest, b8f7de7): 9/10 PASS.
- Round 14 (2026-08-10, Opus 5, strongest, 2f1c8b9): 10/10 PASS. Two Mediums handed forward.
- Round 15 (2026-08-25, Opus 4.8, strongest, e0ce263, branch fix/build-model-effort-source):
  10/10 PASS. Both round-14 Mediums closed (FU4a and FU4b); residuals were polish, led by the
  model-plan block sitting on the 75-line structure trigger.
- Round 16 (2026-09-16, Opus 5 [1M], strongest, fab5c0d, branch
  feature/windows-powershell-entry): 10/10 PASS. Scope: commit 54f3ab1, the whole stop
  condition now stated in both review loops (`:218-222`, `:264-268`), verified clause by
  clause against `docs/eval-framework.md:175-210` and `AGENTS.md:39-44`. Cross-document check:
  no competing cap survives; one live seam found in `docs/eval-framework.md:179` (the APPROVE
  threshold written in the 12-point rubric's units while governing loops scored 8/10 or not
  scored at all). Regenerated once, unchanged in scores or findings, after the dispatcher
  supplied the HEAD sha missing at first write.
- Round 17 (2026-09-17, Opus 5 [1M], strongest, 2e7c740, branch
  feature/windows-powershell-entry): 10/10 PASS. The SKILL was unchanged since round 16
  (established by re-resolving every round-16 line anchor plus the 330-line length; no shell),
  so that round re-confirmed an unchanged artifact at a new commit. New work: verification
  against `53f246e`, which rewrote `docs/eval-framework.md`'s stop condition; both directions
  agreed and round 16's Top fix 5 closed without an edit here. Two new seams found outside the
  file (`docs/eval-framework.md:201` pointing at "step 2" where the rule lives in B5 step 2;
  `docs/plan-format.md:200` heading the plan rubric "Scored by architecture-reviewer" while the
  framework and the agent say it publishes no score), one inside it (`:265` "LOOPS until clean"
  applied to a scored loop).
- Round 18 (2026-09-17, Opus 5 [1M], strongest, 994ede8, branch
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 17's. The SKILL is
  still unchanged (established this time by reading all 330 lines and matching them against
  every round-17 anchor and quotation; no shell, so no diff). `994ede8` closed both external
  round-17 fixes correctly and created no contradiction with the skill. Three new findings, all
  outside the artifact: `docs/plan-format.md:230` still declares "Threshold: total >= 8/10"
  inside the block whose new prose says nothing reads it as a gate, and
  `docs/eval-framework.md:195` still routes readers there; `AGENTS.md` states the review-loop
  exit twice and incompatibly (`:39-41` approve/3/class vs `:285-287` max score/no actionable
  fixes/3 cycles), which is the upstream cause of the `:265` seam rather than a skill defect;
  and the holder half of Guardrails 1 (a revised declaring plan returns its consumers to the
  gate) is assigned to this skill's actor by `AGENTS.md:232-234` and
  `agents/architecture-reviewer.md:27-32` but has no step in B5.3. Round 15's structure fix
  carries a fourth time.
