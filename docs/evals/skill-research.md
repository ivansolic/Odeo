---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 246bcc9
artifact_version: 6
date: 2026-10-13
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 1, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
previous_total: 10/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Round 1 on this branch, at 246bcc9 (the commit the dispatcher supplied; I have no shell and
cannot confirm it, so I scored the files on disk, which the dispatcher reports as a clean
tree at that commit). The change under test: the rubric's Claim definition (one fact per
claim), its Verified definition (both notes quote that same fact; a nearby fact leaves it
one source), and SKILL.md step 4b pointing at them. Motivating evidence:
`docs/evals/RES-002.md`, rounds 5 to 7, one defect class ("stated confidence stronger than
the shown evidence").

Files read in full: `skills/research/SKILL.md` (119 lines), `skills/research/rubric.md`
(125 lines, was 121). Also read: `docs/research/RES-002-platform-support.md` (v7, 471
lines), because the worked example quotes it; `docs/evals/RES-002.md`; the C18 block of
`scripts/skills-lint.sh`; `docs/system-map.md` line 72. Model tier: strongest, as
dispatched; the live lineup could not be re-checked from this agent (no web access).

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2, "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, ...". Correct format for an
  auto-invoked skill, with the user's own words ("is it true that...").
- structure: 2, unchanged. SKILL.md:9-11, "defined once, in the Definitions of
  `${CLAUDE_PLUGIN_ROOT}/skills/research/rubric.md`; this skill uses them and never rewords
  them". 119 lines; the rubric is the only supporting file, one level deep.
- worked example: 1 (was 2). Two defects, both at SKILL.md:80-93.
  - The clause it models is two claims under the NEW Claim definition. SKILL.md:84-85, "users
    must approve plugin hooks before they run, apparently again whenever a hook changes (one
    source, note 2)". That joins two facts (approval before running; approval again after a
    change) under one confidence word. "apparently" is not one of the confidence words.
    rubric.md:10-11 now says: "a sentence that joins two facts ... is two claims, and each
    carries its own confidence word". Step 4b says "one fact per claim". Copying the example
    reproduces the compound-claim pattern that RES-002 round 5 found and that this commit
    exists to prevent. Round 2 set the precedent: an unchanged example that breaks a new rule
    drops to 1.
  - Its statements about RES-002 are no longer true of the RES-002 in this repo (v7).
    - SKILL.md:81, "The note and its quote are verbatim from it": the quote is verbatim, but
      it now sits in note 5 (RES-002:204, "lines 406 to 408"), at
      "developers.openai.com/codex/hooks.md (redirects to learn.chatgpt.com/docs/hooks.md)".
      Note 2 is now the Codex `marketplace_cmd.rs` source (RES-002:184).
    - SKILL.md:82-83, "which RES-002 itself did not do": v7 writes a confidence word on every
      claim, for example RES-002:86, "F8 Codex runs a non-managed hook only after the user
      trusts it. **Verified** (notes 5, 7)."
    - SKILL.md:91-93, "the sources behind most of its table cells were not kept": v7 says
      "Each cell names its finding" (RES-002:164-165), and every cell does.
    - This drift did not come from 246bcc9. It came from RES-002 v4 to v7 landing on this
      branch's history. Round 5 checked these sentences against v3, where they were true.
- precision: 1 (was 2). The new Verified sentence is ambiguous at the exact boundary it was
  written to decide. rubric.md:28-30: "A quote of a nearby fact does not count: a field name,
  a test name, a string in a binary or a related sentence that only implies the claim leaves
  it one source."
  - Reading A: "that only implies the claim" qualifies all four items. Then a field name
    that states the claim counts.
  - Reading B: it qualifies only "a related sentence". Then every field-name, test-name or
    binary-string quote is one source, whatever it states.
  - The Independent sources definition (rubric.md:14-15) supports Reading A, since shipped
    code counts "when each states the claim itself".
  - The two readings score real evidence differently. Under Reading B these Verified
    findings in RES-002 v7 lose their second source: F5, whose code quote is the enum
    variants `SessionStart`, `SubagentStart` (RES-002:207-208); F7b, `rename =
    "additionalContextLimit"` (RES-002:212); and arguably F2 and F15b, whose quotes are
    constants (RES-002:189, 304).
  - Two scorers can therefore split on the claims this commit was written for. That is a
    vague boundary term, the same kind of finding round 1 docked under precision.
  - Everything else is exact: paths, script names, the RES-NNN rule, the editor commands.
