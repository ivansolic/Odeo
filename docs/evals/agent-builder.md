---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: 5b46abd
artifact_version: 5
date: 2026-08-06
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 1 }
total: 9/10
verdict: PASS
previous_total: 10/10
---

# Agent: builder (round 4, at 5b46abd)

Scoped re-review of ONE change: the model bullet in `## Rules for yourself` (`:110-116`).
Frontmatter is untouched. Everything cleared in rounds 1 to 3 was re-checked at this commit
and carries forward with its evidence.

Version note: `artifact_version: 5` = the fifth reviewed state (v2 = aee5ab1, v3 = f8f8da6,
v4 = f4e295a, v5 = 5b46abd).

Method note: no Bash in this reviewer's grant, so `git show` was not run. Scored the file as
it stands at the supplied `reviewed_commit`, with the previous wording taken from the round-3
record and the dispatch brief. Cross-checked `AGENTS.md`, `skills/build/SKILL.md`,
`docs/plan-format.md`, `bin/skills-lint.sh`.

## Scores

- **trigger/description clarity: 2** , `:3` unchanged: what it does, when it is dispatched
  ("Dispatched by /build after the human approves the architect's plan"), and the refusal
  condition ("Requires the plan; without an approved plan it does not build").
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`); every
  member is exercised by the pipeline (green baseline, edits, verify commands), contained by
  `isolation: worktree` (`:7`) and "One story, one worktree, never merge" (`:117`). Note the
  interaction with finding 1: `Write`/`Edit` are legitimate here, which is exactly why an
  ownerless instruction pointing at the plan file matters.
- **role boundary: 2** , the edit ADDS an explicit boundary that was previously only implied:
  "You never change your own model" (`:115-116`), on top of step 5's escalation (`:48-51`) and
  5b's routing of the hard case back into it (`:59-61`). Nothing else in the file asks the
  builder to select a model. Residual (finding 1) is scored under instruction quality rather
  than penalised twice.
- **policy conformance: 2** , `model: sonnet` (`:5`) is still a TIER from the allowed
  sonnet/inherit set, `effort: high` declared per AGENTS.md:55-58, `isolation: worktree` set on
  the one role that mutates files in parallel, no version-pinned name anywhere in the file
  (C11 clean; `bin/skills-lint.sh:96` pattern would catch `sonnet-<n>` and there is none). The
  new prose adds no version, no id, no host name. House style clean: no em or en dash in the
  file (checked), no Cyrillic.
- **instruction quality: 1** , clear but one of the three new sentences is an obligation with
  no owner that the builder can satisfy only by fabricating or by editing its own contract,
  and it contradicts `:18-19` of this same file. Detail below. The rest of the contract
  (process, output shape, guardrail integration, rules-for-yourself) remains at level-2
  quality, which is why this is 1 and not 0.

## Total: 9/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reachable
Nothing about this role structurally caps a criterion. 10/10 was held at v4 and this round
gives one point back on instruction quality; fixing finding 1 (one sentence) restores it.

## Round-by-round
Round 1 (aee5ab1): 9/10, 2 Important + 3 Minor.
Round 2 (f8f8da6): 10/10, 3 Minor open.
Round 3 (f4e295a): 10/10, 2 Minors closed, 1 carried.
Round 4 (5b46abd): 9/10 PASS. One Important introduced by this edit (instruction quality
2 -> 1), plus 2 Minors; no criterion at 0, no regression elsewhere.

## What the edit got right
- The mechanism it REMOVED was wrong under the new design. "For a max-quality run the human
  flips your `model:` to `inherit`" named a FILE edit as the escalation path; the whole point
  of the change is that a stronger model for one story touches no file. Deleting it is a
  correctness fix, not a loss.
- `:110-113` states the default correctly and in tier language, and pins the reason to the
  system's shape ("you execute while the plan you follow and the reviews behind you ride the
  strong tiers"), which matches AGENTS.md:52-54.
- "You never change your own model" (`:115`) makes an implicit boundary explicit and is the
  right sentence for a rules-for-yourself section: it is a prohibition the agent CAN obey.

## Findings

**1. Important, `:116` vs `:18-19`: an ownerless duty on the `model_plan:` line.**
The new sentence ends "and the model that actually ran is what goes in `model_plan:`". In a
section addressed to the builder ("Rules for yourself"), a passive sentence about what "goes
in" a field reads as a duty. Three problems compound:
- **Wrong owner.** `skills/build/SKILL.md:192-195` assigns it to the pipeline: the chosen model
  is "passed at dispatch and recorded in the plan's `model_plan:` line", by the same actor that
  flips `approved:` and writes `arch_review:` (`SKILL.md:183-189`, `docs/plan-format.md:23-29`).
  The builder is not that actor.
- **It points a write-capable agent at its own contract.** This agent holds `Write, Edit`
  (`:4`) and is told "The plan is a contract: you implement it, you do not redesign it"
  (`:11-12`), but nothing in the file forbids editing the plan's frontmatter, and a provenance
  line is not obviously "design". The one instruction in the file that mentions putting a value
  into the plan is this one.
- **It cannot be done honestly.** A dispatched agent cannot reliably resolve which model is
  executing it; `skills/build/SKILL.md:42-46` requires ASKING rather than stating a guess and
  names a fabricated `model_plan:` as a failure that "has happened". So the only routes open to
  a literal builder are fabrication or an unauthorised edit.
- **Internal contradiction.** `:18-19` defines the block as "who thinks, who executes, and at
  what EFFORT, as resolved when the plan was written", while `:116` says it holds the model that
  actually ran. Normally identical; they diverge precisely in the case this commit created (a
  per-run choice made after the plan document exists), and no one is designated to reconcile.
Fix (replaces the last clause of `:116`): "`/build` records the model it dispatched you on in
the plan's `model_plan:` line; you neither write nor verify that line. If you can see you are
running on a model that contradicts it, report the mismatch in your result and keep building,
never edit the plan."
That also closes the "unexpected model" gap the brief asked about: today the file gives the
builder no observable, no check and no action for that case.

**2. Minor, `:114-115`: guidance for the human in the builder's rules, copied not cited.**
"Choosing higher is right when the OUTPUT itself is judgment (wording, instructions, prose),
since then building is not transcription" is a near-verbatim restatement of
`skills/build/SKILL.md:56-58` ("Choose higher when the OUTPUT ITSELF is judgment (wording,
instructions, prose), because then the building is not transcription"). It is a decision rule
for the human at the model-plan step; the builder cannot act on it, and it sits one clause
before "You never change your own model", so the file explains a choice and then forbids
making it. It is also the copy-vs-cite drift class that round 3 closed for the binding list,
where both sites now cite `docs/plan-format.md` with "that file wins if this differs"
(`:52-55`, `:100-102`). Fix: keep one clause and cite, e.g. "when to choose higher is the
human's call at `/build`'s model-plan step (`skills/build/SKILL.md`), never yours", or delete
the sentence: it costs the builder nothing.

**3. Minor, cross-file (not fixable in this file): `AGENTS.md:52-54` and
`bin/skills-lint.sh:100` still describe the pre-change mechanism.** AGENTS.md:52-54 reads
"Execution (the builder) is pinned to the `sonnet` TIER" as a flat invariant, and the lint
comment reads "its tier is pinned to sonnet (or inherit for max-quality)", i.e. the file-edit
route this commit abandoned. builder.md `:110-113` now calls that pin a default that a human
may raise per run. I did not dock policy conformance: the frontmatter pin, C11 and
AGENTS.md:262-266 ("who thinks, who executes ... the model named in any record is the one that
actually ran") are all satisfied, and AGENTS.md:257-261 is intentionally unchanged. But
AGENTS.md is the source of truth, so its wording should catch up or a later reader will read a
contradiction. Fix: at AGENTS.md:52-54, "the builder's DECLARED tier is `sonnet` (lint C11);
the human may dispatch a stronger model for a given run at `/build`'s model-plan step, which
edits no file"; and correct the parenthetical in `bin/skills-lint.sh:100`.

## Open (carried from round 3)
- **Minor, `:10` and `:36`** , "executing its APPROVED plan exactly" and "never guess mid-build"
  still precede any pointer to 5b. Mitigated by `:117-118`. Fix at `:10`: "what 'exactly' binds
  is in step 5b".
- **Nit, `:55-57` and `:102-103`** , insertions still leave short half-lines mid-sentence;
  rewrap. The new bullet itself wraps cleanly.

## Integrity
House voice throughout; consistent with `agents/architect.md` and the skills. No text that
looks imported from another project. The one near-verbatim overlap is internal
(`skills/build/SKILL.md`) and is finding 2, a citation issue, not an integrity issue.

## Vs previous version
10/10 -> 9/10. Nothing regressed structurally: tools, isolation, effort, the contract pipeline
and 5b are byte-identical in effect. The single rewritten bullet improved role boundary
(explicit "never change your own model") and removed a now-wrong mechanism, but introduced one
ownerless, unverifiable duty (`:116`) that also contradicts `:18-19`. One sentence, one point.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; all three
  5b qualifications landed; 3 Minors open.
- 2026-08-04 v4 (f4e295a): scoped re-review of the materiality rewording and the binding-list
  citation, both confirmed closed. Round 3 = 10/10 PASS, held.
- 2026-08-06 v5 (5b46abd): scoped re-review of the rewritten model bullet (`model:` as default,
  build model chosen per run at dispatch). Round 4 = 9/10 PASS. instruction_quality 2 -> 1 for
  the ownerless `model_plan:` duty at `:116` (wrong owner per SKILL.md:192-195, unverifiable by
  a dispatched agent, contradicts `:18-19`); role_boundary held at 2 on the new explicit "You
  never change your own model"; policy conformance held at 2 (tier-only, C11 clean), with the
  AGENTS.md:52-54 / lint-comment drift logged as a cross-file Minor.
