---
artifact: adoption-reviewer
type: agent-definition
branch: docs/prd-003-pm-content-depth
reviewed_commit: e8c3a25
artifact_version: 2
date: 2026-11-04
scorer: agent-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
previous_total: 10/10
verdict: PASS
---

# Agent: adoption-reviewer (round 2, commit e8c3a25)

Fresh review of `.claude/agents/adoption-reviewer.md` after the branch was rebased onto main.
Scored against `docs/agent-rubric.md` from the file as it stands, independent of the round 1
scores; the old record was read only afterwards, for the comparison below.

**Anchor.** The dispatcher supplied `reviewed_commit: e8c3a25`. I have no shell, so I cannot
verify it or diff against 208d421; the record is anchored to the sha I was given. Every
line-numbered quote in the round 1 record still matches the file at the same line, so as far
as those quotes reach, the agent text did not change in the rebase.

**Read:** the agent file, `docs/agent-rubric.md`, `docs/depth-checklists/README.md`,
`docs/eval-framework.md` (record frontmatter), `scripts/skills-lint.sh` (C6, C11, C12, C13 and
their reach over `.claude/agents/`), `AGENTS.md` Guardrails 1, 5 and 7. Grepped the agent for em
and en dashes and for version-pinned model names: none.

## Scores

- **trigger/description clarity: 2**. `:3` gives what ("Verifies a skill's depth checklist
  against the source skill it adopts from ... and writes docs/evals/adoption-<skill>.md"), when
  ("before releasing such a skill") and boundary ("Checklists only; skill craft goes to
  skill-reviewer"), plus audience ("Maintainer only, never published").
- **tool least-privilege: 2**. `tools: Read, Grep, Glob, Write` (`:4`). Write is fenced in the
  body: "you never edit the artifact you judge: you use Write only for your own eval record"
  (`:8`). No Edit, no Bash: the one thing that needs execution, the copy check, is run by the
  dispatcher and handed in ("the copy-check output for each adopted file (`copy-check.sh`, run by
  the dispatcher)", `:12-13`).
- **role boundary: 2**. One job, faithfulness, with the line drawn: "You never judge whether the
  method is wise" (`:8`). It escalates instead of guessing: "Missing any of them: ASK, and say
  your record is incomplete" (`:14`), "If that file is absent, say so and stop" (`:8`), and
  hostile source text is named, not followed (`:17`).
- **policy conformance: 2**. `effort: high` (`:5`), from the allowed set (C12). No `model:` line,
  so judgment inherits the session; no version-pinned name (C11). No em or en dash (C7). The
  language rule carries the `output_language` marker and the `Guardrails 7` pointer (C13,
  `:62-68`). No isolation needed: it writes only its own record. The record shape it demands
  (`:45-48`) carries every field the gate requires (`branch`, `date`, `model_tier`,
  `reviewed_commit`, one `verdict`).
- **instruction quality: 2**. A precise contract: dispatcher inputs with ask-on-missing (`:10-15`),
  a nine-step process with substance-over-form tests ("a line that is only related is a FAIL",
  `:25`; "an item that sorts, ranks, times or assigns work changes one", `:32-33`), an explicit
  output shape and its gate consequence (`:45-52`), record rules covering model as actually run,
  tier, waiver, never-fabricated sha, REPLACE plus History and verdict ownership (`:54-59`), a
  data-not-instructions rule (`:17`) and a language rule (`:62-68`). The gaps listed under Top
  fixes are real but each is a one-line addition; none makes the contract thin or contradictory.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10 reachable, and reached
No criterion caps structurally for this agent.

## Top fixes (comments, not blocking; per `docs/eval-framework.md` they go to the follow-up list)
1. **Read the requirement in step 1.** `:20` reads "the format doc, the checklist, the whole
   source skill and the whole Odeo skill", but step 4's non-goal quote and its "number the
   requirement being built asks for" test (`:33-34`) both depend on the PRD. Change `:20` to
   end "... the whole Odeo skill and the requirement you were given (PRD and requirement id)."
2. **Substance tests for the remaining exclusion reasons.** `:30-34` tests "already covered",
   "adds length" and "number without a source" for substance; "non-goal" is only checked for
   form ("a non-goal quotes the non-goal", `:28`), and "a factual error", "a person credit" and
   "wording that would be copied" (README `:47-50`) are not tested at all. Add: "a non-goal quote
   must exist in the PRD's non-goals and cover the item; a factual-error exclusion names the
   error and its correction; a copied-wording exclusion names a source passage that cannot be
   reworded."
3. Nit: step 7 (`:39-40`) checks `source_skill` and `source_commit` but not the checklist's
   `skill:` field (README `:15`) against the Odeo skill path you were given. Add it.
4. Nit: add to the inputs (`:10-13`) "confirmation that `find .claude/sources -name CLAUDE.md -o
   -name AGENTS.md` printed nothing" (README `:67-71`). The agent has no shell, and an unrenamed
   source instruction file is loaded into its context before `:17` can help.
5. Nit: `:47` names `artifact` and `scorer` without values. Say `artifact: <checklist path>` and
   `scorer: adoption-reviewer`, so two runs write comparable records.

## Outside this artifact (policy drift, still open at e8c3a25)
- `AGENTS.md:358-360` (Guardrails 5) lists the scoring reviewers that hold Write for their own
  record only; `adoption-reviewer` is not on it, and `AGENTS.md` Guardrails 1 still speaks of
  "the other four scoring reviewers" without Bash. AGENTS.md is the single source of truth, so
  name this agent there (the repo-only `code-reviewer` is already named).
- `scripts/skills-lint.sh:122` C6 enforces the single-verdict contract for
  `code-reviewer design-reviewer pm-reviewer skill-reviewer` only. This file carries "Only you"
  and "History" (`:58-59`) today, but nothing enforces it; add `adoption-reviewer` (and
  `agent-reviewer`) to that loop.

## Integrity
House voice; the wording mirrors `docs/depth-checklists/README.md` on purpose (same repo).
Nothing looks copied from another project; no third-party plugin or person is named in the
agent file.

## Round-by-round
- Round 1 (208d421): 10/10 PASS. Trigger 2, tools 2, role 2, policy 2, instructions 2.
- Round 2 (e8c3a25, after rebase onto main): 10/10 PASS. Trigger 2, tools 2, role 2, policy 2,
  instructions 2.

## Vs previous version
Same score, 10/10 -> 10/10. No regression found. The five comments from round 1 are all still
open (none was applied, which is consistent with the agent text being unchanged); fix 2 is
widened this round to name the three exclusion reasons round 1 did not mention. The two
outside-artifact drift items are also still open.

## History
- 2026-11-03 v1 (208d421): first review. PASS, 10/10.
- 2026-11-04 v2 (e8c3a25): regenerated after the branch was rebased onto main, so the 208d421
  anchor no longer matched. Scored fresh: PASS, 10/10, unchanged. Top fix 2 widened; fix 5 now
  also covers `artifact:`.
