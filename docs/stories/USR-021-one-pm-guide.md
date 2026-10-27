---
id: USR-021
title: One guide for the PM workflow
prd: PRD-002
order: 15
depends_on: USR-012, USR-020
covers: R2 R16
---

# USR-021: One guide for the PM workflow

**Card:** As a founder new to Odeo, I want one short guide that installs Odeo and walks the
core path, so that I am not handed three long guides written for building software.

## Acceptance criteria (observable, binary)
- The install guide covers only what a PM needs: Claude, the Odeo plugin, and version
  history for documents; its final check lists only skills that exist.
- The workflow guide and the beginners' guide are replaced by one guide that walks the core
  path from idea to package.
- Neither guide names a removed or merged skill, or describes building, merging, testing
  code or worktrees.
- The development sections of the old guides are kept in the private archive, not deleted
  without a copy.
- The README links only to guides that exist.

**Verification note (this repo):** maintainer decision 2026-10-27: one PM guide; INSTALL.md
is shortened, WORKFLOW.md and BEGINNERS-GUIDE.md merge into it.

## INVEST / size
~1 day.

Traceability: `R2 -> USR-021, R16 -> USR-021`.
