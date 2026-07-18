# Plan format (the architect's contract)

The implementation plan is the CONTRACT between planning and building: the
`architect` produces it, the human approves it, the `builder` executes it exactly.
The quality bar: **a context-free builder (or an unfamiliar developer) can execute
it alone, without asking what was meant.**

## Where plans live
`docs/plans/<YYYY-MM-DD>-<feature-or-story-slug>.md`, one plan per story (or one
per small batch when stories are tightly related). Committed to git; the approved
version is the contract. The `/build` pipeline will not dispatch a builder
without an approved plan file.

## Structure

```markdown
# Plan: <story id + name>
approved: no            # flipped to yes by the human at the gate
model_plan:             # resolved LIVE when the plan is written; the user saw
  judgment: <model>     # and answered the model question; builder requires this
  builder: <tier -> model>
arch_review: pending    # set by the /build pipeline after the plan-review loop:
                        # "clean (vN, YYYY-MM-DD)" or "waived (human)" for
                        # standalone human-supplied plans. The builder requires it.

## Header
Goal: <the story's outcome, one sentence>
Architecture context: <the relevant product-level decisions this plan inherits,
  e.g. "modular monolith, Postgres, REST", never redecided here>
Constraints: <copied verbatim from the spec/story + do-not-touch boundaries
  that apply, from docs/codebase-map.md if it exists>

## File map (before any tasks)
<every file this plan creates or modifies, with its responsibility>
- src/billing/invoice.ts      MODIFY: add issueInvoice(); owns invoice lifecycle
- src/billing/invoice.test.ts CREATE: tests for issueInvoice
- src/routes/billing.ts       MODIFY: POST /invoices endpoint, validation at boundary

## Tasks
<the smallest independently testable units, in dependency order; each task:>
### Task 1: <name>
- Test first (per the project's dev-rigor style): <the exact test to write,
  named, with the expected failure>
- Implement: <exact function signatures, paths, and the change, no "add
  validation", write WHICH validation, on WHICH field, with WHAT rule>
- Verify: <exact command(s) and expected output>
- Consumes: <interfaces/types this task needs, from which task or existing code>
- Produces: <interfaces/types the next tasks may use>
- Commit: <the conventional commit message>

## Risks / open questions
<anything ambiguous the builder must ASK about rather than decide alone>
```

## Rules
- **No placeholders.** "TBD", "add error handling", "improve X" are plan failures.
  Exact paths, names, signatures, commands.
- **Interfaces explicit between tasks** (consumes/produces), so dependencies are
  visible and tasks stay independently verifiable.
- Task granularity: one test cycle each (test, fail, implement, pass, commit).
- DRY and YAGNI apply: no speculative structures the story doesn't need.
- The plan INHERITS product-level architecture; if the story seems to require
  changing it, the plan must say so and STOP for a human/ADR decision.
- On existing codebases: respect conventions and DO-NOT-TOUCH boundaries from
  `docs/codebase-map.md`; the plan lists which boundaries are nearby.

## Plan rubric (checked at the human gate; 0-2 per criterion)
```
1. Executability   0 needs interpretation / 1 mostly / 2 context-free builder could run it
2. File map        0 missing / 1 partial / 2 complete with responsibilities
3. Task quality    0 vague steps / 1 mixed / 2 smallest testable units, exact signatures,
                   verify commands, consumes/produces stated
4. Constraint fit  0 ignores architecture or boundaries / 1 partial / 2 inherits explicitly,
                   do-not-touch respected, escalations flagged
5. Honesty         0 hides ambiguity / 1 some / 2 risks and open questions listed for the
                   builder to ask, not guess
Threshold: total >= 8/10 AND no criterion at 0.
```
