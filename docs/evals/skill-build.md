---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 15b168f
artifact_version: 22
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
HEAD `15b168f` against `docs/skill-authoring-standard.md`. This record REPLACES round 21's
(`5972c27`). The four commits since (`ad00988`, `1b3c72d`, `853d03a`, `15b168f`) touched
`bin/ledger-backup.sh`, `bin/docs-claims-check.sh`, their two test suites, `README.md`,
`docs/system-map.md` row 145 and `skills/retro/SKILL.md` rows 51 and 53, none of which this
skill points at, so this round is a RE-ANCHOR: `merge-gate.sh` compares `reviewed_commit:`
against the code being merged, and a record anchored at `5972c27` would refuse the merge even
though nothing this skill depends on moved. The work beyond re-scoring: re-establishing that
the artifact is unchanged, re-checking `docs-claims-check.sh` now that its FAILURE conditions
changed (not only its summary), confirming the `/build` rows in `docs/system-map.md` did not
shift, and restating the five carried findings with their status at HEAD.

## Did the artifact change since round 21? No.

Stated with its method, because I hold no shell and cannot run
`git diff 5972c27..HEAD -- skills/build/SKILL.md`. What I did instead, the same method as
rounds 17-21: read the file in full and re-resolve every line anchor the previous record
quoted, at both ends and in the middle, plus the file's length. An insertion or deletion
anywhere shifts every anchor below it, so anchors holding at the top, the middle and the bottom
together with an unchanged length is a strong equivalence argument. Its limit, unchanged and
restated rather than assumed forgotten: anchors plus length prove the quoted lines and the file
size, not every character in between. A change that replaced text within a line I did not quote,
or swapped two lines of equal count between anchors, would not be caught by anchors alone. It is
bounded further by the fact that I read all 330 lines this round and re-derived the scores from
that text, and by two greps over the file (below) that returned the same zero results as last
round.

| Anchor quoted in round 21 | Text at that line at `15b168f` | Match |
|---|---|---|
| `:2` description | "Build one or more ready user stories. Two modes you choose..." | yes |
| `:3` invocation mode | `disable-model-invocation: true` | yes |
| `:12` spec gate | "`spec-gate.sh <story paths...>` (in `~/bin` or `bin/`) and STOP on" | yes |
| `:37` model-plan block opens | "**Model plan, asked before any work, and the BUILD model is the user's choice too.**" | yes |
| `:111` block closes | "a block: the choice is the user's." | yes, still exactly 75 lines |
| `:215` B5.2 heading | "2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:" | yes |
| `:219-221` plan-loop stop condition | "(`docs/eval-framework.md`: / clean, 3 rounds, or two consecutive rounds of the same defect class, / whichever comes first; a Critical is always reported)" | yes |
| `:224` recorded verdict format | "`arch_review: clean (v<N>, <date>)` plus a short findings-and-resolutions" | yes |
| `:264-268` code-loop stop condition | "The review LOOPS until clean: fix -> / same reviewer re-verifies and regenerates the record -> repeat, under the / same stop condition as the plan loop (3 rounds, ...)" | yes |
| `:271` `boundary-check.sh` | "Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED)" | yes |
| `:278` B7 heading | "### B7. Gate + integrate (the merge is the user's move, full stop)" | yes |
| `:290-312` worked example fence | "## Worked example" at `:290`, closing fence at `:312` | yes |
| `:321-329` safety rules | "## Safety rules" at `:321`, last bullet at `:329` | yes |
| file length | last numbered line 330 | yes |

