---
artifact: architecture-reviewer
type: agent-definition
branch: test/plan-human-layer-behavior
reviewed_commit: e1e28d2
artifact_version: 7
date: 2026-10-02
scorer: agent-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

# Agent: architecture-reviewer (round 8, at e1e28d2)

Scoped review of the criterion-6 paragraph (`:28-34`) on `test/plan-human-layer-behavior`,
which narrows the Risks half of the `What you decide` class and adds a carve-out for builder
stop rules. I re-read the whole file at this commit. Outside `:28-34` it matches the text
scored at 2859827, apart from line numbers shifting by two below the paragraph. I checked the
canonical text in `docs/plan-format.md` at the same commit: the class at `:72-78`, the Risks
section definition at `:185-186`, and criterion 6 at `:295-301`.

Method note: this reviewer holds no Bash. The sha `e1e28d2` was supplied by the dispatcher;
files were read in the worktree `plan-behavior-tests`. The tier is the one my context reports
(Opus class), not re-resolved against a live lineup in this run (no web tool).

## Scores

- **trigger/description clarity: 2**, `:3` unchanged: plan-review mode, the Guardrails-1
  detector duty, and "Not for shipped code (code-reviewer), UI (design-reviewer), or PM
  documents (pm-reviewer)."
- **tool least-privilege: 2**, `tools: Read, Grep, Glob` (`:4`), matching AGENTS.md
  Guardrails 5 `[E]`; `:47-48` keeps the loop closed ("You cannot write files").
- **role boundary: 2**, the change only narrows what the reviewer reports. "A builder stop
  rule in Risks ('if X, stop and ask') is not such a choice and is not a finding" (`:33-34`)
  takes away a false finding; it gives the reviewer no new decision to make for the human. The
  reviewer still surfaces every human-answered choice and still decides none of them.
- **policy conformance: 2**, `effort: high` (`:5`), no `model:` line, C11 clean, no
  `isolation:` needed.
- **instruction quality: 2**, the paragraph still applies criterion 6 "in full as written in
  ... plan-format.md, which wins" (`:28-29`). The class echo matches the canonical members, and
  the carve-out is stated more plainly than in the canonical text. One Minor below: the echo
  drops the gloss that tells the reviewer which Risks questions count. It does not contradict
  anything.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Every criterion is at its described top level. The Minor and Nits below are open; none blocks
the ceiling.

## The three checks asked for

**1. Does the echo match plan-format's class in meaning? Yes for both members and the
carve-out, with one gloss missing.**

| plan-format.md:73-78 | architecture-reviewer.md:29-34 |
|---|---|
| "every open question in Risks that the HUMAN answers (a choice about what the user gets)" | "every open question in Risks that the human answers" |
| "every Design decision that changes what the user gets or departs from the story's wording" | identical |
| "A purely technical decision (how, not what) stays in Design decisions alone" | not echoed; implied by the positive class |
| "and so does a builder stop rule in Risks ('if X, stop and ask'): it is for the build, not the gate" | "A builder stop rule in Risks ('if X, stop and ask') is not such a choice and is not a finding." |

The dropped parenthetical, "(a choice about what the user gets)", matters more than its
length. A stop rule is also answered by the human in the end: the builder stops and asks
them. So "that the human answers" taken alone does not separate the two kinds of Risks item.
The gloss does, and so does the agent's own carve-out sentence for the common case. Because
the paragraph defers to plan-format, the meaning is preserved, but the test the reviewer
applies at the point of use is one step less exact than the canonical one. See Minor 1.

**2. Role boundary holds.** See the score above. The narrowing reduces findings and moves no
decision away from the human.

