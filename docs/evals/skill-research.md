---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 81877e4
artifact_version: 16
date: 2026-10-21
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Change C, round 3, at 81877e4. The dispatcher supplied the sha. I have no shell, so I could
not run the diffs myself. The dispatcher reports that rubric.md is unchanged since 9705c4e,
that SKILL.md changed only in the report layout's Question line (the optional edit from v15,
approved by the human), and that `scripts/research-check.sh` changed how it skips link
addresses (header lines 31-37). The files on disk agree with this: SKILL.md is now 162 lines
(160 plus the two extra wrapped lines), and rubric.md is still 128.

Files read in full:
- `skills/research/SKILL.md` (162 lines)
- `skills/research/rubric.md` (128 lines)
- `scripts/research-check.sh` (343 lines), to check that step 4b still agrees with it

Also read: `docs/system-map.md:72`.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Optional v15 edit, checked
SKILL.md:60-62 now reads:
`## Question (scope, region, segment and date sensitivity where they apply,`
`   sub-questions, the decision it serves, key terms; mode and depth may sit`
`   in the frontmatter)`

What holds:
- The content is word for word what v15 proposed. Only the wrap differs (three lines, not
  two). It sits inside the shape's code fence, and the Answer and Findings lines wrap the
  same way, so the layout stays consistent.
