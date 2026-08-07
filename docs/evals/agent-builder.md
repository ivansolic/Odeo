---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: 0fcc65b
artifact_version: 8
date: 2026-08-07
scorer: agent-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, tool_least_privilege: 2, role_boundary: 2, policy_conformance: 2, instruction_quality: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

# Agent: builder (round 7 re-anchored at 0fcc65b)

Record regeneration so the merge gate has a record covering HEAD, NOT a new review round.
`agents/builder.md` did not move: its text at `0fcc65b` is identical, line for line, to the
`995fde4` state scored in round 7, so `artifact_version:` stays 8 (same reviewed state of the
artifact) while `reviewed_commit:` advances to the commit that merges. Scores held: 10/10 PASS.

Read-through check on the three `skills/build/SKILL.md` wordings in this commit: none makes a
line in `agents/builder.md` stale, and nothing blocks. One of the three is only PARTLY applied,
in the skill, not here; detail under Out of scope, because it should not reach the human gate
believed closed.

Method note: no Bash in this reviewer's grant, so no `git show`. I verified content identity by
re-reading `agents/builder.md` in full at this commit and comparing it against the v8 text quoted
in round 7; I cannot independently verify from inside this session which paths a commit touched,
so the "unchanged" claim rests on that content comparison plus the dispatcher's statement.

## Scores (all held, artifact unchanged)

- **trigger/description clarity: 2** , `:3`, unchanged.
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), fenced by
  `isolation: worktree` (`:7`), `:123` and `:122`.
- **role boundary: 2** , `:116-122`, unchanged.
- **policy conformance: 2** , `model: sonnet` (`:5`), `effort: high`, `isolation: worktree`;
  re-grepped clean at this commit: no version-pinned model name (C11), no em or en dash.
- **instruction quality: 2** , one enumeration of the preconditions at `:17-27`, step 1 pointing
  at it (`:39-41`).

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Open items are one Minor and four Nits (one added below), all cosmetic or citation-level.

## Round-by-round
Round 1 (aee5ab1) 9/10 -> round 2 (f8f8da6) 10/10 -> round 3 (f4e295a) 10/10 -> round 4
(5b46abd) 9/10 -> round 5 (a2eec03) 9/10 -> round 6 (76188a6) 10/10 -> round 7 (995fde4) 10/10,
re-anchored here at `0fcc65b` with no artifact change and no score movement.

## Read-through check on this commit's three wordings
- **B5.3 now names all three preconditions and points here** (`skills/build/SKILL.md:198-200`:
  "...and a `builder_tier:` line in its `model_plan:`; all three are the builder's contract
  preconditions (`agents/builder.md` has the authoritative list)") , this CLOSES the cross-file
  note round 7 raised, and it closes it the better way: by pointing at one home rather than
  maintaining a second list. No conflict with `:18`, which cites `docs/plan-format.md` for the
  FIELD's shape while the skill cites this file for WHICH preconditions exist. Two different
  questions, no circular authority.
- **The worked example no longer glosses `build_model_as_dispatched:` as "the model the builder
  ran on"** (`skills/build/SKILL.md:267` now "<the model it was dispatched on>") , correct, and
  invisible to this file: `agents/builder.md` never glosses that field, it only forbids writing or
  verifying it (`:119-120`).
- **The effort placeholder in the model-plan question** (`skills/build/SKILL.md:62`, now "at
  effort <as the user just told you>") , applied in the question template, and it does not touch
  this file: the builder's effort is declared in its own frontmatter (`:6`), never taken from that
  question. See Out of scope for the surviving instance.

## Open (carried, none blocking)
- **Minor, `:10` and `:39`** , "executing its APPROVED plan exactly" and "never guess mid-build"
  precede any pointer to 5b. Mitigated by `:126-127`. Fix at `:10`: "what 'exactly' binds is in
  step 5b".
- **Nit, `:119-120`** , "`/build` records what it dispatched you on in the eval record"; the
  writer is `code-reviewer` from a value the orchestrator hands it
  (`skills/build/SKILL.md:205-207`). Immaterial: the builder is forbidden to write or verify it in
  the same sentence.
- **Nit, `:59-61` and `:106-107`** , short half-lines mid-sentence; rewrap.
- **Nit, `:17-24`** , the Inputs bullet is a ~100-word sentence with nested parentheses; a
  sub-bullet per precondition would make the three countable at a glance. Worth doing only if that
  bullet is edited again anyway.
- **Nit, NEW, `:17-27`** , `skills/build/SKILL.md:200` now designates this list "the
  authoritative list", but the list itself claims no such status. Nothing is false today (the list
  IS complete), so this is not a finding against the file; it is a durability gap: a future edit
  here would not know another file leans on it. One clause fixes it, in this file's existing
  precedence style ("this list is authoritative; `docs/plan-format.md` defines each field's
  shape").

## Out of scope, for the coordinator (skill file, `skill-reviewer` owns it)
The third wording is only PARTLY applied. `skills/build/SKILL.md:62` (the question template) now
reads "at effort <as the user just told you>", but the worked example still prints the old
placeholder: `:254-255`, "Judgment (plans, reviews): <the model the session is running now> at /
effort <as resolved>." That is the exact string the change removed, and it survives in the part of
the file an agent imitates most, next to `:50-51`'s own warning against "a resolved-looking effort
value you were not told". Not a builder.md issue and not a blocker for this record; flagged
because the message to me described this nit as closed, and the human gate should not inherit that
belief. Suggested fix: make `:255` "at effort <as the user just told you>", matching `:62`.

## Integrity
House voice, consistent with the sibling agents. No imported text; overlap with siblings is by
citation only.

## Vs previous version
No artifact change, so no score movement: 10/10 -> 10/10. The only substantive difference from the
v8 record is that the cross-file duplicate-enumeration note round 7 logged is now closed in
`skills/build/SKILL.md:198-200`, and one durability Nit is added in its place.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS,
  two Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; 3 Minors.
- 2026-08-04 v4 (f4e295a): materiality rewording + binding-list citation closed. Round 3 =
  10/10 PASS, held.
- 2026-08-06 v5 (5b46abd): rewritten model bullet. Round 4 = 9/10 PASS; instruction_quality
  2 -> 1 for an ownerless, unverifiable `model_plan:` duty; AGENTS.md "pinned" drift logged.
- 2026-08-06 v6 (a2eec03): all three round-4 findings closed; held at 1 on a new defect, the
  precondition list still describing the one-field `model_plan:`. Round 5 = 9/10 PASS.
- 2026-08-06 v7 (76188a6): precondition list names `builder_tier:`, cites the format, disarms the
  false-refusal path; report destinations disambiguated. Provenance relocation verified against
  `bin/merge-gate.sh:294` and `docs/eval-framework.md:67-76`. Round 6 = 10/10 PASS.
- 2026-08-07 v8 (995fde4): step 1 points at the Inputs list, so the file carries one enumeration.
  Round-6 Minor closed; read-through against four sibling files found nothing stale. Round 7 =
  10/10 PASS, held.
- 2026-08-07 v8 re-anchored (0fcc65b): record regenerated for gate coverage; `agents/builder.md`
  unchanged (content compared line for line), so no new round and no score movement. This
  commit's three `skills/build/SKILL.md` wordings read through clean; the B5.3 fix closes round
  7's cross-file note by pointing here, one durability Nit added, and the effort-placeholder nit
  is confirmed only partly applied (`skills/build/SKILL.md:254-255` still shows "<as resolved>"),
  routed to `skill-reviewer`.
