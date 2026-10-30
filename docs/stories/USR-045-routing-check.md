---
id: USR-045
title: Skills still route correctly when asked
prd: PRD-003
order: 17
depends_on: USR-036, USR-039
covers: R25
---

# USR-045: Skills still route correctly when asked

**Card:** As the maintainer, I want a written list of plain requests checked before each
release, also with the alternative installed next to Odeo, so that asking for a skill
starts that skill and not its neighbour.

## Acceptance criteria (observable, binary)
- A written list of sample requests exists with, for each skill, at least one request
  that should start it, and requests that separate it from its two nearest neighbours,
  including the two new skills against interview synthesis and product signal.
- Before the release, every request on the list is run and the skill that started is
  written down per request.
- The same list is run with the alternative installed next to Odeo, and the result is
  written down per request.
- The alternative is installed only at the recorded commit (USR-029: `07b34f6`, or a newer
  commit read in full first), in a separate
  profile with no private repositories, credentials or connected services, and removed
  afterwards; the record says so.
- An Odeo skill that loses a request it should win gets a sharper description, and the
  request passes on a re-run, before the release ships.
- Requests from earlier releases stay on the list.

## INVEST / size
~1 day.

Traceability: `R25 -> USR-045`.
