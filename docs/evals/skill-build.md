---
artifact: skills/build/SKILL.md
type: skill
branch: fix/ledger-backup-and-eval-docs
reviewed_commit: 2b772ab
artifact_version: 23
date: 2026-09-30
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/build/SKILL.md` (335 lines, no supporting files) at `2b772ab`, read
against `docs/skill-authoring-standard.md`, plus the two neighbour files that commit touched
(`docs/eval-framework.md`, `AGENTS.md`) as far as they carry the five findings this record
deferred in round 22. This record REPLACES round 22's (`15b168f`). Unlike rounds 20-22, this is
NOT a re-anchor: the artifact changed. `effort: high` is the value declared in this agent's
frontmatter, not an observed runtime value.

Method, stated with its limit: I hold no shell, so I cannot run `git show 2b772ab`. I read all
335 lines of the skill and the edited regions of both neighbours at this worktree, and located
each change by the round-22 anchors: everything above `:238` is unmoved (the model-plan block is
still `:37-111`, B5.2 still opens at `:215`), four lines were added at `:238-241`, the code-loop
paragraph grew by one line (was `:264-268`, now `:268-273`), and everything below shifted by
five (worked example `:295-317`, safety rules `:326-334`). 330 + 5 = 335, consistent. Lint
C15/C16 passing at `2b772ab` is the dispatcher's statement; I did not run `skills-lint.sh`, and
what I checked by reading is below.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Unchanged: `disable-model-invocation: true` `:3` with the plain
  what-you-get description the standard requires for explicit commands ("Build one or more ready
  user stories. Two modes you choose..." `:2`), including the non-obvious parallel invocation
  (`"/odeo:build USR-001 USR-002 in parallel"`).
- structure **2**. The round-15 trigger (model-plan block over 75 lines OR 25% of the file, or a
  subsection not tied to a named finding) did not fire: `:37-111` is still exactly 75 lines, now
  22.4% of 335. The two additions sit where the findings put them (B5.3 and B5.4), add no
  subsection, and are each tied to a named finding (e) and (d). 335 of 500 lines, no supporting
  files. The block remains ON the edge, ninth round.
- worked example **2**. Unchanged `:296-317`: real story id, real plan path
  (`docs/plans/2026-07-14-usr-012-timer.md`), real frontmatter keys, real worktree path, real
  verdict shape ("code-reviewer 12/12 APPROVE -> docs/evals/code-USR-012.md") and the explicit end
  of authority (`<- ENDS here`). `<session model>` at `:307` is the never-fabricate rule applied,
  not a placeholder failure.
- precision **2**, and improved. Finding (d) closed: `:268-269` "The review LOOPS until the
  reviewer APPROVES (its rubric's threshold, no criterion at 0)" now names the code loop's real
  exit (`agents/code-reviewer.md:91` "no dimension at 0, total >= 9/12"), and `:271` cites
  `${CLAUDE_PLUGIN_ROOT}/docs/eval-framework.md` directly, so both of this file's citations of
  the stop condition (`:219`, `:271`) now point at the same canonical file. "clean" now appears
  only where it belongs, the plan loop (`:215`, `:220`, `:224`, `:226`; `:143` is "cleanup"). One
  low seam in the new B5.3 sentence's rationale (see finding g); it does not move the score
  because the rule itself is exact and matches its source.
- safety integration **2**, and the round-18 gap closed. Finding (e): `:238-241` "If you revise a
  plan after it was approved, every other plan in the batch that references its contracts loses
  its approval and returns to this gate (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 1). You hold
  that half". That matches `AGENTS.md:243-247` ("revising a declaring plan after approval
  invalidates its consumers' approval and they return to the gate. Holder: the orchestrating
  session at gate 1") and references the guardrail rather than restating its whole text. All
  other references unchanged and landing (Guardrail 3 + C11 `:88`, Guardrails 7 `:214`, `:231`,
  `:263`, plan-format binding list `:154`, enforced gates `:12-16`, `:276`, merge non-permissions
  `:286-291`).

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: explicit command (trigger clarity reaches
2 on the what-you-get form), real guardrails and enforced scripts to reference, a concrete
end-to-end example.

## The five deferred findings, each checked against its wording
| Finding | Where at `2b772ab` | Status |
|---|---|---|
| (a) plan row under "declares the threshold" | `docs/eval-framework.md:196` "no number: the loop clears on **clean** (see the note below)" | CLOSED, verbatim to the proposed cell |
| (b) rubric definition assumes a threshold | `docs/eval-framework.md:26-28` "...with one deliberate exception, the plan rubric, which declares none (see the stop-condition section)." | CLOSED, verbatim; the pointer lands on `### The review loop's STOP CONDITION` `:176` |
| (c) "a few lines above" locator | `AGENTS.md:302-304` "is the one stated in the Agent-first workflow section near the top of this file" | CLOSED; it lands on `AGENTS.md:39-42`, which states approve / three rounds / same class / Critical overrides |
| (d) code loop "until clean", second-hand citation | `skills/build/SKILL.md:268-273` | CLOSED, verbatim; see precision |
| (e) Guardrails 1 holder half missing | `skills/build/SKILL.md:238-241` | CLOSED; wording expanded beyond the proposed sentence, see (g) |

