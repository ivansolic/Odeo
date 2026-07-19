---
artifact: second-opinion-plan
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
replicates the approved `second-opinion-code` (10/10) for the plan target, with the
architecture-reviewer record-authorship wrinkle.

## Scores
- trigger clarity: 2. Correct explicit-command form, not "Use when...". Opens with
  what the user gets ("Get a paid, independent SECOND OPINION on an implementation
  plan ... then weigh it against OUR architecture-reviewer"), states when ("a risky
  or hard-to-reverse plan, a large epic, or a contested architectural call"),
  example ("second opinion on the sync-engine plan"). Matches the protocol's "Big
  bet" trigger (hard-to-reverse decision).
- structure: 2. Follows the body shape (essence, when/when-not, numbered process,
  worked example, output, rules). 71 lines, one file, no refs, so one-level and
  <500-line limits hold. Contract deferred: "read it; not restated here".
- worked example: 2. Concrete and imitable: payload =
  `docs/plans/2026-07-19-sync-engine.md` + inherited architecture note;
  `second-opinion.sh plan docs/plans/2026-07-19-sync-engine.md`; real comparison
  outcome (overlap = retry path can double-write; only-vendor = no backpressure when
  the queue fills; only-ours = naming drift; recommendation = add backpressure).
- precision: 2. Exact commands, flags, and paths: wrapper signature
  `second-opinion.sh plan <payload-file> [--vendor NAME] [--model ID]`, exit-code
  semantics (1 blocked, 3 vendor missing), record path
  `docs/evals/second-opinion-plan-<id>.md`. No TBDs.
- safety integration: 2. References guardrails rather than restating: pre-send
  `privacy-scan.sh` ("The pre-send scan blocks secrets/PII regardless"),
  never-simulate (exit 3), consent + non-persisted scope, authority "informs, never
  rules", cost. Rules block points back to the protocol.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Required checks
- Vendor-neutrality: holds. No `codex`/`gemini`/`gpt`/`openai` token; vendor is "an
  argument, never part of this skill's name or a command" (line 70). Matches C10.
- Protocol reference (C10): lines 10-11 reference `docs/second-opinion-protocol.md`
  ("read it; not restated here"); `bin/second-opinion.sh` referenced at step 4.
- THE PLAN WRINKLE (the critical follow-up check): CORRECT. Step 5 states
  `architecture-reviewer` "returns advice and writes NO record (its verdict lives in
  the plan's `arch_review:` line, written by the orchestrator). So dispatch
  architecture-reviewer on the plan, then YOU (the orchestrating session) author the
  second-opinion comparison record". The Output block repeats it: record "written by
  the ORCHESTRATOR (since architecture-reviewer writes none)". This matches the
  protocol's "Reviewer asymmetry" clause (architecture-reviewer writes no record; the
  orchestrating skill writes the comparison for a plan target) and cross-checks
  against `agents/architecture-reviewer.md` line 19 ("You cannot write files; the
  orchestrating session records your verdict in the plan's `arch_review:`
  frontmatter"). The skill does NOT claim architecture-reviewer writes the record.
- Authority preserved: the vendor "never touches the plan's `arch_review:` verdict"
  (step 5); "our review still governs" (essence). Matches "the line that never moves".
- Coherence with the protocol:
  - Consent: step 1 per-invocation confirm + optional this-branch non-persisted scope.
  - Model as a question: step 3 "announce the model as a QUESTION ... confirm, pick
    another, or stop".
  - Offer once, never after decline: line 21.
  - Record: no gate `verdict:`, uses `related_branch:` not `branch:` (lines 62-64).
  - Next step on a real gap: step 6 sends the plan back to the `architect` for a
    revision, per the normal plan-review loop, correct integration point.

## Map duty
Satisfied. `/second-opinion-plan` is catalogued in `docs/system-map.md` line 136,
and the catalog entry itself notes the orchestrator-writes-the-comparison wrinkle.

## Top fixes (optional polish, none blocking)
1. None blocking. The wrinkle is stated twice (process step 5 + Output), which is
   appropriate given it is the one thing that differs from the other three skills.

## History
- 2026-07-19: first review on branch feature/second-opinion-code. 10/10 PASS.
