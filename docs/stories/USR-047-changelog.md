---
id: USR-047
title: Release notes for Odeo itself
prd: PRD-003
order: 19
depends_on: none
covers: R23
---

# USR-047: Release notes for Odeo itself

**Card:** As a user of Odeo, I want to read what a new version changes in the skills I rely
on, so that an update never surprises me.

## Acceptance criteria (observable, binary)
- The repository has a changelog with an unreleased section.
- Each skill change of this release is recorded there in plain words.
- A new version heading, written by the maintainer, marks the release.
- A test fails when the plugin's version and the newest version heading disagree, and
  passes when they match; run on a deliberately mismatched pair, it fails.

## INVEST / size
~0.5 day.

Traceability: `R23 -> USR-047`.
