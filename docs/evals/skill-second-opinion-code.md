---
artifact: second-opinion-code
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
`docs/second-opinion-protocol.md`. First review, no prior record.

## Scores
- trigger clarity: 2. Correct explicit-command format, opens with what the user
  gets ("Get a paid, independent SECOND OPINION on a code diff ... then have OUR
  code-reviewer compare the two reads"), states when to run it (risky diff,
  auth/payments/uploads/data-access, security, contested finding, repeated
  REQUEST-CHANGES), and carries an example invocation ("second opinion on this
  branch's diff"). Not the "Use when..." auto form, which is right here.
- structure: 2. Follows the body shape (essence, when/when-not, numbered process,
  worked example, output, rules). 65 lines, one file, no supporting refs, so the
  one-level rule and the <500-line limit are respected. Heavy contract deferred to
  the protocol ("read it; not restated here") = correct progressive disclosure.
- worked example: 2. Concrete and imitable with real values: `git diff main... >
  /tmp/auth.diff`, `second-opinion.sh code /tmp/auth.diff --mode adversarial`, and
  a real comparison outcome (overlap = missing rate-limit; only-vendor = session
  fixation; only-ours = naming nit; recommendation to fix session fixation).
- precision: 2. Exact commands, flags, and paths throughout: the wrapper signature
  `second-opinion.sh code <payload-file> [--vendor NAME] [--model ID] [--mode
  review|adversarial]`, exit-code semantics (1 blocked, 3 vendor missing), and the
  record path `docs/evals/second-opinion-code-<id>.md`. No TBDs or vague steps.
- safety integration: 2. References guardrails rather than restating: the pre-send
  `privacy-scan.sh` (fail-closed, "Secrets/PII are blocked by the pre-send scan
  regardless"), never-simulate (exit 3), consent + non-persisted scope, authority
  "informs, never rules", cost. The Rules block explicitly points back to the
  protocol and guardrails.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Vendor-neutrality (required check)
Holds. No `codex`/`gemini`/`gpt`/`openai` token anywhere in the file; the vendor
is consistently "an argument, never part of this skill's name or a command" (line
64), matching protocol section "Vendor is an argument, never a name" and lint C10.

## Coherence with the protocol (no drift found)
- Consent: step 1 = per-invocation confirm + optional non-persisted scope grant.
  Matches protocol "Consent".
- Authority: "The vendor INFORMS; our reviewer keeps the verdict" and step 5
  "NEVER changes its own verdict". Matches "the line that never moves".
- Comparison authored by OUR code-reviewer: step 5 hands vendor findings to
  code-reviewer, which writes the record (overlap / only-ours / only-vendor +
  recommendation). Matches "The comparison flow" and reviewer asymmetry.
- Model announced as a question: step 3 "announce the model as a QUESTION ... ok /
  pick another / stop". Matches "Model picker".
- Human-invoked-only, offer at most once, never after a decline: line 18. Matches
  "When a skill may OFFER it".
- Record with no gate verdict: Output section "no gate verdict". Matches "The
  record".

## Map duty
Satisfied. `/second-opinion-code` is catalogued in `docs/system-map.md` line 130
with the informs-never-gates framing and the shared-mechanism note (line 133).

## Top fixes (optional polish, none blocking)
1. In Output, consider naming `related_branch:` (not `branch:`) explicitly, since
   that field is the load-bearing reason the verdict-less record dodges the
   merge-gate; today the skill relies wholly on the eval-framework reference for
   it. A one-clause reminder would harden against a reader who skips the ref.

## History
- 2026-07-19: first review on branch feature/second-opinion-code. 10/10 PASS.
