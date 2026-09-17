---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: 2e7c7408fea086eca2ddb02b72e6ef5d01ee1ede
artifact_version: 17
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
HEAD `2e7c740` against `docs/skill-authoring-standard.md`. This round exists because the
record it replaces was anchored at `fab5c0d` and the branch has moved past it; the
merge gate refuses a record whose `reviewed_commit:` predates HEAD. Focus of the round,
beyond the full rubric pass: whether the skill still agrees with
`docs/eval-framework.md` after commit `53f246e` rewrote that file's review-loop STOP
CONDITION today, checked in BOTH directions.

## Did the artifact change since round 16? No.

Stated with its method, because the method matters here. **I hold no shell, so I could not
run `git diff fab5c0d..HEAD -- skills/build/SKILL.md`.** What I could do is re-resolve every
line anchor round 16 recorded and compare the text at each one:

| Anchor from round 16 | Text at that line today | Match |
|---|---|---|
| `:37-111` model-plan block | `:37` "**Model plan, asked before any work...**", `:111` "a block: the choice is the user's." | yes, still exactly 75 lines |
| `:215` B5.2 heading | "2. **Plan review LOOP (architecture-reviewer x architect, to clean, max 3)**:" | yes |
| `:218-222` plan-loop stop condition | "repeat until the stop condition (`docs/eval-framework.md`: / clean, 3 rounds, or two consecutive rounds of the same defect class, / whichever comes first; a Critical is always reported)" | yes |
| `:264-268` code/design-loop stop condition | "under the / same stop condition as the plan loop (3 rounds, or two consecutive rounds of / the same defect class, per the AGENTS.md review-loop rule...)" | yes |
| `:271-273` `boundary-check.sh` | "Before presenting, run `boundary-check.sh` in the story's worktree (ENFORCED)" | yes |
| `:278-286` B7 merge gate | "### B7. Gate + integrate (the merge is the user's move, full stop)" | yes |
| file length | last numbered line 330 (329 content + trailing) | yes, same as round 16 |

