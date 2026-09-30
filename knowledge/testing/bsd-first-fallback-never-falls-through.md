---
module: tests (portable shell across macOS and Linux)
tags: [portability, bsd, gnu, stat, fallback, ci, linux, macos]
problem_type: bug
provenance: chore/ci-setup (first Linux CI run, 2026-09-30), fixed in 08e734c
reuse_count: 0
created: 2026-09-30
---

# A BSD-first fallback never falls through when the BSD flag means something else on GNU

## Problem
`stat -f %Lp file || stat -c %a file` reads a file mode on macOS and "falls back" on Linux.
It never falls back: on GNU, `-f` is `--file-system`, which SUCCEEDS and prints a
filesystem report. The `||` branch never runs.

## Symptoms
Green on macOS for months. On the first Linux run: `expected '644', got '  File: "/tmp/..."'`.
No error, no non-zero exit from `stat`: a wrong value, not a failure.

## What didn't work
Assuming "the other platform's flag will fail". A flag unknown on one system can be a
valid, different flag on the other.

## Solution
Put first the form whose flag the OTHER system REJECTS:

    # before
    stat -f %Lp "$f" 2>/dev/null || stat -c %a "$f"
    # after: BSD stat has no -c and exits 1 ("illegal option -- c")
    stat -c %a "$f" 2>/dev/null || stat -f %Lp "$f"

## Why it works
The chain now relies on a real failure (BSD rejecting `-c`), not a hoped-for one.

## Prevention
- For every `a || b` portability chain, confirm on BOTH systems that `a` actually FAILS
  where it is meant to; a clean exit is not proof it did the right thing.
- Run CI on Linux as well as macOS: this stayed hidden until the first Linux run.
- Same trap for other dual-meaning flags (e.g. `sed -i`, `date -r`): check what the flag
  does on the other system, not just whether it exists.
