---
artifact: second-opinion-pm
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
replicates the approved `second-opinion-code` (10/10) for the pm target.

## Scores
- trigger clarity: 2. Correct explicit-command form, not the "Use when..." auto
  form. Opens with what the user gets ("Get a paid, independent SECOND OPINION on
  a PM document ... then have OUR pm-reviewer compare the two reads"), states when
  ("a big bet, a sink-it assumption a critique surfaced, multi-epic scope, or a
  hard-to-reverse decision"), and carries an example ("second opinion on PRD-007").
  Matches the protocol's "Big bet" trigger.
- structure: 2. Follows the body shape (essence, when/when-not, numbered process,
  worked example, output, rules). 65 lines, one file, no supporting refs, so the
  one-level rule and <500-line limit hold. Heavy contract deferred: "read it; not
  restated here" = correct progressive disclosure.
- worked example: 2. Concrete and imitable with real values:
  `second-opinion.sh pm docs/prds/PRD-007-password-reset.md`, payload
  `docs/prds/PRD-007-*.md`, and a real comparison outcome (overlap = outcome metric
  has no target; only-vendor = riskiest assumption has no experiment; only-ours =
  scope nit; recommendation = add the experiment before build).
- precision: 2. Exact commands, flags, and paths throughout: wrapper signature
  `second-opinion.sh pm <payload-file> [--vendor NAME] [--model ID]`, exit-code
  semantics (1 blocked, 3 vendor missing), record path
  `docs/evals/second-opinion-pm-<id>.md`. No TBDs or vague steps.
- safety integration: 2. References guardrails rather than restating them:
  pre-send `privacy-scan.sh` ("The pre-send scan blocks secrets/PII regardless"),
  never-simulate (exit 3), consent + non-persisted scope, authority "informs,
  never rules", cost. The Rules block points back to the protocol and guardrails.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Required checks
- Vendor-neutrality: holds. No `codex`/`gemini`/`gpt`/`openai` token anywhere;
  vendor is "an argument, never part of this skill's name or a command" (line 64).
  Matches protocol "Vendor is an argument" and lint C10.
- Protocol reference (C10): line 11 references `docs/second-opinion-protocol.md`
  ("read it; not restated here"); script `bin/second-opinion.sh` referenced at
  step 4. Neither is restated.
- Coherence with the protocol:
  - Authority: "The vendor INFORMS; our reviewer keeps the verdict"; step 5 "NEVER
    changes its own verdict". Matches "the line that never moves".
  - Consent: step 1 per-invocation confirm + optional non-persisted scope grant.
  - Model announced as a question: step 3 "announce the model as a QUESTION ...
    confirm, pick another, or stop". Matches "Model picker".
  - Human-invoked-only, offer once, never after decline: lines 19-20. Matches
    "When a skill may OFFER it".
  - Comparison by OUR pm-reviewer: step 5 hands findings to `pm-reviewer`, which
    writes the record. Matches reviewer asymmetry (pm-reviewer writes its own
    record, so it authors the comparison directly).
  - Record: no gate `verdict:`, uses `related_branch:` not `branch:` (Output, lines
    57-58). Matches "The record".

## Map duty
Satisfied. `/second-opinion-pm` is catalogued in `docs/system-map.md` line 135.

## Top fixes (optional polish, none blocking)
1. None blocking. The Output already names `related_branch:` explicitly, which is
   the load-bearing reason the verdict-less record dodges the merge-gate; good.

## History
- 2026-07-19: first review on branch feature/second-opinion-code. 10/10 PASS.
