---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 9705c4e
artifact_version: 15
date: 2026-10-21
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Change C, round 2, at 9705c4e. The dispatcher supplied the sha. I have no shell, so I could
not run the diffs myself. The dispatcher reports that `git diff --stat 43e7b0d 88acd30 --
skills/research/` shows only rubric.md, and that 88acd30 -> 9705c4e also touches only
rubric.md in this folder, so SKILL.md is byte-identical to 43e7b0d. I take that as the
dispatcher's evidence. It closes the round 1 uncertainty ("consistent with no change, not a
proof"), and the files on disk agree with it: SKILL.md is still 160 lines and rubric.md is
still 128, which fits a one-line edit.

Files read in full:
- `skills/research/SKILL.md` (160 lines)
- `skills/research/rubric.md` (128 lines)

Also read: `docs/system-map.md:72`.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Round 1 fix, checked
rubric.md:38 now reads, exactly as proposed:
`1. Question             0 no question, or a question that states no item of Scoped`

What holds:
- Anchor 0 now uses the defined term by name. The bare noun "scope", which is also the first
  item inside Scoped (rubric.md:20), no longer appears in the anchors, so reading (a)
  ("the scope item is missing") is gone.
- The three anchors now split on how many Scoped items are stated: none (0), some but not
  every one that applies (1, rubric.md:39, "an item of Scoped that applies is missing"),
  all that apply (2, "a scoped question"). "Only in part" is the complement of "no item",
  so there is no overlap between 0 and 1. The catch-all at rubric.md:108 still covers
  anything between 1 and 2.
- The round 1 test case, "What do tools charge in Germany?" (region stated, subject not),
  now has one reading: it states an item of Scoped, so it is not 0; an applicable item is
  missing, so it is 1.
- C18: criterion 1 holds no bare "unverified". The only hits are in Definitions
  (rubric.md:9, 34), outside the single closed fence (rubric.md:37-112).
- Dashes: 0 in `skills/research/`.

Edge case considered, not a finding: a question where no Scoped item applies would state
none and so read as 0. That cannot happen in practice, because the subject (scope) always
applies to a research question.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". Triggers
  only, no workflow summary, which is right for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md is 160 lines and the rubric 128, both under 500. The
  rubric is the only supporting file and sits one level deep. The definitions live only in
  rubric.md:6-35 ("this skill uses them and never rewords them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:104-128 is the RES-002 excerpt in the checker
  shape, and SKILL.md:129-134 explains it. Change C does not touch it.
- precision: 1 -> 2. rubric.md:38: "0 no question, or a question that states no item of
  Scoped". All three criterion 1 anchors now use the defined term, and the paths, commands,
  exit codes, citation forms and checker shape are exact throughout (SKILL.md:35, 47-56,
  74-77, 154).
- safety integration: 2, unchanged. SKILL.md:77 ("Exit 2 means the check did not run, so
  say that and why", Guardrails 6). SKILL.md:75-77 give a verifier and a stop (Guardrails
  4). SKILL.md:79 names the source-name check "a heuristic". Guardrails 1, 3 and 7 are
  referenced by number (SKILL.md:81-86, 158), not restated.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached in this round. No criterion is structurally capped.

## Top fixes
None required for this verdict.

Optional, not scored (found this round; it was already in SKILL.md at the 10/10 rounds,
since the file is unchanged since 43e7b0d):
1. SKILL.md:60, the report shape, lists the Question section as "(scope, sub-questions, the
   decision it serves, key terms; ...)". Here "scope" stands for the whole Scoped set, while
   step 1 (SKILL.md:25) and rubric.md:20 use it for one item. An author who follows the
   shape alone could leave out region, segment and date sensitivity and score 1 on
   criterion 1. Step 1 already asks for all four, so the scorer's reading does not change,
   which is why this is not scored. If you want the two files to use one name per concept
   (skill-authoring-standard.md:20), rewrite the line to:
   `## Question (scope, region, segment and date sensitivity where they apply, sub-questions,`
   `   the decision it serves, key terms; mode and depth may sit in the frontmatter)`

Behaviour check: the paired pm-reviewer scoring recommended in round 1 (criterion 1 on three
Question sections, old rubric against new, through /odeo:improve) still applies, because the
change can turn a 0 into a 1, and a 0 is an automatic FAIL. Fix 1 has landed, so the check
would now measure the final text. The dispatcher reports it has not been run and that the
human decides on it. It does not block this verdict, which judges form.

Not scored, outside this folder (carried from v13 and still open, for the dispatcher):
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", without the `one source` label. This is not a map-duty finding, because the
  command is listed.

## Checks
- Size: SKILL.md 160 lines, rubric.md 128, both under 500. References are one level deep.
- Dashes: 0 in `skills/research/`.
- C18: clean. Criterion 1 holds no bare "unverified", and the fence is single and closed.
- Defined terms: criterion 1 anchors 0, 1 and 2 all use Scoped. The bare noun "scope"
  survives only in SKILL.md:25 (as the first item, correct) and SKILL.md:60 (optional item
  above).
- AGENTS.md: nothing restated. Guardrails are referenced by number.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.

## Loop status
Change C, round 2 of at most 3. Max score reached, so the loop stops here.
- Trajectory for change C: 9 -> 10. What changed: rubric.md:38 anchor 0 now names Scoped.
- Open for the human: whether to run the paired scoring check, and whether to apply the
  optional SKILL.md:60 edit (applying it would need one more review round, still under the
  cap).

## Vs previous version
Improved: 9/10 -> 10/10. The verdict line was replaced (PASS -> PASS).
- Precision 1 -> 2: round 1 Top fix 1 applied as proposed.
- No other score moved. SKILL.md is byte-identical to 43e7b0d (dispatcher's diff).

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
- 2026-10-21 (v15, change C round 2, 9705c4e): 10/10 PASS, previous 9/10. The verdict line
  was replaced (PASS -> PASS).
  - Precision 1 -> 2: anchor 0 now reads "a question that states no item of Scoped", so
    criterion 1's anchors split on how many Scoped items are stated.
  - The dispatcher's diff confirms that SKILL.md is byte-identical to 43e7b0d, which closes
    the v14 uncertainty.
  - Optional, not scored: SKILL.md:60 uses "scope" for the whole Scoped set.
  - Paired scoring check still recommended; the human decides.
  - Trajectory for change C: 9 -> 10. Max reached, loop stopped.
