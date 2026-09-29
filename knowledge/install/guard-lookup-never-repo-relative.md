---
module: git guards (scripts/install-git-guards.sh, scripts/merge-gate.sh)
tags: [security, git-hooks, fallback, lookup, fail-open, secret-scan, trust-boundary]
problem_type: bug
provenance: refactor/scripts-dir code review round 1 (0.3.0), finding 1; fixed in 0f02744
reuse_count: 0
created: 2026-09-29
---

# A guard never looks itself up relative to the project it guards

## Problem
The git hooks found Odeo's scripts through PATH, the plugin cache, the install-time
directory, then `scripts/` and `bin/` relative to the repo. With Odeo not found, a
project's OWN `scripts/secret-scan.sh` ran as the secret gate.

## Symptoms
None visible, which is the danger: the "committing WITHOUT the secret gate" warning
disappeared, the commit went through, and a key-shaped line was committed silently.
merge-gate had the same shape: a cwd `scripts/boundary-check.sh` that exits 0 passed a
real DO-NOT-TOUCH violation.

## What didn't work
The relative fallback looked harmless because it was LAST and meant for the Odeo repo
itself; the `bin/` variant had shipped in 0.2.x unnoticed. Order does not help: last still
runs whenever everything before it misses.

## Solution
Look up only locations the guard's owner controls: the cache, the directory the hooks
were installed from (baked in with %q), the checker shipped next to the gate. Nothing
relative to the repo or cwd. When all miss: warn loudly or block, never "find something".

## Why it works
The guarded project is the party the guard checks; any path it controls can replace the
check. Removing those paths makes substitution impossible instead of unlikely.

## Prevention
For every lookup chain in a guard ask: "can the thing being checked put a file here?"
Test it: plant a project script with the guard's name that exits 0, and assert it did
not run AND the missing-guard warning still prints (tests/git-guards.plugin.test.sh
case 10, tests/merge-gate.test.sh last case).

## Example
    for c in "$ODEO_BIN_AT_INSTALL" "scripts" "bin"; do ...   # before: project can win
    [ -x "$ODEO_BIN_AT_INSTALL/$name" ] && printf '%s' ...    # after