- The first four items now match the Scoped definition (rubric.md:20, "its scope, region,
  segment and date sensitivity where they apply") in the same order and the same words.
- One name per concept (skill-authoring-standard.md:20): the bare noun "scope" now appears
  only as the first item of Scoped, at SKILL.md:25, SKILL.md:60 and rubric.md:20. The v15
  residual (it stood for the whole set at SKILL.md:60) is closed.

## Step 4b against the checker header
SKILL.md:53-56: "Cite a note only as `(note N)`, `(notes N, M)`, `(note N, <qualifier>)` with
no digit in the qualifier, or `(note N; <qualifier>)`: a parenthesis holding the word note or
notes without that number list is a violation in every section."

research-check.sh:31-42 (header) and the code agree on all points an author acts on:
- The four forms are the same. They match `NOTE_LIST` (:88), the `;` split in `cited_notes`
  (:138), and the header's "A qualifier after a comma holds no digit" (:38-39).
- The violation message (:141-144) now lists all four forms. This closes the v13 residual
  outside the folder ("lists only three of the four forms").
- "In every section" agrees with ":42, Headings, the title and the frontmatter are scanned
  too" and with `check_citations` (:248-257).
- The checker exempts three places that step 4b does not name: link addresses (the
  parenthesis right after "]", :34-35, `paren_texts` :105-127), code spans (:33-34), and the
  Notes list itself (:33). In each case step 4b is stricter than the checker, never looser.
  An author who follows step 4b can never get a citation violation from them, so this is not
  a precision finding. The header's honesty line, "a separate word "note" in a URL's own
  parentheses is a false alarm, never a miss" (:35-36), lives in the script, which is where
  it belongs.

Whether the new link-skipping code is correct is a code question for `code-reviewer`. I
judged only whether the skill text and the script header agree.

## Calibration result and the three named ambiguities
The blind paired run the v14 and v15 records recommended was carried out, according to the
dispatcher. Its result supports the change: no Scoped item gave 0 under both rubrics. The
partly scoped case was 0 under the old text, with a second reading of 1, and 1 under the new
text, with no second reading. The fully scoped case gave 2 under both. So the 0 / 1 split,
which is the auto-FAIL boundary that change C was about, now has one reading.

The new-rubric scorer named three remaining ambiguities. I judge that none must be fixed in
this change:
1. "A question that states" (rubric.md:20, 38): the question sentence, or the whole Question
   section? This is a real looseness in wording, since "question" names both. But the
   question sentence almost always states its subject, which is the scope item, so the two
   readings can split only 1 from 2, not 0 from 1. SKILL.md:60-62 now puts every Scoped item
   in the `## Question` section, which points to the section reading. This is the cheapest of
   the three to close (see Top fixes, optional).
2. No test for "where they apply": this is latitude the definition grants by design (a
   pricing scan may have no segment), so it is method, not form. It can move 1 and 2 only:
   the scope item always applies, so the 0 anchor does not depend on it.
3. Which terms are "key": step 1 (SKILL.md:26-27) leaves the author to choose them, and
   rubric.md:119-120 says when one counts as defined. Again a judgment call that moves 1 and
   2 only.

Routing all three to a later /odeo:improve is sound. That is where they belong anyway, since
each one is about how a scorer behaves, which needs a behaviour test, not a form review.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". The
  description lists triggers only, with no workflow summary, which is right for an
  auto-invoked skill.
- structure: 2, unchanged. SKILL.md is 162 lines and the rubric is 128, both under 500. The
  rubric is the only supporting file and sits one level deep. The definitions live only in
  rubric.md:6-35 ("this skill uses them and never rewords them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:105-129 is the RES-002 excerpt in the checker shape,
  and SKILL.md:130-135 explains it. This round does not touch it, and it still fits the four
  citation forms ("(notes 1, 2)", "(note 8)").
- precision: 2, unchanged. SKILL.md:60: "## Question (scope, region, segment and date
  sensitivity where they apply," now matches rubric.md:20 term for term. Step 4b agrees with
  the checker header (section above). Paths, commands, exit codes and citation forms are
  exact throughout (SKILL.md:35, 47-56, 75-78, 155).
- safety integration: 2, unchanged. SKILL.md:78: "Exit 2 means the check did not run, so say
  that and why" (Guardrails 6). SKILL.md:76-78 give a verifier and a stop: "at most three
  runs" (Guardrails 4). SKILL.md:80 calls the source-name check "a heuristic". Guardrails 1,
  3 and 7 are referenced by number (SKILL.md:82-87, 159), not restated.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached in this round. No criterion is structurally capped.

## Top fixes
None required for this verdict.

Optional, not scored, for the later /odeo:improve named by the dispatcher:
1. To close ambiguity 1, add one bullet to the scorer notes after rubric.md:120:
   `- Criterion 1: "the question" means the whole Question section, not only its first`
   `  sentence; a Scoped item stated anywhere in that section counts.`
   This edits rubric.md, so it needs its own review round, and change C has reached its
   cap of three. That is why it goes to the later run rather than into this change.

Behaviour check: done (the dispatcher's blind paired run, results above). No further
behaviour test is needed for change C.

Not scored, outside this folder (carried from v13 and still open, for the dispatcher):
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", without the `one source` label. This is not a map-duty finding, because the
  command is listed.

## Checks
- Size: SKILL.md 162 lines, rubric.md 128, both under 500. References are one level deep.
- Dashes: 0 in `skills/research/`.
- C18: rubric.md is unchanged since 9705c4e. Criterion 1 still holds no bare "unverified",
  and the fence (rubric.md:37-112) is single and closed.
- Defined terms: "scope" appears only as the first Scoped item (SKILL.md:25, 60;
  rubric.md:20).
- AGENTS.md: nothing restated. Guardrails are referenced by number.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.

## Loop status
Change C, round 3 of at most 3. Max score reached, so the loop stops here.
- Trajectory for change C: 9 -> 10 -> 10. What changed: rubric.md:38 anchor 0 now names
  Scoped (round 2), and SKILL.md:60-62 now lists the Scoped items in the report shape
  (round 3).
- Open for the human: whether to run the later /odeo:improve on the three named criterion 1
  ambiguities. The optional fix above is ready for it.

## Vs previous version
Steady: 10/10 -> 10/10. The verdict line was replaced (PASS -> PASS).
- The v15 optional edit was applied as proposed, and its residual is closed.
- The v13 residual outside the folder (the checker's message listed three forms) is closed:
  research-check.sh:141-144 lists four.
- No score moved.

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
- 2026-10-21 (v16, change C round 3, 81877e4, the last round under the cap): 10/10 PASS,
  previous 10/10. The verdict line was replaced (PASS -> PASS).
  - The v15 optional edit was applied as proposed (SKILL.md:60-62). The Question line now
    matches rubric.md:20 term for term.
  - Step 4b still agrees with the revised checker header (research-check.sh:31-42). Where
    they differ, step 4b is stricter (link addresses, code spans, the Notes list). The
    checker message now lists all four forms, which closes the v13 residual.
  - The blind paired calibration ran: the 0 / 1 split has one reading under the new rubric.
    Three named ambiguities (question sentence or section, "where they apply", "key" terms)
    move only 1 and 2, so they go to a later /odeo:improve. An optional rubric note for the
    first is ready.
  - Trajectory for change C: 9 -> 10 -> 10. Change C closed.
