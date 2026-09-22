---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: b3b66f71606cedb13701b1875e1b2419ca572be3
artifact_version: 20
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

Scope: the whole `skills/build/SKILL.md` (330 lines, no supporting files), read at branch
HEAD `b3b66f7` against `docs/skill-authoring-standard.md`. This record REPLACES round 19's
(`0125901`). `b3b66f7` touched `bin/ledger-backup.sh`, its test suite,
`bin/docs-claims-check.sh` and `README.md`, none of which this skill points at, so this round
is primarily a RE-ANCHOR: the merge gate compares `reviewed_commit:` against the code being
merged, and a record anchored at `0125901` would refuse the merge even though nothing this
skill depends on moved. The work beyond re-scoring: re-establishing that the artifact is
unchanged, re-resolving every cross-reference the skill makes, and restating the four carried
findings with their status at HEAD.

## Did the artifact change since round 19? No.

Stated with its method, because I hold no shell and cannot run
`git diff 0125901..HEAD -- skills/build/SKILL.md`. What I did instead: read the file in full
and re-resolve every line anchor round 19 quoted, at both ends and in the middle. An insertion
or deletion anywhere shifts every anchor below it, so anchors holding at the top, the middle
and the bottom plus an unchanged length is a strong equivalence argument.

| Anchor quoted in round 19 | Text at that line at `b3b66f7` | Match |
|---|---|---|
| `:2` description | "Build one or more ready user stories. Two modes you choose..." | yes |
| `:12` spec gate | "`spec-gate.sh <story paths...>` (in `~/bin` or `bin/`) and STOP on" | yes |
| `:37` model-plan block opens | "**Model plan, asked before any work, and the BUILD model is the user's choice too.**" | yes |
| `:111` block closes | "a block: the choice is the user's." | yes, still exactly 75 lines |
| `:215` B5.2 heading | "2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:" | yes |
| `:219-221` plan-loop stop condition | "(`docs/eval-framework.md`: / clean, 3 rounds, or two consecutive rounds of the same defect class, / whichever comes first; a Critical is always reported)" | yes |
| `:224` recorded verdict format | "`arch_review: clean (v<N>, <date>)` plus a short findings-and-resolutions" | yes |
| `:264-268` code-loop stop condition | "The review LOOPS until clean: fix -> / same reviewer re-verifies and regenerates the record -> repeat, under the / same stop condition as the plan loop (3 rounds, ...)" | yes, and see the correction below |
| `:271` `boundary-check.sh` | "Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED)" | yes |
| `:278` B7 heading | "### B7. Gate + integrate (the merge is the user's move, full stop)" | yes |
| `:290-312` worked example fence | "## Worked example" at `:290`, closing fence at `:312` | yes |
| `:321-329` safety rules | "## Safety rules" at `:321`, last bullet at `:329` | yes |
| file length | last numbered line 330 | yes |

`Glob skills/build/**` returns `SKILL.md` alone, so "no supporting files" is established, not
assumed. **This round therefore re-confirms an unchanged artifact at a new commit.** The scores
below are re-derived from the current text, not copied.

