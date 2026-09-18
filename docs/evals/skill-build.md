---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 0125901d9fbbb3bc62fd6629783e5ad69049f4c9
artifact_version: 19
date: 2026-09-18
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
HEAD `0125901` against `docs/skill-authoring-standard.md`. This record REPLACES round 18's
(`994ede8`). Focus beyond the full rubric pass: verifying the two cross-document fixes
`0125901` applied in answer to round 18 (the de-scored plan rubric in `docs/plan-format.md`,
the collapsed second stop condition in `AGENTS.md`), whether either created a new
contradiction, whether anything else in the tree still reads a NUMBER from the plan rubric,
and whether `docs/eval-framework.md`'s per-artifact table row for plans now agrees with
`docs/plan-format.md`.

## Did the artifact change since round 18? No.

Stated with its method, because I hold no shell and cannot run
`git diff 994ede8..HEAD -- skills/build/SKILL.md`. What I did instead: I read all 330 lines
and re-resolved every line anchor and quotation the round-18 record made, at both ends of
the file and in the middle.

| Anchor quoted in round 18 | Text at that line at `0125901` | Match |
|---|---|---|
| `:2` description | "Build one or more ready user stories. Two modes you choose..." | yes |
| `:12` spec gate | "`spec-gate.sh <story paths...>` (in `~/bin` or `bin/`) and STOP on" | yes |
| `:37` model-plan block opens | "**Model plan, asked before any work, and the BUILD model is the user's choice too.**" | yes |
| `:111` block closes | "a block: the choice is the user's." | yes, still exactly 75 lines |
| `:215` B5.2 heading | "2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:" | yes |
| `:219-221` plan-loop stop condition | "(`docs/eval-framework.md`: / clean, 3 rounds, or two consecutive rounds of the same defect class, / whichever comes first; a Critical is always reported)" | yes |
| `:224` recorded verdict format | "`arch_review: clean (v<N>, <date>)` plus a short findings-and-resolutions" | yes |
| `:264-268` code-loop stop condition | "The review LOOPS until clean: fix -> ... under the / same stop condition as the plan loop (3 rounds, or two consecutive rounds of / the same defect class, per the AGENTS.md review-loop rule...)" | yes |
| `:271` `boundary-check.sh` | "Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED)" | yes |
| `:278` B7 heading | "### B7. Gate + integrate (the merge is the user's move, full stop)" | yes |
| file length | last numbered line 330 | yes |

