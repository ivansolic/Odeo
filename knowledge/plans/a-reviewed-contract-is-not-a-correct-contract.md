---
module: plan-as-contract (architect, architecture-reviewer, builder, docs/plan-format.md)
tags: [plan, contract, fidelity, test-spec, mutation-proof, review-blind-spot,
       compound-invariant, builder-pushback]
problem_type: pattern
provenance: USR-005 localized prose, 2026-08-12 (plan 10/10 across two review rounds;
  code review found the resulting hole at 8/12, merged d168381)
reuse_count: 0
created: 2026-08-12
---

# A reviewed contract is not a correct contract

## Context

USR-005's plan reached **10/10 across two review rounds** and a gate pass. Its contract
C2 declared a compound invariant: a file carries the rule only if it contains **both**
the token `output_language` **and** the pointer `Guardrails 7`. Its Task 4 then specified
three RED test cases, and each one described a fixture carrying **neither** string.

Implemented faithfully. Result: the pointer clause had **zero coverage**. The reviewer
deleted the `Guardrails 7` grep from the lint and the suite reported `34 passed, 0
failed`, real repo green. The invariant that justified accepting a 16-file coupling was
never tested.

Nobody caught it earlier because the review read the plan for internal consistency and
the code for fidelity to the plan, **and the two were consistent with each other.** The
error lived in the space between them.

## Guidance

1. **Review proves consistency, not discrimination.** A plan reviewer can check that a
   specified test case is well-formed and that the plan does not contradict itself. It
   cannot see that a case would pass on the wrong input. Ask of every case a plan
   specifies: *what would this case pass on?*
2. **Fidelity is a transmission channel, not a defense.** "The builder followed the plan"
   explains why the defect exists; it does not make the code right. When a plan specifies
   test CASES rather than only behavior, the builder owes those cases the same mutation
   proof it owes its own: break the mechanism, watch the named case go red, attribute the
   failure to exactly one case.
3. **For a compound invariant, demand one case per clause.** The mechanical check: for
   each clause, is there a case where **only that clause** is violated? If not, the clause
   is unverified no matter how many tests pass. Here the missing cases were
   token-without-pointer and pointer-without-token, and adding both took the suite 34 to
   36.
4. **The tell is an invariant declared in one section and tested in another.** Diff them
   as sets, not by reading. C2 said "both"; the cases said "neither", three times. The
   invariant's negative space was never specified, and prose review does not surface that.
5. **Where the builder may push back, and when.** A plan's contract binds behavior,
   signatures, invariants and named mechanisms. Its specified test cases are a *means* to
   those, so a case that cannot fail for the reason it names is a plan defect to report,
   not a contract to honor. Say it **before** implementing: after the fact it is
   indistinguishable from an excuse.

## Why it matters

Every gate in the system was working and every one passed. The plan gate approved a plan
whose internal logic was sound; the review gate approved code that matched the plan. A
defect that is consistent with the contract is invisible to both, and the only thing that
surfaces it is asking a test what it would accept.

## When to apply

- any plan that specifies test cases, expected exit codes, or a RED count
- any compound invariant (two or more clauses joined by AND)
- whenever "the plan said so" is the reason a check looks the way it does

## Example

```
plan review     rounds 1-2   -> 10/10, C2's "both strings" never questioned
build                        -> three RED cases, each omitting BOTH strings
suite                        -> 34 passed, 0 failed
delete the pointer grep      -> still 34 passed, 0 failed   <- the hole
add 2 clause-isolating cases -> 36; deleting either grep now fails exactly one case
```
