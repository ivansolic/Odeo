---
artifact: architect
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 2
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 1, instruction_quality: 1 }
total: 8/10
verdict: PASS
previous_total: 10/10 (set-level, docs/evals/agent-set-model-policy.md, different scope)
---

# Agent: architect (post ADR-001, contracts not code)

Scored `agents/architect.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 1 and 5) and
`docs/decisions/ADR-001-plans-carry-contracts-not-code.md` changes 7, 8 and 14.

Method note: no Bash tool in this reviewer's grant, so `git show aee5ab1` could not be
run. Scored the file AS IT STANDS on the branch, against the ADR change list, which is
the binding contract for the edit.

## Scores

- **trigger/description clarity: 2** , `:3` carries all three: what ("Plans ONE story
  (or a small batch) ... produces the plan document that the builder will execute as a
  contract"), when ("Dispatched by /build's for-me mode (Mode B) before any building,
  or invoked standalone"), and the not-for boundary ("Story-level planning only;
  product-level architecture is inherited, never redecided here").

- **tool least-privilege: 2** , `tools: Read, Grep, Glob` (`:4`) is the read-only
  judgment set, matching AGENTS.md:264, and the body closes the loop rather than
  assuming it: "You cannot write files; return the full plan content and the intended
  path, the orchestrating session saves it" (`:64-65`). No Write, Edit or Bash.

- **role boundary: 2** , one job, and ADR-001's authoring hole is now closed at the
  identity line: "You do not author implementations in the plan either: the plan
  carries CONTRACTS (ADR-001)" (`:10-11`). Escalation is explicit and correct:
  "If the story seems to require such a change, STOP and escalate: that is a human
  decision recorded as an ADR, not a plan detail" (`:30-32`).

- **policy conformance: 1** , `effort: high` declared (allowed set), no `model:` line
  so judgment inherits the session per AGENTS.md:41-42, no version-pinned id (C11
  clean), isolation correctly absent for a role that mutates nothing. The lost point is
  a factual contradiction with the single source of truth: `:76-77` tells the architect
  "you are the detector during plan review", while AGENTS.md:170 assigns that duty
  elsewhere ("Detector: `architecture-reviewer` during plan review"), which is also what
  ADR-001:308 specifies. The architect cannot hold this duty on the merits either: the
  rule detects a declaring plan REVISED AFTER APPROVAL, and the architect neither sees
  approval state nor writes files.

- **instruction quality: 1** , the contracts instruction itself is precise and
  greppable ("exact signatures, the behavior (WHICH validation, on WHICH field, with
  WHAT rule), the INVARIANTS that must remain true, the test cases, and the verify
  commands ... an unlabelled block is a rubric failure", `:43-51`). Three gaps cost the
  point: (a) the format enumeration at `:33-36` still lists five of the format's ten
  sections and omits four that ADR-001 change 3 added for this exact reason (Design
  decisions, Task order and parallelism, Success signal, Do-not-touch boundaries), so a
  partial restatement of a referenced spec is now stale against it; (b) a NAMED
  MECHANISM is binding on the builder but carries no marker, while a snippet carries a
  mandatory `illustrative-not-contract:` label, so the one binding category that is
  neither signature nor invariant nor test case is the one the builder must infer from
  prose (`:45-46`); (c) a rewrap artifact splits a sentence mid-clause at `:77-78`
  ("review). The overlap / check (`worktree-parallel-check`) findings").

## Total: 8/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable
No criterion structurally caps this agent. Both lost points are text fixes inside this
file: correct the detector attribution at `:76-77` and close the three instruction gaps.

## Findings

- **Important, `agents/architect.md:76-77`** , "you are the detector during plan
  review" contradicts AGENTS.md:170 and ADR-001:308. Fix: "the `architecture-reviewer`
  is the detector during plan review; your duty is to declare which plan owns each
  shared contract and to cite it as `<plan-file> C<n>`, so the reference is checkable."
- **Minor, `agents/architect.md:70-77`** , the batch rule RESTATES both clauses of the
  human-floor bullet and then cites it. AGENTS.md:150-151 says agents reference these
  rules and do not restate them, while AGENTS.md:5-7 sanctions embedding safety-critical
  rules for the plugin-absent case, so the embedding is defensible but the drift surface
  is real and already produced the detector error above. Fix: keep the embedded text and
  add the precedence marker, "(echo of AGENTS.md Guardrails 1, which governs; if they
  differ, AGENTS.md wins)".
- **Minor, `agents/architect.md:3`** , "never writes code" is the unqualified wording
  ADR-001:88-97 diagnosed and repaired at `:10` only. It is now also over-broad against
  the snippet exception the same file grants at `:48-51`. Fix: "never writes code into
  the repo; in the plan it authors contracts, not implementations."
- **Minor, `agents/architect.md:33-36`** , stale section enumeration (see criterion 5).
  Fix: add the four missing sections, or drop the enumeration and rely on "in the exact
  format of `docs/plan-format.md`".
- **Minor, `agents/architect.md:45-46`** , no bindingness marker for a named mechanism.
  Fix: require the mechanism to be stated in contract voice, in the task or in the
  Contracts entry's `Invariants:`, so the builder can distinguish binding mechanism from
  narrative.
- **Minor, `agents/architect.md:77-78`** , rewrap the split sentence.
- **Out of scope, blocking for this agent in practice, `docs/plan-format.md:64-68`** ,
  the task template carries the new references-only line ("Consumes / Produces:
  <REFERENCES into the Contracts section, never new definitions>") AND the old per-task
  definition lines ("Consumes: <interfaces/types this task needs, from which task or
  existing code>", "Produces: ..."). The architect is told to follow this format
  exactly, so it will reproduce the per-task definition sites ADR-001 removed. Fix:
  delete `:67-68`.

## Integrity
House voice throughout, consistent with the rest of `agents/`. Nothing reads as copied
from another project.

## Vs previous version
No prior per-file record. The only prior coverage is `docs/evals/agent-set-model-policy.md`
(2026-07-24), which scored eight agent files as ONE SET at 10/10; per-file defects were
not visible at that granularity, so 10/10 set-level to 8/10 per-file is a change of
scope, not a measured regression. Round 1 for this file.

## History
- 2026-08-04 v2 (branch `chore/adr-001-contracts-not-code`, HEAD aee5ab1): first
  per-file review, after ADR-001 changes 7, 8 and 14. Round 1 = 8/10 PASS, one Important
  (detector attribution) open.
