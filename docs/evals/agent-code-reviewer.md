---
artifact: code-reviewer
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

# Agent: code-reviewer (post ADR-001, contract-adherence duty)

Scored `agents/code-reviewer.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 3, 5 and 6) and ADR-001 change 10.

Method note: no Bash tool in this reviewer's grant, so `git show aee5ab1` could not be
run. Scored the file as it stands against the ADR change list.

## Scores

- **trigger/description clarity: 1** , `:3` states what ("Adversarial code review by a
  senior staff engineer") and when ("Invoke after implementing any non-trivial change,
  before considering the task complete"), but carries NO not-for lane, which the rubric
  requires for a 2. Its siblings do have one (`pm-reviewer`: "Documents only; code goes
  to code-reviewer, UI to design-reviewer, skills to skill-reviewer", quoted in
  `docs/evals/agent-set-model-policy.md:35-36`). Pre-existing, not caused by this commit,
  and newly visible because this is the first per-file scoring.

- **tool least-privilege: 2** , `tools: Read, Grep, Glob, Bash, Write` (`:4`). Every
  grant maps to a documented step: Read/Grep/Glob for review, Bash for scoping the diff
  ("Recent git diff (`git diff`, `git diff main`, or `git log -p -n 1`)", `:13`) and for
  the narrowly permitted focused test (`:24-26`), Write for the record it owns ("write
  the record to `docs/evals/code-<branch-or-story-id>.md`", `:118`). No Edit, so it has
  no in-place affordance on the code it judges. Nothing exceeds the role.

- **role boundary: 2** , the new duty is the boundary risk of change 10 and it stays in
  lane: it checks SHIPPED CODE against the plan's contract, and does not drift into
  judging whether the contract is complete, which belongs to `architecture-reviewer`
  during plan review. It also self-limits rather than expanding scope: "if heavy
  validation seems warranted, recommend it instead of running it" (`:26`) and "If scope
  is unclear (what changed?), ask the user before reviewing" (`:146`).

- **policy conformance: 2** , `effort: high` declared, no `model:` line so judgment
  inherits the session per AGENTS.md:41-42, no version-pinned id (C11 clean), and the
  provenance rules are spelled out in full: `model:` plus `model_tier:`, "Gates refuse
  records without `model_tier:`, and refuse fast-tier judgment without an explicit
  `model_waiver: human` line" (`:133-137`), plus the single-verdict-line rule and "Only
  you, the reviewer, ever write or change a verdict" (`:126-132`). The one blemish, that
  AGENTS.md:264 calls all reviewers read-only while this one legitimately carries Write
  and Bash, is a defect in the AGENTS.md wording rather than in this file; the prior
  record examined the same fact and accepted it, so re-scoring it here would be score
  drift. Recorded as a finding against AGENTS.md instead.

- **instruction quality: 1** , the file is otherwise a thick, precise contract (process,
  budget, six dimensions, rubric, exact output block, record rules, rules for yourself),
  and the new duty is specific about WHAT to compare and includes both disambiguating
  cases: "An invariant the plan states and the code does not hold is a finding even when
  every test passes; an implementation that differs from a snippet labelled
  `illustrative-not-contract:` is NOT a finding" (`:36-39`). The point is lost on an
  unresolved tension with the budget the duty sits inside, plus two smaller wording
  defects (below).

## Total: 8/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable in this file
No structural cap. Criterion 1 needs one clause in `:3`; criterion 5 needs one clause in
the new bullet plus two wording repairs. The AGENTS.md:264 wording fix lands in
AGENTS.md, not here, and does not affect this file's ceiling.

## Findings

- **Important, `agents/code-reviewer.md:34-39` against `:19-21`** , checking an invariant
  frequently requires reading code OUTSIDE the diff (an invariant like "exactly one
  output_language line" holds only if no other writer appends), but the budget permits
  out-of-diff reading "only to evaluate a concrete risk you can NAME in your report".
  The tension is shipped, not resolved: a literal reader can skip the check for lack of a
  named risk, or use the duty as a licence to crawl. Fix: append to the new bullet,
  "Checking a stated invariant COUNTS as a named risk under the budget's first bullet:
  name the entry (`C<n>`) in your report and read only the code that invariant touches."
  Note the other half composes already and needs no change: `:24-26` allows a focused
  test "when reading the code raises a specific doubt no existing run answers", and an
  invariant that may not hold is exactly such a doubt.
- **Important, `agents/code-reviewer.md:35`** , the contract-check list (signatures,
  behavior rules, invariants, named test cases) is NARROWER than the deviation surface
  the builder must report (`agents/builder.md:94`: signature, behavior rule, invariant,
  named test case, verify command or boundary) and narrower than
  `docs/plan-format.md:5-7`. So a verify-command or path deviation is reportable by the
  builder and unchecked by the reviewer. Boundaries are covered elsewhere by
  `boundary-check.sh` (AGENTS.md:266); verify commands and paths are not. The file is
  faithful to ADR-001 change 10, whose own list is the narrow one, so the ADR inherited
  the gap. Fix: extend `:35` to "signatures, paths, behavior rules, invariants, named
  test cases and verify commands (boundaries are covered by `boundary-check.sh`)".
- **Minor, `agents/code-reviewer.md:32-33`** , "No code in a plan was ever executed"
  presupposes that plans contain code, which ADR-001 forbids, so the clause is vestigial
  and its antecedent is nearly empty. The intended meaning is carried by the second half.
  Fix: "Nothing a plan describes was ever executed (its verify commands and expected
  outputs are unrun assertions, `.claude/tasks/lessons.md:11`), so nothing in it is
  pre-verified."
- **Minor, `agents/code-reviewer.md:33`** , "you are its first strong-model line check"
  misuses the tier vocabulary: AGENTS.md:71 defines strong as "sonnet class and up", and
  the builder runs `model: sonnet`, so a strong-tier model already ran. Pre-existing
  wording, retained by this edit. Fix: "you are its first INDEPENDENT judgment-tier
  check."
- **Minor, `agents/code-reviewer.md:3`** , add the not-for lane: "Code only; UI goes to
  design-reviewer, plans to architecture-reviewer, PM documents to pm-reviewer, agent
  definitions to agent-reviewer."
- **Minor, against `AGENTS.md:264`** , "[E] `architect`, reviewers, `codebase-analyst`
  are read-only (tool restriction)" is false for `code-reviewer` (Write, Bash),
  `design-reviewer` and `pm-reviewer` (Write), and AGENTS.md:151-152 says a rule not
  written there does not exist, so the reviewers' record-writing exemption currently
  exists nowhere. Fix in AGENTS.md: "read-only on the code they review; each reviewer
  carries `Write` for the eval record it owns, and `code-reviewer` also `Bash` for diff
  scoping and focused tests."

## What the edit got right
Dropping the transcription premise did NOT weaken the anti-half-coupling defense that
ADR-001's alternative 2 relies on (`ADR-001:272-274`): the replacement clause is broader
("nothing the plan described is pre-verified") and still blocks a `mechanical` tag from
being read as pre-verification. The `illustrative-not-contract:` label is spelled
identically across all four sites that mention it, so it stays greppable as the ADR
required.

## Integrity
House voice, consistent with the sibling reviewers. No copied text.

## Vs previous version
No prior per-file record; `docs/evals/agent-set-model-policy.md` (2026-07-24) covered
this file inside an eight-agent SET at 10/10. That record's trigger-clarity 2 was
argued from `pm-reviewer` and `design-reviewer` examples and did not test this file's
own not-for lane, so the drop to 1 is a granularity change, not a measured regression.
Round 1 for this file.

## History
- 2026-08-04 v2 (branch `chore/adr-001-contracts-not-code`, HEAD aee5ab1): first
  per-file review, after ADR-001 change 10 (review-budget bullet). Round 1 = 8/10 PASS,
  two Important open (budget tension, contract-check list).
