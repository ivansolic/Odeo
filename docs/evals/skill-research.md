---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 56ded01
artifact_version: 10
date: 2026-10-20
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 8/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Round 2 of change B on this branch, at 56ded01. The dispatcher supplied the sha. I have no
shell, so I could not confirm it or diff against 25b2a85. I scored the files on disk.

Files read in full:
- `skills/research/SKILL.md` (154 lines)
- `skills/research/rubric.md` (127 lines)
- `scripts/research-check.sh` (245 lines). I read it only to compare it with the shape the
  skill states. The script itself belongs to code-reviewer.

Also read: `docs/research/RES-002-platform-support.md` frontmatter, lines 70 to 102 (F1 to
F14) and 176 to 230 (`### Notes`, notes 1 to 9); `docs/system-map.md:72`.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (dispatcher-supplied).

## Round 1 fixes, verified
1. Worked example, applied. SKILL.md:97-121 is a fenced block in RES-002's layout, with
   `- **F1** ...`, the line `<!-- terms: codex plugin marketplace add; github -->`,
   `### Notes`, and notes `1.`, `2.` and `8.`. I compared the notes line by line with
   RES-002:180-187 and 221-227. Notes 1, 2 and 8 are identical. SKILL.md:95-96 says the terms
   comment was added. F13 cites note 8 (SKILL.md:101-102), and note 8 is included. I did not
   run the checker. The dispatcher reports exit 0 ("2 findings, 3 notes") on a scratch report.
2. `### Notes` named, applied. Step 4b (SKILL.md:40-41) says "under a `### Notes` heading at
   the end of Findings". The step 5 template (SKILL.md:59-60) says "then `### Notes`, the
   numbered notes with quotes".
3. Note count, applied. SKILL.md:40-41 says "give each source its own numbered note".
   rubric.md:17 was left as it was, which is correct.
4. Terminology, applied in the skill. "Quote terms" appears at SKILL.md:48 and 72. "Key terms"
   is now used only for the question (SKILL.md:26-27, 55; rubric criterion 1). See the
   residual in Checks: one script message still says "key term".
5. Rerun and RES number, applied. SKILL.md:69-71 says "run it again until it exits 0, at most
   three runs; violations still left go to the reviewer as a list". SKILL.md:35 says "pick
   the next RES number now, by step 5's rule".
Optional item, applied, with a new problem (see precision): SKILL.md:73-74.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". This is the
  right format for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md has 154 lines. The rubric is the only supporting file and
  sits one level deep. The checker is called by path (SKILL.md:68), not rewritten in the
  body. That follows the standard's rule to prefer pre-written scripts over agent-generated
  code.
- worked example: 2 (was 1). The example is concrete, uses real values, and shows exactly
  the shape step 4b prescribes. That shape is a Verified claim with its terms comment, a One
  source claim, `### Notes`, and one source per note. SKILL.md:122-123 explains both labels:
  "F1 is verified because both notes quote that same fact, and both quote its terms; F13 has
  one source and says so". It can be copied directly. The punctuation difference below is a
  precision problem in the sentence that describes the example. It is not a gap in the
  example itself.
