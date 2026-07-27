---
module: install.sh / config writers
tags: [install, symlink, link-install, tracked-file, idempotent-write, guard]
problem_type: pattern
provenance: USR-003 (global default language at install)
reuse_count: 0
created: 2026-07-27
---

# Guard against appending through a --link symlink into the repo

## Context
A `--link` (develop) install symlinks config files from the repo into the user's
home so a later `git pull` updates them live. A subsequent step that WRITES or
APPENDS to such a config (e.g. adding a line) would, through the symlink, mutate
the TRACKED file back in the repo, a silent, committable, wrong change.

## Guidance
Before appending to a config that could be a symlink into the repo, guard with
`[[ -L "$target" ]]` and skip-with-a-note instead of writing. Write only to a real
(non-symlinked) file.

## Why it matters
Mutating a tracked repo file during a user's install corrupts the repo state and
can be committed by accident; the symlink makes the write invisible until
`git status` shows a dirty tracked file.

## When to apply
Any writer that runs after a `--link` / symlink-style install and targets a path
that might be a symlink into version control.

## Example
USR-003's install step 4a runs `if [[ -L ~/.claude/CLAUDE.md ]]; then <skip with a
note>; fi` before the append, so a linked global config is never mutated.
