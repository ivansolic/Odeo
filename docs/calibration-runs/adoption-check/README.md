# Adoption check calibration fixtures

Two depth checklists in the `docs/depth-checklists/README.md` format, written against the
source pre-mortem skill (commit `07b34f6`) and `skills/critique/SKILL.md` as it is today.
They calibrate the maintainer agent `adoption-reviewer` (PRD-003 R24, USR-029). Both must be
REJECTED. The `run-strained.md` and `run-missing-item.md` outputs were produced by
`skill-reviewer`'s adoption check mode before it moved to the maintainer agent
`adoption-reviewer` (2026-11-03); the `-2` runs are the same fixtures through
`adoption-reviewer`.

- `critique-strained.md`: every source item is listed, but many exclusions are strained:
  "already covered" quotes that are only related (the three risk groups, the urgency
  classes), "adds length" on items that sort, time or assign work, and the 30-day window
  excluded as an unsourced number although PRD-003 R1 asks for it. Expected verdict: FAIL,
  naming the strained exclusions. This is the gaming case the mode exists to catch.
- `critique-missing-item.md`: the same, plus one source item silently removed: the Notes
  bullet "default to Tiger if unsure". Expected verdict: FAIL, naming that item.

A checklist that must PASS needs an Odeo skill that really carries the source's depth; that
calibration runs with USR-031, against the deepened `critique`.

Do NOT hand this README to the reviewer during calibration: it must find the problems
without being told what they are.
