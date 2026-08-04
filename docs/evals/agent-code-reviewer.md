---
artifact: code-reviewer
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 4
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 1, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

# Agent: code-reviewer (round 3, at HEAD f4e295a)

Scoped re-review: verified ONLY the closure claimed for this file (the primacy overclaim at
`:33`) plus the AGENTS.md residual that was recorded against this file's policy line.
Everything cleared in rounds 1 and 2 carries forward with its evidence re-checked at HEAD.

Version note: `artifact_version: 4` = the fourth reviewed state (v2 = aee5ab1, v3 = f8f8da6,
v4 = f4e295a).

Method note: no Bash in this reviewer's grant; scored the file as it stands at HEAD.

## Scores (all carried, none moved)

- **trigger/description clarity: 1** (unchanged, third round) , `:3` still has no not-for
  lane: "Adversarial code review by a senior staff engineer. Invoke after implementing any
  non-trivial change ...". The rubric requires what AND when AND the scope boundary for a 2.
  Not in any fix set so far; it is the single reason this file is not at 10.
- **tool least-privilege: 2** , `tools: Read, Grep, Glob, Bash, Write` (`:4`); Bash for diff
  scoping (`:13`) and the narrowly permitted focused test (`:22-26`), Write for the one record
  it owns (`:122`), no Edit, so no in-place affordance on the code it judges.
- **role boundary: 2** , the contract-adherence duty is still scoped to shipped code, and the
  round-2 wording risk against this very boundary is now removed (see the closure below).
- **policy conformance: 2** , `effort: high`, no `model:` line (judgment inherits the session,
  AGENTS.md:41-42), C11 clean, and the provenance block at `:137-141` (`model:` +
  `model_tier:`, gates refusing records without the tier and fast-tier judgment without
  `model_waiver: human`) plus the single-verdict rule at `:129-136`. The AGENTS.md residual
  recorded here in round 2 is now closed for this agent: AGENTS.md:266-271 states the `Bash`
  grant and re-tags the honesty half as [I] ("`codebase-analyst` and `code-reviewer` also hold
  `Bash` ... which is not a write restriction, so 'does not modify the artifact' is [I] for
  them"), which is accurate for this file's actual tools line.
- **instruction quality: 2** , the round-2 Minor is closed and the budget/duty composition
  verified in round 2 is untouched. No new defect in this file.

## Total: 9/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10 reachable, blocked by one clause
One clause at `:3`: "Code only; UI goes to design-reviewer, plans to architecture-reviewer,
PM documents to pm-reviewer, agent definitions to agent-reviewer." Nothing structural.

## Round-by-round
Round 1 (aee5ab1): 8/10, 2 Important + 4 Minor.
Round 2 (f8f8da6): 9/10, 1 new Minor + the `:3` residual.
Round 3 (f4e295a): 9/10 PASS. The new Minor closed; `:3` still open, so the total holds.

## Closures verified
- **CLOSED (was Minor), primacy overclaim** , `:32-34` now reads "Nothing a plan described was
  ever executed, so no part of it is pre-verified; you are the first independent judgment-tier
  check of the CODE that claims to satisfy it (the plan itself was reviewed separately)". The
  conflict with AGENTS.md:239-240 (the plan-review loop) is gone, the antecedent is now
  unambiguous, and the parenthetical closes the boundary risk the round-2 record flagged: the
  reviewer is told the plan already had its own independent check, so re-judging plan quality
  is visibly not its job. The anti-half-coupling property is intact: the premise is still
  broad enough that a `mechanical` Scrutiny tag cannot be read as pre-verification.
- **CLOSED for this agent (was PARTIALLY, against AGENTS.md:264)** , the guardrail is now
  split and, for this file, accurate: `[E]` is reserved for the two agents whose tools really
  do prevent writing and executing (`architect`, `architecture-reviewer`), and the `Bash`
  holders are separated into an `[E+I]` bullet that says plainly that Bash is not a write
  restriction. Verified against every agent the split names, by reading each `tools:` line,
  not the summary: `architect` and `architecture-reviewer` = `Read, Grep, Glob` (the [E] claim
  holds); `codebase-analyst` = `Read, Grep, Glob, Bash` and `code-reviewer` = `Read, Grep,
  Glob, Bash, Write` (both correctly named); `code-reviewer`, `design-reviewer`,
  `pm-reviewer`, `skill-reviewer`, `agent-reviewer` all carry exactly one `Write` and no
  `Edit` (the scoring-reviewer exemption is accurate for all five).

## New from these edits
- **Minor, against `AGENTS.md:266-268`, one Bash holder is still missing from the split** ,
  the bullet enumerates the read-side agents that also hold `Bash` as "`codebase-analyst` and
  `code-reviewer`", but `agents/debugger.md:4` is `Read, Grep, Glob, Bash` and the agent is in
  the identical position: no write tools, and an [I]-only promise not to change the artifact
  ("You investigate and return findings; the fix is applied in the main flow",
  `agents/debugger.md:9-10`). Since AGENTS.md:151-152 says a rule not written there does not
  exist, `debugger`'s investigate-do-not-fix property currently has no guardrail home. Fix:
  add it to the same `[E+I]` bullet, "`codebase-analyst`, `code-reviewer` and `debugger` also
  hold `Bash`". Out of scope for this file, recorded here because this file's policy line is
  where the AGENTS.md finding has lived since round 1.

## Open (carried)
- **Minor, `:3`, no not-for lane** , third round open; the file's only ceiling blocker.

## Integrity
House voice, consistent with the sibling reviewers. No copied text.

## Vs previous version
Held at 9/10: the new Minor from round 2 is closed and the AGENTS.md finding is closed for
this agent, but criterion 1 is unchanged, so the total cannot move. Baseline is the round-2
per-file record (v3).

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 10. Round 1 = 8/10 PASS,
  two Important open (budget tension, contract-check list).
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 9/10 PASS; both
  Importants and both wording Minors closed, one new Minor (primacy overclaim), AGENTS.md
  finding partially closed.
- 2026-08-04 v4 (f4e295a): scoped re-review. Primacy overclaim closed; the AGENTS.md split
  verified against every named agent's actual tools line and closed for this agent, with one
  new Minor against AGENTS.md (`debugger` missing from the Bash bullet). Round 3 = 9/10 PASS,
  held; `:3` not-for lane still the only ceiling blocker.
