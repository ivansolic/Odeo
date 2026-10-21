---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: eadb831
artifact_version: 12
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

Round 4 of change B on this branch, at eadb831. This round goes past the 3-round cap
because the human explicitly authorized it to close the round 3 residual. The dispatcher
supplied the sha. I have no shell, so I could not confirm it or run
`git diff 053f4ef eadb831`. I scored the files on disk and took the dispatcher's word
on what the diff contains.

Files read in full:
- `skills/research/SKILL.md` (158 lines)
- `skills/research/rubric.md` (127 lines)
- `scripts/research-check.sh` (320 lines). I read it only to compare the shape the checker
  parses with the shape the skill states. The script itself belongs to code-reviewer.

Also read: `docs/system-map.md:72`, and `agents/skill-reviewer.md` for the declared effort.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (supplied by the dispatcher).

## Round 3 fix, verified
Top fix 1, the quote-delimiter rules missing from step 4b, is applied. I compared it
clause by clause with the script header (research-check.sh:25-36) and the code:
- Quote delimiters. SKILL.md:51-53: "a quote is text in straight double quotes or
  backticks, never in typographic marks („ “ « »), even in a localized report, and a
  source's own typographic marks may stay inside such a quote". The script matches this at
  :26-29 ("a typographic double quote ... outside a straight-quoted or backtick span is a
  violation ...; inside one it is the source's own quote mark"), and the code does the same
  thing (`parse_notes`, :142-147, strips `"..."` and backtick spans before looking for
  marks; `quotes_in`, :131, takes both delimiters). They agree.
- Header. SKILL.md:49-51 ("source's name, a comma, its page or file and a colon ..., and
  only what follows that colon counts as quoted") matches :25-26 and :29-30 and `header()`
  at :153-160. They agree.
- Note citations. SKILL.md:53-55: "Cite a note only as `(note N)`, `(notes N, M)` or
  `(note N, <qualifier>)`: a parenthesis holding the word note or notes without that number
  list is a violation in every section." The script matches this at :32-36 and in
  `cited_notes`/`NOTE_LIST` (:81-82, :112-127), which scan every parenthesis outside the
  Notes list. They agree. The script also accepts `; <qualifier>`, which the skill does not
  offer. That makes the skill stricter than the checker, which is safe: a writer who
  follows the skill never trips the checker.
- Worked example against the new rules: I traced it by reading. I did not run it. Every
  note in SKILL.md:111-125 has its comma and colon before the first double quote, has no
  typographic mark, and has an even count of `"`. The citations `(notes 1, 2)` and
  `(note 8)` fit the citation forms, and both terms of F1 (`codex plugin marketplace add`,
  `github`) fall inside a quote of notes 1 and 2.

Step 5b rewrap: SKILL.md:72-84 is wrapped, and the content is the same as round 3's step
5b (check, three runs, exit 2 meaning, heuristic, branch, dispatch, loop).

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". This is
  the right format for an auto-invoked skill: triggers only, no workflow summary.
- structure: 2, unchanged. SKILL.md is 158 lines. The rubric is the only supporting file and
  sits one level deep. The checker is called by path (SKILL.md:72) and not rewritten in the
  body. The definitions live only in rubric.md:6-35 ("this skill uses them and never rewords
  them", SKILL.md:10-11).
- worked example: 2, unchanged. SKILL.md:102-126 is a fenced RES-002 excerpt in the checker
  shape. It still satisfies the stricter parsing, as traced above. SKILL.md:127-132 explains
  both labels and the failure the rules prevent.
- precision: 2 (was 1). The round 3 gap is closed. Step 4b now gives the whole shape the
  checker parses: claim line, terms comment, note header, quote delimiters, and citation
  forms ("a quote is text in straight double quotes or backticks, never in typographic
  marks", SKILL.md:51-53). Paths, commands and exit codes are exact throughout (SKILL.md:35,
  56, 72-73, 152). There are no placeholders beyond the template slots `<report>`, `NNN` and
  `<slug>`, which are defined where they appear. Three small residuals do not cost the 2,
  because none makes a writer who follows the skill fail the checker:
  - The parenthetical "(„ “ « »)" leaves out U+201D (”), which the script refuses
    (:80). The rule before it, "never in typographic marks", is general, and the list reads
    as examples. Every common pairing (German „“, English “”, French « ») still has a listed
    mark.
  - The script refuses a note with an odd count of `"` (:148-149). The skill does not state
    this, but it follows from "a quote is text in straight double quotes". The one case not
    covered is a lone straight `"` inside a backtick quote, which is rare.
  - The command in step 5b wraps inside its code span (SKILL.md:72-73). Rendered, it reads
    as one command. Copied raw into a shell, the line break would drop `--sources`.
- safety integration: 2, unchanged.
  - SKILL.md:75-76: "Exit 2 means the check did not run, so say that and why" (Guardrails 6).
  - SKILL.md:73-75: a verifier (the exit code) and a stop (three runs), with leftover
    violations handed to the reviewer (Guardrails 4).
  - SKILL.md:77: the name check is "a heuristic" (Guardrails 6).
  - Git discipline and Guardrails 1, 3 and 7 are referenced by name and number
    (SKILL.md:79-84, 156), not restated.
  - The new "even in a localized report" clause is a format rule of the checker. It does not
    restate Guardrails 7, which says nothing about quote marks, and it does not loosen it.
    It sits correctly next to the language rule at SKILL.md:151-158.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reached. No criterion is structurally capped.

## Top fixes
None required. Optional, not scored, in order of value:
1. SKILL.md:72-73, keep the command on one line inside its code span:
   `` `${CLAUDE_PLUGIN_ROOT}/scripts/research-check.sh <report> --sources ~/.cache/odeo/research/RES-NNN` ``,
   and wrap the prose around it instead. A raw copy would then never drop `--sources`.
   Without `--sources` the check exits 0 with "quotes: not checked".
2. SKILL.md:52, write "(„ “ ” « »)" so the list matches the script's set at
   research-check.sh:80.

Not scored, outside this folder:
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", without the `one source` label. The dispatcher has already routed this as a
  separate change. It is not a map-duty finding, because the command is listed.

## Checks
- Size: SKILL.md 158 lines, rubric.md 127, both under 500. References are one level deep.
- Dashes: no em or en dashes in either file (grep count 0 across `skills/research/`).
- AGENTS.md: nothing restated. Guardrails are referenced by number.
- Skill and script header agree on the header, the quote delimiters, typographic marks and
  the citation forms. The skill is stricter than the script only on `; <qualifier>`.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill. The example quotes this repo's own RES-002 on purpose.
- Rubric definitions: not reworded. Step 4b refers to Claim, Note, Verified and the
  Confidence words by name.

## Loop status
Round 4 of change B, past the cap with the human's authorization. The maximum is reached
(10/10 PASS), so the loop ends here.
- Trajectory for change B: 8 -> 9 -> 9 -> 10.
- What changed: round 1 closed the missing `### Notes` heading, the conflicting
  note-source instruction and the double-named "key terms". Round 2 fixed the example's
  layout and its terms comment. Round 3 fixed the unclear "it" and the dropped trailing
  periods. Round 4 (this round) added the quote delimiters and the citation forms to step 4b.
- Class note for the future: the skill and the checker each describe the shape. A stricter
  checker needs the step 4b sentence updated in the same commit, which is what eadb831 did.

This is a form review only. Whether writers of localized reports actually keep straight
quotes is a behaviour question. It belongs to /odeo:improve with a German or French fixture,
not to this gate.

## Vs previous version
Improved: 9/10 -> 10/10. The verdict stays PASS.
- precision 1 -> 2: step 4b now states the checker's quote-delimiter rules and its
  citation forms, and they agree with research-check.sh:25-36.
- No change: trigger clarity 2, structure 2, worked example 2, safety integration 2.

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
