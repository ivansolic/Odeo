---
artifact: docs-knowledge-one-home-for-a-definition
type: code
branch: docs/knowledge-one-home-for-a-definition
reviewed_commit: 1be65e9
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

# Code review: docs/knowledge-one-home-for-a-definition (round 2)

Scope of round 2: the delta `59506b7..1be65e9`. It is one commit
(`1be65e9 docs(knowledge): review round 1, four drifts not three, the C17 fallback, a
skip-when line`) and touches one file, `knowledge/review/one-home-for-a-definition.md`. I
re-read the whole file at 1be65e9, not only the hunks.

Output language: en (handed at dispatch). The model tier is recorded as `strong`: Opus
class counts as sonnet class and up. I did not claim `strongest` because this agent could
not re-check the live model lineup.

## Verdict
APPROVE WITH COMMENTS

## Round-1 findings: closure
1. **Closed (Important, the count).**
   - Lines 19-21 now read "Round 2 found four terms worded differently in the two files
     (note, unverified, criterion 4, scoped), three of them created by round 1's fixes".
     This matches the `0e01673` commit message word for word in substance.
   - "scoped" is now in the term list on line 18.
2. **Closed (Important, the recipe contradicted C17).**
   - Guidance 1 (lines 27-29) gains the fallback: keep both copies and add an equality
     lint, as C17 does.
   - "When to apply" (lines 49-50) now ends "consolidate it, or, where one file cannot
     point at the other, guard their equality with a lint".
   - The C17 example and the recipe now agree. This matches `docs/invariants.md` row C17.
3. **Closed (nitpick, the causal claim).**
   - The provenance now says "the drift ended once the terms had one home, guarded by lint
     C18".
   - Why it matters now quotes round 5's record. I checked the quote with grep: "No
     term-meaning drift was found in either file" occurs once in
     `docs/evals/skill-research.md`.
   - The run past the cap is stated as "part of what the drift cost", which is suitably
     hedged.
4. **Closed (nitpick, related entry).** The Examples section links
   `knowledge/review/parallel-reviewers-diff-term-by-term.md`.
5. **Closed (nitpick, skip-when).** Lines 51-52 add "Skip it when only one file uses the
   term, or the second file merely names it without defining it". That skip condition is
   the target state the entry describes, so it is coherent.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `knowledge/review/one-home-for-a-definition.md:19-20`: "four terms ... (note,
  unverified, criterion 4, scoped)" calls "criterion 4" a term, and it is not one. The
  source commit says these four things were "worded differently". Fix: "four places worded
  differently".
- `knowledge/review/one-home-for-a-definition.md:43`: this line is 99 characters wide,
  while the rest of the body wraps at about 92. Fix: re-wrap the line so "Rounds 4 and 5
  ran past the" starts the next one. This is cosmetic.

## Checks
- `language-guard.sh` with the branch name and the commit subject: "machine surfaces
  clean".
- `prose-language-check.sh`: OK, en=141.
- The file has no non-ASCII bytes and no em or en dashes.
- All six frontmatter fields are present.
- Everything confirmed in round 1 is unchanged by this delta:
  - the trajectory 8, 8, 7, 9, 10;
  - precision 1, 1, 1;
  - C18's behaviour and its fail-closed story;
  - C17's date;
  - SKILL.md steps 4 and 4b.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached.

## What's good
- Every fix was taken from the evidence: the count comes from `0e01673`, and the round 5
  claim is a quote checked with grep, not a paraphrase.
- The C17 fallback makes the recipe hold for the one pair where it could not be applied.
- The fixes added 21 lines and left the entry short.

## History
- Round 1 (`59506b7`): APPROVE WITH COMMENTS, 11/12, with correctness at 1.
  - Important: "three drifts, all three" was a wrong count; `0e01673` says four, three of
    them created by round 1's fixes.
  - Important: "When to apply" told the reader to consolidate CLAUDE.md and plan-format,
    which C17 shows is impossible.
  - Nitpicks: the C18 and 10/10 causal wording, a missing link to the related entry, and
    no skip-when line.
- Round 2 (`1be65e9`): APPROVE WITH COMMENTS, 12/12. All five findings are closed. Two
  cosmetic nitpicks remain. Trajectory: 11 -> 12, which is better.
