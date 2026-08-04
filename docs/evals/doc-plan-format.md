---
artifact: docs/plan-format.md
covers: docs/plan-format.md docs/skill-authoring-standard.md skills/build/SKILL.md
type: standard
branch: chore/adr-001-contracts-not-code
artifact_version: 1
date: 2026-08-04
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 1, worked_example: 1, precision: 1, safety_integration: 1 }
total: 6/10
verdict: CHANGES-REQUIRED
previous_total: n/a
---

Scope: form review of the ADR-001 instruction changes at commit `aee5ab1`, three
files. Judged as an AUTHORING STANDARD (a format agents must produce and a rubric
the human gate scores), not as a `SKILL.md`; the five rubric criteria are read in
that register (trigger clarity = does the reader know what the document governs
and when it binds). Decision under review:
`docs/decisions/ADR-001-plans-carry-contracts-not-code.md` (accepted v5), whose
change table is treated as the contract these edits must satisfy.

## Artifact: docs/plan-format.md + 2 coordinated files  (format spec, not invoked)

## Scores
- trigger clarity 2: `:3-8` "The implementation plan is the CONTRACT between
  planning and building ... **What \"exactly\" binds:** signatures, paths, behavior
  rules, test cases, verify commands, and boundaries. NOT the implementation shape,
  which is the builder's to choose within those." Scope, audience and binding force
  are stated in the first eight lines, and `:12-16` states where the artifact lives
  and what refuses to run without it. ADR change 6 satisfied at this site.
- structure 1: three structural defects. Leftover duplicate fields at `:64-68`
  (F1), no mandatory/conditional convention on the five new sections (F2), and
  declaration-after-use ordering: `## Tasks` at `:47` cites `C1 (Invoice)` at `:65`
  while `## Contracts` only opens at `:75` (F7). Lean (163 lines) and no supporting
  files, so the size and one-level rules are not at risk.
- worked example 1: the five new sections are placeholder-only. `:79` is
  "### C1: <name>" and no entry is ever filled, while the task template at `:65`
  cites a concrete `C1 (Invoice)` that the document itself never declares, so the
  doc's own reference does not resolve inside the doc. The Rules snippet exception
  (`:120-133`) shows no labelled snippet at all. Contrast `:43-45`, where the
  pre-existing File map DOES carry real values (`src/billing/invoice.ts MODIFY:
  add issueInvoice(); owns invoice lifecycle`). ADR change 3 required inline
  generic worked examples for the new sections; the placeholders are inline and
  generic (no denylisted `docs/plans/` path is referenced, which is correct) but
  they are not worked.
- precision 1: exact in most places and it forbids placeholders itself (`:106`),
  but five load-bearing ambiguities remain: the snippet UNIT is undefined
  (`:124` "at most ONE such snippet per task", F5), the label's placement is
  undefined (`:129`, F6), criterion 3 assigns no score level to a violation
  (`:150-157`, F3), `Kind:` multiplicity and `Declaration: <the exact thing,
  verbatim>` misfit the non-textual kinds (`:80-82`, F10), and `Consumes:` exists
  twice with two different meanings (F1).
