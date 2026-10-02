# Review calibration, planted-defect scenarios for the judgment layer

Goal: prove that our JUDGMENT-layer reviewers (code-reviewer, design-reviewer,
architecture-reviewer, pm-reviewer) actually catch the defects they claim to. We
plant a KNOWN flaw in a seed artifact, run the reviewer, and check that it flags
the flaw at the right severity. This is the judgment-layer complement to the
mechanical gate tests (`tests/skills-lint.test.sh`, `tests/merge-gate.test.sh`,
`tests/spec-gate.test.sh`), which already plant violations and assert the gate
refuses them.

## What this proves (and what it doesn't)
- Proves: a reviewer catches a seeded defect at the expected severity, so "the
  review will catch X" is measured, not assumed. Guards changes that cheapen the
  pipeline (e.g. the review budget) against silently weakening the catch.
- Doesn't prove: real-world coverage, novel defect classes, or anything about
  model choice. A pass on the seeds is a floor, not a ceiling.
- Cost: each scenario is a LIVE model run (dispatch the reviewer, read the
  verdict). There is no bash-only automation, judgment is the thing under test.

## Scenario format
Each scenario is one record:
- **id**: short kebab-case name.
- **reviewer**: which agent is under test.
- **seed**: the artifact with a known flaw (a diff, a plan, a UI, a PRD), small
  and self-contained. Inline when short; otherwise under `tests/fixtures/calibration/`,
  with a NEUTRAL file name (a name that states the defect hands the reviewer the answer).
- **planted defect**: the one flaw we are testing for.
- **known unplanted findings** (optional): real flaws in the seed that a good reviewer will
  also raise. They do not affect the grade; listing them keeps a grader from reading them as
  noise or as the planted defect.
- **not a finding (recorded, not graded)** (optional): something the format says is NOT a
  finding, with the exact rule for counting reviewers that raise it anyway. It does not affect
  the grade; the count shows whether a rule is understood.
- **expected finding**: what the reviewer MUST report, and the minimum severity.
- **pass / fail**: PASS if the reviewer flags the defect at or above the expected
  severity; FAIL if it misses it, downgrades it below the bar, or approves clean.
  A per-scenario pass/fail below overrides this generic rule when present. Record
  the run as an eval note per `docs/eval-framework.md`.

## Seed scenarios

### 1. `code-reviewer-catches-assert-nothing-test`
- reviewer: `code-reviewer`
- seed (diff): a new `discountedPriceCents(cents, pct)` plus a test that exercises
  it but asserts nothing meaningful:
  ```js
  // src/pricing.js
  export function discountedPriceCents(cents, pct) {
    return Math.round(cents * (1 - pct / 100));
  }
  // src/pricing.test.js
  test("discountedPriceCents", () => {
    discountedPriceCents(1000, 10); // called, but no expect(...)
  });
  ```
- planted defect: the test verifies no behavior (no assertion); it passes
  vacuously and would stay green if the function were wrong.
- expected finding: flags the test as not verifying real behavior, at Important
  or higher. The FINDING is the bar (expected side effect: testing dimension <= 1,
  but do not fail a run that flags the defect yet scores the dimension high).
- pass/fail: PASS if the vacuous test is flagged at Important or higher; FAIL if
  the change is approved with the test treated as coverage.

### 2. `code-reviewer-catches-idor`
- reviewer: `code-reviewer`
- seed (diff): an endpoint that authenticates the caller but never checks that
  the record belongs to them:
  ```js
  // GET /invoices/:id
  app.get("/invoices/:id", requireLogin, async (req, res) => {
    const invoice = await db.invoice.findById(req.params.id);
    res.json(invoice); // any logged-in user can read ANY invoice
  });
  ```
- planted defect: object-level authorization is missing (IDOR); "logged in" is
  treated as "allowed to see this record."
- expected finding: flags the missing object-level authorization (IDOR) at
  Critical (expected side effect: security dimension 0, and a Critical anywhere is
  a FAIL verdict per the code rubric). Naming the security baseline is a plus, not
  required.
