---
artifact: skill-dogfood-fix-batch
type: skill
artifact_kind: skill
branch: main
date: 2026-07-13
scorer: skill-reviewer
scores:
  build:         { trigger: 2, structure: 2, example: 1, precision: 2, safety: 2, total: 9 }
  merge:         { trigger: 2, structure: 2, example: 2, precision: 2, safety: 2, total: 10 }
  start:         { trigger: 1, structure: 2, example: 1, precision: 2, safety: 2, total: 8 }
  setup-project: { trigger: 1, structure: 2, example: 2, precision: 2, safety: 2, total: 9 }
  setup-design:  { trigger: 1, structure: 2, example: 1, precision: 2, safety: 2, total: 8 }
  prd:           { trigger: 2, structure: 2, example: 1, precision: 2, safety: 2, total: 9 }
  stories:       { trigger: 2, structure: 2, example: 1, precision: 2, safety: 2, total: 9 }
  critique:      { trigger: 1, structure: 2, example: 1, precision: 2, safety: 2, total: 8 }
  brainstorm:    { trigger: 1, structure: 2, example: 1, precision: 2, safety: 2, total: 8 }
  guide:         { trigger: 2, structure: 2, example: 2, precision: 2, safety: 2, total: 10 }
verdict: PASS
---

# Skill review: dogfood fix batch (10 skills)

Threshold per skill: total >= 8/10 AND no criterion at 0. All ten pass. No zeros.

## Evidence per deciding score

- **build, trigger 2**: explicit command, plain what-you-get with example
  invocation ("Name several stories... e.g. \"/build USR-001 USR-002 in
  parallel\""). **example 1**: verbatim ask-scripts are imitable, but there is no
  end-to-end worked run with real story values (contrast merge's usr-012 block);
  workspace commands use `<slug>` parameters only.
- **merge, 10/10**: worked example with real values ("on feature/usr-012-timer");
  gate enforced first ("run it first and STOP on non-zero: merge-gate.sh"); the
  CI-existence rule is exact ("A suite that has never been executed is not
  green... check `.github/workflows/`"); never-self-triggers stated up top.
- **start, trigger 1**: auto-invoked but the description leads with a workflow
  summary ("Reads the project's actual state... and shows...") before "Use
  when..."; the standard requires triggers ONLY. **example 1**: output shape is
  `<placeholder>` template; only the retro reminder line is concrete.
- **setup-project, trigger 1**: auto-invoked, description summarizes the
  workflow ("Interviews the user... then fills in the project CLAUDE.md")
  instead of starting with "Use when...". **example 2**: full verbatim interview
  scripts (architecture options, dev-rigor, teach-me) with concrete values
  ("angular-nest-mysql", "vitest run, never bare vitest").
- **setup-design, trigger 1**: same pattern, workflow summary ("Ingests... or
  proposes... then wires token compilation") ahead of the trigger clause.
  **example 1**: the option menu is imitable but there is no worked token
  proposal or mapping sample.
- **prd, trigger 2**: explicit command, plain ("Produces a structured PRD saved
  to docs/prds/"). **example 1**: one inline outcome example ("<60s without
  support"), no full worked section.
- **stories, trigger 2**: explicit command. **example 1**: strong micro-examples
  ("At least one ingredient, not >=1"; "error shows inline within the form"),
  but no complete example story card.
- **critique, trigger 1**: auto-invoked, description opens with the method
  ("attack the assumptions (red-team), then run a pre-mortem") before "Use
  when...". **example 1**: prompts are quoted, no sample findings/output.
- **brainstorm, trigger 1**: auto-invoked, trailing workflow summary ("Diverges
  into many distinct options through three product lenses, groups them,
  proposes selection criteria") violates "Never summarize the workflow in the
  description". **example 1**: lens and criteria examples are thin/abstract
  ("users can't X without Y").
- **guide, 10/10**: description starts "Use when the user asks how to
  proceed..." with real user phrasings; concrete Jira worked example; "Read-only
  until an explicit yes."

## Intent verification (batch goals expressed cleanly)

- Mode ask: build states it twice ("ALWAYS ask, never infer" + safety rule
  "The mode is ASKED, never inferred, every /build invocation, no exceptions").
- for-me plan review: B5.2 dispatches architecture-reviewer on each plan before
  the human gate; pipeline diagram matches.
- Editor reuse: build ("reuse, never multiply", `code -r` / `code --add`,
  cursor fallback, graceful skip), prd/stories/critique all use `code -r` with
  `cursor -r` fallback and the "stop opening files" opt-out. No skill opens a
  new window. Consistent.
- Merge only offered: build B7 ("`/merge` starts ONLY when the user invokes it
  or answers that offer with an explicit yes"); merge ("This command NEVER
  starts itself"). No skill anywhere instructs auto-merging (repo-wide grep).
- CI-existence check, origin/HEAD set-head, warm /learn+/retro nudges: present
  in merge steps 3, 4, 7. Idea-first entry: start step 5 and setup-project
  step 0 agree. stories words-not-notation and audience adaptation: present.
  brainstorm viability lens: "This lens flags, it never designs: no stacks, no
  architectures."

## Map duty

`docs/system-map.md` reflects the new names (line 65: "**with me** (Mode A)...
**for me** (Mode B)"; line 128: "'Mode A/B' work as aliases"). No new commands
added in this batch. Satisfied.

## Cross-consistency findings (outside the scored files)

1. `skills/guide/SKILL.md:25` says only "Mode A vs B" in the decision-point
   list; a user who knows the modes as with-me/for-me won't recognize it.
2. `agents/architect.md:3` description: "Dispatched by /build Mode B", alias
   only, should read "by /build's for-me mode (Mode B)".
3. `global/CLAUDE.md:195` and `AGENTS.md:21` still describe /build in Mode A/B
   terms only, with no with-me/for-me names.
4. agents/builder.md and agents/code-reviewer.md: consistent (builder "never
   merge"; code-reviewer record is what the /merge gate checks). No
   contradictions found.

## Top fixes

1. Rewrite the five auto-invoked descriptions (brainstorm, critique, start,
   setup-project, setup-design) to start with "Use when..." and carry ONLY
   triggers. E.g. brainstorm: "Use when the user wants to brainstorm, generate
   or weigh product ideas or directions, or is jumping to a solution too early."
   Drop the "Diverges into... three product lenses" sentence.
2. `skills/guide/SKILL.md:25`: "Mode A vs B" -> "with-me vs for-me (Mode A/B)".
3. build: add a compact worked run (real story, mode ask, chosen answer, the
   commands executed), mirroring merge's example block.
4. setup-project: renumber the interview groups; the current order D, D2, E, F,
   F3, F2, G reads as missing/mis-ordered steps.
5. Propagate with-me/for-me naming to `agents/architect.md`, `global/CLAUDE.md`,
   `AGENTS.md`.

## History

First eval record for this batch; no prior record, no regression comparison.
Note: several fixes here are behavioral-adjacent (descriptions changing
auto-invocation); after the description rewrites, run /improve subagent testing
on brainstorm and critique to confirm trigger behavior.