- safety integration 1: references rather than restates in the places it touches
  ("Test-first is unaffected: the builder writes the failing test first (per the
  project's dev-rigor)", `:117-119`; `Scrutiny` non-coupling untouched at `:50-54`;
  `docs/codebase-map.md` still named as the boundary source at `:140-141`). But the
  ONE new safety-relevant affordance, a cross-plan `Consumes:` at `:65` and
  `:153-156`, never points at the human-floor rule that bounds it
  (`AGENTS.md:165-170`, "revising a declaring plan after approval invalidates its
  consumers' approval"), so a scorer at the gate can approve a cross-plan
  reference without learning what approving it binds. Reaches 2 with one clause
  (F4). Nothing contradicts or restates a guardrail, so not 0.

## Total: 6/10   ## Verdict: CHANGES-REQUIRED (threshold 8/10, no zero)

## Ceiling
Max reachable 10/10; nothing structurally caps. Trigger clarity is judged as a
scope statement (the correct format for a non-invoked spec) and already scores 2.
Safety integration can reach 2 because a guardrail genuinely applies here (plan
approval, human floor); worked example can reach 2 because a filled Contracts
entry and a labelled snippet are both writable inline and generically.

## Findings

### Blocking
**F1 (High) `docs/plan-format.md:64-68`, the old definition-site fields survived
the edit.** The template now carries `- Consumes / Produces: <REFERENCES into the
Contracts section...>` at `:64-65` AND, after `Verify:`, `- Consumes:
<interfaces/types this task needs, from which task or existing code>` (`:67`) and
`- Produces: <interfaces/types the next tasks may use>` (`:68`). The surviving
pair is the per-task definition site ADR change 3 replaces ("`Consumes:`/`Produces:`
become references to Contracts, not definition sites"), it now straddles `Verify:`
in the field order, and it makes criterion 3 unscorable: a plan that fills `:67`
prose-style and omits `:64` cannot be judged. Fix: delete `:67-68` and keep one
field placed before `Verify:`.

**F2 (High) `docs/plan-format.md:71-99`, no section is marked mandatory or
conditional.** Walk the format for a small story (one script, three tasks, no
cross-plan sharing): `Design decisions` and `Success signal` fill naturally,
`Task order and parallelism` collapses to one line, and `Do-not-touch boundaries`
(greenfield) and sometimes `Contracts` (three tasks with no interface crossing a
boundary) have nothing to say. The document already knows how to mark this,
`:50` "(optional; omitted = standard)" for `Scrutiny`, and did not do it for the
new sections, so the format will produce empty headings, which `:106` ("No
placeholders") then reads as a failure either way. Fix: one line under
`## Structure`: "Every section is required; where a section has nothing, write
`none` plus one line of why (`Contracts: none, no interface crosses a task
boundary`). `Task order and parallelism` may be a single line (`sequential,
T1 -> T2 -> T3`)."

**F3 (High) `docs/plan-format.md:150-157`, criterion 3 is not consistently
scorable.** Three gaps: (a) "`Consumed by:` and the task-side `Consumes:` must
AGREE" does not say the sets must be equal, so a scorer can accept a one-sided
listing; (b) no level is assigned to a violation, and "An UNLABELED code block is
a failure here" can be read as 0 or as 1, which decides whether the plan is
blocked at all (threshold: no criterion at 0); (c) the 0 and 1 descriptors
("vague steps" / "mixed") were not updated, so the new conditions have no landing
place below 2. Fix: define agreement as "the tasks listed in `Consumed by:` are
exactly the tasks whose `Consumes:` names that entry", and add "a dangling
reference, a `Consumed by:` disagreement, or an UNLABELED code block caps this
criterion at 0".

**F4 (High) `docs/plan-format.md:143` + `agents/architecture-reviewer.md:12-20`,
the reference-graph check has no competent holder.** The rubric header says
"checked at the human gate", the human in this system is explicitly allowed to be
a non-engineer, and the ADR's own consequence list claims non-engineer legibility
only for `Design decisions` and `Success signal`. Criterion 3 nonetheless asks
that human to verify an N-task bidirectional reference graph by hand, while the
actor the ADR names as detector (change 14) has a plan-review mode that mentions
neither the plan rubric, nor resolution, nor the `illustrative-not-contract:`
label. Fix: add to `agents/architecture-reviewer.md` plan-review mode "check that
every `Consumes:`/`Produces:` resolves to a named Contracts entry, that
`Consumed by:` agrees with the task-side `Consumes:`, and that every code block
carries `illustrative-not-contract:`", and change `:143` to "checked by
`architecture-reviewer` during plan review and confirmed at the human gate".

### Important
**F5 (Medium) `docs/plan-format.md:120-126`, the snippet unit is undefined, so the
one-per-task cap is gameable by formatting.** Three probe cases: an `awk` program
with braces inside a shell script is correctly ALLOWED (`:126-128`, host language
is the shell, and "counts as ONE however many lines its syntax needs"); a 4-line
shell function body in a plan for a shell script is correctly FORBIDDEN (`:125`,
"no function bodies and no host-language block bodies"); but two separate regexes
in one task are NOT clearly forbidden, because an architect can put both inside a
single labelled fence and satisfy the letter of "at most ONE such snippet per
task". That is the same class the rule claims to have closed ("a line cap is
gameable by formatting", `:120-121`). Fix: "ONE snippet = one labelled fenced
block carrying ONE load-bearing expression; two expressions are two snippets even
inside one fence."

**F6 (Medium) `docs/plan-format.md:129`, the label's position is unspecified**
("The literal label `illustrative-not-contract:` on the snippet") while the rubric
fails an unlabeled block and the ADR calls the three conditions "all greppable".
Fix: "on the line immediately before the opening fence (or as the fence info
string), so `grep -B1` finds it".

**F7 (Medium) `docs/plan-format.md:47-99`, declaration after use.** `## Tasks`
precedes `## Design decisions` (`:71`) and `## Contracts` (`:75`), so a linear
reader meets `Consumes: C1` before C1 exists and meets the decisions meant to stop
guessing after the tasks that would guess. The practice the ADR cites as proof put
design decisions early (USR-003 `:37`, USR-004 `:32`) and the signal sections late.
Fix: move `Design decisions` and `Contracts` between `File map` and `Tasks`; leave
`Task order and parallelism`, `Success signal`, `Do-not-touch boundaries` and
`Risks` after.

**F8 (Medium) `docs/plan-format.md:38-39` vs `:98-99`, two plan-level homes for
do-not-touch.** Header `Constraints:` still says "copied verbatim from the
spec/story + do-not-touch boundaries that apply, from docs/codebase-map.md" and
the new section repeats the job, with no statement of which is authoritative, while
the ENFORCED source is `docs/codebase-map.md` (`bin/boundary-check.sh:6-7,20,33`).
A second copy of the truth inside the document that forbids second copies. Fix:
trim `Constraints:` to spec constraints and add "boundaries live in
`## Do-not-touch boundaries`, derived from `docs/codebase-map.md`, which remains
the enforced source".

**F9 (Medium) `docs/plan-format.md:75-88`, fill one Contracts entry.** The hardest
new construct ships without a single worked instance, and `:65` already promises
one. Fix, staying on the doc's existing Invoice thread and inline/generic per ADR
change 3:
```
### C1: Invoice
- Kind: type
- Declaration: `type Invoice = { id: string; customerId: string; cents: number; issuedAt: string }`
- Produced by: Task 1
- Consumed by: Task 2, Task 3
- Invariants: `cents` is a non-negative integer in minor units; `issuedAt` is UTC
  ISO-8601; an issued invoice is never mutated, a correction is a new invoice
```
Add one labelled-snippet example under Rules in the same pass (it also closes F6
by showing the placement).

### Minor
**F10 (Low) `docs/plan-format.md:80-82`, the C1 shape fits the repo's interface
kinds with two wording gaps.** Test: writing the real contract for
`bin/language-status.sh` (one stdout line `<code> <scope>`, exit 0 on success and
2 on usage error) forces a choice the template does not make, one entry with two
kinds or two entries, and `Declaration: <the exact thing, verbatim>` has no
verbatim referent for an exit contract. The five fields otherwise fit all four
kinds this repo produces (shell exit contract, stdout format, file-line format,
CLI flag set), and `Invariants:` is where the resolver-is-the-only-source rule
lands cleanly. Fix: "one `Kind:` per entry (an artifact with both a stdout format
and an exit contract gets two entries); `Declaration:` is verbatim for
type/signature/format kinds and an exhaustive enumeration for an exit contract
(`0 = status on stdout; 2 = usage error, nothing on stdout`)."

**F11 (Low) `docs/plan-format.md:8,115` and `docs/skill-authoring-standard.md:49`,
a public file instructs the reader to see an internal document.** Both files are
on the publish allowlist (`docs/public-paths.txt:43,46`) while
`docs/internal-paths.txt:34` classifies `docs/decisions/` internal, so "see the
Implement field and ADR-001" dangles in the snapshot. The rules themselves are
self-sufficient, so the fix is cosmetic: write "(ADR-001, internal decision
record)" or drop the "see" instruction at `:8`.

