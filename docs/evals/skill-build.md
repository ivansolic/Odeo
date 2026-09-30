---
artifact: skills/build/SKILL.md
type: skill
branch: fix/ledger-backup-and-eval-docs
reviewed_commit: 88e96c7
artifact_version: 25
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

Scope: the whole `skills/build/SKILL.md` (335 lines, no supporting files) at `88e96c7`, read
against `docs/skill-authoring-standard.md`, plus `docs/eval-framework.md:176-205` and the two
`AGENTS.md` passages this skill's findings touched. This record REPLACES round 24's
(`6873887`). `effort: high` is the value declared in this agent's frontmatter, not an observed
runtime value.

## This round is a RE-ANCHOR
The dispatcher reports that the branch was rebased onto local main `8dd9ec6`, that main's new
commits touch only `community-sync.sh`, the odeo-context hook and its test, `knowledge/` and
one eval record, and that `git range-diff` shows "=" for all 8 branch commits. So the three
files judged in round 24 should be byte-identical to `6873887`. New HEAD `88e96c7`. Nothing
this skill references is among main's new paths.

Checked, with its limit: I hold no shell, so I cannot run `git range-diff` or
`git diff 6873887..88e96c7`. What I did instead was re-resolve the round-24 anchors by grep in
this worktree:
- `skills/build/SKILL.md`: the model-plan block still opens at `:37` and closes at `:111`
  (75 lines); the new B5.3 rationale at `:241`; the code-loop exit at `:268`; the stop clause
  "same defect class, whichever comes first" at `:272`; the last safety bullet at `:334`.
- `docs/eval-framework.md`: the rubric exception at `:27`, "the plan loop publishes no score"
  at `:187`, the plan row at `:196`.
- `AGENTS.md`: the Guardrails 1 holder at `:245`, the review-loop locator at `:303`.

Every anchor holds at its round-24 line. That proves the quoted lines and their positions, not
every character between them. Together with the dispatcher's `range-diff` result it is a strong
equivalence argument. The scores and findings below are therefore carried unchanged from
round 24, re-anchored at the new commit. The lint pass and suite results are the dispatcher's
statements from round 24; I did not run them.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` `:3` and the plain what-you-get
  description with the parallel invocation spelled out (`:2`).
- structure **2**. The model-plan block `:37-111` is still exactly 75 lines, 22.4% of 335. The
  round-15 trigger did not fire (ninth round on the edge). 335 of 500 lines, no supporting
  files.
- worked example **2**. `:296-317`, real values end to end, `<- ENDS here`.
- precision **2**. `:240-241` "You hold that half: whether a declaring plan was revised after
  approval is a git fact `architecture-reviewer` cannot see (it checks only what the plans
  themselves show)" matches `agents/architecture-reviewer.md:27-32` in both halves. `:268-269`
  names the code loop's real exit ("until the reviewer APPROVES (its rubric's threshold, no
  criterion at 0)") and `:271` cites `${CLAUDE_PLUGIN_ROOT}/docs/eval-framework.md` directly.
- safety integration **2**. Guardrails 1 at `:238-241`, Guardrail 3 + C11 `:88`, Guardrails 7
  `:214`, `:231`, `:263`, enforced gates `:12-16` and `:276`, merge non-permissions `:286-291`.
  The two in-skill stop-condition copies (`:219-221`, `:271-272`) carry identical clauses and
  differ only in the clearing word, which is correct per `docs/eval-framework.md:196-201`.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. No criterion is structurally capped.

## Findings
None open from this batch. (a)-(g) and round 23's Top fix 3 are all closed (rounds 23-24).
The grep across the live instruction files for another "plan rubric has a number" claim found
nothing in round 24. Main's new paths do not include any file that grep covered.

## Seams carried (human-deferred for this batch, tracked; none block, none move a score)
- **Ninth round: the model-plan block sits exactly on the 75-line structure trigger** (`:37-111`).
- **The B5.2 heading still says "to clean, max 3"** (`:215`).
- **B5.4 does not say what to hand the human on stop** (`:272-273`).
- **Low: the `arch_review: waived (human)` path has no step in this skill** (`:235-237`).
- **Cosmetic:** `:272` and `docs/eval-framework.md:187` are unwrapped at about 115 characters.
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
5. **Still open, out of scope: the anti-drift `skills-lint.sh` rule** for the stop condition,
   also covering the claim "the plan rubric has a number".

## Loop status (per `docs/eval-framework.md:179-183`)
The loop stopped on exit 1 (PASS) at round 24. This round re-anchors that result and is not a
new review round. Trajectory for the batch: `2b772ab` 10/10 with 2 new LOW findings ->
`6873887` 10/10 with none -> `88e96c7` re-anchor, unchanged.

## Behavioral confirmation still owed
Form only. The Guardrails 1 holder step (`:238-241`) still wants an `/odeo:improve` subagent test.
Set up two approved plans, B citing A's contract, then revise A. B's `approved:` should be reset
and B presented again. The two earlier cases stand: stop at round two on a repeated class, and
stop at an APPROVE below max while handing over the residual.

## Vs previous version
Round 24 (`6873887`) -> round 25 (`88e96c7`): every criterion 2 -> 2, total 10 -> 10. A
re-anchor after the rebase onto `8dd9ec6`; the artifact and both neighbours read as they did at
`6873887`. No regression. Nothing blocks merge.

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
  fix/ledger-backup-and-eval-docs): 10/10 PASS. This record REPLACED round 23's (committed at
  `7e0034c`). Round 2 of this batch's review loop. `6873887` applies (f)
  (`docs/eval-framework.md:186-187`), (g) (`skills/build/SKILL.md:240-241`) and Top fix 3
  (`:272` "whichever comes first"), all verbatim and verified by reading. File length is still
  335 and the round-23 anchors hold (no shell, so no diff). The stop-condition-copies seam
  closed. A grep across the live instruction files finds no further "plan rubric has a number"
  instance. No new findings. The loop stopped on PASS. The human deferred the residuals
  (model-plan block on the 75-line edge, B5.4 stop handoff, `:215` heading, the stopped-loop
  example, the anti-drift lint rule) out of this batch.
- Round 25 (2026-09-30, Opus 5.5 [1M], strongest, 88e96c7, branch
  fix/ledger-backup-and-eval-docs): 10/10 PASS. This record REPLACES round 24's. A RE-ANCHOR
  after the branch was rebased onto local main `8dd9ec6`. Per the dispatcher, main's new commits
  touch only `community-sync.sh`, the odeo-context hook and its test, `knowledge/` and one
  eval record, and `git range-diff` shows "=" on all 8 branch commits. Checked here by
  re-resolving the round-24 anchors in `skills/build/SKILL.md` (`:37`, `:111`, `:241`, `:268`,
  `:272`, `:334`), `docs/eval-framework.md` (`:27`, `:187`, `:196`) and `AGENTS.md` (`:245`,
  `:303`). All hold. No shell, so no diff; the method's limit is stated in the body. Scores,
  findings and deferred seams carried unchanged. Nothing blocks merge.
