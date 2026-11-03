---
artifact: docs/depth-checklists/critique-1.md docs/depth-checklists/critique-2.md docs/depth-checklists/critique-3.md docs/depth-checklists/critique-4.md
type: adoption
branch: docs/prd-003-pm-content-depth
reviewed_commit: 5067d5d
date: 2026-11-03
scorer: adoption-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
verdict: PASS
---

# Adoption review: critique (red team and pre-mortem, R1 and R24, USR-030 and USR-031)

Round 4, a full re-judgment of all four checklists against the current files, not only the
re-quoted rows.

Inputs read in full: `.claude/agents/adoption-reviewer.md`; checklists `critique-1.md` to
`critique-4.md`; the sources at `07b34f6` (read as data): `pm-execution/skills/strategy-red-team/SKILL.md`,
`pm-execution/commands/red-team-prd.md`, `pm-execution/skills/pre-mortem/SKILL.md`,
`pm-execution/commands/pre-mortem.md`; `skills/critique/SKILL.md`; `skills/critique/example.md`;
PRD-003 (whole; R1 both halves and R24 judged). The format doc and the USR-030 and USR-031
stories were read in round 3 and are unchanged by the commits under review (as supplied);
Grep and Glob were not available in this session, so every file was opened by its path.
Copy check, eight pairs (SKILL.md and example.md against each of the four sources): no
output, exit 0 (as supplied). Source instruction-file check printed nothing (as supplied).

Source text addressing the reader: the persona lines "You are a sharp, fair adversary" (red-team
skill, line 10) and "You are a veteran product manager conducting a pre-mortem analysis"
(pre-mortem skill, line 10) address whoever runs the source method, not a reviewer, and do
not try to change how it is judged. Read as data, not followed. No red flag.

Verdict: PASS. All four checklists pass; comments below, none failing.

## critique-1 (source skill strategy-red-team): PASS

- **Completeness:** my own list (Context: not a pre-mortem, five beat twenty; steps 1 to 8
  with their decision rules; the step 6 fields; the step 8 template: title, Top
  Kill-Assumptions 3 to 5 with Claim, What's Well-Reasoned, What I Couldn't Assess; five
  Notes; Further Reading) is covered by rows 11 to 36. The step 3 good and bad example is
  matched in row 14 (Pass 1 step 3, Good and Bad lines).
- **Present rows:** Pass 1 is unchanged since round 3; every quoted line still exists and
  does the source job. Row 23's elided quote matches the current default line ("More on
  request: a second model's view, an experiment for the top claim, a rewrite of the riskiest
  section, ..."), and the On request block keeps "A second model's opinion:
  `/odeo:second-opinion-pm`."
- **Excluded rows:** 24 (title, adds length, decision named), 36 (author links). Closed list,
  duties met.
- **Frontmatter, method source line, row shape, no personal field:** all hold.

## critique-2 (source command red-team-prd): PASS

- **Completeness:** every source item (invocation examples; steps 1 to 4 with the step 3
  template and the three offers; five Notes) has a row (14 to 33).
