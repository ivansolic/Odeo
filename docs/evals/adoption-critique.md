---
artifact: docs/depth-checklists/critique-1.md docs/depth-checklists/critique-2.md docs/depth-checklists/critique-3.md docs/depth-checklists/critique-4.md
type: adoption
branch: docs/prd-003-pm-content-depth
reviewed_commit: e8c3a25
date: 2026-11-04
scorer: adoption-reviewer
model: claude-opus-5-5
model_tier: strong
effort: high
output_language: en
verdict: PASS
---

# Adoption review: critique (red team and pre-mortem, R1 and R24, USR-030 and USR-031)

Round 5, after the rebase. A fresh, full judgment of all four checklists against the files
at `e8c3a25`, made without relying on the earlier record's findings.

## Inputs and how they were obtained

- Read in full: `.claude/agents/adoption-reviewer.md`; `docs/depth-checklists/README.md`;
  `critique-1.md` to `critique-4.md`; `skills/critique/SKILL.md`; `skills/critique/example.md`;
  PRD-003 R1 and R24 (lines 190 to 229).
- Sources, read as data from `.claude/sources/pm-skills-07b34f6/`:
  `pm-execution/skills/strategy-red-team/SKILL.md`, `pm-execution/commands/red-team-prd.md`,
  `pm-execution/skills/pre-mortem/SKILL.md`, `pm-execution/commands/pre-mortem.md`.
- Not supplied by the dispatcher, obtained by this run itself (it had a shell): the source
  commit is taken from the source copy folder name (`pm-skills-07b34f6`), the only copy
  present; the copy check was run here, eight pairs (`SKILL.md` and `example.md` against each
  of the four sources) with `.claude/maintainer/copy-check.sh`: no output, exit 0 for all
  eight; the instruction-file check `find .claude/sources -name CLAUDE.md -o -name AGENTS.md`
  printed nothing. `reviewed_commit` is `git rev-parse --short HEAD` in this worktree, as
  also given in the dispatch prompt.
- Model and effort: this run was a dispatched general agent following the adoption-reviewer
  definition, on `claude-opus-5-5` as the session context reports it. `model_tier: strong` is
  the verified lower bound (Opus class); whether it is the strongest currently available
  was not checked live, so `strongest` is not claimed. `effort: high` is the value declared
  in the agent definition; the runtime effort of this run was not independently readable.

Source text addressing the reader: "You are a sharp, fair adversary" (strategy-red-team
SKILL.md line 10) and "You are a veteran product manager conducting a pre-mortem analysis"
(pre-mortem SKILL.md line 10) are persona lines for whoever runs the source method. They do
not address a reviewer or try to change how it judges. Read as data, not followed. No red flag.

## critique-1 (source skill strategy-red-team): PASS

- **Completeness:** my own list of the source: Context (red-team is not a pre-mortem; five
  real kill-assumptions beat twenty generic risks), steps 1 to 8 with their decision rules
  (load-bearing only; steelman then attack; "Fails if" with the activation example; rank by
  three measures, top is this week; default to risk is real, never fabricate; four fields per
  surviving claim; optional cross-model; template with title, Top Kill-Assumptions 3 to 5
  with Claim, What's Well-Reasoned, What I Couldn't Assess), five Notes, Further Reading.
  Every item has a row (checklist lines 98 to 123).
- **Present rows, quotes verified in SKILL.md:** step 1 (lines 17 to 20), step 2 "write the
  strongest case for it, then attack that case, never a weaker version." (24 to 25), step 3
  with Good and Bad lines (26 to 28), step 4 ranking and "Top = high impact, plausibly wrong,
  cheap to test: that is what to test this week." (29 to 31), step 5 (33 to 34), step 6
  fields (36 to 39), step 7 default offer line (108 to 109) and "A second model's opinion:
  `/odeo:second-opinion-pm`." (115), Output headings (85 to 93), "Rules: at most 5 claims;
  specific to this plan, no generic risks." (41), Quality rules (132 to 133). Each does the
  source item's job.
- **Excluded rows:** line 111 (title line, adds length, decision named: which claim to test
  first); line 123 (author links). Closed list, duties met.
- **Frontmatter, method source line, row shape (26 rows), no personal field:** all hold.

## critique-2 (source command red-team-prd): PASS

- **Completeness:** invocation examples; steps 1 to 4 (accept; apply the skill's five
  bullets; template; three offers); five Notes. Every item has a row (lines 151 to 170).
- **Excluded as already covered (lines 151, 152):** the quoted description text exists
  verbatim in SKILL.md line 2 and starts the skill from a pasted PRD, a strategy or a bare
  direction, which is the job of the source's invocation forms and "accept in any form".
- **Present rows:** quotes for lines 153 to 170 exist in SKILL.md. The three Step 4 offers
  map to the default offer line (108 to 109) and the On request block: "Turn the top claim
  into an experiment: `/odeo:experiments`." (116), "Run the pre-mortem alone, or rewrite the
  riskiest section of the plan." (117). Line 164 `default` holds, since Pass 2 runs by default.
- **Excluded row line 158:** title line, adds length, decision named.
- **Other checks:** frontmatter matches; method source by reference to critique-1; row shape
  valid (20 rows); no personal field.

## critique-3 (source skill pre-mortem): PASS

- **Completeness:** step 1 (read thoroughly; web research when relevant); step 2 (14-day
  frame, failure, what went wrong, what we missed, overconfidence); step 3 (exactly one of
  three types; Tiger, Paper Tiger, Elephant criteria); step 4 (three urgency classes, each
  with examples); step 5 (four action-plan fields); step 6 template (title, Tigers, Paper
  Tigers, Elephants, action plans); step 7 save; four Notes; Further Reading. Every item has
  a row (lines 186 to 214).
