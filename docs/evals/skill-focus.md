---
artifact: skill-focus
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
  the bar is what-you-get + when + example, not "Use when...". The description
  meets all three: what-you-get ("Fence this session's edits to one directory... a
  PreToolUse hook refuses edits elsewhere"), when ("use it to keep yourself or a
  for-me agent on one module during a focused session, on top of the permanent
  DO-NOT-TOUCH boundaries"), and a concrete example ("/focus apps/api" then
  "/focus off"). It also honestly subordinates itself to the permanent boundaries
  in the description itself.
- **Structure (2):** Follows the body shape, essence, when-to-use (and when not),
  process split into set/lift/status, worked example, rules. 53 lines, no
  supporting files, well under the 500-line limit. No wall of text, no padding.
- **Worked example (2):** Concrete and directly imitable with real values:
  `zone="$(cd apps/api && pwd -P)"` resolving to `/Users/.../myapp/apps/api`, a
  refused edit to `apps/web/App.tsx` with the exact hook refusal message, an
  allowed edit to `apps/api/routes.ts`, and the `/focus off` clear. Not abstract.
- **Precision (2):** Exact commands throughout: `root="$(git rev-parse
  --show-toplevel)"`, physical-path resolve `zone="$(cd "<dir>" && pwd -P)"`, the
  write `mkdir -p "$root/.claude" && printf '%s\n' "$zone" >
  "$root/.claude/focus-zone"`, and the lift `rm -f "$(git rev-parse
  --show-toplevel)/.claude/focus-zone"`. The non-existent-directory case is
  handled ("say so and stop"). No TBDs, no placeholders. The `<dir>` token is a
  genuine argument slot, not vagueness.
- **Safety integration (2):** References the mechanism rather than restating it,
  "Enforced by the `focus-check.sh` PreToolUse hook (the `[E]` guardrail in
  AGENTS.md)", and is honest about every limit the guardrail states: fails open
  ("it can never trap you"), only refuses never grants, sits UNDER the permanent
  DO-NOT-TOUCH boundary ("Not a security boundary: the permanent DO-NOT-TOUCH
  `boundary-check` is the hard guard; `/focus` is a focus aid"), and Claude-Code-
  only with advisory behaviour elsewhere ("advisory on hosts without PreToolUse
  hooks (portability backlog)"). The offer-once discipline is present ("may offer
  it once... Never after a decline"), and it references `session-end-check.sh` and
  the gitignored state file without duplicating their logic.

## Cross-checks

- **Map duty:** satisfied. `/focus` is in docs/system-map.md section 1 (Setup &
  onboarding), line 24; wording matches the skill (fence edits to one directory,
  PreToolUse hook refuses elsewhere until `/focus off`, a focus aid under the
  permanent DO-NOT-TOUCH boundaries).
- **No guardrail contradiction:** matches AGENTS.md guardrail 5 [E] verbatim in
  intent, refuses-only, fails-open, under DO-NOT-TOUCH, Claude-Code-only. The
  skill references, never weakens.
- **Offer consistency:** `/build` with-me offer-once-then-never-after-decline
  matches the `/learn` / `/sync-docs` offer pattern.
- **Prior record:** none, first eval of this skill.

## Top fixes

None required for PASS. Optional polish:
1. The description is long (one dense paragraph). Consider tightening the middle
   clause so the what-you-get lead is not buried, but this is style, not a rubric
   miss.

Behavioral confirmation (does the hook actually refuse the right paths, does
fail-open behave under a malformed state file) is out of a form review's reach,
recommend a `/improve` subagent test before this ships as discipline-critical.

## History
- 2026-07-19, v1: first review, PASS 10/10.
