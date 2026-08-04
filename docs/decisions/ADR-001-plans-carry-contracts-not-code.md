# ADR-001: The plan carries contracts, not code

- Status: **accepted** (v5, human 2026-08-04, conditional on the fifth review round
  returning clean, which it did: two non-blocking residues, both closed in v5 except
  the deferred site 15 recorded below). Five architecture-review rounds folded.
- Date: 2026-08-04
- Affects: `docs/plan-format.md`, `agents/architect.md`, `agents/builder.md`,
  `agents/code-reviewer.md`, `docs/skill-authoring-standard.md`,
  `skills/build/SKILL.md`, `docs/internal-paths.txt`

## Context

On 2026-07-19, commit `fae8a5a` introduced **complete-code-as-economy**:
`docs/plan-format.md` instructs the architect to put the EXACT code in a task so
the builder transcribes rather than reconstructs it. The rationale was token
economy and precision. It passed an architecture-review loop at the time.

Since then the repo has accumulated evidence about what plans actually need.

## Problem

Three problems, in order of strength. The first is the reason; the third is a
consequence, not a premise.

### 1. A pasted code block is a second copy of the truth

This repo's dominant house pattern is a single source plus a mechanical agreement
check. The publish lists "live ONLY in" one place. USR-004 Task 4b exists solely
because the language allowlist had five copies. Loader duplication is the single
reason the publish-guard build scored conventions 1/2
(`docs/evals/code-feature-publish-guard.md:86-92`).

Plan-carried code violates that pattern. The clearest case is inside USR-004
itself: the plan pasted `read_lang` (`docs/plans/2026-07-30-usr-004-change-language-anytime.md:130-143`)
as a copy of `bin/resolve-language.sh:44-57`, and the architecture review then had
to verify the copy was "character-identical to `bin/resolve-language.sh` lines 44
to 57" (same file, `:49`). That verification step exists ONLY because the plan
created a third copy, which can drift between plan-approval and build.

The contract form, "`read_lang` MUST be character-identical to
`bin/resolve-language.sh:44-57`", is a REFERENCE. It is strictly stronger: it
cannot go stale, it is diffable at build time, and it needs no reviewer to compare
characters by eye. Nobody in this repo argues for a second copy on cost grounds.

### 2. Pre-written code does not scale, and the format has no home for what replaces it

A 40-file, multi-module, cross-layer story cannot be pre-written: the plan is stale
before the build, and it creates false "deviation" pressure when the builder finds
a better approach than a document that calls itself a contract.

Worse, code-in-plan implicitly carried the shared interface, which HID a structural
gap. `docs/plan-format.md:16-66` documents exactly four sections (Header, File map,
Tasks, Risks). Interfaces are expressed only per task, as `Consumes:` / `Produces:`
(`:60-61`). At 3 files that is a chain; at 40 it is an N-to-N mesh with no single
place to read the shared types, so the builder of task 9 must read tasks 1 through 8
to learn a type, and any revision must be applied consistently in eight places,
which is the drift class USR-004 Task 4b exists to catch mechanically.

Two distinct cases. The pipeline allows one plan per story, "or one per small batch
when stories are tightly related" (`docs/plan-format.md:9-10`); a large feature
spanning several stories becomes several plan FILES (`agents/architect.md:61-64`,
"Plan each story as its own plan file, in dependency order"), one worktree each
(`agents/builder.md:93`). So: WITHIN one plan, including a small tightly-related
batch carried by a single plan, the plan-level Contracts block below fully solves the
mesh and change 14 is not needed. ACROSS several plan files, the shared interface
crosses FILES, which a plan-level block cannot solve on its own; that is the case
change 14 governs.

Every recent successful plan invented the missing sections, and NONE of them is in
the format document (verified 2026-08-04, zero occurrences each in
`docs/plan-format.md`):

| Section | Invented in |
|---|---|
| `## Design decisions (resolved, so the builder does not guess)` | USR-003 `:37`, USR-004 `:32` |
| `## Success signal` (every acceptance criterion mapped to a check) | USR-002 `:76`, USR-003 `:95`, USR-004 `:528` |
| `## Do-not-touch boundaries` | USR-003 `:104`, USR-004 `:545` |
| `## Task order and parallelism` | USR-002 `:355`, publish-guard `:327` |
| a plan-level contracts block | USR-002 `:42`, as "Precedence rules and CLAUDE.md line format (**the contract, exact**)" |

