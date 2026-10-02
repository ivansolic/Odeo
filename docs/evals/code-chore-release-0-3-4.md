---
artifact: release-0.3.4
type: code
branch: chore/release-0.3.4
reviewed_commit: e16debf
artifact_version: 2
date: 2026-10-02
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 12/12
verdict: APPROVE
---

# Code review: chore/release-0.3.4, round 2

## Scope reviewed

Round 2 covers `git diff c56da53..e16debf`, two commits:
- f983e02 adds the round-1 record to docs/evals. It is byte-identical to the file this
  reviewer wrote, so nothing was hand-edited.
- e16debf changes `docs/checklists/review-calibration.md:96-97` and nothing else. It
  removes the parenthetical that pointed at the internal
  `docs/evals/calibration-plan-human-layer.md`.

No other path moved since c56da53. The round-1 scope is unchanged:
- the release commit c56da53, which bumps `.claude-plugin/plugin.json` from 0.3.3 to 0.3.4
  and nothing else;
- the release contents, `git log 95d17e3..c56da53`, 53 commits on a straight line from
  five branches. 95d17e3 is the 0.3.3 release on local main.

origin is the public publication, a separate history, and was not compared.

## Checks

Carried forward from round 1, because no code moved apart from the line above:

1. **Coverage.** Every non-eval commit is covered by an approving record. Each record is
   anchored at its branch's last code commit, or at a later commit that only adds records:
   - `feature/plan-human-layer`: records at 2859827;
   - `fix/assertion-count-honesty`: record at 64f0635;
   - `chore/research-rubric-and-citations`: code and skill records at eb7e7cb;
   - `docs/knowledge-one-home-for-a-definition`: record at 1be65e9;
   - `test/plan-human-layer-behavior`: agent and skill records at 59d9183.

   That last branch has no code-reviewer record. Its only script, `recount.py`, is internal,
   and in round 1 it reproduced the figures its skill record states. No commit is uncovered.
   e16debf is this branch's own fix, and this record covers it.
2. **Bump type.** Patch is the right bump under CONTRIBUTING.md:42-45. Nothing is moved or
   renamed. The plan format's new criterion 6 (Summary, Why and Explanation required) is a
   stricter review rule, not a structural change:
   - no script refuses or parses an older plan;
   - `agents/builder.md` is unchanged;
   - an approved plan builds as before.

   The other items need no bump decision:
   - `stop rule:`/`gate:` are checked by reviewers, not by a parser;
   - C17/C18, the docs-claims skip counting and the CI step run only on this repo;
   - the research rubric is additive.
3. **Version sites.** The only one is `.claude-plugin/plugin.json:4`.
4. **Classification.** All 332 tracked paths at c56da53 are classified: 223 public, 109
   internal, none unclassified. The two paths touched since are already classified:
   `docs/checklists/review-calibration.md` is public and `docs/evals/` is internal.
   `docs/calibration-runs/` is internal (`internal-paths.txt:29`).
5. **Counts.**
   - The quick `bash scripts/docs-claims-check.sh` passes again at e16debf.
   - The full `--assertions` run was the coordinator's, not this reviewer's. It printed
     "ok: assertions = 1426" and "every countable claim matches the tree" with rc 0, which
     matches README.md:241. I did not re-run it, so it is recorded as their measurement.
   - No file under `tests/` is internal, and no suite reads an internal repo path. The two
     suites that read the real tree need at least 50 tracked paths, and the public tree has
     223. So the public snapshot should count the same 1426. That is inferred from reading
     the suites, not measured on a snapshot.
6. **Dashes.** There are no em or en dashes in `git diff 95d17e3..c56da53`, and none in
   `git diff c56da53..e16debf`.

Round-1 nitpick, applied: the sentence now ends at "`What you decide`." and still reads
correctly. No public file under `docs/checklists`, `docs/plan-format.md`, `agents/`,
`skills/` or `README.md` still names `calibration-runs` or `calibration-plan-human-layer`.

## Findings

Critical: none. Important: none. Nitpicks: none.

Observation, not scored: the two records at 59d9183 ran on the same model but declare
different tiers. `agent-architecture-reviewer` says `strongest` and `skill-review-calibration`
says `strong`. Both pass the gate.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero). PASS.

## Ceiling

12/12 reached and nothing is left open. The 1426 total is the coordinator's measurement,
reported here as theirs.

## History

- Round 1, `c56da53`, 12/12, APPROVE WITH COMMENTS. One nitpick: a public checklist
  pointed at an internal docs/evals note.
- Round 2, `e16debf`, 12/12, APPROVE. The nitpick is applied and nothing else moved.
  Trajectory: 12 -> 12, and the verdict moved from APPROVE WITH COMMENTS to APPROVE.