- **Present rows:** quotes for rows 16 to 33 exist verbatim in the current SKILL.md; rows 26
  to 28 still match the default offer line and the On request block ("Turn the top claim
  into an experiment: `/odeo:experiments`.", "Run the pre-mortem alone, or rewrite the
  riskiest section of the plan."). Row 27 `default` holds: Pass 2 runs by default.
- **Excluded rows:** 14 and 15 (already covered, the description quote exists and starts the
  skill from any of the named inputs), 21 (title, adds length, decision named).
- **Other checks:** frontmatter matches; method source by reference; row shape valid; no
  personal field.

## critique-3 (source skill pre-mortem): PASS

- **Completeness:** my own list of the source (step 1 read plus web research; step 2 the 14
  day frame, failure, what went wrong, what we missed, overconfidence; step 3 one of three
  types with the Tiger, Paper Tiger and Elephant criteria; step 4 three urgency classes with
  examples; step 5 four action-plan fields; step 6 template: title, Tigers, Paper Tigers,
  Elephants, action plans; step 7 save; four Notes; Further Reading) has a row for every
  item (11 to 39).
- **Re-quoted rows:** row 23 (Track) quotes "or watch. ... A watched threat names its
  trigger, the early signal that would move it up." which is in Pass 2 step 3 and does the
  source's monitor-and-escalate job. Row 38 (revisit) quotes "Always end with the `Before
  launch:` line: re-run the pre-mortem on the must-fix items." (Pass 2 step 6) and the Output
  line "Before launch: re-run the pre-mortem on must-fix <numbers>"; both exist, the example
  prints "Before launch: re-run the pre-mortem on must-fix 1.", so the revisit is now in the
  default output, stronger than round 3. The 2 to 3 week interval stays out as a number
  without a source, which R1 and R24 do not ask for.
- **Other present rows:** quotes for rows 11, 12, 14 to 22, 25 to 28, 30 to 33, 35 to 37
  exist verbatim. Row 26's column "Mitigation" is in the must-fix table. Row 24 points at
  the example's pre-mortem part, which shows one must-fix row, one 30-day row and one watched
  risk with its trigger (see comment 1 on the 30-day header).
- **Row 13 (launch in 14 days), excluded as already covered:** the Pass 2 quote exists and
  gives the failure a concrete moment; the time anchor is the recorded maintainer decision
  (supplied). Accepted, as in round 3.
- **Row 27:** owner as a role, the person half dropped for R24's no-personal-field rule.
- **Excluded rows:** 29 (title), 34 (save as file), 39 (author links): closed list, duties met.
- **No personal fields:** both pre-mortem tables carry "Owner role", no name or contact.
- **Frontmatter, method source line, row shape:** all hold.
- **R1 pre-mortem half and USR-031:** three groups, three timing buckets, mitigation and
  owner role per must-fix threat, fixed Output shape.

## critique-4 (source command pre-mortem): PASS

- **Completeness:** every source item (invocation examples; step 1; step 2 frame and five
  categories; step 3 Tiger severity and handling, Paper Tiger and Elephant rules; step 4
  template: header, risk summary, two tables, Track, Paper Tigers, Elephants, Go/No-Go,
  save; step 5 three offers; five Notes) has a row (14 to 42).
- **Re-quoted rows:** row 20 (fast-follow) quotes "fix within 30 days" and "A 30-day threat
  gets a likelihood, an impact, a mitigation and an owner role." (Pass 2 step 3): a planned
  response with an owner, which is what the source asks. Row 29 quotes "| # | Risk |
  Likelihood | Impact | Mitigation | Owner role |" from the Output block, verbatim; every
  source column is carried, planned response as Mitigation. Row 27 (risk summary, adds
  length) quotes the cap rule verbatim; the counts only restate sections of at most three
  items each, so the exclusion sorts, ranks, times or assigns nothing.
- **Other present rows:** row 28's must-fix header verbatim; row 33 `on request` with all five
  Go/No-Go items and the go or no-go itself in the default Launch call; rows 36 and 37
  offered in the default line; row 35 "Revise the PRD; capture security findings as
  requirements."; row 42 "Many must-fix threats mean phase or delay."
- **Excluded rows:** 14 and 15 (description cover, as in critique-2), 26 (header, decision
  named), 27 (above), 34 (save, decision named).
- **Other checks:** frontmatter matches; method source by reference to critique-3; row shape
  valid; no personal field.

## Comments (not failing)

1. **example.md, `### Fix within 30 days` header:** the example's table reads "| # | Risk |
   Likelihood | Impact | Response | Owner role |", while SKILL.md's Output template says
   "Mitigation". No checklist row quotes the example header (critique-4 row 29 quotes the
   Output block, which is right), and the example row still carries the planned response,
   so no source item is lost. But the worked example now disagrees with the fixed shape it
   illustrates; that is a skill-craft defect for `skill-reviewer`, not an adoption one.
2. **Threat cap and the source's "default to Tiger when unsure":** "at most 3 real threats in
   total across the three timing buckets" with "When unsure, call it a real threat." means an
   unsure fourth risk is dropped rather than kept as a Tiger. Row 36's quote exists and does
   the job for the risks that are kept; how many to keep is a method choice outside this
   review's remit (H1 bloat), not a lost item. Likewise "Many must-fix threats" (row 42) now
   means two or three.
3. Round 3 comments 1 (critique-3 row 13 framing), 2 (save-as-file rows) and 3 (critique-4
   row 24, political risks) still apply unchanged and are not repeated.

## History
- 2026-11-03: first review at 17af699. FAIL on critique-2: row 14 (invocation examples)
  pointed at example.md, which shows no invocation form; rows 26 to 28 (Step 4 offers)
  were marked `on request` but nothing offered them. Comment on critique-1 row 23 with the
  same root cause.
- 2026-11-03: re-review at 633b15c. Row 14 now excluded as already covered by the
  description; SKILL.md Output gained the default offer line and the On request block;
  rows 23, 26, 27 and 28 re-quote those lines. Both checklists re-judged in full. Verdict
  FAIL replaced by PASS; two non-failing comments.
- 2026-11-03: re-review at f8239c1 with new scope. The skill now adopts the pre-mortem
  (USR-031): checklists critique-3 and critique-4 added; SKILL.md Pass 2 rewritten, Output
  gained the pre-mortem sections; example.md gained a pre-mortem part. critique-2 row 27
  changed to `default`. All four checklists re-judged in full. Verdict stays PASS; three
  non-failing comments.
- 2026-11-03: re-review at 5067d5d. SKILL.md gained the real-threat cap (at most 3 across the
  buckets), the `Before launch:` re-run line in step 6 and Output, "Mitigation" in both
  pre-mortem tables, the fields a 30-day threat needs in step 3, and the proposal rule now
  covers both passes; example.md gained a security pre-mortem and the `Before launch:` line.
  Re-quoted rows: critique-3 rows 23 and 38, critique-4 rows 20, 27 and 29; all quotes
  verified verbatim. All four checklists re-judged in full. Verdict stays PASS; two new
  non-failing comments (example 30-day header still "Response"; the cap against default to
  Tiger).
