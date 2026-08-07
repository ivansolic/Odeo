---
artifact: skills/build/SKILL.md
type: skill
branch: chore/build-asks-builder-model
reviewed_commit: 895b667
artifact_version: 11
date: 2026-08-07
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: record regeneration at `895b667` after a survivor of the effort-placeholder
fix was found at `skills/build/SKILL.md:255`, inside the worked example, and fixed.
This time I swept the whole file for every string this branch has touched instead
of verifying only the reported lines. Re-checked `agents/builder.md:15-29`,
`docs/plan-format.md:22-40`, `docs/eval-framework.md:55-79`,
`agents/code-reviewer.md:136-142`, `AGENTS.md:262-279`.

## Skill: build  (explicit command)

## Scores
- trigger clarity **2**. Untouched.
- structure **2**. Untouched. Subheading and paragraph split still carried
  knowingly.
- worked example **2**. `:255` now reads "effort <as the user just told you>",
  matching the template at `:62`. The example no longer contains any string the
  step removed.
- precision **2**. The placeholder that had no obtainable source is gone from both
  places it lived. Score holds rather than moves: in round 9 I scored precision 2
  on a file where `:255` still carried the old string, so the 2 was awarded on an
  incomplete check. It is correct NOW, at this commit, which is what
  `reviewed_commit:` binds it to.
- safety integration **2**. `agents/builder.md:16-17` now declares its Inputs list
  "AUTHORITATIVE for WHICH preconditions exist (other files cite it rather than
  keeping a second copy); `docs/plan-format.md` defines each field's shape", so
  `SKILL.md:200`'s pointer at "the authoritative list" now lands on a file that
  claims the status and the ownership split is explicit: which preconditions exist
  (builder.md) versus what each field looks like (plan-format.md). A pointer to an
  unclaimed authority is how second copies get born, so this closes the mechanism,
  not just the wording.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Third copies? Swept, and there are none
I grepped `skills/build/SKILL.md` for every string this branch has added, removed
or reworded, not just the two lines I was told about:
- Effort placeholder: exactly two occurrences, `:62` and `:255`, both
  "<as the user just told you>". No `<as resolved>` anywhere in the file.
- With-me build-line exclusion: one occurrence (`:69-70`). `:79` ("In with-me mode
  the spoken question is the announcement") is a different statement, not a second
  copy of the exclusion.
- Provenance field: `build_model_as_dispatched:` at `:206` and `:267` only; the
  superseded plan-field name `builder_as_dispatched:` appears nowhere.
- "ran on" as a gloss: gone; `:267` says "<the model it was dispatched on>". The
  only surviving "ran" is `:210`, "its absence is never evidence that a build ran on
  the default", which is correct usage (it denies an inference about execution
  rather than claiming one).
- Host enumeration: one occurrence (`:54`), the prohibition. No "available on this
  host" and no "as the harness reports them" remain.
- No "who actually built" anywhere.
Cross-file, `docs/plan-format.md`, `docs/eval-framework.md`,
`agents/code-reviewer.md`, `agents/builder.md` and `AGENTS.md:262-279` still agree
with the skill on where intent lives, where the resolved name lives, and that the
field discloses what was requested.

## On the miss, since it is mine to own
I verified `:62` because that is the line I had named, reported the file clean, and
the survivor sat three lines below my own quoted warning against printing a
resolved-looking effort value. The lesson is specific and I am recording it so the
next reviewer of any skill inherits it: **a wording fix has to be verified as a
file-wide string sweep, never as a spot check of the line the fix names**, because
a worked example is a second copy of the step by construction, which is exactly why
the standard asks the example to mirror the process. That the second reviewer
arrived from `builder.md` and found it is the layering working as designed, not
redundancy: the domain owner checks the line it was told about, and a reader coming
through a cross-reference checks the path a user would actually follow.

## Ceiling
10/10, reached. Nothing structurally capped.

