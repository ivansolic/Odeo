---
id: USR-007
title: Keep the dev phase in a private archive
prd: PRD-002
order: 1
depends_on: none
covers: R10
---

# USR-007: Keep the dev phase in a private archive

**Card:** As the maintainer, I want the whole dev phase kept in a private repository with
its full history before anything is cut, so that I can bring a piece back or turn it into
its own plugin later without it ever becoming public.

## Acceptance criteria (observable, binary)
- A private repository holds this repository's complete history up to the last commit before
  the cut, including the prepared, unpublished 0.5.0 changes.
- The repository is private: opening it while signed out, or as another account, shows no
  content.
- The repository is created only after the maintainer says yes to its name and visibility in
  the conversation; without that yes nothing is created.
- Pushing the archive's history to the public Odeo repository is refused by this
  repository's own push guard, with a message that names the public remote.
- The archive's description says it is not maintained and points to this PRD as the reason.
- A file taken from the archive (for example the build skill) can be restored into a working
  branch with one command that the archive's description states.

**Verification note (this repo):** the archive is a separate private GitHub repository
(maintainer decision 2026-10-25), which satisfies R10's "private only"; PRD-002 still says
"archive branch". Verify the refusal by attempting a dry-run push of an archive ref to
`origin` and showing the guard's exit code.

## INVEST / size
~0.5 day. First, because every later story deletes from the tree this archive preserves.

Traceability: `R10 -> USR-007`.
