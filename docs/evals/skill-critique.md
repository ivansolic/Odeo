---
artifact: skills/critique
type: skill
branch: docs/prd-003-pm-content-depth
reviewed_commit: f8239c1
artifact_version: 3
date: 2026-11-03
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 9/10
verdict: PASS
previous_total: 10/10
---

## Skill: critique  (auto-invoked)

Scope: `skills/critique/SKILL.md` (138 lines) and `skills/critique/example.md` (83 lines) at
commit f8239c1, round 3 after USR-031 (PRD-003 R1, pre-mortem half). The reviewer has no
shell, so the change set was established by reading both files in full against the round 2
record (633b15c), not from `git diff`. Out of scope as before: the `code -r` editor line in
Output and the shared output-language paragraph. `docs/stories/USR-031-critique-pre-mortem.md`,
the calibration README and `run-a-premortem.md` / `run-b-premortem-2.md` were read as
context; this review judges the files, not runtime behaviour. Where a run is cited below it
only corroborates a gap that is visible in the text.

## Scores
- trigger clarity: 2, "Use when the user asks to critique, red-team, poke holes in,
  stress-test, or pre-mortem a PRD, strategy, or product direction before committing to
  build it." Unchanged: auto-invoked, starts with "Use when", triggers only.
- structure: 2, essence (7-9), When to use with the when-NOT line (14), numbered Pass 1
  (16-43) and a numbered Pass 2 (47-69), Security pre-mortem (71-75), Output (77-125),
  Quality rules (127-138). 138 lines, one supporting file, one level deep. Round 2 fix 3
  applied: the only "Re-run if the revisions are large" is line 13. Small gap, see fix 4:
  the example pointer (45) sits inside Pass 1 and `example.md` is still titled "Worked
  example: Red team part" although it now carries the pre-mortem too.
- worked example: 2, `example.md` lines 56-83 now model every Pass 2 element with real
  values: a must-fix row with likelihood, impact, an assignable mitigation, a role owner and
  a plan-point deadline ("| Product | Before beta |"), a 30-day row, a watched threat with a
  trigger labelled as a proposal, an overblown worry with why and what makes it real, an
  unspoken worry with how to check and how to raise, and "Launch call: phase, release to 10
  percent of teams first, because ...". The planted-sentence teaching line is now marked
  "Note for the reader, not part of the output" (7-8). Directly imitable. Residual, fix 3:
  the fictional plan is a paid tier with pay-by-invoice, which touches payments, yet the
  example shows no Security pre-mortem and does not say why it is left out.
- precision: 1, the new Pass 2 has three places where the process and the fixed output shape
  do not say the same thing, the same class that held precision at 1 in round 1:
  (a) line 69 "Rule: at most 3 items per group." Step 2 defines "group" as real threat /
  overblown / unspoken, so the cap reads as at most 3 real threats in total, while the shape
  gives real threats three headings. Both final runs read it per heading instead
  (`run-a-premortem.md`: 3 must-fix + 3 thirty-day + 3 watch = 9 real threats), so the unit
  of the cap is undecidable from the text.
  (b) line 66-67 "Re-run the pre-mortem before launch to check the must-fix items, and route
  that re-run into the follow-ups (see Output)." The shape (lines 81-107) is "always this
  shape" and has no slot that tells the user about the re-run, and the routing paragraph
  (120-122) only fires for findings "the user wants to act on", which the user cannot choose
  if never told. Neither final run mentions the re-run.
  (c) The shape's 30-day table (95) asks for Likelihood, Impact, Response and Owner role, none
  of which the process states (step 4 covers must-fix only), and it names the same concept
  "Response" where must-fix says "Mitigation" (the standard asks for one name per concept).
  Smaller: step 5 "Many must-fix threats mean phase or delay" gives no count. Paths, commands
  and every `/odeo:` name remain exact; no TBDs.
