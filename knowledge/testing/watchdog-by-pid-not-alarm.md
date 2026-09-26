---
module: bash test harnesses (tests/*.test.sh)
tags: [bash, exec, alarm, timeout, watchdog, infinite-loop, macos, test-harness]
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
      "$@" & local pid=$!
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

## Prevention
Prove the watchdog on a real infinite exec loop BEFORE trusting it
(`printf '#!/usr/bin/env bash\nexec "$0"\n'`); expect rc=143 after ~10s.

## Example
tests/odeo-migrate-legacy.test.sh case 8b: a shim whose fallback points at itself must
block (exit 1), not loop; `bounded` turns a regression into rc 143 instead of a hung run.
