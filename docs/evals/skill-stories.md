---
artifact: skills/stories
type: skill
branch: feature/improve-product-name
artifact_version: 2
date: 2026-07-21
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

## Skill: stories (explicit command, disable-model-invocation: true)

Round 2. Re-review after a full end-to-end sample story was added (the exact gap
that capped Round 1 at 9/10), plus the coverage section gained a deterministic
`bin/coverage-check.sh` + `covers:` frontmatter backstop.

## Scores
- trigger clarity: 2, unchanged. Description opens with what you get and when for
  an explicit command: "Break a PRD into small, independent, testable user
  stories... Use after a PRD is critiqued... or standalone." Correct form.
- structure: 2, still follows the body shape (essence, when to use, process,
  worked example, output, coverage, quality gate, quality rules); 85 lines, rubric
  one level deep, coverage-check.sh referenced not inlined. Under 500, no bloat.
- worked example: 2 (was 1). SKILL.md lines 44-59 now carry a complete, concrete,
  directly-imitable story: real PRD-014 with requirements R1/R2/R3, a full card
  ("As a shopper, I want to save my current search filters under a name, so
  that..."), four binary ACs that fold empty-name and duplicate-name error states
  into observable checks, real metadata (`covers: R1`, order 1, ~1 day), and a
  one-row traceability instance (`R1 -> USR-021`). Real values, no placeholders,
  imitable. This is exactly the end-to-end sample story Round 1 flagged as absent.
- precision: 2, exact paths and commands throughout (docs/stories/USR-NNN-<slug>.md,
  code -r <files>, rubric install path, `bin/coverage-check.sh <prd-file>
  docs/stories`). The `covers: R1 R5` field format is exact and matches what the
  script reads. No TBDs.
- safety integration: 2, references guardrails rather than restating: quality gate
  points at pm-reviewer + rubric + the AGENTS.md review-loop rule; coverage section
  defines a precondition that blocks /build and defers grading to the rubric ("a
  set can score 8/8 and still fail coverage"); the new `[E]` deterministic backstop
  points at the script, does not duplicate its logic in prose.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
Achievable ceiling this round is 10/10, and the skill now reaches it. All five
criteria are at max. The worked-example structural cap identified in Round 1 is
resolved by a real, self-contained sample story; nothing else caps below max for
this artifact type.

## Findings
1. Worked example fully closes the Round 1 gap. It is not a fragment: card + four
   binary ACs + metadata + a concrete traceability row, all tied to a named PRD
   and requirement. The ACs demonstrate the skill's own rule (error states folded
   in as binary checks, plain words not notation) rather than merely asserting it.
2. The deterministic coverage backstop is consistent end to end: the `covers: R1`
   field in the worked example matches the field format the process section
   documents (line 70) and the field `bin/coverage-check.sh` actually parses
   (script line 38, `^covers:` inline space-separated). Prose, example, and script
   agree. Good.
3. Map duty satisfied: `/stories` is on docs/system-map.md (line 61) and in the
   `/spec` chain (line 116); no new command was added this round, so no map update
   was owed.
4. The verified example is a static file sample, not a runtime trace. The skill's
   form is now at ceiling; any further change to decomposition behavior (how the
   agent slices or orders in practice) is behavioral and belongs in /improve
   subagent testing per the standard's testing duties, not here.

## History
- 2026-07-21 (v1, Round 1): fresh baseline for the "PRD coverage (traceability, a
  precondition)" addition. Verdict PASS 9/10. Worked example capped at 1: no full
  end-to-end sample story.
- 2026-07-21 (v2, Round 2): worked example 1 -> 2 after the USR-021 "Save a search"
  sample story (card + four binary ACs + `covers: R1` + `R1 -> USR-021` row) was
  added, and the coverage section gained the `bin/coverage-check.sh` + `covers:`
  deterministic backstop. Total 9/10 -> 10/10. Only worked_example moved; the other
  four were already at max and stayed there. No regression on any criterion.
