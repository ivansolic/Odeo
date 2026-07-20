---
artifact: skill-improve
type: skill
date: 2026-07-20
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger: 2, structure: 2, worked_example: 2, precision: 2, safety: 2 }
total: 10/10
verdict: PASS
---

Reviewed: `skills/improve/SKILL.md` on branch `feature/improve-calibrate`, after
the addition of the "## Calibrate mode (measure a reviewer, do not change it)"
section. Scored against `docs/skill-authoring-standard.md` (rubric at bottom).

## Scores

- trigger clarity: 2. Explicit command (`disable-model-invocation: true`); the
  standard asks for "what the user gets and when to run it" plus an example
  invocation for a non-obvious shape. The description delivers the A/B loop
  plainly; the new mode adds its own invocation shape inline ("Invoke by name,
  e.g. 'calibrate the code-reviewer'. Human-invoked."). Frontmatter description
  correctly stays trigger/purpose and does not try to swallow the new mode.
- structure: 2. 87 lines, far under 500. Follows the body shape: essence, when
  it runs, process, worked example, scope, rules. Calibrate mode is added as a
  parallel section with its own bulleted process + worked example, mirroring the
  A/B section rather than bloating it. Progressive disclosure respected: the
  scenario format and seeds live in `docs/checklists/review-calibration.md`, one
  level away, and are referenced ("Run the planted-defect scenarios in
  docs/checklists/review-calibration.md whose reviewer: matches the target"),
  not restated.
- worked example: 2. Both modes carry concrete examples with real values. The
  calibrate example uses named seeds and real numbers: "IDOR caught 5/5 at
  Critical; the assert-nothing test caught 4/5 at Important... the 1/5 miss is
  noted." Directly imitable, no placeholders.
- precision: 2. Exact file path for scenarios, exact reps ("5 reps"), the exact
  gap rule ("A Critical-expected scenario missed in ANY rep is a flagged gap; an
  Important-expected one is flagged if missed in the majority"), and the cost
  statement ("State the run count (scenarios x reps) upfront, these are live
  reviewer runs and cost model calls"). No TBDs, no vagueness.
- safety integration: 2. The honesty guardrail is referenced and applied, not
  restated: "Never fabricate a run; if the reviewer cannot be dispatched, say so
  and stop" matches the never-fabricate rule (AGENTS.md G6). The measure-vs-change
  boundary is stated in the heading and reinforced ("It never edits the reviewer,
  it reports a catch rate"; "The reviewer itself is left unchanged"), so calibrate
  cannot drift into a silent reviewer edit. The A/B fix path stays human-gated
  ("tested and human-gated like any other change"), preserving the keep/revert
  human floor.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Coherence with review-calibration.md
Confirmed. That doc declares itself "the FORMAT plus seed scenarios" and its
boundary note now says the run/score loop "is automated by /improve calibrate
mode." The skill picks up exactly that division of labor: it runs and scores,
the checklist owns the format and seeds. The severity semantics agree, the
checklist's per-scenario pass/fail (IDOR at Critical, assert-nothing at
Important) is exactly what the skill's gap rule keys on. No duplication of the
scenario records into the skill.

## Answers to the specific checks
- Distinct from the A/B loop: yes. Heading, first sentence ("The sibling of the
  A/B loop above: instead of comparing two versions of a skill, it MEASURES..."),
  and the closing line ("Calibrate finds the gap; the A/B loop, with your keep,
  fixes it") draw the measure-vs-change line three times. A reader will not
  confuse them.
- References rather than duplicates: yes (see structure + coherence above).
- Pass bar sound and honest: yes. Catch rate n/N, Critical-expected miss in any
  rep = gap (strict, correct for a security-class floor), Important = majority,
  never fabricate a run, cost stated upfront. Honest and defensible.
- Still fits the standard after the addition: yes, 10/10.

## Map duty
Satisfied. `docs/system-map.md` line 105 already lists /improve with the
calibrate mode described and pointing at review-calibration.md. No finding.

## Top fixes
None required to pass. Optional polish only (not blocking, not scored down):
- The example says "5 reps (calibration is discipline-critical; you can lower
  it)." The "you can lower it" is a small tension with the strict "Critical-
  expected missed in ANY rep = gap" bar, fewer reps weakens that floor. Consider
  a one-clause reason for when lowering is acceptable (e.g. "lower only for a
  quick smoke check, not for a gate decision") so the latitude cannot be used to
  dodge the bar.

## Recommendation
The change is well-formed. The remaining question, whether the reviewer actually
catches the seeds at the stated rates, is behavioral, not a form matter; that is
what a calibrate run itself proves. No skill-reviewer action needed.

## History
- 2026-07-20 (this record): first eval of `skills/improve/SKILL.md`. No prior
  record existed, so no regression comparison. The reviewed delta is the added
  "## Calibrate mode" section; the pre-existing A/B loop content is unchanged and
  independently sound. Verdict PASS 10/10.
