---
type: calibration
date: 2026-10-02
artifact: docs/checklists/review-calibration.md scenarios 3 and 4, skills/build/SKILL.md B5.3
scorer: the orchestrating session (Claude), by rules written before the runs
model: claude-opus-5-5[1m] (the scorer, and the 12 agents, which inherited the session model)
model_tier: strongest
reps: 5, 5, 2
---

# Calibration: the plan human layer, measured on behavior

The plan format (docs/plan-format.md, rubric criterion 6) says a choice that lives only in the
technical layer is a plan-review finding, and /odeo:build B5.3 says the gate shows the plan's
Summary as written. Both were reviewed as text. This note measures whether agents behave so.

## Run 2, BLIND (2026-10-02, format at ff6ee09, after narrowing the Risks class)
Every number below is recomputed by
`python3 docs/calibration-runs/2026-10-02-blind/recount.py`, which reads the archived
outputs in that directory (with GRADING.md, the rules written before the runs) and prints
the runs behind each count. Its sentence matching is a heuristic; the run names let a human
open each one and confirm.

Each of the 12 runs had its own fresh `mktemp` directory holding ONLY the seed (as plan.md),
the story (story.md), the agent's instruction file and every file it names by path, derived
by grep of `${CLAUDE_PLUGIN_ROOT}/...` (reviewer: AGENTS.md, docs/plan-format.md; build:
AGENTS.md, eval-framework.md, plan-format.md and four scripts). The format copied was ff6ee09,
which already carries the stop-rule exclusion. The copy set was grepped for the answer
(`due_date`, the seed and scenario names) and holds none. Agents were told to read nothing
outside their directory; nothing enforces that, so "blind" means the answer was not within
the directory they were given.

| Scenario | Result |
|---|---|
| 3. decision missing from Summary | 5/5 PASS (r-a1..r-a4 Important, r-a5 Blocking; every remedy names `What you decide`) |
| 4. technical decision left alone | 5/5 PASS (none asked; r-b1 named it, as a strength) |
| B5.3 gate shows the Summary | 2/2 PASS: 5/5 bullets verbatim, and the first "file map" text comes after the Summary |
| Risks stop rule asked for in the Summary or `What you decide` (recorded) | 0/10 (run 1: 7/10 Important); 5/10 (r-a3, r-a4, r-b2, r-b4, r-b5) said it is correctly kept out |

The B5.3 order check is a HEURISTIC: it finds the first "file map" text anywhere. A gate that
says "see the file map below" above the Summary would fail a correct output, and so would a
correct output whose map carries another label ("Files touched"), since the check requires the
text "file map". It was shown to react on copies of the
outputs, a one-word paraphrase (4/5) and a "File map first." line added at the top; those
copies were not archived, so that demonstration is self-attested.

What this run can and cannot say: the stop-rule requests fell from 7/10 to 0/10, but run 2
changed the format AND the blinding together, so it cannot separate the two causes, and 10
runs is a small sample. The planted catch held at 5/5 under both. The narrowing is kept on
that evidence and on the format's reading at ff6ee09 (Risks then defined as the builder's
questions), not on the drop alone. Since then the Risks template names two kinds, each item
marked `stop rule:` or `gate:`; that marker version has NOT been run against agents yet, so
this run is evidence for the narrowed class, not for the markers.

Limits that still apply to run 2:
- Contamination: the runs were in a session whose user global CLAUDE.md carries the same
  plan-shape rule.
- Simulated, not dispatched: fresh general-purpose agents followed the copied agent files; the
  installed plugin (0.3.2) would have run the old reviewer.
- The with-me test (a plan for a user without that global) was not run; it needs an isolated
  environment.

## Run 1, not blind (history, superseded by run 2)

### Method
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
  bullet in a copy of a run output made it report FAIL (4/5), so it can fail (self-attested:
  the paraphrased copy was not kept). That the Summary
  comes before the file map was checked BY HAND (line numbers), not by the script.

### Limits, stated
- Contamination: every agent ran in a session whose user global CLAUDE.md carries the same
  plan-shape rule, which may lift results above what a user without it would see.
- Not blind: the grading rules and earlier run outputs sat in the same directory as the seeds,
  and the checklist describing the scenarios was on the branch the agents were told to read.
  No run output names or quotes them, but within reach is not blind. The checklist's run steps
  now require a scratch directory holding only the seed and story; a blind re-run would make
  these results stronger.
- The third requested test (a with-me plan for a user without that global) was NOT run: it
  needs an isolated environment.

### Results
| Scenario | Bar | Result |
|---|---|---|
| 3. decision missing from Summary | raised, important+, surfaced to the human | 5/5 PASS (all Important; each remedy offered "match the story, or keep it and name it in `What you decide`") |
| 4. technical decision left alone | no request to lift it into the human layer | 5/5 PASS (none asked; one run praised it as a clean seam) |
| B5.3 gate shows the Summary | 5 bullets verbatim, before the file map | 2/2 PASS (5/5 bullets each; Summary at line 4 and 3, file map at 16 and 15) |

### Findings beyond the bar (real flaws in the seeds, not planted)
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
  to you during the build". Since decided (ff6ee09): line 73 narrowed to the questions the human answers, and the
  Risks template (now :186) marks each item `stop rule:` or `gate:`.
