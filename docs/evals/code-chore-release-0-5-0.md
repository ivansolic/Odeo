---
artifact: release-0.5.0
type: code
branch: chore/release-0.5.0
reviewed_commit: 96c525e
artifact_version: 1
date: 2026-10-23
scorer: code-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE WITH COMMENTS
---

# Code review: chore/release-0.5.0, round 1

## Scope reviewed

- `git rev-parse --short HEAD` is 96c525e. The branch is one commit on dafa6d4:
  `.claude-plugin/plugin.json` version 0.4.0 -> 0.5.0. `marketplace.json` carries no version;
  `git grep` finds no other 0.4.0/0.5.0 reference outside internal paths.
- Content since the 0.4.0 release (d44afb4..96c525e, outside internal paths): AGENTS.md,
  README.md, docs/eval-framework.md, docs/plan-format.md, scripts/merge-gate.sh, three
  SKILL.md files, tests/merge-gate.test.sh. Already reviewed and approved on
  `feature/review-loop-ends-at-approve` at 4a83eaf (code 12/12, skill PASS); not re-litigated.
- Public snapshot (scratchpad `pub-0.5.0`, commit 6241598 on public f0aa548): read only.
  Suite not re-run here (being run separately).

## Checks

1. **Version.** 0.5.0 is right. The release changes what an enforced guardrail
   (merge-gate, Guardrails 1 [E]) treats as stale, and turns post-review plan immutability
   from enforced into instructed (docs/plan-format.md now says a post-gate edit "voids the
   approval" instead of "refuses the merge"). That is a change in a safety contract users
   rely on, not a fix or a small additive feature, so a patch would under-signal it. Note
   that CONTRIBUTING.md step 6 names only "breaking or structural changes, such as moving
   files"; the commit message supplies the guardrail-semantics criterion itself (nitpick).
2. **Public tree.** Tree of 6241598 equals the tree of 96c525e minus the denylist,
   file-for-file: no file only in public, no public file whose content differs from
   96c525e. No path in the public tree matches any `docs/internal-paths.txt` entry. Added
   lines in the public diff reference no internal file: the `knowledge/`, `docs/plans`,
   `docs/prds` etc. mentions in merge-gate.sh, eval-framework.md and the tests are paths in
   the USER's project (and temp repos in the tests), and `.claude/tasks/todo.md` is the user
   project ledger already named publicly in AGENTS.md. `docs/examples/` is on the public
   allowlist and exists publicly. No em or en dash in added lines. README's 1584 = 1572 + the
   12 new `after_review` cases.
3. **Upgrade notes.** See "Release note content" below; nothing breaks, but one guardrail
   relaxation must be stated plainly.

## Findings

### Critical

None.

### Important

None.

### Nitpicks

- **CONTRIBUTING.md:43-45**, the minor/patch rule does not cover a change in an enforced
  guardrail's semantics, so this bump is justified by a criterion only the commit message
  states. Add "or a change in what an enforced guardrail allows or refuses" to the minor
  clause so the next release is decidable from the file.
- **AGENTS.md:309 (public)**, "(F2 rule holds)" refers to an ID that exists in no public
  file. Pre-existing (same text on public f0aa548), only touched as context here. Replace
  with "(Guardrails 6: only a reviewer changes a verdict)".

## Release note content (for the PR body)

- **merge-gate is lighter after an approve.** Edits only to README, INSTALL, guides,
  CONTRIBUTING, ROADMAP, CHANGELOG, CODE_OF_CONDUCT, or Markdown under `knowledge/`,
  `docs/plans/`, `docs/prds/`, `docs/stories/`, `docs/research/`, `docs/examples/`,
  `docs/decisions/` no longer force a new review round. Everything else still does,
  including skills, agents, AGENTS.md, CLAUDE.md, docs/checklists, and any non-Markdown file
  in those directories.
- **Say the tradeoff out loud:** a plan edited after the code review no longer blocks the
  merge. Plans stay immutable after approval by instruction, no longer by the gate.
- **The review loop ends at an approve** (APPROVE, APPROVE WITH COMMENTS, PASS), also below
  the max score. Remaining comments: prose is fixed directly, a PRD or story comment costs
  one more pm-reviewer round (spec-gate still refuses a record older than the document),
  code comments become follow-ups in the task ledger.
- **One eval-record commit per branch**, with every round in its `## History`.
- **No action needed to upgrade:** no hook refresh, record format unchanged, existing
  records stay valid. Old install.sh copies of `~/bin/merge-gate.sh` keep the stricter
  behavior until migrated (the existing session-start nudge covers it).

## Scores

correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 12/12 (threshold: >=9, no zero)

## Ceiling

12/12, reached.

## Verdict

APPROVE WITH COMMENTS. The bump is correct for a change in an enforced guardrail, the
public snapshot is exactly 96c525e minus the denylist with no dangling internal reference,
and the comments are the release-note content above plus two nitpicks.

## History

- Round 1 (96c525e): 12/12, APPROVE WITH COMMENTS. Two nitpicks, release-note content
  supplied for the PR body.
- Previous release record (`code-chore-release-0-4-0.md`) ended at 12/12; regression note:
  same.