Cross-checks asked for:
- **Nothing in the skill still says the code loop runs "until clean".** Grep for `clean` returns
  only the plan loop and `:143` "cleanup". With-me step 7 `:142` names no loop word.
- **No new contradiction between (d) and the framework.** `:268-273` lead-in (APPROVES) and
  parenthesis (approve, 3 rounds, same class, Critical reported) both agree with
  `docs/eval-framework.md:179-237`. "criterion" vs code-reviewer's "dimension" is the framework's
  own generic word (`:182`), not a finding.
- **`docs/eval-framework.md:202` still resolves** ("per `skills/build/SKILL.md`, mode B5 step 2"):
  B5.2 at `:215-226` still records `arch_review: clean (v<N>, <date>)`.
- **House style:** grep for em and en dashes returns zero in `skills/build/SKILL.md`,
  `docs/eval-framework.md` and `AGENTS.md`.
- **C15/C16 by reading:** the new `AGENTS.md` mention at `:239` is written
  `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`, the new framework citation at `:271` uses the plugin-root
  form, and neither addition names a program from `scripts/`. Consistent with the stated lint
  pass; not independently run.

## New findings

**(f) LOW, outside the skill, same class as (a) and (b): `docs/eval-framework.md:186-187` still
says plans are scored out of 10.** "the totals differ by type (code and UI are scored out of 12,
skills, agent definitions and plans out of 10)". Ten lines below, `:199-200` says
`architecture-reviewer` "publishes no score", `:26-28` now says the plan rubric declares no
threshold, and `docs/plan-format.md:230` says "No threshold, and no score is published". The
sentence sits in the paragraph that introduces the very table row (a) fixed. **Fix (one clause):**
"(code and UI are scored out of 12, skills and agent definitions out of 10; the plan loop
publishes no score)".

This is worth naming beyond its size: (a), (b) and (f) are three findings closed by the SAME KIND
of fix, another sentence that still implies the plan rubric carries a number, and fixing (f)
leaves the next instance possible. That is the "same class" test in
`docs/eval-framework.md:217-223`. It is not a stop for this loop (one round on this version), but
it is evidence for the structural answer, the anti-drift lint rule (Top fix 8, out of scope and
still open), widened to a second claim.

**(g) LOW, inside the skill: the rationale in `:240-241` is not the one the sources give.**
"`architecture-reviewer` sees one plan at a time and cannot see a revision to another."
`AGENTS.md:246` gives "a builder sees one plan" as the builder's limit, not the reviewer's, and
`agents/architecture-reviewer.md:27-32` says the reviewer DOES flag what is readable across the
batch ("a reference into a plan outside this batch, one whose `approved:` is not yes...") and
that the half it cannot see is that "a declaring plan was revised after approval is a git fact".
The rule the sentence states is correct; the reason attached to it partly is not, and a reader
could infer the reviewer ignores cross-plan references. **Fix (one sentence):** "You hold that
half: whether a declaring plan was revised after approval is a git fact
`architecture-reviewer` cannot see (it checks only what the plans themselves show)."

