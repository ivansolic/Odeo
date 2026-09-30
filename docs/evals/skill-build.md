---
artifact: skills/build/SKILL.md
type: skill
branch: fix/ledger-backup-and-eval-docs
reviewed_commit: 6873887
artifact_version: 24
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

Scope: the whole `skills/build/SKILL.md` (335 lines, no supporting files) at `6873887`, read
against `docs/skill-authoring-standard.md`, plus `docs/eval-framework.md:176-205` for finding (f).
This record REPLACES round 23's (`2b772ab`, committed at `7e0034c`). It is round 2 of this
review loop on this batch. `effort: high` is the value declared in this agent's frontmatter,
not an observed runtime value.

Method, stated with its limit: I hold no shell, so I cannot run `git diff 2b772ab..6873887`. The
dispatcher described the diff as SKILL.md B5.3's last two lines, B5.4's stop-condition clause,
`docs/eval-framework.md:186-187`, and a `scripts/ledger-backup.sh` header this skill does not
reference. I re-read `skills/build/SKILL.md:205-335` and `docs/eval-framework.md:176-205` in
full. The file is still 335 lines, B5.3's edit replaces two lines with two (`:240-241`), and
B5.4's edit lengthens `:272` without adding a line. So every round-23 anchor holds, and the
model-plan block (`:37-111`) is untouched. The lint pass and the 39 green suites are the
dispatcher's statements; I did not run them.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Unchanged: `disable-model-invocation: true` `:3` and the plain
  what-you-get description with the parallel invocation spelled out (`:2`).
- structure **2**. The model-plan block `:37-111` is still exactly 75 lines, 22.4% of 335. The
  round-15 trigger did not fire (ninth round on the edge). No line or subsection was added.
