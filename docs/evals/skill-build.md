---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: 5b46abd
artifact_version: 6
date: 2026-08-06
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 1, worked_example: 1, precision: 1, safety_integration: 1 }
total: 6/10
verdict: FAIL
previous_total: 10/10
---

Scope: form review of the rewritten model-plan step (`skills/build/SKILL.md:37-77`)
plus the B5.4 dispatch line (`:193-197`), cross-checked against
`agents/builder.md:109-116` (changed in the same commit), `AGENTS.md:40-83`,
`AGENTS.md:147-152`, `AGENTS.md:257-266`, `docs/plan-format.md:24-26` and the
worked example further down the same skill (`:226-245`). The whole skill was
re-scored for consistency.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. `disable-model-invocation: true` plus a description that
  opens "Build one or more ready user stories. Two modes you choose..." and
  carries an example invocation ("/build USR-001 USR-002 in parallel"). Correct
  explicit-command format; untouched by this commit.
- structure **1**. The file is still inside the limits (262 lines < 500, no
  supporting files, so the one-level rule is not at risk) and still follows the
  body shape, but the model-plan block is now 41 unbroken lines (`:37-77`) inside
  a step titled "## 2. Pick the mode (ALWAYS ask, never infer)", and it carries
  six distinct concerns in one run: live resolution of the session model, live
  resolution of the host lineup, the strongest-of-those, the spoken question, the
  per-run-dispatch rationale, the per-host change mechanism, the `model_plan:`
  write rule, and the switch-up flag. The live-resolution rule is stated twice in
  the same block: `:39` "Resolve LIVE, never from anything written down" and
  `:75-76` "resolve the current lineup live, never from a cached table". Against
  "The proven shape (adapt, don't pad)" and "Keep SKILL.md lean" this reads as
  padding a step rather than structuring it: partial, not a wall of text.
- worked example **1**. The example lags the very thing this commit adds.
  `:231-234` still shows the old single-role phrasing, "Model plan: thinking/reviews
  on <session model, resolved now> at effort <session effort>, building on <builder
  tier> at effort high. Continue, or change?", which STATES the build tier instead
  of OFFERING the choice. The new step (`:51-60`) requires one question that lists
  what the host offers now and carries the recommendation; none of that appears in
  the example, and no example line shows a user naming a build model or the chosen
  model landing in `model_plan:`. Concrete values elsewhere are still good
  (`docs/plans/2026-07-14-usr-012-timer.md`, `../dogfood-usr-012`, `12/12
  APPROVE`), so this is "present but thin", not absent. This is the same defect
  that scored 1 in Round 1 of this record's history; it has reopened.
