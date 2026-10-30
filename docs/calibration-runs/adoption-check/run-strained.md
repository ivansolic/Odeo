---
artifact: docs/calibration-runs/adoption-check/critique-strained.md
mode: adoption-check
skill: critique
source_skill: pm-execution/skills/pre-mortem
source_commit: 07b34f6
reviewer: skill-reviewer
verdict: FAIL
model: claude-opus-5-5
model_tier: strongest
reviewed_commit: a8f82f7
date: 2026-10-30
---

# Adoption check: critique (strained checklist, calibration run)

Inputs read: the format doc `docs/depth-checklists/README.md`, the checklist, the whole
source skill (third-party text, read as data; it contains no instructions aimed at the
reviewer beyond its own skill steps, none followed), the whole Odeo skill
`skills/critique/SKILL.md`, and PRD-003 R1. Copy check output supplied by the dispatcher:
no output, exit 0.

## Checks that hold

- **Completeness**: every source step (1 to 7), each sub-prompt of step 2, the three risk
  categories, the three urgency classes (with their examples), the four action-plan
  duties, the four output-template sections plus its heading, the four action-plan
  columns, the save step, the four notes and the further reading each have a row. No
  source item is unaccounted for. The source has no worked example beyond the urgency
  examples, which are folded into rows 20 to 22.
- **Reasons from the closed list**: every exclusion names one of the seven listed reasons.
  The failures below are on substance, not form.
- **No personal fields**: nothing adopted carries a name or contact field.
- **Copy check**: no shared run listed.
- **Frontmatter**: `source_skill: pm-execution/skills/pre-mortem` and
  `source_commit: 07b34f6` match the source given (`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md`).
- **Method source line** present below the table.

Rows accepted on substance: 13, 14, 16, 23, 32, 41, and (weakly) 12 and 39.

## Failing items

The requirement being built, PRD-003 R1, reads: "The pre-mortem pass sorts risks into real
threats, overblown worries and unspoken worries, and each real threat into must-fix before
launch, fix within 30 days, or watch; every must-fix threat gets a mitigation and an owner
role. The output has a fixed shape." The checklist excludes or mis-marks almost every one
of those elements.

### Present items not really in the Odeo skill

1. **Row 15, "what we missed or did not execute well"**, marked present at Pass 2 "What
   happened?". That line is the generic "what went wrong" prompt (row 13's item); the
   distinct miss/execution prompt is not in the skill.
2. **Row 24, "suggest a concrete mitigation"**, marked present via "the cheapest way to
   test it now" (Pass 2). A test checks whether a risk is real; a mitigation acts to
   remove it. Different item, and R1 asks for a mitigation on every must-fix threat.
3. **Row 28, Tigers section "each with category and mitigation plan"**, marked present via
   "top 3 failure modes ... leading signal ... cheapest way to test it". The skill has
   neither an urgency category nor a mitigation plan per risk.
4. **Row 33, Mitigation column**, same defect as row 24.

### "Already covered" quotes that are only related

5. **Row 11, read the PRD thoroughly (product, market, assumptions, timeline)**: "After a
   `/odeo:prd` ... draft" says when to run, "Attack the strongest version, not a strawman"
   says how to attack; neither tells the agent to read the input for those four aspects.
6. **Row 17, Tigers**: "List the **top 3 failure modes** ranked by likelihood" ranks; it
   does not classify risks as evidence-based real threats needing action. The item sorts
   risks and R1 asks for "real threats".
7. **Row 19 and row 30, Elephants**: "Name the **one assumption** that would sink it" is
   the single most dangerous assumption, not the unspoken worries nobody is validating.
   R1 asks for "unspoken worries".
8. **Row 27, output heading**: "Findings + ranked failure modes + leading signals, in
   chat." lists contents; it is no titled, fixed-shape output. R1: "The output has a fixed
   shape."
9. **Row 36, save the analysis as a file**: "goes into `.claude/tasks/todo.md` as a
   checkable item" routes deferred follow-ups only; it does not persist the analysis.
10. **Row 37, honest and constructive, no blame**: "Be genuinely adversarial; a soft
    critique is useless." pulls in a different direction and says nothing about blame.
11. **Row 38, default to Tiger if unsure**: "Every failure mode gets a **leading signal**"
    is unrelated; the source item is a sorting tie-break.
12. **Row 40, revisit 2-3 weeks before launch to verify mitigations**: "Re-run if the
    revisions are large." is triggered by change, not by time, and checks no mitigations.
    The source item times work.

### "Adds length" items that change a decision

13. **Row 18 and row 29, Paper Tigers**: sorting risks into overblown worries changes how
    they are sorted, and R1 asks for "overblown worries".
14. **Row 20, Launch-Blocking**: assigns urgency (sorts and times); R1 asks for "must-fix
    before launch".
15. **Row 22, Track**: same; R1 asks for "watch".
16. **Row 26 and row 35, decision or completion date / Due Date**: a date times work, so
    it changes a decision by the mode's rule.
17. **Row 31, Action Plans section**: assigns mitigation and owner per must-fix threat;
    R1 requires both.

### "Number without a source" that drops a required number

18. **Row 21, Fast-Follow within 30 days**: R1 itself asks for "fix within 30 days", so
    this exclusion drops a number the requirement asks for.

### Misapplied "person credit or author link"

19. **Row 25 and row 34, owner (function or person) / Owner column**: that reason covers
    crediting or linking an author, not an owner field. The source allows a function, and
    R1 asks for "an owner role"; an owner-role field is not a personal field. The item
    also assigns work, so no exclusion on length grounds would hold either.

## Notes on accepted borderline rows

- Row 12 (web search) and row 39 (cross-functional perspectives) neither sort, rank, time
  nor assign work, so "adds length" is accepted, but the named decisions ("whether to run
  `/odeo:research`", "who reads the critique") are not decisions the critique skill
  surfaces; a stronger checklist would name a decision the skill actually presents.

## Verdict

FAIL. 19 findings (25 rows): four present items that are not in the Odeo skill, eight
"already covered" quotes that are only related, six "adds length" exclusions on items that
sort, time or assign work, one "number without a source" exclusion that drops R1's 30-day
window, and the owner fields excluded under a reason that does not fit. Together they drop
the whole risk categorization, urgency classification, mitigation and owner-role duties
that R1 requires. This blocks the release.