- worked example **2**. Unchanged `:296-317`, real values end to end, `<- ENDS here`.
- precision **2**. Finding (g) closed: `:240-241` "You hold that half: whether a declaring plan
  was revised after approval is a git fact `architecture-reviewer` cannot see (it checks only
  what the plans themselves show)." This now matches `agents/architecture-reviewer.md:27-32`
  ("flag what is READABLE from the plans... Whether a declaring plan was revised after approval
  is a git fact you cannot see; that half stays with the holder") in both halves, and no
  longer borrows the builder's "sees one plan" limit from `AGENTS.md:246`.
- safety integration **2**. Guardrails 1 at `:238-241` and every other reference unchanged and
  landing. The two in-skill copies of the stop condition now carry identical clauses:
  `:219-221` "clean, 3 rounds, or two consecutive rounds of the same defect class, whichever
  comes first; a Critical is always reported" and `:271-272` "approve, 3 rounds, or two
  consecutive rounds of the same defect class, whichever comes first; a Critical is always
  reported". They differ only in the clearing word, which is correct per
  `docs/eval-framework.md:196-201`.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. No criterion is structurally capped.

## Round-23 findings, checked against their proposed wording
| Item | Where at `6873887` | Status |
|---|---|---|
| (f) "plans out of 10" | `docs/eval-framework.md:186-187` "(code and UI are scored out of 12, skills and agent definitions out of 10; the plan loop publishes no score)" | CLOSED, verbatim |
| (g) B5.3 rationale | `skills/build/SKILL.md:240-241` | CLOSED, verbatim |
| Top fix 3, "whichever comes first" | `skills/build/SKILL.md:272` | CLOSED; the stop-condition-copies seam carried since round 22 is gone |

Cross-checks:
- **No further instance of the (a)/(b)/(f) class in live instruction files.** A grep over
  `AGENTS.md`, `docs/*.md`, `agents/*.md` and `skills/**/*.md` for "plans out of 10" and for the
  plan rubric next to a threshold returns zero. The class is empty for now. The lint rule is what
  would keep it empty.
- **"clean" still appears only for the plan loop** (`:215`, `:220`, `:224`, `:226`; `:143` is
  "cleanup").
- **House style:** zero em or en dashes in `skills/build/SKILL.md` and `docs/eval-framework.md`.
- **C15/C16 by reading:** neither edit adds an `AGENTS.md` mention or a program name.
- **Cosmetic, not a finding:** both edits were made without reflowing, so `:272` and
  `docs/eval-framework.md:187` run to about 115 characters where their neighbours wrap near 90.
  The standard sets no line width. It would only matter to a future anchor-based review, and
  only if someone reflows later.

## Seams carried (human-deferred for this batch, tracked; none block, none move a score)
- **Ninth round: the model-plan block sits exactly on the 75-line structure trigger** (`:37-111`).
- **The B5.2 heading still says "to clean, max 3"** (`:215`).
- **B5.4 does not say what to hand the human on stop** (`:272-273`).
- **Low: the `arch_review: waived (human)` path has no step in this skill** (`:235-237`).
- **Context, not a finding:** historical plan records model the retired scored practice.

## Integrity
No sign of text copied from another project.

## Map duty
Satisfied, nothing to update: no command surface added or altered.

## Top fixes (all deferred by the human for this batch; restated so they stay concrete)
1. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan` section,
   or move the resolution mechanics into a supporting file one level deep.
2. **B5.4 stop handoff**: "On stop, present what is still open, what moved between rounds and
   what did not, and name the class in one phrase; the human arbitrates."
3. **`:215` heading** -> "to clean, max 3 rounds or a repeated class".
4. **Optional**: one line in the worked example showing a STOPPED loop.
5. **Still open, out of scope: the anti-drift `skills-lint.sh` rule** for the stop condition.
   Per round 23 it should also cover the claim "the plan rubric has a number".

## Loop status (per `docs/eval-framework.md:179-183`)
Stopped on exit 1 (PASS, no criterion at 0, no Critical) at round 2. Trajectory for this batch:
round 1 (`2b772ab`) 10/10 with 2 new LOW findings (f, g) and 1 narrowed seam -> round 2
(`6873887`) 10/10 with all three closed and no new findings. Residuals are the four seams above
plus the lint rule. The human deferred all of them out of this batch; the decision stays with
the human.

## Behavioral confirmation still owed
Form only. The Guardrails 1 holder step (`:238-241`) still wants an `/odeo:improve` subagent test.
Set up two approved plans, B citing A's contract, then revise A. B's `approved:` should be reset
and B presented again. The two earlier cases stand: stop at round two on a repeated class, and
stop at an APPROVE below max while handing over the residual.

## Vs previous version
Round 23 (`2b772ab`) -> round 24 (`6873887`), per criterion: trigger clarity 2 -> 2, structure
2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total 10 -> 10.
Findings (f) and (g) and Top fix 3 were applied verbatim and verified. The stop-condition-copies
seam closed. No new findings, no regression. Nothing blocks merge.

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
  fix/ledger-backup-and-eval-docs): 10/10 PASS. This record REPLACED round 22's. NOT a
  re-anchor: `2b772ab` edits the skill (`:238-241` added, `:268-273` rewritten; 330 -> 335
  lines), `docs/eval-framework.md` and `AGENTS.md` to apply the five deferred findings. All
  five CLOSED, checked against their proposed wording ((a)-(d) verbatim, (e) expanded); no
  remaining "until clean" for the code loop; no em or en dashes in the three files; C15/C16
  forms correct by reading (lint pass is the dispatcher's statement, not run here). Two new LOW
  findings: (f) `docs/eval-framework.md:187` "plans out of 10", the third instance of one class
  after (a) and (b), and evidence for the still-open anti-drift lint rule; (g) the new B5.3
  sentence's rationale ("sees one plan at a time") does not match
  `agents/architecture-reviewer.md:27-32`. Model-plan block still exactly 75 lines, ninth round.
- Round 24 (2026-09-30, Opus 5.5 [1M], strongest, 6873887, branch
  fix/ledger-backup-and-eval-docs): 10/10 PASS. This record REPLACES round 23's (committed at
  `7e0034c`). Round 2 of this batch's review loop. `6873887` applies (f)
  (`docs/eval-framework.md:186-187`), (g) (`skills/build/SKILL.md:240-241`) and Top fix 3
  (`:272` "whichever comes first"), all verbatim and verified by reading. File length is still
  335 and the round-23 anchors hold (no shell, so no diff). The stop-condition-copies seam
  closed. A grep across the live instruction files finds no further "plan rubric has a number"
  instance. No new findings. The loop stopped on PASS. The human deferred the residuals
  (model-plan block on the 75-line edge, B5.4 stop handoff, `:215` heading, the stopped-loop
  example, the anti-drift lint rule) out of this batch.