`Glob skills/build/**` returned `SKILL.md` alone last round and the folder is untouched by all
four commits, so "no supporting files" still holds. **This round therefore re-confirms an
unchanged artifact at a new commit.** The scores below are re-derived from the current text.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` `:3` with the description form the
  standard requires for explicit commands: what the user gets ("Build one or more ready user
  stories. Two modes you choose..." `:2`), plus the non-obvious invocation spelled out
  ("Name several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in
  parallel\""). No "Use when..." is wanted here; that form is for auto-invoked skills
  (`docs/skill-authoring-standard.md:12-19`).
- structure **2**, and the trigger round 15 set still did not fire. That trigger: structure
  drops when the model-plan block passes 75 lines OR 25% of the file, or gains a subsection not
  tied to a named finding. Measured today: `:37-111` is exactly 75 lines of a 330-line file,
  22.7%, identical to rounds 16-21. Body order follows the standard (essence `:6-7`, gates and
  mode choice, process per mode, worked example `:290-312`, output `:314`, safety rules
  `:321-329`). 330 of the 500-line limit, no supporting files, so the one-level-deep rule is
  satisfied trivially. The block sits ON the edge, so Top fix 2 carries into an eighth round.
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
  (`bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`; none of the four
  commits removed or renamed a `bin/` entry point this skill names). Cross-references resolve in
  the direction they claim: `:236-237` says the builder's precondition list is authoritative in
  `agents/builder.md`, and `agents/builder.md:16` says exactly that of itself. The "LOOPS until
  clean" wording at `:264` is finding (d) below; it stays a seam and not a score move for the
  same reason as rounds 16-21 (the file is exact everywhere a path, field or script is named,
  and the loose word is inherited plain language).
- safety integration **2**. Guardrails are referenced, not restated or weakened, and each
  reference lands: `AGENTS.md` Guardrail 3 + lint C11 for the no-model-names-in-files rule
  `:88` (`AGENTS.md:315-317`); `AGENTS.md` Guardrails 7 for the language handover `:213-214,
  :227-231, :256-259` (`AGENTS.md:395-402`, including the dispatcher duty on EVERY dispatch and
  the fallback chain, which is what the skill cites it for); `docs/eval-framework.md` for the
  loop stop condition `:219-221` (`docs/eval-framework.md:175-236`, clause for clause);
  `docs/plan-format.md` for the contract binding list `:154-155`. Enforced gates are named as
  enforced and as non-bypassable: `spec-gate.sh` "STOP on non-zero... Never work around it; if
  the gate is wrong, that is a bug to report, not to bypass" `:12-16`; `boundary-check.sh`
  "(ENFORCED)" `:271`; the plan gate "structural, not advisory" `:326`; the merge rule as a
  closed list of non-permissions `:282-284`, which matches `AGENTS.md:222-226` counter for
  counter. The partial embedding of the stop condition in the body is sanctioned by
  `AGENTS.md:5-7` (safety-critical rules embedded so they hold when that file is absent, e.g. a
  marketplace install), not a violation of "never restate a guardrail". The one coverage gap is
  finding (e); the criterion's 1 is "silent", and this file is emphatically not silent about
  guardrails, so the gap is a Top fix, not a score move.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: it is an explicit command (trigger
clarity can reach 2 on the what-you-get form), real guardrails and enforced scripts exist to
reference (safety integration can reach 2), and a concrete end-to-end example is present.

## `docs-claims-check.sh` changed again: re-verified, still no duty in this skill's scope

Re-checked rather than carried, because the change is to the FAILURE conditions and not only to
the wording, which is exactly the case where a previous negative result could go stale:

- A suite's non-zero exit now fails the run regardless of skips (`:99-116`: "THE SUITE'S EXIT
  CODE IS READ, not only its output... A broken instrument must never read as a clean bill",
  `rc` captured at `:107`, `fail=1` at `:112-115`).
- The exit contract at `:18-20` now reads "0 every claim this run could measure matches (some
  may be reported UNVERIFIED...); 1 a claim drifted, an expected claim is missing, or a suite
  failed".
- The final summary names the unverified count instead of claiming everything matches
  (`:157-164`: "THE SUMMARY MUST NOT OUTLIVE THE RUN IT SUMMARISES", printing "every claim this
  run could measure matches; N UNVERIFIED (see above)" when `n_unverified > 0`).

So "the claims check passed" and "the claims check failed" both mean something different from
what they meant two commits ago, and any instruction of the form "act when the claims check
fails" would now be incomplete in a NEW way (a green run can carry unverified claims; a red run
can now mean a broken suite rather than a drifted document). Nothing in this skill's scope says
anything of the kind. `skills/build/SKILL.md` is the entire scope (no supporting files), and a
grep over it for `claims` / `README` / `UNVERIFIED` returns ZERO matches at this HEAD, re-run
this round rather than carried: the skill never invokes the checker, never reads `README.md`,
and its enforced gates are `spec-gate.sh` `:12` and `boundary-check.sh` `:271`, neither touched
by these four commits. In the other direction the checker reads `README.md` only (`:32`,
`:78-139`) and never `skills/`. Recorded again as a negative result, not a finding.

## `docs/system-map.md`: the `/build` rows did not shift

Confirmed by grep at this HEAD, not by assumption, because row 145 was rewritten again. The
rows this record anchors on are all above it and all unmoved: the flows at `:12-14` ("New
product", "Incremental feature", "Trivial fix"), `/build` itself at `:67`,
`/worktree-parallel-check` at `:75`, `coverage-check.sh` at `:135` and `spec-gate.sh` at `:136`,
each with the same text as round 21. An edit at row 145 cannot shift lines above it, and the
grep confirms it did not add or remove lines above them either.

## Findings (the five carried; all FIVE STAND at this HEAD)

Restated in full with their exact one-line fixes, because the human decides them as a batch
immediately after the merge, alongside two findings from the ledger review that are not mine and
are named here only so the batch is complete: the `a/b:c` relative-test disagreement, and
`bin/ledger-backup.sh:52`'s claim that the whole git environment is dropped, which is reported
false under `GIT_SSH_COMMAND`. Those two are outside this skill's scope; I did not verify them
and this record certifies nothing about them.

**(a) STANDS, low, outside the skill: `docs/eval-framework.md:195` still names the plan rubric
under a column headed "Rubric that declares the threshold" (`:189`), while that rubric declares
none.** Re-read this round at `:186-203`. Mitigated by "(see the note below)" in the cell and by
the note at `:198-203`, so no reader who follows the pointer is misled; a reader skimming the
table alone is, and the row is the extractable unit. **Fix (one cell):**
`| Implementation plan | no number: the loop clears on **clean** (see the note below) |`.

**(b) STANDS, low, outside the skill: `docs/eval-framework.md:26-27` defines a rubric as
something that HAS a threshold.** "A rubric = named criteria, scoring levels (0 to 2 per
criterion), and a pass threshold (for example: total >= 8/10 AND no criterion at 0)." The plan
rubric is, by design since `0125901`, a rubric with no threshold, which `:198` states in as many
words, 171 lines later, with nothing connecting the two. **Fix (one clause at `:27`):**
"...and a pass threshold, with one deliberate exception, the plan rubric, which declares none
(see the stop-condition section)."

**(c) STANDS, low, outside the skill: the locator in `AGENTS.md:285-286` does not land.**
Re-read this round at `:281-292`: it still says the stop condition "is the one named a few lines
above in this file". The statement it means is `AGENTS.md:39-41`, 246 lines earlier and in a
different section ("Agent-first workflow"). A reader at `:285` scanning a few lines up finds
nothing. **Fix (one sentence, same line):** "...and is the one stated in the Agent-first
workflow section near the top of this file".

**(d) STANDS, low, INSIDE the skill, unblocked: `skills/build/SKILL.md:264` says the code review
loop "LOOPS until clean", and `:267` cites the rule second-hand.** "clean" is the word
`docs/eval-framework.md:198-200` reserves for the plan loop, the one exit with no number; the
code loop's exit is an APPROVE clearing the threshold in `agents/code-reviewer.md:91` ("no
dimension at 0, total >= 9/12"). Round 18 correctly refused to fix this while `AGENTS.md` still
said two things; `0125901` settled that, so the edit has been safe since. **Fix (two one-line
moves, both inside the skill):** `:264` -> "The review LOOPS until the reviewer APPROVES (its
rubric's threshold, no criterion at 0)"; `:267` -> cite `docs/eval-framework.md` instead of "the
AGENTS.md review-loop rule", so both of this file's citations of one rule point at the same
canonical file.

**(e) STANDS, low, INSIDE the skill, open since round 18: Guardrails 1's holder half is assigned
to `/build`'s orchestrator and still has no step in this skill.** `AGENTS.md:229-234`: "A plan
approval covers only the plan as approved... revising a declaring plan after approval
invalidates its consumers' approval and they return to the gate. Holder: the orchestrating
session at gate 1 (the only actor that sees the whole batch; a builder sees one plan)."
Re-established this round by grep, not memory: "batch" and "Guardrails 1" return ZERO matches in
`skills/build/SKILL.md`, and B5.3 `:232-237` covers approve / change / reject without saying
what a post-approval revision does to the other plans in the batch. The path is reachable
through the skill's headline feature, several stories at one gate (`:2`, B3 `:173-183`).
**Fix (one sentence at the end of B5.3):** "If you revise a plan after it was approved, every
other plan in the batch that references its contracts loses its approval and returns to this
gate (`AGENTS.md` Guardrails 1); you hold that half, `architecture-reviewer` cannot see it."

## Seams carried (none block, none move a score)
- **Carried, eighth round: the model-plan block sits exactly on the 75-line structure trigger**
  (`:37-111`). The next inline addition costs the structure point, which is also the budget
  argument for putting finding (e)'s sentence in B5.3 and nowhere else.
- **Carried: the two stop-condition copies inside the skill are not verbatim.** `:266-268` omits
  "whichever comes first", and its clearing exit lives in the lead-in prose rather than in the
  parenthesis, so it reads as two exits where `:219-221` reads as three. Finding (d)'s edit is
  the moment to make them identical.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`). The full condition is one
  line below, so nobody is misled in context, but the heading is the skimmable line.
