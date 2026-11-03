---
artifact: skills/critique
type: skill
branch: docs/prd-003-pm-content-depth
reviewed_commit: 5067d5d
artifact_version: 4
date: 2026-11-03
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 9/10
---

## Skill: critique  (auto-invoked)

Scope: `skills/critique/SKILL.md` (142 lines) and `skills/critique/example.md` (97 lines) at
commit 5067d5d, round 4, requested by the maintainer after reading round 3's three
output-changing comments. The reviewer has no shell, so the change set was established by
reading both files in full against the round 3 record (f8239c1), not from `git diff`. Out of
scope as before: the `code -r` editor line in Output and the shared output-language
paragraph. The calibration README, `run-a-premortem-2.md` and `run-b-premortem-3.md` were
read as context; this review judges the files, not runtime behaviour.

## Scores
- trigger clarity: 2, "Use when the user asks to critique, red-team, poke holes in,
  stress-test, or pre-mortem a PRD, strategy, or product direction before committing to
  build it." Unchanged: auto-invoked, starts with "Use when", triggers only.
- structure: 2, essence (7-9), When to use with the when-NOT line (14), numbered Pass 1
  (16-41), numbered Pass 2 (43-68), Security pre-mortem (70-78), Output (80-129), Quality
  rules (131-142). 142 lines, one supporting file, one level deep. Round 3 fix 4 applied:
  `example.md` line 1 is now "Worked example: Red team and pre-mortem", and the pointer sits
  after the Security pre-mortem in the "Both passes" paragraph (78), reachable from both
  passes.
- worked example: 2, `example.md` now models the whole shape with real values, including
  the parts round 3 found missing: "## Security pre-mortem / The plan adds payments and
  invoices, so this section is required." with three scenarios and what the design must
  include (86-94), "Before launch: re-run the pre-mortem on must-fix 1." (84) and the
  default More on request line (96-97). Directly imitable. The one stale column header is
  counted under precision, where the standard places one-name-per-concept.
- precision: 1, round 3 (a) and (b) are resolved and (c) is resolved in SKILL.md only:
  (a) the cap now has a decidable unit, "Rule: at most 3 real threats in total across the
  three timing buckets, at most 3 overblown worries and at most 3 unspoken worries." (67-68).
  (b) the re-run has a slot: step 6 "Always end with the `Before launch:` line" (63) and the
  shape line "Before launch: re-run the pre-mortem on must-fix <numbers>" (106).
  (c) step 3 now says "A 30-day threat gets a likelihood, an impact, a mitigation and an
  owner role." (54-55) and the shape's 30-day table says "Mitigation" (98). But `example.md`
  line 64 still reads "| # | Risk | Likelihood | Impact | Response | Owner role |". The
  example is the file agents imitate, the shape is declared "always this shape" with headings
  as structural labels (81-82), and the standard asks for "one name per concept, everywhere".
  So the folder still names one concept two ways, in a place that changes the output, and
  the README's claim "one word 'Mitigation' in both tables" is true for SKILL.md but not for
  the example. That single word is the only thing holding precision at 1; paths, commands
  and every `/odeo:` name are exact, no TBDs.
- safety integration: 2, the honesty rule now covers both passes: "**Both passes:** a
  threshold or trigger you propose is labelled as a proposal, and a market fact or benchmark
  is cited or marked unverified (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 6)." (76-78),
  closing round 3 fix 5. Pass 2 keeps "checked with `/odeo:research` or marked unverified"
  (47-48), plan-point deadlines "never an invented calendar date" (60) and role owners
  "never a person's name" (59). Guardrails 7 referenced, not restated (82, 140). The example
  now demonstrates the security pre-mortem instead of teaching its omission.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10
Reachable. Nothing caps structurally; fix 1 (one word) restores precision to 2.

## Top fixes
1. Precision, `example.md` line 64: change the header cell "Response" to "Mitigation", so
   the 30-day table reads "| # | Risk | Likelihood | Impact | Mitigation | Owner role |",
   matching SKILL.md line 98 and step 3. Correct the README line that claims "one word
   'Mitigation' in both tables" only if it is meant to cover the example.
2. Optional, precision nit, step 6 and shape line 106: say what the `Before launch:` line
   prints when there is no must-fix threat, for example "Before launch: no must-fix items;
   re-run the pre-mortem if the plan changes." Today "Always end with" plus "must-fix
   <numbers>" has no defined form for an empty bucket. Neither run hits it, so this is a
   gap in the text, not an observed failure.