Anchors at the top, middle and end of the file all resolve to the same text with no offset
drift, and the total length is unchanged. An insertion or deletion anywhere would have
shifted every anchor below it. **This round therefore RE-CONFIRMS an unchanged artifact at
a new commit; it does not score a changed one.** The scores below are re-derived from the
current text, not copied, and the cross-document verification is new work.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` with a description in the format
  the standard requires for explicit commands: what the user gets ("Build one or more ready
  user stories. Two modes you choose..."), plus the non-obvious invocation spelled out
  ("Name several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in
  parallel\""). No "Use when..." is required or wanted here; that form is for auto-invoked
  skills.
- structure **2**, and the trigger round 15 set still did not fire. That trigger: structure
  drops when the model-plan block passes 75 lines OR 25% of the file, or gains a subsection
  not tied to a named finding. Measured today: `:37-111` is exactly 75 lines of a 330-line
  file, 22.7%, identical to round 16. Body order follows the standard (essence `:6-7`, gates
  and mode choice, process per mode, worked example `:290-312`, output, safety rules
  `:321-329`). 330 of the 500-line limit, no supporting files, so the one-level-deep rule is
  satisfied trivially. The block sits ON the 75-line edge, so Top fix 1 carries forward for a
  third round.
- worked example **2**. `:291-312` runs a real invocation end to end with real values: a
  story id (`USR-012`), a real plan path (`docs/plans/2026-07-14-usr-012-timer.md`), real
  frontmatter keys (`approved: no` -> `approved: yes`, `model_plan:`, `builder_tier: sonnet`),
  a real worktree path (`../dogfood-usr-012`), a real verdict shape ("code-reviewer 12/12
  APPROVE -> docs/evals/code-USR-012.md") and the explicit end of the skill's authority
  ("Run /merge when you want it integrated." `<- ENDS here`). Directly imitable. Worth
  stating so a future reviewer does not mis-flag it: the `<session model>` slot at `:302` is
  NOT a placeholder failure under the standard's "no placeholders" rule. It is the deliberate
  consequence of the never-fabricate-a-model rule at `:70-73` and `AGENTS.md:52-57`; writing a
  concrete model name there would be the defect.
- precision **2**. Exact paths, scripts and field names throughout, with no TBDs and no "add
  X here": `spec-gate.sh <story paths...>` `:12`, `boundary-check.sh` `:271`,
  `worktree-parallel-check` `:161`, `resolve-language.sh <project-dir>` `:211`,
  `git worktree add ../<slug> -b feature/<slug>` `:135`, `code -r -g <file>` `:139`,
  `docs/plans/<date>-<slug>.md` `:208`, `arch_review: clean (v<N>, <date>)` `:224`,
  `builder_tier:` `:242`, `build_model_as_dispatched:` `:245`. Cross-references resolve and
  are correct in the direction they claim: `:236-237` says the builder's precondition list is
  authoritative in `agents/builder.md`, and `agents/builder.md:16-17` says exactly that of
  itself ("This list is AUTHORITATIVE for WHICH preconditions exist... `docs/plan-format.md`
  defines each field's shape"). One wording seam inside this criterion is listed below
  ("LOOPS until clean" applied to a scored loop); it is a phrasing nuance, not vagueness, and
  does not pull the criterion to "mostly exact".
- safety integration **2**. Guardrails are referenced, not restated or weakened:
  `AGENTS.md` Guardrail 3 + lint C11 for the no-model-names-in-files rule `:88`,
  `AGENTS.md` Guardrails 7 for the language handover `:213-214, :229-231, :257-259`,
  `docs/eval-framework.md` for the loop stop condition `:218-222`, `docs/plan-format.md` for
  the contract binding list `:154-155`. The enforced gates are named as enforced and as
  non-bypassable: `spec-gate.sh` "STOP on non-zero... Never work around it; if the gate is
  wrong, that is a bug to report, not to bypass" `:12-16`; `boundary-check.sh` "(ENFORCED)"
  `:271`; the plan gate "structural, not advisory" `:326`; and the merge rule stated as a
  closed list of non-permissions at `:281-284` ("Reviews passing is not permission; 'the
  pipeline naturally continues' is not permission; having merged the previous story is not
  permission"). The partial embedding of the stop condition in the skill body is sanctioned
  by `AGENTS.md:5-7` (safety-critical rules are embedded so they hold when that file is
  absent, e.g. a marketplace install), not a violation of "never restate a guardrail".

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion here: it is an explicit command (so
trigger clarity can reach 2 on the what-you-get form), real guardrails and enforced scripts
exist to reference (safety integration can reach 2), and a concrete end-to-end example is
present.

## The stop-condition check after `53f246e`, both directions

**Verdict: they agree, and the agreement is TIGHTER than at round 16. One pointer defect
remains, and it is in `docs/eval-framework.md`, not in the skill.**

1. **Skill -> framework (does the skill's citation still describe the source?).** `:218-222`
   cites "(`docs/eval-framework.md`: clean, 3 rounds, or two consecutive rounds of the same
   defect class, whichever comes first; a Critical is always reported)". Against
   `docs/eval-framework.md:178-236`: three exits, "stops on the FIRST of these", Critical
   "always overrides the cap". All three present, in source order, first-of-these semantics
   intact, Critical clause intact. Agreement confirmed clause by clause.
2. **The round-16 seam is CLOSED, by the framework.** Round 16 found exit 1 written in one
   rubric's units ("clears the threshold (>= 9 of 12, no criterion at 0)"), which was
   literally false for the plan loop (no score at all) and for skill/agent loops (8/10).
   `53f246e` replaced it with "the threshold declared by the rubric for THAT artifact type"
   plus a per-type table at `:189-196`, and added `:198-203`: "**The plan loop is the one exit
   without a number.** `architecture-reviewer` writes no record and publishes no score, so its
   clearing verdict is **clean**". The skill's word "clean" is now exactly the source's word
   for that loop, instead of being a paraphrase more accurate than its source. Round 16's Top
   fix 5 is resolved; it needed no edit to this skill.
3. **Framework -> skill (does the source's back-reference land?).** `docs/eval-framework.md:200-201`
   now writes the format INTO the framework and points back: "recorded by the orchestrator as
   `arch_review: clean (v<N>, <date>)` in the plan's frontmatter, per `skills/build/SKILL.md`
   step 2". The format matches this skill character for character (`:223-224`: "YOU record the
   outcome in the plan's frontmatter as `arch_review: clean (v<N>, <date>)`") and matches
   `docs/plan-format.md:53-55`. **The anchor does not land, though:** the skill's top-level
   "step 2" is `:18`, "Pick the mode (ALWAYS ask, never infer)". The plan-review loop is B5's
   step 2, at `:215`. A reader following that pointer arrives at mode selection. Small, but it
   is a pointer added by today's commit and it is the only inbound reference of its kind in
   the repo (`docs/eval-framework.md:201` is the sole hit). Fix belongs in the framework:
   "per `skills/build/SKILL.md`, B5 step 2".
4. **A second-order contradiction exposed by the same edit, outside this skill.**
   `docs/eval-framework.md:198-199` states that `architecture-reviewer` "publishes no score";
   `docs/plan-format.md:199-201` heads its rubric "Scored by `architecture-reviewer` during
   plan review". `agents/architecture-reviewer.md:16` settles it in the framework's favour
   ("findings ranked blocking / important / note, or state \"clean\" explicitly"; `:17` uses
   the plan rubric as a CHECKLIST, criterion 3). So `docs/plan-format.md:200` is the line that
   now overstates. The skill is on the correct side of this: `:221-224` says the reviewer
   "cannot write files" and has the orchestrator record `clean`, never a score. Reported as a
   cross-document finding, not as a defect of this artifact.

## Seams in the skill (none block, none move a score; 3 are carried from round 16)

- **Carried: the model-plan block sits exactly on the 75-line structure trigger** (`:37-111`).
  Third round unresolved. The next inline addition costs the structure point.
- **Carried: two pointers for one rule inside one file.** `:219` cites
  `docs/eval-framework.md` (canonical); `:266` cites "the AGENTS.md review-loop rule", and
  `AGENTS.md:39` is itself a pointer ("declared in `docs/eval-framework.md`"). B5.4's reader
  reaches the rule on a second hop, and a future editor has two places to keep true.
- **Carried: the two copies are not verbatim.** `:266` omits "whichever comes first", and its
  clearing exit lives in the lead-in prose rather than in the parenthesis, so `:266` reads as
  two exits where `:219` reads as three.
- **Carried: the B5.2 heading still says "to clean, max 3"** (`:215`). The full condition is
  one line below, so nobody is misled in context, but the heading is the skimmable line and
  round-cap-only phrasing is exactly what the delta reviewed in round 16 set out to remove.
- **Carried: B5.4 does not say what to hand the human on stop.** The plan loop does (`:222`,
  "present the disagreement, the human arbitrates"); B5.4 ends at "the user sees first ->
  final score". `docs/eval-framework.md:208-211` asks for "what is still open, what moved
  between rounds, and what did not", and `:221-222` asks for the class in one phrase.
- **New, small: "The review LOOPS until clean" applied to a SCORED loop** (`:265`). After
  `53f246e`, "clean" is the framework's term of art for the one loop WITHOUT a number (the
  plan loop, `:198-203`). The code/design loop's exit is a scored APPROVE against
  `agents/code-reviewer.md`'s threshold, not zero findings. Read strictly, `:265` now asks for
  something stricter than the rubric and could spend a round the framework would not require.
  The parenthesis that follows carries the correct rule, so no agent is misled in context;
  one word fixes it.
- **Low priority: the `arch_review: waived (human)` path has no step in this skill.**
  `agents/builder.md:24-26` and `docs/plan-format.md:54-55` both allow a waiver for a
  human-supplied standalone plan. `:236` says only "an `arch_review:` line", which is
  compatible with the waiver, so this is a coverage gap in the orchestrator's narrative, not a
  contradiction. Note it only if the waiver is meant to be reachable through `/build`.

## Integrity
No sign of text copied from another project. The voice is this system's throughout, and every
cross-reference resolves inside this repo (`docs/eval-framework.md`, `AGENTS.md`,
`docs/plan-format.md`, `agents/builder.md`, `merge-gate.sh`, `spec-gate.sh`,
`boundary-check.sh`, `resolve-language.sh`, `worktree-parallel-check`). Verified by opening
the cited files, not by pattern.

## Map duty
Satisfied, and nothing to update: no command surface was added or altered this round.
`/build` is catalogued at `docs/system-map.md:67` with both modes, its scripts at `:135-136`
(`coverage-check.sh`, `spec-gate.sh`), the overlap check at `:75`, and the mode rule restated
for the quick-reference at `:166`. Not a finding.

## Top fixes
1. **Structure, overdue since round 15**: lift `:37-111` into its own `## 3. Model plan`
   section, or move the resolution mechanics (model precedence, effort precedence, the
   source-tagging duty) into a supporting file one level deep. The block is exactly on the
   75-line trigger.