Those sections, not the code blocks, are what carried USR-003 and USR-004.

### 3. Role integrity (a consequence, and a wording bug)

If the architect authors the implementation, the builder is a transcriber and
choosing its model tier is decorative.

The apparent self-contradiction is smaller than it looks and must NOT carry this
decision. `agents/architect.md:4` is `tools: Read, Grep, Glob` and `:58-59` says
"You cannot write files; return the full plan content and the intended path". Read
against those, `:10` ("you never write code, your tools cannot, and that is
intentional") is a claim about TOOL CAPABILITY: no code the architect authors can
reach the repo without a human gate and a builder. Under that reading, specifying
code in a document is not a contradiction, and the original design did reconcile
them. The genuine residue is that the clause reads as a claim about the ROLE; it is
repaired by one qualifier, not by this ADR. Recorded here so a future reader does
not re-derive the wording fix and reopen the decision.

## Evidence

**The natural experiment already in the repo** (confounded by complexity, so it
does not prove causation, but it refutes "transcription is required for precision"):

| Story | Plan shape | Fenced blocks | Arch-review | Code review |
|---|---|---|---|---|
| USR-002 | heavy literal code | many | v1 (1 blocking) to v3 | 12/12, round 1 |
| **USR-003** | **prose contracts, no code** | **0** | **clean at v1** | **12/12, round 1** |
| publish-guard | prose plus snippets | few | v1 (3 blocking) to v3 | 11/12, 2 latent fail-opens |
| USR-004 | heaviest literal code | 8 (5 bash) | v1 to v3 | 10/12, 4 Important, 3 rounds |

(The count is BLOCKS, not fence delimiters. ADR v1 said 16, which is the delimiter
count from `grep -c '^```'`; there are 16 delimiters and therefore 8 blocks, five of
them bash. Recorded because it is the same failure as the corrected claim below,
verifying the wrong quantity and calling it verified.)

**Corrected empirical claim.** ADR v1 asserted that "exactly ONE" architecture-review
finding depended on the plan containing literal code. That was wider than the record
supports, and it is the same class of error `.claude/tasks/lessons.md:14` warns
against, made inside the document arguing against that class. The accurate statement,
from `docs/plans/2026-07-30-usr-004-change-language-anytime.md:49-51`:

- ONE finding strictly required literal code: the pasted `read_lang` had to be
  compared character by character. As argued above, that case is strictly WEAKER as
  a copy than as a reference clause.
- TWO more were reached faster because code was present: the arg-parse walk across
  the 8 existing cases, and "no awk path can truncate the target". Both are
  expressible as invariants plus tests.
- ONE is the `sed`-vs-`awk` divergence, which the snippet exception below PERMITS.
  It does not produce it: that finding came from comparing the MECHANISM of two
  writers, which a contract must state anyway ("replace in place, keeping the first
  match and dropping later ones, a deliberate superset of `init-project.sh`'s
  `sed`"). Crediting the exception with the finding would overstate it.
- The remaining findings came from reading the REAL tree and from noticing the plan
  ASSERTED an invariant nothing enforced. Both would have arisen under either rule.

**Failure mode that plan-carried code causes.** A frozen code region suppresses
builder-side defect detection. USR-004's plan says "The existing fresh-write tail
(`mkdir -p`, ensure file, append, 'set to') stays exactly as it is"
(`:363`). The round-2 code-review Important was precisely in that tail: the append
branch reported a false success on an unwritable config
(`docs/evals/code-feature-usr-004-language.md:174-175`). "Stays exactly as it is"
is a sentence a contract-shaped plan would not write; it would state the exit-code
invariant, and the invariant would have caught it.

## Decision

**The plan carries contracts, not implementations.**

A plan task STATES: exact signatures, interfaces and paths; the behavior concretely
(WHICH validation, on WHICH field, with WHAT rule); the test cases with expected
failures; exact verify commands and expected output; consumes / produces as
REFERENCES to the plan-level contracts block.

A plan task does NOT contain the implementation.

**The snippet exception, bounded so it cannot creep back:** a short snippet is
allowed where the exact characters are load-bearing and easy to get wrong (a regex,
shell quoting, an `awk`/`sed` expression, a format string). Three conditions, all
greppable:

1. **Shape and one-per-task, never a line count** (a line cap is gameable by
   formatting): **at most ONE such snippet per task**, no function bodies and no HOST-language block bodies,
   and never a whole file, class, or task implementation. A `sed`/`awk`/regex program
   counts as ONE however many lines its own syntax needs, since no `awk` program of
   interest exists without `{ ... }`; forbidding "block bodies" outright would forbid
   the exact class this exception exists to permit. "Host language" means the language
   of the file being created: when the artifact ITSELF is a `sed`/`awk` program, the
   exception does not apply, because that is an implementation and the contract states
   its behavior.
2. **A required literal label**, `illustrative-not-contract:`, on every such
   snippet. An unlabeled code block in a plan is a rubric failure under criterion 3.
3. **A required one-line reason** why the characters are load-bearing (escaping,
   quoting, format string). If the architect cannot name the reason, prose sufficed.

**The plan format gains the sections that practice already proved**, in this same
change, because they carry the load the code blocks were carrying: `Design
decisions`, `Success signal` (acceptance-criterion-to-check table), `Do-not-touch
boundaries`, `Task order and parallelism`, and a plan-level `Contracts` block that
declares each cross-task interface ONCE.

**The Contracts block has a specified shape**, not a free-form one. Two reasons it
cannot be left to the architect: it becomes rubric-scored (changes 4 and 5, and
criterion 1's "two competent builders produce functionally equivalent
implementations" cannot be scored consistently against an undefined subject), and
without a naming rule a `Consumes:` reference cannot resolve to anything checkable.
Minimum shape, covering every interface kind this repo actually produces:

```
## Contracts (declared once, referenced by name)
### C1: <name>
- Kind: type | signature | file format | exit contract | CLI | stdout format
- Declaration: <the exact thing, verbatim; for an EXTERNAL entry, by reference to
  the declaring plan, NEVER copied, which is argument 1 applied to itself>
- Produced by: Task N   (or: <plan-file> Task N, external, declared there)
- Consumed by: Task M, Task P   (WITHIN-PLAN ONLY, and DERIVED: the task-side
  `Consumes:` is authoritative, and criterion 3 requires the two directions to
  agree. External consumers are deliberately NOT listed, see change 4)
- Invariants: <what must remain true>
```

`Invariants:` is the field to insist on beyond naming, because the Negative
consequence below is that the failure mode becomes an INCOMPLETE contract, and both
publish-guard fail-opens were missing invariants, not missing steps ("entries are
trimmed before classification; a padded entry must still match" is an invariant, not
a step). `Produced by` / `Consumed by` is what makes the reference graph checkable
and what replaces the N-to-N mesh. Prose style, ordering and entry count stay with
the architect.

## Consequences

**Positive**
- No second copy of the truth in a plan. References to REPO CODE cannot go stale (a
  drift is diffable at build time); cross-plan references point at another plan
  document, which is mutable, so they are pinned by same-gate approval (change 14).
- ONE format from a 3-file story to a 40-file cross-layer feature.
- The builder's model tier becomes meaningful again (it reasons, not types). Note
  the corollary: on a weaker builder tier, contracts must be tighter.
- The plan review changes target: from comparing code against a copy of code
  (catches transcription errors) to checking whether the contract is complete and
  honest (catches design errors). The latter is what actually found our defects.
- Two of the new sections, `Design decisions` and `Success signal`, are readable by
  a non-engineer at the human gate. This is claimed for those two ONLY: the
  `Implement` field of a contract-shaped plan is often DENSER than formatted code
  (see USR-003 `:69`, a single line carrying `set -uo pipefail`, arg count, the
  allowlist, the config-path default and the idempotence gate), so no general
  legibility win is claimed.
- Smaller external payload: `bin/second-opinion.sh:13,28,44` sends the plan file to
  an external vendor CLI, so a contracts-only plan exposes materially less IP.

**Negative**
- Loses the transcription economy that was the original rationale. Unmeasured
  before and after; no claim is made in either direction.
- The failure mode moves rather than disappears: from "wrong code in the plan" to
  "**incomplete contract**". Both latent fail-opens in the publish-guard build
  (padded denylist entries silently inert, `docs/evals/code-feature-publish-guard.md:60-67`;
  PIPESTATUS reset masking an enumeration failure, `:76-81`) trace to prose at
  `docs/plans/2026-07-24-enforced-publish-guard.md:186-187` that never said "trim".
  The fix is a better contract ("entries are trimmed before classification; a
  padded entry must still match"), not a code block. Contracts must state
  INVARIANTS, not steps.
- Verify commands and expected counts in plans remain unexecuted and fallible
  (`.claude/tasks/lessons.md:11`). This ADR does not fix that; it keeps them, so
  the "unverified artifact" property is a property of plans generally, not of code.

**Neutral / verified**
- No migration needed: every plan in `docs/plans/` is `approved: yes` AND already
  built (verified 2026-08-04).
- No gate, lint or rubric depends on transcribable code: `bin/spec-gate.sh` and
  `bin/merge-gate.sh` contain zero "plan"/"architect" matches; `bin/skills-lint.sh`
  does not inspect plans; `agents/builder.md:17-25` requires only `approved:`,
  `model_plan:`, `arch_review:`. `agents/builder.md` DOES need changes, for a
  different reason (see the change list).

## Alternatives considered

1. **Keep code, add a `plan_depth` switch** (`transcribe | hybrid | contract`,
   derived from the File map). REJECTED: a third classification axis beside
   `dev_rigor` and `Scrutiny`, grading plans by how much implementation they carry,
   which is only a variable because the code rule made it one. Mechanism over
   diagnosis. Note the warning that made this ADR expand its scope: if the sections
   above are NOT codified in this same change, `plan_depth` returns under another
   name ("plan tiers", "one plan per module").

2. **Contracts by default, literal code permitted only for `Scrutiny: mechanical`
   tasks.** REJECTED on the repo's own data, not as a compromise:
   - It corrupts the one signal the code reviewer uses to allocate attention.
     `docs/plan-format.md:46-50` defines `Scrutiny` as an attention signal,
     explicitly "NOT a model selector", explicitly never lowering coverage of other
     tasks. This alternative turns an advisory hint into a permission token, with an
     inverted incentive: the architect GAINS the right to write code by tagging
     DOWN, so the most literal content would sit under the least scrutiny.
     `agents/code-reviewer.md:31` already exists as a defense against that
     half-coupling ("a `mechanical` tag on code transcribed from the plan does NOT
     mean that code was pre-verified").
   - Empirically it preserves ZERO economy. Every literal implementation block in
     this repo's plan history sits in a `judgment`- or `standard`-tagged task, and
     not one sits in a `mechanical` task (USR-002 T1 judgment, T2 standard, T3
     mechanical-no-code; USR-004 T1/T2/T3 judgment with code, T4 mechanical-no-code,
     T4b judgment-no-code). It would have permitted none of the code actually
     written, while adding a new coupling.
   - Its one real advantage, auditability of a discrete declared token, is imported
     into the snippet exception's mandatory label instead.

3. **Remove code entirely, no exception.** REJECTED as slightly too strict:
   escape-level and quoting details are where prose genuinely fails, and forcing
   derivation invites a wrong escape that tests may not catch.

4. **Leave it as is.** REJECTED: the format does not scale to the enterprise half of
   the audience, and the second-copy problem stands.

## Changes required (verified by grep, 2026-08-04)

| # | Site | Change |
|---|---|---|
| 1 | `docs/plan-format.md:55-58` | Implement field: behavior + signatures, no implementation; snippet exception with its three conditions |
| 2 | `docs/plan-format.md:78-81` | Reframe "complete code does not waive test-first": plans carry no implementations; test-first unchanged |
| 3 | `docs/plan-format.md:16-66` | Add the five sections: Design decisions, Contracts (plan-level, declared once, in the shape specified above), Success signal, Do-not-touch boundaries, Task order and parallelism. `Consumes:`/`Produces:` become references to Contracts, not definition sites. **Write the worked examples INLINE and generic**: `plan-format.md` is public while every existing example of these sections lives in denylisted `docs/plans/`, so referencing them would make the public format doc dangle exactly as change 13 describes |
| 4 | `docs/plan-format.md:96` | Rubric criterion 3: "exact signatures + exact behavior and test cases"; an unlabeled code block is a failure. **Plus the reference-resolution clause**, which change 3 makes necessary: every `Consumes:`/`Produces:` entry must resolve to a named entry in THIS plan's Contracts block, or to a named entry in another plan of the same batch cited as `<plan-file> C<n>`. Citation form, stated once so it is greppable and scorable: local `Consumes: C1 (Invoice)`, cross-plan `Consumes: <plan-file> C1 (Invoice)`. In the PUBLIC `docs/plan-format.md` the example must use the placeholder form (matching how `docs/plan-format.md:9` writes `<YYYY-MM-DD>-<slug>`), never a concrete dated filename. The task-side `Consumes:` is AUTHORITATIVE and the Contracts block's `Consumed by:` is derived, so criterion 3 also requires the two directions to AGREE, WITHIN ONE PLAN: `Consumed by:` and the agreement check are within-plan only. A CROSS-PLAN `Consumes:` is checked one-directionally, it must RESOLVE to a named entry in the cited plan, and the declaring plan is NOT required to know its external consumers. That asymmetry is deliberate: plans are written in dependency order (`agents/architect.md:61-64`), so the declaring plan usually exists before its consumers, and requiring its derived field to enumerate their tasks would make it stale the moment a consumer is written, which is the stale-copy failure argument 1 condemns. Without this clause a reference can dangle and a builder in a fresh context cannot distinguish "declared elsewhere" from "forgotten", so the ADR would demand single-source and then ship an unchecked reference graph |
| 5 | `docs/plan-format.md:93` | Rubric criterion 1 (Executability) must move with 3: define "context-free builder could run it" as every signature, behavior rule, test case, verify command and unspecified-decision boundary present, such that two competent builders produce functionally equivalent implementations |
| 6 | `docs/plan-format.md:3` + `skills/build/SKILL.md:30,98` | Define what "executes the plan exactly" BINDS: signatures, paths, behavior rules, test cases, verify commands, boundaries. NOT implementation shape. Otherwise the false-deviation pressure moves from code to prose |
| 7 | `agents/architect.md:41-45` | Author contracts, not implementations; the snippet exception and its label |
| 8 | `agents/architect.md:10` | One qualifier: "you never write code INTO the repo", so the tool-capability reading is recorded and the ADR is not reopened |
| 9 | `agents/builder.md:45-51, 83, 93` | **Implementation latitude clause** (the line between "unspecified, choose well" and "a different design, STOP and ask"); redefine "deviation" as contract deviation, not implementation shape; improving on an `illustrative-not-contract:` snippet is explicitly NOT a deviation |
| 10 | `agents/code-reviewer.md:27-34` | Drop the "transcribed from the plan" premise; add the new duty: compare shipped code against the plan's CONTRACT (signatures, behavior rules, named test cases), which is what keeps "contract" honest |
| 11 | `docs/skill-authoring-standard.md:68` | REPLACE the row, do not reword it. That file's own rule (`:60-62`) says add a rationalization "ONLY where the shortcut has been observed, never speculatively", and "the plan already has the code" becomes unreachable. Replace with the observed one: "the plan says preserve this block exactly, so I need not check it" -> "a frozen block is unexamined, not verified; USR-004's frozen append tail carried a false-success bug" |
| 12 | `docs/skill-authoring-standard.md:45` | One line distinguishing domains, so ADR-001 is not misread as reversing the `privacy-scan.sh` principle: shipped deterministic scripts are pre-written by design; plan documents are not where they get pre-written |
| 13 | `docs/internal-paths.txt` | **Classify `docs/decisions/` as INTERNAL (denylist).** Verified: it is in neither path list and is not gitignored, so committing this ADR makes `publish-guard.sh --require-allowlist` exit 1 and `publish-snapshot.sh` refuse (proven by running the guard, 2026-08-04). Internal, not public, for three reasons: (a) this ADR's entire evidence base is denylisted artifacts, at least three full-path citations each into `docs/plans/`, `docs/evals/` and `.claude/tasks/lessons.md`, plus story-level and line-level references throughout the evidence and section tables, all stripped from the snapshot, so a published ADR would dangle every load-bearing citation and leak internal review scores in prose; (b) `docs/public-paths.txt:11-12` states "NEVER add a bare `docs/` line ... any new docs path must be classified", and a `docs/decisions/` PREFIX would auto-publish every future ADR with no human classification, which is the fail-open the allowlist was built to remove; (c) ADRs are the artifact class most likely to carry pre-launch state (`.claude/tasks/lessons.md:12` quarantines the integration-branch scheme for exactly that reason). The RULE ships publicly through `docs/plan-format.md`, where it belongs; the REASONING with internal evidence stays internal. The entry MUST carry a why-comment, following the `knowledge/` precedent at `docs/internal-paths.txt:16-18` (annotated precisely because a reader would otherwise think it belongs public): ADRs are public in most repos, so an uncommented entry invites a well-meaning revert |
| 14 | `agents/architect.md:61-64` | **Cross-plan contracts.** The batch instruction is the only place governing a shared interface once a feature spans several plan FILES: one plan per story or per small tightly-related batch (`docs/plan-format.md:9-10`), so a multi-story feature becomes several plan files (`agents/architect.md:61-64`), one worktree each (`agents/builder.md:93`). Two rules: (i) when a batch shares an interface, ONE plan declares it in its Contracts block and the others reference it by plan and entry name, never declared twice. A mirror entry in a consuming plan is a REFERENCE, not a declaration: "never declared twice" means never two verbatim `Declaration:` bodies, so both citing `<plan-file> C1` directly and carrying a local by-reference mirror are legal; (ii) **[I]** a cross-plan reference is legal only WITHIN ONE BATCH APPROVED AT THE SAME GATE, and revising a declaring plan after approval invalidates its consumers' approval, which return to the gate. Holder: the orchestrating session at gate 1 (`skills/build/SKILL.md` B5), the only actor that sees the whole batch; the `architecture-reviewer` is the detector during plan review, and the builder structurally cannot be, since it sees one plan. Marked **[I]** because nothing mechanical can check it (verified: `bin/merge-gate.sh` has zero `plan`/`architect` matches, no script parses plan cross-references, and `agents/builder.md:17-25` checks approval only on the builder's OWN plan). Without (ii) a declaring plan could be revised after a consumer was approved and the consumer's contract would change silently, since `agents/builder.md:17-25` checks `approved:`/`arch_review:` only on the builder's OWN plan |

## Measurement and the trip-wire

Token cost was not measured before this change and is not measured here; no claim
is made in either direction. This is a role-boundary decision, which no A/B run can
settle, so it takes the ADR path rather than `/improve`'s measure-then-keep path
(`skills/improve/SKILL.md:9-10`, whose trigger `:2` is repeated eval drops on one
criterion, not this).

The evidence that bounds the risk is the natural experiment above: USR-003's
contract-shaped plan cleared architecture review at v1 and scored 12/12 on the
first code review.

**Named trip-wire, so this is not left to memory:** if either of the next two plans
needs more architecture-review rounds than USR-003 did, or a code review raises an
Important attributable to a reconstruction the plan under-specified, that is the
signal to revisit through `/improve`, NOT to quietly re-add code blocks.

**Site 15, done in this change rather than deferred.** Rule (ii) of change 14 governs
when a human approval stops covering a plan, which is human-floor territory, and
`AGENTS.md:148-152` says guardrails are the single source of truth and that "a rule
that is not written here does not exist". The review offered to defer it since nothing
in the first build depends on its placement; it is done now instead, because deferring
would ship rule (ii) as a rule that formally does not exist, which is the
claim-wider-than-mechanism class this ADR is about. One `[I]` bullet was added under
AGENTS.md Guardrails section 1 (human floor), naming the holder (the orchestrating
session at gate 1) and the detector (`architecture-reviewer` during plan review);
change 14 REFERENCES it rather than restating it.

**Follow-up (not in this change):** `docs/checklists/review-calibration.md` names
`architecture-reviewer` in its purpose (`:4`) but both seed scenarios (`:36`, `:58`)
are `code-reviewer`. Nothing today would detect the PLAN reviewer getting worse
after this change. Add an `architecture-reviewer` seed scenario.
