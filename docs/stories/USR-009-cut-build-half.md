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
- No remaining skill, guide answer or system-map row points to a removed item; asking the
  guide how to build or merge says that Odeo ends with a package ready for delivery and does
  not name a removed command.
- Sharing a prototype still opens a tunnel, and a second opinion on a PM document still
  runs, because the scripts those two skills use still ship.
- Every script that a remaining skill names exists in the installed plugin.
- The pre-push guard is no longer installed into users' projects; the secret scan on commit
  still is.

**Verification note (this repo):** remove the files, the hook entry, and every pointer;
`skills-lint.sh` reference check (scripts referenced by a skill must exist) covers the
fourth AC. This story also writes the list of every removed name into one file in the
repository, which the name check in USR-022 reads. The enforced name check that keeps this
true comes in USR-022.

## INVEST / size
~1.5 days (mostly removal and pointer cleanup).

Traceability: `R2 -> USR-009, R11 -> USR-009`.
