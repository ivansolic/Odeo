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
`perl alarm` (bash drops the inherited alarm across its own exec chain), and `timeout`
(not on macOS by default).

## Solution
    bounded() {
      "$@" & local pid=$!
      ( sleep 10; kill "$pid" 2>/dev/null ) & local dog=$!
      wait "$pid"; local rc=$?
      kill "$dog" 2>/dev/null; wait "$dog" 2>/dev/null
      return "$rc"
    }
An exec chain keeps the PID, so killing by PID stops it (exit 143).

## Prevention
Prove the watchdog on a real infinite exec loop BEFORE trusting it
(`printf '#!/usr/bin/env bash\nexec "$0"\n'`); expect rc=143 after ~10s.
