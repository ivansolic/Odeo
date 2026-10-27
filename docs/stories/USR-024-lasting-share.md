---
id: USR-024
title: A lasting prototype share keeps its link like a shared document
prd: PRD-002
order: 18
depends_on: USR-009
covers: R14
---

# USR-024: A lasting prototype share keeps its link like a shared document

**Card:** As a founder whose stakeholders review over days, I want to publish a prototype
once and keep the same link after my machine is off and after I update it, so that sharing
works like sharing a document.

## Acceptance criteria (observable, binary)
- Building on today's preview deploy step, Odeo publishes only to a place the user already
  has where every check below holds, and says which check fails when the chosen place cannot
  meet one.
- Each publication needs the user's yes before anything leaves the machine.
- The privacy scan runs on the prototype first; a planted e-mail address or key blocks the
  publication until the user answers.
- The share is private to the user until they share it; nobody without the link (and the
  password, where the place offers one) can reach it.
- After the user's machine is off, and after an update, the same link shows the current
  prototype.
- The session-start overview lists every lasting share.
- One request withdraws a share, and afterwards the link no longer shows the prototype.
- When the user says the prototype holds real or personal data, Odeo does not publish it and
  asks for it to be replaced with seed data first.

**Verification note (this repo):** today the prototype skill already offers a preview
deploy, records it in the share list, recommends a password and is deleted by hand; Odeo
names no hosting provider.

## INVEST / size
~1.5 days.

Traceability: `R14 -> USR-024`.
