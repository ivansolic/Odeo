---
artifact: docs/calibration-runs/adoption-check/critique-strained.md
skill: critique
mode: adoption-check
reviewer: adoption-reviewer
verdict: FAIL
model: claude-opus-5-5
model_tier: strongest
effort: high
reviewed_commit: 208d421
date: 2026-11-03
---

# Adoption check: critique (strained checklist), calibration run 2

Inputs: checklist `docs/calibration-runs/adoption-check/critique-strained.md`; source
`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md` at `07b34f6`;
Odeo skill `skills/critique/SKILL.md`; requirement PRD-003 R1 (R24 for checklist rules);
copy-check: no output, exit 0. Format doc `docs/depth-checklists/README.md` present.

Note on tooling: Grep was not available in this session; all files were read in full with
Read instead, which the process requires anyway.

## Checks that hold
- **Completeness (check 2):** every source step, template section, table column, decision
  rule and worked example (the urgency examples are folded into rows 20 to 22) has a row.
  "What went wrong?" is merged into rows 13 and 15; acceptable.
- **Row shape (check 9):** every `kind` is from the allowed five; every `excluded` row has
  `shown` empty; every `present` row is `default`.
- **Frontmatter (check 7):** `source_skill: pm-execution/skills/pre-mortem` and
  `source_commit: 07b34f6` match the inputs.
- **No personal fields (check 5):** the Owner field is not adopted, so no adopted template
  carries a name or contact field.
- **Copy check (check 6):** no shared run reported.
- **Further reading (row 41):** "a person credit or author link" fits, and matches the
  non-goal "no links to its author's articles".

## Failures

### A. Exclusions that drop what R1 itself requires
R1: "The pre-mortem pass sorts risks into real threats, overblown worries and unspoken
worries, and each real threat into must-fix before launch, fix within 30 days, or watch;
every must-fix threat gets a mitigation and an owner role. The output has a fixed shape."
The checklist excludes every one of these parts.
1. **Row 21, Fast-Follow, "a number asked for without a source: the 30-day window has no
   evidence behind it".** R1 asks for exactly this number ("fix within 30 days"). A
   number-without-a-source exclusion must not drop a number the requirement asks for. FAIL.
2. **Rows 25 and 34, Owner, "a person credit or author link".** Wrong reason: that reason
   covers crediting authors, not a template field; the source asks for "the best owner
   (function/person)", and R1 asks for "an owner role", which is no personal field. The
   item should be present as a role. FAIL.
3. **Rows 17 to 22, 29 to 31: the three-way sort and the urgency classes** are all
   excluded, so the R1 sorting and the "fixed shape" are absent from the Odeo skill
   (`skills/critique/SKILL.md` Output: "Findings + ranked failure modes + leading signals,
   in chat." has no fixed shape). FAIL.

### B. "Adds length" exclusions on items that sort, rank, time or assign work
Each of these changes a decision, so the exclusion is a FAIL regardless of the decision named:
- Row 18, Paper Tigers (sorts risks).
- Row 20, Launch-Blocking (sorts by urgency; also gates "revise the PRD before building",
  the very decision it claims to leave unchanged).
- Row 22, Track (sorts by urgency).
- Row 26, decision or completion date (times work).
- Row 29, Paper Tigers section (the sort's output).
- Row 31, Action Plans for Launch-Blocking Tigers (assigns mitigation work).
- Row 35, Due Date column (times work).
Weaker, noted not counted: row 39 (cross-functional perspectives) arguably assigns review
perspectives; row 12 (web search) names `/odeo:research`, which the critique skill does not
mention.

### C. "Already covered" quotes that are only related
- Row 17, Tigers: "List the **top 3 failure modes** ranked by likelihood" ranks; it does not
  classify risks as evidence-based and requiring action. FAIL.
- Rows 19 and 30, Elephants: "Name the **one assumption** that would sink it" targets the
  biggest known assumption, not unspoken worries nobody is validating, nor an investigation
  approach. FAIL.
- Row 36, save as a markdown document: the quoted todo.md rule routes deferred follow-ups;
  the Odeo skill states the analysis stays "in chat". It does not save the analysis. FAIL.
- Row 37, be constructive and do not assign blame: "Be genuinely adversarial; a soft
  critique is useless." pulls the other way; it does not cover a no-blame rule. FAIL.
- Row 38, default to Tiger if unsure: "Every failure mode gets a **leading signal**" is no
  tie-break rule for unsure risks. FAIL.
- Row 40, revisit 2 to 3 weeks before launch: "Re-run if the revisions are large." has a
  different trigger (document change, not launch proximity) and no verification of
  mitigations. FAIL.
- Row 14, 14-day horizon: the Odeo quote fixes a 6-month horizon, so the added claim "the
  horizon is the user's, not fixed" is false. Covered in substance (a horizon exists);
  the gloss is wrong. Noted.
- Row 11, gather and read the PRD: "After a `/odeo:prd` ... draft" and "Attack the strongest
  version" do not instruct reading the product, market, assumptions and timeline.
  Borderline; noted.

### D. Present items that are only related
- Rows 24 and 33, Mitigation: "the cheapest way to test it now" (Pass 2) is a test of a
  failure mode, not a mitigation action that reduces the risk. FAIL.
- Row 28, Tigers section "each with category and mitigation plan": the Odeo pass gives no
  category and, per above, no mitigation. FAIL.
- Rows 23 and 32 cite "each failure mode listed with what happened" / "the failure mode
  named" as if quotes; neither string is in the Odeo skill. The substance (Pass 2: "What
  happened?" with ranked failure modes) is close enough; the citation should quote the line.

### E. Method source line (check 8)
"the classic pre-mortem technique, as named in the skill" points back at the Odeo skill's
own phrase (`skills/critique/SKILL.md` line 8 to 9), not at a primary method source the
method was checked against. The line exists in form but names no source. FAIL.

## Red flag in the source (data, not followed)
`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md` line 10: "You
are a veteran product manager conducting a pre-mortem analysis on $ARGUMENTS." It addresses
the reading agent directly with a role. It describes the source method's prompt and was
not followed; it did not affect this judgment.

## Verdict
FAIL. The checklist is complete and well-formed, but its exclusions are strained: it drops
the three items R1 names (the three-way sort, the urgency classes including the 30-day
window, the owner role), uses "adds length" on items that sort and time work, and leans on
"already covered" quotes that are only related.
