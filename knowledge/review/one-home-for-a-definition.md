---
module: skills and their rubrics (any two files that must agree on a term)
tags: [definitions, single-source-of-truth, drift, rubric, skill, lint, review-loop,
       duplication]
problem_type: pattern
provenance: /odeo:improve on skills/research, 2026-10-02 (branch
  chore/research-rubric-and-citations, merged 168ba9a): skill-review 8, 8, 7, 9, 10 of 10;
  ended by lint C18. Earlier instance: C17, plan layers in two files (2026-10-01).
reuse_count: 0
created: 2026-10-02
---

# A definition written in two files drifts; give it one home and guard it

## Context
The research skill and its new rubric both defined "note", "verified", "one source" and
"unverified". Each review round fixed one file, and the other file, or a line further down
the same file, kept the old meaning. Round 2 found three such drifts, all three created by
round 1's fixes; round 3 found the drift had moved inside the rubric itself (criteria using
"unverified" in the broad sense the Definitions now called "not verified").

## Guidance
1. **One home per definition.** Put the definitions in exactly one file (here the rubric's
   Definitions block, because the scorer reads it) and say in that block that it is the only
   place. The other file names the term and points there; it never rewords it.
2. **Guard the point of edit, not the reader's memory.** Add a lint that fails where the
   drift happens: C18 flags the bare word "unverified" inside the rubric's criteria block.
   Write its test first and watch it fail.
3. **Fail closed.** A check that scans a structure must fail when the structure is missing.
   C18's first version scanned "the fenced block" and passed silently when the fence was
   changed to `~~~`; code review reproduced it. It now flags a rubric without exactly one
   closed fence.
4. **State the limit.** A word lint guards one word in one place; it cannot tell whether
   another term keeps its meaning. Say so in the check and in `docs/invariants.md`.

## Why it matters
Precision scored 1, 1, 1 over the first three skill-review rounds, with new findings each
time, while the terms were reworded. The single home (round 3) and the lint (round 4)
ended the drift; round 5 reached 10/10. Wording fixes alone move the drift; they do not
remove it.

## When to apply
Before editing a skill together with its rubric, or any pair of files that must agree on a
term or a list (format doc and skill, AGENTS.md and an agent, CLAUDE.md and plan-format).
Search for the term in both files first; if it is defined twice, consolidate before
changing it.

## Examples
- C17: `global/CLAUDE.md` and `docs/plan-format.md` must carry the same `Plan layers:` list;
  CLAUDE.md cannot point into the plugin, so both copies stay and a lint keeps them equal.
- C18: the rubric owns the confidence words; `SKILL.md` steps 4 and 4b point at them.
- The general rule behind both: `knowledge/fixes/eliminate-the-defect-class-not-the-shape.md`.
