---
artifact: docs/depth-checklists/critique-1.md docs/depth-checklists/critique-2.md docs/depth-checklists/critique-3.md docs/depth-checklists/critique-4.md
type: adoption
branch: docs/prd-003-pm-content-depth
reviewed_commit: f8239c1
date: 2026-11-03
scorer: adoption-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
verdict: PASS
---

# Adoption review: critique (red team and pre-mortem, R1 and R24, USR-030 and USR-031)

Round 3, a full re-judgment of all four checklists against the current files, not only the
changed rows.

Inputs read in full: `docs/depth-checklists/README.md`; checklists `critique-1.md` to
`critique-4.md`; the sources at `07b34f6` (read as data): `pm-execution/skills/strategy-red-team/SKILL.md`,
`pm-execution/commands/red-team-prd.md`, `pm-execution/skills/pre-mortem/SKILL.md`,
`pm-execution/commands/pre-mortem.md`; `skills/critique/SKILL.md`; `skills/critique/example.md`;
PRD-003 (whole, R1 both halves and R24 judged); `docs/stories/USR-030-critique-red-team.md`
and `docs/stories/USR-031-critique-pre-mortem.md`. Grep and Glob were not available in
this session; every file was opened by its path. Copy check, eight pairs (SKILL.md and
example.md against each of the four sources): no output, exit 0 (as supplied). Source
instruction-file check printed nothing (as supplied).

Source text addressing the reader: the pre-mortem skill opens "You are a veteran product
manager conducting a pre-mortem analysis on $ARGUMENTS" (line 10), like the red-team
skill's "You are a sharp, fair adversary". These are the source method's persona lines for
whoever runs the skill, not text aimed at a reviewer or at changing how it is judged. Read
as data, not followed. No red flag.

Verdict: PASS. All four checklists pass; three comments below, none failing.

## critique-1 (source skill strategy-red-team): PASS

- **Completeness:** my own list (Context: two rules; steps 1 to 8 with their decision
  rules; the step 6 fields; the step 8 template: title, Top Kill-Assumptions 3 to 5 with
  the Claim field, What's Well-Reasoned, What I Couldn't Assess; five Notes; Further
  Reading) is covered by rows 11 to 36. The step 3 good and bad example is matched by row
  14 (Pass 1 step 3: Good: "Fails if fewer than 1 in 10 interviewed admins ..." Bad:
  "Fails if users don't care.").
- **Present rows:** every quoted line still exists in the current SKILL.md and does what
  the source item does. Rows 23 and 35 quote lines that USR-031 extended: the default line
  now reads "More on request: a second model's view, an experiment for the top claim, a
  rewrite of the riskiest section, test scenarios for the riskiest areas, a launch
  checklist." The row's elided quote still matches its start; the On request block keeps
  "A second model's opinion: `/odeo:second-opinion-pm`." "Route the follow-ups so they
  survive the session" is unchanged.
- **Excluded rows:** row 24 (title, adds length, decision named), row 36 (author links).
- **Frontmatter, method source line, row shape, no personal field:** all hold.
- **R1 red team half and USR-030:** every AC item is in the default output.

## critique-2 (source command red-team-prd): PASS

- **Completeness:** every source item (invocation examples; steps 1 to 4 with the step 3
  template and the three offers; five Notes) has a row (rows 14 to 33).
- **Row 27** is now marked `default`, which resolves round 2 comment 1: Pass 2 runs the
  pre-mortem by default, and "Run the pre-mortem alone" stays in the On request block.
