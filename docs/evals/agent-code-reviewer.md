---
artifact: code-reviewer
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 3
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 1, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 9/10
verdict: PASS
previous_total: 8/10
---

# Agent: code-reviewer (round 2, at HEAD f8f8da6)

Scored `agents/code-reviewer.md` against `agents/agent-rubric.md`, cross-checked against
`AGENTS.md` (model policy, Guardrails 3, 5 and 6) and `docs/plan-format.md:5-9`.

Version note: labelled `artifact_version: 3`, not 2. The file changed again between the
round-1 review (aee5ab1, recorded as v2) and this one (f8f8da6).

Method note: no Bash in this reviewer's grant; scored the file as it stands at HEAD.

## Scores

- **trigger/description clarity: 1** (unchanged) , `:3` states what ("Adversarial code
  review by a senior staff engineer") and when ("Invoke after implementing any non-trivial
  change, before considering the task complete"), but still carries NO not-for lane, which
  the rubric requires for a 2. Its siblings have one (`pm-reviewer`: "Documents only; code
  goes to code-reviewer, UI to design-reviewer, skills to skill-reviewer"). This finding
  was not in the fix set; it is the single reason this file is not at 10.

- **tool least-privilege: 2** , `tools: Read, Grep, Glob, Bash, Write` (`:4`). Every grant
  maps to a documented step: Read/Grep/Glob for review, Bash for scoping the diff ("Recent
  git diff (`git diff`, `git diff main`, or `git log -p -n 1`)", `:13`) and the narrowly
  permitted focused test (`:22-26`), Write for the one record it owns ("write the record to
  `docs/evals/code-<branch-or-story-id>.md`", `:122`). No Edit, so it has no in-place
  affordance on the code it judges.

- **role boundary: 2** , the contract-adherence duty stays in lane: it checks SHIPPED CODE
  against the plan's contract and does not drift into judging whether the contract is
  complete (that is `architecture-reviewer` at plan review). It self-limits rather than
  expanding ("if heavy validation seems warranted, recommend it instead of running it",
  `:25-26`; "If scope is unclear (what changed?), ask the user before reviewing", `:150`).
  One new wording risk against this boundary is noted below (`:33`) but the duty text
  itself remains scoped to the shipped code.

- **policy conformance: 2** , `effort: high` declared, no `model:` line so judgment
  inherits the session (AGENTS.md:41-42), no version-pinned id (C11 clean), and the
  provenance rules are spelled out in full: `model:` plus `model_tier:`, "Gates refuse
  records without `model_tier:`, and refuse fast-tier judgment without an explicit
  `model_waiver: human` line" (`:137-141`), plus the single-verdict-line rule and "Only
  you, the reviewer, ever write or change a verdict" (`:129-136`). The round-1 blemish
  (AGENTS.md calling all reviewers read-only) is now largely repaired in AGENTS.md itself,
  see the partially-closed finding below; the residual is an AGENTS.md defect, not this
  file's, so it does not move this score.

- **instruction quality: 1 -> 2** , both round-1 Importants are closed inside the new
  bullet, and it now composes with the budget it sits in rather than fighting it:
  "Checking a stated invariant COUNTS as a named risk under the first bullet: name the
  entry (`C<n>`) and read only the code that invariant touches" (`:41-43`) resolves the
  crawl-versus-skip tension in the direction that preserves both the budget and the duty,
  and `:34-37` now cites "the canonical binding list in `docs/plan-format.md` (signatures,
  paths, behavior rules, invariants, named mechanisms, test cases, verify commands;
  boundaries are covered by `boundary-check.sh`)", which both widens the check to the full
  deviation surface and removes this site as a drift source. The vestigial premise is gone
  ("Nothing a plan described was ever executed, so no part of it is pre-verified",
  `:32-33`) and so is the tier misuse. Level 2's descriptor (process, output shape,
  honesty/guardrail integration, rules for yourself) is met in full; one new Minor
  residual is named below rather than waived.

## Total: 9/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable, blocked by one clause
Criterion 1 is the only thing between this file and 10, and it is a single clause at `:3`,
not a structural cap. Nothing about the code-review role prevents a not-for lane.

## Round-by-round
Round 1 (aee5ab1): 8/10 PASS, 2 Important + 4 Minor.
Round 2 (f8f8da6): 9/10 PASS. Moved: instruction quality 1 -> 2. Criterion 1 stayed at 1
because its finding was not in the fix set.

## Findings closed
- **CLOSED (was Important), budget-versus-invariant tension** , `:41-43` makes the
  invariant check a named risk by definition and bounds the reading to what the invariant
  touches, so neither the skip reading nor the crawl reading survives.
- **CLOSED (was Important), contract-check list narrower than the deviation surface** ,
  `:34-37` now cites the canonical list and explicitly includes paths, verify commands and
  named mechanisms, with boundaries correctly delegated to `boundary-check.sh`
  (AGENTS.md:269-270). This site is now a citation, not a fifth copy.
- **CLOSED (was Minor), the "no code in a plan" premise** , `:32-33` no longer presupposes
  that plans contain code.
- **CLOSED (was Minor), "strong-model line check"** , the tier-vocabulary misuse against
  AGENTS.md:71 ("strong = sonnet class and up", and the builder runs `model: sonnet`) is
  gone. See the new Minor below on what replaced it.
- **PARTIALLY CLOSED (was Minor, against AGENTS.md:264)** , the reviewers'
  record-writing exemption now exists in the single source of truth: "Scoring reviewers
  (`code-reviewer`, `design-reviewer`, `pm-reviewer`, `skill-reviewer`, `agent-reviewer`)
  hold `Write` for ONE purpose, their own eval record under `docs/evals/`; they never edit
  the artifact they judge" (AGENTS.md:265-267). Two residuals, both in AGENTS.md, both
  live under the [E] "read-only (tool restriction)" claim, which Bash makes untrue:
  (a) `code-reviewer` also holds `Bash` (verified `agents/code-reviewer.md:4`; it is the
  only scoring reviewer that does), and the new sentence covers Write only;
  (b) `codebase-analyst` is still listed as read-only by tool restriction while holding
  `Bash` (`agents/codebase-analyst.md:4`), so the [E] tag overstates what is enforced.
  Fix in AGENTS.md:264-267: name the two Bash grants and what they are for (diff scoping
  and focused tests; repo inspection), or drop the "(tool restriction)" claim for the
  Bash-holding roles and tag them [I].

## Findings open
- **Minor, `:33`, the replacement clause overclaims primacy** , "you are its first
  independent judgment-tier check" reads, on the antecedent the sentence supplies ("no part
  of IT is pre-verified", it = the plan), as if nothing had independently judged the plan.
  AGENTS.md:239-240 mandates the opposite: "Plans go through the plan-review loop
  (architecture-reviewer x architect, to clean, max 3)", which is an independent
  judgment-tier check of the plan. The behavioural risk is small but real and points at
  this agent's own boundary: an invitation to re-judge plan quality rather than the shipped
  code. Fix: "you are the first independent judgment-tier check of the CODE that claims to
  satisfy it" (the plan itself was checked by `architecture-reviewer` before approval).
- **Minor, `:3`, no not-for lane (round-1 residual, and the file's only ceiling blocker)** ,
  fix: "Code only; UI goes to design-reviewer, plans to architecture-reviewer, PM documents
  to pm-reviewer, agent definitions to agent-reviewer."

## What the edit got right
The rewrite kept the anti-half-coupling property that ADR-001's alternative 2 depends on:
the replacement premise is broader than the one it replaced, so a `mechanical` Scrutiny tag
still cannot be read as pre-verification (`:27-33`). The `illustrative-not-contract:` label
is still spelled identically at every site that mentions it, so it stays greppable.

## Integrity
House voice, consistent with the sibling reviewers. No copied text.

## Vs previous version
Improved, 8/10 -> 9/10. Both round-1 Importants closed; the remaining gap is the same
`:3` clause flagged in round 1 and not taken. Baseline is the round-1 per-file record (v2).

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 10.
  Round 1 = 8/10 PASS, two Important open (budget tension, contract-check list).
- 2026-08-04 v3 (f8f8da6): re-review after the fix pass. Round 2 = 9/10 PASS. Both
  Importants closed plus both Minor wording defects; the AGENTS.md finding partially
  closed (Write exemption written, Bash grants still unstated); one new Minor (`:33`
  primacy overclaim) and the unchanged `:3` not-for lane remain.
