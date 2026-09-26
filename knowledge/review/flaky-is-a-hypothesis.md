---
module: git guards (bin/install-git-guards.sh hooks, the ~/bin shim from odeo-migrate-legacy.sh)
tags: [flaky-test, stdin, exec, while-read, file-descriptor, security, pre-push, root-cause]
problem_type: bug
provenance: fix/publish-guard-project-lists, shipped in public 0.2.1
reuse_count: 0
created: 2026-09-26
---

# "Flaky" is a hypothesis: the varying failure was a real security bug

## Problem
tests/install-git-guards.test.sh failed a different case on each run, "also on main". A
reviewer labelled it flaky, it was logged as a follow-up, and everyone moved on.

## Symptoms
Passed 3/3 with a clean HOME and PATH, failed with the real ones. A hand-run push printed
`publish-guard: clean (0 files checked)` for a push that contained files.

## What didn't work
Accepting "flaky"; isolating the test would have hidden the bug.

## Solution
The ~/bin shim exec'd the real guard INSIDE a loop that read a cache listing on stdin:
    while IFS= read -r d; do run_if "$d/$name" "$@"; done < <(ls ...)   # guard inherits the listing
Fixed by reading the listing on fd 3 and closing it on exec:
    while IFS= read -r d <&3; do run_if "$d/$name" "$@"; done 3< <(ls ...)
    run_if() { ... exec "$1" "${@:2}" 3<&-; }
The guard now gets the caller's stdin (the pushed paths). Test: bytes in == bytes out.

## Prevention
Before accepting "flaky", run the test in a clean environment AND the real one; if they
differ, the difference is the bug. Trace a varying failure's INPUT instead of retrying.
Never exec from inside a loop that redirects stdin.
