---
module: cross-cutting (applies to any matcher, parser, or heuristic under review)
tags: [defect-class, recurring-critical, heuristic, decidability, review-loop,
       structural-invariant, bounded-residual, escalation, fail-closed, parser,
       emulation, residual-direction]
problem_type: pattern
provenance: USR-006 prose-language check, 2026-08-13 to 2026-08-19. Three review
  Criticals of one class across rounds 2, 3, 4 (each 7-8/12); resolved by removing
  the class, 12/12 APPROVE at 9ff98f5; and research-check.sh on
  chore/research-one-fact-rule, 2026-10-20 to 2026-10-21: change B (fail-open class in
  three places, closed structurally each time, 12/12 at 43e7b0d) and its follow-up, the
  nitpick change (link addresses, 12/12 at 57daa41)
reuse_count: 0
created: 2026-08-21
---

# Eliminate the defect class, do not chase its next shape

## Context
USR-006 extracted a document's "prose region" by deleting code spans, so a
language check could count function words. Backticks had to be paired. Three
review rounds each found a Critical of the **same class**: a stray backtick
mispaired with a real span's delimiter, so the deletion ate real prose between
them, which silenced the very warning the feature exists to raise.

Each round fixed the shape that was found and moved the mispairing elsewhere:

| round | fix applied | new shape that broke |
|---|---|---|
| 2 | delete spans across the whole region | ate whole paragraphs |
| 3 | paragraph records + parity guard | two strays around a whitespace-only line (parity even, guard silent) |
| 4 | per-line fallback inside odd paragraphs | a line beginning mid-span pairs offset by one |

The tell: the reviewer's own proposed round-4 patch had the identical hole in its
other branch, measured at `de=1`. Two competent parties were trading failure
shapes, not converging.

## Guidance
When the same class of defect returns across fix attempts, stop patching and ask
a different question: **is this problem decidable at all?**

Here it was not. Given a document with an unbalanced backtick, no local rule can
tell a stray from a real delimiter; CommonMark itself would eat the prose. A
heuristic chased by an adversarial reviewer who can always construct the next
counterexample is an unwinnable loop.

Then choose between two moves, and take them to the human:
1. **Structural elimination.** Find an invariant that makes the whole class
   impossible, not a guard per instance. Here: pair delimiters *within a line
   only*, so a deletion can never leave the line it starts on, and cross-line
   eating becomes unrepresentable rather than defended.
2. **Escalate the tradeoff.** Elimination usually costs capability. Naming that
   cost is a product decision, not a code decision.

Then **bound and pin the residual**: state each remaining cost in the contract
and pin it with a test case, never with prose. Two residuals shipped here (a
wrapped span's content is counted; one mispaired line loses its own prose), each
with a case proving it cannot grow.

## Why it matters
Round-over-round scores were flat at 7-8/12 while real effort went in, because
correctness kept scoring 0 for a new instance of one old cause. The structural
fix scored 12/12 **and deleted 39 lines**: the paragraph records, the parity
branch, the per-line fallback and a whitespace-line special case all became
unnecessary at once. Guards accumulate; invariants remove.

A second, quieter cost: the round-3 comment *certified* the guard as covering
"the harmful direction". That claim was false, and writing it made an assumed
bound look examined. Prose is where unproven bounds hide.

## When to apply
- Two or more fixes for one root cause, each trading one failure shape for another.
- Before applying the next fix, ask: does this just move the mispairing?
- A reviewer keeps finding new counterexamples in the same mechanism.
- Skip when a defect is genuinely one-off, or when the class is decidable and the
  fix is complete rather than a guard.

## Example
```awk
# BEFORE, round 4: pair within an odd paragraph, per line.
# A line whose FIRST backtick is a CLOSER pairs offset by one and eats prose.
nl=split(para, L, "\n")
for (i=1; i<=nl; i++) if (count(L[i]) % 2 == 0) delete_spans(L[i])

# AFTER: one bit of state makes the class impossible.
# A line that begins INSIDE an open span is code, kept verbatim, never scanned.
if (opn == 0) delete_spans(line)      # only pair where pairing is unambiguous
bt=$0; opn=(opn + gsub(/`/, "", bt)) % 2
```
The `opn` bit is not another guard on the pairing rule. It removes the case in
which pairing could be wrong.

## Second case: a checker that must fail closed (research-check.sh, 2026-10)

Change B's class was "input the parser does not understand is read as clean". It came
back in three places, one review round each: note parsing, note citations (a qualifier
or an unlisted section), and a number hidden after a comma ("(notes 1, 2, and 9)"). The
follow-up change then spent three rounds on link addresses. Four moves closed it, each
removing a class rather than a shape:

| shape found | instance patch on offer | structural fix taken |
|---|---|---|
| a note header or quote mark the parser did not read | one more guard per shape, as round 1 did | notes parse fail closed: one header grammar, anything else is a violation (053f4ef) |
| qualified citation "(note 9, measured)" invisible | add the qualifier form to the regex | every parenthesis is scanned; a "note" that is not a number list is a violation (eadb831) |
| "(notes 1, 2, and 9)" skipped note 9 | forbid "and/or/& digit" after the comma | a comma qualifier holds no digit at all (43e7b0d) |
| link regex too loose, then too tight | a fuller CommonMark regex | stop deciding where a link ends: skip the "(" after "]", still read what is nested in it (81877e4, finished in 57daa41) |

Two things this case adds to the guidance above:

1. **Emulating someone else's grammar breeds the class: it failed open, then closed.**
   The link regex was a hand-made copy of CommonMark. Too loose, a broken link hid the
   citations after it; too tight, valid titled links raised false alarms. Every fix
   added a case to the copy. The way out was one fact the checker can verify locally,
   never the grammar: "a link address does not start with note or notes and
   whitespace".
2. **Check which way the residual points after removing a class.** Removing the link
   regex traded a false alarm for a narrow MISS ("[F1](note 9)" skipped), which the
   next review caught. For a fail-closed check the residual must be a false alarm,
   never a miss. Say which way it points in the header, and probe for misses before
   you claim "never a miss": the 57daa41 commit body claimed it, and "[F1](notes, 1)"
   is still skipped.

What stopped the loop each time was not a better patch but the review loop's stop
conditions (the same class twice in a row, or three rounds on one artifact), which
handed the choice to the human. The rules worked; this entry existed and was not looked
up, which is the placement limit named in lessons.md, not a wording problem.
