---
artifact: builder
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 3
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

# Agent: builder (round 2, at HEAD f8f8da6)

Scored `agents/builder.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 3 and 5) and `docs/plan-format.md:5-9`.

Version note: labelled `artifact_version: 3`, not 2. The file changed again between the
round-1 review (aee5ab1, recorded as v2) and this one (f8f8da6), so this is the third
reviewed state.

Method note: no Bash in this reviewer's grant; scored the file as it stands at HEAD.

## Scores

- **trigger/description clarity: 2** , `:3` states what ("Builds ONE user story by
  executing an APPROVED implementation plan as a contract"), when ("Dispatched by /build
  after the human approves the architect's plan (one instance per story, each in its own
  git worktree)") and the refusal condition that is this role's sharpest boundary
  ("Requires the plan; without an approved plan it does not build"). Unchanged.

- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`) is
  the full build set and every member is exercised by the pipeline (write code, edit
  existing files, run tests, commit). Paired with the containment that makes it safe:
  `isolation: worktree` (`:7`) plus "One story, one worktree, never merge" (`:107`).

- **role boundary: 2** , the latitude clause still does not loosen escalation. Step 5
  keeps "You never improvise a different design and never touch DO-NOT-TOUCH paths"
  (`:50-51`) and 5b routes the hard case back into that same vocabulary: "something that
  CONTRADICTS a stated contract, or changes a signature, an invariant, or the mechanism
  the plan named, is a different design, so STOP and ask" (`:57-59`). Report shape
  follows: "Implementation choices the plan left unspecified are NOT deviations; list them
  under decisions" (`:98-99`).

- **policy conformance: 2** , `model: sonnet` (`:5`) is the pinned execution TIER per
  AGENTS.md:52-54 and from the allowed sonnet/inherit set, `effort: high` declared,
  `isolation: worktree` set on the one role that mutates files in parallel, no
  version-pinned id (C11 clean). `:105-107` states the tier policy correctly and reserves
  the flip to `inherit` for the human.

- **instruction quality: 1 -> 2** , all three round-1 qualifications landed, in the exact
  places the friction was:
  (a) `:111-112` now reads "Ambiguity about WHAT the contract requires = ask, not guess; a
  choice the contract leaves open = decide it well and note it (5b). Plan conflict = stop,
  not improvise", so the Rules summary no longer reads as forbidding what 5b grants;
  (b) `:59-60` adds the recognition fallback, "If you cannot tell whether a sentence
  states a binding mechanism or merely describes intent, treat it as BINDING and ask",
  which fails safe (toward asking) rather than toward silent drift;
  (c) `:60-62` adds a materiality filter with two testable predicates and a negative
  example, "Note only choices a reviewer would want to see (a behavior-visible or
  convention-level choice), not every local variable". That is actionable, not just
  softer: "behavior-visible" and "convention-level" can each be answered yes/no about a
  concrete choice, where the round-1 suggestion ("a real tradeoff") could not.
  Level 2's descriptor is met in full; three Minor residuals below are named, not waived.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
No structural cap. 10/10 means every criterion sits at its described top level, NOT that
the file is flawless: three Minor residuals are open below.

## Round-by-round
Round 1 (aee5ab1): 9/10 PASS, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10 PASS. Moved: instruction quality 1 -> 2. No criterion dropped.

## The latitude line against the same three cases (re-run)

1. Plan says "validate the code against the allowlist and exit 1 with the allowed set
   listed", silent on `for` versus `case`. **Resolved unconditionally**, as before: 5b
   names "which loop" as unspecified, `:98-99` confirms it is not a deviation, and
   `:60-62` now also answers whether to report it (a local control-flow pick is neither
   behavior-visible nor convention-level, so no).
2. Plan states the invariant "exactly one output_language line" and a cheaper approach
   would leave two. **Resolved unconditionally**, as before: an invariant binds (`:53-54`)
   and changing it is a different design, so STOP and ask. Still double-covered by
   `agents/code-reviewer.md:37-40` (unheld stated invariant = a finding even when every
   test passes), and now triple-covered by `:41-43` which authorises the reviewer to
   actually go look.
