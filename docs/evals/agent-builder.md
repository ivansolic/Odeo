---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: a2eec03
artifact_version: 6
date: 2026-08-06
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 1 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

# Agent: builder (round 5, at a2eec03)

Re-review after the round-4 fix pass. All three round-4 findings are CLOSED and verified.
One NEW finding, of a different and lower-hazard class: the plan-precondition list at `:17-21`
was not updated for the two-field `model_plan:` that landed in `docs/plan-format.md` in the
same change, so the canonical format now asserts a requirement (`builder_tier:` is "the
builder's contract") that this file never names and step 1 never checks.

Version note: `artifact_version: 6` (v2 = aee5ab1, v3 = f8f8da6, v4 = f4e295a, v5 = 5b46abd,
v6 = a2eec03).

Method note: no Bash in this reviewer's grant, so no `git show`. Scored the file as it stands
at the supplied `reviewed_commit`, against `AGENTS.md`, `docs/plan-format.md`,
`docs/invariants.md`, `skills/build/SKILL.md`, `bin/skills-lint.sh`.

## Scores

- **trigger/description clarity: 2** , `:3` unchanged: what, when dispatched, and the refusal
  condition ("Requires the plan; without an approved plan it does not build").
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), all
  exercised, contained by `isolation: worktree` (`:7`). The round-4 concern about `Write`/`Edit`
  aimed at the plan is closed by "Never edit the plan" (`:118`).
- **role boundary: 2** , stronger than v5. `:113-118` names three rules the builder actually
  owns and ends "Never edit the plan"; `:112-113` hands the WHEN decision away explicitly
  ("the human's call at `/build`'s model-plan step (see AGENTS.md), never yours").
- **policy conformance: 2** , frontmatter untouched: `model: sonnet` (`:5`) from the allowed
  sonnet/inherit set, `effort: high`, `isolation: worktree`. C11 clean (grepped: no
  version-pinned name, no em or en dash in the file). AGENTS.md drift from round 4 is closed,
  so the file and the source of truth now say the same thing.
- **instruction quality: 1** , the contract's ENTRY POINT (`:17-21`, the plan preconditions)
  describes a `model_plan:` shape the format no longer provides, and the field the canonical
  format says this agent's contract requires is named nowhere in this file. Detail in finding 1.
  Everything else in the file is level-2 quality.

## Total: 9/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reachable
No criterion structurally caps for this role. Finding 1 is a two-line edit at `:18-19`
(plus one optional clause at `:36`); fixing it restores 10/10.

## Round-by-round
Round 1 (aee5ab1): 9/10, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10, 3 Minor open.
Round 3 (f4e295a): 10/10, 2 Minors closed, 1 carried.
Round 4 (5b46abd): 9/10, instruction_quality 2 -> 1 (ownerless `model_plan:` duty).
Round 5 (a2eec03): 9/10 PASS. Round 4's Important + both Minors CLOSED; instruction_quality
stays at 1 for a NEW, unrelated defect at `:17-21`. The point is not lost twice for the same
reason, and this round's hazard is strictly lower: the round-4 defect risked fabrication and an
edit to the builder's own contract, this one risks at worst a needless refusal.

## Closures verified

