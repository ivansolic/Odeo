---
artifact: docs/calibration-runs/adoption-check/critique-missing-item.md
skill: critique
mode: adoption-check
reviewer: skill-reviewer
verdict: FAIL
model: claude-opus-5-5
model_tier: strongest
effort: high
reviewed_commit: a8f82f7
date: 2026-10-30
---

# Adoption check: critique (pre-mortem source), calibration run

Inputs: checklist `docs/calibration-runs/adoption-check/critique-missing-item.md`; source
`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md`; Odeo skill
`skills/critique/SKILL.md`; copy check: no output, exit 0; commit a8f82f7; requirement
PRD-003 R1. Output language: en (handed).

## 1. Completeness: FAIL

Source items listed independently: step 1 (two parts), step 2 (horizon, imagine failure,
three prompts), step 3 (Tigers, Paper Tigers, Elephants), step 4 (three urgency classes),
step 5 (four action-plan parts), step 6 (heading, four sections, four columns), step 7
(save), four Notes, Further Reading. Every one has a row EXCEPT:

- **MISSING, decision rule: "Default to \"Tiger\" if unsure; it's better to address risks
  early"** (source, Notes, line 84). Neither `present` nor `excluded` in the checklist; the
  Notes rows cover lines 83, 85 and 86 only. Per the format doc: "A source item that is
  neither `present` nor `excluded` is a defect, and the checklist fails review."

## 2. Present items

Quotes exist in the Odeo skill for rows 13, 15, 16, 23, 32, 33 ("It's 6 months later and
this shipped and failed. What happened?", "which single assumption, if wrong, collapses
the whole thing?", "List the **top 3 failure modes**"). All marked `default`. Weak, not
failed on their own:
- Rows 24 and 33 map source "concrete mitigation action" to "the cheapest way to test it
  now". A test detects a risk; a mitigation reduces it. Related, not the same.
- Row 28 claims the Tigers section "with category and mitigation plan" is present, but the
  category (urgency class) is excluded in rows 20 to 22, so the section is only partly there.

## 3. Excluded items: FAIL (substance)

PRD-003 R1, the requirement being built, says: "The pre-mortem pass sorts risks into real
threats, overblown worries and unspoken worries, and each real threat into must-fix before
launch, fix within 30 days, or watch; every must-fix threat gets a mitigation and an owner
role." Exclusions that drop what R1 asks for, or that sort, time or assign work under
"adds length", fail:

- Row 18 and row 29, Paper Tigers ("adding length ... leaves unchanged the decision which
  three failure modes to test first"): Paper Tigers is a sort (what not to invest in), and
  R1 asks for "overblown worries". FAIL.
- Row 19 and row 30, Elephants ("already covered" by "Name the **one assumption** that
  would sink it"): the quote names the single fatal assumption; Elephants are the several
  unspoken, unvalidated worries to investigate. Related only, and R1 asks for "unspoken
  worries". FAIL.
- Row 17, Tigers ("already covered" by "top 3 failure modes ranked by likelihood"): R1 asks
  for the explicit "real threats" class; the ranking does not sort real from overblown. FAIL.
- Row 20, Launch-Blocking ("adding length ... whether to revise the PRD before building"):
  an urgency class times work and is exactly the decision it claims to leave unchanged; R1
  asks for "must-fix before launch". FAIL.
- Row 21, Fast-Follow ("a number asked for without a source: the 30-day window"): R1 asks
  for "fix within 30 days", so the exclusion drops a number the requirement asks for. FAIL.
- Row 22, Track ("adding length"): times work; R1 asks for "watch". FAIL.
- Row 25 and row 34, Owner ("a person credit or author link"): an owner field is not a
  credit or author link, the source allows a function ("function/person"), it assigns work,
  and R1 asks for "an owner role". Wrong reason. FAIL.
- Row 26 and row 35, Due date ("adding length"): a date times work, so it changes a
  decision. FAIL.
- Row 37, "be honest and constructive ... not assign blame" ("already covered" by "Be
  genuinely adversarial; a soft critique is useless."): the quote does not do what the
  source note does (no-blame, constructive framing); it pulls the other way. FAIL.
- Row 39, "revisit 2-3 weeks before launch" ("already covered" by "Re-run if the revisions
  are large."): the source is a time-based check that mitigations are on track; the quote is
  a trigger on revision size. Related only. FAIL.
- Row 36, save as a file ("already covered" by the todo.md routing line): the quoted rule
  stores follow-ups, not the analysis. The Odeo choice "in chat" (Output) would have been
  the matching quote; as written, the quote does not do what the source step does. FAIL.

Weak, not counted as failures: row 12 (web search, "adds length", decision named is
"whether to run `/odeo:research`", which is the step itself), row 38 (cross-functional
perspectives, decision named "who reads the critique" is not a decision the item touches),
row 31 (action-plans section excluded while its parts are claimed present in rows 23, 24).
Row 40 (Further Reading, author links) is a correct use of reason 3.

## 4. No personal fields: PASS
The Odeo skill's output has no field for a person's name or contact detail.

## 5. Copy check: PASS
Supplied output: no output, exit 0. No shared run listed.

## 6. Frontmatter: PASS
`source_skill: pm-execution/skills/pre-mortem` and `source_commit: 07b34f6` match the
source given (`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md`).

## Note on third-party text
The source copy's `CLAUDE.md` (under `.claude/sources/pm-skills-07b34f6/`) was loaded into
context and contains instructions to agents ("Offer relevant follow-ups", run the
validator). Treated as data; not followed.

## Verdict
FAIL: one source item missing from the checklist (Notes, "Default to Tiger if unsure"),
plus exclusions that drop what PRD-003 R1 requires or that sort, time or assign work.
