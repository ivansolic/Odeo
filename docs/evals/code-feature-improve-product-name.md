---
artifact: coverage-check
type: code
branch: feature/improve-product-name
artifact_version: 2
date: 2026-07-21
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 10/12
---

## Artifact: bin/coverage-check.sh + tests/coverage-check.test.sh (deterministic PRD-requirement coverage gate, v2)

## Round-by-round (Round 1 -> Round 2)
- correctness 2 -> 2 (held). CRLF was the round-1 latent risk; now fixed, so it
  strengthens rather than changes an already-passing criterion.
- security 2 -> 2 (held). Read-only, no injection surface, no eval/shell of input.
- performance 2 -> 2 (held).
- readability 2 -> 2 (held). The awk state machine was replaced by a single
  two-stage grep; net simpler.
- testing 1 -> 2 (MOVED UP). Suite grew 6 -> 12 assertions. The three round-1
  gaps are now pinned: R1-vs-R10 whole-token guard (both fail and pass legs),
  non-English PRD resolving by ID, and inline `**R2**` prose NOT counted.
- conventions 1 -> 2 (MOVED UP). Both the PRD `id:` and each story `prd:` value
  now pass through `tr -d '\r'`, matching focus-check/merge-gate/spec-gate. The
  cross-platform CRLF bug that would have caused false COVERAGE FAIL on GNU sed
  is closed.

Total 10/12 -> 12/12. Regression status: BETTER on two criteria, no regressions.

## Achievable ceiling
12/12, now reached. Nothing about this artifact structurally caps any criterion
below max. The two round-1 deductions were fixable gaps (CRLF portability and
test depth), both fixed, both verified.

## Verdict
APPROVE. Both round-1 Important findings are resolved and independently verified:
- CRLF: a `\r`-terminated PRD id + story `prd:`/`covers:` now passes (rc=0, "all 2
  requirements covered"). The round-1 false-FAIL on GNU sed is gone.
- Tests: all 12 assertions pass (rc=0). I re-ran and also probed the disjoint
  multi-story union (rc=0, "all 3 requirements covered"), a no-`covers:` story
  (correctly FAILs without aborting under set -e), and the whole-token guard at
  the regex level (`grep -qx 'R10'` does not match `R1`).

## On the section-scoping trade (asked)
Sound. Dropping the awk section-scope in favor of "any list item whose bold token
is R<n> is a requirement" is the correct trade for language independence, and it
matches the /prd emission convention (requirements are the `- **R<n> , ...` list
items). The old awk approach keyed the requirement set off an English-ish heading
regex (`[Rr]equirements`), which is exactly the language dependence this branch
exists to remove: a German `## Anforderungen` PRD would have yielded zero
requirements and a spurious exit 2. Verified the new path resolves that PRD 2/2.

The cost is real but narrow: a bold `- **R9 , ...` list item placed OUTSIDE the
requirements section (e.g. under `## Changelog`) now counts as a requirement (I
verified: it produces COVERAGE FAIL for R9). This is acceptable because (a) the
recogniser is tight, it requires a LIST ITEM with a leading bold `**R<n>` token,
so prose "see R9" and inline `**R9**` mid-sentence do not trip it (both tested);
and (b) reusing the `R<n>` bold-list form for something that is NOT a requirement
is an authoring contract violation, and failing closed (demanding coverage) is
the safe direction for a coverage gate, worst case is a false FAIL the author
fixes by not overloading the notation, never a false PASS that ships an uncovered
requirement. That safe-direction property is what makes the trade defensible: the
gate errs toward over-counting, never under-counting.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- tests/coverage-check.test.sh (test 1/2). The disjoint multi-story union is
  exercised by test 1 (USR-A covers R1 R2, USR-B covers R3, all pass) but no
  assertion isolates "the union is what passes". Test 2 removes USR-B and asserts
  R3 fails, covering half. Fully pinning union would add one symmetric case (drop
  USR-A, assert R1/R2 named). Behavior is correct (verified manually); this is
  test-explicitness only, not a defect.
- bin/coverage-check.sh:38. `grep -m1 '^covers:'` still reads only the single
  `covers:` line, so a multi-line YAML list (`covers:\n  - R1`) would silently
  under-count. Current stories all use the inline form; a one-line "inline
  `covers:` only" note at the grep would remove all doubt if the template changes.
- bin/coverage-check.sh:29. The recogniser accepts `-`/`*` bullets but not
  numbered list items (`1. **R1 ...`). Matches what /prd emits (dash bullets), so
  correct today; worth a comment only if numbered requirement lists become valid.

## What's good
- The round-1 fixes are precise and minimal-blast-radius: two `tr -d '\r'` inserts
  on the id/prd extraction, and a regex swap that deletes the awk state machine
  entirely (fewer lines, one recognition rule, no heading-language coupling).
- The whole-token guard survives the refactor: extraction is two-stage
  (`grep -oE '^...\*\*R[0-9]+'` then `grep -oE 'R[0-9]+'`) and matching is
  `grep -qx`, so R1 still cannot satisfy R10. This is the one subtlety most
  refactors would silently break; the test now locks it on both legs.
- Language independence is genuinely achieved and tested, not just claimed: the
  German-heading PRD resolves 2/2 by ID with zero prose dependence, which is the
  branch's reason to exist.
- set -euo pipefail interactions remain sound after the rewrite: no-`covers:`
  stories, empty union, and the `grep -c` count all still fail closed without
  aborting the parent (re-verified).

## History
- v1 (2026-07-21): 10/12 APPROVE WITH COMMENTS. Two Important findings, CRLF
  portability in the `prd:`/`id:` compare, and thin test coverage of the
  language-independence / whole-token / prose-not-counted claims.
- v2 (2026-07-21): 12/12 APPROVE. Both Important findings fixed and verified;
  awk section-scope replaced by a language-independent bold-R list-item
  recogniser; suite 6 -> 12 assertions. Trade judged sound (fails closed).
