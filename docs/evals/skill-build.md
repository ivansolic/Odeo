---
artifact: skills/build/SKILL.md
type: skill
branch: feature/windows-powershell-entry
reviewed_commit: fab5c0d   # HEAD of the branch, supplied by the dispatcher
                           # (full: fab5c0de7c35869a778a09df14973544abf83e96).
                           # The delta under review is commit 54f3ab1, unchanged at HEAD.
                           # Round 15's sha was e0ce263.
artifact_version: 16
date: 2026-09-16
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: the whole `skills/build/SKILL.md` (330 lines), read against
`docs/skill-authoring-standard.md`, `docs/eval-framework.md:175-210` (the canonical review
stop condition) and `AGENTS.md:39-44` (reworded in the same commit). The delta under review
is commit `54f3ab1`: both review loops in Mode B, the plan loop (`:215-222`) and the
code/design loop (`:262-268`), previously stated only the round cap and now carry the whole
declared stop condition. Cross-document check run over the three files for competing caps
and for wording drift, plus the thresholds the condition's APPROVE clause implies
(`agents/code-reviewer.md:91`, `agents/design-reviewer.md:61`, `agents/architecture-reviewer.md:16`,
`agents/skill-reviewer.md:49`, `agents/agent-rubric.md:37`). Structure re-measured against
the mechanical trigger round 15 set. `docs/system-map.md` checked for the map duty. The
branch stacks this change with several unrelated small items on purpose, one review cycle
instead of several; the skill file is unchanged between `54f3ab1` and `fab5c0d`.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Untouched this branch. `disable-model-invocation: true` with a
  description that says what the user gets and shows the non-obvious invocation ("Name
  several stories to build them in parallel, e.g. \"/build USR-001 USR-002 in parallel\"").
  Correct format for an explicit command.
- structure **2**, and the round-15 trigger did NOT fire. That trigger: structure drops when
  the model-plan block passes 75 lines OR 25% of the file, or gains a new subsection not tied
  to a named finding. Measured today: the block is still `:37-111`, exactly 75 lines, and the
  file grew to 330 lines, so the block is 22.7%, further from the percentage edge than last
  round. This commit added no subsection; it added one clause inside `B5.2` and one inside
  `B5.4`, both tied to the named single-source finding. 330 lines against the 500 limit, no
  supporting files. The block remains exactly ON the 75-line edge, so Top fix 1 from round 15
  carries forward unchanged.
