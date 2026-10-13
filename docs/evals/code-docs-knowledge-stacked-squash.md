---
artifact: docs-knowledge-stacked-squash
type: code
branch: docs/knowledge-stacked-squash
reviewed_commit: e82c918
date: 2026-10-13
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
previous_total: 10/12
---

# Code review: docs/knowledge-stacked-squash (round 3, final under the loop cap)

Scope: `git diff 84dde3e e82c918`, one commit, one file:
`knowledge/fixes/stacked-branch-squash-conflicts-where-diffs-overlap.md`. The commit
applies the structural fix the human chose after round 2: the measured table goes into the
entry, and every rule names the rows it holds for. Output language: en (handed at dispatch).

## Verdict
APPROVE WITH COMMENTS

## Round-2 findings: closure
1. **Closed (Important).** The safe route and the combine rule went beyond what was
   measured. They are now scoped to named rows:
   - `--onto` is stated as clean in rows 1 to 4 and 6, and conflicting in rows 5 and 7.
   - The hand-resolution recipe ("main's A lines plus `git diff old-A-tip B`") is limited to
     rows 2 to 4. I checked it against each of those rows. In row 3, main's A line equals the
     old one, so applying B's diff gives B's edit. In row 2, B's diff does not touch A's
     line, so the fix stays. Row 4 is additive.
   - Rows 5 and 7, the true double edits, are named a human judgment call, with "never take
     either side".
   - A scope line forbids extending the table by analogy.
   - This closes the defect class, not only the instance: no rule is now stated for a shape
     outside the table.
2. **Closed (nitpick).** Plain `git rebase main` is no longer a blanket "still conflicts".
   The table gives the outcome per row.
3. **Checked (nitpick).** `8c5d29e` exists on Odeo-personal main ("chore(global): sharpen
   story and plan rules after review", `global/CLAUDE.md`, +20/-6). Its message covers
   "Plan shape" rules, which is consistent with the Examples claim that it edited
   plan-shape lines.

## Table verification (every cell)
- My round-1 run (`repro.sh`) covers:
  - squash B: rows 1 to 6;
  - `--onto`: row 2 (case 7);
  - plain rebase: row 2 (case 8).
- My round-2 run (`repro2.sh`) covers both rebase routes for rows 1 to 5 and row 7.
- The three remaining cells come from the author's `fill-gaps.sh`, which I re-ran myself:
  - row 7, squash B: CONFLICT;
  - row 6, `--onto`: clean, `l5-fixed-on-A` and `B-line` kept;
  - row 6, plain rebase: clean, same lines kept.

All 21 cells match the entry.

## Critical (must fix before merge)
None.

## Important (should fix)
None.

## Nitpicks (optional)
- `...where-diffs-overlap.md:39`: the summary line overstates row 3. It reads "Every clean
  result kept A's latest lines and all of B's lines, and A's line appeared once." In row 3's
  clean results, A's line is replaced by B's edit (`A-line-by-B`), which is the correct
  result. So literally, A's line does not "appear" at all.
  **Fix:** "kept A's latest lines (in row 3, as B edited them) and all of B's lines, with no
  duplicate".
- `...where-diffs-overlap.md:56-59`: "review reproduced 8 cases" is now dated, since the
  evidence is the 7x3 table. **Fix (optional):** "review measured the table above".

## Checks that passed
- `language-guard.sh` reports "machine surfaces clean" for the file, the branch and the
  commit subject "docs(knowledge): stacked squash entry states each rule by its measured
  table rows".
- No non-ASCII bytes and no em or en dashes. No line exceeds 100 characters; the table
  rows are within the limit.
- The frontmatter shape matches the sibling entries. `knowledge/` stays internal
  (`docs/internal-paths.txt:18`).

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 2/2 · conventions 2/2  -> total 12/12  (threshold: >=9, no zero)

## Ceiling
12/12, reached. The verdict is APPROVE WITH COMMENTS rather than APPROVE because of the
two optional wording nitpicks. Neither would lead an agent to a wrong action.

## What's good
- The structural fix closed the class. Every rule now carries the evidence it holds for,
  and the unresolvable rows are handed to a human instead of being given a rule.
- The safe default (`--onto` first, and stop at a conflict) fails safe in every row,
  including conflicts outside the table.
- The three unmeasured cells were measured before the rules were written, not after.

## History
- Round 1 at 5df0dbf: 9/12, REQUEST CHANGES (correctness 0).
  - Critical: "resolve toward main" dropped B's own edits (cases 3 and 5).
  - Important: the "only if A changed after the cut" scope was wrong in both directions.
  - Important: the rebase route had no command, and a plain rebase conflicts.
  - Three nitpicks.
- Round 2 at 84dde3e: 10/12, REQUEST CHANGES (correctness 1).
  - All round-1 findings were closed.
  - New Important: the safe route and the combine rule failed when A's post-cut fix and
    B's edit overlap (cases 5 and 9).
  - Stop condition 3 was reached (the same class twice). The human chose the structural
    fix plus round 3.
- Round 3 at e82c918: 12/12, APPROVE WITH COMMENTS.
  - Every finding is closed, and all 21 table cells are verified.
  - Two optional nitpicks remain.
  - Regression check: improved (10 -> 12). Trajectory 9 -> 10 -> 12.