- **Carried: B5.4 does not say what to hand the human on stop.** The plan loop does (`:221-222`,
  "present the disagreement, the human arbitrates"); B5.4 ends at "the user sees first -> final
  score". `docs/eval-framework.md:208-211` asks for "what is still open, what moved between
  rounds, and what did not", and `:212-222` asks for the class in one phrase.
- **Carried, low: the `arch_review: waived (human)` path has no step in this skill.**
  `agents/builder.md:24-26` and `docs/plan-format.md` both allow a waiver for a human-supplied
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
`bin/spec-gate.sh`, `bin/boundary-check.sh`, `bin/resolve-language.sh`).

## Map duty
Satisfied, nothing to update: no command surface was added or altered this round, and the
`/build` rows are unshifted (see the system-map section above). Not a finding.

## Top fixes
1. **The three one-line neighbours outside the skill** (findings a-c), decidable as a batch
   after the merge: `docs/eval-framework.md:195` -> "no number: the loop clears on **clean** (see
   the note below)"; `docs/eval-framework.md:27` -> add "with one deliberate exception, the plan
   rubric, which declares none"; `AGENTS.md:285-286` -> "the one stated in the Agent-first
   workflow section near the top of this file".
2. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan`
   section, or move the resolution mechanics (model precedence, effort precedence, the
   source-tagging duty) into a supporting file one level deep. The block is exactly on the
   75-line trigger, eighth round, and every other fix below wants to add a line.
3. **Take the unblocked wording fix inside the skill** (finding d): `:264` "LOOPS until the
   reviewer APPROVES (its rubric's threshold, no criterion at 0)" and `:267` citing
   `docs/eval-framework.md` instead of "the AGENTS.md review-loop rule".
4. **Add the batch sentence to B5.3** (finding e), verbatim as quoted there.
5. **Add the stop handoff to B5.4**: "On stop, present what is still open, what moved between
   rounds and what did not, and name the class in one phrase; the human arbitrates."
6. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the line
   people skim carries the whole rule.
7. **Still the structural fix, still unbuilt: a `bin/skills-lint.sh` C-rule** failing any skill
   or agent file that states a review round cap ("max 3", "3 rounds") without the
   same-defect-class clause in the same paragraph. The condition is written in four places and
   nothing fails when one drifts. The repo's own Core Principle (eliminate the class, do not
   restate it) applied to the rule about loops.
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
Round 21 (`5972c27`) -> round 22 (`15b168f`), per criterion: trigger clarity 2 -> 2, structure
2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total 10 -> 10.
Neither the artifact nor anything it cites moved: the four commits changed the ledger backup,
the claims checker, their tests, the README, `docs/system-map.md` row 145 and
`skills/retro/SKILL.md` rows 51 and 53. The record moved because the commit did, and a stale
`reviewed_commit:` would refuse the merge. New verification this round beyond the re-anchor:
`docs-claims-check.sh`'s FAILURE conditions changed (a suite's non-zero exit now fails
regardless of skips, and the summary names the unverified count), so last round's negative
result was re-derived rather than carried, and it still holds, zero matches for `claims` /
`README` / `UNVERIFIED` in the skill; and the `/build` rows in `docs/system-map.md` (`:12-14`,
`:67`, `:75`, `:135-136`) were confirmed unshifted after row 145 was rewritten again. All five
carried findings STAND at HEAD with their fixes unchanged, (a)-(c) outside the skill and (d)-(e)
inside it and both unblocked. Round 15's structure fix carries an eighth time. Nothing blocks
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
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACED round 19's. Primarily a
  RE-ANCHOR: `b3b66f7` touched `bin/ledger-backup.sh` + its tests, `bin/docs-claims-check.sh`
  and `README.md`, none of which this skill reads, but a record anchored at `0125901` would
  refuse the merge. The SKILL was still unchanged (established by reading it in full and
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
- Round 21 (2026-09-22, Opus 5 [1M], strongest, 5972c27, branch
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACED round 20's. Primarily a
  RE-ANCHOR: `5972c27` touched `bin/ledger-backup.sh`, `bin/docs-claims-check.sh`, their two
  test suites, `README.md`, `docs/system-map.md:145` and `skills/retro/SKILL.md:51`, none of
  which this skill points at, but a record anchored at `b3b66f7` would refuse the merge. The
  SKILL was still unchanged (established by reading all 330 lines and re-resolving every
  round-20 anchor, the 75-line model-plan block at `:37-111`, the 330-line length, and
  `Glob skills/build/**`; no shell, so no diff, and the method's limit stated in the body).
  Cross-references re-verified by opening them: the stop condition (`docs/eval-framework.md`
  `:175-236`) and the per-artifact threshold table (`:189-196`), the de-scored plan rubric with
  no `Threshold:` line (`docs/plan-format.md:199-235`), `AGENTS.md` Guardrail 3 (`:267-324`,
  C11 at `:315-317`) and Guardrails 7 (`:395-434`), the existence of `bin/spec-gate.sh`,
  `bin/boundary-check.sh` and `bin/resolve-language.sh`, and `agents/code-reviewer.md:91`'s
  numeric code-loop exit. New that round: checked whether `docs-claims-check.sh`'s new
  UNVERIFIED outcome (a claim can mismatch without failing) makes any statement in this skill
  incomplete; nothing in scope mentions the checker (zero grep matches) and the checker reads
  `README.md` only, so no duty lands here, recorded as a negative result. All FIVE carried
  findings STAND. Round 15's structure fix carries a seventh time.
- Round 22 (2026-09-22, Opus 5 [1M], strongest, 15b168f, branch
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 21's. A RE-ANCHOR
  over four commits (`ad00988`, `1b3c72d`, `853d03a`, `15b168f`) touching
  `bin/ledger-backup.sh`, `bin/docs-claims-check.sh`, their two test suites, `README.md`,
  `docs/system-map.md` row 145 and `skills/retro/SKILL.md` rows 51 and 53, none of which this
  skill points at; a record anchored at `5972c27` would refuse the merge. The SKILL is still
  unchanged (established by reading all 330 lines and re-resolving every round-21 anchor, the
  75-line model-plan block, the 330-line length; no shell, so no diff, and the method's limit
  restated in the body). Two checks done rather than carried: (1) `docs-claims-check.sh`
  changed its FAILURE conditions, not only its summary, a suite's non-zero exit now fails the
  run regardless of skips (`:99-116`), the exit contract was rewritten (`:18-20`) and the
  summary now names the unverified count (`:157-164`); the negative result was re-derived and
  still holds, since `claims` / `README` / `UNVERIFIED` return zero matches in the skill and
  the checker reads `README.md` only; (2) the `/build` rows in `docs/system-map.md` (`:12-14`,
  `:67`, `:75`, `:135-136`) were confirmed unshifted after row 145 was rewritten again. All
  five carried findings STAND at HEAD with their exact one-line fixes restated for the human's
  post-merge batch, (a)-(c) outside the skill, (d)-(e) inside it and both unblocked; the two
  ledger-review findings named in the dispatch (`a/b:c` relative test, `:52`'s GIT_SSH_COMMAND
  claim) are outside this scope and this record certifies nothing about them. Round 15's
  structure fix carries an eighth time. Nothing blocks merge.