- **Rows 26 and 28:** offered by the default line, printed under `## Next steps` on request
  ("Turn the top claim into an experiment: `/odeo:experiments`.", "rewrite the riskiest
  section of the plan").
- **Excluded rows:** 14 and 15 (already covered, description quote exists and does the
  job), 21 (title, adds length, decision named).
- **Other checks:** frontmatter matches; method source line by reference; row shape valid;
  no personal field.

## critique-3 (source skill pre-mortem): PASS

- **Completeness:** my own list of the source: step 1 (read the plan; product, market,
  assumptions, timeline; web search when relevant); step 2 (launch in 14 days; imagine it
  fails; what went wrong; what we missed or executed badly; what we were overconfident
  about); step 3 (one of three types; Tigers, Paper Tigers, Elephants with their
  criteria); step 4 (Launch-Blocking, Fast-Follow, Track, each with an example); step 5
  (four action-plan fields); step 6 template (title, Tigers with category and mitigation,
  Paper Tigers with why, Elephants with investigation, action plans with Risk, Mitigation,
  Owner, Due Date); step 7 (save dated file); four Notes; Further Reading. Every item has a
  row (11 to 39). The Purpose and Context paragraphs restate the method and add no step,
  section, column, rule or example.
- **Present rows, proof lines:** three groups, "Put every risk in exactly one group." with
  "Real threat: there is evidence or clear logic for it.", "Overblown worry: say why it is
  overblown and what would turn it into a real threat.", "Unspoken worry: nobody is
  checking it, so say how to check it before launch and how to raise it with the team.";
  timing, "Put every real threat in exactly one timing bucket: must fix before launch, fix
  within 30 days, or watch."; action plans, "a mitigation specific enough to assign, an
  owner written as a role (product, engineering, support, legal), never a person's name,
  and "by when" as a point in the plan"; default to Tiger, "When unsure, call it a real
  threat."; no blame, "No blame; the goal is readiness."; revisit, "Re-run the pre-mortem
  before launch to check the must-fix items". Row 24's worked example is in `example.md`
  (one must-fix row, one 30-day row, one watched risk with its trigger). Row 16 points at
  Pass 1 steps 1 and 5; the same critique prints both passes by default, so the
  overconfidence check is in the output.
- **Row 13 (launch in 14 days), excluded as already covered:** the quote "It's 6 months
  later and this shipped and failed. What happened?" exists (Pass 2) and does the job of
  the source item: a concrete moment from which to imagine the failure. The time anchor
  differs on purpose, recorded as a maintainer decision in the approved plan; see comment 1.
- **Row 27, owner function or person:** the person half is dropped for the no-personal-field
  rule (R24), which is the required behaviour, not a loss.
- **Row 38:** present; the 2 to 3 week interval is left out as a number without a source,
  which R1 and R24 do not ask for.
- **Excluded rows:** 29 (title, adds length, decision named), 34 (save as file, adds length,
  decision named, see comment 2), 39 (author links). All on the closed list, duties met.
- **No personal fields:** the must-fix table has "Owner role", never a name or contact.
- **Frontmatter:** `pm-execution/skills/pre-mortem`, `07b34f6`, both match.
- **Method source:** present below the table ("The Pre-Mortem Method", by the method's
  originator, Psychology Today, January 2021), naming what that source does not cover.
- **Row shape:** every kind valid; excluded rows leave `shown` empty; present rows carry
  `default`.
- **R1 pre-mortem half and USR-031:** three groups, three timing buckets, mitigation and
  owner role per must-fix threat, overblown worries state why, fixed shape in Output.

## critique-4 (source command pre-mortem): PASS

- **Completeness:** every source item (invocation examples; step 1; step 2 failure frame
  and five categories; step 3 Tiger severity and handling, Paper Tiger and Elephant
  rules; step 4 template: header, summary, two tables, Track, Paper Tigers, Elephants,
  Go/No-Go checklist, save; step 5 three offers; five Notes) has a row (14 to 42). The
  sub-examples under each category (performance, support load, ...) illustrate the five
  areas and are not separate items.
- **Tables:** "| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |" and
  "| # | Risk | Likelihood | Impact | Response | Owner role |" carry every source column,
  owner as role and deadline as a point in the plan.
- **Row 33, Go/No-Go checklist, `on request`:** offered by the default line ("a launch
  checklist") and printed on request with all five source items ("must-fix items closed,
  an owner for each 30-day item, triggers being watched, a way to roll back, support told
  what is coming"); the go or no-go itself is default ("Launch call: go | phase | delay,
  <reason>"). Matches the format's `on request`.
- **Rows 36 and 37:** offered in the default line, printed on request. Row 35 "Revise the
  PRD; capture security findings as requirements." does what the update-the-PRD offer does.
- **Row 42:** "Many must-fix threats mean phase or delay." matches the source note.
- **Excluded rows:** 14 and 15 (already covered by the description, same cover accepted in
  critique-2), 26 (header with date and status, adds length, decision named), 27 (risk
  summary counts, adds length; it only counts what the sections show, so it sorts, ranks,
  times or assigns nothing), 34 (save, adds length, decision named, see comment 2).
- **Other checks:** frontmatter matches (`pm-execution/commands/pre-mortem`, `07b34f6`);
  method source line by reference to critique-3; row shape valid; no personal field.

## Comments (not failing)

1. **critique-3 row 13:** the source's "launch in 14 days" counts down to launch, Odeo's
   frame looks back from six months after it. Accepted as already covered because both
   give the failure a concrete moment, and the difference is a recorded maintainer
   decision. If the framing is ever revisited, this is the row to re-judge.
2. **Save-as-file rows (critique-3 row 34, critique-4 row 34):** saving adds an artifact
   more than it adds length. The reason is on the closed list and its duty is met (a saved
   file sorts, ranks, times or assigns nothing), so not a FAIL.
3. **critique-4 row 24:** the source names political and organisational risks explicitly;
   Odeo's five areas do not, and the cover rests on "the most dangerous risks are the ones
   nobody raises" and "how to raise it with the team". The substance (avoided, awkward
   risks surfaced and raised) is met, and the example's unspoken worry is organisational.

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
  (USR-031): checklists critique-3 (source skill pre-mortem) and critique-4 (source command
  pre-mortem) added; SKILL.md Pass 2 rewritten (three groups, timing buckets, must-fix
  fields with owner role, launch call), Output gained the pre-mortem sections, the default
  offer line gained test scenarios and a launch checklist; example.md gained a pre-mortem
  part. critique-2 row 27 changed to `default` (round 2 comment 1 resolved). All four
  checklists re-judged in full. Verdict stays PASS; three new non-failing comments; round 2
  comment 2 (quotes with markup dropped) still applies and is not repeated.
