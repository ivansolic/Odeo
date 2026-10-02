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
  and self-contained. Inline here for now; extract to a fixtures directory under
  `tests/` when `/odeo:improve` calibrate mode automates the runs.
- **planted defect**: the one flaw we are testing for.
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
- seed (plan + story, too long to inline): `tests/fixtures/calibration/plan-decision-missing-from-summary.md`
  for the story `tests/fixtures/calibration/USR-014-export-csv.md`.
- planted defect: a Design decision writes the CSV header as `due_date` where the story says
  "due date", a change to what the user gets, and the Summary's `What you decide` does not
  name it. The human approves from the Summary and would never see the choice.
- expected finding: the header deviation, flagged under criterion 6 at important or higher,
  WITH the remedy that the human decides it (name it in `What you decide`).
- pass/fail: PASS as above. FAIL if the plan is called clean, if the deviation is only a
  note, or if it is raised only as "fix the header" without surfacing the choice.

### 4. `architecture-reviewer-leaves-technical-decision-alone` (false-positive control)
- reviewer: `architecture-reviewer` (plan-review mode)
- seed: `tests/fixtures/calibration/plan-technical-decision-only.md` (same story). The same
  plan with the header deviation named in `What you decide`, plus a purely technical Design
  decision (the serializer is a pure function with no I/O) that the Summary does not mention.
- planted defect: none for criterion 6. This scenario guards the opposite failure: a reviewer
  that pushes every decision into the Summary, so the human layer swells into a second spec.
- expected finding: no finding asking for the technical decision in the human layer. Other
  findings do not affect the grade.
- pass/fail: PASS if no finding (any rank) asks for the pure-function decision in the Summary
  or `What you decide`; FAIL otherwise.

## How to run (manual, until `/odeo:improve` calibrate mode)
1. Put the seed on a scratch branch (or paste it as the review scope).
2. Dispatch the reviewer under test on that seed.
3. Compare its verdict against the expected finding and severity above.
4. Record PASS/FAIL as an eval note. A FAIL is a real regression in the
   reviewer, fix the agent (or the rubric), then re-run, per the review loop.

## Boundary (honest)
This doc is the FORMAT plus seed scenarios. The run/score loop (seed -> dispatch
-> assert on the verdict, over N reps) is automated by `/odeo:improve` calibrate mode
("calibrate the code-reviewer"); you can also run any scenario by hand.
Extend the seed set whenever a real miss is observed in dogfood.
