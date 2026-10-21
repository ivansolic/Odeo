---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 43e7b0d
artifact_version: 13
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

Round 5 of change B on this branch, at 43e7b0d. This round goes past the 3-round cap
because the human explicitly authorized it. The dispatcher supplied the sha. I have no
shell, so I could not confirm it or run `git diff eadb831 43e7b0d`. I scored the files on
disk and took the dispatcher's word on what the diff contains. The dispatcher asked for a
PASS; the verdict below is my own reading of the files, not that request.

Files read in full:
- `skills/research/SKILL.md` (160 lines)
- `skills/research/rubric.md` (127 lines)
- `scripts/research-check.sh` lines 1-239 (header, citation parsing, note parsing, header
  check, Verified check). I read it only to compare the shape the checker parses with the
  shape the skill states. The script itself belongs to code-reviewer.

Also read: `docs/system-map.md:72`, `agents/skill-reviewer.md:5` (`effort: high`).

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Round 4 optional edits and the citation change, verified
- Typographic marks. SKILL.md:52-53: "never in typographic marks („ “ ” « »)". That is five
  marks, the same five as `TYPOGRAPHIC = "“”„«»"` (research-check.sh:82) and the header list
  "U+201C, U+201D, U+201E, U+00AB, U+00BB" (:26-27). They agree.
- Step 5b command. SKILL.md:74 is one line inside one code span:
  `${CLAUDE_PLUGIN_ROOT}/scripts/research-check.sh <report> --sources ~/.cache/odeo/research/RES-NNN`.
  A raw copy now keeps `--sources`.
- Citation forms. SKILL.md:54-56: "Cite a note only as `(note N)`, `(notes N, M)`,
  `(note N, <qualifier>)` with no digit in the qualifier, or `(note N; <qualifier>)`: a
  parenthesis holding the word note or notes without that number list is a violation in
  every section." The script header at :33-38 says "optionally then ", <qualifier>" or
  "; <qualifier>" ... A qualifier after a comma holds no digit ...; one with a digit follows
  ";"", and the code does the same: `NOTE_LIST` (:84) allows `,\s*\D[^\d]*` after the
  number list, and `cited_notes` (:122) cuts the segment at the first `;` or `)`, so a
  qualifier after `;` is never parsed as part of the number list. All four forms the skill
  offers pass the checker, and "every section" matches "every parenthesis outside the Notes
  list is scanned" (:33). They agree.
- The skill is still stricter than the checker in one place: the checker also accepts a
  qualifier after a list (`(notes 1, 2, measured)`), which the skill does not offer. A writer
  who follows the skill never trips the checker, so this is safe.
- Worked example (SKILL.md:104-128), traced by reading, not run. It is unchanged since
  round 4. Its citations `(notes 1, 2)` and `(note 8)` are the first two forms. Notes 1, 2
  and 8 each have the comma and the `: ` before the first `"` (`header()`, :155-162), no
  typographic mark, and an even count of `"` (2, 6 and 6). Both F1 terms
  (`codex plugin marketplace add`, `github`) sit inside one quote of note 1 (the line 191
  example) and of note 2 (the `owner/repo` help text). The parentheses inside note 8
  (`(`bin/` row)`, `(redirects to ...)`) hold no "note" word once code spans are removed.
  The example still fits.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". Triggers
  only, no workflow summary, which is right for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md is 160 lines, the rubric 127, both under 500. The rubric
  is the only supporting file and sits one level deep. The checker is called by path
  (SKILL.md:74) and not rewritten in the body. The definitions live only in rubric.md:6-35
  ("this skill uses them and never rewords them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:104-128 is a fenced RES-002 excerpt in the checker
  shape and still passes every rule step 4b now states, as traced above. SKILL.md:129-134
  explains both labels and the failure the rules prevent.
- precision: 2, unchanged, and the round 4 residuals are closed. Step 4b gives the full
  checker shape with no gap I could find against the script: claim line, terms comment, note
  header, quote delimiters, the full typographic set, and all four citation forms, including
  the digit rule ("`(note N, <qualifier>)` with no digit in the qualifier, or
  `(note N; <qualifier>)`", SKILL.md:54-55). Paths, commands and exit codes are exact
  (SKILL.md:35, 58, 74-77, 154). The only placeholders are the template slots `<report>`,
  `NNN`, `<slug>` and `<qualifier>`, each defined where it appears.
- safety integration: 2, unchanged.
  - SKILL.md:77: "Exit 2 means the check did not run, so say that and why" (Guardrails 6).
  - SKILL.md:75-77: a verifier (the exit code) and a stop (three runs), with leftover
    violations handed to the reviewer (Guardrails 4).
  - SKILL.md:79: the name check is "a heuristic" (Guardrails 6).
  - Git discipline and Guardrails 1, 3 and 7 are referenced by name and number
    (SKILL.md:81-86, 158), not restated.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reached. No criterion is structurally capped.

## Top fixes
None required in this folder.

Not scored, outside this folder (the script belongs to code-reviewer):
1. research-check.sh:125-126, the violation message says "write (note N), (notes N, M) or
   (note N, <qualifier>)". It leaves out `(note N; <qualifier>)`, the one form a writer needs
   when the qualifier holds a digit. Add it so the message lists the same four forms as
   SKILL.md:54-55. The message is a subset, not a contradiction, so the skill score does not
   move.
2. `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
   unverified", without the `one source` label. The dispatcher already routed this as a
   separate change. It is not a map-duty finding, because the command is listed.

## Checks
- Size: SKILL.md 160 lines, rubric.md 127, both under 500. References are one level deep.
- Dashes: no em or en dashes in `skills/research/` (grep count 0).
- AGENTS.md: nothing restated. Guardrails are referenced by number.
- Skill and script header agree on the note header, the quote delimiters, the five
  typographic marks, the four citation forms with the digit rule, and the every-section scan.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.
- Rubric definitions: not reworded. Step 4b refers to Claim, Note, Verified and the
  Confidence words by name.

## Loop status
Round 5 of change B, past the cap with the human's authorization. The maximum holds
(10/10 PASS), so the loop ends here.
- Trajectory for change B: 8 -> 9 -> 9 -> 10 -> 10.
- What changed: round 1 closed the missing `### Notes` heading, the conflicting
  note-source instruction and the double-named "key terms". Round 2 fixed the example's
  layout and its terms comment. Round 3 fixed the unclear "it" and the dropped trailing
  periods. Round 4 added the quote delimiters and the citation forms to step 4b. Round 5
  (this round) applied both optional edits and brought the `;` citation form and the digit
  rule into step 4b, in the same commit as the checker change.
- Class note, unchanged: the skill and the checker each describe the shape, so every
  checker change needs the step 4b sentence updated in the same commit. 43e7b0d did that.

This is a form review only. Whether writers actually put a digit-bearing qualifier after
`;` is a behaviour question for /odeo:improve, not for this gate.

## Vs previous version
Held: 10/10 -> 10/10. The verdict stays PASS.
- No score moved. Both round 4 optional items are applied (the full typographic set, the
  one-line step 5b command), and the citation sentence now matches the checker on all four
  forms instead of being stricter on `;`.

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