- safety integration: 2, unchanged. SKILL.md:60-65: step 5b commits "on a branch (on
  `main`, ask the human to create one first: Git discipline in
  `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`)", hands the sha and `output_language` "(Guardrails 1 and
  7 ...)", and loops under "Guardrails 3, with its stop condition". SKILL.md:108-109 points
  at the honesty guardrail. Neither file restates a guardrail.

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no zero)

PASS exactly at the threshold, with no criterion at 0. The loop's stop condition 1 is met,
but this is below max, so the three things owed below max follow (Ceiling, residuals, open
decision).

## Ceiling
10/10 is reachable. No criterion caps structurally for this skill. Both 1s are text fixes
inside `skills/research/`.

## The specific checks the dispatcher asked for
- **Single definitions, no rewording (C18 and "defined once"): holds, with one missing
  pointer.**
  - Step 4b points at "the rubric's Claim definition", "the rubric's Note definition" and
    "the rubric's Confidence words" (SKILL.md:38-42).
  - "one fact per claim" and "quote that fact from both sources, not a nearby one" compress
    rubric.md:10-11 and 26-30 without changing their meaning. I found no drift.
  - The second clause is the only one with no pointer. It paraphrases the Verified
    definition but does not name it (fix 3).
  - C18: rubric.md has exactly two fences (lines 36 and 110). Lowercase "unverified" occurs
    only at lines 9 and 33, both in Definitions, outside the fence. Clean.
- **Worked example vs the new definitions: inconsistent.** See worked example above. It
  models a two-fact clause under one confidence word, and its provenance sentences describe
  RES-002 v3, not the v7 in the repo.

## Top fixes
1. **Worked example (SKILL.md:79-93), rebase it on RES-002 v7 and make it obey the Claim
   definition.**
   - Replace the Answer clause with two claims, each with its own word. Keep the quote, but
     cite note 5:
     - "users must approve plugin hooks before they run (one source, note 5)"
     - "whether that approval repeats after every hook change is unverified, an inference
       from 'the current hook definition'"
   - Add one Verified line that shows both notes quoting the same fact. The cleanest pair in
     v7 is F1 (RES-002:72-73), with note 1 "Use `codex plugin marketplace add` to add and
     track a marketplace source" and note 2's help text "codex plugin marketplace add
     https://github.com/owner/repo".
   - Change "Note 2: developers.openai.com/codex/hooks" to "Note 5:
     developers.openai.com/codex/hooks.md".
   - Delete "which RES-002 itself did not do" and the closing sentence about table cells,
     or reword them as history: "an earlier version (v3) wrote no confidence words and kept
     no sources for most table cells; v4 to v7 fixed both."
2. **Verified definition (rubric.md:28-30), remove the scope ambiguity.** Proposed text:
   "A quote of a nearby fact does not count: a quote that only names a field, test or string,
   or a related sentence, without itself stating the claim, leaves it one source. A code,
   binary or changelog quote that states the claim itself counts (Independent sources)."
   This keeps one definition and makes it agree with rubric.md:14-15.
3. **Step 4b (SKILL.md:39-40), add the missing pointer.** After "not a nearby one", insert
   "(the rubric's Verified definition)". Then each defined term in 4b is cited where it is
   used, as SKILL.md:9-11 promises.
4. Outside this skill folder, not scored: `docs/system-map.md:72` says "every claim 2+
   independent sources or labeled unverified". In the rubric, "unverified" now means no
   nameable source, and "one source" is a separate label. Suggested map text: "every claim
   verified by 2+ independent sources or labeled one source or unverified".

