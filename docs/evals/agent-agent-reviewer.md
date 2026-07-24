---
artifact: agent-reviewer
type: agent
branch: feature/model-policy-effort
artifact_version: 1
date: 2026-07-24
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 1 }
total: 9/10
verdict: PASS
previous_total: none
---

Bootstrap review: `agent-reviewer` cannot review itself into existence, so
`skill-reviewer` performs the neutral form check on the reviewer-agent
definition (`agents/agent-reviewer.md`) plus its rubric (`agents/agent-rubric.md`),
using the agent rubric applied by analogy to the skill rubric.

## Scores (agent-reviewer.md)
- trigger/description clarity: 2 — description states what ("Scores an AGENT
  DEFINITION file"), when ("Invoke when writing or changing an agent definition,
  or on a community-contributed agent before curation"), and the scope boundary
  ("Agents only; skills go to skill-reviewer, documents to pm-reviewer, code to
  code-reviewer, UI to design-reviewer").
- tool least-privilege: 2 — `tools: Read, Grep, Glob, Write` is exactly the
  record-writing-reviewer set, identical to skill-reviewer; Write is justified by
  step 5 (writes the eval record); no Edit/Bash.
- role boundary: 2 — "If asked to review a non-agent file, say so and stop" and
  "Score the definition, not the role's usefulness ... is an architecture
  question, not this rubric's" keep it to one job and escalate rather than
  overreach.
- policy conformance: 2 — `effort: high` declared, no version-pinned model name,
  routes policy checks to AGENTS.md as single source of truth, and correctly
  enforces C11 / builder-model / isolation in step 3.
- instruction quality: 1 — a precise contract (Process, Output format, Rules for
  yourself) but ONE conformance gap vs its sibling: the record-provenance
  paragraph (step 5) omits the fast-tier refusal + `model_waiver: human` rule that
  skill-reviewer spells out, and its Output-format block is missing the `## Ceiling`
  line that the Rules section and eval-framework require the scorer to emit.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)
## Ceiling: 10/10 reachable — no criterion structurally caps this agent; the one
lost point is a fixable instruction gap, not an inherent limit.

## agent-rubric.md (well-formedness)
Well-formed: 5 criteria, 0-2 levels each with concrete anchors, an explicit
threshold ("total >= 8/10 AND no criterion at 0"), scorer notes requiring quotes,
and criteria that are meaningful and non-overlapping (trigger/desc clarity, tool
least-privilege, role boundary, policy conformance, instruction quality). The
"score the definition, not the role's usefulness" note correctly fences it off
from the architecture question. No integrity concern; wording is in this
project's own voice, not copied.

## Top fixes
1. In agent-reviewer.md step 5, mirror skill-reviewer's provenance sentence: add
   that gates refuse records without `model_tier:` and refuse fast-tier judgment
   without an explicit `model_waiver: human` line.
2. Add the `## Ceiling: <max reachable>/10 + why ...` line to the Output-format
   fenced block (the Rules section already demands it; the template must show it,
   as skill-reviewer's does on line 50).

## History
- 2026-07-24 v1: first review (bootstrap). Round 1 = final, 9/10, PASS. No prior
  record; no regression to compare.