## Round-by-round (this branch)
- Round 1 (5b46abd): 6/10 FAIL. Four blocking findings.
- Round 2 (a2eec03): 9/10 PASS. All four closed; one residual contradiction.
- Round 3 (76188a6): 9/10 PASS. Contradiction closed; three smaller findings.
- Round 4 (995fde4): 10/10 PASS. Precision 1 -> 2. (Awarded on a spot check; `:255`
  still carried the old string.)
- Round 5 (0fcc65b): 10/10 PASS, regeneration. Three wordings.
- Round 6 (895b667): 10/10 PASS, regeneration. Placeholder survivor at `:255`
  fixed, builder.md's Inputs list declared authoritative, file-wide sweep clean.

## Is it clean?
Yes, and this time the claim rests on a whole-file sweep rather than the lines I
was pointed at. Every criterion is at 2, no instruction requires a value the agent
cannot obtain, no duplicated instruction remains, no two instructions disagree with
each other or with the four files that share this design, and no gate is touched or
weakened. Ready for the human gate.

Unchanged caveat for the human: this is form verification, not behavioral. Whether
an agent at runtime walks the order of authority and asks, instead of trusting the
session-start model and a plausible-looking effort level visible in its own
context, is an `/improve` subagent test, and it belongs after the merge.

## Vs previous version
Version 10 (0fcc65b) scored 10/10 but was verified by spot check, and one copy of
the effort placeholder survived in the worked example. Version 11 removes it and
gives `SKILL.md:200`'s "authoritative list" pointer a target that claims the status
(`agents/builder.md:16-17`). No criterion moved; the difference is that the score
now rests on a file-wide check.

## Map duty
No command surface added or altered (`docs/system-map.md:67` already carries
`/build` with both modes), so no map delta is required. Not a finding.

## History
- Round 1 (2026-07-24, Opus 4.8, strongest): 9/10 PASS. Model-plan/effort change;
  worked example lagged the edited step.
- Round 2 (2026-07-24, Opus 4.8, strongest): 10/10 PASS. Worked example refreshed.
- Round 3 (2026-07-25, Opus 4.8, strongest): 10/10 PASS. Foreground-default
  guardrail added in B3 + Safety rules.
- Round 4 (2026-07-27, Opus 4.8, strongest): 10/10 PASS. For-me editor-open offer
  removed.
- Round 5 (2026-07-30, Opus 4.8, strongest): 10/10 PASS. Strongest-model-available
  resolution added.
- Round 6 (2026-08-06, Opus 5, strongest, 5b46abd): 6/10 FAIL. Build model became
  the user's choice; four blocking form defects.
- Round 7 (2026-08-06, Opus 5, strongest, a2eec03): 9/10 PASS. All four closed; one
  residual contradiction inside the block.
- Round 8 (2026-08-06, Opus 5, strongest, 76188a6): 9/10 PASS. Contradiction
  closed; provenance field moved to the eval record coherently across five files.
- Round 9 (2026-08-07, Opus 5, strongest, 995fde4): 10/10 PASS. Effort fixed at the
  premise, duplicate deleted, plan-write phrase disambiguated. Precision 1 -> 2,
  awarded on a spot check.
- Round 10 (2026-08-07, Opus 5, strongest, 0fcc65b): 10/10 PASS, regeneration.
  Example gloss, effort slot, B5.3 preconditions enumerated with a pointer.
- Round 11 (2026-08-07, Opus 5, strongest, 895b667): 10/10 PASS, regeneration. A
  surviving "<as resolved>" in the worked example (`:255`), missed by my spot check
  of `:62` and found by `agent-reviewer` following the cross-reference from
  `builder.md`, is fixed; `agents/builder.md:16-17` now claims the authority
  `SKILL.md:200` points at. File-wide sweep for every string this branch touched:
  no third copy of anything. Clean for the human gate; behavioral confirmation
  still owed to `/improve`.
