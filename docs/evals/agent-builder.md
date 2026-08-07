---
artifact: builder
type: agent-definition
branch: chore/build-asks-builder-model
reviewed_commit: 895b667
artifact_version: 9
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

# Agent: builder (round 8, at 895b667)

Scoped review of one addition: the authority sentence opening `## Inputs you require` (`:16-17`),
which closes the durability Nit round 7's re-anchor raised. The artifact moved, so
`artifact_version:` bumps to 9. Score held at 10/10 PASS.

The split it declares is the RIGHT one, and I state why below rather than just accepting it. One
Nit on its scope wording (one word), non-blocking.

Version note: `artifact_version: 9` (v2 = aee5ab1, v3 = f8f8da6, v4 = f4e295a, v5 = 5b46abd,
v6 = a2eec03, v7 = 76188a6, v8 = 995fde4 and re-anchored at 0fcc65b, v9 = 895b667). The file grew
by two lines, so v8 citations after `:15` sit two lines lower here.

Method note: no Bash in this reviewer's grant, so no `git show`. Re-read `agents/builder.md` in
full at this commit; cross-checked `skills/build/SKILL.md`, `docs/plan-format.md`, `AGENTS.md`.

## Scores (all held)

- **trigger/description clarity: 2** , `:3`, unchanged.
- **tool least-privilege: 2** , `tools: Read, Write, Edit, Bash, Grep, Glob` (`:4`), fenced by
  `isolation: worktree` (`:7`), `:125` ("One story, one worktree, never merge") and `:124`
  ("Never edit the plan").
- **role boundary: 2** , `:118-124`, unchanged.
- **policy conformance: 2** , `model: sonnet` (`:5`), `effort: high` (C12), `isolation: worktree`;
  re-grepped clean at this commit: no version-pinned model name (C11), no em or en dash.
- **instruction quality: 2** , held. The addition improves it: the file now declares what it owns,
  so the cross-file pointer at `skills/build/SKILL.md:200` rests on a claimed status instead of an
  assumed one. The one-word over-reach below is a Nit, not a level change.

## Total: 10/10   ## Verdict: PASS (threshold >= 8/10, no criterion at 0)

## Ceiling: 10/10, reached
Open: one Minor and four Nits, all cosmetic or citation-level. Listed so a 10 hides nothing.

## Round-by-round
Round 1 (aee5ab1) 9/10 -> round 2 (f8f8da6) 10/10 -> round 3 (f4e295a) 10/10 -> round 4 (5b46abd)
9/10 -> round 5 (a2eec03) 9/10 -> round 6 (76188a6) 10/10 -> round 7 (995fde4, re-anchored
0fcc65b) 10/10 -> round 8 (895b667) 10/10. Three consecutive rounds at max; every structural item
raised in rounds 1 to 6 is closed.

## Is "authoritative for WHICH, shape owned elsewhere" the right split? Yes.
`:16-17` reads "This list is AUTHORITATIVE for WHICH preconditions exist (other files cite it
rather than keeping a second copy); `docs/plan-format.md` defines each field's shape." Tested
against every consumer and against the failure history:
- **It matches what each file can change on its own.** WHICH preconditions exist is a ROLE fact:
  it decides when this agent refuses (`:27`, "**No approved, review-carrying plan = do not
  build.**"), and no other file can change that behaviour. A field's shape is a FORMAT fact that
  changes when the plan format changes. Behaviour here, syntax there, each owner able to edit
  without asking the other: that is a clean seam, not a compromise.
- **The alternative would reintroduce the failure this file spent five rounds closing.** If this
  file owned the shape too, every plan-format change would require editing an agent definition,
  which is exactly the drift that produced round 1's four-way binding-list divergence and the
  round-5 stale precondition list. `:59-61` already settled the same question the same way for the
  binding contract list ("that file wins if this differs"), so the new sentence is consistent with
  the file's own precedent rather than a new policy.
- **It is verified in both directions.** `skills/build/SKILL.md:198-200` cites this list for WHICH
  ("all three are the builder's contract preconditions (`agents/builder.md` has the authoritative
  list)"), and `:20-21` cites `docs/plan-format.md` for the shape ("a tier word plus effort... per
  `docs/plan-format.md`"), where `docs/plan-format.md:31` is the definition
  (`builder_tier: <tier word> effort <level>`). Each claim points at the file that owns it; there
  is no cycle, because the two files answer different questions.
- **It should NOT also own the shape.** `:20-21` paraphrases the shape as a reading convenience.
  Making that paraphrase normative would put a volatile format detail inside an instruction file,
  the same class of mistake lint C11 exists to prevent for model names.

## Nit on the new sentence: narrow "preconditions" to "plan preconditions"
The claim as written ("AUTHORITATIVE for WHICH preconditions exist") is one word broader than the
list. Pipeline step 1 (`:43`) holds a precondition this list does not contain: "the plan covers
THIS story". Nothing breaks in practice, because the file that cites this list
(`skills/build/SKILL.md:198-200`) enumerates exactly the three PLAN-carried conditions, and
story-coverage is a matching check no plan can carry and no gate can pre-verify. But an
exhaustive-sounding claim immediately followed by an extra check in step 1 is the seam a future
reader trips on. Fix, one word: "AUTHORITATIVE for WHICH **plan** preconditions exist". That keeps
round 7's pointing structure intact (step 1 keeps its own two items: this-story scope and
ask-now). The alternative, moving story-coverage into the Inputs list, also works but re-opens the
step-1 wording that is now settled, so I recommend the one-word form.

