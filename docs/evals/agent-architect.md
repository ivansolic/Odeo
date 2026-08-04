---
artifact: architect
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
previous_total: 8/10
---

# Agent: architect (round 2, at HEAD f8f8da6)

Scored `agents/architect.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 1 and 5) and `docs/plan-format.md`.

Version note: labelled `artifact_version: 3`, not 2. The file changed again between
the round-1 review (HEAD aee5ab1, recorded as v2) and this one (HEAD f8f8da6), so this
is the third reviewed state. Renumbering on request; no gate reads this field.

Method note: no Bash in this reviewer's grant, so `git show` could not be run. Scored
the file as it stands at HEAD, against the round-1 finding list supplied with the task.

## Scores

- **trigger/description clarity: 2** , `:3` still carries all three: what ("Plans ONE
  story (or a small batch) ... produces the plan document that the builder will execute
  as a contract"), when ("Dispatched by /build's for-me mode (Mode B) before any
  building, or invoked standalone"), and the not-for boundary ("Story-level planning
  only; product-level architecture is inherited, never redecided here"). Unchanged from
  round 1.

- **tool least-privilege: 2** , `tools: Read, Grep, Glob` (`:4`) is the read-only
  judgment set required by AGENTS.md:264, and the body closes the loop instead of
  assuming it: "You cannot write files; return the full plan content and the intended
  path, the orchestrating session saves it" (`:67-68`). No Write, Edit or Bash.

- **role boundary: 2** , one job, and the authoring hole is closed at the identity line
  ("You do not author implementations in the plan either: the plan carries CONTRACTS",
  `:10-11`) with the escalation intact ("STOP and escalate: that is a human decision
  recorded as an ADR, not a plan detail", `:31-32`).

- **policy conformance: 1 -> 2** , the round-1 deduction is gone. The batch section now
  reads "the `architecture-reviewer` is the detector during plan review" (`:80-81`),
  matching AGENTS.md:170, and the echo carries its precedence marker: "the human-floor
  rule in AGENTS.md Guardrails 1 governs; if this echo ever differs, AGENTS.md wins"
  (`:77-78`). The architect's own duty is now stated at the level it can actually
  discharge: "to declare which plan OWNS each shared contract and to cite it as
  `<plan-file> C<n>` so the reference is checkable" (`:78-80`). Frontmatter unchanged and
  conformant: `effort: high` from the allowed set, no `model:` line so judgment inherits
  the session (AGENTS.md:41-42), no version-pinned id (C11 clean), no `isolation:` which
  is correct for a role that mutates nothing.

- **instruction quality: 1 -> 2** , two of the three round-1 gaps are closed. The format
  enumeration at `:33-39` now lists all nine sections of `docs/plan-format.md` (header,
  design decisions, contracts, file map, tasks, task order and parallelism, success
  signal, do-not-touch boundaries, risks and open questions) plus the delegation for the
  `none` question ("Follow that file for which sections may be `none` on a small story"),
  and the mid-clause rewrap artifact at the old `:77-78` is gone. The contracts
  instruction remains the precise part ("exact signatures, the behavior (WHICH
  validation, on WHICH field, with WHAT rule), the INVARIANTS that must remain true, the
  test cases, and the verify commands ... an unlabelled block is a rubric failure",
  `:46-54`). Level 2's descriptor (process, output shape, honesty integration, rules for
  yourself) is met in full; two Minor residuals below are named, not waived.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
No criterion structurally caps this agent. 10/10 means every criterion sits at its
described top level, NOT that the file is flawless: two Minor residuals are open below.

## Round-by-round
Round 1 (aee5ab1): 8/10 PASS, 1 Important + 5 Minor + 1 out-of-scope blocker.
Round 2 (f8f8da6): 10/10 PASS. Moved: policy conformance 1 -> 2 (detector attribution
corrected), instruction quality 1 -> 2 (enumeration completed, rewrap fixed).

## Findings closed
- **CLOSED (was Important), detector attribution** , `:80-81` now names
  `architecture-reviewer`, matching AGENTS.md:170.
- **CLOSED (was Minor), missing precedence marker on the embedded human-floor rule** ,
  `:77-78` adds "if this echo ever differs, AGENTS.md wins", which is the cheapest
  possible defence against exactly the drift that produced the detector error.
- **CLOSED (was Minor), stale section enumeration** , `:33-39` now enumerates all nine.
- **CLOSED (was Minor), rewrap artifact** , the sentence at `:81-82` reads continuously.
- **CLOSED (was out-of-scope, blocking in practice), `docs/plan-format.md`** , the
  per-task `Consumes:`/`Produces:` DEFINITION pair is deleted; only the reference field
  remains (`docs/plan-format.md:90-91`), so following the format no longer reproduces a
  second definition site.
- **NOT A DEFECT (was Minor), `:3` "never writes code"** , closed as accepted, and not
  merely as a tolerable simplification. In a sentence about producing plan documents,
  "never writes code" reads as "produces no implementation code", which is the position
  the whole file takes; the snippet exception grants only a block labelled
  `illustrative-not-contract:`, i.e. explicitly NOT code the builder is bound to ship.
  The nuance also cannot mislead in practice, since the agent loads `:10-11` and `:50-54`
  together with `:3`. No deduction, no fix required. If exactness is ever wanted for free:
  "never writes code into the repo".

## Findings open
- **Minor, `:47-48`, no bindingness marker for a named mechanism (round-1 residual)** ,
  "Where a mechanism is a design decision, state the mechanism, not the lines that
  implement it" still gives the builder no greppable signal, while a snippet carries a
  mandatory label. Materially mitigated from the other side this round:
  `docs/plan-format.md:6` now lists "named mechanisms" in the canonical binding list, and
  `agents/builder.md:59-60` fails safe ("treat it as BINDING and ask"). Optional fix:
  require the mechanism to be stated in contract voice, in the task or in the Contracts
  entry's `Invariants:`.
- **Minor, `:33-39`, the enumeration is now a second listing of another document's
  section names** , the round-1 fix chose completeness over delegation, which trades
  today's staleness for tomorrow's drift risk (rename or add a section in
  `docs/plan-format.md` and this list is stale again). Fix, matching the pattern this
  same commit introduced at `:77-78`: add "(that file is canonical; if this list differs,
  it wins)".
- **Note, not scored, `:64-65`** , step 5 names only `approved: no` and never says who
  fills `model_plan:` and `arch_review:`, both builder-blocking preconditions
  (`agents/builder.md:17-21`). Verified as covered elsewhere and therefore NOT a defect
  here: `skills/build/SKILL.md:49-51` and `:162-163` assign both to the orchestrating
  session, which is the only actor that can resolve them.

## Integrity
House voice throughout, consistent with the rest of `agents/`. Nothing reads as copied
from another project.

## Vs previous version
Improved, 8/10 -> 10/10, entirely by the fixes listed above. Comparison basis is the
round-1 per-file record (this file, v2). The 2026-07-24 set-level record
(`docs/evals/agent-set-model-policy.md`, 10/10 over eight files) is a different scope and
is not the regression baseline.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 changes 7, 8, 14.
  Round 1 = 8/10 PASS, one Important open (detector attribution).
- 2026-08-04 v3 (f8f8da6): re-review after the fix pass. Round 2 = 10/10 PASS. Detector
  attribution, precedence marker, section enumeration and the rewrap all closed; the
  description wording closed as not-a-defect; mechanism marker and enumeration drift
  surface remain as Minors.
