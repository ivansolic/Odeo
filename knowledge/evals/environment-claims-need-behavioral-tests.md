---
module: /improve A/B loop, eval framework, instruction files (skills/, agents/, AGENTS.md)
tags: [improve, ab-test, behavioral-test, form-review, host-facts, fabrication,
       scenario-design, blind-scoring, sourced-values]
problem_type: pattern
provenance: /improve on /build's model-plan step, 2026-08-10 (merged 5ccc98e;
  skill-build rounds 12-14, 8/10 -> 10/10)
reuse_count: 0
created: 2026-08-10
---

# An instruction's claims about the environment need a behavioral test, not a review

## Context

`/build`'s model-plan step said: *"EFFORT is not machine-readable at all (see
AGENTS.md), so there is nothing to resolve: ASK for it."*

Two reviewers across five rounds read that sentence and scored the file. Nobody
flagged it, because it reads as sound design rationale. It was false: `CLAUDE_EFFORT`
and `effortLevel` both exist and are readable. The citation was dangling too, AGENTS.md
said "not **reliably** script-readable", never "not at all".

What found it was running the instruction with fresh subagents. One run printed
`effort high` and **cited its sources**. Because it named them, one command settled it:

```bash
echo "${CLAUDE_EFFORT:-UNSET}"; grep -o '"effortLevel"[^,}]*' ~/.claude/settings.json
```

The run that looked like the fabrication was the only honest one in its group.

## Guidance

1. **Form review cannot test a claim about the environment.** A reviewer checks
   internal consistency, precision, policy conformance. Statements like "X is not
   readable", "no tool reports Y", "the host offers Z" are only testable by executing
   the instruction and verifying what the actor cites. Never treat "five review rounds
   passed" as evidence about a factual claim.
2. **An instruction that demands a fact the agent cannot obtain produces fabrication,
   not a refusal.** The old text ordered the lineup "resolved live". Measured: 2 of 5
   runs invented model names and presented them as the current lineup; 3 of 5 burned
   ~350k tokens (vs ~26k) researching, and 2 of those 3 invented anyway. Replacing the
   demand with an explicit "do NOT enumerate, nothing here reports that" took
   fabrication to 0 of 5. Forbid the unobtainable and name what IS knowable.
3. **Require every value to be spoken with its source.** Unsourced output is
   unfalsifiable; a citation is a testable claim. This serves the tester as much as the
   user.
4. **The fixture must contain the diff.** A behavioral test on an extract narrower than
   the change proves nothing about the uncovered lines. Here the tested extract was the
   rule block, so a stale worked example 200 lines away survived 10 clean runs and was
   caught by a reviewer.
5. **Do not let the scenario suppress the step under test.** The same fixed instruction
   scored 3 of 5 under a scenario opening "everything you know about this session" and
   5 of 5 once the framing allowed reading the real environment. The closed-world
   phrasing forbade exactly the step being measured.
6. **Two independent blind scorers on objective criteria; their agreement is the
   validity check.** Here they matched on all 50 cells. Disclose when the change ADDS a
   criterion the old variant cannot score on, and report the totals with and without it.

## Why it matters

Form review's blind spot sits exactly where instruction files are most dangerous, on
statements about the host, because they look like rationale and read as authoritative.
A false one then propagates silently: this step asked the user for a value it could have
read, on every single run, and no artifact anywhere recorded that as a defect.

## When to apply

- any `/improve` on a skill or agent that asserts something about the environment
- any instruction telling an agent that something is impossible or unavailable
- whenever a reviewer's verdict is about to stand in for a measurement

## Example

```
form review, rounds 8-12   -> the false sentence read and scored, never flagged
behavioral A/B, 10 runs    -> one run cites effortLevel + CLAUDE_EFFORT
one shell command          -> both exist; the instruction was wrong
fix + 10 more runs         -> 5/5 open-world read the source, 0/10 unsourced values
```
