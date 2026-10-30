---
id: USR-029
title: Depth checklist per adopted skill
prd: PRD-003
order: 1
depends_on: none
covers: R24
---

# USR-029: Depth checklist per adopted skill

**Card:** As the maintainer, I want every skill that adopts from a source skill to carry a
checked list of what it took and what it left out, so that "same depth as the source" is
proven per skill instead of claimed.

## Acceptance criteria (observable, binary)
- For each skill that adopts from a source skill, a checklist is saved with the release.
  It names the source skill and one recorded commit of the alternative, and lists every
  step, output-template section, table column, decision rule and worked example of the
  source skill at that commit.
- Every item is marked either present, naming where it appears in Odeo's skill and
  whether it is shown by default or on request (the lean default), or excluded with one reason from the closed list in PRD-003 section 2. A non-goal exclusion
  quotes the non-goal; an "already covered" exclusion quotes the Odeo rule or step; an
  "adds length" exclusion names the user decision it leaves unchanged.
- Each adopted method has a line naming the primary method source it was checked against.
- No sentence of more than eight words in Odeo's skill is identical to the source; the
  check names every sentence that is.
- No adopted template has a field for a person's name or contact detail.
- Before the release ships, `skill-reviewer` checks each saved checklist against the
  source skill at the recorded commit and passes or rejects it; a rejected checklist
  blocks the release.
- A sample checklist with one source item neither present nor excluded is rejected.
- The recorded commit is `07b34f6`, the commit PRD-003 was written from, or a newer commit
  read in full before it is recorded; it is the same one the routing check (USR-045)
  installs.

## INVEST / size
~1.5 days: the checklist shape, the reviewer's check, the sample that must be rejected.

Traceability: `R24 -> USR-029`.