- worked example **2**. Untouched and still concrete: real story id, real paths, real
  frontmatter keys, a real verdict shape ("code-reviewer 12/12 APPROVE ->
  docs/evals/code-USR-012.md"). It shows the loops' NORMAL exit (one round, clean), which is
  the right default to teach. The new stop condition is not demonstrated there, but unlike
  the usual "stale example far from the rule" failure, the file already carries a concrete
  instantiation AT the point of use, `:225-226` ("v1: 2 blocking findings -> v2: 1 -> v3:
  clean"). An agent is not left to invent the shape. A stopped-loop line in the example would
  still teach the harder case, carried as a fix, not a deduction.
- precision **2**. The wording matches the source, checked clause by clause rather than by
  impression. `:218-222`: "repeat until the stop condition (`docs/eval-framework.md`: clean,
  3 rounds, or two consecutive rounds of the same defect class, whichever comes first; a
  Critical is always reported)". Against `docs/eval-framework.md:177-196` that is all three
  exits, in source order, with the first-of-these semantics and the Critical clause intact.
  `:264-268` states the same three for the code/design loop. Both are actionable without
  reading the source: a builder-side agent now knows it may stop at round two on a repeated
  class, which is the behavior the old "max 3" wording silently withheld. Exact paths, names
  and commands hold throughout the rest of the file (`spec-gate.sh`, `boundary-check.sh`,
  `worktree-parallel-check`, `arch_review:`, `builder_tier:`); no placeholders, no TBDs. Two
  seams inside this delta do not reach "mostly exact" but are listed below and are worth the
  next edit.
- safety integration **2**. The condition is cited, not invented, and the rationale (why
  three, what STOP does not mean, the operational definition of "same class") is left in
  `docs/eval-framework.md` rather than copied. The partial restatement is sanctioned policy,
  not a violation of "never restate a guardrail": `AGENTS.md:5-7` states that safety-critical
  rules are deliberately embedded in skill and agent bodies so they hold when that file is
  absent, for instance in a marketplace install. Nothing here weakens the rule; the skill's
  version is strictly stricter than the old one. The enforced gates around it (`spec-gate.sh`
  at `:12-16`, `boundary-check.sh` at `:271-273`, the plan gate, the merge-is-the-user's-move
  rule at `:278-286`) are untouched.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. Nothing structurally caps a criterion: explicit command (trigger clarity can
be 2), real guardrails to reference (safety integration can be 2), concrete worked example
present.

## Cross-document check (the three files, asked for explicitly)
**Verdict: the caps agree; one real seam remains, and it is in `docs/eval-framework.md`, not
in the skill.**

1. **No competing cap survives.** All three say three. `AGENTS.md:39-44` labels the
   historical five as an incident in the same breath: "Five is what the missing cap cost on
   that branch, not a second limit: the limit is the three above". `docs/eval-framework.md:198-204`
   does the same for four: "Four is what those branches cost before this cap existed, not a
   competing cap: the cap is three". Both readings hold as stated; a reader cannot come away
   with a number other than three, and each incident stays legible as evidence FOR the cap.
   `SKILL.md:219` and `:266` both say three. Confirmed.
2. **The live seam: the APPROVE clause is written in one rubric's units.**
   `docs/eval-framework.md:179-180` defines exit 1 as "The verdict clears the threshold
   (>= 9 of 12, no criterion at 0)". That is the code and design rubric
   (`agents/code-reviewer.md:91`, `agents/design-reviewer.md:61`). The same stop condition
   governs loops where it does not apply: the plan loop's reviewer produces no score at all
   ("findings ranked blocking / important / note, or state \"clean\" explicitly",
   `agents/architecture-reviewer.md:16`), and skill and agent reviews run on 8/10
   (`docs/skill-authoring-standard.md:99`, `agents/agent-rubric.md:37`). So the canonical
   document's own first exit is literally false for two of the loops it governs, and
   `SKILL.md`'s paraphrase ("clean") is MORE accurate than the source it cites. Fix belongs
   in `docs/eval-framework.md:179`: "the verdict clears ITS rubric's threshold (code and
   design 9/12, skills and agents 8/10, plan review: an explicit 'clean') with no Critical".
   Not a blocker for this skill; it is the next place this class returns.
3. **Vocabulary drift, style not contradiction.** Three names for one exit (`AGENTS.md`
   "approve", `eval-framework` "APPROVE ... clears the threshold", `SKILL.md` "clean") and
   two phrasings of the Critical clause ("always overriding the cap" vs "is always
   reported"). The skill's phrasing keeps the operative consequence, so no agent is misled,
   but one vocabulary across the three files would cost nothing.

## Seams inside this delta (none block, none move a score)
- **Two pointers for one rule, inside one file.** `:219` cites `docs/eval-framework.md`, the
  canonical home; `:266` cites "the AGENTS.md review-loop rule", and `AGENTS.md:39` is itself
  a pointer ("declared in `docs/eval-framework.md`"). A reader of `B5.4` therefore reaches
  the rule through a second hop, and a future editor has two places to keep true. In a commit
  whose whole purpose is single-sourcing, both parentheses should cite the same file.
- **The two copies are not verbatim.** `:266` drops "whichever comes first", and its "clean"
  lives in the lead-in prose ("The review LOOPS until clean") rather than in the parenthesis,
  so the parenthesis reads as two exits where `:219`'s reads as three. Substantively equal,
  textually divergent, which is how copies start drifting.
- **The B5.2 heading still carries the old shorthand.** `:215`: "Plan review LOOP
  (architecture-reviewer x architect, to clean, max 3)". The full condition is one line
  below, so nobody is misled in context, but the heading is the line people quote and skim,
  and round-cap-only phrasing is precisely what this commit set out to remove.
- **The code loop does not say what to hand the human on stop.** The plan loop does (`:222`,
  "present the disagreement, the human arbitrates"); `B5.4` ends at "the user sees first ->
  final score". `docs/eval-framework.md:181-184` asks for "what is still open, what moved
  between rounds, and what did not", plus the class stated in one phrase when the class rule
  is invoked (`:196`). One sentence closes it.
- **Four written copies, no mechanism keeping them equal.** The condition now lives in
  `eval-framework` (canonical), `AGENTS.md:39-44`, and twice in this skill. Policy allows the
  embedding (`AGENTS.md:5-7`), and the duplication is deliberate. What is missing is the
  tripwire: nothing fails when copy three drifts from copy one. That is the repo's own Core
  Principle about eliminating a class rather than restating it, applied to this commit.

## Integrity
No sign of text copied from another project. Voice is this system's; every cross-reference
(`docs/eval-framework.md`, `AGENTS.md`, `docs/plan-format.md`, `merge-gate.sh`,
`spec-gate.sh`, `boundary-check.sh`, `resolve-language.sh`) resolves inside this repo.

## Map duty
No command surface added or altered; `/build` and its scripts already sit on
`docs/system-map.md`. Not a finding.

## Top fixes (all next-edit polish, none a blocker)
1. **Structure (overdue, carried from round 15)**: lift `:37-111` into its own `## 3. Model
   plan`, or move the resolution mechanics to a supporting file. The block is exactly on the
   75-line trigger; the next inline addition costs the point.
2. **Make the two stop-condition parentheses verbatim identical** and have both cite
   `docs/eval-framework.md`. Suggested text for both: "(`docs/eval-framework.md`: clean, 3
   rounds, or two consecutive rounds of the same defect class, whichever comes first; a
   Critical is always reported)".
