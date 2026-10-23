---
artifact: feature-review-loop-ends-at-approve
type: code
branch: feature/review-loop-ends-at-approve
reviewed_commit: 0fabcd5
artifact_version: 2
date: 2026-10-23
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: feature/review-loop-ends-at-approve, round 2

## Scope reviewed

- `git show 0fabcd5` (the round-1 fixes) in full, plus `git diff 1b0d4c1..0fabcd5` to
  confirm the branch as a whole. In scope: `scripts/merge-gate.sh` (PROSE_FILES,
  PROSE_DIRS, NOT_PROSE as used by 3c and 3d), `tests/merge-gate.test.sh` case 17b and its
  mutation header, and the gate and stop-rule claims in AGENTS.md, docs/eval-framework.md,
  README.md, skills/prd, skills/stories, skills/build (wording beyond the gate claims is
  skill-reviewer's).

## Round-1 findings, verified

1. Important 1 (prose directories excluded every file type): FIXED. Directories now enter
   NOT_PROSE only as `:(exclude,glob)<dir>/**/*.md`; top-level names stay plain excludes;
   `docs/evals` is excluded whole, as before. Three new 17b cases (script under knowledge/
   refuses, nested knowledge Markdown passes, docs/checklists refuses).
2. Important 2 (PRD/story comments vs spec-gate freshness): FIXED.
   `docs/eval-framework.md:185-191` scopes "fixed directly" to merge-gate records and adds
   the PRD/story exception (one more pm-reviewer round, counted toward the cap); AGENTS.md
   and both skills say the same thing and point at the single stop rule instead of copying
   it. Verdict vocabulary PASS/FAIL matches `agents/pm-reviewer.md` and `spec-gate.sh`.
3. Important 3 (prose-only branch with REQUEST CHANGES): FIXED,
   `docs/eval-framework.md:249-253`.
4. Nitpick (docs/checklists): resolved by human decision, removed from the list and pinned
   by a test. Nitpick (AGENTS.md width): rewrapped.

## Checks run (scratch repos under the session scratchpad, never the working tree)

- Pathspec probes with the exact NOT_PROSE construction, git 2.50.1, macOS,
  `core.ignorecase=true`, each judged by both 3c (`git diff --quiet`) and 3d (`git log -1`),
  which agreed in every case:
  - PROSE: `knowledge/new.md`, `knowledge/a/b/c.md`, deletion of a knowledge `.md`,
    `docs/examples/n.md`, dotfile `.md`, `.md` under a dot directory.
  - CODE: `knowledge/r2.sh`, `docs/examples/n.ts`, deletion of `knowledge/run.sh`,
    `knowledge.md` at top level, `s/README.md`, a DIRECTORY named `knowledge/evil.md/`
    holding a script and the nested `knowledge/a/x.md/b/run.sh` (no subtree pruning on a
    directory whose name ends in `.md`), case variants `knowledge/U.MD`, `knowledge/Y.Md`
    and `Knowledge/x.md` (the last added through the index, since the case-insensitive
    filesystem otherwise folds it into `knowledge/`). Exclude magic stays case-sensitive:
    fail-closed.
  - Renames: script -> `knowledge/x.md`, knowledge `.md` -> `scripts/k.sh`, and
    `knowledge/run.sh` -> `knowledge/run.md` all count as CODE (the non-prose side stays
    visible to the pathspec).
  - Accepted by the human's decision ("a `.md` that is really something else"): a mode
    change to `+x` on a knowledge `.md`, and a `knowledge/l.md` symlink to a script, both
    PROSE.
- Mutation claims in the 17b header, re-measured on a `git archive` copy of 0fabcd5:
  baseline 88 passed, 0 failed; `PROSE_FILES=(none) PROSE_DIRS=(none)` -> 5 FAIL (the five
  named); prose dirs as plain `:(exclude)$p` -> 1 FAIL (the knowledge script);
  `PROSE_FILES=("*.md")` -> 3 FAIL (skill, AGENTS.md, docs/checklists). All three match the
  header exactly.
- README total: 1572 on main + 12 new 17b cases = 1584, consistent with the README line.
- Full suite and docs-claims not re-run (builder evidence stands).

## Findings

### Critical

None.

### Important

None.

### Nitpicks (code comments: to the follow-up list, not another round)

- `scripts/merge-gate.sh:312-313`, the 3c refusal text still says "outside the plain-prose
  list" and "(prose-only changes such as README or knowledge/ do not count)". Since 0fabcd5
  a non-Markdown file under knowledge/ DOES count, so a user refused for
  `knowledge/run.sh` is told the opposite of why. Fix: "outside the plain-prose lists"
  and "(README and the like, and Markdown under knowledge/, plans and the other prose
  directories, do not count)".
- `tests/merge-gate.test.sh:257`, the rewritten 17b header line is 106 columns; rewrap.

### Accepted residuals (named, not findings)

- `docs/evals/` is excluded whole, so a non-Markdown file there after the review does not
  stale the record. This is the pre-branch behavior and was my own round-1 suggestion; the
  gate reads records from that directory, so the residual is bounded and documented in the
  gate's comment.
- A `.md` that is really something else (exec bit, symlink, Markdown a tool executes)
  passes as prose, by the human's decision.

## Security review

No `/security-review` needed: no auth, user input, upload or data access. The change's
security surface is the gate's own fail-open risk; the probes above show the glob form
fails closed on every non-Markdown, case-variant, rename and directory-name shape tried.

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached. The verdict is APPROVE WITH COMMENTS only because two nitpicks remain.

## Regression note

Better than round 1: 10/12 -> 12/12. All three Importants fixed, both nitpicks resolved,
no new Important or Critical. Under the stop rule in `docs/eval-framework.md` this approve
ends the loop; the nitpicks are code comments and go to `.claude/tasks/todo.md`.

## History

- Round 1 (ccdd70e): 10/12, APPROVE WITH COMMENTS. Importants: prose directories excluded
  every file type (security); PRD/story comments vs spec-gate freshness; prose-only branch
  with REQUEST CHANGES.
- Round 2 (0fabcd5): 12/12, APPROVE WITH COMMENTS. Importants fixed and verified by probe
  and mutation; two nitpicks (stale refusal text, one header line width).
