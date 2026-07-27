---
module: install.sh / bin
tags: [install, PATH, bin, mid-install, absolute-path, bootstrapping]
problem_type: pattern
provenance: USR-003 (global default language at install)
reuse_count: 0
created: 2026-07-27
---

# Call a just-installed helper by absolute path, not via PATH

## Context
`install.sh` copies helper scripts into `~/bin` and adds `~/bin` to PATH by editing
the shell profile. That PATH edit only takes effect in a NEW shell (after the user
runs `source`), so during the SAME install run the freshly-copied helpers are NOT
yet on PATH.

## Guidance
When `install.sh` (or any bootstrap script) needs to CALL a helper it just
installed, invoke it by its absolute source path in the repo
(`"$REPO_DIR/bin/helper.sh"`), never by bare name relying on PATH.

## Why it matters
A bare-name call works on a machine where the tool is already on PATH (the
author's), and fails on a clean machine (the user's first install) with
`command not found`, exactly the moment install must not fail.

## When to apply
Any script that installs a tool AND uses it in the same run. More generally: never
assume a PATH edit is live within the process that made it.

## Example
USR-003's install step 4a calls `"$REPO_DIR/bin/set-global-language.sh" "$code"`,
not `set-global-language.sh "$code"`.
