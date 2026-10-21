---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 88acd30
artifact_version: 14
date: 2026-10-21
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 10/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Change C, round 1, at 88acd30. The dispatcher supplied the sha. I have no shell, so I could
not run `git diff 43e7b0d 88acd30`. I scored the files on disk and took the dispatcher's
word on what the diff contains.

Files read in full:
- `skills/research/SKILL.md` (160 lines)
- `skills/research/rubric.md` (128 lines, one more than the 127 at 43e7b0d, which fits the
  criterion 1 anchor growing from two lines to three)

Also read: `scripts/skills-lint.sh:304-324` (C18) and `docs/system-map.md:72`.

SKILL.md unchanged: I cannot prove this without a diff. What I can say is that it is still
160 lines, and every line the v13 record quotes (2, 10-11, 52-56, 74-77, 79, 81-86,
104-128, 154, 158) reads the same at those line numbers. That is consistent with no change.
It is not a proof.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Change C, checked
The new criterion 1 anchors (rubric.md:38-43):
- 0: "no question, or a question with no scope at all"
- 1: "scoped only in part (an item of Scoped that applies is missing), or sub-questions,
  mode, depth or the decision it serves are missing, or a key term in it is undefined"
- 2: "a scoped question, its sub-questions, mode, depth, the decision it serves, and its key
  terms defined"

What holds:
- Anchor 1 uses the defined term by name ("an item of Scoped that applies") and does not
  reword it. "Applies" mirrors the definition's "where they apply" (rubric.md:20-21), so the
  RES-002 case (scoped by product, not by date) now scores 1 on the text, not only on a
  reading of it.
