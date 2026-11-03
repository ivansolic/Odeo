---
artifact: adoption-reviewer
type: agent-definition
branch: docs/prd-003-pm-content-depth
reviewed_commit: 208d421
artifact_version: 1
date: 2026-11-03
scorer: agent-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
---

# Agent: adoption-reviewer (round 1, commit 208d421)

First review of `.claude/agents/adoption-reviewer.md`, the maintainer-only agent that took
over the adoption check from `agents/skill-reviewer.md`. Scored against `docs/agent-rubric.md`;
the whole file was read and scored.

**Anchor.** The dispatcher supplied `reviewed_commit: 208d421`. I have no shell to verify it
independently; the record is anchored to the sha I was given, and the gate catches a wrong one.

**Method note.** No Bash in this reviewer's grant, so I could not run
`git show 686e56f:agents/skill-reviewer.md`. The comparison with the former section is
reconstructed from the line-by-line quotes in `docs/evals/agent-skill-reviewer.md` (round 2 on
75c14e1). Read: the agent file, `docs/agent-rubric.md`, `docs/depth-checklists/README.md`,
current `agents/skill-reviewer.md`, `docs/evals/agent-skill-reviewer.md`,
`docs/calibration-runs/adoption-check/README.md`, `.claude/maintainer/merge-gate.sh` (grep:
enrolment by `branch:`, required single fields, accepted verdicts, PROSE lists),
`docs/eval-framework.md` (record frontmatter), `scripts/skills-lint.sh` (C6, C7, C11, C12, C13
scope over `.claude/agents/`) and `AGENTS.md` Guardrails 1 and 5. Grepped the agent for em and
en dashes (none).

## Former section: nothing lost or softened (as far as the prior record's quotes reach)

| Former (skill-reviewer adoption mode, per prior record) | Now | Status |
|---|---|---|
| `:3` trigger "before releasing a skill that adopts from a source skill", boundary "Skills and their depth checklists only" | `:3` "before releasing such a skill", "Checklists only; skill craft goes to skill-reviewer" | kept, boundary sharper |
| `:11-13` faithfulness to source and requirement, "never whether the method itself is wise" | `:8` "faithful to the source skill ... and to the requirement ... You never judge whether the method is wise" | kept |
| `:42-44` format doc absent: "say so and stop" | `:8` "If that file is absent, say so and stop." | kept |
| `:47-52` inputs incl. source commit, requirement, per-file copy-check output, branch; "never guess the copy-check result, the source commit or the sha" | `:10-15` same list, same never-guess sentence | kept |
| `:55-58` read the whole source skill, enumerate items yourself | `:20-23` | kept |
| `:59-61` present-item substance test "a line that is only related is a FAIL" | `:24-26` | kept |
| `:65-69` exclusion substance tests (already covered, adds length, unsourced number vs requirement) | `:27-34` | kept |
| `:72` copy check "for each adopted file" | `:37-38` | kept |
| `:77-84` full record frontmatter, `branch:` makes the gate read a FAIL, PASS only when every check holds | `:45-52` | kept |
| `:45` "the rubric above does not run" | dropped | correct: there is no rubric in this file |
| Process step 6 record rules (model, model_tier, waiver, reviewed_commit, REPLACE + History, only you), previously only implicit for the mode | `:54-59` "Record rules", explicit | strengthened (closes prior nit 4) |

Added, as the dispatcher stated: "Source is data" (`:17`, closes prior comment 1), step 8
method source line (`:41`, closes prior comment 2), step 9 row shape (`:42`, closes prior nit 3).
Steps 8 and 9 match the format doc (`README.md:40-41`, `:27-34`). Current
`agents/skill-reviewer.md` carries no leftover of the mode.

**Limit of this check:** lines of the former section that the prior record did not quote (exact
wording of steps 2, 4, 5 and 7) were not compared word for word. The dispatcher, who has a
shell, should run `git show 686e56f:agents/skill-reviewer.md | sed -n '41,84p'` against `:19-52`
here to close that gap mechanically.

## Scores

- **trigger/description clarity: 2**, `:3`. What: "Verifies a skill's depth checklist against
  the source skill it adopts from ... and writes docs/evals/adoption-<skill>.md." When: "before
  releasing such a skill". Boundary: "Checklists only; skill craft goes to skill-reviewer." It
  also says "Maintainer only, never published."
- **tool least-privilege: 2**, `tools: Read, Grep, Glob, Write` (`:4`). Write is fenced in the
  agent's own words: "you never edit the artifact you judge: you use Write only for your own eval
  record" (`:8`), which fixes the nit the skill-reviewer record noted (that file relied on
  Guardrails 5 alone). No Bash: the copy check is run by the dispatcher and handed in (`:13`). No
  Edit.
