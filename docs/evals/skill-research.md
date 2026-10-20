---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 295631c
artifact_version: 7
date: 2026-10-20
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 2, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 8/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

This is round 2 on this branch, at 295631c. The dispatcher supplied that sha. I have no
shell, so I cannot confirm it myself. I scored the files on disk, which the dispatcher
reports as a clean tree at that commit.

The change under test is round 1's fixes 1 to 3:
- fix 1: the worked example is rebased on RES-002 v7 (F1 and F13, plus the earlier
  nearby-fact failure told as history);
- fix 2: the rubric's Verified sentence is rewritten so its scope is unambiguous;
- fix 3: step 4b now points at the rubric's Verified definition.

Fix 4 (`docs/system-map.md`) is outside the skill folder and was not applied.

Files read in full:
- `skills/research/SKILL.md` (120 lines)
- `skills/research/rubric.md` (126 lines)

Also read:
- `docs/research/RES-002-platform-support.md`, lines 1 to 230 (Question, Answer, Findings,
  capability table, notes 1 to 9), to check the example word for word;
- the history section of `docs/evals/RES-002.md`;
- the C18 block of `scripts/skills-lint.sh`;
- `docs/system-map.md`, line 72.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2 reads "Use when the user wants market or web
  research with sources, asks about market size, TAM/SAM/SOM, ...". That is the correct
  format for an auto-invoked skill, and it uses the user's own words ("is it true that...").
- structure: 2, unchanged. SKILL.md:9-11 says the terms are "defined once, in the
  Definitions of `${CLAUDE_PLUGIN_ROOT}/skills/research/rubric.md`; this skill uses them and
  never rewords them". SKILL.md has 120 lines. The rubric is the only supporting file, and it
  is one level deep.
- worked example: 1, unchanged score with a different defect. Round 1's defects are fixed,
  but the new excerpt cuts the notes down so far that copying them gives non-conforming
  notes.
  - **What is now right.** I checked these against RES-002:
    - F1 matches RES-002:72-73 word for word, apart from line wrapping.
    - F13 matches RES-002:100-101.
    - Note 1's first quote, "Use `codex plugin marketplace add` to add and track a
      marketplace source", matches RES-002:181-182.
    - Note 2's help text, "codex plugin marketplace add https://github.com/owner/repo",
      matches RES-002:185-186.
    - The compound clause is gone. Each finding carries one confidence word. The sentence
      "F1 is verified because both notes quote that same fact" (SKILL.md:90-91) is true of
      the quotes shown.
  - **Defect A: the notes drop the page or file.**
    - SKILL.md:84 reads "Note 1, OpenAI docs:". RES-002:180 names
      "developers.openai.com/plugins/build/plugins.md ... lines 184 to 191".
    - SKILL.md:86 reads "Note 2, Codex source at `90f00bd`:". RES-002:184 names
      "`codex-rs/cli/src/marketplace_cmd.rs` lines 62 to 66".
    - The rubric's Note definition (rubric.md:17-18) requires each source "with its page or
      file and a quote or locator". Traceability 2 (rubric.md:59-60) requires "page or file
      plus a quote or locator".
    - An agent that copies the example's note shape writes notes that score 1 on Traceability
      at the most. The anchor says "directly imitable". This example teaches the confidence
      rule but not the note shape, and the note shape is the part step 4b sends the reader
      to.
    - The v5 example kept the page ("Note 2: developers.openai.com/codex/hooks"), so this
      defect came in with 295631c.
  - **Defect B: one quote is truncated without marking it.**
    - SKILL.md:85 quotes the example as "codex plugin marketplace add
      https://github.com/example/plugins.git" and closes the quote there.
    - The source, RES-002:183, continues: "... plugins.git --sparse .agents/plugins".
    - SKILL.md:81 says "The findings and quotes are verbatim from it". The quoted text does
      appear in the source, but the cut is not marked. In a skill whose rule is "Never
      fabricate ... a quote" (SKILL.md:109), the example should show how to mark a cut.
  - **Could not verify (not scored).** The history sentence at SKILL.md:92-94 names the test
    `session_start_hooks_apply_additional_context_limits_individually`. That string appears
    nowhere in the working tree except SKILL.md. It would sit in an earlier RES-002 version
    (v5 or v6, per `docs/evals/RES-002.md:270-274`), which I cannot open without a shell. The
    dispatcher should run
    `git log -S session_start_hooks_apply_additional_context_limits_individually -- docs/research/RES-002-platform-support.md`.
    If that returns nothing, the sentence is a claim with no source, and it must change.
