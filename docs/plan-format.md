# Plan format (the architect's contract)

The implementation plan is the CONTRACT between planning and building: the
`architect` produces it, the human approves it, the `builder` executes it exactly.
**What "exactly" binds** (this list is canonical; other files cite it rather than
restating it): signatures, paths, behavior rules, INVARIANTS, named mechanisms, test
cases, verify commands, and boundaries. NOT the implementation shape, which is the
builder's to choose within those. The plan states the promises the code must keep; it does not
contain the code (see the Implement field and the Rules below).
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
model_plan:             # the judgment model and effort AS OF when the plan is written.
  judgment: <model> effort <level>   # Either field may be STATED by the user (write it
                        # plain) or READ in step 2 (the model from the session, the effort
                        # from config) rather than resolved live in front of them. A READ
                        # value carries its source, the SAME duty for both fields, so a
                        # reader at the gate can tell it from a confirmed one:
                        # `effort high (configured, per CLAUDE_EFFORT)`,
                        # `judgment <model> (per session environment)`. The read order
                        # lives in AGENTS.md. A
                        # PLAN-TIME SNAPSHOT: never "corrected" after the gate, even if
                        # the session model changes later (the step recommends switching
                        # up for architecture-critical work, so it legitimately can). A
                        # post-gate plan edit refuses the merge, and the eval record's own
                        # `model:` is authoritative for who judged.
  builder_tier: <tier word> effort <level>   # the APPROVED INTENT, a tier word, so it
                        # cannot go stale. Present at approval; the builder's contract
                        # requires THIS line. Raise it above the default when the
                        # output is itself judgment (wording, instructions, prose).
                        # The plan holds INTENT only and is immutable after the gate.
                        # The resolved model NAME is NOT recorded here: merge-gate
                        # compares every non-evals path against `reviewed_commit:`, so a
                        # post-review plan edit refuses the merge and would force a full
                        # code re-review for one provenance line. It goes in the eval
                        # record as `build_model_as_dispatched:` instead, which that
                        # comparison excludes by construction. Named "as dispatched",
                        # not "as ran": nobody here can verify which model the vendor
                        # actually served, so it discloses what was requested rather
                        # than claiming what executed. Prior plans keep the older
                        # `builder:` child; they are records of what was, never migrated.
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
Constraints: <copied verbatim from the spec/story. Boundaries live in the
  Do-not-touch section below, not here, so they have one home.>

## Design decisions (resolved, so the builder does not guess)
<each decision the build depends on, with its reason, so no task re-opens it. Write
 `none` if the story genuinely presented no choice.>
- The `--overwrite` flag is opt-in, so the default write path is byte-identical and
  the install-time "asked once" guarantee holds by construction.

## Contracts (declared once, referenced by name)
<every interface crossing task boundaries, declared HERE and nowhere else, so tasks
 reference and never redefine it. Write `none` whenever no interface crosses a task
 boundary, however many tasks the plan has. Declared BEFORE the tasks that cite it.>
### C1: language status line
- Kind: stdout format + exit contract   (one entry may carry both when they are one
  observable surface; split them only if tasks consume them separately)
- Declaration: `language-status.sh <project-dir>` prints exactly `<code> <scope>`,
  scope in `project | global | default`; exit 0 on success, 2 on usage error.
  <For an EXTERNAL entry shared across a batch, state it BY REFERENCE to the
  declaring plan, never copied. Cross-plan references are legal only within ONE
  batch approved at the same gate: see the human-floor rule in AGENTS.md
  Guardrails 1, which governs.>
- Produced by: Task 1        (or: <plan-file> Task N, external, declared there)
- Consumed by: Task 4        (within-plan only, and DERIVED: the task-side
  `Consumes:` is authoritative and the two must agree as a set. External consumers
  are deliberately NOT listed, so this plan cannot go stale when a consumer is
  written.)
- Invariants: the `<code>` field always equals `resolve-language.sh`'s output; an
  invalid project value reports scope `global`, never `project`.

## File map (before any tasks)
<every file this plan creates or modifies, with its responsibility>
- bin/language-status.sh        CREATE: prints the effective language and its scope
- tests/language-status.test.sh CREATE: tests for language-status.sh
- skills/language/SKILL.md      CREATE: the /language command surface

## Tasks
<the smallest independently testable units, in dependency order; each task:>
### Task 1: <name>
- Scrutiny: <mechanical | standard | judgment> (optional; omitted = standard), a
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
  definitions: local `C1 (language status line)`, cross-plan
  `<plan-file> C1 (language status line)`.>
- Verify: <exact command(s) and expected output>
- Commit: <the conventional commit message>

## Task order and parallelism
<which tasks are independent (safe to build in parallel) and which are sequential.
 One line is enough on a single-task or strictly sequential plan.>

## Success signal (every acceptance criterion mapped to a concrete check)
<ONE ROW PER acceptance criterion in the story, quoted short and attributed, so the
 mapping is provably complete: the row count MUST equal the story's criterion count.>
| Criterion (short quote, USR-00X) | Proven by |
|---|---|
| "a newly generated PRD body is in German" | `bash tests/localized-prose.test.sh` |

