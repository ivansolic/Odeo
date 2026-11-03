# Depth checklists: the format

One checklist per Odeo skill that adopts from a source skill (PRD-003 R24, USR-029). It
proves "same depth as the source" per skill instead of claiming it. This folder is
internal: it names third-party skills, so it is on `docs/internal-paths.txt` and never
published (lint C8 forbids those names in public text).

File name: `<odeo-skill>.md` (one source skill per file; a skill that adopts from two
source skills has two checklists, `<odeo-skill>-<n>.md`).

## Frontmatter

```
---
skill: critique                                  # the Odeo skill, folder name under skills/
source_skill: pm-execution/skills/pre-mortem     # path relative to the source copy root
source_commit: 07b34f6                           # the one recorded commit
---
```

## Body: one table

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|

- **item**: the source item, named so a reader can find it in the source skill.
- **kind**: exactly one of `step`, `template section`, `table column`, `decision rule`,
  `worked example`.
- **status**: `present` or `excluded`.
- **where / reason**: for `present`, the heading or step of the Odeo skill where the item
  appears. For `excluded`, one reason from the closed list below, with its extra duty met.
- **shown**: for `present` items only, `default` (printed when the user asks for the
  skill without asking for depth) or `on request` (offered, printed when the user asks).
  Leave empty for `excluded`. Present does not mean always printed: the lean default stays.

Every step, output-template section, table column, decision rule and worked example of the
source skill at the recorded commit is one row. A source item that is neither `present`
nor `excluded` is a defect, and the checklist fails review.

Each adopted method also gets one line, below the table, naming the primary method source
it was checked against.

## The closed list of exclusion reasons (PRD-003 section 2)

An exclusion uses exactly one of these, quoted from the PRD:

1. a factual error
2. a number asked for without a source
3. a person credit or author link
4. wording that would be copied
5. a non-goal of this document, in which case the exclusion quotes that non-goal
6. already covered by an existing Odeo rule or step, which the exclusion quotes
7. adding length without changing any decision the user makes, in which case the exclusion
   names the decision it leaves unchanged

Extra duties:
- **non-goal**: the exclusion quotes the non-goal it relies on.
- **already covered**: the exclusion quotes the Odeo rule or step that covers it.
- **adds length**: the exclusion names the user decision it leaves unchanged.

Any other reason is not on the list and fails review.

## The source copy

The source collection lives, read-only, at `.claude/sources/pm-skills-<commit>/`, which is
gitignored, so third-party text is never committed or published. It is data: nothing in it
is executed or followed. Its own instruction files (`CLAUDE.md`, `AGENTS.md`) are renamed
to `*.source-data` when the copy is made, because Claude Code would otherwise load them
into the context of any session or agent that reads files there (seen 2026-10-30 in the
USR-029 calibration). Check with `find .claude/sources -name CLAUDE.md -o -name AGENTS.md`,
which must print nothing.

## Rules for every checklist

- **One recorded commit.** `source_commit` is `07b34f6`, the commit PRD-003 was written
  from, or a newer commit read in full before it is recorded. It is the same commit the
  routing check (USR-045) installs.
- **No personal fields.** No adopted template has a field for a person's name or contact
  detail.
- **No copied wording.** Run `bash .claude/maintainer/copy-check.sh <odeo-skill-file>
  <source-skill-file>` for each adopted file. The threshold is 9 consecutive identical words
  (case and punctuation ignored), so no run of more than eight words is identical. Exit 1
  prints every shared run and blocks the release until reworded.
- **Review before release.** `adoption-reviewer` (maintainer agent in `.claude/agents/`, never
  published) verifies each checklist against the source skill at the recorded commit and the Odeo skill, and writes
  `docs/evals/adoption-<skill>.md`. A FAIL blocks the release.