- precision **1**. Most of the block is exact, but the load-bearing new
  instruction has no mechanism: `:47-48` "the models AVAILABLE on this host right
  now, as the harness reports them" and the question slot `:54` "<list what this
  host offers now>". No tool in this system reports a host's or a subscription's
  model list, and the agent cannot run `/model` itself. The step therefore asks
  for data it cannot obtain, while the bullet directly above it forbids the only
  other source an agent has (memory), so by omission the instruction invites the
  exact fabrication the same paragraph bans. It also silently swaps out a mechanism
  that DID exist: `AGENTS.md:46-47` resolves the lineup "against the CURRENT
  official model lineup (models-overview + a second source)", which is fetchable;
  "as the harness reports them" is not. Second precision gap: the ASK fallback
  fires on "If it cannot be resolved with certainty" (`:42-43`), a self-assessed
  trigger, and its utterance covers only the model ("run `/model` and tell me what
  it reports") while the bullet it serves covers "the model ... and its effort".
  `AGENTS.md:62-64` states plainly that runtime effort is "not reliably
  script-readable", so effort has no resolution path at all here.
- safety integration **1**. Nothing is weakened: the spec gate (section 1), the
  plan gate (B5.3), ENFORCED `boundary-check.sh` (B6) and the merge gate (B7) are
  untouched, the never-fabricate rule is invoked at the right point (`:45-46`), the
  per-host adapter and the builder's contract are referenced rather than copied
  (`:68-71`), and the switch-up stays a question. Two things cap it at 1. (a) The
  closing paragraph restates a guardrail it should reference: `:63-67` reproduces
  C11's content, its rationale AND its incident basis, all three of which already
  live at `AGENTS.md:67-68` and `docs/invariants.md:20`, against
  `AGENTS.md:150-151` "Skills and agents REFERENCE these rules; they do not
  restate them". (b) More serious: the skill now instructs a behavior its own
  single source of truth does not contain. `AGENTS.md:52` still says "Execution
  (the builder) is pinned to the `sonnet` TIER" and `AGENTS.md:258` still says
  "the builder's tier is pinned (lint C11)", while `:57-60` and `:193-197` hand the
  user a per-run build-model choice and `agents/builder.md:110` recasts the pin as
  "a DEFAULT, not a ceiling". `AGENTS.md:152` is explicit: "A rule that is not
  written here (or in the baseline above) does not exist." Not 0: the guardrail is
  named with its enforcement mechanism and no gate is loosened.

## Total: 6/10   ## Verdict: FAIL (threshold 8/10, no zero)

## Ceiling
Max reachable: 10/10. Nothing is structurally capped. Explicit command, so
trigger clarity is judged on plain what-you-get (achieved); the change is
guardrail-adjacent, so safety integration can reach 2. One narrow exception
inside worked example: the model-plan example line must use tier/slot form
(`<session model, resolved now>`) rather than a real model name, because a named
version would trip lint C11, so "real values" there means real SHAPE. That does
not cap the criterion, the rest of the example carries real values and the
missing build-model branch is fixable in two lines.

## Findings (in fix order)

1. **`skills/build/SKILL.md:47-48` and `:54`, instruction with no mechanism
   (blocking).** Replace "the models AVAILABLE on this host right now, as the
   harness reports them" with the two paths that actually exist, ASK first:
   > - which models this host offers. You cannot enumerate the user's
   >   subscription, so ASK: "which models does `/model` list for you?" If they
   >   would rather not check, offer the builder's declared tier and say the list
   >   was not resolved. The official lineup (models-overview plus a second
   >   source, per AGENTS.md) tells you what EXISTS, never what this account has;
   >   never fill the list from memory.
   and change the question slot `:54` from "<list what this host offers now>" to
   "<the models the user just named, or 'declared tier' if they did not check>".

2. **`skills/build/SKILL.md:42-43`, firm up the ASK trigger (blocking).**
   "If it cannot be resolved with certainty" makes the agent judge its own
   certainty, the weakest possible condition. Invert it to a mechanical default:
   > Only two sources count: the user telling you in THIS turn, or the host
   >   reporting it in THIS turn. Session-start environment text, earlier turns
   >   and memory are not sources, so ASK by default: "run `/model` and `/effort`
   >   and tell me what they report."
   This also closes the effort gap (the current utterance names only `/model`
   while the bullet covers effort, which `AGENTS.md:62-64` says is not readable).

3. **`skills/build/SKILL.md:226-245`, refresh the worked example (blocking).**
   Replace the `:231-234` block with the two-role question and show the choice
   being exercised, e.g.
   ```
   "Model plan.
    Judgment (plans, reviews): <session model, resolved now> at effort high.
    Build: which model? You said /model lists <tier A>, <tier B>.
    Default is the builder's declared tier, right here (plan is precise, work is
    mechanical). Continue, or name a build model?"
   > continue
   architect -> docs/plans/2026-07-14-usr-012-timer.md (approved: no,
     model_plan: judgment <resolved> effort high | builder <declared tier> effort high)
   ```
   Optionally add a one-line variant where the user names a higher build model and
   it appears in `model_plan:`, since that is the branch this commit exists for.

4. **`AGENTS.md:52` and `:258`, the single source of truth has not caught up
   (blocking, one line in AGENTS.md).** Add to the model-policy bullet: "the
   builder's frontmatter tier is a DEFAULT, not a ceiling; the human may choose a
   higher build model per run at `/build`'s model-plan step, passed AT DISPATCH and
   recorded in `model_plan:`, never written into a file (lint C11)." Then the
   skill's closing paragraph shrinks to a pointer (finding 5) and `builder.md:110`
   stops being the only place the new rule is written.

5. **`skills/build/SKILL.md:63-67`, reference instead of restating.** Keep the
   operative sentence, drop the reasoning: "The user's build choice is passed AT
   DISPATCH, per run, and is never written into `agents/builder.md` or any other
   file (AGENTS.md model policy, lint C11: a version in a file goes stale)." The
   staleness rationale and the incident already live in `AGENTS.md:67-68` and
   `docs/invariants.md:20`; two copies drift, and the drift is what the
   reference rule prevents. Verdict on the exception question: an exception is NOT
   needed here, because the reason a future reader needs is already written in a
   durable, single place, and the pointer carries them there in six words.

6. **`skills/build/SKILL.md:193-197`, name the dispatch mechanism or its
   fallback (non-blocking but real).** "passed at dispatch" states no mechanism
   either. Add: "if this host's dispatch cannot take a model override, say so and
   offer the choice again (accept the declared tier, or build with-me on the chosen
   model); `model_plan:` records the model that ACTUALLY ran, never the one that was
   requested" (`AGENTS.md:265-266`).

7. **`skills/build/SKILL.md:57`, nit.** "the builder's declared tier (`sonnet`)"
   duplicates a value that lives in `agents/builder.md` frontmatter, which lint
   C11 also permits to be `inherit`. Say "the builder's declared tier in
   `agents/builder.md`" and let the file own the value.

8. **`skills/build/SKILL.md:39` vs `:75-76`, nit.** The live-resolution rule is
   stated twice in one block. Let the opening bullet own "never from a cached
   table" and shorten the closing sentence to "below the STRONGEST model available
   (resolved live, per above) OR below `high` effort".

## House style
No em or en dashes in the new text; English only; no version-pinned model name
anywhere in the block (lint C11 clean: `sonnet` is a tier word); no
time-sensitive external facts asserted. "a list someone typed months ago" is
figurative, not a dated claim. Confirmed clean.

## Consistency verdict
- Internal: FAILS on one axis. The worked example (`:231-234`) still speaks the
  pre-change single-role phrasing and does not offer the build model, so the
  skill's own example contradicts its process step.
- `agents/builder.md`: consistent. `:110-116` ("a DEFAULT, not a ceiling", "passed
  AT DISPATCH, per run", "You never change your own model") matches the skill's
  `:57-60` and `:193-197`, including the "output itself is judgment" criterion.
  Note that criterion is now written in both files; after finding 4 it should live
  in AGENTS.md once and be referenced.
- `AGENTS.md:257-266`: partially consistent. The never-fabricate, tiers-not-versions
  and model-plan-as-a-question rules are all honored, and the framing that a
  per-run choice never touches a file is right, so C11 needed no change. But the
  per-run choice itself is absent from AGENTS.md, which still says "pinned" twice.
  See finding 4.
- `docs/plan-format.md:24-26`: consistent. `builder: <tier -> model> effort
  <level>` already accommodates a chosen model.

## Map duty
No command surface added or altered (`docs/system-map.md:67` already carries
`/build` with both modes), so no map delta is required. Not a finding.

## Round-by-round
- Round 1 (2026-08-06): 6/10 FAIL. Four criteria dropped from 2 to 1 against
  version 5. All four drops are attributable to text this commit introduced, not
  to a stricter re-reading of unchanged text: the host-lineup instruction replaced
  a fetchable mechanism with an unobtainable one (precision), the block grew to 41
  lines with the live-resolution rule stated twice (structure), the example was
  not updated alongside the step it illustrates (worked example), and the C11
  rationale was inlined while AGENTS.md was left describing the builder as pinned
  (safety integration).

## Vs previous version
Version 5 (2026-07-30) scored 10/10: the model-plan step then resolved the
session model and the strongest AVAILABLE model live, and flagged a switch-up for
architecture-critical work. Version 6 turns the build model into a user choice
too. The intent is sound and the guardrail reasoning behind it is correct (a
per-run dispatch choice never writes a version into a file, so C11 stands
unchanged and did not need weakening). The FORM regressed: the new obligation
"resolve the models the host offers right now" has no mechanism in this system,
the ASK fallback rests on self-assessed certainty, the worked example was left
speaking the old single-role phrasing, the C11 rationale is restated where a
pointer belongs, and AGENTS.md, the declared single source of truth, still says
the builder's tier is pinned. Findings 1 to 4 are the ones that move the score
back to 10; 5 to 8 tighten.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed
  to mirror the step. Gap closed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed; no gate touched.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Model-plan step resolves
  the STRONGEST model available on the host live (never cached) as well as the
  session model, and recommends a switch-up for architecture-critical work.
  Non-blocking nits recorded: rule stated twice; example showed only the happy path.
- Round 6 (2026-08-06, Opus 5, strongest): 6/10 FAIL, commit 5b46abd, branch
  chore/build-asks-builder-model. The build model became the user's choice too.
  Both Round 5 nits have now hardened into scored defects (the twice-stated rule
  inside a 41-line block, and an example that omits the new branch), and two new
  ones appeared: an instruction with no mechanism ("the models AVAILABLE on this
  host right now, as the harness reports them") and a per-run choice that
  AGENTS.md does not yet carry while it still calls the builder's tier "pinned".
  What changed in this record versus version 5: structure 2 -> 1, worked example
  2 -> 1, precision 2 -> 1, safety integration 2 -> 1, verdict PASS -> FAIL.

Note: this is a form review. Findings 1 and 2 are form problems with behavioral
consequences (whether the agent asks rather than invents the model list, and
whether it asks rather than trusting a session-start reading). Once the file is
fixed, an `/improve` subagent test is the right instrument to confirm the agent
actually asks instead of listing models from memory; a form review cannot see
that.