Every anchor resolves at the same line number with the same text, and the length is
unchanged; an insertion or deletion anywhere would have shifted everything below it. This
remains an equivalence argument, not a git fact: only a diff proves a no-op, and I could not
run one. **This round therefore re-confirms an unchanged artifact at a new commit.** The
scores below are re-derived from the current text, not copied; the cross-document
verification is new work. `Glob skills/build/**` returns `SKILL.md` alone, so "no supporting
files" is established, not assumed.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` `:3` with the description form the
  standard requires for explicit commands: what the user gets ("Build one or more ready user
  stories. Two modes you choose..." `:2`), plus the non-obvious invocation spelled out
  ("Name several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in
  parallel\""). No "Use when..." is wanted here; that form is for auto-invoked skills.
- structure **2**, and the trigger round 15 set still did not fire. That trigger: structure
  drops when the model-plan block passes 75 lines OR 25% of the file, or gains a subsection
  not tied to a named finding. Measured today: `:37-111` is exactly 75 lines of a 330-line
  file, 22.7%, identical to rounds 16, 17 and 18. Body order follows the standard (essence
  `:6-7`, gates and mode choice, process per mode, worked example `:290-312`, output `:314`,
  safety rules `:321-329`). 330 of the 500-line limit, no supporting files, so the
  one-level-deep rule is satisfied trivially. The block sits ON the edge, so Top fix 2
  carries into a fifth round.
- worked example **2**. `:291-312` runs one real invocation end to end with real values: a
  story id (`USR-012`), a real plan path (`docs/plans/2026-07-14-usr-012-timer.md`), real
  frontmatter keys (`approved: no` -> `approved: yes`, `model_plan:`, `builder_tier: sonnet`),
  a real worktree path (`../dogfood-usr-012`), a real verdict shape ("code-reviewer 12/12
  APPROVE -> docs/evals/code-USR-012.md") and the explicit end of the skill's authority
  ("Run /merge when you want it integrated." `<- ENDS here`). Directly imitable. Restated so
  a future reviewer does not mis-flag it: `<session model>` at `:302` is NOT a placeholder
  failure under the standard's no-placeholders rule. It is the deliberate consequence of the
  never-fabricate-a-model rule at `:70-73` and `AGENTS.md:324-332`; a concrete model name
  there would be the defect.
- precision **2**. Exact paths, scripts and field names throughout, no TBDs and no "add X
  here": `spec-gate.sh <story paths...>` `:12`, `boundary-check.sh` `:271`,
  `worktree-parallel-check` `:161`, `resolve-language.sh <project-dir>` `:211`,
  `git worktree add ../<slug> -b feature/<slug>` `:135`, `code -r -g <file>` `:139`,
  `docs/plans/<date>-<slug>.md` `:208`, `arch_review: clean (v<N>, <date>)` `:224`,
  `builder_tier:` `:241`, `build_model_as_dispatched:` `:243`. Cross-references resolve in
  the direction they claim: `:236-237` says the builder's precondition list is authoritative
  in `agents/builder.md`, and `agents/builder.md:17,:24` says exactly that of itself. The
  "LOOPS until clean" wording at `:265` is finding 4 below; it stays a seam and not a score
  move for the same reason as rounds 16-18 (the file is exact everywhere a path, field or
  script is named, and the loose word is inherited plain-language), but `0125901` has now
  removed the upstream blocker, so the edit is available this round.
- safety integration **2**. Guardrails are referenced, not restated or weakened:
  `AGENTS.md` Guardrail 3 + lint C11 for the no-model-names-in-files rule `:88`,
  `AGENTS.md` Guardrails 7 for the language handover `:213-214, :227-231, :256-259`,
  `docs/eval-framework.md` for the loop stop condition `:219-221`, `docs/plan-format.md` for
  the contract binding list `:154-155`. Enforced gates are named as enforced and as
  non-bypassable: `spec-gate.sh` "STOP on non-zero... Never work around it; if the gate is
  wrong, that is a bug to report, not to bypass" `:12-16`; `boundary-check.sh` "(ENFORCED)"
  `:271`; the plan gate "structural, not advisory" `:326`; the merge rule as a closed list of
  non-permissions `:282-284`. The partial embedding of the stop condition in the body is
  sanctioned by `AGENTS.md:5-7` (safety-critical rules embedded so they hold when that file is
  absent, e.g. a marketplace install), not a violation of "never restate a guardrail". The one
  coverage gap is finding 5; the criterion's 1 is "silent", and this file is emphatically not
  silent about guardrails, so the gap is a Top fix, not a score move.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: it is an explicit command (trigger
clarity can reach 2 on the what-you-get form), real guardrails and enforced scripts exist to
reference (safety integration can reach 2), and a concrete end-to-end example is present.

## Verification of the two fixes in `0125901`

**Both landed, both are correct, neither contradicts the skill, and each leaves one small
residual in a neighbouring line the same edit could have carried.**

1. **Fix 1 landed, inside the fence, as asked.** `docs/plan-format.md:230-234` no longer
   carries `Threshold: total >= 8/10 AND no criterion at 0.`. It now reads: "No threshold, and
   no score is published: the plan loop clears on CLEAN, meaning no real finding is left, and
   nothing downstream reads a number from here. The bar the reviewer works toward is every
   criterion at 2; anything below that is a finding to state, not a total to weigh.
   (`Threshold:` is the token the SCORED rubrics use to declare a gate, so it is deliberately
   absent here.)" That closes round 18's finding 1 at its sharpest point: the correction is
   now in the fenced, extractable unit rather than only in the prose above it, and the
   sentence about the token answers the precise reason the old line was dangerous
   (`docs/skill-authoring-standard.md:99` and `agents/agent-rubric.md:37` use that same token
   to declare real gates). It also agrees with the prose four lines up at `:200-206` instead
   of contradicting it.
2. **Fix 2 landed, and names the disagreement rather than hiding it.** `AGENTS.md:285-290` now
   reads: "The stop condition is declared ONCE, in `docs/eval-framework.md`, and is the one
   named a few lines above in this file; it is not restated here. A second copy said 'max
   score reached, or no actionable fixes remain, or 3 cycles', which DISAGREED with the source
   at every verdict between the threshold and the max: at an APPROVE of 10/12 the framework
   stops and that copy continued. Two stop conditions for one loop is not redundancy, it is a
   coin flip." The incompatible policy is gone. `AGENTS.md:39-44` survives as the single
   in-file statement and is clause-for-clause compatible with `docs/eval-framework.md:178-222`
   (approve / three rounds / two consecutive rounds of the same class, whichever comes first,
   Critical overriding the cap).
3. **No new contradiction inside `AGENTS.md`'s own paragraph.** The surviving lead-in
   (`:281-284`, "when any reviewer returns findings below the max score: apply the actionable
   fixes, re-dispatch ... and repeat") could have been read as a competing continuation rule,
   but `:291-295` resolves it explicitly for the case that used to be ambiguous: "A loop that
   stops short of max ends with three things, always: WHY max is not reachable ..., the
   residual findings AS THEY ARE ..., and the open decision handed to the human". So max is
   the BAR the loop works toward and the framework holds the EXIT, which is the same
   bar-versus-exit split fix 1 made in `docs/plan-format.md:231-233`. The two fixes are
   consistent with each other, which is the stronger result.
4. **No new contradiction with the skill.** The skill was already on the correct side of both
   edits and needed no move: `:222-224` has the reviewer unable to write files and the
   orchestrator recording `clean`, never a score; `:225-226` presents the plan-loop trajectory
   as finding COUNTS ("v1: 2 blocking findings -> v2: 1 -> v3: clean"), not as a score
   progression, which is exactly what a de-scored plan rubric requires; `:219-221` cites
   `docs/eval-framework.md` directly for the stop condition, so fix 2 shortened the path the
   skill's OTHER citation walks (`:266`) without invalidating either.

## Does anything else still read a number from the plan rubric?

**No live instruction file does.** Checked every reader of the plan rubric and of
`arch_review:` in the tree:
- `agents/architecture-reviewer.md:16-17` returns "findings ranked blocking / important /
  note, or state 'clean' explicitly" and cites `docs/plan-format.md` "rubric criterion 3"
  as a CHECKLIST ("that file is canonical; if this list differs, it wins"). No total, no
  threshold. `:38-39` repeats that it writes no file and the orchestrator records the verdict.
- `agents/builder.md:24` requires `arch_review:` to be non-`pending` ("clean (vN, date)" or
  the human waiver). A word, not a number.
- `AGENTS.md:307-309` says plans go "to clean, max 3". Consistent.
- `docs/second-opinion-protocol.md:63-67` and `skills/second-opinion-plan/SKILL.md:36,:41,:56`
  both route a plan second opinion into the `arch_review:` line and say
  `architecture-reviewer` writes no record. Consistent.
- `skills/build/SKILL.md:222-226` records `clean` and presents finding counts. Consistent.
- The only numbers left are HISTORY:
  `docs/plans/2026-08-13-usr-006-prose-language-warning.md:6,:337,:363,:434` record plan
  reviews as "`architecture-reviewer`, 8/10" with a "8/10 -> 9/10 -> 9/10" frontmatter
  trajectory. Records are never re-dated or migrated, so this is correct as-is; it is a
  copying hazard for anyone imitating a past plan, and round 18 already logged it as context.
  If it is ever worth answering, the place is one line in `docs/plan-format.md`, not the old
  records.

## Does `docs/eval-framework.md`'s table row for plans now agree with `plan-format.md`?

**Substantively yes, typographically not yet, and the gap is the same SHAPE as the one fix 1
just closed, which is why it is worth one more line of editing.**

`docs/eval-framework.md:189-195` is a table headed "Rubric that declares the threshold", and
the plan row reads: `| Implementation plan | docs/plan-format.md, the plan rubric (see the
note below) |`. Three lines under it, `:198-203` states the correction in full: "**The plan
loop is the one exit without a number.** `architecture-reviewer` writes no record and
publishes no score, so its clearing verdict is **clean** ... The plan rubric still governs
WHAT the reviewer checks; it just is not the thing the loop reads to stop."

So the reader is pointed at the note, the note is adjacent and unambiguous, and nothing in the
two files now asserts opposite facts. That is why this is a LOW finding and not the medium
round 18 raised. What survives is the skimmable-unit problem round 18 named: the table cell
answers the question "which rubric declares this artifact's threshold" by naming a rubric that
declares none, and the row is the extractable unit while the answer sits in prose below it.
Round 18's suggested wording still applies and still costs one cell:
`| Implementation plan | no number: the loop clears on **clean** (see the note below) |`.

## Findings

**1. Residual of fix 1, low: `docs/eval-framework.md:195` still names the plan rubric under a
column headed "Rubric that declares the threshold".**
Mitigated by "(see the note below)" and by `:198-203`, so no reader following the pointer is
misled; a reader skimming the table alone is. One-cell fix as quoted above.

**2. New, low, surfaced by fix 1: `docs/eval-framework.md:27` defines a rubric as something
that HAS a threshold.**
"A rubric = named criteria, scoring levels (0 to 2 per criterion), and a pass threshold (for
example: total >= 8/10 AND no criterion at 0)." After `0125901` the plan rubric is a rubric
with no threshold by design, which `:198` says in as many words. The definition and the
exception now sit 170 lines apart in one file with nothing connecting them. Fix, one clause at
`:27`: "...and a pass threshold, with one deliberate exception, the plan rubric, which
declares none (see the stop-condition section)."

**3. New, low, inside fix 2: the locator in `AGENTS.md:285-286` does not land.**
It says the stop condition "is the one named a few lines above in this file". The statement it
means is `AGENTS.md:39-44`, about 245 lines earlier and in a different section ("Agent-first
workflow"). A reader at `:285` scanning a few lines up finds nothing. Fix, same sentence:
"...and is the one stated in the Agent-first workflow section near the top of this file".

**4. Carried and now UNBLOCKED, low: `skills/build/SKILL.md:265` says the code review loop
"LOOPS until clean", and `:266` cites the rule by the longer path.**
"clean" is the word `docs/eval-framework.md:198-200` reserves for the plan loop, the one exit
with no number; the code loop's exit is an APPROVE clearing the threshold in
`agents/code-reviewer.md:91`. Round 18 correctly refused to fix this in the skill first,
because the skill was faithful to `AGENTS.md`, which then said two things. `0125901` settled
that, so the skill edit is now safe and is no longer blocked on anything. Two small moves,
both inside the skill: word `:265` as "The review LOOPS until the reviewer APPROVES (its
rubric's threshold, no criterion at 0)", and change `:266`'s citation from "per the AGENTS.md
review-loop rule" to `docs/eval-framework.md`, so both of this file's citations of one rule
point at the same canonical file instead of one direct and one second-hop.

**5. Carried, unfixed since round 18, low: Guardrails 1's holder half is assigned to `/build`'s
orchestrator and still has no step in this skill.**
`AGENTS.md:229-234`: "A plan approval covers only the plan as approved. When plans in a batch
reference each other's contracts, that is legal only within ONE batch approved at the same
gate; revising a declaring plan after approval invalidates its consumers' approval and they
return to the gate. Holder: the orchestrating session at gate 1 (the only actor that sees the
whole batch; a builder sees one plan)." `agents/architecture-reviewer.md:27-32` hands the same
half over explicitly: "Whether a declaring plan was revised after approval is a git fact you
cannot see; that half stays with the holder, the orchestrating session." The orchestrating
session at gate 1 is this skill. Re-established this round by grep, not by memory: the words
"batch" and "Guardrails 1" do not occur anywhere in `skills/build/SKILL.md` (its only
Guardrail references are 3 at `:88` and 7 at `:214, :231, :259`), and B5.3 `:232-237` covers
approve / change / reject without saying what a post-approval revision does to the other plans
in the batch. The path is reachable through the skill's headline feature, several stories at
one gate (`:2`, B3 `:173-183`). **Concrete one-sentence fix, to be added at the end of B5.3:**
"If you revise a plan after it was approved, every other plan in the batch that references its
contracts loses its approval and returns to this gate (`AGENTS.md` Guardrails 1); you hold
that half, `architecture-reviewer` cannot see it."
The human decides whether to take it: it is one sentence and closes a rule with a named
holder, against the cost of the model-plan-adjacent line budget noted in Top fix 2.

## Seams carried from round 18 (none block, none move a score)
- **Carried, fifth round: the model-plan block sits exactly on the 75-line structure trigger**
  (`:37-111`). The next inline addition costs the structure point, which is also the budget
  argument against finding 5's sentence being added anywhere but B5.3.
- **Carried: the two stop-condition copies inside the skill are not verbatim.** `:266` omits
  "whichever comes first", and its clearing exit lives in the lead-in prose rather than in the
  parenthesis, so `:266` reads as two exits where `:219-221` reads as three. Finding 4's edit
  is the moment to make them identical.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`). The full condition is
  one line below, so nobody is misled in context, but the heading is the skimmable line.
- **Carried: B5.4 does not say what to hand the human on stop.** The plan loop does (`:221-222`,
  "present the disagreement, the human arbitrates"); B5.4 ends at "the user sees first ->
  final score". `docs/eval-framework.md:208-211` asks for "what is still open, what moved
  between rounds, and what did not", and `:212-222` asks for the class in one phrase.
- **Carried, low: the `arch_review: waived (human)` path has no step in this skill.**
  `agents/builder.md:24` and `docs/plan-format.md:53-55` both allow a waiver for a
  human-supplied standalone plan; `:235-236` says only "an `arch_review:` line", which is
  compatible with the waiver but never names it.
- **Context, not a finding: historical plan records model the retired scored practice**
  (`docs/plans/2026-08-13-usr-006-prose-language-warning.md:6,:337,:363,:434`). See the
  number-readers section above.

## Integrity
No sign of text copied from another project. The voice is this system's throughout, and every
cross-reference resolves inside this repo (`docs/eval-framework.md`, `AGENTS.md`,
`docs/plan-format.md`, `agents/builder.md`, `agents/architecture-reviewer.md`,
`agents/code-reviewer.md`, `merge-gate.sh`, `spec-gate.sh`, `boundary-check.sh`,
`resolve-language.sh`, `worktree-parallel-check`). Verified by opening the cited files, not by
pattern.

## Map duty
Satisfied, nothing to update: no command surface was added or altered this round. `/build` is
catalogued at `docs/system-map.md:67` with both modes, its scripts at `:135-136`
(`coverage-check.sh`, `spec-gate.sh`), the overlap check at `:75`, and the flows at `:12-14`.
Not a finding.

## Top fixes
1. **Finish this commit's two neighbouring lines** (findings 1-3), all outside the skill, all
   one line each: `docs/eval-framework.md:195` -> "no number: the loop clears on **clean** (see
   the note below)"; `docs/eval-framework.md:27` -> add "with one deliberate exception, the plan
   rubric, which declares none"; `AGENTS.md:285-286` -> "the one stated in the Agent-first
   workflow section near the top of this file".
2. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan`
   section, or move the resolution mechanics (model precedence, effort precedence, the
   source-tagging duty) into a supporting file one level deep. The block is exactly on the
   75-line trigger, fifth round, and every other fix below wants to add a line.
3. **Take the now-unblocked wording fix inside the skill** (finding 4): `:265` "LOOPS until the
   reviewer APPROVES (its rubric's threshold, no criterion at 0)" and `:266` citing
   `docs/eval-framework.md` instead of "the AGENTS.md review-loop rule".
4. **Add the batch sentence to B5.3** (finding 5), verbatim as quoted there.
5. **Add the stop handoff to B5.4**: "On stop, present what is still open, what moved between
   rounds and what did not, and name the class in one phrase; the human arbitrates."
6. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the line
   people skim carries the whole rule.
7. **Still the structural fix, still unbuilt: a `skills-lint.sh` C-rule** failing any skill or
   agent file that states a review round cap ("max 3", "3 rounds") without the
   same-defect-class clause in the same paragraph. `0125901` removed the one copy that
   DISAGREED, which is the right fix and not a durable one: the condition is still written in
   four places, and nothing fails when one of them drifts again. The repo's own Core Principle
   (eliminate the class, do not restate it) applied to the rule about loops.
8. **Optional, teaches the harder case**: one line in the worked example showing a STOPPED
   loop, e.g. "architecture-reviewer v2: same class as v1 (missing precondition on the same
   contract) -> loop stopped, presented for arbitration".

## Behavioral confirmation still owed
Form only, as always. Whether an agent stops at round two on a repeated class, names the class
in one phrase, and still reports a Critical found after the cap is an `/improve` subagent test.
The matrix case worth running is unchanged: round 2 raises a finding closed by the same kind of
fix as round 1, score still below threshold; the agent should stop AND say why rather than
spend round 3 because the cap allows it. Round 18's second proposed case is now RUNNABLE
because the policy is settled: a code review that APPROVES below max score, where the loop must
stop and hand over the residual per `AGENTS.md:291-295` rather than spend another round.

## Vs previous version
Round 18 (`994ede8`) -> round 19 (`0125901`), per criterion: trigger clarity 2 -> 2,
structure 2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total
10 -> 10. The ARTIFACT did not move (see the anchor table); the record moved because the branch
did. What moved around it is `0125901`, which closed two of round 18's three findings: the
plan rubric's fence no longer declares a threshold it does not use, and `AGENTS.md` no longer
states the review loop's exit twice and incompatibly. Both landed correctly, they are
consistent with each other (both split "the bar" from "the exit"), and neither contradicts the
skill, which already sat on the correct side of both. Nothing else in the tree reads a number
from the plan rubric; the only numbers left are in a historical plan record, which is correct
as history. Three low findings this round, all outside the artifact and all one line
(`eval-framework.md:195`, `eval-framework.md:27`, `AGENTS.md:285-286`), plus round 18's third
finding still open (Guardrails 1's holder half, no step in B5.3) and its `:265` seam now
unblocked for an in-skill edit. Round 15's structure fix carries a fifth time. Nothing blocks
merge.

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
  feature/windows-powershell-entry): 10/10 PASS. The SKILL was still unchanged (established by
  reading all 330 lines and matching them against every round-17 anchor and quotation; no
  shell, so no diff). `994ede8` closed both external round-17 fixes correctly and created no
  contradiction with the skill. Three new findings, all outside the artifact:
  `docs/plan-format.md:230` still declared "Threshold: total >= 8/10" inside the block whose
  new prose said nothing reads it as a gate, and `docs/eval-framework.md:195` still routed
  readers there; `AGENTS.md` stated the review-loop exit twice and incompatibly (`:39-41`
  approve/3/class vs `:285-287` max score/no actionable fixes/3 cycles), which was the upstream
  cause of the `:265` seam rather than a skill defect; and the holder half of Guardrails 1 (a
  revised declaring plan returns its consumers to the gate) is assigned to this skill's actor
  by `AGENTS.md:232-234` and `agents/architecture-reviewer.md:27-32` but has no step in B5.3.
- Round 19 (2026-09-18, Opus 5 [1M], strongest, 0125901, branch
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 18's. The SKILL is
  still unchanged (established by reading all 330 lines and re-resolving every round-18 anchor
  and quotation, plus `Glob skills/build/**` for the no-supporting-files claim; no shell, so no
  diff). `0125901` closed round-18 findings 1 and 2 correctly and consistently with each other:
  `docs/plan-format.md:230-234` replaces the `Threshold:` line with "No threshold, and no score
  is published: the plan loop clears on CLEAN", stating that the token is deliberately absent;
  `AGENTS.md:285-290` reduces the second stop condition to a pointer at
  `docs/eval-framework.md` and names the disagreement it removed. Verified additionally: no
  live instruction file reads a number from the plan rubric (only the historical usr-006 plan
  does, correctly, as history), and `docs/eval-framework.md:195` now agrees with
  `docs/plan-format.md` substantively while its table cell still names the plan rubric under a
  "declares the threshold" column, mitigated by "(see the note below)". Three new LOW findings,
  all one-line and all outside the skill (`eval-framework.md:195`, `eval-framework.md:27`'s
  rubric definition, the "a few lines above" locator in `AGENTS.md:285-286`). Round 18's third
  finding (Guardrails 1's holder half missing from B5.3; "batch" still absent from the file,
  re-established by grep) remains open with a concrete one-sentence fix for the human to
  decide. The `:265` "LOOPS until clean" seam is now unblocked for an in-skill edit, since the
  upstream policy it was faithful to is settled. Round 15's structure fix carries a fifth time.