---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 16c6cc5
artifact_version: 17
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

Re-anchor at 16c6cc5, requested because merge-gate refused the v16 record (anchored at
81877e4) after non-eval files changed. The dispatcher supplied the sha. I have no shell, so I
could not run the diff myself. The dispatcher reports that `git diff --stat 81877e4 16c6cc5`
outside `docs/evals` lists only README.md, `scripts/research-check.sh` and
`tests/research-check.test.sh`, so nothing under `skills/research/` changed. The script
change (57daa41): a parenthesis right after "]" is now read as a citation, not skipped as a
link address, when it starts with the word note or notes and whitespace.

Files read this round:
- `skills/research/SKILL.md` in full (161 lines)
- `scripts/research-check.sh:1-170` (header, `NOTE_LIST`, `paren_texts`, `cited_notes`)
- `docs/system-map.md` (grep for research, :72)

`skills/research/rubric.md` was not re-read in full: it is unchanged per the dispatcher's
diff, and its line count is 127. Line counts this round come from the Read and Grep tools;
v16 gave 162 and 128, an off-by-one in my earlier count, not a change in the files.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Step 4b against the revised checker header
SKILL.md:53-56: "Cite a note only as `(note N)`, `(notes N, M)`, `(note N, <qualifier>)` with
no digit in the qualifier, or `(note N; <qualifier>)`: a parenthesis holding the word note or
notes without that number list is a violation in every section."

research-check.sh:31-43 (header) and the `paren_texts` docstring (:107-112) now say: "a link
address, the parenthesis right after "]" unless it starts with "note " or "notes ", is
skipped". The code matches: `link` is false when the text after "(" matches
`[ \t]*notes?\s` (:117-118).

What holds:
- The four citation forms are unchanged and still agree: `NOTE_LIST` (:89), the `;` split in
  `cited_notes` (:142), the header's "A qualifier after a comma holds no digit" (:39-40), and
  the violation message (:145-148), which lists all four.
- "In every section" still agrees with the header's "Headings, the title and the frontmatter
  are scanned too" (:42-43).
- The change NARROWS the checker's one link-address exemption: a parenthesis after "]" that
  opens with note or notes is now read like any other. Step 4b exempts no parenthesis at all,
  so the checker moved toward step 4b, not away from it. The round-3 conclusion stands, and
  is now tighter: wherever the two differ (link addresses whose text does not open with
  note, code spans, the Notes list), step 4b is the stricter one. An author who follows
  step 4b can never get a citation violation the skill did not warn about.
- No sentence of SKILL.md describes link-address handling, so there is nothing in the skill
  that the change made stale.

Not mine, for `code-reviewer`: the header says "note " / "notes " (a space), while the code
accepts leading spaces or tabs, any case, and any whitespace after the word, including a
newline. The docstring's "the word note or notes and a space" has the same simplification.
That is header-versus-code accuracy inside the script, a code question; it does not touch
step 4b, which says nothing about link addresses.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". Triggers
  only, no workflow summary, right for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md 161 lines, rubric.md 127, both under 500; the rubric is
  the only supporting file and sits one level deep. Definitions live only in the rubric
  ("this skill uses them and never rewords them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:105-129 is the RES-002 excerpt in the checker shape,
  explained at :130-135. Its citations, "(notes 1, 2)" and "(note 8)", fit the four forms, and
  it holds no link after "]", so the script change cannot affect it.
- precision: 2, unchanged. SKILL.md:53-56 agrees with the revised header (section above).
  SKILL.md:60-62, "## Question (scope, region, segment and date sensitivity where they
  apply,", still matches rubric.md:20 term for term. Paths, commands, exit codes and citation
  forms are exact (SKILL.md:35, 47-56, 75-78, 155).
- safety integration: 2, unchanged. SKILL.md:78: "Exit 2 means the check did not run, so say
  that and why" (Guardrails 6). SKILL.md:76-78: "at most three runs" (Guardrails 4).
  SKILL.md:80 names the source-name check "a heuristic". Guardrails 1, 3 and 7 are referenced
  by number (SKILL.md:82-87, 159), not restated.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10, reached. No criterion is structurally capped.

## Top fixes
None required for this verdict.

Carried, optional, not scored (unchanged from v16):
1. For the later /odeo:improve on criterion 1 ambiguity 1, add after rubric.md:120:
   `- Criterion 1: "the question" means the whole Question section, not only its first`
   `  sentence; a Scoped item stated anywhere in that section counts.`

Outside this folder, not scored:
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", without the `one source` label (carried from v13). Not a map-duty finding:
  the command is listed.
- research-check.sh header and docstring say "a space" where the code accepts any
  whitespace and leading blanks (see above), for `code-reviewer`.

Behaviour check: not needed. This round changed no skill text.

## Checks
- Size: SKILL.md 161 lines, rubric.md 127, both under 500. References one level deep.
- Dashes: 0 em or en dashes in `skills/research/`.
- C18: rubric.md unchanged since 9705c4e per the dispatcher's diff.
- AGENTS.md: nothing restated; Guardrails referenced by number.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.

## Loop status
Re-anchor only, not a new review round of change C (which closed at v16). No file under
`skills/research/` changed, no score moved, so the loop has nothing to iterate.

## Vs previous version
Steady: 10/10 -> 10/10. The verdict line was replaced (PASS -> PASS) and `reviewed_commit`
moved from 81877e4 to 16c6cc5.
- Skill folder unchanged per the dispatcher's diff.
- Step 4b checked again against the revised checker header: still agrees, and the change
  narrows the gap between them.
- Line counts corrected to what the tools report (161 and 127, v16 said 162 and 128).

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
- 2026-10-21 (v17, re-anchor at 16c6cc5 after merge-gate refused v16): 10/10 PASS, previous
  10/10. The verdict line was replaced (PASS -> PASS).
  - No file under `skills/research/` changed since 81877e4, per the dispatcher's diff.
  - The script change 57daa41 (a parenthesis after "]" opening with note or notes is read
    as a citation) narrows the checker's link exemption. Step 4b (SKILL.md:53-56) still
    agrees with the header (research-check.sh:31-43) and remains the stricter of the two.
  - Line counts corrected to 161 and 127 (v16 said 162 and 128).
  - For code-reviewer, not scored: the header's "a space" is narrower than the code's
    `[ \t]*notes?\s`.
