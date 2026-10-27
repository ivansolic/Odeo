---
id: USR-012
title: Set up a new place for product documents
prd: PRD-002
order: 6
depends_on: USR-009
covers: R16 R4
---

# USR-012: Set up a new place for product documents

**Card:** As a founder starting a product, I want one setup that creates a place for my
product documents and asks only about my product, so that I can start a PRD without
answering questions about stacks or build commands.

## Acceptance criteria (observable, binary)
- Setup creates a new folder with the document folders, a project instruction file and
  version history, and reports the full path it used.
- The output language is taken from the parent folder's setting, else the user's global
  default, else English, and is not asked; the user is told it can be changed later with the
  language skill.
- Setup asks three things and nothing else: what the product is (who it is for and the
  outcome it produces); whether to teach product terms as it goes, with yes as the default;
  and the product's security and data facts (personal data it handles, who its users are and
  where, whether they log in, known compliance requirements, what is most worth protecting).
- All three answers are written into the project's instruction file; the file contains no
  stack, build command, test command or test-strictness placeholders.
- No design layer, knowledge folder or stack preset is created or offered.
- A commit of a file holding a planted key is refused in the new place.
- Setup says that the pre-push guard older Odeo versions installed is no longer installed.
- Creating a remote repository is offered once and runs only after the user's explicit yes,
  and only after the privacy scan of what would be pushed is clean or answered.

**Verification note (this repo):** replaces `new-project` and the new-project half of
`setup-project`; the template loses stack, `dev_rigor`, design and knowledge parts; name
validation from today's `new-project` stays.

## INVEST / size
~1.5 days.

Traceability: `R16 -> USR-012, R4 -> USR-012`.