## Checks
- Size: SKILL.md 119 lines, rubric 125. Under 500 lines; references are one level deep.
- Dashes: none in either file.
- AGENTS.md: nothing restated.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md` (line 72); see fix 4
  for a wording drift there.
- Integrity: first-party skill, so no copied-text check applies.

## Loop status and open decision
- The form gate passes at 8/10. Re-dispatch this reviewer after fixes 1 to 3 to reach
  10/10. That would be round 2 of 3 on this branch.
- Not covered by this gate: the change is behavioural. Whether "one fact per claim" and the
  same-fact quote rule actually stop the compound-verified pattern needs `/odeo:improve`
  subagent testing (baseline vs variant, with RES-002-style material). A form PASS is not
  evidence that the behaviour changed.
- RES-002's 16/16 (round 8, `921f906`) was scored against the rubric before this commit. If
  fix 2 lands as Reading B, that record would need re-scoring. Under Reading A, the fix
  proposed above, it should hold.
- Human decision: apply fixes 1 to 3 and re-review, or accept 8/10 with the residuals as
  listed.

## Vs previous version
Worse: 10/10 -> 8/10. The verdict stays PASS.
- worked example 2 -> 1:
  - The new Claim definition makes the example's compound clause non-conforming.
  - Separately, RES-002 moved to v7 under it, which made three provenance statements false.
    That second cause is not from 246bcc9.
- precision 2 -> 1: introduced by 246bcc9. The new Verified sentence scopes "that only
  implies the claim" ambiguously.
- No change: trigger clarity 2, structure 2, safety integration 2.
- The change itself is sound in form: one definition each, pointed at from SKILL.md, and
  C18 is clean.

## History
- 2026-10-02 (v1, Round 1, f947223): first record. 8/10 PASS. Structure 1 (SKILL.md did
  not name or dispatch the rubric, the shapes diverged), precision 1 (undefined boundary
  terms, anchors that left some cases unscored).
- 2026-10-02 (v2, Round 2, 914009a): 8/10 PASS. Structure 1 -> 2. Worked example 2 -> 1 (the
  unchanged example broke the new Answer rule). Precision 1 -> 1 with new conflicts, three
  introduced by the round 1 fixes; the class was named and a structural fix proposed.
- 2026-10-02 (v3, Round 3, 213733b): 7/10 FAIL. The structural fix landed. Safety 2 -> 1
  (step 5b's commit named no branch, from round 2 Top fix 8). Worked example stayed 1.
  Precision stayed 1 (criteria 2 and 7 used the old broad "unverified"; criteria 2 and 5
  disagreed on where the confidence word goes). This was the last round under the cap.
- 2026-10-02 (v4, Round 4, c2ca2a2, past the cap on the human's explicit decision): 9/10
  PASS. Worked example 1 -> 2 (real RES-002 excerpt, verified verbatim). Safety 1 -> 2.
  Precision stayed 1 on two closing statements about RES-002, one inaccurate and one uncited.
- 2026-10-02 (v5, Round 5, eb7e7cb, re-anchor past the cap under the round 4 decision):
  10/10 PASS, previous 9/10. Precision 1 -> 2: the closing sentence now matched RES-002 (v3)
  and the uncited threshold claim was dropped. Branch chore/research-rubric-and-citations.
  Trajectory there: 8 -> 8 -> 7 -> 9 -> 10.
- 2026-10-13 (v6, Round 1 on chore/research-one-fact-rule, 246bcc9): 8/10 PASS, previous
  10/10. Scored the one-fact Claim rule and the same-fact Verified rule.
  - Worked example 2 -> 1: compound clause under the new Claim rule, and provenance that is
    stale against RES-002 v7.
  - Precision 2 -> 1: ambiguous scope in the new nearby-fact sentence.
  - The definitions stay single-sourced and C18 is clean.