## Do-not-touch boundaries
<files and behaviors this plan must NOT change, with the reason for each. Write
 `none` plus one line of why whenever no boundary applies (a greenfield repo, or an
 existing one with no mapped boundaries near this work); the enforced list lives in
 docs/codebase-map.md, this section names only what THIS plan must respect.>

## Risks / open questions
<anything ambiguous the builder must ASK about rather than decide alone>
```

## Rules
- **No placeholders.** "TBD", "add error handling", "improve X" are plan failures.
  Exact paths, names, signatures, commands. A deliberate `none` plus its one-line
  reason is NOT a placeholder: it is an answered question, and it is how a small
  story fills the sections that genuinely do not apply. An EMPTY heading is a
  failure; `none, greenfield repo with no prior boundaries` is not.
- **Interfaces declared once, in `Contracts`**, and referenced by tasks via
  `Consumes:`/`Produces:`, so dependencies are visible, tasks stay independently
  verifiable, and no interface has two definition sites.
- Task granularity (right-size it): a task is the SMALLEST unit that still
  carries its own test cycle AND is worth a fresh reviewer's gate. Merge trivial
  setup/config steps into the task that needs them; split only where a reviewer
  could meaningfully reject. Each task is still one cycle: test, fail, implement,
  pass, commit.
- **The plan carries contracts, not implementations.** A task states
  signatures, behavior, invariants, test cases and verify commands; it does not
  contain the code. Test-first is unaffected: the builder writes the failing test
  first (per the project's dev-rigor), watches it fail, THEN implements to satisfy
  the contract.
- **Snippet exception**, for cases where the exact characters are load-bearing and
  easy to get wrong (a regex, shell quoting, a `sed`/`awk` expression, a format
  string). All three conditions required:
  1. Shape and one-per-task, never a line count (a line cap is gameable by
     formatting): at most ONE such snippet per task, meaning one fenced block
     containing one construct, so two regexes in one fence is two snippets and fails.
     No function bodies and no host-language block bodies, never a whole file, class
     or task implementation. A `sed`/`awk`/regex program counts as ONE however many
     lines its own syntax needs. "Host language" means the language of the file being
     created: when the artifact ITSELF is a `sed`/`awk` program, the exception does
     not apply.
  2. The literal label `illustrative-not-contract:` on the line IMMEDIATELY BEFORE
     the opening fence, so it is greppable and unambiguous. An UNLABELED code block
     inside an `Implement:` field is a rubric failure (criterion 3). The label means
     the builder may do better and is never bound to transcribe it.
  3. A one-line reason why the characters are load-bearing. If the reason cannot be
     named, prose sufficed.

  Worked example, inside a task's `Implement:` field:

  illustrative-not-contract: exact escaping, easy to get wrong by hand
  ```
  sed -E 's/^output_language:[[:space:]]*//'
  ```
  The contract is the behavior ("strip the key and any following whitespace"); the
  snippet only saves the builder from re-deriving the character class.
- DRY and YAGNI apply: no speculative structures the story doesn't need.
- The plan INHERITS product-level architecture; if the story seems to require
  changing it, the plan must say so and STOP for a human/ADR decision.
- The plan names the north star it serves (`Serves:`), so execution sees the WHY,
  not just the WHAT. If the story seems to drift from that north star, flag it at
  the gate rather than building the literal spec anyway.
- On existing codebases: respect conventions and DO-NOT-TOUCH boundaries from
  `docs/codebase-map.md`; the plan lists which boundaries are nearby.

## Plan rubric (0-2 per criterion)
Scored by `architecture-reviewer` during plan review, which is the actor that can
walk the reference graph and the labels, and read again by the human at the gate.
```
1. Executability   0 needs interpretation / 1 mostly / 2 context-free builder could run it.
                   "Could run it" = every signature, behavior rule, invariant, test case,
                   verify command and unspecified-decision boundary is present, such that
                   TWO competent builders would produce functionally equivalent code.
2. File map        0 missing / 1 partial / 2 complete with responsibilities
3. Task quality    0 vague steps, OR an unlabeled code block inside an `Implement:`
                   field (a plan carrying an implementation is not a contract;
                   fenced commands under `Verify:` are not code blocks in this
                   sense) / 1 mixed, or one dangling
                   reference / 2 right-sized units (each worth its own reviewer gate),
                   exact signatures + exact behavior and test cases, verify commands,
                   and a CLEAN reference graph: every Consumes/Produces entry resolves
                   to a named Contracts entry (this plan's, or `<plan-file> C<n>` in
                   the same batch); every Contracts entry names its producing task;
                   within a plan, the set of tasks listing `Consumes: C<n>` EQUALS
                   that entry's `Consumed by:` set (cross-plan references are checked
                   one-directionally, resolution only); and the Success signal row
                   count equals the story's criterion count.
4. Constraint fit  0 ignores architecture or boundaries / 1 partial / 2 inherits explicitly,
                   do-not-touch respected, escalations flagged
5. Honesty         0 hides ambiguity / 1 some / 2 risks and open questions listed for the
                   builder to ask, not guess
Threshold: total >= 8/10 AND no criterion at 0.
```