## Seams carried (none block, none move a score)
- **Ninth round: the model-plan block sits exactly on the 75-line structure trigger** (`:37-111`).
- **Narrowed: the two in-skill stop-condition copies are closer but not verbatim.** (d) moved the
  clearing exit into the parenthesis (`:271-272` "approve, 3 rounds, or two consecutive rounds of
  the same defect class"), so both now read as three exits. `:271-272` still omits "whichever
  comes first", which `:221` and `AGENTS.md:41` carry.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`).
- **Carried: B5.4 does not say what to hand the human on stop** (`:272-273` ends at "first ->
  final score"; `docs/eval-framework.md:209-211` asks for what is open, what moved, what did not).
- **Carried, low: the `arch_review: waived (human)` path has no step in this skill** (`:235-237`).
- **Context, not a finding:** historical plan records model the retired scored practice
  (`docs/plans/2026-08-13-usr-006-prose-language-warning.md`); correct as history.

## Integrity
No sign of text copied from another project. Voice is this system's throughout; every
cross-reference resolves inside this repo.

## Map duty
Satisfied, nothing to update: `2b772ab` adds and alters no command surface, and
`docs/system-map.md` is not touched by it. Not a finding.

## Top fixes
1. **(f)** `docs/eval-framework.md:187` -> "(code and UI are scored out of 12, skills and agent
   definitions out of 10; the plan loop publishes no score)".
2. **(g)** `skills/build/SKILL.md:240-241` -> "You hold that half: whether a declaring plan was
   revised after approval is a git fact `architecture-reviewer` cannot see (it checks only what
   the plans themselves show)."
3. **Make the two in-skill stop-condition copies identical**: at `:271-272` add "whichever comes
   first" after "of the same defect class".
4. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan` section,
   or move the resolution mechanics (model precedence, effort precedence, source-tagging duty)
   into a supporting file one level deep.
5. **B5.4 stop handoff**: "On stop, present what is still open, what moved between rounds and
   what did not, and name the class in one phrase; the human arbitrates."
6. **`:215` heading** -> "to clean, max 3 rounds or a repeated class".
7. **Optional**: one line in the worked example showing a STOPPED loop.
8. **Out of scope for this commit, stays open: the anti-drift `skills-lint.sh` rule** for the
   stop condition. (a), (b) and (f) now show the same need for a second claim ("the plan rubric
   has a number"), which is the argument for making the rule check both.

## Behavioral confirmation still owed
Form only. Whether an orchestrator actually returns a batch's consuming plans to the gate after
revising a declaring plan (the new `:238-241` step) is behavior, not form: an `/odeo:improve`
subagent test with two plans where plan B cites plan A's contract, A revised after both are
approved, expecting B's `approved:` to be reset and presented again. The two earlier cases stand:
stop at round two on a repeated class, and stop at an APPROVE below max while handing over the
residual.

## Vs previous version
Round 22 (`15b168f`) -> round 23 (`2b772ab`), per criterion: trigger clarity 2 -> 2, structure
2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total 10 -> 10. The
score was already at max, so the movement is in the findings: all five deferred findings (a)-(e)
CLOSED, each checked against its proposed wording ((a)-(d) verbatim, (e) expanded). Two new LOW
findings: (f) outside the skill, the same class as (a) and (b); (g) inside the skill, a rationale
in the new (e) sentence that does not match `agents/architecture-reviewer.md`. The
stop-condition-copies seam narrowed. No regression. Nothing blocks merge.

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
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACED round 21's. A RE-ANCHOR
  over four commits (`ad00988`, `1b3c72d`, `853d03a`, `15b168f`) touching
  `bin/ledger-backup.sh`, `bin/docs-claims-check.sh`, their two test suites, `README.md`,
  `docs/system-map.md` row 145 and `skills/retro/SKILL.md` rows 51 and 53, none of which this
  skill points at; a record anchored at `5972c27` would refuse the merge. The SKILL was still
  unchanged (all 330 lines read, every round-21 anchor re-resolved; no shell, so no diff).
  `docs-claims-check.sh`'s changed FAILURE conditions were re-checked, negative result still
  holds; the `/build` rows in `docs/system-map.md` were confirmed unshifted. All five carried
  findings STOOD with exact one-line fixes restated for the human's post-merge batch, (a)-(c)
  outside the skill, (d)-(e) inside it. Round 15's structure fix carried an eighth time.
- Round 23 (2026-09-30, Opus 5.5 [1M], strongest, 2b772ab, branch
  fix/ledger-backup-and-eval-docs): 10/10 PASS. This record REPLACES round 22's. NOT a
  re-anchor: `2b772ab` edits the skill (`:238-241` added, `:268-273` rewritten; 330 -> 335
  lines), `docs/eval-framework.md` and `AGENTS.md` to apply the five deferred findings. All
  five CLOSED, checked against their proposed wording ((a)-(d) verbatim, (e) expanded); no
  remaining "until clean" for the code loop; no em or en dashes in the three files; C15/C16
  forms correct by reading (lint pass is the dispatcher's statement, not run here). Two new LOW
  findings: (f) `docs/eval-framework.md:187` "plans out of 10", the third instance of one class
  after (a) and (b), and evidence for the still-open anti-drift lint rule; (g) the new B5.3
  sentence's rationale ("sees one plan at a time") does not match
  `agents/architecture-reviewer.md:27-32`. Model-plan block still exactly 75 lines, ninth round.