- safety integration: 2, lines 41-43 reference Guardrails 6 for proposed thresholds and
  market facts; Pass 2 applies the same honesty rule where it bites: "A risk that rests on a
  market fact gets it checked with `/odeo:research` or marked unverified" (51-52) and "by
  when" as a plan point, "never an invented calendar date" (62-63). Owners as roles, "never
  a person's name" (61-62) keeps people's names out of the output. Guardrails 7 referenced,
  not restated (79, 136); security pre-mortem kept; the todo.md routing stays inside the
  Guardrails 1 documented-flow exception. Residual, fix 5: the "labelled as a proposal" rule
  is scoped to Pass 1 (it sits under Pass 1's "Rules:"), so Pass 2 trigger thresholds are not
  covered by it; the example labels its trigger "(proposal)", both runs do not.

## Total: 9/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10
Reachable. Nothing caps structurally; fixes 1 and 2 restore precision to 2.

## Top fixes
1. Precision (a), line 69: decide the cap's unit and say it. Either "Rule: at most 3 items
   under each pre-mortem heading (Must fix, Fix within 30 days, Watch, Overblown, Unspoken)."
   or "Rule: at most 3 real threats in total across the three timing headings, and at most 3
   overblown and 3 unspoken worries." Keep the word "group" for the three groups of step 2
   only.
2. Precision (b), line 66-67 and the shape: give the re-run a slot. Add under `Launch call:`
   in the shape a line such as `Before launch: re-run the pre-mortem on must-fix <numbers>`,
   and in step 6 say that this line is always printed and becomes a follow-up item in
   `.claude/tasks/todo.md` when the user acts on the critique. Add the line to `example.md`
   after its Launch call.
3. Worked example, `example.md`: the plan adds billing and pay-by-invoice, so by line 72
   ("If it touches auth, PII, payments ...") it needs a security pre-mortem. Either add a
   short `## Security pre-mortem` with 3 scenarios, or extend the reader note at lines 7-8:
   "The security pre-mortem this plan needs (it touches payments) is left out to keep the
   example short." Without one of the two, the example teaches skipping a required section.
4. Structure: retitle `example.md` line 1 to "Worked example: Red team and pre-mortem", and
   move the pointer at line 45 to just before `## Output`, or repeat it once at the end of
   Pass 2, so it is found from both passes.
5. Precision (c) and safety: in step 4 or a new step-3 sentence, state what a 30-day item
   needs (likelihood, impact, a response, an owner role), and use one word, "Mitigation" or
   "Response", in both tables. Move the "A threshold you propose is labelled as a proposal"
   sentence out of Pass 1's Rules into a line that covers both passes, so watch triggers are
   covered. Optionally replace "Many must-fix threats" with a count, for example "Two or
   more open must-fix threats mean phase or delay."

## Other checks
- Round 2 optional fixes: all three applied. Line 109 now says "The `More on request` line
  above offers the deeper parts"; step 5 line 35 "That claim stays in the ranked table but
  gets no kill test.", and `example.md` line 49 agrees; the duplicate re-run line is gone.
- USR-031 acceptance criteria versus the text: three groups (step 2), three timing buckets
  (step 3), mitigation plus role owner (step 4), overblown states why (step 2), fixed
  headings (Output). The text carries each; whether outputs comply is behaviour.
- Map duty: no new command added. `/odeo:critique` is on `docs/system-map.md` (line 62) and
  in the `/odeo:spec` chain (line 98). Satisfied.
- One-level-deep rule and size: satisfied (138 lines, one supporting file).
- Integrity: first-party skill, not a community contribution; the verbatim-copy check does
  not apply.
- Behaviour: the runs show the new shape followed on two documents with the same headings
  in the same order, on the sonnet tier, one run each. They also show the two gaps behind
  fixes 1 and 2 (cap read per heading, no re-run mention). After fixes 1 and 2, re-run both
  samples or run an `/odeo:improve` subagent test before claiming the cap and the re-run hold.
  The README's honest residual on the planted colour sentence is fair: `run-a-premortem.md`
  line 18 predates the reader-note fix, so it does not count against the current example.

## Vs previous version
Regressed on one criterion: 10/10 -> 9/10. Precision 2 -> 1, caused by the new Pass 2 text
(cap unit, re-run without a slot, 30-day fields only in the shape), not by the red-team
part, which is unchanged in substance. Trigger clarity, structure, worked example and
safety integration stay 2; the worked example gained a full pre-mortem part.

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
