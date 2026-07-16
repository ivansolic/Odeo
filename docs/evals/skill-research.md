---
artifact: skill-research
type: skill
branch: main
artifact_version: 2
date: 2026-07-16
scorer: skill-reviewer
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 8/10
---

## Findings

- **Trigger clarity (2):** The description is now triggers-only and in the
  correct auto-invoked format: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape,
  what competitors charge, a pricing or trend scan, or verifying a claim
  ('is it true that...'), or when a PRD/strategy rests on unverified
  assumptions." The former second sentence (output-contract summary) is
  deleted; the added keywords ("TAM/SAM/SOM", "what competitors charge") are
  the words sessions actually contain. Nothing summarizes the workflow.
- **Structure (2):** Follows the body shape: one-line essence ("Turns a
  question into a CITED report the rest of the system can lean on"), modes,
  numbered process (7 steps), output path and template inside step 5, worked
  example, "Where it sits in the process", "Honest limits", "Rules for
  yourself". 84 lines, no supporting files needed, nothing deeper than one
  level.
- **Worked example (2):** Concrete and directly imitable: real question ("how
  big is the meal-prep app market in the EU?"), real search phrasings, both
  triangulation methods named, and the output shows the contract in action:
  "€180-420M SAM (two methods, 2025 data); the wide range comes from
  disagreement between analyst reports (labeled) ... Unverified: retention
  benchmarks (one source)." It also demonstrates the routing step ("cite
  RES-003 in PRD-001's Context?").
- **Precision (2):** Exact throughout. Paths and commands:
  `docs/research/RES-NNN-<slug>.md`, `code -r <file>` with `cursor -r`
  fallback, `.claude/tasks/todo.md`. The numbering rule is now explicit in
  step 5: "NNN = next number after the highest existing `RES-` file there".
  The formerly false integration claim is now true: skills/discover/SKILL.md
  line 19 reads "Adjacent, pull in when relevant: `/research` (cited web
  evidence for any claim, market size, competitors, pricing), ...", matching
  the skill's "`/discover` offers it as an optional evidence step". No TBDs,
  no placeholders.
- **Safety integration (2):** References the honesty guardrail by name and
  applies it without weakening or restating: "Never fabricate a number, a
  source, or a quote (honesty guardrail; a fabricated citation is worse than
  no report)." The no-web-access rule extends the guardrail honestly: "say so
  immediately and stop, a report from memory is not research", with even the
  fallback output labeled "not verified, research pending".

## Cross-checks

- **Map duty:** satisfied, `/research` row present in docs/system-map.md
  (line 67); wording matches the skill (2+ sources or unverified, ranges with
  methods, RES-NNN, offered by /discover and /prd, standalone).
- **/discover offer:** now CONSISTENT, skills/discover/SKILL.md line 19 lists
  `/research` in the adjacent skills, closing the v1 gap.
- **/prd offer:** consistent, skills/prd/SKILL.md step 3 offers "shall I back
  this with `/research`?" and cites RES-NNN, matching "Where it sits" and the
  quick-scan depth.
- **Honesty guardrail:** referenced, applied, not contradicted.
- **Two-altitude prioritization (AGENTS.md line 18):** no conflict, step 7
  feeds market sizing into `/prioritize` (epic/portfolio altitude), never into
  `/stories` ordering.
- **Over-promising vs environment:** handled by "Honest limits" (absent or
  blocked web access, imperfect coverage, data aging).
- **Editor rule (lint invariant C3):** satisfied, `research` is in the C3 list
  in bin/skills-lint.sh (line 39) and the skill contains `code -r` (step 6).
- **Integrity check:** no verbatim-copied text from other projects detected;
  terminology and voice match this repo's house style.

## Top fixes

None. All v1 fixes landed; nothing open against the standard. Description
edits are behavioral (they change when the skill auto-invokes): if
auto-invocation feels off in practice, route through /improve subagent
testing rather than further form edits.

## History

- 2026-07-16, v2 (this record): re-review after fixes, 8/10 -> 10/10, PASS.
  Trigger clarity 1 -> 2: the workflow-summary second sentence was deleted
  from the description and trigger keywords (TAM/SAM/SOM, "what competitors
  charge") added, so it now describes only triggering conditions. Precision
  1 -> 2: the /discover integration now exists (skills/discover/SKILL.md
  line 19) and step 5 states the RES numbering rule. All other criteria
  unchanged at 2.
- 2026-07-16, v1: first review, PASS 8/10. Findings: description's second
  sentence summarized the output contract (trigger clarity 1); the claimed
  /discover offer did not exist in skills/discover/SKILL.md and the RES
  numbering rule was unstated (precision 1).
