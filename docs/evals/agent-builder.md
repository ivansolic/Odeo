---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: 995fde4
artifact_version: 8
date: 2026-08-07
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

# Agent: builder (round 7, at 995fde4)

Form check, not a new cycle: the file was already 10/10 at `76188a6` and the only change here is
the step-1 edit this reviewer recommended. Verified as applied, verified against the four
sibling files that moved in the same commit, and re-anchored to this commit so the merge gate's
content check matches what merges. Score held at 10/10. One Minor and three Nits remain open,
all cosmetic or citation-level; nothing blocks the human gate.

Version note: `artifact_version: 8` (v2 = aee5ab1, v3 = f8f8da6, v4 = f4e295a, v5 = 5b46abd,
v6 = a2eec03, v7 = 76188a6, v8 = 995fde4). Step 1 grew by one line, so v7 citations after `:39`
sit one line lower here.

Method note: no Bash in this reviewer's grant, so no `git show`. Scored the file as it stands at
the supplied `reviewed_commit`, cross-checked against `AGENTS.md`, `docs/plan-format.md`,
`docs/eval-framework.md`, `skills/build/SKILL.md`, `bin/merge-gate.sh`.

## Scores (all held)

- **trigger/description clarity: 2** , `:3` unchanged: what, when dispatched, and the refusal
  condition ("Requires the plan; without an approved plan it does not build").
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), all
  exercised, fenced by `isolation: worktree` (`:7`), "One story, one worktree, never merge"
  (`:123`) and "Never edit the plan" (`:122`).
- **role boundary: 2** , `:116-122` keeps the WHEN decision with the human, states the three
  rules the builder owns, and closes both write paths it could otherwise reach.
- **policy conformance: 2** , frontmatter untouched: `model: sonnet` (`:5`) from the allowed
  set, `effort: high` (C12), `isolation: worktree`. Grepped clean: no version-pinned model name
  (C11), no em or en dash. Now matches the reworded `AGENTS.md` model policy on every point
  (below).
- **instruction quality: 2** , held, and the round-6 Minor that was the last structural item is
  CLOSED: the file has exactly one enumeration of the plan preconditions.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Open items are one Minor and three Nits, listed below so a 10 hides nothing.

## Round-by-round
Round 1 (aee5ab1): 9/10, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10, 3 Minor open.
Round 3 (f4e295a): 10/10, 2 Minors closed, 1 carried.
Round 4 (5b46abd): 9/10, instruction_quality 2 -> 1 (ownerless, unverifiable `model_plan:` duty).
Round 5 (a2eec03): 9/10, that Important closed, held at 1 on the stale precondition list.
Round 6 (76188a6): 10/10, instruction_quality 1 -> 2; one Minor left (duplicate enumeration).
Round 7 (995fde4): 10/10 PASS, held. That Minor CLOSED. Two consecutive rounds at max, and the
first round in this sequence with no structural item open.

## (a) The step-1 edit is what I meant, and the lists no longer differ
`:39-41` now reads "**Verify the contract**: every precondition in *Inputs you require* above is
satisfied, and the plan covers THIS story. Ask any clarification questions NOW, never guess
mid-build." That is the pointing form, not the adding form:
- ONE enumeration of the preconditions, at `:17-27` (`approved: yes`, `builder_tier:` present,
  `arch_review:` not `pending`), which is also the one place that cites
  `docs/plan-format.md` and disarms the non-refusal case.
- Step 1 keeps only what is genuinely its own: this-story scope, and ask-now-not-mid-build.
- The next `model_plan:` format change touches one place in this file. That was the whole point:
  the four-way binding-list drift of round 1 cost two cycles, and this file's own precedent
  (`:56-59`, `:104-106`, both deferring to `docs/plan-format.md`) is cite-one-home.
The word "above" is a small improvement over my proposed wording: it makes the reference
directional in a file that is read top-to-bottom by an agent loading its own instructions.

## (b) Read-through check on the four sibling changes: nothing in this file is stale
- **`AGENTS.md` heading, now "Model policy (judgment inherits, execution defaults to sonnet)"**
  (`AGENTS.md:40`) , agrees with `:114` ("a DEFAULT, not a ceiling"). The prior "rides sonnet"
  phrasing was the last place the pinned reading survived; with it gone, no sibling contradicts
  this file's default-not-pin framing.
