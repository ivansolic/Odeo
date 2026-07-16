---
artifact: skill-research
type: skill
branch: main
artifact_version: 1
date: 2026-07-16
scorer: skill-reviewer
scores: { trigger_clarity: 1, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
---

## Findings

- **Trigger clarity (1):** The first sentence is exemplary for an auto-invoked
  skill: "Use when the user wants market or web research with sources, market
  size, competitor landscape, pricing scan, trend check, or verifying a claim
  ('is it true that...'), or when a PRD/strategy rests on unverified
  assumptions.", real session keywords, symptoms, and the upstream trigger. But
  the second sentence, "Produces a cited report in docs/research/; every claim
  needs two independent sources or is marked unverified.", summarizes the
  output contract, which the standard forbids for auto-invoked descriptions
  ("describe ONLY the triggering conditions ... Never summarize the workflow
  in the description").
- **Structure (2):** Follows the body shape: one-line essence ("Turns a
  question into a CITED report the rest of the system can lean on"), modes,
  numbered process (7 steps), output path and template inside step 5, worked
  example, "Where it sits in the process" (when to use), "Honest limits",
  "Rules for yourself". 84 lines, no supporting files needed, nothing deeper
  than one level.
- **Worked example (2):** Concrete and directly imitable: real question ("how
  big is the meal-prep app market in the EU?"), real search phrasings, both
  triangulation methods named, and the output shows the contract in action:
  "€180-420M SAM (two methods, 2025 data); the wide range comes from
  disagreement between analyst reports (labeled) ... Unverified: retention
  benchmarks (one source)." It also demonstrates the routing step
  ("cite RES-003 in PRD-001's Context?").
- **Precision (1):** Paths and commands are exact throughout
  (`docs/research/RES-NNN-<slug>.md`, `code -r <file>` with `cursor -r`
  fallback, `.claude/tasks/todo.md`). One failure: the claim "`/discover`
  offers it as an optional evidence step" is false against the current tree,
  skills/discover/SKILL.md (flow lines 13-17, adjacent list line 19) contains
  no `/research` mention. A stated integration that does not exist is a
  precision defect. Minor: how NNN is chosen (next free number in
  docs/research/) is unstated.
- **Safety integration (2):** References the honesty guardrail by name and
  applies it without weakening or restating: "Never fabricate a number, a
  source, or a quote (honesty guardrail; a fabricated citation is worse than
  no report)." The no-web-access rule is the guardrail extended honestly:
  "say so immediately and stop, a report from memory is not research", and
  even the fallback output is labeled "not verified, research pending".

## Cross-checks

- **Map duty:** satisfied, `/research` row present in docs/system-map.md
  (line 67); wording matches the skill (2+ sources or unverified, ranges with
  methods, RES-NNN, offered by /discover and /prd, standalone).
- **/prd offer:** consistent, skills/prd/SKILL.md step 3 offers "shall I back
  this with `/research`? (cited sources, ~10 min quick scan)" and cites
  RES-NNN, matching the skill's "Where it sits" and its quick-scan depth.
- **/discover offer:** INCONSISTENT, the claimed optional evidence step is
  missing from skills/discover/SKILL.md (see Precision). Either edit was
  planned and not made, or the skill over-claims.
- **Honesty guardrail:** referenced, applied, not contradicted.
- **Two-altitude prioritization (AGENTS.md line 18):** no conflict, step 7
  feeds market sizing into `/prioritize` (epic/portfolio altitude), never into
  `/stories` ordering.
- **Over-promising vs environment:** handled, "Honest limits" covers absent or
  blocked web access, imperfect coverage ("the Sources list IS the coverage
  claim, nothing beyond it"), and data aging. The "~10 min" quick-scan figure
  is a soft estimate, acceptable, and consistently quoted in /prd's offer.
- **Editor rule (lint invariant C3):** satisfied, `research` is in the C3 list
  in bin/skills-lint.sh (line 39) and the skill contains `code -r` (step 6).
- **Integrity check:** no verbatim-copied text from other projects detected;
  terminology and voice match this repo's house style.
- **Prior record:** none, first eval of this skill.

## Top fixes

1. Close the /discover gap (one of two concrete edits): add `/research` to
   skills/discover/SKILL.md line 19, e.g. "Adjacent, pull in when relevant:
   `/research` (cited evidence for any claim before you bet on it),
   `/interview-synthesis` (if you have research), `/competitor-analysis`,
   `/market-segments`.", or, if /discover must stay untouched, rewrite the
   skill's line to "Discovery-phase skill; `/prd` offers it when the Context
   section rests on assumptions."
2. Rewrite the description to triggers only: delete "Produces a cited report
   in docs/research/; every claim needs two independent sources or is marked
   unverified." (the body's opening paragraph already carries the contract)
   and, if length allows, add trigger keywords instead: "TAM", "SAM",
   "market size", "who are the competitors", "what do they charge".
3. Minor: in step 5, state the numbering rule explicitly, "NNN = next number
   after the highest existing RES- file in docs/research/".

## History
- 2026-07-16, v1: first review, PASS 8/10.
