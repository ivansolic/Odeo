---
artifact: builder
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 2
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 1 }
total: 9/10
verdict: PASS
previous_total: 10/10 (set-level, docs/evals/agent-set-model-policy.md, different scope)
---

# Agent: builder (post ADR-001, implementation latitude)

Scored `agents/builder.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 3 and 5) and ADR-001 change 9.

Method note: no Bash tool in this reviewer's grant, so `git show aee5ab1` could not be
run. Scored the file as it stands against the ADR change list.

## Scores

- **trigger/description clarity: 2** , `:3` states what ("Builds ONE user story by
  executing an APPROVED implementation plan as a contract"), when ("Dispatched by
  /build after the human approves the architect's plan (one instance per story, each in
  its own git worktree)"), and its refusal condition, which is the sharpest boundary
  this role has ("Requires the plan; without an approved plan it does not build").

- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`) is
  the full build set and every member is used by the pipeline (write code, edit existing
  files, run tests and commits). It is paired with the containment that makes it safe:
  `isolation: worktree` (`:7`) plus "One story, one worktree, never merge" (`:106`).

- **role boundary: 2** , one job, and the new latitude clause does NOT loosen the
  escalation paths. Step 5 keeps "You never improvise a different design and never touch
  DO-NOT-TOUCH paths" (`:50-51`), and 5b deliberately reuses that same vocabulary to
  route the hard case back into it: "something that CONTRADICTS a stated contract, or
  changes a signature, an invariant, or the mechanism the plan named, is a different
  design, so STOP and ask" (`:56-59`). The two hinge on one concept, so they compose
  rather than collide. The report shape follows: deviation is scoped to CONTRACT
  deviation and "Implementation choices the plan left unspecified are NOT deviations;
  list them under decisions" (`:94-96`).

- **policy conformance: 2** , `model: sonnet` (`:5`) is the pinned execution tier per
  AGENTS.md:52-54 and is from the allowed sonnet/inherit set, `effort: high` declared,
  `isolation: worktree` set on the one role that mutates files in parallel, no
  version-pinned id (C11 clean). The self-rule at `:102-104` states the tier policy
  correctly and reserves the flip to `inherit` for the human.

- **instruction quality: 1** , 5b is otherwise a good contract (it enumerates what
  binds, gives concrete unspecified examples, and settles the snippet question: "A
  snippet labelled `illustrative-not-contract:` is a convenience, never a requirement:
  doing better than it is expected and is NOT a deviation", `:59-61`). Three
  qualifications are missing, all one-liners: (a) `:108` still reads "Ambiguity = ask,
  not guess" with no scope, while 5b says an UNSPECIFIED choice is the builder's to
  decide, and "unspecified" and "ambiguous" are near-synonyms in ordinary use; the same
  friction sits at `:36-37` ("never guess mid-build"). A builder taking the Rules
  section as the summary can read the file as forbidding what 5b grants; (b) no fallback
  for the recognition problem that 5b's own wording creates, "the mechanism the plan
  named" is binding, but nothing tells the builder how to tell a named mechanism from
  prose describing intent; (c) "you decide and note in your report" (`:56-57`) has no
  materiality filter, so it reads as either report noise or arbitrary self-filtering.

## Total: 9/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable
No structural cap. The lost point is three qualifying clauses in this file.

## The latitude line against three live cases

1. Plan says "validate the code against the allowlist and exit 1 with the allowed set
   listed", silent on `for` versus `case`. **Resolved correctly.** 5b names "which loop"
   literally as unspecified, so the builder decides and notes it, and `:96` confirms it
   is not a deviation.
2. Plan states the invariant "exactly one output_language line" and a cheaper approach
   would leave two. **Resolved correctly.** An invariant is bound (`:53`) and changing it
   is a different design, so STOP and ask. Double covered: `code-reviewer.md:36-37` makes
   an unheld stated invariant a finding "even when every test passes".
3. Plan names the mechanism "keep the first match, drop later ones" and the builder
   prefers sed's every-line replace. **Resolved only conditionally.** 5b binds "the
   mechanism the plan named", but recognition is left to inference: a builder can
   classify that sentence as prose about intent and treat the writer choice as an
   unspecified implementation detail. Snippets got a mandatory greppable label precisely
   because illustrative-versus-binding cannot be inferred; mechanisms, the one binding
   category that is neither signature nor invariant nor test case, got none.

## Findings

- **Important, `agents/builder.md:108` (with `:52-61`)** , the decide-versus-ask
  slogan is unqualified against 5b. Fix: "Ambiguity about WHAT the contract requires =
  ask, not guess; a choice the contract leaves open = decide it well and note it (5b).
  Plan conflict = stop, not improvise."
- **Important, four sites state the binding list and no two agree** ,
  `docs/plan-format.md:5-7` (signatures, paths, behavior rules, test cases, verify
  commands, boundaries, NO invariants), `skills/build/SKILL.md:98-100` (signatures,
  behavior, invariants, tests, verify, boundaries, NO paths), `agents/builder.md:53-54`
  (all seven, the superset and the correct one), `agents/code-reviewer.md:35` (four).
  This is ADR-001's own argument 1 applied to the contract-binding list itself. The
  worst omission is the canonical doc dropping INVARIANTS, the field the ADR insists on
  (`:200-205`) and the field the code reviewer's new duty leans on. Fix: make
  `docs/plan-format.md:5-8` canonical with the seven-item list and have the other three
  cite it instead of re-listing.
- **Minor, `agents/builder.md:56-58`** , add the recognition fallback: "if you cannot
  tell whether a mechanism statement is binding, treat it as binding and ask."
- **Minor, `agents/builder.md:56-57`** , add a materiality filter: "note the choices a
  reviewer would want to know about (a real tradeoff), not every syntactic pick."
- **Minor, `agents/builder.md:10` and `:36`** , "executing its APPROVED plan exactly"
  and "never guess mid-build" both predate the latitude clause and are only reconciled
  42 lines later. Fix: add the pointer at `:10`, "what 'exactly' binds is in step 5b".

## Integrity
House voice, consistent with `agents/architect.md` and the skills. No copied text.

## Vs previous version
No prior per-file record; `docs/evals/agent-set-model-policy.md` (2026-07-24) covered
this file inside an eight-agent SET at 10/10, where per-file wording gaps were not
scoreable. Scope change, not a measured regression. Round 1 for this file.

## History
- 2026-08-04 v2 (branch `chore/adr-001-contracts-not-code`, HEAD aee5ab1): first
  per-file review, after ADR-001 change 9 (steps 5b, the report's contract-adherence
  bullet, and `:106`). Round 1 = 9/10 PASS.