- No gap between 1 and 2. Anchor 2 requires a fully Scoped question. A partial one falls
  under anchor 1, and anything else falls under the catch-all at rubric.md:108 ("meets none
  of its 0 conditions and misses any of its 2 conditions scores 1").
- The 0 and 1 overlap is resolved. A question with no scope also lacks "an item of Scoped",
  but rubric.md:108 tests the 0 conditions first, and "only in part" implies some part is
  present.
- C18: no bare lowercase "unverified" inside the fence. The only hits, rubric.md:9 and 34,
  are in Definitions, outside the fence that opens at :37. The fence is still single and
  closed.
- Dashes: no em or en dashes in `skills/research/` (grep count 0).
- The Scoped definition's pointer "(the first four items of step 1 in the research skill)"
  still matches SKILL.md:25-26: scope, region, segment, date sensitivity.

What does not hold: anchor 0 says "no scope at all", not the defined term. "Scope" is
also the name of the FIRST ITEM inside Scoped ("states its scope, region, segment and date
sensitivity", rubric.md:20). So the 0 anchor can be read two ways:
- (a) the scope item is missing, which scores 0;
- (b) no item of Scoped is stated, which scores 0 only when nothing is scoped.

The two readings give different scores for a plausible vague question. Take "What do tools
charge in Germany?": region is stated, the subject is not. Reading (a) gives 0, a FAIL
under the no-zero rule. Reading (b) gives 1. This is the same kind of 0-versus-1 split
change C set out to close, moved to the other side of anchor 1. It maps to the standard's
"consistent terminology (one name per concept, everywhere)" (skill-authoring-standard.md:20),
not to taste.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". It lists
  triggers only and gives no workflow summary, which is right for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md is 160 lines and the rubric 128, both under 500. The
  rubric is the only supporting file and sits one level deep. The definitions live only in
  rubric.md:6-35 ("this skill uses them and never rewords them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:104-128 is the RES-002 excerpt in the checker
  shape, and SKILL.md:129-134 explains it. Change C does not touch the Question section the
  example leaves out.
- precision: 2 -> 1. Rubric.md:38: "0 no question, or a question with no scope at all". The
  bare noun "scope" is an item of Scoped, so the 0 anchor reads two ways (above). Everything
  else is still exact: paths, commands, exit codes, the citation forms and the checker shape
  (SKILL.md:35, 47-56, 74-77, 154).
- safety integration: 2, unchanged. SKILL.md:77 ("Exit 2 means the check did not run, so
  say that and why", Guardrails 6). SKILL.md:75-77 give a verifier and a stop (Guardrails
  4). SKILL.md:79 names the source-name check "a heuristic". Guardrails 1, 3 and 7 are
  referenced by number (SKILL.md:81-86, 158), not restated.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reachable. No criterion is structurally capped. One edit to rubric.md:38 closes
the gap. The maximum is not reached in this round.

## Top fixes
1. Rewrite rubric.md:38 to use the defined term, so 0, 1 and 2 split on how many Scoped
   items are stated:
   `1. Question             0 no question, or a question that states no item of Scoped`
   With this, 0 means none stated, 1 means some (anchor 1, unchanged), and 2 means all that
   apply. Anchor 1 then also reads cleanly, because "only in part" is the complement of
   "no item".

Does change C need an A/B test? Not a full one. It writes down a reading pm-reviewer
already applied (RES-002 round 4 scored 1), so a blind A/B on that report would mostly
show both texts scoring 1, which tells us little. But the change can move a 0 to a 1, and a
0 is an automatic FAIL, so the edit can turn a FAIL into a PASS. It is therefore a
behavioural rubric change, and per skill-authoring-standard.md:85 it goes through
/odeo:improve. A proportionate check is one paired pm-reviewer scoring of criterion 1 on
three Question sections, old rubric against new:
- one with no Scoped item;
- one missing an applicable item (RES-002's, with no date);
- one fully Scoped.

The expected result is 0/0, 0-or-1/1 and 2/2. Run it after fix 1 lands, so the test
measures the final text. This is a recommendation and does not block this verdict, which
judges form.

Not scored, outside this folder (carried from v13 and still open, for the dispatcher):
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", without the `one source` label. This is not a map-duty finding, because the
  command is listed.

## Checks
- Size: SKILL.md 160 lines, rubric.md 128, both under 500. References are one level deep.
- Dashes: 0 in `skills/research/`.
- C18: clean. Criterion 1 holds no bare "unverified", and the fence is single and closed.
- Defined terms: anchor 1 uses Scoped by name. Anchor 0 uses the bare noun "scope", which
  is the precision finding above.
- AGENTS.md: nothing restated. Guardrails are referenced by number.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.

## Loop status
Change C, round 1 of at most 3. One actionable fix remains (fix 1), so the loop continues:
apply it, then re-dispatch this reviewer at the new sha.
- Trajectory for change C: 9.

This is a form review only. Whether scorers actually split 0 and 1 this way is a behaviour
question for /odeo:improve (see the paired scoring above).

## Vs previous version
Regressed: 10/10 -> 9/10. The verdict stays PASS.
- Precision 2 -> 1. Change C fixed the 0-versus-1 reading at anchor 1 but introduced the
  bare "scope" at anchor 0, and that noun collides with the first item of Scoped.
- No other score moved. SKILL.md appears unchanged (same line count and same quoted lines,
  not proven by a diff).

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
  - Worked example stayed 1, for a new reason: the notes were shortened below the Note
    definition, and one quote was cut without marking.
  - The history test name could not be verified from the working tree.
- 2026-10-20 (v8, Round 3 on chore/research-one-fact-rule, f3b6fce, the last round under the
  cap): 10/10 PASS, previous 9/10. The verdict line was replaced (PASS -> PASS).
  - Worked example 1 -> 2: notes 1 and 2 copied word for word from RES-002:180-187, and the
    test name confirmed by the dispatcher's `git log -S` result (03d1739 introduced, 64df14e
    removed).
  - The human kept change A after a blind A/B; that decision is recorded in the dispatcher's
    ledger.
  - Trajectory on this branch: 8 -> 9 -> 10. Change A closed.
- 2026-10-20 (v9, change B round 1, 25b2a85): 8/10 PASS, previous 10/10. The verdict line
  was replaced (PASS -> PASS).
  - Scored the source cache (step 3), the checker shape (step 4b) and the
    `research-check.sh` step (step 5b).
  - Worked example 2 -> 1: the example is not in the checker shape and has no terms
    comment.
  - Precision 2 -> 1: the `### Notes` heading is missing, the instruction on how many
    sources go in a note conflicts, and "key terms" names two concepts.
  - Rubric definitions were not reworded.
- 2026-10-20 (v10, change B round 2, 56ded01): 9/10 PASS, previous 8/10. The verdict line
  was replaced (PASS -> PASS).
  - Worked example 1 -> 2: RES-002 layout, terms comment, notes 1, 2 and 8 identical to the
    source.
  - Precision stayed 1. The round 1 items are closed. New: the unclear "it" in the optional
    heuristic sentence (SKILL.md:73), and findings called verbatim without their trailing
    periods.
  - Residual outside the folder: research-check.sh:168 still says "key term".
- 2026-10-20 (v11, change B round 3, 053f4ef, the last round under the cap): 9/10 PASS,
  previous 9/10. The verdict line was replaced (PASS -> PASS).
  - Both round 2 fixes verified as applied; the script's "key term" message is now "quote
    term".
  - Precision stayed 1, for a new reason: step 4b's stated shape omits the checker's
    quote-delimiter rules (straight double quotes or backticks only, typographic marks
    refused, quotes must pair), which collide with localized reports.
  - Trajectory for change B: 8 -> 9 -> 9. Cap reached; the residual goes to the human.
- 2026-10-21 (v12, change B round 4, eadb831, past the cap on the human's explicit
  authorization): 10/10 PASS, previous 9/10. The verdict line was replaced (PASS -> PASS).
  - Precision 1 -> 2: step 4b now states the quote delimiters, the handling of typographic
    marks (refused outside a quote, allowed inside) and the three citation forms. All agree
    with research-check.sh:25-36 and its code.
  - Optional, not scored: keep the step 5b command on one line, and add U+201D to the listed
    marks.
  - Trajectory for change B: 8 -> 9 -> 9 -> 10. Change B closed.
- 2026-10-21 (v13, change B round 5, 43e7b0d, past the cap on the human's explicit
  authorization): 10/10 PASS, previous 10/10. The verdict line was replaced (PASS -> PASS).
  - Both v12 optional edits verified as applied: U+201D is in the step 4b list, and the step
    5b command sits on one line in one code span.
  - Step 4b now lists four citation forms, adding `(note N; <qualifier>)` and the rule that a
    comma qualifier holds no digit. It agrees with research-check.sh:33-38, `NOTE_LIST` (:84)
    and `cited_notes` (:122). The RES-002 example still fits.
  - Outside the folder, not scored: the checker's violation message (:125-126) lists only
    three of the four forms.
  - Trajectory for change B: 8 -> 9 -> 9 -> 10 -> 10. Change B closed.
- 2026-10-21 (v14, change C round 1, 88acd30): 9/10 PASS, previous 10/10. The verdict line
  was replaced (PASS -> PASS).
  - Scored the new rubric criterion 1 anchors. Anchor 1 uses Scoped by name, there is no
    gap or overlap between 1 and 2, C18 is clean, and there are no dashes.
  - Precision 2 -> 1: anchor 0's "no scope at all" uses the bare noun "scope". That is also
    the first item of Scoped, so a question with a region but no subject scores 0 or 1
    depending on the reading.
  - A/B: a full one is not needed. A paired three-case pm-reviewer scoring through
    /odeo:improve is recommended after the fix.
  - Trajectory for change C: 9.
