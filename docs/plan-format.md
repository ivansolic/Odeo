# Plan format (the architect's contract)

The implementation plan is the CONTRACT between planning and building: the
`architect` produces it, the human approves it, the `builder` executes it exactly.
**What "exactly" binds:** signatures, paths, behavior rules, test cases, verify
commands, and boundaries. NOT the implementation shape, which is the builder's to
choose within those. The plan states the promises the code must keep; it does not
contain the code (see the Implement field and ADR-001).
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
  validation", write WHICH validation, on WHICH field, with WHAT rule. State the
  BEHAVIOR and the INVARIANTS (what must remain true), not the code: the code is
  the builder's, the promises are yours. Where a mechanism is a design decision,
  state the mechanism ("replace in place, keeping the first match and dropping
  later ones") rather than the lines that implement it. Snippets only under the
  exception in Rules below, labelled.>
- Consumes / Produces: <REFERENCES into the Contracts section, never new
  definitions: local `C1 (Invoice)`, cross-plan `<plan-file> C1 (Invoice)`.>
- Verify: <exact command(s) and expected output>
- Consumes: <interfaces/types this task needs, from which task or existing code>
- Produces: <interfaces/types the next tasks may use>
- Commit: <the conventional commit message>

## Design decisions (resolved, so the builder does not guess)
<each decision the build depends on, with its reason, so no task re-opens it:
 "the flag is opt-in, so the install-time guarantee holds by construction">

## Contracts (declared once, referenced by name)
<every interface crossing task boundaries, declared HERE and nowhere else. This is
 what replaces per-task interface definitions: at 3 files that was a chain, at 40 it
 is an unreadable mesh.>
### C1: <name>
- Kind: type | signature | file format | exit contract | CLI | stdout format
- Declaration: <the exact thing, verbatim. For an EXTERNAL entry shared across a
  batch, BY REFERENCE to the declaring plan, never copied.>
- Produced by: Task N        (or: <plan-file> Task N, external, declared there)
- Consumed by: Task M, Task P   (within-plan only, and DERIVED: the task-side
  `Consumes:` is authoritative and the two must agree. External consumers are
  deliberately NOT listed, so this plan cannot go stale when a consumer is written.)
- Invariants: <what must remain true; this is where "entries are trimmed before
  classification, and a padded entry must still match" lives>

## Task order and parallelism
<which tasks are independent (safe to build in parallel) and which are sequential>

## Success signal (every acceptance criterion mapped to a concrete check)
| Criterion | Proven by |
|---|---|
| <the AC, in the story's words> | <the exact command or observation> |

## Do-not-touch boundaries
<files and behaviors this plan must NOT change, with the reason for each>

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
- **The plan carries contracts, not implementations** (ADR-001). A task states
  signatures, behavior, invariants, test cases and verify commands; it does not
  contain the code. Test-first is unaffected: the builder writes the failing test
  first (per the project's dev-rigor), watches it fail, THEN implements to satisfy
  the contract.
- **Snippet exception**, for cases where the exact characters are load-bearing and
  easy to get wrong (a regex, shell quoting, a `sed`/`awk` expression, a format
  string). All three conditions required:
  1. Shape and one-per-task, never a line count (a line cap is gameable by
     formatting): at most ONE such snippet per task, no function bodies and no
     host-language block bodies, never a whole file, class or task implementation.
     A `sed`/`awk`/regex program counts as ONE however many lines its syntax needs.
     "Host language" means the language of the file being created: when the artifact
     ITSELF is a `sed`/`awk` program, the exception does not apply.
  2. The literal label `illustrative-not-contract:` on the snippet. An UNLABELED
     code block in a plan is a rubric failure (criterion 3). The label means the
     builder may do better and is never bound to transcribe it.
  3. A one-line reason why the characters are load-bearing. If the reason cannot be
     named, prose sufficed.
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
1. Executability   0 needs interpretation / 1 mostly / 2 context-free builder could run it.
                   "Could run it" = every signature, behavior rule, invariant, test case,
                   verify command and unspecified-decision boundary is present, such that
                   TWO competent builders would produce functionally equivalent code.
2. File map        0 missing / 1 partial / 2 complete with responsibilities
3. Task quality    0 vague steps / 1 mixed / 2 right-sized units (each worth its own
                   reviewer gate), exact signatures + exact behavior and test cases,
                   verify commands, consumes/produces stated. Every Consumes/Produces
                   entry RESOLVES to a named Contracts entry (this plan's, or
                   `<plan-file> C<n>` in the same batch) and every Contracts entry
                   names its producing task; within a plan, `Consumed by:` and the
                   task-side `Consumes:` must AGREE (cross-plan references are checked
                   one-directionally). An UNLABELED code block is a failure here.
4. Constraint fit  0 ignores architecture or boundaries / 1 partial / 2 inherits explicitly,
                   do-not-touch respected, escalations flagged
5. Honesty         0 hides ambiguity / 1 some / 2 risks and open questions listed for the
                   builder to ask, not guess
Threshold: total >= 8/10 AND no criterion at 0.
```