3. **Add the stop handoff to `B5.4`**: "On stop, present what is still open, what moved
   between rounds and what did not, and name the class in one phrase; the human arbitrates."
4. **Reword the `:215` heading** to "to clean, max 3 rounds or a repeated class", so the
   skimmable line carries the whole rule.
5. **Fix `docs/eval-framework.md:179`** per cross-document point 2 (the 9/12 threshold stated
   as if universal). Outside this skill, but this is where the class recurs next.
6. **Consider a `skills-lint.sh` C-rule**: fail any skill or agent file that states a review
   round cap ("max 3", "3 rounds") without the same-defect-class clause in the same
   paragraph. That is the mechanism that keeps the four copies equal; prose alone will not.
7. **Optional, teaches the harder case**: one line in the worked example showing a stopped
   loop, e.g. "architecture-reviewer v2: same class as v1 (missing precondition on the same
   contract) -> loop stopped, presented for arbitration".

## Behavioral confirmation still owed
Form only, as always. Whether an agent actually stops at round two on a repeated class,
states the class in one phrase, and still reports a Critical found after the cap, is an
`/improve` subagent test. The form is good enough to test. The matrix case worth running is
the one the old wording got wrong: round 2 raises a finding closed by the same kind of fix as
round 1, score still below threshold. The agent should stop AND say why, not spend round 3
because the cap allows it.

## Vs previous version
Round 15 (`e0ce263`, fix/build-model-effort-source) -> this round (`54f3ab1`, read at branch
HEAD `fab5c0d` on feature/windows-powershell-entry), per criterion: trigger clarity 2 -> 2,
structure 2 -> 2, worked example 2 -> 2, precision 2 -> 2, safety integration 2 -> 2. Total
10 -> 10. The score held at the ceiling; what changed is that both review loops now state the
WHOLE stop condition instead of the round cap alone, which closes a rule that was enforced in
`docs/eval-framework.md` and merely believed in the skill that runs the loops. The residuals
are different in kind from round 15's: those were provenance asymmetries inside the model-plan
block, these are duplication seams (two pointers, two non-identical copies, no lint keeping
them equal). Round 15's Top fix 1 (structure, the 75-line edge) is unresolved and carried.
Nothing blocks merge.

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
  feature/windows-powershell-entry): 10/10 PASS. This record REPLACES round 15's. Scope:
  commit 54f3ab1, the whole stop condition now stated in both review loops (`:218-222`,
  `:264-268`), verified clause by clause against `docs/eval-framework.md:175-210` and
  `AGENTS.md:39-44`. Cross-document check: no competing cap survives, five and four are
  labeled as incidents and read that way; one live seam found in `docs/eval-framework.md:179`
  (the APPROVE threshold written in the 12-point rubric's units while governing loops scored
  8/10 or not scored at all). New residuals are duplication seams inside the delta; round 15's
  structure fix is carried forward unresolved. Regenerated once, unchanged in scores or
  findings, after the dispatcher supplied the HEAD sha that was missing at first write.