- precision: 2 (was 1). Fixes 2 and 3 landed as proposed.
  - rubric.md:28-31 now reads: "A quote of a nearby fact does not count: a quote that only
    names a field, test or string, or a related sentence, without itself stating the claim,
    leaves it one source. A code, binary or changelog quote that states the claim itself
    counts (Independent sources)."
  - "without itself stating the claim" now applies to all four items. That is Reading A, and
    it agrees with rubric.md:14-16 ("when each states the claim itself"). Two scorers can no
    longer split on F5, F7b, F2 or F15b.
  - SKILL.md:40 now reads "not a nearby one (the rubric's Verified definition)", so every
    defined term in step 4b is cited where it is used.
  - Paths, script names, the RES-NNN numbering rule and the editor commands are exact. There
    are no TBDs.
- safety integration: 2, unchanged.
  - SKILL.md:60-65: step 5b commits "on a branch (on `main`, ask the human to create one
    first: Git discipline in `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`)". It hands over the sha and
    `output_language` "(Guardrails 1 and 7 ...)" and loops under "Guardrails 3, with its stop
    condition".
  - SKILL.md:109-110 points at the honesty guardrail.
  - Neither file restates a guardrail.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

The skill passes at 9/10 with no criterion at 0. Stop condition 1 is met (it was met in
round 1 too). The skill is below max, so the three things owed for a below-max result
follow: the ceiling, the remaining findings and the open decision.

## Ceiling
10/10 is reachable. No criterion is capped by the nature of this skill. The remaining 1 is a
text fix inside `skills/research/SKILL.md`.

## The specific checks the dispatcher asked for
- **Example vs RES-002, word for word:** the findings match. Quote by quote:
  - F1: matches (RES-002:72-73).
  - F13: matches (RES-002:100-101).
  - Note 1's first quote: matches (RES-002:181-182).
  - Note 1's example: cut short without marking (RES-002:183).
  - Note 2's help text: matches (RES-002:185-186).
  - Note headers: shortened. They drop the page and file that the notes in RES-002 carry.
  - History test name: cannot be verified from the working tree (see above).
- **Fix 2 wording:** applied word for word as proposed in round 1.
- **Fix 3 pointer:** present at SKILL.md:40.
- **Single definitions (C18 and "defined once"):** hold.
  - rubric.md has exactly two fences (lines 37 and 111).
  - Lowercase "unverified" appears only at lines 9 and 34, both in Definitions, outside the
    fence.

## Top fixes
1. **Worked example (SKILL.md:84-87): give the notes in full, copied from RES-002, with no
   shortening.** Proposed text:
   > Note 1, OpenAI docs, developers.openai.com/plugins/build/plugins.md, lines 184 to 191:
   > "Use `codex plugin marketplace add` to add and track a marketplace source"; example line
   > 191: "codex plugin marketplace add https://github.com/example/plugins.git --sparse
   > .agents/plugins".
   > Note 2, Codex source, github.com/openai/codex at `90f00bd`,
   > `codex-rs/cli/src/marketplace_cmd.rs` line 63: help text "codex plugin marketplace add
   > https://github.com/owner/repo".

   This fixes defects A and B together. Each note then names its page or file and quotes
   the source exactly, which is the note shape the rubric scores.
2. **History sentence (SKILL.md:92-94): confirm the test name before the merge.** Run the
   `git log -S` command given above.
   - If it finds the string, keep the sentence.
   - If not, replace the name with the finding that was actually affected, as recorded in
     the history of `docs/evals/RES-002.md`.
3. Outside this skill folder, not scored, still open from round 1 (fix 4):
   `docs/system-map.md:72` says "every claim 2+ independent sources or labeled unverified".
   The rubric now uses "unverified" only for a claim with no nameable source. Suggested map
   text: "every claim verified by 2+ independent sources or labeled one source or
   unverified".

## Checks
- Size: SKILL.md has 120 lines and the rubric 126, both under 500. References are one level
  deep.
- Dashes: neither file has any.
- AGENTS.md: nothing is restated.
- Map duty: this change adds no command. `/odeo:research` is on `docs/system-map.md`
  (line 72). Fix 3 covers a wording drift there.
- Integrity: this is a first-party skill, so the copied-text check does not apply.

## Loop status and open decision
- Round 2 of 3 on this branch. Stop condition 1 (PASS) is met. A further round is the
  human's choice and would be the last under the cap.
