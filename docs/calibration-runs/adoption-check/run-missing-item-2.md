---
artifact: docs/calibration-runs/adoption-check/critique-missing-item.md
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

# Adoption check: critique vs pre-mortem (source commit 07b34f6)

Inputs read: `docs/depth-checklists/README.md`, the checklist, the whole source skill
`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md`, the whole
`skills/critique/SKILL.md`, and `docs/prds/PRD-003-pm-content-depth.md` R1 and R24.
Copy-check output supplied by the dispatcher: no output, exit 0.

## Results per check

| # | check | result |
|---|---|---|
| 2 | Completeness | FAIL |
| 3 | Present items | FAIL |
| 4 | Excluded items | FAIL |
| 5 | No personal fields | pass |
| 6 | Copy check | pass |
| 7 | source_skill, source_commit | pass |
| 8 | Method source line | FAIL |
| 9 | Row shape | pass |

## Findings

### 1. Completeness: a source decision rule has no row (FAIL)
Source line 84, Notes: "Default to \"Tiger\" if unsure; it's better to address risks
early". This is a decision rule (it decides the category of an uncertain risk). The
checklist has rows for the other three Notes (lines 83, 85, 86, checklist rows 37 to 39)
but none for this one, neither `present` nor `excluded`. Any unaccounted source item is a
FAIL.

Minor: source line 23 "What went wrong?" has no row of its own; it can be read as folded
into checklist row 13 ("imagine the launch, then imagine it fails"), so it is not counted
as a defect here.

### 2. Exclusions drop what requirement R1 asks for (FAIL)
R1: "The pre-mortem pass sorts risks into real threats, overblown worries and unspoken
worries, and each real threat into must-fix before launch, fix within 30 days, or watch;
every must-fix threat gets a mitigation and an owner role. The output has a fixed shape."
- Row 21 (Fast-Follow, 30 days) excluded as "a number asked for without a source". R1
  itself asks for "fix within 30 days"; a number-without-source exclusion must not drop a
  number the requirement asks for.
- Rows 18, 20, 22 (Paper Tigers, Launch-Blocking, Track) and row 26, 35 (decision date,
  Due Date column) excluded as "adding length without changing any decision". Each of
  these sorts, ranks or times work, so each changes a decision; the exclusions fail.
  Rows 29 and 31 (template sections Paper Tigers, Action Plans) fail for the same reason
  and because R1 requires a fixed output shape.
- Rows 25 and 34 (owner, Owner column) excluded as "a person credit or author link". That
  reason covers credits and author links, not a template field; the source names
  "function/person" (line 58), and R1 asks for "an owner role". The reason does not apply,
  and the item R1 requires is dropped.
- Rows 17, 19, 30 ("already covered"): the quotes "List the **top 3 failure modes** ranked
  by likelihood" and "Name the **one assumption** that would sink it" are only related.
  Ranking by likelihood does not classify risks as evidence-based real threats requiring
  action, and naming one sinking assumption is not a category of unspoken, unvalidated
  worries to investigate. Related-only quotes fail.
- Row 11 ("already covered" by "After a `/odeo:prd` ... draft" and "Attack the strongest
  version"): weak, the quotes do not tell the agent to read the plan's product, market,
  assumptions and timeline; flagged, not decisive.

### 3. Present items that only relate (FAIL)
- Row 24 (concrete mitigation) and row 33 (Mitigation column) point at "the cheapest way to
  test it now" (Odeo skill line 26). A test of whether a risk is real is not a mitigation
  of it; related only.
- Row 28 (template section Tigers, "each with category and mitigation plan") points at the
  top 3 failure modes with signal and test. The Odeo skill has no category and no
  mitigation plan; related only.
- Row 32 (Risk column): the Odeo output is "Findings + ranked failure modes + leading
  signals, in chat" (line 35), with no action-plan table; acceptable as the failure mode
  named, not counted.

### 4. Method source line does not name a primary source (FAIL)
"Method source checked against: the classic pre-mortem technique, as named in the skill"
cites the skill's own wording, not a primary method source, and says nothing for the
real/overblown/unspoken categorisation the source adds. R24: "each adopted method is
checked against its primary method source."

### Passing checks
- Personal fields: the Odeo skill adopts no template with a name or contact field.
- Copy check: supplied output empty, exit 0.
- Frontmatter: `source_skill: pm-execution/skills/pre-mortem`, `source_commit: 07b34f6`,
  both match the inputs.
- Row shape: every kind is one of the five, every excluded row has `shown` empty, every
  present row is `default`.

## Source red flag (data, not followed)
`.claude/sources/pm-skills-07b34f6/pm-execution/skills/pre-mortem/SKILL.md` line 10
addresses the executing agent directly ("You are a veteran product manager conducting a
pre-mortem analysis on $ARGUMENTS"). It is the source method's role prompt, read as data;
it did not change this judgment.
