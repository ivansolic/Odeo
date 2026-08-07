---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: 76188a6
artifact_version: 7
date: 2026-08-06
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

# Agent: builder (round 6, at 76188a6)

Re-review after the second fix pass. The round-5 Important is CLOSED, both smaller items are
CLOSED, and the provenance relocation (resolved model name out of the plan, into the code eval
record) is verified against the gate that forced it. Nothing in this file is now false,
unactionable, or unowned. Two Minors and three Nits remain open, all of the maintenance class;
none blocks the human gate.

Version note: `artifact_version: 7` (v2 = aee5ab1, v3 = f8f8da6, v4 = f4e295a, v5 = 5b46abd,
v6 = a2eec03, v7 = 76188a6). Line numbers in this record are at v7; the file grew by three
lines, so earlier records' citations sit three lines lower here.

Method note: no Bash in this reviewer's grant, so no `git show`. Scored the file as it stands at
the supplied `reviewed_commit`, cross-checked against `AGENTS.md`, `docs/plan-format.md`,
`docs/eval-framework.md`, `docs/invariants.md`, `skills/build/SKILL.md`, `bin/merge-gate.sh`.

## Scores

- **trigger/description clarity: 2** , `:3` unchanged: what, when dispatched, and the refusal
  condition ("Requires the plan; without an approved plan it does not build").
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), every member
  exercised by the pipeline, contained by `isolation: worktree` (`:7`), "One story, one worktree,
  never merge" (`:122`) and "Never edit the plan" (`:121`). The write grant now has an explicit
  fence on both artifacts it could reach and should not: the plan, and the record.
- **role boundary: 2** , `:115-121` keeps the WHEN decision with the human ("never yours"),
  states the three rules the builder owns, and closes both write paths ("you neither write nor
  verify those fields", "Never edit the plan").
- **policy conformance: 2** , frontmatter untouched: `model: sonnet` (`:5`) from the allowed
  sonnet/inherit set, `effort: high` (C12), `isolation: worktree` on the one role that mutates
  files in parallel. Grepped clean: no version-pinned model name (C11), no em or en dash.
  Consistent with `AGENTS.md:52-59` (DEFAULT, rebuttable) and `AGENTS.md:262-266` ([E] file
  value / [I] run model).
- **instruction quality: 2** , restored. The two defects that held this at 1 are gone: the
  precondition list now names the field the canonical format names and explicitly disarms the
  refusal path, and the model bullet's report destinations no longer overlap. What remains is
  duplication risk between two enumerations of the same gate (`:17-27` and `:39`), which is a
  Minor of the class that coexisted with 10/10 in rounds 2 and 3, not a correctness defect.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Every criterion at its described top level. Open items below are Minors and Nits; they are
listed so nobody has to wonder what a 10 is hiding.

## Round-by-round
Round 1 (aee5ab1): 9/10, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10, 3 Minor open.
Round 3 (f4e295a): 10/10, 2 Minors closed, 1 carried.
Round 4 (5b46abd): 9/10, instruction_quality 2 -> 1 (ownerless, unverifiable `model_plan:` duty).
Round 5 (a2eec03): 9/10, that Important closed, 1 -> 1 held on a new defect (stale precondition
list after the two-field `model_plan:` split).
Round 6 (76188a6): 10/10 PASS. instruction_quality 1 -> 2. Both point-holding defects closed;
no regression anywhere; nothing false left in the file.

## Closures verified

- **CLOSED (was Important), the stale precondition list.** `:17-21` now reads "a `model_plan:`
  block whose `builder_tier:` line is present (a tier word plus effort, the APPROVED INTENT, per
  `docs/plan-format.md`; the resolved model NAME is recorded after dispatch by your dispatcher,
  in the eval record, so its absence here is never a missing precondition and never a reason to
  refuse)". Three fixes in one sentence: it names the field by the name the canonical format uses
  (`docs/plan-format.md:26-28`), it cites rather than restates, and it disarms the false-refusal
  path against `:25` ("**No approved, review-carrying plan = do not build.**") in the file's own
  words instead of leaving a literal reader to infer it. The requirement `plan-format.md:27-28`
  advertises ("the builder's contract requires THIS line") now has a stated home in this file.
- **CLOSED (was Minor), two report rules claiming one observation.** `:119-121` now routes the
  observation: "note it under decisions in your report, NEVER in your contract-deviation list,
  and keep building." That matches the report sections it points at (`:103-107` contract
  adherence, `:108-109` decisions) and cannot be read two ways any more.
- **CLOSED (was Nit), "that line" singular.** `:119` is now "those fields".

## The provenance relocation (checked, not taken on faith)
`bin/merge-gate.sh:294` is `git diff --quiet "$reviewed" HEAD -- . ':(exclude)docs/evals'`, so
`docs/plans/` IS inside the compared set and `docs/evals/` IS excluded. The rationale is
therefore correct as stated: writing the resolved model back into the plan after the review
would refuse the merge with "code changed after the reviewed commit" and force a full code
re-review for one provenance line. The chosen destination is the one path the comparison
excludes by construction. `docs/eval-framework.md:67-76` defines the field, assigns it to CODE
records after a for-me build, and carries the honesty guard "Omit it when you were given no
value; never guess one", which is the same never-fabricate shape as the `reviewed_commit:` rule
this reviewer works under. `docs/plan-format.md:30-40` keeps the plan immutable after the gate
and does not migrate prior plans ("records of what was"). `skills/build/SKILL.md:197-203` hands
the resolved name to `code-reviewer` and forbids the write-back. The chain is consistent and no
new refusal path was created: the field is optional, so a missing value cannot fail a gate.

