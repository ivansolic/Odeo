---
artifact: skill-ci
type: skill
branch: main
artifact_version: 1
date: 2026-07-13
scorer: skill-reviewer
scores: { trigger_clarity: 1, structure: 2, worked_example: 2, precision: 1, safety_integration: 2 }
total: 8/10
verdict: PASS
---

## Findings

- **Trigger clarity (1):** Description starts correctly with "Use when the user
  asks to set up CI, continuous integration, or GitHub Actions, says yes to a CI
  offer from /setup-project or /merge, or wants pull requests automatically
  tested." But the second sentence, "Generates the project's workflow from its
  OWN commands in CLAUDE.md.", summarizes the workflow, which the standard
  forbids for auto-invoked skills ("Never summarize the workflow in the
  description").
- **Structure (2):** Follows the body shape: essence, why-this-exists,
  preconditions (functioning as when-NOT-to-use with routing to /setup-project),
  numbered process, worked example, output location, rules. 92 lines, no
  supporting files needed, one level deep.
- **Worked example (2):** The checks.yml is concrete and directly imitable: real
  action versions (checkout@v4, pnpm/action-setup@v4, setup-node@v4), correct
  step order (pnpm setup before node with `cache: pnpm`), correct concurrency
  block, non-watch test note inline. Explicitly labeled adaptable ("adapt setup
  steps to the actual stack").
- **Precision (1):** Mostly exact throughout (exact paths, `gh repo create`
  invocation, branch name `chore/ci-setup`, `gh run list --limit 1`). One
  failure: the branch-protection command ends in a literal `...` , an incomplete,
  non-runnable command, which the standard classes as a placeholder. Also
  `-f required_status_checks[strict]=true` sends a string where the API expects
  a boolean (`-F`).
- **Safety integration (2):** References the human floor rather than restating
  it ("shipping stays behind the human floor", "deployment is a human decision
  outside CI"), routes the file through branch + code-reviewer + /merge ("never
  directly to main"), verify-first honesty ("A CI that never ran is as
  unverified as the tests it guards"), honest secrets rule, honest note on
  branch-protection plan limits.

## Cross-checks

- **Map duty:** satisfied, `/ci` row present in docs/system-map.md (line 67),
  wording matches the skill (verify only, never deploy, offered by
  /setup-project and /merge).
- **No guardrail contradiction:** merge's human-floor and the never-deploy rule
  are referenced, not weakened.
- **Offer consistency:** /merge step 3 offers /ci exactly when no CI exists
  (matches precondition 3); /setup-project section 5 offers only when a GitHub
  remote exists (matches precondition 1). Both offer once, non-pushy, as the
  skill's design intends. bin/init-project.sh lists /ci in the build line.
- **Prior record:** none, first eval of this skill.

## Top fixes

1. Rewrite the description to triggers only: drop "Generates the project's
   workflow from its OWN commands in CLAUDE.md." and instead add trigger
   keywords a session would contain, e.g. "checks.yml", "GitHub workflow",
   "run tests on every PR", "tests didn't run".
2. Make the branch-protection command complete and runnable (no trailing
   `...`): include the remaining required fields of the PUT
   /branches/main/protection call (`enforce_admins`,
   `required_pull_request_reviews`, `restrictions`) and use `-F` for booleans,
   or state explicitly which flags to add instead of eliding them.

## History
- 2026-07-13, v1: first review, PASS 8/10.
