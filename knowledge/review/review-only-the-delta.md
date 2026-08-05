---
module: review pipeline (architecture-reviewer, code-reviewer, skill-reviewer, agent-reviewer)
tags: [review-loop, delta-review, convergence, blocking-vs-cosmetic, loop-exit, arch-review]
problem_type: pattern
provenance: ADR-001 contracts-not-code (5 plan-review rounds + 4 build-review rounds, merged bb62fc9)
reuse_count: 0
created: 2026-08-05
---

# Review only the delta, and give the loop an exit

## Context

ADR-001 took five plan-review rounds and four build-review rounds. The decision was
right from round 1; what kept it open was that **every fix introduced new, unreviewed
text**, and each round then found defects in the text written to fix the previous round.

Real instances from that change:

- Rewording the snippet rule so it would permit an `awk` program dropped the "at most
  one per task" cap. A rule written against creep began permitting six snippets.
- Adding cross-plan contract references introduced an agreement clause that **forbade
  the mechanism added in the same change**: every reference the new rule mandated would
  have failed the rubric criterion the same commit wrote.
- A check added to catch a dropped acceptance criterion **did not say where to find its
  input** (it needed the story file; the mode block said the agent is given a plan).
- The evidence table said 16 code blocks. That was the fence-DELIMITER count from
  `grep -c '^```'`; there were 8 blocks. The wrong quantity was verified and called
  verified.

## Guidance

1. After the first full review, send back **only the delta**, and say so explicitly:
   "verify only what changed since vN; do not re-review what you already cleared."
2. Require the reviewer to classify every residue as **blocking or cosmetic**, and to
   say whether it can be closed downstream by reviewers that already run there. Without
   that, the loop has no exit and ends on exhaustion instead of on a decision.
3. Stop editing at the **last item that changes behavior**. Line wraps and description
   polish are not worth re-staling a passing eval record.
4. Expect the count to fall, not to reach zero. On ADR-001: 5 findings, then 2 must +
   2 should, then 1 must + 2 should + 2 nits, then 2 non-blocking residues, then clean.
   That is convergence, and it is the signal to ship.
5. When the fix changes a file that a DIFFERENT reviewer scored, that reviewer's record
   is stale too. Regenerate it through the reviewer; never re-date a record by hand.

## Why it matters

The default loop (fold all findings, resubmit the whole document) grows the reviewed
surface every round. The reviewer re-reads settled text while the newest text, which is
the most likely to be wrong because nothing has ever checked it, gets the least
attention. Delta review inverts that.

## When to apply

Any review loop past round 2. Especially on instruction documents (skills, agents,
format specs, ADRs), where a fix is prose and prose has no test to fail.

## Example

```
round 1  full review        -> 4 IMPORTANT + 5 NIT
round 2  "verify only v2 delta"   -> 2 must-change + 6 nits   (all inside the v2 text)
round 3  "verify only v3 delta"   -> 1 must + 2 should + 2 nits
round 4  "verify only v4 delta, and say if it BLOCKS or is cosmetic"
         -> 2 non-blocking residues + "take it to the gate now"
```

The round-4 phrasing is what ended it. Asking for a blocking/cosmetic verdict turns a
reviewer from a defect generator into a decision partner.
