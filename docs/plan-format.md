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
  judgment: <model> effort <level>   # and answered the model+effort question
  builder: <tier -> model> effort <level>   # builder requires this line
arch_review: pending    # set by the /build pipeline after the plan-review loop:
                        # "clean (vN, YYYY-MM-DD)" or "waived (human)" for
                        # standalone human-supplied plans. The builder requires it.

## Header
Goal: <the story's outcome, one sentence>
Serves: <the north star this work advances, one line: the strategy bet or the
  outcome from the project's vision/strategy, so execution stays anchored to WHY
  (e.g. "strategy bet 2: enterprise Excel users; cut manual re-entry"). If there
  is no strategy doc yet, the story's own outcome stands in.>
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
- Scrutiny: <mechanical | standard | judgment> (optional; omitted = standard) , a
  complexity signal that tells the reviewer WHERE to spend the deepest attention
  (judgment tasks get the hardest look). It is NOT a model selector: reviews
  always run on the session judgment tier, and it never lowers coverage of the
  other tasks. (Named `Scrutiny` on purpose, to stay clear of the model `tier`.)
- Test first (per the project's dev-rigor style): <the exact test to write,
  named, with the expected failure>
- Implement: <exact function signatures, paths, and the change, no "add
  validation", write WHICH validation, on WHICH field, with WHAT rule.
  When the change is mechanical enough to write out, PUT THE EXACT CODE HERE:
  the builder transcribes and tests it, which is cheaper and more precise than
  a prose description it has to reconstruct. For genuinely novel logic, describe
  the approach and let the builder work it out under test.>
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
- Task granularity (right-size it): a task is the SMALLEST unit that still
  carries its own test cycle AND is worth a fresh reviewer's gate. Merge trivial
  setup/config steps into the task that needs them; split only where a reviewer
  could meaningfully reject. Each task is still one cycle: test, fail, implement,
  pass, commit.
- **Complete code in a task does NOT waive test-first.** The builder still writes
  the failing test first (per the project's dev-rigor), watches it fail, THEN
  transcribes the plan's code to make it pass. Code in the plan is the intended
  implementation, never a licence to skip the test.
- DRY and YAGNI apply: no speculative structures the story doesn't need.
- The plan INHERITS product-level architecture; if the story seems to require
  changing it, the plan must say so and STOP for a human/ADR decision.
- The plan names the north star it serves (`Serves:`), so execution sees the WHY,
  not just the WHAT. If the story seems to drift from that north star, flag it at
  the gate rather than building the literal spec anyway.
- On existing codebases: respect conventions and DO-NOT-TOUCH boundaries from
  `docs/codebase-map.md`; the plan lists which boundaries are nearby.

## Plan rubric (checked at the human gate; 0-2 per criterion)
```
1. Executability   0 needs interpretation / 1 mostly / 2 context-free builder could run it
2. File map        0 missing / 1 partial / 2 complete with responsibilities
3. Task quality    0 vague steps / 1 mixed / 2 right-sized units (each worth its own
                   reviewer gate), exact signatures + exact code where mechanical,
                   verify commands, consumes/produces stated
4. Constraint fit  0 ignores architecture or boundaries / 1 partial / 2 inherits explicitly,
                   do-not-touch respected, escalations flagged
5. Honesty         0 hides ambiguity / 1 some / 2 risks and open questions listed for the
                   builder to ask, not guess
Threshold: total >= 8/10 AND no criterion at 0.
```
