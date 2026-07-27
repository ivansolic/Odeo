---
artifact: skills/build/SKILL.md
type: skill
artifact_version: 4
date: 2026-07-27
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: form review of the for-me editor-policy change. Mode B (for-me) no longer
offers to open/add the worktree to the user's editor; that live-watch affordance
now belongs solely to with-me (Mode A). Three coordinated edits: B4 retitled
"Orientation (for-me does NOT open the editor)" with the interactive `code --add`
offer replaced by a one-line orientation note; the "Editor (both modes, one rule)"
paragraph's closing sentence split by mode with a cross-reference to B4; the
worked-example line swapped from the old `code --add` offer to a headless-review
parenthetical. Whole skill re-scored for consistency.

## Skill: build  (explicit command)

## Scores
- trigger clarity 2: `disable-model-invocation: true` + description opens "Build
  one or more ready user stories. Two modes you choose..." with an example
  invocation. Correct explicit-command format, untouched by this change.
- structure 2: Still follows the body shape and is lean (232 lines < 500); no
  supporting files, so the one-level rule is not at risk. The change is a net
  simplification: B4 (lines 136-141) drops an interactive branch for a one-line
  orientation note, and the "Editor (both modes)" paragraph now carries a crisp
  two-clause split (lines 65-66). No wall of text.
- worked example 2: Lines 196-214 remain concrete with real values
  (`docs/plans/2026-07-14-usr-012-timer.md`, `../dogfood-usr-012`, `12/12
  APPROVE`). The refreshed line 210 "(builder runs headless in its worktree;
  nothing changes in your editor, you review at the gate)" mirrors B4 exactly, so
  the example does not lag the edited step.
- precision 2: Exact throughout. B4 names the exact review locus ("B6: diff +
  reviewer verdicts") and the exact reason ("a still editor is not mistaken for a
  stall"). No TBDs, no vagueness.
- safety integration 2: References guardrails without restating them, and weakens
  none. The change removes a display-only affordance; the plan gate (B5.3,
  "No builder runs without an approved plan"), the ENFORCED `boundary-check.sh`
  (B6), and the merge gate (B7) are all untouched. Zero enforcement changed.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Consistency verdict (the gating question)
CORRECT and internally consistent.
- Mode A (with-me) STILL opens/reveals the editor: A4 `code -r .` and
  `code -r -g <file>` are intact (line 79), and the "Editor (both modes)"
  paragraph reaffirms "With-me opens the editor by default" (line 65). Not
  contradicted anywhere.
- The "reuse, never multiply / `code -r` / `code --add`" rule still stands
  (lines 60-64) for with-me and for the spec-doc skills that reference it; it is
  now correctly scoped by the closing sentence so it no longer implies for-me
  opens the editor.
- Nothing dangles: the surviving `code --add` mention is in the general rule
  statement, not a for-me instruction; the B4 cross-reference resolves; the worked
  example no longer carries the removed offer.
- The mode distinction is sharper (for-me = review the RESULT at the gate;
  with-me = watch live), and the orientation value the removed offer used to
  provide is preserved by the explicit "nothing changes in their editor by
  design ... say this once" note in B4.

## Ceiling
Max reachable: 10/10, achieved. Explicit command (trigger clarity judged on plain
what-you-get, achieved); the change touches guardrail-adjacent text (editor policy
per mode), so safety integration reaches 2. Nothing is structurally capped.

## Non-blocking nits (would tighten, do not lower any score)
1. The "for-me does NOT open the editor" policy is now stated three times (B4
   title, B4 body, and the "Editor (both modes)" paragraph). Slightly more than
   "reference, don't restate", though each lands at a different reading entry
   point, so it is defensible. Shortest form would let B4 own the rule and have
   lines 65-66 point at it.

No em/en dashes present; English only. Confirmed.

## Map duty
No command surface added or altered (an editor-policy change on the existing
`/build`), so no `docs/system-map.md` delta is required. Not a finding.

## Round-by-round
- Round 1 (2026-07-27): 10/10 PASS. All five criteria held at 2. The
  editor-policy change is internally consistent (A4 intact, cross-references
  resolve, no dangling for-me editor reference) and touches no gate.

## Vs previous version
Version 3 (2026-07-25) scored 10/10 on the foreground-default guardrail. Version 4
removes the for-me editor-open offer. Score holds at 10/10; no regression on any
criterion. The change sharpens the mode contract and reduces surface without
weakening safety.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed
  to mirror the step. Gap closed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules. Correct and internally consistent with
  Mode B, B3 dials, B5, and the 2-4 / single-builder rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed (B4 retitle + orientation note, "Editor (both modes)" cross-reference
  split, worked-example line refreshed). Mode A editor step A4 confirmed intact
  and uncontradicted; the "reuse never multiply / code -r / code --add" rule still
  governs with-me and the spec-doc skills; no dangling for-me editor reference; no
  gate touched (plan gate, B6 boundary-check, merge gate unaffected). One
  non-blocking nit (policy stated three times); crosses no rubric boundary, so
  10/10 stands.

Note: this is a form review. The delta is partly behavioral (whether the agent
actually refrains from offering `code --add` in for-me and delivers the one-line
orientation instead); recommend an `/improve` subagent test to confirm the runtime
behavior. The file form is clean and ships.