3. Optional, precision nit, shape: say how an empty timing bucket is printed. Both runs
   independently wrote "None." under `### Fix within 30 days`, which is a sensible default;
   one word in the shape ("(write None. when empty)") would make it the rule rather than
   luck.

## Other checks
- Round 3 fixes: 1 applied (cap, 67-68); 2 applied (re-run line, 63-65 and 106, example 84);
  3 applied (security pre-mortem in the example, 86-94); 4 applied (title, pointer at 78);
  5 applied in SKILL.md (step 3 at 54-55, "Mitigation" at 96 and 98, proposal rule at 76),
  missed in `example.md` line 64 (fix 1 above).
- Declined: replacing "Many must-fix threats mean phase or delay" (61-62) with a count.
  This was optional in round 3. The reason given ("a number without a source") is the
  maintainer's call on method, which this review does not judge; the vagueness is bounded
  because the launch call must carry its reason. Not a finding.
- Map duty: no new command added. `/odeo:critique` is on `docs/system-map.md` (line 62)
  and in the `/odeo:spec` chain (line 98). Satisfied.
- One-level-deep rule and size: satisfied (142 lines, one supporting file).
- Integrity: first-party skill, not a community contribution; the verbatim-copy check does
  not apply.
- Behaviour: `run-a-premortem-2.md` and `run-b-premortem-3.md` corroborate fixes 1, 2 and 5
  in the text: 3 real threats each (sample-a 2 must-fix + 1 watch; sample-b 2 must-fix + 1
  watch), "Before launch: re-run the pre-mortem on must-fix 1, 2" in both, watch triggers
  labelled "(proposal)", a security pre-mortem in both, the same headings in the same order,
  and the planted colour sentence absent from sample-a. Neither run has a 30-day item, so
  they cannot show which header (example "Response" or shape "Mitigation") an agent copies.
  One run each on the sonnet tier: evidence of shape, not proof that the cap and the re-run
  hold; run an `/odeo:improve` subagent test before claiming that.
- Naming drift outside the skill folder, not scored: the run headers and README say "review
  round 4" for what this record calls round 3 (f8239c1), and commit 5067d5d calls it "review
  round 3". Pick one numbering so the trajectory reads the same in all three places.

## Vs previous version
Same total, 9/10 -> 9/10, but the defects behind it shrank from three classes to one word.
Precision stays 1: round 3's cap unit and re-run slot are fixed, the 30-day fields are now
stated in the process, and only the example's stale "Response" header remains. Structure,
worked example and safety integration stay 2, each with its round 3 residual closed (title
and pointer, security pre-mortem in the example, proposal rule covering both passes).

## History
- 2026-11-03 (v1, Round 1, 17af699): baseline after USR-030. PASS 8/10. Precision 1 (output
  shape omits Strongest case and the ranking and top-pick lines; "top-ranked" defined twice;
  Fails if and Kill criterion not distinguished). Safety integration 1 (silent on
  Guardrails 6 where the process asks for thresholds and evidence).
- 2026-11-03 (v2, Round 2, 633b15c): round 1 fixes 1 to 5 applied, fix 6 declined with a
  reason that was accepted; a single default "More on request" line added from the adoption
  review. PASS 10/10. Residual: three optional wording nits (line 78 off-by-one reference,
  held-up claims in the ranked table unspecified, duplicate re-run line). Verdict line
  replaced, PASS to PASS.
- 2026-11-03 (v3, Round 3, f8239c1): USR-031 rewrote Pass 2 (five areas, three groups, three
  timing buckets, must-fix with role owner and plan-point deadline, launch call, no blame,
  re-run before launch) and its Output shape; `example.md` gained a pre-mortem part; round 2
  fixes 1 to 3 applied. PASS 9/10. Precision 2 -> 1 for the new Pass 2: the "at most 3 items
  per group" cap has no decidable unit, the re-run in step 6 has no slot in the fixed shape,
  and the 30-day table's fields exist only in the shape. Verdict line replaced, PASS to PASS.
- 2026-11-03 (v4, Round 4, 5067d5d): requested by the maintainer. Round 3 fixes 1 to 4
  applied in full, fix 5 applied in SKILL.md; the optional count for "Many must-fix threats"
  declined, accepted as not a finding. New runs `run-a-premortem-2.md` and
  `run-b-premortem-3.md` show the cap, the re-run line and the security pre-mortem. PASS
  9/10. Precision stays 1 for one residual: `example.md` line 64 still heads the 30-day
  table "Response" while the shape says "Mitigation". Verdict line replaced, PASS to PASS.
