---
artifact: competitor-analysis
type: skill
branch: feature/improve-product-name
artifact_version: 3
date: 2026-07-21
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger: 2, structure: 2, worked_example: 2, precision: 2, safety: 1 }
total: 9/10
verdict: PASS
previous_total: 8/10
---

## Skill: competitor-analysis  (explicit command)

Single-file skill (`SKILL.md` only, no supporting files); `disable-model-invocation: true`,
so judged as an explicit command. On the system map (`/competitor-analysis`), map duty met.
Change under review (Round 2): a standalone `## Example (a meeting-notes AI)` section was
added with real named alternatives, user axes, an explicit gap/wedge, why-now, and a
platform-absorption threat, the exact fix Round 1 recommended.

## Scores
- trigger clarity: 2, "explicit-command format correct: says what the user gets
  ('Map the competitive landscape and find your wedge') and when to run it ('Use
  when scoping a new product/feature, writing a PRD's context, or sharpening
  positioning')."
- structure: 2, "follows the body shape (essence -> when to use -> process ->
  output -> example -> quality rules), 45 lines, well under 500, no supporting
  files needed; one excellent example, not several mediocre ones."
- worked example: 2, "the new '## Example (a meeting-notes AI)' carries real named
  players ('direct , Otter, Fireflies; indirect , Notion AI'), two real user axes
  ('setup effort (zero-touch <-> configure) x trust in accuracy'), an explicit
  wedge ('zero-touch accuracy with an audit trail for regulated teams'), a why-now,
  and a concrete platform-absorption threat ('the meeting platform (Zoom/Teams)
  ships native notes'). Directly imitable, exercises every process step. 1 -> 2."
- precision: 2, "exact output path ('saved under docs/research/'), named downstream
  feeds ('/prd, /positioning, /strategy'), no TBDs or placeholders; the example's
  claims are concrete and verifiable."
- safety integration: 1, "no guardrails apply to this content skill and none are
  contradicted or restated; quality rule 'Use real, verifiable claims; flag
  anything you are inferring vs. know' aligns with the honesty rule but references
  no named guardrail (silent, correctly scored 1, structural cap for this skill)."

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
Reachable maximum is 9/10, not 10. Safety integration is structurally capped at 1:
this is a content skill that produces a research artifact and touches no guardrailed
operation (no data leaving the machine, no merge, no test, no auth). There is no
relevant guardrail to reference, so a silent 1 is the correct top score here, not a
defect. Raising it to 2 would require inventing a reference to a rule that does not
apply, which the standard forbids (safety = 0 "contradicts or restates guardrails").
All four applicable criteria are now at 2.

## Round-by-round
- Round 1 (v2): 8/10. worked_example = 1 (no standalone example; only inline
  illustrations in step 3). All others at max-reachable.
- Round 2 (v3): 9/10. worked_example 1 -> 2 (standalone meeting-notes example added).
  No other criterion moved; ceiling reached.

## Findings (non-blocking)
1. Style nit, not scored: the example uses "direct , Otter", "indirect , Notion AI",
   "status quo , nobody takes notes" and "zero-touch <-> configure". The lone commas
   after the bucket labels read as dropped dashes (the no-dash rule applied
   mechanically); consider a colon there for readability ("direct: Otter, Fireflies").
   Does not affect precision or the score.

## History
- v3 (2026-07-21, feature/improve-product-name): Round 2. Standalone worked example
  added (meeting-notes AI) with real named alternatives, user axes, wedge, why-now,
  and platform-absorption threat, closing the Round 1 gap. worked_example 1 -> 2,
  total 8 -> 9. Ceiling (9/10) reached; safety integration remains a correct
  structural 1.
- v2 (2026-07-21, feature/improve-product-name): first eval record. Reviewed the
  Threats step-6 addition (first-party / platform absorption). Form gate PASS, 8/10;
  standing worked-example gap (1) was the only thing below ceiling.
