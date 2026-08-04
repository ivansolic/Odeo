---
artifact: architecture-reviewer
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 2
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 1, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 1 }
total: 8/10
verdict: PASS
previous_total: 10/10 (set-level, docs/evals/agent-set-model-policy.md, different scope)
---

# Agent: architecture-reviewer (first per-file review, at HEAD f8f8da6)

Scored `agents/architecture-reviewer.md` against `agents/agent-rubric.md`, cross-checked
against `AGENTS.md` (Guardrails 1, 3 and 5) and `docs/plan-format.md` (structure + plan
rubric criterion 3).

Scope note: reviewed as a FOURTH file this round because its plan-review mode was
materially changed on this branch (the reference-graph and label checks, plus being named
as the detector for the cross-plan approval rule). `artifact_version: 2` = the second
state of this file, the first that has ever been scored per-file.

Method note: no Bash in this reviewer's grant; scored the file as it stands at HEAD.

## Scores

- **trigger/description clarity: 1** , `:3` states what ("Architectural review by a staff
  engineer ... Evaluates module boundaries, data flow, failure modes, and 2-year
  maintainability") and a when ("Invoke when making architectural decisions, adding major
  features, or before big refactors"), and "Read-only analysis, produces recommendations,
  never edits code" is a clean capability boundary. Two gaps hold it at 1: the description
  never mentions PLAN REVIEW, which is now a first-class dispatched mode
  (`skills/build/SKILL.md:156` dispatches it in the plan-review loop) and the mode that
  carries a guardrail duty; and there is no not-for lane (what belongs to `code-reviewer`
  versus this agent). The rubric's 2 requires what it does AND when AND the scope boundary.

- **tool least-privilege: 2** , `tools: Read, Grep, Glob` (`:4`) is exactly the read-only
  set AGENTS.md:264 requires, with no Write even though the agent produces a verdict, and
  the body closes that loop instead of assuming it: "You cannot write files; the
  orchestrating session records your verdict in the plan's `arch_review:` frontmatter"
  (`:27-28`). Correctly NOT on the Write-holding list in AGENTS.md:265-267, since its
  outcome is recorded by the session rather than in its own eval record. Nothing exceeds
  the role.

- **role boundary: 2** , one job (architecture judgment) applied to two artifact kinds,
  code-in-place and a plan, with the plan mode explicitly scoped to what only it can see
  ("**Also check what only you can check**", `:17`) and to review, not authorship
  ("findings move only by plan revisions", `:25-26`). It does not take the architect's job
  (it never proposes the plan text) and does not take the human's ("You are also the
  detector", not the holder; AGENTS.md:169-170 keeps the holder at the orchestrating
  session). Re-review discipline is stated ("verify each prior finding resolved and say
  so", `:24-25`).

- **policy conformance: 2** , `effort: high` declared from the allowed set, no `model:`
  line so judgment inherits the session (AGENTS.md:41-42), no version-pinned id (C11
  clean), no `isolation:` which is correct for a role that mutates nothing, tools match
  Guardrails 5. The plan-review mode cites its authorities correctly: `docs/plan-format.md`
  rubric criterion 3 (`:17`) and AGENTS.md Guardrails 1 (`:22-23`).

- **instruction quality: 1** , the general review contract is strong and specific (six
  named question sets, an exact output block, a PROCEED/PROCEED WITH MODIFICATIONS/
  RECONSIDER recommendation, "Be concrete. 'This coupling will hurt' is useless. Say
  where, why, what breaks, and when", `:105`). Three defects in the newly added plan-review
  mode cost the point, all of them specification gaps rather than vagueness: a duty it
  cannot fully discharge with its tools, an incomplete restatement of the rubric clause it
  cites, and two competing output shapes with no precedence. All three are detailed below.

## Total: 8/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable
No criterion structurally caps this agent. Criterion 1 needs two clauses in `:3` (the
plan-review mode and a not-for lane); criterion 5 needs the detector duty scoped to the
tool grant, two rubric clauses added, and one sentence saying which output shape applies
in plan mode.

## Findings

- **Important, `:22-24`, half of the detector duty is beyond this agent's tools** , it is
  told to "flag a reference into a plan outside this batch, or into one revised since it
  was approved". The first half is checkable with Read/Grep (read the referenced plan's
  frontmatter). The second is not: "revised since it was approved" is a fact about git
  history, and this agent has no Bash, no git, and no view of approval timestamps. The plan
  format offers no revision marker it could use either, `arch_review: clean (vN, date)`
  versions the REVIEW, not the post-approval revision. So a duty AGENTS.md:169-170 assigns
  here is, in its most important half (the one that invalidates a consumer's approval),
  undischargeable as written. Two concrete fixes, either works:
  (a) scope the duty to what the tools can see, "flag a reference into a plan that is not
  in this batch, or whose `approved:` is not `yes`, or whose `arch_review:` version differs
  from the version the reference cites", and leave revision-after-approval detection with
  the holder (the orchestrating session, which has git); or
  (b) make it readable, require cross-plan references to cite the approved version
  (`<plan-file> C<n> @v<N>`) so a mismatch is visible in the plan text alone.
  Note this is the second time this duty has needed a home: round 1 removed it from
  `architect` because that agent could not discharge it either. Landing it here is right on
  the merits (this agent does read the plans), but the tool-limited half still needs the
  holder.
- **Important, `:17-22`, the enumeration of "what only you can check" drops two clauses of
  the rubric criterion it cites** , `docs/plan-format.md:169-176` criterion 3 requires,
  besides the three checks listed, that "every Contracts entry names its producing task"
  and that "the Success signal row count equals the story's criterion count". Neither
  appears here, and the success-signal count is exactly the mechanical completeness check a
  plan reviewer is the last line for (the builder will not notice a missing acceptance
  criterion; it executes the tasks it was given). This is the same defect class that was
  just fixed in `agents/architect.md:33-39` (a partial restatement of a referenced spec),
  so consistency argues for the same treatment. Fix: add both clauses, and add the
  precedence marker "(that rubric is canonical; if this list differs, it wins)".
- **Minor, `:15-16` against `:70-101`, two output shapes with no precedence** , plan-review
  mode says "Return findings ranked blocking / important / note, or state 'clean'
  explicitly", while the Output Format section says unconditionally "Return your review in
  this structure" with `## Concerns` and a PROCEED/RECONSIDER recommendation. The
  plan-mode vocabulary is the one the pipeline consumes (`skills/build/SKILL.md:162-165`
  records `arch_review: clean (v<N>, <date>)` and presents "v1: 2 blocking findings -> v2:
  1 -> v3: clean"), so the ambiguity is resolvable but unresolved in the file. Fix: one
  sentence in the mode block, "in this mode the ranked blocking / important / note list
  plus an explicit `clean` REPLACES the Output Format below".
- **Note, not scored, `:12-28`** , this agent is the natural plan-time detector for the
  new-UI-surface design-wiring requirement (AGENTS.md:241-243, currently guarded at plan
  time only by the architect's own `agents/architect.md:57-63` and caught late by
  `design-reviewer`'s tokens dimension). Adding it to the plan-review checklist would close
  the gap earlier. Role-design suggestion, outside the rubric.

## Integrity
House voice, consistent with the sibling reviewers; the plan-review block matches the
vocabulary used in `agents/architect.md` and `docs/plan-format.md`. Nothing reads as copied
from another project.

## Vs previous version
No prior per-file record. `docs/evals/agent-set-model-policy.md` (2026-07-24) covered this
file inside an eight-agent SET at 10/10, judging only the model-policy frontmatter axis
(it quotes this file's description for the read-only claim and its tools line against
guardrail 5, nothing else), so 10/10 set-level -> 8/10 per-file is a change of scope and of
axis, not a measured regression. Round 1 for this file; the plan-review mode being scored
here did not exist in a comparable form at that record's date.

## History
- 2026-08-04 v2 (f8f8da6): first per-file review, after the plan-review mode gained the
  reference-graph and label checks and the Guardrails-1 detector duty. Round 1 = 8/10 PASS,
  two Important open (undischargeable half of the detector duty, incomplete criterion-3
  enumeration).