- **CLOSED (was Important), the ownerless `model_plan:` duty.** `:113-118` now reads "Three
  rules that are yours: you were dispatched with a model and you never change it; running above
  your declared tier is legitimate and is NOT a deviation to report; and `/build` records what
  it dispatched you on in the plan's `model_plan:`, so you neither write nor verify that line.
  If you can see you are running on a model that contradicts the plan, say so in your result and
  keep building. Never edit the plan." All three problems are gone: the owner is named
  (`/build`), the duty is a prohibition the agent can obey, and no sentence requires the builder
  to resolve its own model. Better than the fix I proposed on one point I had not raised: "running
  above your declared tier is legitimate and is NOT a deviation to report" pre-empts a builder
  filing a contract deviation (`:100-104`) because it noticed it was running above `sonnet`,
  which my wording left open. The unexpected-model case now has an action and a non-action
  ("say so in your result and keep building"), and the honesty condition is right: it triggers
  on "if you can see", never on an obligation to find out. Consistent with
  `docs/plan-format.md:30-36`, which makes the same non-verifiability point explicitly
  ("Deliberately named 'as dispatched', not 'as ran': nobody here can verify which model the
  vendor actually served").
- **CLOSED (was Minor), copy-vs-cite drift.** The "output itself is judgment" decision rule is
  no longer restated here; `:112-113` cites the owner and the location instead. The rule now
  lives at `AGENTS.md:57-58` and `docs/plan-format.md:28-29`, and the builder points at it
  rather than repeating it, matching this file's binding-list precedent (`:52-55`, `:100-102`).
- **CLOSED (was Minor, cross-file), the "pinned" drift.** `AGENTS.md:52-59` now reads "Execution
  (the builder) DEFAULTS to the `sonnet` TIER... The default is rebuttable, not a pin... What is
  ENFORCED is only the file's default value (lint C11); the run model is the human's call", and
  `AGENTS.md:262-266` splits the claim ("[E] ... `model:` value must be `sonnet` or `inherit`
  (lint C11). That enforces the FILE DEFAULT only. [I] The model a builder actually runs on is
  the human's per-run choice... so do not read 'pinned' into it"). `docs/invariants.md:20` carries
  the same clarification. `skills/build/SKILL.md:197-201` now names `builder_as_dispatched:` and
  assigns it to the orchestrator. The [E]/[I] split is the right correction: what a lint can see
  is a file value, and claiming enforcement of a run-time choice would have been a false [E].

## Findings

**1. Important, `agents/builder.md:17-21` (with `:36`): the precondition list predates the
two-field `model_plan:`.** It still requires "a `model_plan:` block (who thinks, who executes,
and at what EFFORT, as resolved when the plan was written)". The format it must match is now:
- `builder_tier: <tier word> effort <level>` , "the APPROVED INTENT, a tier word, so it cannot
  go stale. Present at approval; **the builder's contract requires THIS line**"
  (`docs/plan-format.md:26-28`).
- `builder_as_dispatched: <model>` , "written by the ORCHESTRATOR after dispatch"
  (`docs/plan-format.md:30-31`), i.e. NOT present when the builder checks its preconditions.

Three concrete consequences:
- **A requirement with no enforcer.** `plan-format.md:27-28` asserts that the builder's contract
  requires `builder_tier:`. This file never names that field, and the operative checklist at
  `:36` ("plan exists, `approved: yes`, `arch_review:` not pending, covers this story") does not
  check the `model_plan:` block at all. So the canonical doc claims an invariant that nothing
  implements, the same false-assertion class that `AGENTS.md:262-266` just fixed by splitting
  [E] from [I].
- **A false-refusal path.** `:22` is a hard gate ("**No approved, review-carrying plan = do not
  build.**"). A builder reading `:18-19` literally looks for who executes "as resolved", finds a
  tier word and no resolved model (by design: `builder_as_dispatched:` is written after it was
  dispatched), and may call the block incomplete. The direction is safe (a refusal, not a wrong
  build) and `:36` gives a careful builder an out, which is why this is not Critical.
- **Wrong words for the new design.** "as resolved when the plan was written" is precisely what
  `builder_tier:` is NOT: `plan-format.md:26` chose a tier word "so it cannot go stale".
Fix, replacing `:18-19`: "a `model_plan:` block whose `builder_tier:` line is present (a tier
word plus effort, the approved intent, per `docs/plan-format.md`; `builder_as_dispatched:` is
written by the orchestrator AFTER dispatch, so its absence is never a missing precondition)".
Optionally add `builder_tier:` present to the step-1 checklist at `:36`, so the requirement
`plan-format.md` advertises has an actual check behind it. Say which one you intend: if the
builder is NOT meant to check it, weaken `plan-format.md:27-28` instead, but do not leave both
sides as they are.

**2. Minor, `:114-118`: two report rules that can both fire on the same observation.** "Running
above your declared tier is legitimate and is NOT a deviation to report" and "If you can see you
are running on a model that contradicts the plan, say so in your result" overlap in the common
case (dispatched above `sonnet`, plan says `builder_tier: sonnet`). Reconcilable on a careful
read (not a deviation, but a note, and either way "keep building"), so the outcome is benign in
both directions; still, this is the one sentence pair in the bullet a literal reader can resolve
two ways. Fix: make the destination explicit, "never in your contract-deviation list; a line
under decisions is enough."

**3. Nit, `:116`: "that line", singular.** The block now has two lines the builder must never
write; `plan-format.md:35` says "The builder never writes either line". Fix: "neither of those
lines". Fold into finding 1's edit.

## Open (carried from round 3)
- **Minor, `:10` and `:36`** , "executing its APPROVED plan exactly" and "never guess mid-build"
  still precede any pointer to 5b. Mitigated by `:119-120`. Fix at `:10`: "what 'exactly' binds
  is in step 5b".
- **Nit, `:55-57` and `:102-103`** , insertions still leave short half-lines mid-sentence;
  rewrap. The rewritten model bullet itself wraps cleanly.

## Did the rewrite lose anything (asked explicitly)
No actionable loss. Two clauses left with the old wording: the "choose higher when the output is
judgment" test (now cited, round-4 finding 2, its home is `AGENTS.md:57-58`) and "a stronger
model for one story never edits this file" (the C11 rationale, now at `AGENTS.md:52-59` and
`docs/invariants.md:20`). Neither was something the builder could act on; the operative
prohibition it needs, "you were dispatched with a model and you never change it", survived and
is now stated as a rule rather than as a rationale.

