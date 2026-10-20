---
artifact: skills/research
type: skill
branch: chore/research-one-fact-rule
reviewed_commit: 25b2a85
artifact_version: 9
date: 2026-10-20
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

Round 1 of change B on this branch, at 25b2a85. Change A closed at 10/10 (v8, f3b6fce). The
dispatcher supplied the sha; I have no shell, so I could not confirm it or diff against
f3b6fce. I scored the files on disk.

Change B, as the dispatcher describes it: step 3 now saves fetched sources under
`~/.cache/odeo/research/RES-NNN/`; step 4b now states the claim shape the checker reads, a
`<!-- terms: ... -->` comment on Verified claims, and a "source name, comma" start for
notes; step 5b now runs `research-check.sh` before the review. The script itself belongs to
code-reviewer. I read it only to check whether the skill's description of the shape is
complete. That is a precision question about the skill, not a review of the script.

Files read in full:
- `skills/research/SKILL.md` (135 lines)
- `skills/research/rubric.md` (126 lines)
- `scripts/research-check.sh` (157 lines), read only to compare against the shape the skill states

Also read: `docs/research/RES-002-platform-support.md` lines 65 to 76, and the line numbers
of `### Notes` (178) and notes 1 and 2 (180, 184); `docs/system-map.md:72`.

Model tier: strongest, as dispatched. This agent has no web access, so I could not re-check
the live model lineup. Output language: en (dispatcher-supplied).

## Scores
- trigger clarity: 2, unchanged. SKILL.md:2 reads "Use when the user wants market or web
  research with sources, asks about market size, TAM/SAM/SOM, ...". That is the correct
  format for an auto-invoked skill.
- structure: 2, unchanged. SKILL.md has 135 lines. The rubric is the only supporting file
  and sits one level deep. The script is referenced by path (SKILL.md:66) rather than
  described in the body, which is the standard's "pre-written scripts over agent-generated
  code" principle.
- worked example: 1 (was 2). The values are real and the quotes match RES-002. But since
  this change the example no longer shows the shape it asks the reader to copy:
  - SKILL.md:46-49 prescribes `- **F1** <one fact>. **Verified** (notes 1, 2)`, a
    `<!-- terms: ... -->` comment on a Verified claim, and numbered notes.
  - The example renders F1 as `> F1: "Codex adds ... **Verified** (notes 1, 2)."`
    (SKILL.md:92-93) and its notes as `> Note 1: OpenAI docs, ...` (SKILL.md:94). It has no
    terms comment.
  - So a report that copies the example fails the checker: with no `### Notes` and no
    `1.` notes, `research-check.sh` exits 2 ("no '## Findings' with a '### Notes' list");
    laid out correctly but still without the comment, it reports "F1: Verified but no key
    terms". The standard asks for an example that is "runnable or directly imitable".
  - On the tension you named: being verbatim does not stop the example from carrying the
    comment. RES-002 itself already uses the checker shape: `- **F1** Codex adds a plugin
    marketplace ...` at RES-002:72, `### Notes` at 178, and `1. OpenAI docs, ...` at 180.
    The `F1:` and `Note 1:` labels are the skill's own adaptation, so the example matches
    the checker better if it copies RES-002's actual layout. The only thing RES-002 lacks is
    the terms comment. Adding it and saying it was added keeps "The findings and quotes are
    verbatim from it" (SKILL.md:91) true, because the comment is neither a finding nor a
    quote. See fix 1.
- precision: 1 (was 2). Step 4b says it writes "the shape step 5b checks" (SKILL.md:46), but
  that shape is incomplete in ways the checker depends on:
  - (a) The `### Notes` heading is not named anywhere in the skill. SKILL.md:58 says only
    "the numbered notes with quotes follow the claims". Without that heading the step 5b
    command does not run (exit 2). The script header (research-check.sh:20) needs it.
  - (b) The skill contradicts itself on how many sources go in a note. SKILL.md:41 says "put
    its sources in a numbered note" (one note, several sources). The shape on SKILL.md:47
    and the checker need one note per source: "Verified needs two notes", and a note's
    source is "the text before its first comma" (research-check.sh:13). A writer who follows
    SKILL.md:41 for a Verified claim gets "F1: Verified needs two notes". The rubric's Note
    definition (rubric.md:17, "naming one or more sources") is not reworded, but step 4b now
    gives two instructions that conflict.
  - (c) One name for two concepts. The standard says "consistent terminology (one name per
    concept, everywhere)". "Key terms" in SKILL.md:26, SKILL.md:53 and rubric criterion 1
    (rubric.md:40-42, 118) means the question's terms, defined for the reader. In SKILL.md:47
    and 69 it means the words each note of a Verified claim must quote. So a rubric scorer
    reading "key term in it is undefined" and a writer reading "adds its key terms" are
    talking about different things under the same name.
  - (d) Minor: SKILL.md:67 says "fix every violation it names (exit 1)" but never says to run
    the check again, so a fix is never confirmed. Also, step 3 (SKILL.md:35) uses `RES-NNN`
    before step 5 (SKILL.md:50-51) says how NNN is chosen.

  Rubric definitions: nothing in the change rewords them. Step 4b still points at the
  rubric's Claim, Note, Verified and Confidence words definitions by name. The new "the
  words of that fact each of its notes must quote" (SKILL.md:47-48) adds a check, not a
  definition, and SKILL.md:69-70 keeps the same-fact judgment with the reviewer. The rubric
  file reads exactly as the definitions previously scored (126 lines). I could not diff it.