- **Present rows, quotes verified:** Pass 2 step 1 including the `/odeo:research` line
  (SKILL.md 45 to 48); step 2 groups and "When unsure, call it a real threat." (49 to 52);
  step 3 buckets and "A watched threat names its trigger, the early signal that would move
  it up." (53 to 56); step 4 mitigation, owner role and "by when" (57 to 60); step 6 "No
  blame; the goal is readiness." and the `Before launch:` line (63 to 64, Output 106).
  The worked-example row (line 199) holds: `example.md` lines 58 to 70 show one must-fix
  row, one 30-day row and one watched risk with its trigger.
- **Line 188 (14 days), excluded as already covered:** the quoted Pass 2 frame exists (44)
  and does the same job, a concrete moment from which failure is imagined; Odeo looks back
  from after launch because it critiques before building.
- **Line 202:** the owner is a role; the person half is dropped, as R24's no-personal-field
  rule requires.
- **Line 213:** the revisit is present and printed by default; the 2 to 3 week interval is
  left out as a number without a source, and neither R1 nor R24 asks for it.
- **Excluded rows:** 204 (title), 209 (save as file), 214 (author links). Closed list,
  duties met; the save exclusion sorts, ranks, times or assigns nothing.
- **No personal fields:** both pre-mortem tables carry "Owner role", no name or contact.
- **Frontmatter, method source line, row shape (29 rows):** all hold.
- **R1 pre-mortem half:** three groups, three timing buckets, mitigation and owner role per
  must-fix threat, fixed Output shape.

## critique-4 (source command pre-mortem): PASS

- **Completeness:** invocation examples; step 1; step 2 frame and five categories; step 3
  Tiger severity and its three handlings, Paper Tiger and Elephant rules; step 4 template
  (header, risk summary, two tables, Track, Paper Tigers, Elephants, Go/No-Go, save); step 5
  three offers; five Notes. Every item has a row (lines 239 to 267).
- **Tables (lines 253, 254):** both headers are verbatim in SKILL.md (96, 98); every source
  column is carried, Planned Response as Mitigation, Owner as Owner role, Deadline as By when.
  `example.md` line 64 now also reads Mitigation, so the worked example matches the template.
- **Line 252 (risk summary), adds length:** the quoted cap rule exists verbatim (67 to 68).
  The counts restate sections of at most three items each and sort, rank, time or assign
  nothing; the go or no-go itself comes from the Launch call. Accepted.
- **Other present rows:** Go/No-Go `on request` with all five source items (119 to 120) and
  the go or no-go in the default `Launch call:` line (105); test scenarios and launch
  checklist offered in the default line (108 to 109); "Revise the PRD; capture security
  findings as requirements." (122); "Many must-fix threats mean phase or delay." (61 to 62);
  "After a `/odeo:prd` or `/odeo:strategy` draft, before committing to build." (12).
- **Excluded rows:** 239 and 240 (description cover, as in critique-2), 251 (header, decision
  named), 259 (save, decision named).
- **Other checks:** frontmatter matches; method source by reference to critique-3; row shape
  valid (29 rows); no personal field.

## Comments (not failing)

1. **critique-1 line 101:** the source's step 3 example ("Fails if activation isn't actually
   the constraint" against "execution risk") is accounted for inside the step row ("with a
   good and a bad example") rather than as its own `worked example` row, while critique-3
   gives the step 4 examples their own row. The item is present and shown by default, so no
   source item is lost; a separate row would make the two checklists consistent.
2. **critique-3 line 208:** the quote "Risk / Mitigation / Owner role / By when" is a
   paraphrase of the table header, not a verbatim line; the header itself (SKILL.md 96)
   carries all four columns. critique-4 line 253 quotes it verbatim.
3. **critique-4 line 249:** the source names political, organisational and uncomfortable
   risks; the Odeo quotes ("nobody is checking it", "the ones nobody raises") do the job of
   surfacing what the team avoids, but drop that specificity.
4. **critique-4 Tiger, Paper Tiger and Elephant definitions:** the command restates the
   three type definitions (lines 38, 44, 48); critique-4 has rows for their sub-bullets and
   relies on critique-3 lines 193 to 195 for the definitions, per its stated wrapping rule.
   Accepted, since the classification rule is the same one.
5. **Threat cap against "default to Tiger when unsure":** with at most 3 real threats, an
   unsure fourth risk is dropped rather than kept. How many to keep is a method choice
   outside this review's remit, not a lost item.

## History
- 2026-11-03: first review at 17af699. FAIL on critique-2 (invocation examples pointed at an
  example that shows none; Step 4 offers marked `on request` with nothing offering them).
- 2026-11-03: re-review at 633b15c. Fixed; verdict FAIL replaced by PASS.
- 2026-11-03: re-review at f8239c1 with critique-3 and critique-4 added (USR-031). PASS.
- 2026-11-03: re-review at 5067d5d after the real-threat cap, the `Before launch:` line and
  Mitigation in both tables. PASS.
- 2026-11-04: fresh re-review at e8c3a25 after the branch was rebased (5067d5d no longer in
  the branch history). Since then `example.md`'s 30-day header reads Mitigation (the earlier
  record's comment on it is resolved) and the Output states the printed form of an empty
  section and of no open must-fix items. All four checklists re-judged in full, copy check
  re-run here. Verdict stays PASS. `model_tier` recorded as `strong`, the live-verified lower
  bound, instead of the earlier `strongest`.