2. **Make the two stop-condition parentheses verbatim identical, both citing the canonical
   file.** Use at `:266` the exact text already at `:219-221`: "(`docs/eval-framework.md`:
   clean, 3 rounds, or two consecutive rounds of the same defect class, whichever comes
   first; a Critical is always reported)".
3. **Reword `:265` so the code loop's exit is its rubric, not "clean"**: "The review LOOPS
   until the reviewer's verdict clears its rubric's threshold" keeps "clean" reserved for the
   plan loop, matching `docs/eval-framework.md:198-203`.
4. **Add the stop handoff to B5.4**: "On stop, present what is still open, what moved between
   rounds and what did not, and name the class in one phrase; the human arbitrates."
5. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the line
   people skim carries the whole rule.
6. **Outside this skill, fix the pointer added today**: `docs/eval-framework.md:201`,
   "per `skills/build/SKILL.md` step 2" -> "per `skills/build/SKILL.md`, B5 step 2".
7. **Outside this skill, resolve the scoring contradiction**: `docs/plan-format.md:200`,
   "Scored by `architecture-reviewer` during plan review" -> "Checked by
   `architecture-reviewer` during plan review, which publishes findings and an explicit
   'clean', never a score", per `agents/architecture-reviewer.md:16` and
   `docs/eval-framework.md:198-199`.