- **`AGENTS.md` no longer claims resolved names live in plans unqualified** (`AGENTS.md:70-74`:
  "A plan carries a resolved name for JUDGMENT only; the build model appears there as a TIER
  WORD, and its resolved name lives in the eval record") , this is exactly what `:19-21` tells
  the builder ("the resolved model NAME is recorded after dispatch by your dispatcher, in the
  eval record"). `AGENTS.md:55-57` says the same in the model-policy bullet. Three files, one
  claim.
- **`docs/plan-format.md:25-30`, `judgment:` is a plan-time snapshot never corrected after the
  gate** , does not read through: this file requires only `builder_tier:` from the block
  (`:18`) and never asks the builder to read, check or refresh `judgment:`. The immutability
  rationale ("A post-gate plan edit refuses the merge") is the same fact that put provenance in
  the eval record, and it reinforces `:122` "Never edit the plan" rather than straining it.
- **`skills/build/SKILL.md:204-208`, hand the build model to `code-reviewer` on EVERY
  dispatch** , correct and invisible to this file: it is an orchestrator duty, and the reason
  given (the review loop REGENERATES the record, so a later round would drop the field and the
  surviving record is the one the merge gate reads) is a real failure mode I can confirm from
  the gate's shape at `bin/merge-gate.sh:294`, which reads the record present at merge time. No
  new builder obligation, so `:119-120` ("you neither write nor verify those fields") stands.
- **Field-shape agreement re-checked**: `:18` requires "a tier word plus effort", and
  `docs/plan-format.md:31` is `builder_tier: <tier word> effort <level>`. Match.

## Open (all carried, none blocking)
- **Minor, carried from round 3, `:10` and `:39`** , "executing its APPROVED plan exactly" and
  "never guess mid-build" still precede any pointer to 5b, so a reader meets the unqualified
  form ~46 lines before its qualification. Mitigated by `:126-127`. Fix at `:10`: "what
  'exactly' binds is in step 5b". Note the step-1 rewrite slightly IMPROVES this: step 1 no
  longer re-lists checks, so 5b is proportionally more prominent in the pipeline it belongs to.
- **Nit, `:119-120`** , "`/build` records what it dispatched you on in the eval record"; the
  writer is `code-reviewer`, from a value the orchestrator hands it
  (`skills/build/SKILL.md:204-206`). Immaterial, the builder is forbidden to write or verify it
  in the same sentence.
- **Nit, `:59-61` and `:106-107`** , insertions still leave short half-lines mid-sentence;
  rewrap both paragraphs.
- **Nit, `:17-24`** , the Inputs bullet is a ~100-word sentence with nested parentheses; the
  content is right, but a sub-bullet per precondition would make the three countable at a glance.
  Worth doing only if that bullet is edited again for another reason.

## Out of scope, for the coordinator
`skills/build/SKILL.md:198-199` still says "No builder runs without an approved plan that carries
an `arch_review:` line, **both** are the builder's contract preconditions", i.e. two, while
`docs/plan-format.md:32-33` says the builder's contract also requires `builder_tier:` and this
file now requires three. Nothing in `agents/builder.md` is wrong (it is the fuller and correct
list), so it does not touch these scores; but it is the same duplicate-enumeration class we just
closed inside this file, now living across two files. `skill-reviewer` owns that file.

## Integrity
House voice, consistent with `agents/architect.md` and the sibling agents. No imported text; all
overlap with siblings is by citation.

## Vs previous version
10/10 -> 10/10, held, with the last structural Minor closed and no regression. The file is in its
best state across seven rounds: one home per rule, every model-policy claim matching `AGENTS.md`
and `docs/plan-format.md` word for word, and every remaining item cosmetic. Clean for the human
gate.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; 3 Minors.
- 2026-08-04 v4 (f4e295a): materiality rewording + binding-list citation closed. Round 3 =
  10/10 PASS, held.
- 2026-08-06 v5 (5b46abd): rewritten model bullet. Round 4 = 9/10 PASS; instruction_quality
  2 -> 1 for an ownerless, unverifiable `model_plan:` duty; AGENTS.md "pinned" drift logged.
- 2026-08-06 v6 (a2eec03): all three round-4 findings closed; held at 1 on a new defect, the
  precondition list still describing the one-field `model_plan:`. Round 5 = 9/10 PASS.
- 2026-08-06 v7 (76188a6): precondition list names `builder_tier:`, cites the format and
  disarms the false-refusal path; report destinations disambiguated. Provenance relocation
  verified against `bin/merge-gate.sh:294` and `docs/eval-framework.md:67-76`. Round 6 = 10/10
  PASS, instruction_quality 1 -> 2; recommended step 1 POINT at the Inputs list.
- 2026-08-07 v8 (995fde4): that recommendation applied at `:39-41`, so the file carries one
  enumeration of the preconditions and step 1 keeps only its own two checks. Round-6 Minor
  CLOSED. Read-through check against the four sibling files changed in the same commit (AGENTS.md
  heading and resolved-name qualification, `judgment:` as a plan-time snapshot, the
  every-dispatch handover) found nothing stale in this file. Round 7 = 10/10 PASS, held.