3. Plan names the mechanism "keep the first match, drop later ones" and the builder
   prefers sed's every-line replace. **Now resolved unconditionally** (round 1: only
   conditionally). Both branches terminate in the same place: if the builder recognises
   the sentence as a named mechanism, `:57-59` requires STOP and ask; if it cannot tell,
   `:59-60` requires treating it as BINDING and asking. The path that leaked in round 1
   (classify it as prose about intent, then treat the writer choice as unspecified) no
   longer exists unless the builder is affirmatively wrong rather than merely unsure,
   which is the irreducible residual of having no greppable mechanism marker
   (`agents/architect.md:47-48`, open there). Cost of the fix: it biases toward asking,
   which is the correct direction for this role.

## Findings closed
- **CLOSED (was Important), `:111-112`** , the decide-versus-ask slogan is now scoped.
- **CLOSED (was Important), binding-list drift** , the canonical site is fixed and
  complete: `docs/plan-format.md:5-9` declares itself canonical ("this list is canonical;
  other files cite it rather than restating it") and now includes INVARIANTS and named
  mechanisms, the two the round-1 record called the worst omissions. See the residual
  below for the parts of the family that still re-list rather than cite.
- **CLOSED (was Minor), `:59-60`** , recognition fallback added.
- **CLOSED (was Minor), `:60-62`** , materiality filter added.

## Findings open
- **Minor, `:53-54` and `:96-97`, this file re-lists the binding set instead of citing
  the now-canonical one, and both listings are short** , `:53-54` gives "signatures,
  paths, behavior rules, invariants, test cases, verify commands and boundaries" (no
  *named mechanisms*, though `:57-59` binds them three lines later) and `:96-97` gives
  "a signature, behavior rule, invariant, named test case, verify command or boundary"
  (no *paths*, no *named mechanisms*). Low impact by construction, a mechanism deviation
  cannot reach the report because 5b forces an ask first, and paths are now checked by
  `agents/code-reviewer.md:34-37`. Fix, matching what `code-reviewer` did this round:
  "The plan binds what `docs/plan-format.md` declares canonical (signatures, paths,
  behavior rules, invariants, named mechanisms, test cases, verify commands and
  boundaries)", and cite the same list at `:96-97`.
- **Minor, `:10` and `:36`, round-1 residual** , "executing its APPROVED plan exactly"
  and "never guess mid-build" still precede any pointer to 5b, so a reader meets the
  unqualified form 43 lines before the qualification. Materially mitigated now that
  `:111-112` carries the distinction in the Rules summary. Fix: at `:10`, "what 'exactly'
  binds is in step 5b".
- **Minor, `:60-61`, "behavior-visible" can be misread as a trigger to ask** , since the
  plan binds "behavior rules", a builder could read "behavior-visible" as "this is
  behavior, therefore contract, therefore stop". The intended set is real: choices that
  are visible in behavior but covered by NO stated behavior rule (an error message's
  wording, the order of two independent outputs). Fix: "behavior-visible but not covered
  by a stated behavior rule".

## Integrity
House voice, consistent with `agents/architect.md` and the skills. No copied text.

## Vs previous version
Improved, 9/10 -> 10/10, and the one case that resolved only conditionally in round 1
(case 3) now resolves unconditionally. Baseline is the round-1 per-file record (v2), not
the 2026-07-24 set-level record.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9.
  Round 1 = 9/10 PASS, two Important open (unqualified ask-slogan, binding-list drift).
- 2026-08-04 v3 (f8f8da6): re-review after the fix pass. Round 2 = 10/10 PASS. Both
  Importants closed, all three 5b qualifications landed, case 3 now unconditional; three
  Minors remain (in-file binding-list drift, `:10`/`:36` pointer, "behavior-visible").