**3. No new contradiction with criterion 6 (`plan-format.md:295-301`).** Level 1 fails a plan
for "leaving a gate decision or story deviation only in the technical layer". A stop rule is
by definition answered during the build, not at the gate ("it is for the build, not the
gate"), so excluding it is consistent with level 1. Level 2's "EVERY decision they make" sits
in the same criterion as "gate decision" and reads as gate decisions. Under that reading it
also holds. One residual, not a contradiction and outside this file: nothing tells the human
at the gate that a stop rule may bring a question back to them mid-build. That was option 3 in
the calibration note, and it was not taken. It is a format choice, recorded here so it is not
lost.

## Open findings
- **Minor 1, `:29`, the echo drops the gloss that defines "the human answers".** Fix: write
  "every open question in Risks that the human answers (a choice about what the user gets)",
  copying `plan-format.md:74`. That makes the echo word for word, and the classifier sits where
  the reviewer applies it. The calibration (0/10 false requests) suggests behaviour is already
  right with the carve-out, so this is about exactness, not a measured failure.
- **Nit, carried, `:36-48`**, the last plan-review paragraph carries three duties (Guardrails-1
  readable checks, vocabulary, re-review discipline).
- **Nit, carried, `:44-45`**, rewrap artifact ("... non-plan architectural review. On a /
  re-review ...").

## Closure verified
- **CLOSED (was Nit), line width at `:28`/`:31`.** The paragraph is rewrapped to about 92
  columns. `:28` is still long because of the `${CLAUDE_PLUGIN_ROOT}` path, which is the same
  pattern as `:17` and `:37`, so I count it as the file's convention, not a defect.

## Out of scope (for the dispatcher)
- **`docs/plan-format.md:76-78`, the stop-rule clause misplaces the stop rule.** It says "A
  purely technical decision ... stays in Design decisions alone, and so does a builder stop rule
  in Risks". Read literally, that says the stop rule stays in Design decisions, but it lives in
  Risks. The intent ("stays out of the Summary") is clear from context. Better wording: "...
  stays in the technical layer alone". The agent's own sentence (`:33-34`) does not inherit
  the slip.
- **Risks now holds two kinds of item** under one definition (`plan-format.md:186`, "anything
  ambiguous the builder must ASK about"): questions the human answers at the gate, and stop
  rules for the build. The class text tells them apart, but the section template does not. A
  plan author could mark each item (for example "gate:" or "stop rule:"). That is a format
  choice, not this agent's.

## On the calibration evidence
I read `docs/evals/calibration-plan-human-layer.md` as supporting data, not as something that
moves a score (this rubric scores the definition). It reports scenario 3 caught 5/5,
scenario 4 with no false flag 5/5, and false stop-rule requests falling from 7/10 (run 1) to
0/10 (run 2, blind). Limits to keep in view:
- The note itself says run 2 was against the format at ff6ee09, not e1e28d2. It does not say
  whether the agent text it ran included this exact carve-out sentence.
- Its runs were general-purpose agents told to follow the files, not the dispatched agent. The
  note states this itself for run 1.
- Ordering and blindness are self-attested.

None of this weakens the definition. It means the measured behaviour describes this text
only to the extent ff6ee09 carried it.

## Integrity
House voice. The carve-out and the narrowed class match the vocabulary of
`docs/plan-format.md`. Nothing reads as copied from another project.

## Round-by-round
Round 1 (f8f8da6): 8/10, 2 Important + 1 Minor.
Round 2 (f4e295a): 9/10, 1 Minor + 2 Nits.
Round 3 (93536c7): 9/10 PASS, ceiling blocked by `:3`.
Round 4 (4f001fa): 10/10 PASS, 2 Minor + 2 Nits.
Round 5 (e5dbea0): 10/10 PASS, both Minors closed; 3 cosmetic Nits open.
Round 6 (babe300): 10/10, re-anchor.
Round 7 (2859827): 10/10, re-anchor after rebase onto 95d17e3.
Round 8 (e1e28d2, new branch test/plan-human-layer-behavior): 10/10 PASS. Narrowed Risks class
and stop-rule carve-out scored; line-width Nit closed; 1 Minor new (missing gloss) + 2 Nits
carried. No criterion moved.

## Vs previous version
Held at 10/10, no regression. The change removes a measured false-finding pattern without
loosening the catch on a real one. The echo is one parenthetical short of word for word.

## History
- 2026-08-04 v2 (f8f8da6): first per-file review, after the plan-review mode gained the
  reference-graph and label checks and the Guardrails-1 detector duty. Round 1 = 8/10 PASS,
  two Important open.
- 2026-08-04 v3 (f4e295a): Round 2 = 9/10 PASS; instruction quality 1 -> 2; one Minor (story
  input) + 2 Nits open.
- 2026-08-04 v4 (93536c7): Round 3 = 9/10 PASS, held; story-input Minor closed; `:3` and both
  Nits open by the author's choice.
- 2026-10-01 v5 (4f001fa, branch feature/plan-human-layer): criterion-6 paragraph added; `:3`
  found revised. Round 4 = 10/10 PASS; trigger clarity 1 -> 2; two Minors new.
- 2026-10-01 v6 (e5dbea0): criterion 6 applied in full by reference; class defined once in
  plan-format and echoed exactly; paragraph separated by blank lines. Round 5 = 10/10 PASS,
  held; both Minors closed; three cosmetic Nits open, none ceiling-blocking.
- 2026-10-01 v6 re-anchored (babe300): artifact unchanged. Round 6 = 10/10 PASS, held.
- 2026-10-01 v6 re-anchored (2859827): rebased onto released main 95d17e3; artifact unchanged.
  Round 7 = 10/10 PASS, held.
- 2026-10-02 v7 (e1e28d2, branch test/plan-human-layer-behavior; the record's `branch:` moved
  from feature/plan-human-layer): Risks half of the `What you decide` echo narrowed to "that
  the human answers", stop-rule carve-out added, paragraph rewrapped. Round 8 = 10/10 PASS,
  held; line-width Nit closed; missing-gloss Minor new.
