---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 053f4ef
artifact_version: 11
date: 2026-10-20
scorer: skill-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

## Skill: research  (auto-invoked, no disable-model-invocation)

Round 3 of change B on this branch, at 053f4ef, the last round under the cap. The dispatcher
supplied the sha. I have no shell, so I could not confirm it or diff against 56ded01. I
scored the files on disk.

Files read in full:
- `skills/research/SKILL.md` (154 lines)
- `skills/research/rubric.md` (127 lines)

Also read: `scripts/research-check.sh` lines 1 to 50 and 84 to 163, only to compare the
shape the checker reads with the shape the skill states (the script belongs to
code-reviewer); `docs/research/RES-002-platform-support.md` lines 68 to 103;
`docs/system-map.md:72`.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (dispatcher-supplied).

## Round 2 fixes, verified
1. Unclear "it", applied as proposed. SKILL.md:71-74 now reads "It checks labels, notes,
   quote terms and quotes, not meaning, and it judges sources independent only by their
   names (a heuristic), so the reviewer still judges whether two notes state the same fact
   and whether their sources are really independent." Both "it"s refer to the check, and
   the reviewer's job is whole again, matching the rubric's Independent sources definition
   (rubric.md:12-13) and the script header (research-check.sh:11-14).
2. Trailing periods, applied. SKILL.md:98-99 and RES-002:72-73 are identical; SKILL.md:101-102
   and RES-002:100-101 are identical, periods included. "Verbatim" at SKILL.md:95 is true. I
   did not run the checker; the dispatcher reports exit 0, "2 findings, 3 notes", on a
   scratch report built from the example.
Out-of-folder note from round 2, done: research-check.sh:158 now prints "quote term '...' not
inside a quote of note N", and grep finds no "key term" in the script.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2: "Use when the user wants market or web research
  with sources, asks about market size, TAM/SAM/SOM, competitor landscape, ...". The right
  format for an auto-invoked skill.
- structure: 2, unchanged. 154 lines, the rubric is the only supporting file and sits one
  level deep, and the checker is called by path (SKILL.md:68), not rewritten in the body.
- worked example: 2, unchanged. SKILL.md:97-121 is a fenced RES-002 excerpt in the checker
  shape (a Verified claim with its terms comment, a One source claim, `### Notes`, one
  source per note), now word for word including punctuation, and SKILL.md:122-127 explains
  both labels.
- precision: 1 (was 1). Both round 2 items are closed. One new item, small:
  - Step 4b says "Write it in the shape step 5b checks" (SKILL.md:47) and spells out the
    note header: "a note starts with its source's name, a comma, its page or file and a
    colon ..., and only what follows that colon counts as quoted" (SKILL.md:49-51).
  - The checker's quote rules are not in that statement. Per research-check.sh:25-28 ("Notes
    parse FAIL CLOSED"), :95 and :107-110:
    - a quote is only text inside straight double quotes or backticks after the header, not
      everything after the colon;
    - any typographic quote mark in a note (U+201C, U+201D, U+201E, U+00AB, U+00BB) is a
      violation ("typographic quote mark; use straight double quotes");
    - an odd number of `"` in a note is a violation.
  - This collides with the skill's own language rule (SKILL.md:146-153): a report written in
    German, Croatian or French, all supported by the resolver, naturally uses „ “ or « »,
    and the skill does not say that quote marks are mechanics that stay ASCII.
  - Mitigation, and why this is not a 0: the example shows straight quotes, and step 5b's
    rerun loop names the fix, so the cost is one extra run, not a wrong report. Still, it is
    the same kind of item I scored as precision in round 1 (the `### Notes` heading the
    checker needs was missing from the stated shape), so 1 is the consistent score.
  - The commit subject of 053f4ef ("note parsing fails closed") suggests the stricter
    parsing is new this round; I cannot diff to confirm.
- safety integration: 2, unchanged.
  - SKILL.md:71: "Exit 2 means the check did not run, so say that and why" (Guardrails 6).
  - SKILL.md:69-71: verifier (exit code) and stop (three runs), leftovers to the reviewer
    (Guardrails 4).
  - SKILL.md:73: the name check is "a heuristic" (Guardrails 6).
  - Git discipline and Guardrails 1, 3 and 7 referenced (SKILL.md:74-79, 151); nothing
    restated.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reachable. No criterion is structurally capped. The precision item is a one-clause
edit in step 4b.

## Top fixes
1. SKILL.md:51, complete the stated shape with the checker's quote rules. After "and only
   what follows that colon counts as quoted" add: "; a quote is text in straight double
   quotes or backticks, never typographic marks („ “ « »), even in a localized report, and a
   note's double quotes must pair". Optionally name quote marks among the mechanics that stay
   ASCII in the language rule at SKILL.md:148-150, but one statement in step 4b is enough.

Not scored, outside this folder:
- `docs/system-map.md:72` still says "every claim 2+ independent sources or labeled
  unverified", leaving out the `one source` label. The dispatcher has routed it as a separate
  change. Not a map-duty finding: the command is listed.

## Checks
- Size: SKILL.md 154 lines, rubric.md 127, both under 500. References one level deep.
- Dashes: no em or en dashes in either file (grep count 0).
- AGENTS.md: nothing restated; guardrails referenced by number.
- Map duty: no new command; `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: first-party skill; the example quotes this repo's own RES-002 on purpose.
- Rubric definitions: not reworded; step 4b refers to Claim, Note, Verified and Confidence
  words by name.

## Loop status
Round 3 of 3 for change B: the cap is reached, so the loop stops here. PASS at 9/10, not the
maximum, so per Guardrails 3:
- Why max is not reached: precision 1, because step 4b's stated shape omits the checker's
  quote-delimiter rules, which a localized report is likely to break.
- Residual as it is: Top fix 1, unapplied.
- Open decision for the human: accept 9/10 with the residual (the checker loop catches it at
  run time), apply fix 1 and authorize a round past the cap, or route it to a later change.
Defect class: round 2 was an unclear referent and a copy-accuracy claim; round 3 is the skill's
shape statement lagging the checker. Not the same class in consecutive rounds (round 1 had the
lagging-shape class). It arrived with a script change, not a skill edit: the skill and the
checker each describe the shape, so a stricter checker needs the skill line updated in the
same commit.

This is a form review only. Whether writers of localized reports actually trip the quote rule
is a behaviour question for /odeo:improve with a German fixture, not for this gate.

## Vs previous version
Unchanged total: 9/10 -> 9/10. The verdict stays PASS.
- precision 1 -> 1: both round 2 items closed (the referent at SKILL.md:71-74, the periods at
  SKILL.md:99 and 102). New: the quote-delimiter rules missing from step 4b.
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
