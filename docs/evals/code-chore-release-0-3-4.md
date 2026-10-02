---
artifact: release-0.3.4
type: code
branch: chore/release-0.3.4
reviewed_commit: c56da53
artifact_version: 1
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: chore/release-0.3.4, round 1

## Scope reviewed

The release commit c56da53 (`git show c56da53`): `.claude-plugin/plugin.json` 0.3.3 -> 0.3.4,
one line, nothing else. The release contents are `git log 95d17e3..c56da53`, 53 commits on a
linear history, five branches. 95d17e3 is the 0.3.3 release on local main. origin is the
public publication, a separate history, so it was not compared.

## Checks

1. **Coverage.** Every non-eval commit is covered by an approving record. Each record is
   anchored at, or after only eval commits past, its branch's last code commit:
   - feature/plan-human-layer (6b5e8f8..c999834): code-feature-plan-human-layer APPROVE,
     agent-architect, skill-build and skill-plan-format PASS, all at 2859827. 2859827 and
     c04c60b touch docs/evals only.
   - fix/assertion-count-honesty (4c96dcb..64f0635, the CI step 91e979c included):
     code-fix-assertion-count-honesty APPROVE at 64f0635.
   - chore/research-rubric-and-citations (45b65b8..eb7e7cb, C18 and README 1424/1426
     included): code-chore-research-rubric-and-citations APPROVE and skill-research PASS
     at eb7e7cb.
   - docs/knowledge-one-home-for-a-definition (59506b7, 1be65e9): APPROVE WITH COMMENTS
     at 1be65e9.
   - test/plan-human-layer-behavior (ad5faba..59d9183): agent-architecture-reviewer and
     skill-review-calibration PASS at 59d9183. bb51a80 touches docs/evals only. The branch
     has no code-reviewer record, but it ships no executable code to users: its only script
     is recount.py, which is internal. I ran it at c56da53 and it reproduces the figures the
     skill record checked by reading (5/5, 0/5, 0/10, 5/10, and the gate copies 5/5 each).
   agent-architecture-reviewer.md moved from branch feature/plan-human-layer to
   test/plan-human-layer-behavior. That record re-read the whole agent file, so the final
   state of the agent is covered.
   No commit is uncovered.
2. **Bump type.** Patch is right under CONTRIBUTING.md:42-45. Nothing moves or is renamed,
   and no file users depend on changes location. The most structural item is the plan
   format: criterion 6 makes Summary, Why and Explanation required (`plan-format.md`, "The
   human layer is never `none`"). After upgrading, a plan still in plan review draws a
   criterion-6 finding and needs the three sections. No script refuses an older plan,
   though. No script parses plan sections, `agents/builder.md` is unchanged, and an
   already approved plan builds as before. So this is a stricter review rule, not a
   breaking or structural change. `stop rule:`/`gate:` is a marking convention judged by
   review, not by a parser. C17/C18, the docs-claims skip counting and the CI step run on
   this repo only. The research rubric and its optional frontmatter fields are additive.
   The `docs/calibration-runs/` move is internal.
3. **Version sites.** `git grep` finds `"version"` and `0.3.3`/`0.3.4` only in
   `.claude-plugin/plugin.json:4`. marketplace.json carries no version.
4. **Classification.** All 52 paths changed in the range are classified, 26 public and
   26 internal. All 332 tracked paths are classified, 223 public and 109 internal, with
   zero unclassified. This was checked with the guard's own rule: a trailing slash is a
   prefix, anything else is exact. `docs/calibration-runs/` is on the internal list
   (internal-paths.txt:29) and `docs/internal-paths.txt` itself is public.
5. **Counts.** `bash scripts/docs-claims-check.sh` passes at c56da53: 26 programs, 39
   suites, 26 with their own suite. The assertion count was skipped as designed; the
   caller runs the full `--assertions` run (README.md:241, 1426) separately. No file under
   `tests/` is internal (47 tracked, all public), so the snapshot keeps every suite and
   every fixture. No suite reads an internal repo path: test references to `.claude/`,
   `docs/plans` and `knowledge/` are all in temp sandboxes. The two suites that read the
   real tree need at least 50 tracked paths, and the public tree has 223. The public
   tree should therefore count the same 1426, provided the full run confirms 1426 here.
   This is inferred from reading the suites, not measured on a snapshot. `skills-lint.sh`
   passes at c56da53.
6. **Dashes.** Zero U+2014/U+2013 in all of `git diff 95d17e3..c56da53`, not only in
   added lines. The search was checked against a planted positive control.

## Findings

Critical: none. Important: none.

Nitpicks:
- docs/checklists/review-calibration.md:97: a PUBLIC file points at
  `docs/evals/calibration-plan-human-layer.md`, an internal record that the snapshot
  drops, so a public reader is sent to a file that does not exist there. This is new in
  the range: at 95d17e3 no public checklist cited docs/evals. Fix: drop the
  parenthetical, or say "(the maintainers' calibration note has the history)".

Observation, not scored: the two records at 59d9183 ran on the same model but declare
different tiers (agent-architecture-reviewer `strongest`, skill-review-calibration
`strong`). Both pass the gate. It is provenance noise for the next release review, not a
defect in this release.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero). PASS.

## Ceiling

12/12 reached. One optional nitpick remains, so the verdict is APPROVE WITH COMMENTS.
The 1426 assertion total is the caller's separate run and is not certified by this
record.

## History

- Round 1, `c56da53`, 12/12, APPROVE WITH COMMENTS. This is the first record for this
  branch. For comparison only, since it is a different branch: the 0.3.3 release review
  ended at 12/12 after three rounds.