**One correction to round 19's own prose, not a change in the file.** Round 19's anchor table
cited the code-loop block as `:264-268` (correct) but its finding 4 and Top fix 3 cited the
"LOOPS until clean" wording at `:265`. The sentence begins at `:264`
("pushback allowed, you arbitrate. The review LOOPS until clean: fix ->") and the citation to
be changed sits at `:267` ("per the AGENTS.md review-loop rule"). This is an off-by-one
inherited from round 17, not evidence of a shifted file: everything below (`:271`, `:278`,
`:290`, `:321`, length 330) resolves unchanged, which an inserted line could not do. Finding 4
below is re-anchored accordingly so the human edits the right lines.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` `:3` with the description form the
  standard requires for explicit commands: what the user gets ("Build one or more ready user
  stories. Two modes you choose..." `:2`), plus the non-obvious invocation spelled out
  ("Name several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in
  parallel\""). No "Use when..." is wanted here; that form is for auto-invoked skills
  (`docs/skill-authoring-standard.md:17-19`).
- structure **2**, and the trigger round 15 set still did not fire. That trigger: structure
  drops when the model-plan block passes 75 lines OR 25% of the file, or gains a subsection not
  tied to a named finding. Measured today: `:37-111` is exactly 75 lines of a 330-line file,
  22.7%, identical to rounds 16-19. Body order follows the standard (essence `:6-7`, gates and
  mode choice, process per mode, worked example `:290-312`, output `:314`, safety rules
  `:321-329`). 330 of the 500-line limit, no supporting files, so the one-level-deep rule is
  satisfied trivially. The block sits ON the edge, so Top fix 2 carries into a sixth round.
- worked example **2**. `:291-312` runs one real invocation end to end with real values: a story
  id (`USR-012`), a real plan path (`docs/plans/2026-07-14-usr-012-timer.md`), real frontmatter
  keys (`approved: no` -> `approved: yes`, `model_plan:`, `builder_tier: sonnet`), a real
  worktree path (`../dogfood-usr-012`), a real verdict shape ("code-reviewer 12/12 APPROVE ->
  docs/evals/code-USR-012.md") and the explicit end of the skill's authority ("Run /merge when
  you want it integrated." `<- ENDS here`). Directly imitable. Restated so a future reviewer
  does not mis-flag it: `<session model>` at `:302` is NOT a placeholder failure under the
  no-placeholders rule. It is the deliberate consequence of the never-fabricate-a-model rule at
  `:70-73` and `AGENTS.md:315-319`; a concrete model name there would be the defect.
- precision **2**. Exact paths, scripts and field names throughout, no TBDs and no "add X here":
  `spec-gate.sh <story paths...>` `:12`, `boundary-check.sh` `:271`, `worktree-parallel-check`
  `:161`, `resolve-language.sh <project-dir>` `:211`, `git worktree add ../<slug> -b
  feature/<slug>` `:135`, `code -r -g <file>` `:139`, `docs/plans/<date>-<slug>.md` `:208`,
  `arch_review: clean (v<N>, <date>)` `:224`, `builder_tier:` `:241`,
  `build_model_as_dispatched:` `:243`. Every named script exists in this tree
  (`bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`, verified by listing
  `bin/*.sh`). Cross-references resolve in the direction they claim: `:236-237` says the
  builder's precondition list is authoritative in `agents/builder.md`, and
  `agents/builder.md:16` says exactly that of itself ("This list is AUTHORITATIVE for WHICH
  preconditions exist"), with `:19-24` carrying `approved: yes`, `builder_tier:` and a
  non-`pending` `arch_review:`. The "LOOPS until clean" wording at `:264` is finding 4 below; it
  stays a seam and not a score move for the same reason as rounds 16-19 (the file is exact
  everywhere a path, field or script is named, and the loose word is inherited plain language).
- safety integration **2**. Guardrails are referenced, not restated or weakened, and each
  reference lands: `AGENTS.md` Guardrail 3 + lint C11 for the no-model-names-in-files rule
  `:88` (`AGENTS.md:315-317`, "Model tiers, never versions: version-pinned model ids are banned
  in skills/agents"); `AGENTS.md` Guardrails 7 for the language handover `:213-214, :227-231,
  :256-259` (`AGENTS.md:395-402`, including the dispatcher duty on EVERY dispatch and the
  fallback chain, which is what the skill cites it for); `docs/eval-framework.md` for the loop
  stop condition `:219-221` (`docs/eval-framework.md:175-236`, clause for clause);
  `docs/plan-format.md` for the contract binding list `:154-155`. Enforced gates are named as
  enforced and as non-bypassable: `spec-gate.sh` "STOP on non-zero... Never work around it; if
  the gate is wrong, that is a bug to report, not to bypass" `:12-16`; `boundary-check.sh`
  "(ENFORCED)" `:271`; the plan gate "structural, not advisory" `:326`; the merge rule as a
  closed list of non-permissions `:282-284`, which matches `AGENTS.md:222-226` counter for
  counter. The partial embedding of the stop condition in the body is sanctioned by
  `AGENTS.md:5-7` (safety-critical rules embedded so they hold when that file is absent, e.g. a
  marketplace install), not a violation of "never restate a guardrail". The one coverage gap is
  finding 5; the criterion's 1 is "silent", and this file is emphatically not silent about
  guardrails, so the gap is a Top fix, not a score move.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: it is an explicit command (trigger
clarity can reach 2 on the what-you-get form), real guardrails and enforced scripts exist to
reference (safety integration can reach 2), and a concrete end-to-end example is present.

## Cross-reference re-check at `b3b66f7`

All five targets still exist and still say what the skill claims. Verified by opening them, not
by memory:

1. **`docs/eval-framework.md`, the stop condition** (`:175-236`). Still three exits in this
   order: APPROVE/PASS clearing the rubric's threshold with no criterion at 0 and no Critical
   (`:180-183`), three rounds (`:208-211`), two consecutive rounds of the same class
   (`:212-222`), "whichever comes first" implied by "the FIRST of these" `:178`, with a Critical
   always overriding the cap `:234-236`. The skill's `:219-221` reproduces it correctly.
2. **`docs/eval-framework.md`, the per-artifact threshold table** (`:189-196`). Unchanged since
   round 19, including the plan row `:195` and the note at `:198-203`. Finding 1 below.
3. **`docs/plan-format.md`, the plan rubric** (`:199-235`). Still de-scored: the prose at
   `:200-206` ("It is a checklist here, not a published score... the plan loop stops on
   **clean**, not on a total") and the closing line inside the fence at `:230-234` ("No
   threshold, and no score is published... `Threshold:` is the token the SCORED rubrics use to
   declare a gate, so it is deliberately absent here"). No `Threshold:` line. The skill's
   `:222-226` (records `clean`, presents finding counts, never a score) is consistent.
4. **`AGENTS.md` Guardrail 3** (`:267-319`). Carries what the skill cites at `:88`: lint C11 and
   the tiers-never-versions ban, `:315-317`; and the plan-review loop "to clean, max 3" at
   `:307-309`, consistent with the skill's B5.2 heading.
5. **`AGENTS.md` Guardrails 7** (`:395-431`). Carries what the skill cites three times: resolve
   with `resolve-language.sh <project-dir>` or the handed value `:396-398`, the dispatcher duty
   on EVERY dispatch including re-dispatches in a review loop `:399-401`, and the fallback chain
   (handed line, else the project's `CLAUDE.md`, else English and say so) `:401-402`.
6. **Scripts exist:** `bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`
   are all present in `bin/`. `worktree-parallel-check` is catalogued as a command at
   `docs/system-map.md:75`.

Nothing in `b3b66f7` (ledger backup, its tests, the README claims checker, the README) is read
by this skill. `bin/docs-claims-check.sh` verifies countable claims in `README.md` only
(`:30`, `:40-56`); it does not read `skills/`, so it imposes no new duty here.

## Findings (the four carried from round 19, plus one)

**1. STANDS, low, outside the skill: `docs/eval-framework.md:195` still names the plan rubric
under a column headed "Rubric that declares the threshold" (`:189`), while that rubric declares
none.**
Mitigated by "(see the note below)" in the cell and by the note at `:198-203`, so no reader who
follows the pointer is misled; a reader skimming the table alone is, and the row is the
extractable unit. One-cell fix, unchanged:
`| Implementation plan | no number: the loop clears on **clean** (see the note below) |`.

**2. STANDS, low, outside the skill: `docs/eval-framework.md:26-27` defines a rubric as
something that HAS a threshold.**
"A rubric = named criteria, scoring levels (0 to 2 per criterion), and a pass threshold (for
example: total >= 8/10 AND no criterion at 0)." The plan rubric is, by design since `0125901`, a
rubric with no threshold, which `:198` states in as many words, 171 lines later, with nothing
connecting the two. One-clause fix at `:27`: "...and a pass threshold, with one deliberate
exception, the plan rubric, which declares none (see the stop-condition section)."

**3. STANDS, low, outside the skill: the locator in `AGENTS.md:285-286` does not land.**
It says the stop condition "is the one named a few lines above in this file". The statement it
means is `AGENTS.md:39-41` ("The REVIEW loop's own stop condition is declared in
`docs/eval-framework.md`: approve, or..."), 246 lines earlier and in a different section
("Agent-first workflow"). A reader at `:285` scanning a few lines up finds nothing. One-sentence
fix, same line: "...and is the one stated in the Agent-first workflow section near the top of
this file".

**4. STANDS, low, inside the skill, still unblocked, now correctly anchored:
`skills/build/SKILL.md:264` says the code review loop "LOOPS until clean", and `:267` cites the
rule second-hand.**
"clean" is the word `docs/eval-framework.md:198-200` reserves for the plan loop, the one exit
with no number; the code loop's exit is an APPROVE clearing the threshold declared in
`agents/code-reviewer.md:91` ("no dimension at 0, total >= 9/12"). Round 18 correctly refused to
fix this in the skill while `AGENTS.md` still said two things; `0125901` settled that, so the
edit has been safe since. Two moves, both inside the skill, both one line, at the corrected
anchors: word `:264` as "The review LOOPS until the reviewer APPROVES (its rubric's threshold,
no criterion at 0)", and change `:267`'s citation from "per the AGENTS.md review-loop rule" to
`docs/eval-framework.md`, so both of this file's citations of one rule point at the same
canonical file instead of one direct and one second-hop.

**5. STANDS, low, inside the skill, open since round 18: Guardrails 1's holder half is assigned
to `/build`'s orchestrator and still has no step in this skill.**
Listed here because it is still open, though it was not among the four the dispatcher named.
`AGENTS.md:229-234`: "A plan approval covers only the plan as approved. When plans in a batch
reference each other's contracts, that is legal only within ONE batch approved at the same gate;
revising a declaring plan after approval invalidates its consumers' approval and they return to
the gate. Holder: the orchestrating session at gate 1 (the only actor that sees the whole batch;
a builder sees one plan)." Re-established this round by grep, not memory: "batch" and
"Guardrails 1" return ZERO matches in `skills/build/SKILL.md`, and B5.3 `:232-237` covers
approve / change / reject without saying what a post-approval revision does to the other plans
in the batch. The path is reachable through the skill's headline feature, several stories at one
gate (`:2`, B3 `:173-183`). **One-sentence fix, at the end of B5.3:** "If you revise a plan
after it was approved, every other plan in the batch that references its contracts loses its
approval and returns to this gate (`AGENTS.md` Guardrails 1); you hold that half,
`architecture-reviewer` cannot see it."

## Seams carried (none block, none move a score)
- **Carried, sixth round: the model-plan block sits exactly on the 75-line structure trigger**
  (`:37-111`). The next inline addition costs the structure point, which is also the budget
  argument for putting finding 5's sentence in B5.3 and nowhere else.
- **Carried: the two stop-condition copies inside the skill are not verbatim.** `:266-268` omits
  "whichever comes first", and its clearing exit lives in the lead-in prose rather than in the
  parenthesis, so it reads as two exits where `:219-221` reads as three. Finding 4's edit is the
  moment to make them identical.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`). The full condition is one
  line below, so nobody is misled in context, but the heading is the skimmable line.
- **Carried: B5.4 does not say what to hand the human on stop.** The plan loop does (`:221-222`,
  "present the disagreement, the human arbitrates"); B5.4 ends at "the user sees first -> final
  score". `docs/eval-framework.md:208-211` asks for "what is still open, what moved between
  rounds, and what did not", and `:212-222` asks for the class in one phrase.
- **Carried, low: the `arch_review: waived (human)` path has no step in this skill.**
  `agents/builder.md:24` and `docs/plan-format.md` both allow a waiver for a human-supplied
  standalone plan; `:235-236` says only "an `arch_review:` line", compatible with the waiver but
  never naming it.
- **Context, not a finding: historical plan records model the retired scored practice**
  (`docs/plans/2026-08-13-usr-006-prose-language-warning.md`). Records are never re-dated or
  migrated, so this is correct as history; it is only a copying hazard for anyone imitating an
  old plan.

## Integrity
No sign of text copied from another project. The voice is this system's throughout, and every
cross-reference resolves inside this repo (`docs/eval-framework.md`, `AGENTS.md`,
`docs/plan-format.md`, `agents/builder.md`, `agents/code-reviewer.md`, `docs/system-map.md`,
`bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`). Verified by opening the
cited files, not by pattern.

## Map duty
Satisfied, nothing to update: no command surface was added or altered this round. `/build` is
catalogued at `docs/system-map.md:67` with both modes, its scripts at `:135-136`
(`coverage-check.sh`, `spec-gate.sh`), the overlap check at `:75`, and the flows at `:12-13`.
Not a finding.

## Top fixes
1. **The three one-line neighbours outside the skill** (findings 1-3), decidable as a batch
   after the merge: `docs/eval-framework.md:195` -> "no number: the loop clears on **clean** (see
   the note below)"; `docs/eval-framework.md:27` -> add "with one deliberate exception, the plan
   rubric, which declares none"; `AGENTS.md:285-286` -> "the one stated in the Agent-first
   workflow section near the top of this file".
2. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan`
   section, or move the resolution mechanics (model precedence, effort precedence, the
   source-tagging duty) into a supporting file one level deep. The block is exactly on the
   75-line trigger, sixth round, and every other fix below wants to add a line.
3. **Take the unblocked wording fix inside the skill** (finding 4, corrected anchors): `:264`
   "LOOPS until the reviewer APPROVES (its rubric's threshold, no criterion at 0)" and `:267`
   citing `docs/eval-framework.md` instead of "the AGENTS.md review-loop rule".
4. **Add the batch sentence to B5.3** (finding 5), verbatim as quoted there.
5. **Add the stop handoff to B5.4**: "On stop, present what is still open, what moved between
   rounds and what did not, and name the class in one phrase; the human arbitrates."
6. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the line
   people skim carries the whole rule.
7. **Still the structural fix, still unbuilt: a `bin/skills-lint.sh` C-rule** failing any skill
   or agent file that states a review round cap ("max 3", "3 rounds") without the
   same-defect-class clause in the same paragraph. The condition is written in four places and
   nothing fails when one drifts; `0125901` removed the copy that DISAGREED, which is the right
   fix and not a durable one. The repo's own Core Principle (eliminate the class, do not restate
   it) applied to the rule about loops.
8. **Optional, teaches the harder case**: one line in the worked example showing a STOPPED loop,
   e.g. "architecture-reviewer v2: same class as v1 (missing precondition on the same contract)
   -> loop stopped, presented for arbitration".

## Behavioral confirmation still owed
Form only, as always. Whether an agent stops at round two on a repeated class, names the class
in one phrase, and still reports a Critical found after the cap is an `/improve` subagent test.
The matrix case is unchanged: round 2 raises a finding closed by the same kind of fix as round
1, score still below threshold; the agent should stop AND say why rather than spend round 3
because the cap allows it. The second case stays runnable: a code review that APPROVES below max
score, where the loop must stop and hand over the residual per `AGENTS.md:291-295`.

## Vs previous version
Round 19 (`0125901`) -> round 20 (`b3b66f7`), per criterion: trigger clarity 2 -> 2, structure
2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total 10 -> 10.
Neither the artifact nor anything it cites moved: `b3b66f7` changed `bin/ledger-backup.sh`, its
tests, `bin/docs-claims-check.sh` and `README.md`. The record moved because the commit did, and
a stale `reviewed_commit:` would refuse the merge. All four carried findings still stand at HEAD
(1, 2 and 3 outside the skill, 4 inside it and unblocked), plus round 18's Guardrails 1 finding,
still open with its one-sentence fix. One correction to round 19's prose: the "LOOPS until
clean" seam is at `:264`, not `:265`, and the citation to change is at `:267`. Round 15's
structure fix carries a sixth time. Nothing blocks merge.

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
  feature/windows-powershell-entry): 10/10 PASS. The SKILL was still unchanged (established by
  reading all 330 lines and re-resolving every round-18 anchor and quotation, plus
  `Glob skills/build/**` for the no-supporting-files claim; no shell, so no diff). `0125901`
  closed round-18 findings 1 and 2 correctly and consistently with each other:
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
- Round 20 (2026-09-22, Opus 5 [1M], strongest, b3b66f7, branch
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 19's. Primarily a
  RE-ANCHOR: `b3b66f7` touched `bin/ledger-backup.sh` + its tests, `bin/docs-claims-check.sh`
  and `README.md`, none of which this skill reads, but a record anchored at `0125901` would
  refuse the merge. The SKILL is still unchanged (established by reading it in full and
  re-resolving every round-19 anchor, the 75-line model-plan block, the 330-line length, and
  `Glob skills/build/**`; no shell, so no diff). Re-verified that every cross-reference still
  resolves and still says what the skill claims: the stop condition and the per-artifact table
  in `docs/eval-framework.md`, the de-scored plan rubric in `docs/plan-format.md:199-235`,
  `AGENTS.md` Guardrail 3 (`:267-319`) and Guardrails 7 (`:395-431`), and the existence of
  `bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`. All four carried
  findings STAND at HEAD, unchanged in fix and cost; round 18's Guardrails 1 finding also
  stands ("batch" and "Guardrails 1" still absent from the skill, re-checked by grep). One
  correction to round 19's prose, not to the file: the "LOOPS until clean" seam is anchored at
  `:264` and the citation to change at `:267`, an off-by-one inherited from round 17. Round
  15's structure fix carries a sixth time. Nothing blocks merge.
