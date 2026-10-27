---
id: USR-023
title: A quick prototype share can last longer and keep its link
prd: PRD-002
order: 17
depends_on: USR-009
covers: R13 R4
---

# USR-023: A quick prototype share can last longer and keep its link

**Card:** As a founder showing a prototype, I want to choose how long a share stays open and
extend it without a new link, so that a review that runs long does not break the link my
reviewers already have.

## Acceptance criteria (observable, binary)
- When sharing, the user chooses how long the share stays open, up to 8 hours in total; a
  longer request is refused with the limit stated.
- Every share announces its end time when it opens.
- The privacy scan runs on the prototype before a share opens; a planted e-mail address or
  key stops the share until the user answers.
- An open share can be extended up to the 8-hour total by moving its end time; the link
  stays the same and reviewers already on it are not disconnected.
- An extension past the 8-hour total is refused with the limit stated.
- The share closes on its own at its end time, and the user is told it closed.
- While open, the share is listed by the session-start overview with its end time.

**Verification note (this repo):** today `share-tunnel.sh` takes a TTL and extending means
re-running it, which creates a new hostname (Cloudflare Quick Tunnels docs, read
2026-10-25); the change moves the end time of the running tunnel. Tests use the existing TTL
override.

## INVEST / size
~1 day.

Traceability: `R13 -> USR-023, R4 -> USR-023`.
