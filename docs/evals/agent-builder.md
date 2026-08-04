---
artifact: builder
type: agent-definition
branch: chore/adr-001-contracts-not-code
artifact_version: 4
date: 2026-08-04
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

# Agent: builder (round 3, at HEAD f4e295a)

Scoped re-review: verified ONLY the two closures claimed for this file (the materiality
filter's "behavior-visible" ambiguity, and the binding-list citation). Everything cleared in
rounds 1 and 2 carries forward with its evidence re-checked at this HEAD.

Version note: `artifact_version: 4` = the fourth reviewed state (v2 = aee5ab1, v3 = f8f8da6,
v4 = f4e295a).

Method note: no Bash in this reviewer's grant; scored the file as it stands at HEAD.

## Scores (all carried, none moved)

- **trigger/description clarity: 2** , `:3` unchanged: what, when, and the refusal condition
  ("Requires the plan; without an approved plan it does not build").
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), every
  member exercised by the pipeline, contained by `isolation: worktree` (`:7`) and "One story,
  one worktree, never merge" (`:113-114`).
- **role boundary: 2** , step 5's escalation (`:48-51`) and 5b's routing of the hard case
  back into it (`:59-61`) unchanged and still composing on one concept.
- **policy conformance: 2** , `model: sonnet` (`:5`) is the pinned execution TIER per
  AGENTS.md:52-54 and from the allowed sonnet/inherit set, `effort: high` declared,
  `isolation: worktree` set on the one role that mutates files in parallel, C11 clean.
- **instruction quality: 2** , both round-2 residuals in the fix set are closed and 5b is now
  the single self-consistent statement of the latitude line (details below). One carried
  Minor and one Nit remain.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Every criterion at its described top level; one Minor and one Nit remain open below.

## Round-by-round
Round 1 (aee5ab1): 9/10, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10, 3 Minor open.
Round 3 (f4e295a): 10/10 PASS. Two Minors closed, one carried.

## Closures verified
- **CLOSED (was Minor), "behavior-visible" misreadable as a trigger to ask** , `:62-66` now
  reads "behavior-visible but NOT covered by any stated behavior rule (an error-message
  wording, the order of two independent outputs), or convention-level. Not every local
  variable. If a stated rule covers it, that is not latitude, it is the contract." Better
  than the fix I proposed: the added final sentence states the rule from the other direction,
  so the filter now defines the reportable set AND re-affirms the contract boundary in the
  same breath, which is where a builder is most likely to reason wrongly.
- **CLOSED (was Minor), this file re-listing the binding set** , both sites now cite the
  canonical list rather than copying it: `:52-55` ("The plan binds the canonical list in
  `docs/plan-format.md` (signatures, paths, behavior rules, invariants, named mechanisms,
  test cases, verify commands, boundaries; that file wins if this differs)") and `:100-102`
  (the report's contract-adherence bullet, same citation). Both now include *named
  mechanisms* and *paths*, the two items each was missing, and both carry the precedence
  marker, so the parenthetical is a reading convenience rather than a competing definition.
  Cross-checked the family: `docs/plan-format.md:5-9` (canonical), `agents/code-reviewer.md`
  `:35-38`, `skills/build/SKILL.md:98-100` ("holds the plan's contract exactly: the canonical
  binding list in docs/plan-format.md"). All sites now cite; round 1's four-way drift is
  fully closed.

## Open (carried)
- **Minor, `:10` and `:36`** , "executing its APPROVED plan exactly" and "never guess
  mid-build" still precede any pointer to 5b, so a reader meets the unqualified form 42 lines
  before the qualification. Mitigated by the Rules summary at `:117-118`. Fix: at `:10`,
  "what 'exactly' binds is in step 5b".
- **Nit, new from this edit, `:55-57` and `:102-103`** , both insertions leave short
  half-lines mid-sentence ("HOW you satisfy them is yours: choose the / implementation, and /
  choose it well", and "boundaries), of which / there should be none"). Cosmetic, same class
  as round-1 finding 15; rewrap both paragraphs.

## The three latitude cases (re-checked, unchanged)
All three still resolve unconditionally. Case 1 now also gets a cleaner report answer from
the reworded filter (a local control-flow pick is neither behavior-visible-and-unruled nor
convention-level, so it is not reported). Case 2 unchanged. Case 3 still closes from both
branches (`:59-61` recognise-and-ask, `:61-62` unsure-and-ask), with the same irreducible
residual: an affirmatively-wrong classification, which only a greppable mechanism marker in
the plan would catch (open in `agents/architect.md:48-49`).

## Integrity
House voice, consistent with `agents/architect.md` and the skills. No copied text.

## Vs previous version
Held at 10/10 with two Minors closed and no regression. Baseline is the round-2 per-file
record (v3).

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; all
  three 5b qualifications landed, latitude case 3 became unconditional; 3 Minors open.
- 2026-08-04 v4 (f4e295a): scoped re-review of the materiality rewording and the binding-list
  citation, both confirmed closed (family-wide drift now fully closed). Round 3 = 10/10 PASS,
  held. `:10`/`:36` pointer still open (Minor); one new Nit (rewrap).
