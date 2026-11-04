---
artifact: skills/critique
type: skill
branch: docs/prd-003-pm-content-depth
reviewed_commit: e8c3a25
artifact_version: 5
date: 2026-11-04
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

## Skill: critique  (auto-invoked)

Scope: `skills/critique/SKILL.md` (142 lines) and `skills/critique/example.md` (97 lines) as
they stand in the worktree on branch `docs/prd-003-pm-content-depth`, commit e8c3a25 (sha
supplied by the dispatcher; the reviewer has no shell and did not resolve it). The branch
was rebased onto main, so the round 4 record (5067d5d) no longer anchored the code. Scored
fresh against `docs/skill-authoring-standard.md` and its rubric, reading both files in full,
not carried over from the old record. Out of scope as in earlier rounds: the shared
output-language paragraph's wording and the `code -r` editor line in Output (see Other
checks). This review judges the files, not runtime behaviour.

## Scores
- trigger clarity: 2, "Use when the user asks to critique, red-team, poke holes in,
  stress-test, or pre-mortem a PRD, strategy, or product direction before committing to
  build it." (line 2). Auto-invoked (no `disable-model-invocation`), starts with "Use when",
  lists only triggers and the words people use, no workflow summary.
- structure: 2, essence (7-9), When to use with the when-NOT line "Not for code, a single
  story or a second model's read" (14), numbered Pass 1 (16-41), numbered Pass 2 (43-68),
  Security pre-mortem (70-74), Output (80-129), Quality rules (131-142). 142 lines, one
  supporting file, referenced from SKILL.md line 78 ("A worked example of both passes with
  real values: `example.md`."), which references nothing further: one level deep.
- worked example: 2, `example.md` models the full output shape in order with real values:
  ranking rule, ranked table with H/M/L per measure, "Top pick this week: claim 1.", kill
  tests with "(proposal)" labels, What holds up, What I could not judge, both pre-mortem
  tables, Watch with a labelled trigger, overblown and unspoken worries, "Launch call:
  phase, ...", "Before launch: re-run the pre-mortem on must-fix 1.", a required Security
  pre-mortem with three scenarios, and the default More on request line. Directly imitable.
- precision: 2, the round 4 residual is closed: `example.md` line 64 now reads
  "| # | Risk | Likelihood | Impact | Mitigation | Owner role |", matching SKILL.md line 98
  and step 3 ("a likelihood, an impact, a mitigation and an owner role", 54-55), so one
  concept has one name across the folder. The two optional nits from round 4 are also
  closed: "an empty section says \"None.\"" (81) and the shape line "Before launch: re-run
  the pre-mortem on must-fix <numbers>   (none open: re-run if the plan changes)" (106).
  Caps have a decidable unit ("at most 3 real threats in total across the three timing
  buckets", 67-68; "at most 5 claims", 41). Every command name resolves to an existing
  skill and a `docs/system-map.md` entry (`/odeo:critique` 63, `/odeo:experiments` 38,
  `/odeo:research` 39, `/odeo:strategy` 46, `/odeo:second-opinion-pm` 132); paths
  (`.claude/tasks/todo.md`, `${CLAUDE_PLUGIN_ROOT}/scripts/resolve-language.sh`,
  `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`) are exact. The `<N>`, `<numbers>`, `<reason>` tokens
  are slots in a declared output shape, not placeholders. No TBDs. Remaining wording nits
  are listed as optional fixes and do not drop the criterion below "exact throughout".
- safety integration: 2, "**Both passes:** a threshold or trigger you propose is labelled
  as a proposal, and a market fact or benchmark is cited or marked unverified
  (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 6)." (76-78), plus "checked with
  `/odeo:research` or marked unverified" (47-48), "never a person's name" (59) and "never an
  invented calendar date" (60). Guardrails 7 is referenced, not restated (82, 140-141). The
  Security pre-mortem section applies the baseline's design-time pre-mortem for auth, PII,
  payments and uploads (70-74). Ledger writes go to `.claude/tasks/todo.md` only for
  findings "the user wants to act on" (124-126), consistent with AGENTS.md Guardrails 1,
  which names `/odeo:critique` follow-ups as carrying the user's OK.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10
Reached. Nothing caps structurally.

## Top fixes
None required. Optional wording nits, none of which changes the score:
1. Line 106: write the empty-bucket form as the literal printed line rather than an
   annotation, for example a second shape line
   "Before launch: no must-fix items open; re-run the pre-mortem if the plan changes."
   Today an agent has to compose the printed text from "(none open: re-run if the plan
   changes)", so two runs may phrase it differently.
2. Line 122, "Revise the PRD; capture security findings as requirements.": name the actor.
   Read next to line 128 ("If the PRD was revised"), it is unclear whether the skill edits
   the PRD itself or advises the user to. Suggested: "Offer to revise the PRD; when the
   user agrees, capture security findings as requirements in it."
3. `example.md` line 65: the separator cell under "Mitigation" is still sized for the old
   word (`|----------|`). Cosmetic only; Markdown renders it correctly.

## Other checks
- Map duty: no new command added. `/odeo:critique` is on `docs/system-map.md` line 63.
  Satisfied.
- One-level-deep rule and size: satisfied (142 lines; one supporting file, no deeper chain).
- Integrity: first-party skill, not a community contribution; the verbatim-copy check does
  not apply.
- Not scored, flagged for the human: lines 128-129 tell the agent to open a revised PRD with
  `code -r <file>`. The maintainer's own preference recorded elsewhere is not to open an
  editor after saving a PRD and to give the path instead. This is a preference conflict,
  not a standard violation, so it is outside this rubric; decide whether the line should
  default to "give the path".
- Behaviour: this round's changes (the "Mitigation" header, the "None." rule, the
  none-open form) are form fixes. No run has yet hit an empty must-fix bucket or a 30-day
  item, so whether agents copy the new header and the none-open form is untested; an
  `/odeo:improve` subagent run with a plan that has no must-fix threat and one 30-day threat
  would show it.
