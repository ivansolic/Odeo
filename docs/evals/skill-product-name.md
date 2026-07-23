---
artifact: product-name
type: skill
branch: feature/improve-product-name
artifact_version: 2
date: 2026-07-21
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 1 }
total: 9/10
verdict: PASS
---

## Skill: product-name  (explicit command)

Explicit command (`disable-model-invocation: true`), on the system map as
`/product-name`. Single file, no supporting files, ~35 lines, well under the
500-line limit. One-level-deep rule trivially satisfied.

## Scores
- trigger clarity: 2, "description says what the user gets (brainstorm names, sanity-check ownability) and when to run it (naming anything) in plain language, correct form for an explicit command."
- structure: 2, "follows the body shape: essence, When to use, Process, Output, Example, Quality rules; lean at ~35 lines."
- worked example: 2, "Example uses concrete real values from this system's own naming lesson (Rivo/Rovo homophone, coin/oblique, working title)."
- precision: 2, "exact references (`/positioning`), concrete heuristics (1-2 syllables, hard consonants k/t/v, Odeo/Odoo), no TBDs or placeholders."
- safety integration: 1, "no guardrail applies to name brainstorming; skill is silent on guardrails, which is correct here (1 = silent, not a defect for this domain)."

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Findings (all minor, non-blocking)
1. The five edits land cleanly and stay in-standard: additions are references and
   compact heuristics, not restated prose. No bloat.
2. Process step 2 (Diverge) is now the densest sentence in the file: it carries
   the coined/oblique lead, the syllable heuristic, and the vowel-vs-consonant
   sound-craft note in one run. It is still readable, but it is the one place a
   split into two sentences (approach-selection vs sound-craft) would improve
   scanability. Optional polish, not required to pass.
3. Slight conceptual overlap: "lead with coined/oblique in saturated spaces"
   appears in step 2, and "dictionary words in crowded spaces are mostly taken"
   appears again in step 4. Both earn their place (one guides divergence, one
   guides the ownability check) so this is reinforcement, not redundancy, but a
   future edit could cross-reference rather than re-assert.
4. The homophone addition (step 4) and trademark-by-class distinction are clear
   and correctly scoped ("flag same-category ones loudly" vs "different class may
   still be usable"). Good precision.
5. The stop-condition bullet in Quality rules is a genuine addition, not a
   restatement of the Output "working title" line: Output says what to produce
   when nothing is clean; the quality rule adds the behavioral guard (don't
   spiral). Both are needed.

## Top fixes
1. (Optional) Split step 2 into two sentences: keep approach selection
   ("lead with coined/oblique...") in one, move the sound-craft heuristic
   (syllables, vowel vs hard-consonant endings) into its own trailing sentence,
   so the divergence instruction and the craft note read as distinct guidance.

## Testing note
The changes are behavioral (they alter how the agent diverges and checks
ownability). Form passes cleanly; recommend an `/improve` subagent test only if
you want evidence the new heuristics change output quality. Content-skill route
(produce a shortlist, score against intended criteria) is the cheaper proof.

## History
- v2 (2026-07-21, feature/improve-product-name): first eval record. Scored the
  five edits (saturated-space divergence + sound-craft, homophone + trademark-
  class ownability, external-tool brief, stop-condition rule, refreshed example).
  9/10 PASS. No prior record to regress against.