- safety integration: 2, unchanged.
  - SKILL.md:68: "exit 2 means the check did not run, so say that and why" applies the
    honesty rule that a check which did not run is never reported as passing.
  - SKILL.md:68-70: "It checks labels, notes, key terms and quotes, not meaning: the
    reviewer still judges whether two notes state the same fact" names the mechanical
    limit.
  - Git discipline and Guardrails 1, 3 and 7 are still referenced (SKILL.md:71-75, 133). No
    guardrail is restated.
  - Saving public pages to `~/.cache` sends nothing off the machine.

## Total: 8/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
10/10 is reachable. No criterion is capped by the nature of this skill. All four precision
items and the example fix are edits inside SKILL.md.

## Top fixes
1. Worked example (SKILL.md:89-104): copy RES-002's real layout instead of the `F1:` and
   `Note 1:` labels. Use `- **F1** Codex adds a plugin marketplace ... **Verified** (notes 1,
   2).`, then a terms comment line, then `### Notes`, then `1. OpenAI docs, ...` and
   `2. Codex source, ...` (RES-002:72-73, 178-187). Add the comment, for example
   `<!-- terms: codex plugin marketplace add; github -->`; both notes quote both terms
   (note 1: "Use `codex plugin marketplace add` ..." and ".../github.com/example/..."; note
   2: `bin_name = "codex plugin marketplace add"` and ".../github.com/owner/repo"). Change
   SKILL.md:90-91 to: "The findings and quotes are verbatim from it; the terms comment is
   added here, since RES-002 predates it." Before claiming the example passes, run the
   checker on a scratch copy of it. That is a behaviour check, which this gate does not do.
2. Name the `### Notes` heading. In step 4b (SKILL.md:41), change "in a numbered note under
   Findings" to "in a numbered note (`1. ...`) under a `### Notes` heading at the end of
   Findings". In the step 5 template (SKILL.md:57-58), change "the numbered notes with quotes
   follow the claims" to "then `### Notes`, the numbered notes with quotes".
3. Resolve the note-count conflict at SKILL.md:41. Change "put its sources in a numbered
   note" to "give each source its own numbered note". Do not touch rubric.md:17; one source
   per note is a stricter writing rule that the rubric's "one or more" already allows.
4. Give the checker's concept its own name. In SKILL.md:47 and 69, replace "key terms" with
   "quote terms" (for example "a verified claim adds its quote terms, the words of that fact
   each of its notes must quote"). Leave "key terms" for the question (SKILL.md:26, 53;
   rubric criterion 1). The script's message text ("no key terms") should follow in the
   code-reviewed change; the `<!-- terms: -->` marker can stay.
5. Minor: at SKILL.md:67, after "fix every violation it names (exit 1)", add "and run it
   again until it exits 0 (at most three runs; violations still left are listed for the
   reviewer)". This gives the fix a verifier and a stop, per Guardrails 4. At step 3
   (SKILL.md:35), add "(NNN as in step 5)".

Optional, not scored: in SKILL.md:69-70, also say that the checker judges whether two notes
come from independent sources only by name (the text before the first comma), which is a
heuristic (Guardrails 6). Open from earlier rounds and outside this folder:
`docs/system-map.md:72` still says "2+ independent sources or labeled unverified".

## Checks
- Size: SKILL.md has 135 lines and rubric.md 126, both under 500. References are one level
  deep.
- Dashes: none in either file (grep count 0).
- AGENTS.md: nothing is restated.
- Map duty: no new command. `/odeo:research` is on `docs/system-map.md:72`.
- Integrity: this is a first-party skill. The example quotes this repo's own RES-002 on
  purpose.

## Loop status
Round 1 of 3 for change B. This is a PASS, so stop condition 1 is met, but at 8/10 and not
the maximum. Guardrails 3 asks for fixes 1 to 5 and a re-dispatch. No defect class repeats
from change A. The example finding is new: it comes from the new shape, not from the
copy-drift problem closed in v8.

This is a form review only. Whether the checker shape actually catches over-labelled
Verified claims is a behaviour question. Test it with the checker run on a fixture and with
/odeo:improve, not here.

## Vs previous version
Worse: 10/10 -> 8/10. The verdict stays PASS.
- worked example 2 -> 1: the example now differs from the shape step 4b prescribes, and has
  no terms comment.
- precision 2 -> 1: the `### Notes` heading is not named; one note with several sources
  conflicts with one source per note; "key terms" names two concepts.
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
