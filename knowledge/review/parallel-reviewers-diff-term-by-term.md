---
module: review pipeline (parallel dispatch, cross-file consistency)
tags: [parallel-review, redundancy, list-drift, single-source, enumeration-diff, independent-confirmation]
problem_type: pattern
provenance: ADR-001 contracts-not-code (agent-reviewer + skill-reviewer in parallel, merged bb62fc9)
reuse_count: 0
created: 2026-08-05
---

# Parallel reviewers are not redundant, and lists must be diffed term by term

## Context

Two reviewers ran in parallel over one change: `agent-reviewer` on four agent
definitions, `skill-reviewer` on the format spec and two coordinated files.

**Both independently found the same defect**: the old per-task `Consumes:`/`Produces:`
DEFINITION lines had been left beside the new reference-only field, so an architect
following the format would reproduce exactly the definition sites the change existed to
remove. Two reviewers reaching that from different starting points is the strongest
available signal that a finding is real and not a taste call.

**And one found something the other had explicitly cleared.** `skill-reviewer` v1 wrote
that an inlined binding list "matched" the canonical one. It matched by *register*, not
by *items*: `paths` and `named mechanisms` were absent. It later self-corrected, and its
explanation is the reusable part, it had compared the sentences for MEANING and never
diffed the enumerations term by term. `agent-reviewer` caught it by walking four sites
and comparing lists element by element, finding four different versions of one list,
each internally plausible.

## Guidance

- Dispatch parallel reviewers with **different lenses**, not the same prompt twice.
  Agreement then means confirmation; disagreement points at a real seam rather than at
  reviewer variance.
- Whenever a claim is that two lists, sets or enumerations agree, **diff them element by
  element and state the count**. "Same meaning" is not agreement. "Same register" is not
  agreement.
- The same discipline applies to counting anything: verifying the wrong quantity and
  calling it verified is the failure mode, not laziness. Counting fence delimiters
  instead of fenced blocks passed as verification once in this same change.
- Ask each reviewer to try to find what the OTHER lens would miss. The most valuable
  finding of the pass came from asking one reviewer to find a mutation the guard would
  NOT catch.

## Why it matters

List drift is silent. Nothing fails when four files carry four versions of one binding
list; each reads fine alone. The failure arrives later, when an agent acts on the
shortest one and quietly holds a smaller contract than the system believes it holds.
The same applies to allowlists: a code accepted by one script and degraded by another
tells the user "set to es" while producing English output.

## When to apply

- Whenever a rule, allowlist, or binding list exists in more than one file.
- Whenever a review asserts that two artifacts are consistent.
- Whenever a change touches several artifact TYPES at once (agents + docs + skills), so
  no single reviewer's domain covers all of it.

## Example

```
claim   : "the inlined list matches docs/plan-format.md"
sentence: "signatures, behavior, invariants, tests, verify, boundaries"
canonical: "signatures, paths, behavior rules, INVARIANTS, named mechanisms,
            test cases, verify commands, boundaries"
diff    : missing `paths`, missing `named mechanisms`   -> 6 items vs 8
```

`named mechanisms` is exactly the item a builder talks itself out of, so the shorter
list was not merely incomplete, it was incomplete in the load-bearing place.

## Related

- [[review-only-the-delta]], the other half of the same loop: what to send back, and
  how to end it.
