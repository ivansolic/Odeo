---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: f3b6fce
artifact_version: 8
date: 2026-10-20
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

This is round 3 on this branch, the last one allowed under the cap, at f3b6fce. The
dispatcher supplied that sha. I have no shell, so I cannot confirm it myself. I scored the
files on disk, which the dispatcher reports as the shipped state at that commit.

What this round covers:
- round 2's fix 1: notes 1 and 2 of the worked example copied word for word from RES-002;
- round 2's fix 2: the test name in the history sentence. The dispatcher ran
  `git log -S session_start_hooks_apply_additional_context_limits_individually -- docs/research/RES-002-platform-support.md`
  and reports two commits: 03d1739 (v4, introduced) and 64df14e (v6, removed). I did not run
  it. I accept it as dispatcher-supplied evidence, and it agrees with the history in
  `docs/evals/RES-002.md:267-274` (v5 on `03d1739`; v6 names "the second note of a Verified
  pair quotes a nearby fact").
- The human kept change A after a blind A/B. That decision is recorded in the dispatcher's
  ledger, not here, and it is not something this form gate judges.

Round 2's fix 3 (`docs/system-map.md`) is outside the skill folder and was not applied.

Files read in full:
- `skills/research/SKILL.md` (125 lines)
- `skills/research/rubric.md` (126 lines)

Also read:
- `docs/research/RES-002-platform-support.md`, lines 68 to 103 (Findings F1 to F14) and 176
  to 200 (notes 1 to 5), to check the example word for word;
- `docs/evals/RES-002.md`, lines 262 to 286 (history v4 to v8);
- `docs/system-map.md`, line 72.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup.

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2 reads "Use when the user wants market or web
  research with sources, asks about market size, TAM/SAM/SOM, ...". That is the correct
  format for an auto-invoked skill, and it uses the user's own words ("is it true that...").
- structure: 2, unchanged. SKILL.md:9-11 says the terms are "defined once, in the
  Definitions of `${CLAUDE_PLUGIN_ROOT}/skills/research/rubric.md`; this skill uses them and
  never rewords them". SKILL.md has 125 lines. The rubric is the only supporting file, and it
  is one level deep. The body follows the standard's shape: essence, modes, process, worked
  example, output (step 5), rules.
- worked example: 2 (was 1). Both round 2 defects are gone.
  - Defect A (notes dropped the page or file) is fixed. SKILL.md:84 reads "Note 1: OpenAI
    docs, developers.openai.com/plugins/build/plugins.md: line 541, ...". SKILL.md:89-90 reads
    "Note 2: Codex source, github.com/openai/codex at `90f00bd`,
    `codex-rs/cli/src/marketplace_cmd.rs` lines 62 to 66". Each note now has the page or file
    plus quotes, which is what the rubric's Note definition (rubric.md:17-18) and
    Traceability 2 (rubric.md:59-60) ask for. Copying this shape gives a conforming note.
  - Defect B (quote cut short) is fixed. SKILL.md:87-88 carries the full example line,
    "codex plugin marketplace add https://github.com/example/plugins.git --sparse
    .agents/plugins".
  - Word-for-word check against RES-002:
    - F1, SKILL.md:82-83 = RES-002:72-73;
    - F13, SKILL.md:93-94 = RES-002:100-101;
    - note 1, SKILL.md:84-88 = RES-002:180-183;
    - note 2, SKILL.md:89-92 = RES-002:184-187.
    The only differences are line wrapping and the label ("Note 1:" in place of "1."), which
    "Adapted from a real report" (SKILL.md:80) covers. "The findings and quotes are verbatim
    from it" (SKILL.md:81) is now true.
  - The explanation holds. "F1 is verified because both notes quote that same fact"
    (SKILL.md:96): both notes quote adding a marketplace from a GitHub URL with that
    command. The history sentence (SKILL.md:96-99) is backed by the dispatcher's `git log -S`
    result and by `docs/evals/RES-002.md:270-274`.
- precision: 2, unchanged. Paths, script names, the RES-NNN numbering rule (SKILL.md:44-45)
  and the editor commands (SKILL.md:66-67) are exact. There are no TBDs. Step 4b
  (SKILL.md:38-43) cites the rubric definition behind every term it uses.
- safety integration: 2, unchanged.
  - SKILL.md:60-65: step 5b commits "on a branch (on `main`, ask the human to create one
    first: Git discipline in `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`)". It hands over the sha and
    `output_language` "(Guardrails 1 and 7 ...)", and it loops under "Guardrails 3, with its
    stop condition".
  - SKILL.md:114-115 points at the honesty guardrail. SKILL.md:123-124 points at Guardrails 7
    and does not restate it.
  - Neither file restates a guardrail.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

The skill passes at the maximum score with no criterion at 0. Stop condition 1 (PASS) is
met, and the maximum is reached, so the review loop ends here.

## Ceiling
10/10, reached. No criterion is capped by the nature of this skill.

## Top fixes
None are needed to pass, and none change the score. Two optional items:
1. Optional, inside the skill. Note 1 also quotes line 541 ("a legacy-compatible marketplace
   at `$REPO_ROOT/.claude-plugin/marketplace.json`"). That quote backs F2, not F1. The rubric
   allows this ("a note that backs several claims verifies only those it gives two sources
   for", rubric.md:27-28), and copying the note in full was the right fix. A reader could
   still mistake it for the nearby-fact quote the paragraph warns about. If you want to close
   that off, append to SKILL.md:96: "(note 1's line 541 quote backs F2, not F1)". This would
   change the file and so need a re-review, and the cap on this branch is spent. I recommend
   leaving it unless there is another reason to edit the skill.
2. Outside this skill folder, not scored, still open from round 1 (fix 4) and round 2 (fix
   3): `docs/system-map.md:72` says "every claim 2+ independent sources or labeled
   unverified". The rubric uses "unverified" only for a claim with no nameable source.
   Suggested map text: "every claim verified by 2+ independent sources or labeled one source
   or unverified". It belongs in a separate change.

## Checks
- Size: SKILL.md has 125 lines and the rubric 126, both under 500. References are one level
  deep.
- Dashes: neither file contains an em dash or an en dash (grep count 0).
- AGENTS.md: nothing is restated.
- Map duty: this change adds no command. `/odeo:research` is on `docs/system-map.md`
  (line 72). The wording drift there is optional fix 2.
- Integrity: this is a first-party skill, so the copied-text check does not apply. The
  verbatim text in the example is copied from this repo's own RES-002, on purpose.

## Loop status
- Round 3 of 3 on this branch. Stop condition 1 (PASS) is met at 10/10. No further round is
  needed.
- Stop condition 3, round 2's concern: the worked example kept drifting from its source when
  it was copied by hand. That class is now closed. The notes are copied whole, so the only
  drift left would come from RES-002 itself changing, and a re-check against it is
  mechanical.
- This gate does not cover behaviour. Whether "one fact per claim" and the same-fact quote
  rule actually stop over-labelled Verified claims is a behavioural question. The blind A/B
  the human ran under `/odeo:improve` is the place for that evidence. A pass on form is not
  evidence of behaviour.

## Vs previous version
Better: 9/10 -> 10/10. The verdict stays PASS.
- worked example 1 -> 2: the notes now carry their page or file, quote in full, and match
  RES-002 word for word. The test name in the history sentence is confirmed by the
  dispatcher's `git log -S` result.
- No change: trigger clarity 2, structure 2, precision 2, safety integration 2.

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
  - Trajectory on this branch: 8 -> 9 -> 10.
