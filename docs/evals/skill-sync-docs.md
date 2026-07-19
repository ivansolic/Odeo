---
artifact: skill-sync-docs
type: skill
branch: feature/focus-sync-docs
artifact_version: 1
date: 2026-07-19
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
---

## Findings

- **Trigger clarity (2):** Explicit command (`disable-model-invocation: true`), so
  the bar is what-you-get + when + example. The description delivers all three:
  what-you-get ("Reconcile what the shipped code actually does against what the
  docs claim... then sync the docs or name the gap, always with your approval"),
  when ("run it after a change altered behavior the docs describe, or before a
  release or pitch"), and a concrete example ("/sync-docs" after shipping a change
  to the export format). Correctly not "Use when...".
- **Structure (2):** Follows the body shape, essence, when-to-use (and when not),
  numbered process (scope -> list docs -> compare -> draft -> gate -> offer),
  worked example, output, rules. 56 lines, no supporting files, far under the
  limit. Lean, no padding.
- **Worked example (2):** Concrete with real values: an Excel-alongside-CSV
  change, README "Exports" claiming "export to CSV" marked STALE, the CLI
  `--format` help marked MISSING the `xlsx` value, drafted fixes ("export to CSV
  or Excel (.xlsx)"; add `xlsx`), and a realistic partial-approval gate where the
  README edit is applied and the help text deferred but listed so it is not lost.
  Directly imitable.
- **Precision (2):** Exact throughout: the diff scoping (`git diff main...`), the
  named doc set (README.md, `docs/`, CLAUDE.md, release notes), and the four
  precise verdict labels (MATCHES / STALE / MISSING / ASPIRATIONAL) each with a
  defined meaning and a defined action. No TBDs, no vague steps.
- **Safety integration (2):** Follows the gather -> compare -> draft -> human-gate
  template like `/outcome` and `/product-signal`, and integrates the two honesty
  guardrails exactly where they apply. Never edits without approval, stated twice
  ("always with your approval", "Nothing is written silently", "Never edit a doc
  without your approval (draft-first, per the guardrails)"). Never invents
  unverified behaviour ("never claims behavior it did not verify in the code",
  "Verify every claim against the actual code"), which is the never-fabricate rule
  (guardrail 6) applied to docs. Treats an ASPIRATIONAL doc as a decision to
  surface, not to silently rewrite ("do not quietly rewrite a doc to match
  half-built code, that is a decision for the human, not a sync"). Offer-once
  discipline present ("Offered by `/merge`... Never after a decline"). References
  guardrails, does not restate their machinery.

## Cross-checks

- **Map duty:** satisfied. `/sync-docs` is in docs/system-map.md section 6 (Build
  & integrate), line 68; wording matches the skill (reconcile code vs docs, sync
  or name the gap, your approval, offered by /merge when a diff touched documented
  behavior).
- **/merge integration:** step 7 (skills/merge/SKILL.md line 47-51) offers
  `/sync-docs` once when the merged diff touched documented behavior, states the
  reason ("this changed the export format the README documents, want me to
  reconcile the docs?"), and is bounded by "never after a decline" plus the
  draft-first / "a 'no' is final" note. This matches the `/learn` offer-once
  pattern in the same step. No drift.
- **No guardrail contradiction:** the human floor (approval before any doc write)
  and never-fabricate (verify every claim) are referenced and reinforced, not
  weakened.
- **Prior record:** none, first eval of this skill.

## Top fixes

None required for PASS. Optional polish:
1. Step 6 offers `/release-notes`, confirm `/release-notes` exists on the system
   map (guardrail 6 forbids inventing commands). If it is not yet a real command,
   soften to a plain "note the user-facing change for release" until it ships.

Behavioral confirmation (does it actually verify each claim against code rather
than guess, does it hold the gate under pressure) is out of a form review's reach,
recommend a `/improve` subagent test.

## History
- 2026-07-19, v1: first review, PASS 10/10.
