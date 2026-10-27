---
id: USR-009
title: The plugin no longer contains the build half
prd: PRD-002
order: 3
depends_on: USR-007, USR-008
covers: R2 R11
---

# USR-009: The plugin no longer contains the build half

**Card:** As a founder or PM installing Odeo, I want a plugin that holds only product work,
so that I am not offered build, merge, deploy or code-review steps I will never use.

## Acceptance criteria (observable, binary)
- After install, the plugin's file list contains none of the 20 skills, 7 agents and 4
  scripts the Cut item names, and no session-start reminder about community knowledge.
- Every other published file that belongs only to the build phase leaves with the cut and is
  kept in the archive: the build plan format, its decision record about plans, the stack
  presets, the design and knowledge project templates, and the tests of the removed scripts.
- The list of removed items, kept in one file in the repository, names every item the two
  criteria above remove and nothing else; it is the one definition of what leaves.
- Asking the guide how to build or merge says that Odeo ends with a package ready for
  delivery and does not name a removed command.
- Sharing a prototype still opens a tunnel, and a second opinion on a PM document still
  runs, because the scripts those two skills use still ship.
- Every script that a remaining skill names exists in the installed plugin.
- The pre-push guard is no longer installed into users' projects; the secret scan on commit
  still is.

**Verification note (this repo):** remove the files and the hook entry, and fix pointers in
the files this story touches; USR-022 owns every other mention; `skills-lint.sh` reference
check (scripts referenced by a skill must exist) covers the fourth AC. The list file is what
USR-022 cleans against and USR-028 checks against. Maintainer decision 2026-10-27, in the
conversation: everything that belongs to the build phase leaves.

## INVEST / size
~1.5 days (mostly removal and pointer cleanup).

Traceability: `R2 -> USR-009, R11 -> USR-009`.