- pass/fail: PASS if flagged as Critical (IDOR / missing ownership check); FAIL if
  missed or downgraded below Critical.

### 3. `architecture-reviewer-flags-decision-missing-from-summary`
- reviewer: `architecture-reviewer` (plan-review mode)
- seed (plan + story, too long to inline): `tests/fixtures/calibration/plan-usr-014-a.md` for
  the story `tests/fixtures/calibration/USR-014-export-csv.md`.
- planted defect: a Design decision writes the CSV header as `due_date` where the story says
  "due date", a change to what the user gets, and the Summary's `What you decide` does not
  name it. The human approves from the Summary and would never see the choice.
- known unplanted findings: the formula guard prefixes `-` too, so a title like "-1 day
  buffer" changes, against criterion 4, and the Summary does not say so; and the seed
  predates the `stop rule:` / `gate:` markers, so its Risks item is unmarked.
- not a finding (recorded, not graded): the Risks line "if `listTasks` returns due dates as
  strings, stop and ask" is a builder stop rule, which plan-format keeps out of the human
  layer. Counted when any finding asks for it in the Summary or `What you decide`.
- expected finding: the header deviation, at important or higher, with a remedy that lets
  the human decide. Citing criterion 6 by number is not required.
- pass/fail: PASS when the deviation is raised at important or higher AND the remedy names it
  in `What you decide`, alone or as one of two options ("match the story, or keep `due_date`
  and name it in `What you decide`" passes). FAIL when the plan is called clean, when it is
  only a note, or when the only remedy is "match the story" with no choice surfaced.

### 4. `architecture-reviewer-leaves-technical-decision-alone` (false-positive control)
- reviewer: `architecture-reviewer` (plan-review mode)
- seed: `tests/fixtures/calibration/plan-usr-014-b.md` (same story): the plan of scenario 3
  with the header deviation named in `What you decide`, plus a purely technical Design
  decision (the serializer is a pure function with no I/O) that the Summary does not mention.
- planted defect: none. This scenario guards the opposite failure: a reviewer that pushes
  every decision into the human layer, so it swells into a second spec.
- known unplanted findings: the same as scenario 3 (the formula guard changing titles is a
  real criterion-6 finding here, and expected).
- not a finding (recorded, not graded): the same Risks stop rule as scenario 3, counted by
  the same rule.
- expected finding: no finding asking for the pure-function decision in the human layer
  (Summary, Why, Explanation or `What you decide`). Other findings do not affect the grade.
- pass/fail: PASS if no finding (any rank) asks for the pure-function decision anywhere in the
  human layer; FAIL otherwise.

## How to run (manual, or by `/odeo:improve` calibrate mode)
1. Run BLIND, per the blind scoring in `docs/eval-framework.md`: copy the seed and its story
   (only those) to a fresh scratch directory, under neutral names, and give the reviewer that
   directory. No grading rule, earlier output or this checklist may be within its reach.
2. Dispatch the reviewer under test on that seed. For a reviewer changed on a branch the
   installed plugin does not carry yet, copy the branch's agent file AND EVERY FILE IT NAMES
   BY PATH (a `${CLAUDE_PLUGIN_ROOT}/...` reference included) into the scratch directory of
   step 1, keeping their relative paths, then point a fresh agent at those copies and never
   at the worktree, and record that it was not the dispatched agent. Derive the set from the
   agent file each time rather than from a list here: a hand list goes stale with the agent.
   (For `architecture-reviewer` at the time of writing that is AGENTS.md, docs/plan-format.md
   and the agent file itself; an example, not the rule.)
3. Compare its verdict against the expected finding and severity above, by the rules written
   here before the run.
4. Record PASS/FAIL as an eval note. A FAIL is a real regression in the
   reviewer, fix the agent (or the rubric), then re-run, per the review loop.

## Boundary (honest)
This doc is the FORMAT plus seed scenarios. The run/score loop (seed -> dispatch
-> assert on the verdict, over N reps) is automated by `/odeo:improve` calibrate mode
("calibrate the code-reviewer"); you can also run any scenario by hand.
Extend the seed set whenever a real miss is observed in dogfood.
