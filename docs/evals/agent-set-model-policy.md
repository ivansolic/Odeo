---
covers: builder architect architecture-reviewer code-reviewer design-reviewer pm-reviewer codebase-analyst debugger
type: agent-definition
branch: feature/model-policy-effort
artifact_version: 1
date: 2026-07-24
scorer: agent-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
---

# Agent set: model-policy /improve (effort: high added to 8 agent definitions)

Reviewed the model-policy change on `feature/model-policy-effort`: `/improve` added
`effort: high` to the frontmatter of eight dispatched-agent definitions. Scored the
SET against `agents/agent-rubric.md` (5 criteria, 0-2 each), cross-checked against
`AGENTS.md` model policy and guardrail 5 (agents/isolation).

Scope note: `agent-reviewer.md` excluded (self-review; bootstrap-checked by
skill-reviewer). The per-file diff confirms the reviewed change is `+effort: high`
on each; other hunks on these files (builder's `model_plan` EFFORT wording,
the reviewers' `## Ceiling` blocks, pm-reviewer's coverage clause) are pre-existing
branch changes, not part of this policy edit, and are consistent with it.

## Scores (the set)

- **trigger/description clarity: 2/2** — every `description:` states what the agent
  does, when it is dispatched, AND its scope boundary. E.g. code-reviewer:
  "Invoke after implementing any non-trivial change, before considering the task
  complete"; agent-set members like pm-reviewer name the not-for lane explicitly
  ("Documents only; code goes to code-reviewer, UI to design-reviewer, skills to
  skill-reviewer"). architecture-reviewer: "Read-only analysis, produces
  recommendations, never edits code."

- **tool least-privilege: 2/2** — tools are exactly what each role needs, no
  over-grant found:
  - Read-only judgment roles carry NO mutating tools: `architect` and
    `architecture-reviewer` = `Read, Grep, Glob` (matches AGENTS.md guardrail 5
    "[E] architect, reviewers, codebase-analyst are read-only").
  - `codebase-analyst` and `debugger` = `Read, Grep, Glob, Bash`: Bash is
    justified in-body as inspection-only ("Bash is for read-only commands: ls,
    git log, wc, test runs if asked"); no Write/Edit, correctly.
  - `code-reviewer`/`design-reviewer`/`pm-reviewer` carry `Write` legitimately to
    record their eval ("write the record to docs/evals/..."); no `Edit` (no
    reason to mutate other files), correct minimum. code-reviewer's extra `Bash`
    is defensible (focused test runs / `git diff` scoping) and it explicitly
    self-limits ("Do NOT re-run the full test suite").
  - `builder` = `Read, Write, Edit, Bash, Grep, Glob`: full set is the build role
    and matches its job; paired with `isolation: worktree`.
  No read-only role carries Write/Edit/Bash it does not need.

- **role boundary: 2/2** — each is one clear job that escalates instead of
  overreaching. architect: "You never redecide product-level architecture ...
  STOP and escalate: that is a human decision recorded as an ADR." builder:
  "The plan is a contract: you implement it, you do not redesign it. ... you
  never merge." Reviewers stay in-lane (design-reviewer: "Never touch
  backend/logic/security, defer to code-reviewer").

- **policy conformance: 2/2** — fully conforms to AGENTS.md model policy:
  - `effort: high` present and valid on all 8 (allowed set low|medium|high|
    xhigh|max; `high` is in-set) and defensible per role: every dispatched role
    is judgment- or contract-execution-critical, and AGENTS.md itself mandates
    "Every dispatched agent ... runs at high effort, set explicitly in its
    frontmatter (effort:)". The change makes the files match the policy that
    previously lived only in prose.
  - Tiers not versions (C11): version-pin scan across all 8 files is clean; no
    `claude-*` / `opus-4` / `sonnet-4` / `[1m]` id appears. builder speaks the
    tier only: `model: sonnet`.
  - builder model = `sonnet` (the allowed sonnet/inherit set), correct for
    execution.
  - Isolation set where it is needed: `isolation: worktree` on builder (the only
    file-mutating role that runs in parallel per story). Read-only roles and
    single-record reviewers do not require it.

- **instruction quality: 2/2** — each is a precise contract: process, output
  shape, guardrail integration, and a "Rules for yourself" section. builder's
  pipeline (verify contract -> success-signal -> green baseline -> execute ->
  contract discipline -> loop-to-signal), the reviewers' rubric + fixed output
  + eval-record format with the single-verdict-line rule, debugger's ordered
  root-cause process. No vague or contradictory instruction surfaced.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10
No criterion structurally caps below max for this set. The policy edit is
minimal, correct, and brings every dispatched-agent file into explicit
conformance with the AGENTS.md effort mandate; least-privilege was already
clean and is unaffected. Full marks are reachable and reached.

## Findings
- No over-grant, no version-pin, no missing/invalid effort, no builder-model
  violation. The change is defensible on every file.
- Consistency: `effort: high` is now uniform across ALL ten agent files
  (the 8 reviewed + skill-reviewer + agent-reviewer), so no dispatched role
  silently inherits session effort. This is exactly the policy intent.

## Top fixes
None required to pass. Optional hardening (not blocking, not part of this edit):
1. Consider whether any high-throughput read-only role would benefit from a
   declared lower effort in future; today AGENTS.md mandates `high` for all
   dispatched roles, so `high` is correct as written. Revisit only if the
   policy itself changes.

## Vs previous version
No prior record for this set (`docs/evals/agent-set-model-policy.md` did not
exist). This is Round 1 / baseline.
