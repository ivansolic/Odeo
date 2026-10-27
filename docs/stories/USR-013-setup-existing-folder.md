---
id: USR-013
title: Set up product documents inside an existing folder
prd: PRD-002
order: 7
depends_on: USR-012
covers: R16
---

# USR-013: Set up product documents inside an existing folder

**Card:** As a PM with an existing folder of notes, I want setup to add a place for product
documents without touching what is already there, so that my recordings and spreadsheets
never end up in version history by accident.

## Acceptance criteria (observable, binary)
- In an existing folder without version history, setup starts one, and its first commit
  holds only the files setup created; a planted interview recording and a planted customer
  spreadsheet that were already in the folder are not in it.
- No file the user already had is overwritten or deleted; a planted file with the same name
  as one setup would create is left as it was and setup says so.
- In an existing project instruction file, setup adds its own lines (language, product,
  terms preference, security and data facts) and replaces nothing; if a language line
  already exists, no second one is added.
- The language comes from the folder's own setting if it has one, else the user's global
  default, else English.
- Running setup twice does not duplicate any line or folder.

**Verification note (this repo):** stage only the paths setup wrote (never `git add -A`);
test with a fixture folder holding a fake recording and a fake spreadsheet.

## INVEST / size
~1 day.

Traceability: `R16 -> USR-013`.
