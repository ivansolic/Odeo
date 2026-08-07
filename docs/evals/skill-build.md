---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: 995fde4
artifact_version: 9
date: 2026-08-07
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

Scope: form check of the three round-3 fixes plus the two architecture-review
additions in the same file (`skills/build/SKILL.md:37-85`, `:200-216`, `:247-268`).
Cross-checked against `AGENTS.md:40-89`, `AGENTS.md:262-279`,
`agents/builder.md:15-27` and `:112-121`, `agents/code-reviewer.md:136-142`,
`docs/plan-format.md:22-40`, `docs/eval-framework.md:55-79`,
`docs/invariants.md:20`.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Unchanged: `disable-model-invocation: true` with a
  description that says what you get plus an example invocation.
- structure **2** (held). The block is 49 lines and now paragraphed to match its
  content: the effort rule got its own paragraph (`:48-51`), the duplicate is gone,
  and the lineup sentence wraps normally instead of colliding. The `### Model plan`
  subheading and three-way split remain undone and are carried knowingly; that is
  the author's call and, as I said in round 3, its symptoms were the thing I was
  charging for and they are now fixed.
- worked example **2** (held). `:253-259` mirrors the step, `:265-266` now shows
  the provenance field landing where it lives ("docs/evals/code-USR-012.md
  (branch: + reviewed_commit: + build_model_as_dispatched: ...)"). One two-word nit
  below on the gloss.
- precision **2** (was 1, moves). Nothing in the block now asks for a value the
  agent cannot obtain, which is what held this at 1 for three rounds. `:48-51`
  states the fact ("EFFORT is not machine-readable at all (see AGENTS.md), so there
  is nothing to resolve"), gives the action ("ASK for it in the same breath ('and
  what does `/effort` say?')"), and forbids the failure ("Never print a
  resolved-looking effort value you were not told"). `:76-78` now names exactly what
  goes in the plan and points at B5.4 for what does not. Paths, names, fields and
  commands are exact throughout: `/model`, `/effort`, `spec-gate.sh`,
  `boundary-check.sh`, `merge-gate.sh`, `builder_tier:`,
  `build_model_as_dispatched:`, `docs/plan-format.md`. No TBDs, no placeholder
  steps, no version-pinned name.
- safety integration **2** (held, and stronger). Two additions harden it. `:48-51`
  ties effort to the never-fabricate rule at the exact point where a plausible
  value would be invented. `:206-210` closes the loop hole I would have raised if
  the architecture review had not: the review loop regenerates the record, so the
  value must be handed over on EVERY dispatch, and the field is declared best-effort
  with the inference explicitly barred ("its absence is never evidence that a build
  ran on the default"). That is the right posture for provenance no gate reads.
  Everything downstream still agrees: `docs/eval-framework.md:67-76`,
  `agents/code-reviewer.md:142` ("Omit the field if you were given no value, and
  never guess one"), `agents/builder.md:18-21` (absence "is never a missing
  precondition and never a reason to refuse"), `AGENTS.md:275-279` (the one
  never-fabricate exception, labelled). Records stay reviewer-owned. No gate is
  weakened.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## (a) The three findings
1. **Effort: CLOSED, and closed better than I specified.** I asked for `/effort`
   in the ASK; the fix instead removed the false premise. The step no longer claims
   effort is resolvable, which is what `AGENTS.md:67-69` actually says, and it bars
   printing a value that was not given. Fixing the verb rather than appending the
   flag was the correct diagnosis of my own finding.
2. **Duplicate with-me sentence: CLOSED.** Exactly one occurrence remains
   (`:69-70`), placed next to the quoted question where an agent copies from, and
   the 130-character collision at the old `:75` is gone with it.
3. **The `:71-73` phrase: CLOSED.** `:76-78` now reads "write into the plan's
   `model_plan:` the judgment model and effort AND `builder_tier:` (a tier word plus
   effort; that is the line the builder's contract requires). The build model NAME
   never goes in the plan, see B5.4." No longer readable against B5.4.

## (b) Does precision move off 1? Yes
The reason it sat at 1 through rounds 1 to 3 was always the same: an instruction
that demanded a value with no obtainable source (first the host's model list, then
the session effort). Both are gone. What remains are two wording nits that leave no
instruction unfollowable and open no fabrication path, so 2 is the honest score.
Applying my own round-1 test: if this text arrived fresh with only these two items,
I would have scored precision 2 and listed them as nits. Consistency requires the
same answer now.

## Non-blocking nits (would tighten, do not lower any score)
1. **`:266`, two words.** The example glosses the field as
   "build_model_as_dispatched: <the model the builder ran on>", which asserts the
   claim the field's name deliberately refuses. `docs/plan-format.md:36-38`,
   `docs/eval-framework.md:73-76` and `AGENTS.md:275-279` all say "as dispatched",
   not "as ran", because nobody here can verify what the vendor served. Change the
   gloss to "<the model it was dispatched on>". The record stays honest either way,
   since the field is labelled and its definition lives elsewhere; this is the one
   place a reader imitates, so the prose should match.
2. **`:62`, one word.** The question still prints "at effort <as resolved>" while
   `:48-51` has just established there is nothing to resolve. The adjacent
   paragraph fixes the meaning, so no agent is misled, but "<as the user just told
   you>" would remove the last echo of the old premise.
3. The subheading and paragraph split, carried knowingly. Still worth doing the
   next time these lines are edited, for the reason recorded in round 3 (three of
   four defects across this branch lived in that one paragraph). Not a deduction.

## House style
No em or en dashes in the new text. English only. C11 clean: `sonnet` appears only
as a tier word (pattern `(opus|sonnet|haiku|fable)[- ][0-9]` has no hit). No
time-sensitive external fact asserted; the `merge-gate.sh` rationale at `:210-214`
is a measured mechanism, not a volatile claim.

## Ceiling
10/10, reached. Nothing structurally capped: explicit command (trigger clarity on
plain what-you-get), guardrail-adjacent change (safety integration can reach 2),
and the example's `<...>` model slots are the correct tier-speaking form rather
than a shortfall, since a named version would trip lint C11.

## Round-by-round (this branch)
- Round 1 (5b46abd): 6/10 FAIL. Four blocking findings.
- Round 2 (a2eec03): 9/10 PASS. All four closed; one residual contradiction.
- Round 3 (76188a6): 9/10 PASS. Contradiction closed; the effort fix had landed on
  the wrong sentence, plus a stale duplicate and one ambiguous phrase.
- Round 4 (995fde4): 10/10 PASS. All three closed, precision 1 -> 2. Trajectory
  6/10 -> 9/10 -> 9/10 -> 10/10, moved only by fixing files.

## Is it clean?
Yes. Nothing blocks. No criterion is below 2, no instruction in the block requires
a value the agent cannot get, no two instructions disagree with each other or with
`AGENTS.md`, `docs/plan-format.md`, `docs/eval-framework.md`,
`agents/builder.md` or `agents/code-reviewer.md`, and no gate is touched or
weakened. The three nits above are optional polish, not gate material. This is
ready for the human gate.

The one thing the human should know it is NOT: a behavioral verification. The
whole design rests on an agent, at runtime, walking the order of authority and
ASKING instead of trusting the session-start model and a plausible-looking effort
level it can see in its own context. The form now supports that everywhere; only
an `/improve` subagent test (baseline without the step, variant with it) can show
the behavior holds. Worth scheduling after the merge, not before it.

## Vs previous version
Version 8 (76188a6) scored 9/10 with one unresolvable value left in the question.
Version 9 removes the false premise behind it rather than papering over it, deletes
the stale duplicate, and disambiguates what goes in the plan. The
architecture-review additions close a loop hole in the same pass: the provenance
value is handed over on every dispatch, because the review loop regenerates the
record and only the surviving record is read, and the field is declared best-effort
so its absence cannot be read as evidence. Score 10/10, no regression on any
criterion across the branch.

## Map duty
No command surface added or altered (`docs/system-map.md:67` already carries
`/build` with both modes), so no map delta is required. Not a finding.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Strongest-model-available
  resolution added.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL. Build model became
  the user's choice; four blocking form defects (unobtainable enumeration,
  self-assessed ASK trigger, stale example, AGENTS.md not carrying the rule).
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS. All four closed;
  residual contradiction between the never-enumerate paragraph and the old
  strongest-on-this-host clause.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS. Contradiction
  closed; C11 paragraph cut to a pointer; the resolved build model moved from the
  plan to the code eval record coherently across five files. Precision held at 1:
  the effort fix landed on the switch-up sentence instead of the ASK.
- Round 9 (2026-08-07, Opus 5, strongest, 995fde4): 10/10 PASS. Effort fixed at
  the premise (not machine-readable, so ASK and never print a value you were not
  told), duplicate deleted with its collided line, plan-write phrase disambiguated,
  and the provenance handover made loop-safe and explicitly best-effort. Precision
  1 -> 2; all other criteria held at 2. Three optional nits recorded (the "as ran"
  gloss at `:266`, the "<as resolved>" echo at `:62`, the deferred paragraph split).
  Clean for the human gate; behavioral confirmation still owed to `/improve`.
