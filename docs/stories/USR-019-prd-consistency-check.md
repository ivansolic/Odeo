---
id: USR-019
title: A PRD checks its decisions across the project
prd: PRD-002
order: 13
depends_on: USR-009
covers: R18
---

# USR-019: A PRD checks its decisions across the project

**Card:** As a PM changing a decision in a PRD, I want Odeo to show me every place in my
project that still carries the old form, so that a renamed, merged or redefined item is not
left behind in another document.

## Acceptance criteria (observable, binary)
- Before a PRD is saved, it lists every item the new or changed decisions rename, merge,
  move, remove or redefine; a decision with no such item says so in one line.
- For each item it searches the PRD and the whole project and shows every place that still
  carries the old form, with path and line.
- Each place ends with one of three outcomes: the edit that fixes it, a note that it is left
  for a story, or "history record, left as it is" for dated records such as review records
  and older PRDs.
- It states its known limit: it searches by name, so a copy written in other words can be
  missed.
- Replayed on PRD-002 at its round-8 state, it returns every published file that still names
  the two merged setup skills, including the AGENTS.md line, the guide, language, start and
  brainstorm skills, the README and the install guide, and marks review records as history.

**Verification note (this repo):** the replay uses commit 55dca67 as a fixture; the expected
list comes from a full-text search at that commit, written into the test before the step
exists (RED first).

## INVEST / size
~1 day.

Traceability: `R18 -> USR-019`.
