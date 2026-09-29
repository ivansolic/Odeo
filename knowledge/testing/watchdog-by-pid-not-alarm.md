---
module: bash test harnesses (tests/*.test.sh)
tags: [bash, exec, alarm, timeout, watchdog, infinite-loop, macos, test-harness, stdin, background-job]
problem_type: bug
provenance: odeo-migrate-legacy shim self-exec case (round 3 of the plugin-install review)
reuse_count: 0
created: 2026-09-26
---

# Bound a possibly-looping command with a PID watchdog, not perl alarm

## Problem
A test had to prove a shim does not exec itself forever. The bound `perl -e 'alarm 10; exec @ARGV'`
never fired, and the whole suite hung for minutes.

## Symptoms
The test run never finishes; the process tree shows the same PID re-exec'ing.

## What didn't work
`perl alarm`, and `timeout` (not on macOS by default). The alarm is NOT dropped by exec:
it survives 50 bash self-execs and still fires (rc 142). On macOS each execve restarts its
countdown instead (alarm 3 over `sleep 2; exec sleep 6` fired at 5.4s, without the exec at
3.0s; measured on Darwin 25, bash 3.2, other OSes not checked). A loop that re-execs faster
than the timeout therefore never fires.

## Solution
    bounded() {
      "$@" <&0 & local pid=$!
      ( sleep 10; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 & local dog=$!
      wait "$pid"; local rc=$?
      kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null
      return "$rc"
    }
The watchdog's output goes to /dev/null so it does not hold a command substitution's pipe
open: without that, `out="$(bounded echo hi)"` waits the full 10s.

## Why it works
An exec chain keeps the PID, and the kill targets the PID, not a timer the kernel restarts
on each exec, so it stops the loop at 10s whatever the loop does (exit 143).

## Limit: the bounded command gets NO stdin unless it is redirected
`"$@" &` in a non-interactive shell (no job control) gives the background command
/dev/null as stdin, per the bash manual ("If a command is followed by a & and job control
is not active, the default standard input for the command is the empty file /dev/null").
So with the original helper `printf abc | bounded wc -c` printed 0. A test that pipes data
through it then reads as "the program lost its input": in the 0.3.0 shim test it looked
exactly like the stdin-swallowing bug the shim once had, and would have sent the fix to the
wrong place. Fix, now in the helper above: redirect on the backgrounded command itself,
`"$@" <&0 &` (measured: 3 bytes arrive).

## Prevention
Prove the watchdog on a real infinite exec loop BEFORE trusting it
(`printf '#!/usr/bin/env bash\nexec "$0"\n'`); expect rc=143 after ~10s. And a positive control for input: `printf abc | bounded wc -c`
must print 3.

## Example
tests/odeo-migrate-legacy.test.sh case 8b: a shim whose fallback points at itself must
block (exit 1), not loop; `bounded` turns a regression into rc 143 instead of a hung run.