- Stop condition 3, said plainly so the human can judge it: the worked-example finding in
  round 1 and the one in this round could be the same class, "the hand-copied RES-002
  excerpt drifts from its source or from the skill's own format". Both were fixed by editing
  the example text. The same criterion also dropped for this reason in earlier rounds (v2,
  v3, v4).
  - What would eliminate the class: copy whole notes word for word, with no shortening or
    paraphrase (fix 1). Then the only possible drift is RES-002 itself changing later, and a
    re-check against it is mechanical.
  - If the human prefers, the residual can be accepted at 9/10 instead.
- Not covered by this gate: the change is behavioural. Testing whether "one fact per claim"
  and the same-fact quote rule actually stop over-labelled Verified claims needs
  `/odeo:improve` subagent testing: a baseline run against a variant run, using material like
  RES-002's. A pass on form is not evidence that the behaviour changed.
- Fix 2 in the rubric took Reading A, so RES-002's 16/16 (round 8, `921f906`) should still
  hold under the reworded Verified definition. I did not re-score it. That is pm-reviewer's
  job.
- Human decision, choose one:
  - apply fix 1 (and fix 2 if needed), then dispatch round 3;
  - accept 9/10 with the residual as listed.

## Vs previous version
Better: 8/10 -> 9/10. The verdict stays PASS.
- precision 1 -> 2: the Verified sentence now has one reading, and step 4b names the
  definition it compresses.
- worked example 1 -> 1: round 1's two defects are fixed (the compound clause, and the stale
  provenance against v7). The new excerpt shortens its two notes below the rubric's Note
  definition and cuts one quote without marking it.
- No change: trigger clarity 2, structure 2, safety integration 2.

## History
- 2026-10-02 (v1, Round 1, f947223): first record. 8/10 PASS.
  - Structure 1: SKILL.md did not name or dispatch the rubric, and the shapes diverged.
  - Precision 1: undefined boundary terms, and anchors that left some cases unscored.
- 2026-10-02 (v2, Round 2, 914009a): 8/10 PASS.
  - Structure 1 -> 2.
  - Worked example 2 -> 1: the unchanged example broke the new Answer rule.
  - Precision stayed 1, with new conflicts. Three of them came from the round 1 fixes. The
    class was named and a structural fix proposed.
- 2026-10-02 (v3, Round 3, 213733b): 7/10 FAIL. The structural fix landed.
  - Safety 2 -> 1: step 5b's commit named no branch (from round 2 Top fix 8).
  - Worked example stayed 1.
  - Precision stayed 1: criteria 2 and 7 used the old broad "unverified", and criteria 2 and
    5 disagreed on where the confidence word goes.
  - This was the last round under the cap.
- 2026-10-02 (v4, Round 4, c2ca2a2, past the cap on the human's explicit decision): 9/10
  PASS.
  - Worked example 1 -> 2: a real RES-002 excerpt, checked word for word.
  - Safety 1 -> 2.
  - Precision stayed 1, on two closing statements about RES-002: one inaccurate, one uncited.
- 2026-10-02 (v5, Round 5, eb7e7cb, re-anchored past the cap under the round 4 decision):
  10/10 PASS, previous 9/10. Branch chore/research-rubric-and-citations.
  - Precision 1 -> 2: the closing sentence now matched RES-002 (v3), and the uncited
    threshold claim was dropped.
  - Trajectory on that branch: 8 -> 8 -> 7 -> 9 -> 10.
- 2026-10-13 (v6, Round 1 on chore/research-one-fact-rule, 246bcc9): 8/10 PASS, previous
  10/10. Scored the one-fact Claim rule and the same-fact Verified rule.
  - Worked example 2 -> 1: a compound clause under the new Claim rule, and provenance that
    was stale against RES-002 v7.
  - Precision 2 -> 1: ambiguous scope in the new nearby-fact sentence.
  - The definitions stayed single-sourced and C18 was clean.
- 2026-10-20 (v7, Round 2 on chore/research-one-fact-rule, 295631c): 9/10 PASS, previous
  8/10. The verdict line was replaced (PASS -> PASS).
  - Precision 1 -> 2: fixes 2 and 3 applied as proposed.
  - Worked example stayed 1, for a new reason: the notes are shortened below the Note
    definition, and one quote is cut without marking.
  - The history test name could not be verified from the working tree.
  - Trajectory on this branch: 8 -> 9.
