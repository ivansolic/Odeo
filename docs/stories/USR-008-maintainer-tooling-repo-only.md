---
id: USR-008
title: Odeo's own maintenance tools stay but never ship
prd: PRD-002
order: 2
depends_on: USR-007
covers: R6
---

# USR-008: Odeo's own maintenance tools stay but never ship

**Card:** As the maintainer, I want the merge gate, the code reviewer and the push guard for
this repository kept in a place only this repository has, so that I can keep maintaining
Odeo's scripts while users never install build tooling.

## Acceptance criteria (observable, binary)
- On this repository, the full test suite, the lint, the publish guard, the merge gate, the
  push guard and a code review of a changed script all still run and pass on a clean tree.
- A planted change to a reviewed script without a fresh review is still refused by the merge
  gate here.
- The published tree built by the publish step contains none of these maintainer tools, and
  the publish guard refuses a published tree that does.
- Nothing a user installs refers to these tools: a search of the shipped plugin for their
  names finds none.

**Verification note (this repo):** move them under one repository-only folder that
`docs/internal-paths.txt` denylists; the merge-gate and pre-push tests keep running from the
new paths (RED first: a test that points at the old path fails after the move until
updated).

## INVEST / size
~1 day. Before the cut, so the tools the maintainer needs are safe before the build half is
removed.

Traceability: `R6 -> USR-008`.