8. **Still the structural fix, still unbuilt: a `skills-lint.sh` C-rule** failing any skill or
   agent file that states a review round cap ("max 3", "3 rounds") without the
   same-defect-class clause in the same paragraph. The condition now lives in four written
   places and nothing fails when one drifts. This is the repo's own Core Principle (eliminate
   the class, do not restate it) applied to the rule about loops.
9. **Optional, teaches the harder case**: one line in the worked example showing a STOPPED
   loop, e.g. "architecture-reviewer v2: same class as v1 (missing precondition on the same
   contract) -> loop stopped, presented for arbitration".

## Behavioral confirmation still owed
Form only, as always. Whether an agent actually stops at round two on a repeated class, names
the class in one phrase, and still reports a Critical found after the cap is an `/improve`
subagent test, not something this review can establish. The form is good enough to test. The
matrix case worth running is still the one the old wording got wrong: round 2 raises a finding
closed by the same kind of fix as round 1, score still below threshold. The agent should stop
AND say why, rather than spend round 3 because the cap allows it.

## Vs previous version
Round 16 (`fab5c0d`) -> round 17 (`2e7c740`), per criterion: trigger clarity 2 -> 2,
structure 2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total
10 -> 10. The ARTIFACT did not move (see the anchor table above); the record moved because the
branch did. What changed around the artifact is `53f246e`, which rewrote the framework's exit
1 into per-type thresholds and made "clean" the framework's own word for the plan loop. Net
effect on this skill: round 16's Top fix 5 is closed without touching the skill, and the
skill's citation went from "more accurate than its source" to "matching its source". Two new
seams appeared, both created by that edit and both OUTSIDE this file (the `step 2` anchor in
`docs/eval-framework.md:201`, the "Scored by" claim in `docs/plan-format.md:200`), plus one
new one-word seam inside it (`:265` "until clean" on a scored loop). Round 15's structure fix
remains unresolved into its third round. Nothing blocks merge.

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
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 16's. The SKILL is
  unchanged since round 16 (established by re-resolving every round-16 line anchor plus the
  330-line length; no shell was available to run `git diff`), so this round re-confirms an
  unchanged artifact at a new commit. New work: verification against `53f246e`, which rewrote
  `docs/eval-framework.md`'s stop condition. Both directions agree, and round 16's Top fix 5
  is closed by that commit without an edit here, since exit 1 is now per-artifact-type and
  "clean" is the framework's own word for the plan loop. Two new seams found outside this
  file (`docs/eval-framework.md:201` points at "step 2" where the rule lives in B5 step 2;
  `docs/plan-format.md:200` says the plan rubric is "Scored by architecture-reviewer" while
  the framework and the agent say it publishes no score), one inside it (`:265` "LOOPS until
  clean" applied to a scored loop). Round 15's structure fix carried a third time.