- precision: 1 (was 1). The round 1 items are closed. Two new items, both small:
  - (a) An unclear "it" in the sentence added for the optional item. SKILL.md:72-74 reads: "It
    checks labels, notes, quote terms and quotes, not meaning: the reviewer still judges
    whether two notes state the same fact, and it judges sources independent only by their
    names (a heuristic)."
    - The nearest subject before "and it judges" is "the reviewer". The sentence can
      therefore be read as saying that the reviewer judges independence only by source
      names.
    - That reading contradicts the rubric's Independent sources definition
      (rubric.md:12-13). Under that definition, "two articles citing one press release are
      ONE source", which no name comparison can detect.
    - The intended reading (the check judges by name) also no longer says that the reviewer
      judges real independence. The script header says so (research-check.sh:12-14,
      "whether two differently named sources are really independent").
    - I scored a sentence of this kind the same way in v6 ("ambiguous scope in the new
      nearby-fact sentence"), so 1 is the consistent score.
  - (b) SKILL.md:95-96 says "The findings and quotes are verbatim from it, in its layout".
    The quotes are verbatim, but the findings are not quite:
    - RES-002:73 ends F1 with "**Verified** (notes 1, 2)." and RES-002:101 ends F13 with
      "**One source** (note 8).".
    - The example (SKILL.md:99, 102) drops both trailing periods. That matches the template
      at SKILL.md:47-48 rather than the source.
    - This is a small difference. But this skill's own history (v4) scored an inaccurate
      statement about RES-002 as a precision item, and the example's whole claim is that it
      is copied word for word.
- safety integration: 2, unchanged.
  - SKILL.md:71-72: "Exit 2 means the check did not run, so say that and why". A check that
    did not run is never reported as passing (Guardrails 6).
  - SKILL.md:69-71: the rerun loop has a verifier (the exit code) and a stop (three runs),
    with leftovers handed to the reviewer (Guardrails 4).
  - SKILL.md:74: the name check is called "a heuristic". Guardrails 6 requires heuristics to
    be named as heuristics.
  - Git discipline and Guardrails 1, 3 and 7 are still referenced (SKILL.md:75-79, 151). No
    guardrail is restated.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reachable. No criterion is capped by the nature of this skill. Both precision items
are one-line edits inside SKILL.md.

## Top fixes
1. SKILL.md:72-74, make the subject explicit and keep the reviewer's job whole. Replace
   "the reviewer still judges whether two notes state the same fact, and it judges sources
   independent only by their names (a heuristic)" with: "the check judges sources
   independent only by their names (a heuristic), so the reviewer still judges whether two
   notes state the same fact and whether their sources are really independent".
2. SKILL.md:99 and 102, restore RES-002's trailing periods: `**Verified** (notes 1, 2).` and
   `**One source** (note 8).`. "Verbatim" at SKILL.md:95 is then true again.
   - Reading research-check.sh:135, the `\(notes? ([\d, ]+)\)` pattern matches whether or
     not a period follows. Re-run the dispatcher's scratch check after the edit to confirm
     it still exits 0. That is a behaviour check, which this gate does not do.
   - The template at SKILL.md:47-48 can keep or gain the period. Either way, the checker
     does not care.

Not scored, outside this folder:
- research-check.sh:168 still prints "key term '...' not inside a quote of note N". A writer
  sees this message during step 5b, while the skill calls the concept "quote terms" (round 1
  fix 4, "one name per concept, everywhere"). Line 160 was changed and line 168 was not.
  Route it to code-reviewer with the script change.
- `docs/system-map.md:72` still says "2+ independent sources or labeled unverified". This
  has been open since earlier rounds. It leaves out the `one source` label. This is not a
  map-duty finding, because the command is listed there.

## Checks
- Size: SKILL.md has 154 lines and rubric.md 127, both under 500. References are one level
  deep.
- Dashes: no em or en dashes in either file (grep count 0).
- AGENTS.md: nothing is restated. Guardrails are referenced by number.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: this is a first-party skill. The example quotes this repo's own RES-002 on
  purpose.
- Rubric definitions: not reworded. Step 4b still refers to the rubric's Claim, Note,
  Verified and Confidence words definitions by name.

## Loop status
Round 2 of 3 for change B. This is a PASS, so stop condition 1 is met, but at 9/10 and not
the maximum. Guardrails 3 asks for fixes 1 and 2 and a re-dispatch. Round 3 is the last
round under the cap.

Defect class:
- Round 1's precision items were a missing heading, a conflicting instruction and one name
  for two concepts. Round 2's are an unclear referent and a punctuation-level copy claim.
- I do not count these as the same class twice in a row. Note, however, that item (a) was
  introduced by applying a fix (the optional sentence). v2 recorded the same pattern
  ("three of them came from the round 1 fixes").

This is a form review only. Whether the checker shape catches Verified claims that are
labelled more strongly than their notes support is a behaviour question. Test it with the
checker on a fixture and with /odeo:improve, not here.

## Vs previous version
Improved: 8/10 -> 9/10. The verdict stays PASS.
- worked example 1 -> 2: the example is in the checker shape, has the terms comment and
  includes note 8.
- precision 1 -> 1: all four round 1 items are closed. Two new small items: the unclear
  "it" at SKILL.md:73 and "verbatim" findings without their trailing periods.
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
  - Trajectory for change B: 8 -> 9.