## Answers to the three questions asked

**(b) Inputs list vs Pipeline step 1: acceptable, but fix it by pointing, not by adding.**
Neither list is false now, so this is a Minor, not the three-statements problem. `:17-27`
enumerates three preconditions (`approved: yes`, `builder_tier:` present, `arch_review:` not
pending); `:39` enumerates four checks (plan exists, `approved: yes`, `arch_review:` not
pending, covers this story) and omits `builder_tier:`. Two overlapping enumerations of the same
gate in one file is exactly the shape that drifted four ways in round 1 and cost two cycles to
close. This file already settled the pattern for that: cite one home and mark precedence
(`:55-58` and `:103-105` both defer to `docs/plan-format.md`, "that file wins if this differs").
So: make step 1 point, do not add a fourth item. Concretely, replace `:39` with "**Verify the
contract**: every precondition in *Inputs you require* is satisfied, and the plan covers THIS
story. Ask any clarification questions NOW, never guess mid-build." That leaves ONE enumeration
plus the two things genuinely step 1's own (this-story scope, ask-now), and the next format
change touches one place. Adding `builder_tier:` to step 1 also works and is not wrong; it just
buys a permanent re-sync obligation for no reader benefit.

**(c) Pointing the builder at "the eval record": right, with one wording Nit.** The operative
clause is "its absence here is never a missing precondition and never a reason to refuse", which
is fully actionable without the builder ever opening a record. Naming the destination earns its
place for two reasons: it explains WHY the value is missing from the contract the builder is
reading (otherwise a careful builder hunts for it, which is the behaviour that produced the
round-5 false-refusal path), and it makes the prohibition at `:118-119` concrete rather than
abstract. The builder is also not a stranger to that artifact's author: `code-reviewer` runs on
its result and it consumes the findings (`:93-97`). Nit: `:118-119` says "`/build` records what
it dispatched you on in the eval record", while the actual writer is `code-reviewer` from a
value the orchestrator hands it (`skills/build/SKILL.md:199-200`). Immaterial to the builder,
which is forbidden to write or verify it in the same breath, but "your dispatcher hands it to
`code-reviewer`, which records it" would be exact.

**(d) Scores:** 2/2/2/2/2 = 10/10, PASS. instruction_quality 1 -> 2.

## Open (all Minor or Nit, none blocking)
- **Minor, `:17-27` and `:39`** , the duplicate precondition enumeration described in (b).
- **Minor, carried from round 3, `:10` and `:39`** , "executing its APPROVED plan exactly" and
  "never guess mid-build" still precede any pointer to 5b, so a reader meets the unqualified
  form ~45 lines before its qualification. Mitigated by `:125-126`. Fix at `:10`: "what
  'exactly' binds is in step 5b".
- **Nit, carried, `:58-60` and `:105-106`** , insertions still leave short half-lines
  mid-sentence ("choose the / implementation, and / choose it well"; "boundaries), of which /
  there should be none"); rewrap both paragraphs.
- **Nit, `:118-119`** , the writer of `build_model_as_dispatched:` is `code-reviewer`, not
  `/build` directly, per (c).
- **Nit, `:17-24`** , the Inputs bullet is now a 100-word sentence with nested parentheses; the
  content is right, but splitting the `builder_tier:` clause into its own sub-bullet would make
  the three preconditions countable at a glance.

## Did anything get lost this time
No. The bullet's only semantic change is the record's location (`model_plan:` -> the eval
record), which the gate evidence above shows is a correctness fix, not a loss. Every operative
rule the builder had at v6 survives verbatim in effect: never change the dispatched model,
running above the tier is not a deviation, never write or verify the provenance field, note a
visible mismatch and keep building, never edit the plan.

## Integrity
House voice, consistent with `agents/architect.md` and the sibling agents. No imported text; all
overlap with sibling files is by citation, and the one place that formerly restated a sibling's
rule now cites it.

## Vs previous version
9/10 -> 10/10. The precondition list stopped describing a format that no longer exists and
stopped implying a refusal it should never make; the report destinations were disambiguated; the
plural was fixed. No criterion moved down. This is the highest state this file has been in: the
two earlier 10/10 rounds carried three and one open Minors respectively against a policy that
has since been made more precise around it.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; the 5b
  qualifications landed; 3 Minors open.
- 2026-08-04 v4 (f4e295a): scoped re-review of the materiality rewording and the binding-list
  citation, both closed. Round 3 = 10/10 PASS, held.
- 2026-08-06 v5 (5b46abd): scoped re-review of the rewritten model bullet. Round 4 = 9/10 PASS;
  instruction_quality 2 -> 1 for an ownerless, unverifiable `model_plan:` duty; AGENTS.md
  "pinned" drift logged as a cross-file Minor.
- 2026-08-06 v6 (a2eec03): all three round-4 findings closed; instruction_quality held at 1 on a
  NEW defect, the precondition list still describing the one-field `model_plan:`. Round 5 = 9/10
  PASS.
- 2026-08-06 v7 (76188a6): precondition list now names `builder_tier:`, cites
  `docs/plan-format.md` and disarms the false-refusal path; report destinations disambiguated;
  "those fields" plural. Provenance relocation to the eval record verified against
  `bin/merge-gate.sh:294` (`docs/plans/` compared, `docs/evals/` excluded) and
  `docs/eval-framework.md:67-76` (optional field, "never guess one"). Round 6 = 10/10 PASS,
  instruction_quality 1 -> 2. Recommendation on the last open choice: step 1 should POINT at the
  Inputs list rather than re-list, per this file's cite-one-home precedent.
