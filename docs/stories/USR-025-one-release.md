---
id: USR-025
title: Release the PM plugin as one release
prd: PRD-002
order: 19
depends_on: USR-007, USR-008, USR-009, USR-010, USR-011, USR-012, USR-013, USR-014, USR-015, USR-016, USR-017, USR-018, USR-019, USR-020, USR-021, USR-022, USR-023, USR-024
covers: R3 R4
---

# USR-025: Release the PM plugin as one release

**Card:** As an existing Odeo user, I want one release that explains what changed and what I
keep, so that I know what left, what replaced it and what to refresh.

## Acceptance criteria (observable, binary)
- The release notes name the removed skills, the merged setup, the private archive, the end
  of the model policy, and that the pre-push guard is no longer installed while the secret
  scan on commit stays.
- The prepared 0.5.0 is not published on its own; its changes are handled as follows, and
  the release notes say so: the review loop ends at an approve, with or without comments
  (ships); a PRD or story edited after an approve costs one more review (ships); the review
  record is committed once per branch (ships); the merge gate treats prose changes after a
  review as not stale (stays in the maintainer's repository-only tooling, USR-008); the
  build skill and plan-format wording (leave with the cut, kept in the archive).
- Every remaining PM skill still passes its review, and every changed skill has a passing
  skill review.
- The guide routes every PM question it routed before the release; the list of questions
  compared is kept with the release.
- The release reaches the public repository only through the publish step, after the
  maintainer's yes, on a branch whose name starts with `publish/`, describes the release and
  contains no date.

**Verification note (this repo):** the branch-name rule is the maintainer's decision of
2026-10-27, made in the conversation.

## INVEST / size
~1 day.

Traceability: `R3 -> USR-025, R4 -> USR-025`.
