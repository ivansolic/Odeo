# Skills alignment pass, results (2026-07-07)

One-time audit of all 56 skills against `docs/skill-authoring-standard.md`.
Method: mechanical audit (frontmatter, invocation mode, size, description format,
concrete-example presence) + targeted fixes. Recorded per the "everything in
writing" rule: the RESULT, not just "done".

## Checks and results
| Check | Result |
|---|---|
| Frontmatter present + description on every skill | 56/56 PASS |
| Size under 500 lines | 56/56 PASS (largest: setup-project, 171 lines) |
| Explicit commands carry `disable-model-invocation: true` | PASS (all except the 4 intended auto-skills) |
| Auto-invoked skills are exactly the intended set | PASS: guide, test-driven-development, ux-design, ux-writing |
| Auto-invoked descriptions start "Use when..." (trigger-only) | FIXED in this pass: test-driven-development, ux-design, ux-writing (guide was already compliant) |
| Concrete worked example present | 53/56 had inline examples; FIXED in this pass: merge, retro, sync-community (worked-example blocks added) |
| Supporting files max one level deep | PASS (rubric.md files sit beside SKILL.md) |
| No em/en dashes | PASS (checked continuously) |

## Honest notes
- "Concrete example" was verified by signal (e.g./quotes/arrows/blocks), not by a
  human read of all 56; the deep qualitative read happens naturally through
  `/improve` and eval records as skills get used (dogfood).
- skill-reviewer scoring of every skill (0-2 rubric per skill) was NOT run in
  this pass, that is 56 agent runs; risk-based call: run it per-skill on change
  (via /improve) rather than as a bulk pass.

## Follow-ups
- None blocking. Future skills are checked at creation (standard is the checklist)
  and scored by skill-reviewer when changed.
