---
artifact: bin/second-opinion.sh
type: code
branch: feature/second-opinion-code
artifact_version: 2
date: 2026-07-19
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 9/12
---

## Summary
Sanctioned wrapper for a paid cross-model review. Sends ONE artifact to an
external vendor CLI (codex/gemini), read-only, after a hard privacy-scan gate,
capturing a raw transcript + provenance. Reviewed hard on security and
correctness because this sends data off the machine. Round 2 re-review after the
two round-1 Important findings + the two nitpicks were addressed.

Test suite: 16/16 pass (`bash tests/second-opinion.test.sh`), no network,
PATH-shimmed fake vendor. Two new tests added since round 1 (empty output -> 3,
model parser ignores prose).

## The security-critical questions, answered (re-verified round 2)
- **Any path to the vendor call without a passing scan?** No. The gate (line 70)
  runs before the only vendor invocation (line 121). Fail-closed: rc 1 -> exit 1,
  any other non-zero -> exit 2. Re-verified with a secret payload in a fresh dir:
  exit 1 and no log dir is ever created, the vendor never runs.
- **Can a missing/unauth vendor be simulated?** No. `command -v` miss -> exit 3;
  `--version` probe failure -> exit 3; version-OK-but-fails-the-call (realistic
  unauth) -> rc!=0 -> exit 3. Re-verified with a fake that versions OK then exits
  7: got 3.
- **Payload injection (crafted filename / contents)?** None. VCMD is an array,
  the prompt is delivered on stdin, the filename is never interpolated into a
  shell command. Re-verified with a literal filename `$(touch PWNED); rm -rf x.diff`:
  no PWNED marker, run completed rc 0 with the filename treated as data.
- **Empty output?** Now caught: rc-0 with a zero-byte transcript -> exit 3
  ("no output, not a usable second opinion"). Test present.
- **Provenance integrity?** sha256 portable, trap cleans the prompt temp, logs
  gitignored, and the model parse no longer corrupts provenance (see below).
- **Exit-code contract?** Consistent with the header (0/1/2/3/124), all exercised.

## Round-1 findings: status
- **[FIXED] Orphaned watchdog sleep.** The sleeping-subshell watchdog is gone.
  Replaced by a foreground poll loop (lines 125-133) that ticks `sleep 1` until
  the vendor exits or the timeout elapses, then TERM + 1s grace + KILL. No
  process is backgrounded except the vendor itself, so nothing can orphan.
  Adversarially verified: after a fast happy run with
  `SECOND_OPINION_TIMEOUT=300`, zero `sleep 300` processes exist before or after
  (before=0, after=0). The leak is genuinely eliminated by design, not patched.
- **[FIXED] Model-parse over-match.** Now a line-anchored sed (line 156):
  `s/^[[:space:]]*"?[Mm]odel"?[[:space:]]*[:=][[:space:]]*"?([A-Za-z0-9._-]+).*/\1/p`.
  Adversarially verified: prose ("the data model here is wrong", "our object
  model became inconsistent", "using model: which is set below") captures
  nothing and falls back to requested/unknown; real declarations (`model: X`,
  `  model = X`, `"model": "X"`, `Model: X`) capture the value correctly. The
  fallback direction is the safe one: provenance is never a guess.
- **[FIXED, nitpick] Empty-output guard** added (`[[ ! -s "$RAW" ]]` -> exit 3).
- **[FIXED, nitpick] Probe message** softened; no longer claims to prove auth.

## Critical (must fix before merge)
None. No path leaks the payload before the gate, no simulation path, no
injection vector, no orphaned process, no provenance corruption.

## Important (should fix)
None.

## Nitpicks (optional)
- bin/second-opinion.sh:156, the line-anchored parser will miss a model
  declaration formatted as a markdown list item (`- model: X`), recording the
  requested model or "unknown" instead. This is the intended safe fallback (a
  guess is worse than a known gap) and the raw log always carries the truth, so
  it is acceptable; noted only so the behavior is not mistaken for a bug later.
- bin/second-opinion.sh:66, scan resolution still prefers
  `$HOME/bin/privacy-scan.sh` over the repo copy and accepts a non-executable
  file (`-x || -f`), always invoked via `bash`. A stale `~/bin` copy would
  shadow the repo's. Minor supply-chain surface; acceptable, unchanged from r1.
- bin/second-opinion.sh:110, the no-git fallback writes the transcript to a
  `mktemp -d` (0700) outside the documented logs dir without announcing the
  location. Safe but silent; unchanged from r1.

## Scores
correctness 2/2 (watchdog leak eliminated by the poll-loop redesign; model parse
line-anchored and safe; empty output caught) ·
security 2/2 (gate-before-send fail-closed and re-verified, no simulation, no
injection, temp perms 0700, logs gitignored) ·
performance 2/2 (no backgrounded sleep, no orphan; the only background process is
the vendor, reaped via wait) ·
readability 2/2 (clear structure, header contract matches behavior, comments
explain the poll-loop and the anchored parser) ·
testing 2/2 (16/16, now covers the two former defects: empty-output -> 3 and the
model-parse prose case, plus the timeout, block, injection-by-construction, and
missing/unauth vendor) ·
conventions 2/2 (bin style, exit 3 for missing/failed CLI, privacy-scan pre-send
gate, gitignored logs, no em/en dashes)
-> total 12/12 (threshold: >=9, no zero) PASS

## What's good
- The pre-send gate is fail-closed and now doubly confirmed: on a blocked
  payload the vendor is never invoked and no log dir is created.
- The watchdog rewrite is the right fix, not a workaround: removing the
  backgrounded sleep removes the whole class of orphan, rather than chasing the
  child PID after the fact.
- The model parser now fails safe: it either reads a real declaration or records
  the requested/unknown value, and never fabricates provenance from prose.
- Test suite grew to cover exactly the two things round 1 flagged, so the fixes
  are regression-guarded, not just hand-checked.

## History
- v1 (2026-07-19, opus-4-8 strongest): first review. 9/12, APPROVE WITH COMMENTS.
  Two Important findings (watchdog sleep leak, model-parse over-match) dropped
  correctness and performance to 1, testing to 1. No Criticals: send-after-scan
  ordering, no-simulation contract, and injection resistance all held.
- v2 (2026-07-19, opus-4-8 strongest): re-review after fixes. 12/12, APPROVE.
  Regression vs v1: BETTER (+3). Both Important findings fixed and adversarially
  re-verified (no orphan sleep survives a fast happy run; prose "model" is not
  captured while real `model:` lines are). Both nitpicks (empty-output guard,
  probe wording) also addressed. Two new tests lock in the former defects; suite
  now 16/16. Security invariants (scan-before-send, never-simulate, exit-code
  contract, injection resistance) re-confirmed unchanged. No Criticals, no
  Important findings remain; only three acceptable nitpicks.
