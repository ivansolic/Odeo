---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: 76188a6
artifact_version: 8
date: 2026-08-06
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

Scope: third pass on the model-plan step (`skills/build/SKILL.md:37-80`) and B5.4
(`:195-207`) after the round-2 fixes and the plan-field change the architecture
review made in the same commit. Cross-checked against `AGENTS.md:40-89`,
`AGENTS.md:147-152`, `AGENTS.md:262-279`, `agents/builder.md:15-27` and
`:112-121`, `agents/code-reviewer.md:136-142`, `docs/plan-format.md:22-40`,
`docs/eval-framework.md:55-79`, `docs/invariants.md:20`.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Unchanged, correct explicit-command format with an
  example invocation in the description.
- structure **2** (held). Cutting the C11 paragraph removed about six lines; the
  block is 44 lines with the ordered-authority list intact. I am NOT scoring the
  missing split, because its observable symptoms (a stale duplicate, a collided
  line) are scored under precision and double counting would be unfair. But my
  answer to your question is yes, the split has stopped being cosmetic: see
  "On the paragraph split" below, it is now evidence-backed.
- worked example **2** (held). `:244-250` mirrors the step and improved by
  accident of the design change: `model_plan: judgment <session model> ·
  builder_tier: sonnet` is now exactly the shape `docs/plan-format.md:24-29`
  prescribes, and my round-2 nit about `builder_as_dispatched:` is obsolete since
  the field moved out of the plan. One new nit (5).
- precision **1** (held, for a smaller reason). Two of three round-2 items landed.
  The blocking contradiction is gone: `:75-79` now reads "below the strongest model
  in the CURRENT OFFICIAL LINEUP (resolved live per AGENTS.md, which tells you what
  EXISTS, not what this account has)" and adds "If the user says it is not on their
  plan, drop the point", which is resolvable and no longer fights `:48-51`. But the
  effort finding did NOT land where the dispatch message says it did. `:46` still
  reads "if neither is unambiguous, ASK: 'run `/model` and tell me what it
  reports.'" `/effort` was added at `:78` instead, which is the switch-up
  sentence, a different instruction. So the question at `:57` still asks for
  "effort <as resolved>" with nothing in the skill resolving it, and
  `AGENTS.md:67-69` says runtime effort is "not reliably script-readable". That is
  the same class of defect as the two already fixed: a template asking for a value
  the block provides no path to. Plus a stale duplicate and one loose phrase
  (findings 2 and 3).
- safety integration **2** (held). The ecosystem moved coherently in one commit,
  which is the strongest form of this criterion: `docs/plan-format.md:30-40` says
  the plan holds intent only and is immutable after the gate,
  `docs/eval-framework.md:67-76` defines `build_model_as_dispatched:` with the same
  reason and the same "as dispatched, not as ran" honesty,
  `agents/code-reviewer.md:142` makes the reviewer the field's author ("Omit the
  field if you were given no value, and never guess one"),
  `agents/builder.md:18-21` tells the builder the absent name "is never a missing
  precondition and never a reason to refuse", and `AGENTS.md:275-279` labels the
  one never-fabricate exception explicitly. `SKILL.md:67-68` is now a pointer, not
  a copy, and the reason it had to be cut is the right one: after the field moved,
  the old paragraph asserted the opposite of the design. Records stay
  reviewer-owned, which is what kept this from becoming a guardrail problem. One
  upstream clause to tighten (finding 4), not enough to cost the point.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## (a) Round-2 findings
1. **Leftover strongest-model clause: CLOSED.** `:75-79`, resolvable via the
   official lineup, with the "not on their plan, drop the point" exit.
2. **Effort in the ASK: NOT CLOSED.** `/effort` went to `:78`, not to the ASK at
   `:46`. See finding 1; one-line fix.
3. **With-me exclusion moved next to the quote: CLOSED at `:64-65`**, and moving
   it to where an agent copies from was the right call. But the old copy at
   `:74-75` was not deleted, so the instruction now exists twice (finding 2).

