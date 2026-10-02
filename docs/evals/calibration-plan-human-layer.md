---
type: calibration
date: 2026-10-02
scenarios: review-calibration 3, 4, and the build B5.3 gate presentation
reps: 5, 5, 2
model_tier: strongest
---

# Calibration: the plan human layer, measured on behavior

The plan format (docs/plan-format.md, rubric criterion 6) says a choice that lives only in the
technical layer is a plan-review finding, and /odeo:build B5.3 says the gate shows the plan's
Summary as written. Both were reviewed as text. This note measures whether agents behave so.

## Method
- Seeds: tests/fixtures/calibration/ (story USR-014, two plans). Grading rules were written
  BEFORE any run and were not changed after.
- Reviewer runs: fresh general-purpose agents told to act as `architecture-reviewer` by
  following agents/architecture-reviewer.md and docs/plan-format.md from the branch worktree.
  Not the dispatched agent: the installed plugin was 0.3.2, whose body has no criterion 6, so
  dispatching `odeo:architecture-reviewer` would have tested the old instructions. Tools and
  system prompt therefore differ from a real dispatch.
- B5.3 runs: fresh agents acting as the /odeo:build orchestrator at B5 step 3 per
  skills/build/SKILL.md, given plan-technical-decision-only.md as reviewed clean. Graded by a
  script: each of the five Summary bullets must appear verbatim (whitespace aside), and the
  Summary must come before the file map. The script was shown to FAIL on a paraphrase.
- Contamination, stated: every agent ran in a session whose user global CLAUDE.md carries the
  same plan-shape rule, which may lift results above what a user without it would see. The
  third requested test (a with-me plan for a user without that global) was NOT run for that
  reason; it needs an isolated environment.

## Results
| Scenario | Bar | Result |
|---|---|---|
| 3. decision missing from Summary | flagged, important+, surfaced to the human | 5/5 PASS (all Important, all tied to `What you decide`) |
| 4. technical decision left alone | no request to lift it into the Summary | 5/5 PASS (none asked; one run praised it as a clean seam) |
| B5.3 gate shows the Summary | 5 bullets verbatim, before the file map | 2/2 PASS (5/5 bullets each; Summary at line 4 and 3, file map at 16 and 15) |

## Findings beyond the bar (the seeds had flaws I did not plant)
- **The formula guard changes titles.** 8 of 10 reviewer runs raised that prefixing `-` (and
  `=`, `+`, `@`) changes a title like "-1 day buffer", against criterion 4's "unchanged", and
  that the Summary does not say so. A real defect in my seed, caught as criterion 6 intends.
- **A builder stop rule read as a human decision.** 6 of 10 runs (all five on scenario 3, one
  as a note on scenario 4) flagged the Risks line "if
  `listTasks` returns due dates as strings, stop and ask" as an open question missing from
  `What you decide`. That is the format applied as written ("every open question in Risks"),
  but the line is a builder stop rule, not a choice for the gate. Either the format narrows
  the class to questions the human answers, or architects keep builder stop rules out of
  Risks. A format decision, recorded for the human, not changed here.
