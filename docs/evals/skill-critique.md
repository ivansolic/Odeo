---
artifact: skills/critique
type: skill
branch: docs/prd-003-pm-content-depth
reviewed_commit: 633b15c
artifact_version: 2
date: 2026-11-03
scorer: skill-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 8/10
---

## Skill: critique  (auto-invoked)

Scope: `skills/critique/SKILL.md` (105 lines) and `skills/critique/example.md` (55 lines) at
commit 633b15c, round 2 after USR-030 review round 1. The reviewer has no shell, so the
change set was established by reading both files in full against the lines quoted in the
round 1 record (17af699), not from `git diff`. Pass 2 and the security pre-mortem are
unchanged on purpose (USR-031). The `code -r` editor line in Output is known, tracked
separately and not scored here. `docs/calibration-runs/critique-red-team/run-b-lean-3.md`
was read as context only; this review judges the files, not runtime behaviour.

## Scores
- trigger clarity: 2, "Use when the user asks to critique, red-team, poke holes in,
  stress-test, or pre-mortem a PRD, strategy, or product direction before committing to
  build it." Unchanged: auto-invoked, starts with "Use when", triggers only, no workflow
  summary.
- structure: 2, essence (lines 7-9), When to use now with a when-NOT line (14: "Not for
  code, a single story or a second model's read (that is `/odeo:second-opinion-pm`)."),
  numbered process for Pass 1 (16-38), example pointed at once (44, one level deep), Output
  (57-91) now holding the "On request" block (78-82) next to the `## Next steps` slot it
  governs, Quality rules (93-105). 105 lines, far under 500. Round 1's two structural gaps
  are closed.
- worked example: 2, `example.md` now follows the tightened contract: "Ranking rule:" line,
  "Top pick this week: claim 1.", Strongest case first in each kill test, and each Kill
  criterion is a decision on this week's evidence, labelled as a proposal: "Kill criterion
  (proposal): 5 or more of the 8 admins name a second approver. Then stop the per-seat plan
  and price per team on an invoice instead." Claim 1's kill criterion now thresholds the 8
  calls instead of a different test, and claim 2's adds the decision instead of repeating
  the Fails if threshold. Concrete, real values, directly imitable.
- precision: 2, the output contract now matches the process. Line 68 "(per claim: Strongest
  case / Fails if / Evidence this week / Kill criterion / Cheapest test)" matches step 6;
  lines 63 and 66 give the ranking rule and top pick a slot; line 95 "The top-ranked claim
  is the **one to test this week** (step 4); name it in the Top pick line." gives
  "top-ranked" one meaning; lines 37-38 separate the fields: "Fails if says when the claim
  is false; the Kill criterion is the decision: the result on this week's evidence at which
  you stop or change the plan, and what changes." Paths and commands exact, every `/odeo:`
  command named is on the map, no TBDs. Residual wording nits listed under Top fixes do not
  leave a placeholder or a contradictory instruction, so they do not drop the level.
- safety integration: 2, lines 40-42 now reference Guardrails 6 where the process asks for
  numbers: "A threshold you propose is labelled as a proposal, and a market fact or
  benchmark is cited or marked unverified (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 6)."
  That applies the rule to this skill's two numeric fields and points at the source; it
  does not copy the guardrail. Guardrails 7 is referenced, not restated (lines 58-59 and
  102-103), the security pre-mortem is kept for sensitive features, and the todo.md routing
  stays inside the Guardrails 1 documented-flow exception.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling: 10/10
Reached. Nothing caps structurally; guardrails apply (6, 7, security pre-mortem) and are
referenced where they bite.

## Top fixes
All optional; none changes a score.
1. Precision, line 78: "The last line above offers the deeper parts" is off by one; the last
   line of the shape is `## Next steps`. Change to "The `More on request` line above offers
   the deeper parts".
2. Precision, step 5: say whether a claim moved to What holds up stays in the ranked table.
   `example.md` keeps claim 3 in the table (Medium / Low / Low) and gives it no kill test;
   `run-b-lean-3.md` leaves the held-up claim out of the table. Add one clause to step 5,
   for example "keep it in the table, but give it no kill test", or the opposite, and make
   the example agree.
3. Structure (cosmetic): "Re-run if the revisions are large" (line 13) and "Re-run if
   changes were large" (line 84) say the same thing; keep one.
4. Round 1 fix 6 (language rule mentions "the whole frontmatter block, the filename slug"
   for a chat-only skill) was declined because the paragraph is the shared standard text
   across skills. Accepted: keeping one shared wording serves the standard's
   consistent-terminology rule, and the extra clause is vacuous here, not wrong.

## Other checks
- Map duty: no new command added. `/odeo:critique` is on `docs/system-map.md` (line 62) and
  in the `/odeo:spec` chain (line 98). Satisfied.
- One-level-deep rule and size: satisfied (SKILL.md 105 lines, one supporting file, no
  deeper references).
- Integrity: first-party skill, not a community contribution; the verbatim-copy check does
  not apply.
- Behaviour: the round 1 fixes change what the model emits. `run-b-lean-3.md` shows the new
  shape (ranking rule, top pick, Strongest case, "(proposal)" labels, "treat both numbers as
  unverified", the single "More on request" line, no `## Next steps` unasked), but that is
  one run on one sample. Round 1 asked for both calibration samples; re-run sample-a (or an
  `/odeo:improve` subagent test) before claiming the behaviour holds. This review does not
  test behaviour.

## Vs previous version
Improved: 8/10 -> 10/10, no criterion dropped. Precision 1 -> 2 (output shape, top-pick
definition and Fails if versus Kill criterion now agree with the process and the example).
Safety integration 1 -> 2 (Guardrails 6 referenced at the numeric fields). Structure stays
2, with the when-NOT line added and the on-request block moved under Output.

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
