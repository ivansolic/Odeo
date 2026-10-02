---
type: calibration
date: 2026-10-02
artifact: docs/checklists/review-calibration.md scenarios 3 and 4, skills/build/SKILL.md B5.3
scorer: the orchestrating session (Claude), by rules written before the runs
model: claude-opus-5-5[1m]
model_tier: strongest
reps: 5, 5, 2
---

# Calibration: the plan human layer, measured on behavior

The plan format (docs/plan-format.md, rubric criterion 6) says a choice that lives only in the
technical layer is a plan-review finding, and /odeo:build B5.3 says the gate shows the plan's
Summary as written. Both were reviewed as text. This note measures whether agents behave so.

## Method
- Seeds: tests/fixtures/calibration/ (story USR-014 and two plans, since renamed to the neutral
  plan-usr-014-a.md and -b.md; the runs used neutral copies, plan-s3.md and plan-s4.md).
- Grading rules were written to a file before any run and not changed after. That ordering is
  self-attested: nothing but the file's own header and this session's history shows it.
- Reviewer runs: fresh general-purpose agents told to act as `architecture-reviewer` by
  following agents/architecture-reviewer.md and docs/plan-format.md from the branch worktree.
  Not the dispatched agent: the installed plugin was 0.3.2, whose body has no criterion 6, so
  dispatching `odeo:architecture-reviewer` would have tested the old instructions. Tools and
  system prompt therefore differ from a real dispatch.
- B5.3 runs: fresh agents acting as the /odeo:build orchestrator at B5 step 3 per
  skills/build/SKILL.md, given plan-usr-014-b.md as reviewed clean. A script checked that each
  of the five Summary bullets appears verbatim (whitespace aside); a one-word paraphrase of one
  bullet in a copy of a run output made it report FAIL (4/5), so it can fail. That the Summary
  comes before the file map was checked BY HAND (line numbers), not by the script.

## Limits, stated
- Contamination: every agent ran in a session whose user global CLAUDE.md carries the same
  plan-shape rule, which may lift results above what a user without it would see.
- Not blind: the grading rules and earlier run outputs sat in the same directory as the seeds,
  and the checklist describing the scenarios was on the branch the agents were told to read.
  No run output names or quotes them, but within reach is not blind. The checklist's run steps
  now require a scratch directory holding only the seed and story; a blind re-run would make
  these results stronger.
- The third requested test (a with-me plan for a user without that global) was NOT run: it
  needs an isolated environment.

## Results
| Scenario | Bar | Result |
|---|---|---|
| 3. decision missing from Summary | raised, important+, surfaced to the human | 5/5 PASS (all Important; each remedy offered "match the story, or keep it and name it in `What you decide`") |
| 4. technical decision left alone | no request to lift it into the human layer | 5/5 PASS (none asked; one run praised it as a clean seam) |
| B5.3 gate shows the Summary | 5 bullets verbatim, before the file map | 2/2 PASS (5/5 bullets each; Summary at line 4 and 3, file map at 16 and 15) |

## Findings beyond the bar (real flaws in the seeds, not planted)
- **The formula guard changes titles.** 8 of 10 reviewer runs raised, as a finding, that
  prefixing `-` (and `=`, `+`, `@`) changes a title like "-1 day buffer", against criterion
  4's "unchanged", and that the Summary does not say so (counted by reading each finding, not
  only its heading). Criterion 6 working as intended, on a defect I did not plant.
- **A builder stop rule read as a human decision.** All 10 runs mention the Risks line "if
  `listTasks` returns due dates as strings, stop and ask"; 7 rank it Important as an open
  question missing from `What you decide`, 3 as a note, and three scenario-4 runs called it a
  builder stop rule themselves. The conflict is inside the format: docs/plan-format.md:184
  defines Risks as "anything ambiguous the builder must ASK about rather than decide alone",
  while :73 puts "every open question in Risks" under `What you decide`. Options for the
  human: narrow :73 to questions the human answers; move builder stop rules out of Risks
  (redefining :184); or keep both and say once in the Summary that "a question may come back
  to you during the build". A format decision, recorded here, not changed.