## (b) Does anything in the block still disagree with anything else?
No outright contradiction remains. I walked all nine instructions in `:37-80`
pairwise. What remains is the soil contradictions grow in, not a contradiction:
- **A duplicate that agrees.** `:64-65` ("In WITH-ME mode drop the Build line from
  that question entirely") and `:74-75` ("In with-me mode there IS no builder agent
  and no dispatch, so do not offer a build model there") say the same thing twice.
  Harmless today, and exactly how both earlier contradictions started: an edit that
  added the new sentence without removing the old one.
- **One phrase readable against B5.4.** `:71-73` "write the answer into the plan
  file as `model_plan:` including the effort for each role" could be read as
  putting the resolved build model in the plan, which `:201` forbids and
  `plan-format.md:31` forbids. The parenthetical naming `builder_tier:` saves it
  for a careful reader; a hasty one could write a resolved name (finding 3).
- **A collided line.** `:75` physically joins the tail of the stale with-me
  sentence to the head of the new lineup sentence on one ~130-character line, well
  past this file's wrap. That is not style: it is evidence the paragraph is now
  hard to edit without collateral damage.
Cross-file, everything material agrees (see safety integration). The one loose
clause is upstream: `AGENTS.md:266` still says the model a builder actually runs on
is "recorded in the plan". `AGENTS.md:271-279` gets it right two lines later, so a
reader of the whole guardrail lands correctly, which is why this is finding 4 and
not a blocker.

## On the paragraph split (your NOT-done item)
It now counts, and here is the evidence rather than the preference: of the four
defects found across rounds 1 to 3, three lived in this one closing paragraph (the
enumeration demand, the strongest-on-this-host contradiction, the stale with-me
duplicate), and the newest edit landed by colliding two sentences on `:75`. A
paragraph that keeps producing the same class of defect under edit is a structural
problem, not a formatting taste. I am still not deducting for it, because I would
be charging twice for lines already charged under precision. Recommendation: do
the split in the same pass as finding 1, since you will be editing these exact
lines anyway. `### Model plan` over `:37`, then three short paragraphs: what gets
asked, what gets written where, the switch-up flag.

## Findings

1. **`skills/build/SKILL.md:46`, the one fix between this and 10/10.** Replace
   with: "if neither is unambiguous, ASK: 'run `/model` and `/effort` and tell me
   what they report.'" Optionally add the honest fallback, since
   `AGENTS.md:67-69` says effort is not machine-readable: "if the user does not
   check, say the judgment effort was not resolved rather than naming a level."

2. **`skills/build/SKILL.md:74-75`, delete the stale duplicate (required tidy).**
   Remove "In with-me mode there IS no builder agent and no dispatch, so do not
   offer a build model there: the only lever is `/model` for the session itself."
   `:64-65` already says it, better placed. Then start the lineup sentence on its
   own line so `:75` stops being a collided run-on.

3. **`skills/build/SKILL.md:71-73`, close the last readable-two-ways phrase.**
   Replace "write the answer into the plan file as `model_plan:` including the
   effort for each role (`builder_tier:` is the line the builder's contract
   requires)" with: "write `judgment: <resolved model> effort <level>` and
   `builder_tier: <tier word> effort <level>` into the plan's `model_plan:`. The
   resolved BUILD model never goes in the plan (B5.4 says why)."

4. **`AGENTS.md:266`, tighten one clause (nit, upstream).** "recorded in the
   plan" is now loose: the plan records the approved TIER, the resolved name goes
   to the code eval record. Suggested: "approved in the plan as a tier word
   (`builder_tier:`) and disclosed in the code eval record as
   `build_model_as_dispatched:`; nothing enforces it, so do not read 'pinned' into
   it."

5. **`skills/build/SKILL.md:256`, one token in the example (nit).** The record
   line says "(branch: field set)"; make it "(branch + build_model_as_dispatched
   set)" so the provenance field's destination is visible in the one place a
   reader imitates.

## House style
No em or en dashes. English only. Middle dot at `:250` matches house usage
(`AGENTS.md:121`). C11 clean: `sonnet` appears only as a tier word, pattern
`(opus|sonnet|haiku|fable)[- ][0-9]` has no hit. No time-sensitive external fact
asserted. The `merge-gate.sh:294` rationale at `:201-205` is a measured
mechanism, not a volatile claim.

## Ceiling
Max reachable 10/10, one line away (finding 1). Nothing structurally capped.

## Round-by-round (this branch)
- Round 1 (5b46abd): 6/10 FAIL. Four blocking findings.
- Round 2 (a2eec03): 9/10 PASS. All four closed; one residual contradiction.
- Round 3 (76188a6): 9/10 PASS. The contradiction is closed and the plan-field
  change is coherent across five files, but the effort fix landed on the wrong
  line, so precision holds at 1. The total did not move; the residual behind it
  shrank from "an instruction that contradicts another instruction" to "an
  instruction whose value has no resolution path, plus two tidies". Reported as it
  is rather than rounded up: 9/10, not 10.

## Can this go to the human gate?
Rubric verdict: PASS, and nothing here is a guardrail risk, so I am not standing
in the way of the gate. My recommendation is to spend one more edit first, not
another review cycle: findings 1 and 2 are a one-line addition and a two-line
deletion in lines you are already touching, and finding 1 is the third instance of
the same defect class this branch has been closing. Taking it to the human with
`/effort` missing from the ASK means shipping a question that asks for a value the
skill never resolves. If you apply 1 to 3 (and, on your judgment, 4 and 5),
re-dispatch me for a fresh record at the new commit; that is a form check, and it
is cheap.

## Vs previous version
Version 7 (a2eec03) scored 9/10 with one blocking contradiction. Version 8 closes
it and, through the architecture review's plan-field change, makes the provenance
story genuinely coherent: intent in the plan before the gate, resolved name in the
reviewer-owned eval record, "as dispatched" labelled as disclosure rather than a
claim about execution, and a measured reason (`merge-gate.sh:294`) for the split
instead of a guess. The score holds at 9 because a different, smaller precision
hole was left open.

## Map duty
No command surface added or altered (`docs/system-map.md:67` already carries
`/build`), so no map delta is required. Not a finding.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Strongest-model-available
  resolution added to the model-plan step.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL. Build model became
  the user's choice; four blocking form defects (unobtainable enumeration,
  self-assessed ASK trigger, stale example, AGENTS.md not carrying the rule).
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS. All four closed;
  residual contradiction between `:48-51` and the old `:77-79`.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS. Contradiction
  closed; C11 paragraph cut to a pointer (it had come to assert the opposite of
  the design once the field moved); the resolved build model moved from the plan to
  the code eval record, coherently across `plan-format.md`, `eval-framework.md`,
  `code-reviewer.md` and `builder.md`, with records staying reviewer-owned.
  Precision held at 1: `/effort` was added to the switch-up sentence (`:78`)
  instead of to the ASK (`:46`), leaving "effort <as resolved>" unresolvable, plus
  a stale with-me duplicate at `:74-75` and one phrase at `:71-73` readable against
  B5.4. Composition unchanged from version 7 (2,2,2,1,2); the residual shrank.

Note: form review. The behavioral question is unchanged and still open by
construction, whether an agent walks the order of authority at runtime instead of
trusting the session-start value visible in its own context. That is an `/improve`
subagent test, not mine. The form now supports the right behavior everywhere
except the effort value.