## Out of scope, for the coordinator
`skills/build/SKILL.md:199-201` still frames the recorded value as the contract stating "who
actually built" in the surrounding sentence, while `plan-format.md:32-34` deliberately refuses
that claim ("not 'as ran' ... discloses what was requested instead of claiming what executed").
That is a skill file, so `skill-reviewer` owns it; flagging only because it is the same
never-fabricate distinction this round's fix got right.

## Integrity
House voice, consistent with `agents/architect.md` and the skills. No imported text; the only
overlap with sibling files is by citation.

## Vs previous version
9/10 -> 9/10, but not a stall: the round-4 Important and both Minors closed, role boundary and
policy conformance are materially stronger (explicit "Never edit the plan", AGENTS.md aligned),
and the remaining point is held by a different defect that the same commit's `plan-format.md`
split created at `:17-21`.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; the 5b
  qualifications landed; 3 Minors open.
- 2026-08-04 v4 (f4e295a): scoped re-review of the materiality rewording and the binding-list
  citation, both closed. Round 3 = 10/10 PASS, held.
- 2026-08-06 v5 (5b46abd): scoped re-review of the rewritten model bullet. Round 4 = 9/10 PASS;
  instruction_quality 2 -> 1 for an ownerless, unverifiable `model_plan:` duty at `:116`; the
  AGENTS.md "pinned" drift logged as a cross-file Minor.
- 2026-08-06 v6 (a2eec03): re-review after the fix pass. All three round-4 findings CLOSED
  (ownerless duty replaced by three owned rules + the unexpected-model action; the decision rule
  now cited not copied; AGENTS.md:52-59 / :262-266 / invariants C11 now say DEFAULT and split
  [E] from [I]). Round 5 = 9/10 PASS. instruction_quality stays 1 on a NEW finding: `:17-21`
  still describes the one-field `model_plan:`, so `builder_tier:` (which `plan-format.md:27-28`
  calls the builder's contract) is named nowhere in this file and checked nowhere in step 1.
