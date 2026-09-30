---
module: tests (portable shell across macOS and Linux)
tags: [portability, bsd, gnu, stat, fallback, command-substitution, stdout, ci, linux, macos]
problem_type: bug
provenance: chore/ci-setup (first Linux CI run, Odeo-private run 36688443398, 2026-09-30), fixed in 08e734c
reuse_count: 0
created: 2026-09-30
---

# A fallback inside $(...) keeps the first command's stdout even when it fails

## Problem
`$(stat -f %Lp "$f" 2>/dev/null || stat -c %a "$f")` reads a file mode on macOS and falls
back on Linux. On Linux the fallback DOES run, but the value is still wrong: GNU `stat -f`
means `--file-system` and takes no argument, so `%Lp` becomes a second file name. stat
prints the filesystem report for `$f` to stdout, then fails on the file `%Lp` (the error
is hidden by `2>/dev/null`) and exits non-zero. `||` runs `stat -c %a`, and `$(...)`
captures the stdout of BOTH commands.

## Symptoms
Green on macOS. On the first Linux run: `expected '644', got '  File: "/tmp/..." ... 644'`,
a filesystem report with the right answer as its last line.

## What didn't work
Reading the symptom as "the fallback never ran". The trailing `644` in the log shows it
did; the mistake was only caught because a reviewer read the whole captured value.

## Solution
Put first the form that fails WITHOUT printing anything on the other system:

    # before
    stat -f %Lp "$f" 2>/dev/null || stat -c %a "$f"
    # after: BSD stat has no -c, exits 1 and writes nothing to stdout
    stat -c %a "$f" 2>/dev/null || stat -f %Lp "$f"

## Why it works
In `$(a || b)`, `a` must fail AND print nothing to stdout. BSD `stat -c` does both
(measured: rc=1, 0 bytes on stdout); GNU `stat -f %Lp` fails but prints first.

## Prevention
- For every `a || b` inside `$(...)`, check on BOTH systems what `a` writes to stdout when
  it fails, not only its exit code.
- Assert the whole captured value (an exact match), never a substring: an exact `644`
  comparison is what made this visible.
- Run CI on Linux as well as macOS: this stayed hidden until the first Linux run.
- A related trap with a flag that means different things: BSD `sed -i -e 's/a/X/' f` reads
  `-e` as the backup suffix, exits 0, edits the file and leaves a stray `f-e` behind.
