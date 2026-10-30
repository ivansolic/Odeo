---
id: USR-048
title: Release 1 comparison decides shipping
prd: PRD-003
order: 20
depends_on: USR-030, USR-031, USR-032, USR-033, USR-034, USR-035, USR-036, USR-037, USR-038, USR-039, USR-040, USR-041, USR-042, USR-043, USR-044, USR-045, USR-046, USR-047
covers:
---

# USR-048: Release 1 comparison decides shipping

**Card:** As the maintainer, I want a reader who is not me to compare Odeo before, Odeo
after and the alternative without knowing which is which, so that release 1 ships only if
the deeper skills are actually better, not just longer.

## Acceptance criteria (observable, binary)
- Before the comparison, the no-lost-rigor check of PRD-003 section 2 passes: the lint
  and all test suites are green, no skill asks for a number without a source or a
  hypothesis label, no skill names a person or a third-party plugin, and no
  `skill-reviewer` score is lower than before.
- Three sample ideas are used, at least one from a person who is not the maintainer.
- For each idea the PRD, critique and stories are produced three ways: Odeo before, Odeo
  after, and the alternative's PRD, pre-mortem, red-team and stories skills, with the
  alternative installed as USR-045 requires.
- The reader is named before the run, is not the maintainer, and is not told which
  document came from where.
- Per idea the reader's preference and reason are written down.
- For one idea the discovery documents release 1 changes are compared before and after in
  the same way.
- The length of each "after" PRD and stories against "before", on the lean default
  output, is written down with the `pm-reviewer` scores; more than 50% longer without a
  higher score counts as a loss for that skill.
- Pass: Odeo after is preferred in 3 of 3 ideas over both others, with no length loss;
  release 1 ships.
- Fail: release 1 does not ship; the losing skills are revised, the reasons go into
  PRD-003, and the comparison runs once more, with a fresh reader where possible. After
  the second run, a skill whose "after" still loses to "before" returns to its before
  state, the others ship, and the maintainer decides on releases 2 and 3 with the
  reader's reasons.

## INVEST / size
~1 day of maintainer time plus the reader's reading.

Traceability: PRD-003 section 2 (release 1 metric) and H1; it covers no single
requirement.