**F12 (Low) `docs/skill-authoring-standard.md:71`, the replacement row cites an
internal story ID in a public file** ("USR-004's frozen append tail carried a
false-success bug"), and its right cell is three clauses against the file's own
"One line each" (`:60`). The ADR prescribed this wording (change 11) and the
observed-evidence requirement (`:63-65`) is met, so this is presentation only; the
claim survives rephrasing: "a frozen append tail in this repo's history reported
exit 0 with nothing written".

## ADR-001 change-table conformance (the three sites in scope)
| # | Site | Status |
|---|---|---|
| 1 | Implement field + snippet exception | met (`:57-63` behavior/invariants/no code, conditions at `:120-133`), weakened by F5 and F6 |
| 2 | reframe "complete code does not waive test-first" | met, `:115-119`, replaced not reworded |
| 3 | five sections + Consumes/Produces become references + inline generic examples | PARTIAL: sections present, examples inline and generic with no denylisted path, but the old definition-site fields survive (F1), no optionality convention (F2), no worked entry (F9) |
| 4 | criterion 3 resolution clause | present with the required placeholder citation form (`<plan-file> C<n>`), not consistently scorable (F3), unheld (F4) |
| 5 | criterion 1 equivalence definition | met, `:145-148`, "TWO competent builders would produce functionally equivalent code" |
| 6 | define what "exactly" binds, plan-format + build SKILL | met at all three sites (`docs/plan-format.md:5-8`, `skills/build/SKILL.md:30-31,98-100`) |
| 11 | skill-authoring-standard row REPLACED | met, and the replacement is an observed shortcut, so `:63-65` is respected; F12 is presentation |
| 12 | privacy-scan principle scoped | met, `docs/skill-authoring-standard.md:45-49`, "different domains, both single-source" |

Coordinated sites outside this diff were spot-checked and agree: `agents/architect.md:10-11,43-50,70-72`,
`agents/builder.md:52-61,93-96`, `agents/code-reviewer.md:36`, `docs/internal-paths.txt:31-34`,
`AGENTS.md:165-170`. No contradiction found between them and the three files reviewed.

## skills/build/SKILL.md (the smallest change, and it is clean)
`:30-31` ("a builder agent builds to that plan's contract in its own worktree")
and `:98-100` ("holds the plan's contract exactly: signatures, behavior,
invariants, tests, verify, boundaries; the implementation within it is the
builder's") match `docs/plan-format.md:5-8` and `agents/builder.md:52-61`. The
description, the gates (spec gate, plan gate, `boundary-check.sh`, merge) and the
worked example are untouched, and the file stays under the size limit (239 lines).
Nothing here needs reverting; the CHANGES-REQUIRED verdict is driven by
`docs/plan-format.md`. Its own record (`docs/evals/skill-build.md`, v5, 10/10) is
now one version stale and should be refreshed in the same pass that closes F1-F4.

## House style
No em or en dashes and no non-Latin characters in any of the three files (grep,
zero matches each). English throughout. No versions, dates or "currently" added.
The new sections reference no denylisted `docs/plans/` file, which ADR change 3
required, and the cross-plan example uses the placeholder form `<plan-file> C1
(Invoice)`, matching `:13`.

## Map duty
No command surface added or altered (a format spec plus two wordings), so no
`docs/system-map.md` delta is required. `docs/system-map.md:77` ("`builder`
(executes the approved plan, own worktree)") does not carry the "exactly" wording
ADR change 6 targeted, so it is not stale. Not a finding.

## Round-by-round
- Round 1 (2026-08-04, Opus 5 (1M), strongest): 6/10 CHANGES-REQUIRED. Four
  blocking findings, all in `docs/plan-format.md`: a leftover duplicate
  `Consumes:`/`Produces:` pair that contradicts the change it implements, no
  mandatory/conditional convention for the five new sections (small stories will
  produce empty headings), a criterion 3 that two scorers can score differently,
  and a reference-graph check assigned to a non-engineer gate with no reviewer
  support. Five Medium, three Low.

## Vs previous version
No prior record for `docs/plan-format.md`, so no regression baseline; this is
artifact_version 1 of this record. The nearest neighbour,
`docs/evals/skill-build.md` v5 (10/10 PASS), covers a file also touched here and
is unaffected by these findings.

## History
- Round 1 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high): 6/10
  CHANGES-REQUIRED, record created.

Note: this is a FORM review. The producibility and scorability failures above are
readable in the file and do not need runtime evidence. Once F1-F4 are closed, the
remaining risk is behavioral (does the architect actually declare contracts once
and reference them, and does the plan reviewer catch a dangling reference), which
is an `/improve` subagent test, not a form review.