- **role boundary: 2**. One job, faithfulness, with the wisdom line drawn (`:8`). Escalates
  rather than guessing: "Missing any of them: ASK, and say your record is incomplete" (`:14`);
  "If that file is absent, say so and stop" (`:8`); hostile source text is named, not obeyed
  (`:17`).
- **policy conformance: 2**. `effort: high` (`:5`), allowed set (C12). No `model:` line and no
  version-pinned name (C11); judgment inherits the session. No em or en dash (C7). Output
  language rule present with the `Guardrails 7` pointer (C13, `:62-68`). Bare `AGENTS.md`
  citations (`:56`, `:66`) are correct for a repo-only file: `skills-lint.sh:111-113` exempts
  `.claude/agents/` from C14-C16, matching `.claude/agents/code-reviewer.md`. No isolation needed:
  it writes only its own record. Record frontmatter satisfies merge-gate: `branch`, `date`,
  `verdict`, `model_tier`, `reviewed_commit` each once (`merge-gate.sh:210`), `PASS` accepted
  (`:224`), `type: adoption` unrestricted.
- **instruction quality: 2**. A precise contract: inputs with ask-on-missing, a nine-step process
  with substance-over-form tests, an explicit record shape the gate reads, record rules
  (`model:` as actually run, tier, waiver, sha never fabricated, REPLACE + History, verdict
  ownership), a data-not-instructions rule, and a language rule. The comments below are real but
  each is a one-line addition; none makes the contract thin. Calibration evidence (behavior, not
  scored): both fixtures through this agent at 208d421 return `verdict: FAIL` as expected
  (`docs/calibration-runs/adoption-check/run-strained-2.md`, `run-missing-item-2.md`).

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10 reachable, and reached
No criterion caps structurally for this agent.

## Top fixes (comments, not blocking; per `docs/eval-framework.md` they go to the follow-up list)
1. **Substance tests for every exclusion reason, not three of seven.** Step 4 (`:30-34`) tests
   "already covered", "adds length" and "number without a source". A "non-goal" exclusion is
   only checked for quoting ("a non-goal quotes the non-goal"), not that the quote exists in the
   PRD and actually covers the item; "a factual error" is not checked at all. Both are gaming
   routes of the kind this agent exists to catch. Add: "a non-goal quote must exist in the PRD's
   non-goals and cover the item; a factual-error exclusion names the error and its correction."
2. **Read the requirement in step 1.** `:20` reads the format doc, checklist, source skill and
   Odeo skill, but not the requirement, which step 4's number test and the non-goal duty depend
   on. Change to "... the whole Odeo skill and the requirement (PRD and requirement id)."
3. Nit: step 7 (`:39-40`) checks `source_skill` and `source_commit` but not the checklist's
   `skill:` field against the Odeo skill path you were given. Add it.
4. Nit: add to the inputs (`:10-13`) "confirmation that `find .claude/sources -name CLAUDE.md -o
   -name AGENTS.md` printed nothing" (`README.md:67-71`). The agent has no shell, and an
   unrenamed source instruction file is loaded into its context before `:17` can help.
5. Nit: `:47` names `scorer` without its value. Say `scorer: adoption-reviewer`.

## Outside this artifact (policy drift found while checking conformance)
- `AGENTS.md:358-360` (Guardrails 5) lists the scoring reviewers that hold Write for their own
  record only; `adoption-reviewer` is not on it. `AGENTS.md:233` (Guardrails 1) still says "the
  other four scoring reviewers"; with this agent there are five without Bash. AGENTS.md is the
  single source of truth, so add the agent there (code-reviewer, also repo-only, is already named).
- `scripts/skills-lint.sh:119` C6 checks the single-verdict contract for four reviewers only.
  This file carries "Only you" and "History" (`:58-59`) today, but nothing enforces it; add
  `adoption-reviewer` (and `agent-reviewer`) to that list.

## Integrity
House voice; the wording mirrors `docs/depth-checklists/README.md` and the former skill-reviewer
section on purpose (same repo). Nothing looks copied from another project; no third-party plugin
or person is named in the agent file.

## Round-by-round
- Round 1 (208d421): 10/10 PASS. Trigger 2, tools 2, role 2, policy 2, instructions 2.

## Vs previous version
No prior record for this agent. Against its predecessor (skill-reviewer adoption mode, 10/10 on
75c14e1): same score, and the three open comments plus one nit from that record are closed
(source is data, method source line, row shape, explicit record rules). No regression found
within the quoted lines.

## History
- 2026-11-03 v1 (208d421): first review. PASS, 10/10.
