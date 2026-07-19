---
artifact: second-opinion-design
type: skill
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
---

Explicit command (`disable-model-invocation: true`). Reviewed against
`docs/skill-authoring-standard.md` and the shared contract
`docs/second-opinion-protocol.md`. First review, no prior record. Follow-up that
replicates the approved `second-opinion-code` (10/10) for the multimodal design
target.

## Scores
- trigger clarity: 2. Correct explicit-command form, not "Use when...". Opens with
  what the user gets ("Get a paid, independent SECOND OPINION on UI (the look and
  the UI code) from an external MULTIMODAL vendor model ... then have OUR
  design-reviewer compare the two reads"), states when ("a high-stakes or contested
  UI, or when a design review scored low"), example ("second opinion on the
  checkout screen"). The MULTIMODAL requirement is surfaced right in the
  description.
- structure: 2. Follows the body shape (essence, when/when-not, numbered process,
  worked example, output, rules). 68 lines, one file, no refs, so one-level and
  <500-line limits hold. Contract deferred: "read it; not restated here".
- worked example: 2. Concrete and imitable: payload = component code plus a
  screenshot of the rendered state; `second-opinion.sh design /tmp/checkout-bundle.md`;
  real comparison outcome (overlap = primary button lacks visible focus ring;
  only-vendor = error state has no recovery affordance; only-ours = spacing-scale
  slip; recommendation = fix focus + error recovery).
- precision: 2. Exact commands, flags, and paths: wrapper signature
  `second-opinion.sh design <payload-file> [--vendor NAME] [--model ID]`, exit-code
  semantics (1 blocked, 3 vendor missing), record path
  `docs/evals/second-opinion-design-<id>.md`. No TBDs.
- safety integration: 2. References guardrails and adds the domain-specific one
  correctly: pre-send `privacy-scan.sh` with "Seed/fake data only, never real user
  data in a shared screen" (step 2) and again in Rules ("fake data only in a shared
  screen"), never-simulate (exit 3), consent + non-persisted scope, authority
  "informs, never rules", cost.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Required checks
- Vendor-neutrality: holds. No `codex`/`gemini`/`gpt`/`openai` token; vendor is "an
  argument, never part of this skill's name or a command" (line 68). Matches lint
  C10. The multimodal need is expressed as a capability requirement ("a MULTIMODAL
  vendor", "multimodal default from the protocol matrix"), not a vendor name, which
  is the correct way to encode it.
- Protocol reference (C10): line 11 references `docs/second-opinion-protocol.md`
  ("read it; not restated here"); `bin/second-opinion.sh` referenced at step 4.
- Multimodal requirement (design-specific): correct. Description and lines 15-16
  require the vendor to "read the rendered look, not just the code", and step 2
  requires "the UI code plus a rendered view (a screenshot or an exported render)"
  so the multimodal vendor can judge the look. Default vendor for this target is
  noted as differing from the code target, per the protocol matrix.
- Fake-data-only for shared screens: correct and stated twice (step 2 and Rules).
- Coherence with the protocol:
  - Authority: "The vendor INFORMS; our reviewer keeps the verdict"; step 5 "NEVER
    changes its own verdict".
  - Consent: step 1 per-invocation confirm + optional non-persisted scope.
  - Model as a question: step 3 "announce the model as a QUESTION ... strongest
    multimodal model ... confirm, pick another, or stop".
  - Offer once, never after decline: line 22.
  - Comparison by OUR design-reviewer: step 5 hands findings to `design-reviewer`,
    which writes the record. Matches reviewer asymmetry (design-reviewer writes its
    own record).
  - Record: no gate `verdict:`, uses `related_branch:` not `branch:` (lines 60-61).

## Map duty
Satisfied. `/second-opinion-design` is catalogued in `docs/system-map.md` line 137
with the multimodal note.

## Top fixes (optional polish, none blocking)
1. None blocking. The multimodal payload guidance is a nice differentiator from the
   code skill and is handled correctly.

## History
- 2026-07-19: first review on branch feature/second-opinion-code. 10/10 PASS.
