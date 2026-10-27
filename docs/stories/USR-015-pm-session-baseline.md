---
id: USR-015
title: Every session carries PM rules only
prd: PRD-002
order: 9
depends_on: USR-009
covers: R17
---

# USR-015: Every session carries PM rules only

**Card:** As a founder with Odeo installed, I want the rules Odeo adds to every session to
be about product work, so that my sessions are not filled with git, code-style and testing
rules I never use.

## Acceptance criteria (observable, binary)
- Every section of the baseline Odeo adds to a session belongs to one of four groups:
  communication, PM practice, honesty, privacy.
- The baseline keeps the privacy rules: secrets and personal data stay out of documents, and
  nothing leaves the machine without approval.
- Nothing about git branches, code style, tests, code security, plan formats, bug fixing,
  the task ledger, community knowledge or a removed agent remains in it.
- No remaining skill refers to a baseline section that no longer exists; the check lists
  every such reference it found, and the list is empty.
- The product-terms preference is described in one place, AGENTS.md, and the baseline points
  to it.
- No published file describes that preference as an aside for technical terms (today the
  guide skill and AGENTS.md do).
- On a machine whose own global instructions do not already carry the baseline, a new
  session shows it; the maintainer's machine is not used for this check.

**Verification note (this repo):** `global/CLAUDE.md` is what the session-start hook
injects; a test asserts its section headings against the four groups (RED first on today's
file).

## INVEST / size
~1 day.

Traceability: `R17 -> USR-015`.
