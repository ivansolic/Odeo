---
id: USR-016
title: Start any skill by asking for it
prd: PRD-002
order: 10
depends_on: USR-009
covers: R15
---

# USR-016: Start any skill by asking for it

**Card:** As a founder, I want to say "write the stories for this PRD" and have it happen,
so that I never need to know or type a command.

## Acceptance criteria (observable, binary)
- Every remaining skill starts when the user asks for it in words or says yes to an offer of
  it; none requires a typed command.
- Asking for a skill in words no longer produces a request to type the command instead.
- No skill starts when the user has neither asked for it nor said yes to it; a conversation
  that only mentions a topic (for example "our pricing is unclear") does not start the
  pricing skill without an offer and a yes.
- Every step that sends something off the machine or makes it public (a quick or lasting
  prototype share, a remote repository setup offers to create) still asks for an explicit
  yes before it happens, whoever started the skill.
- Merging into this repository's main branch still happens only when the maintainer runs it.

**Verification note (this repo):** remove the user-only flag from the remaining skills and
give each description a trigger that names the user's request; `skills-lint` rule C1 (a
model-invocable skill has a 'Use when' trigger) then covers all of them.

## INVEST / size
~1 day (one description per skill).

Traceability: `R15 -> USR-016`.