- Loop note: round 4 already returned PASS, so this round is a re-anchor after the rebase
  plus the comment fixes in eb58580, not a fifth round of an unconverged loop.

## Vs previous version
9/10 -> 10/10. Precision 1 -> 2: the single residual from round 4 (`example.md` heading the
30-day table "Response" while the shape says "Mitigation") is fixed, and both optional
round 4 nits (printed form for empty sections and for no must-fix items) are applied.
Trigger clarity, structure, worked example and safety integration stay 2.

## History
- 2026-11-03 (v1, Round 1, 17af699): baseline after USR-030. PASS 8/10. Precision 1 (output
  shape omits Strongest case and the ranking and top-pick lines; "top-ranked" defined twice;
  Fails if and Kill criterion not distinguished). Safety integration 1 (silent on
  Guardrails 6 where the process asks for thresholds and evidence).
- 2026-11-03 (v2, Round 2, 633b15c): round 1 fixes 1 to 5 applied, fix 6 declined with a
  reason that was accepted; a single default "More on request" line added from the adoption
  review. PASS 10/10. Residual: three optional wording nits. Verdict line replaced, PASS to
  PASS.
- 2026-11-03 (v3, Round 3, f8239c1): USR-031 rewrote Pass 2 and its Output shape;
  `example.md` gained a pre-mortem part. PASS 9/10. Precision 2 -> 1 (cap without a
  decidable unit, re-run without a slot, 30-day fields only in the shape). Verdict line
  replaced, PASS to PASS.
- 2026-11-03 (v4, Round 4, 5067d5d): round 3 fixes applied, fix 5 only in SKILL.md. PASS
  9/10. Precision stays 1: `example.md` line 64 still headed the 30-day table "Response".
  Verdict line replaced, PASS to PASS.
- 2026-11-04 (v5, re-anchor after rebase onto main, e8c3a25): scored fresh. The "Response"
  header is now "Mitigation"; empty sections print "None."; the Before launch line has a
  none-open form. PASS 10/10, precision 1 -> 2. Verdict line replaced, PASS to PASS;
  reviewed_commit moved 5067d5d -> e8c3a25.