## Open (carried, none blocking)
- **Minor, `:10` and `:41`** , "executing its APPROVED plan exactly" and "never guess mid-build"
  precede any pointer to 5b. Mitigated by `:128-129`. Fix at `:10`: "what 'exactly' binds is in
  step 5b".
- **Nit, `:121-122`** , "`/build` records what it dispatched you on in the eval record"; the writer
  is `code-reviewer` from a value the orchestrator hands it (`skills/build/SKILL.md:205-207`).
  Immaterial: the builder is forbidden to write or verify it in the same sentence.
- **Nit, `:61-63` and `:108-109`** , short half-lines mid-sentence; rewrap.
- **Nit, `:19-26`** , the Inputs bullet is a ~100-word sentence with nested parentheses; a
  sub-bullet per precondition would make the three countable at a glance. Worth doing only if that
  bullet is edited again anyway.
- **Nit, NEW, `:16`** , the one-word scope narrowing above.

## Closed since the re-anchor
- **The effort placeholder is now fully applied.** `skills/build/SKILL.md:255` reads "at effort
  <as the user just told you>", matching the template at `:62`. The instance I found from this file
  by following the cross-reference is gone.
- **The durability Nit is closed** by `:16-17`, in this file's existing precedence style.
- Process note, factual: the surviving placeholder sat in a file this reviewer does not own and was
  found by following a citation out of `agents/builder.md`, after the domain owner verified the
  line it was pointed at and reported clean. Recorded because it is a reusable signal about
  cross-reference review, not because it changes any score here.

## Integrity
House voice, consistent with the sibling agents. No imported text; overlap with siblings is by
citation only, and the new sentence makes the citation direction explicit.

## Vs previous version
10/10 -> 10/10, held, with one durability gap closed and no regression. `agents/builder.md` is now
self-describing about its own authority, which is the last item that had been raised against it in
eight rounds.

## History
- 2026-08-04 v2 (aee5ab1): first per-file review after ADR-001 change 9. Round 1 = 9/10 PASS, two
  Important open.
- 2026-08-04 v3 (f8f8da6): re-review after the first fix pass. Round 2 = 10/10 PASS; 3 Minors.
- 2026-08-04 v4 (f4e295a): materiality rewording + binding-list citation closed. Round 3 = 10/10
  PASS, held.
- 2026-08-06 v5 (5b46abd): rewritten model bullet. Round 4 = 9/10 PASS; instruction_quality 2 -> 1
  for an ownerless, unverifiable `model_plan:` duty; AGENTS.md "pinned" drift logged.
- 2026-08-06 v6 (a2eec03): all three round-4 findings closed; held at 1 on a new defect, the
  precondition list still describing the one-field `model_plan:`. Round 5 = 9/10 PASS.
- 2026-08-06 v7 (76188a6): precondition list names `builder_tier:`, cites the format, disarms the
  false-refusal path. Provenance relocation verified against `bin/merge-gate.sh:294` and
  `docs/eval-framework.md:67-76`. Round 6 = 10/10 PASS.
- 2026-08-07 v8 (995fde4): step 1 points at the Inputs list, so the file carries one enumeration.
  Round 7 = 10/10 PASS, held. Re-anchored at 0fcc65b with no artifact change; that commit's B5.3
  fix closed round 7's cross-file note, and the effort placeholder was found only partly applied.
- 2026-08-07 v9 (895b667): Inputs section now declares its own authority (`:16-17`, WHICH
  preconditions here, field shape in `docs/plan-format.md`), closing the durability Nit. The split
  verified correct in both directions and against the drift history; one Nit added (narrow the
  claim to "plan preconditions", since step 1 holds the story-coverage check). Round 8 = 10/10
  PASS, held.
