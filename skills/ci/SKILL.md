---
description: Use when the user asks to set up CI, continuous integration, GitHub Actions, or a checks.yml workflow, wants pull requests tested automatically, complains tests didn't run on a PR, or says yes to a CI offer from /setup-project or /merge.
---

# CI (the safety net that outlives the session)

Generates `.github/workflows/checks.yml` so every pull request runs the
project's typecheck, lint, tests, and build on GitHub's machines, the same
checks the local flow runs, now guaranteed to run even when nobody remembers.
CI here means continuous INTEGRATION (verify), never continuous deployment:
shipping stays behind the human floor.

## Why this exists (tell the user in one line)
A test suite that never runs is not green. "Deferred to CI" is only honest when
CI exists; this command makes it exist in about two minutes.

## Preconditions (check, don't assume)
1. **A GitHub remote exists** (`git remote -v`). None yet -> point to
   `gh repo create <name> --private --source=. --remote=origin --push`, then return.
2. **CLAUDE.md Commands are real** (no `[...]` placeholders). Placeholders ->
   route to `/setup-project` first; CI built on guessed commands lies.
3. **`.github/workflows/` doesn't already have a checks workflow.** If it does,
   offer to review/update it instead of overwriting.

## Build the workflow FROM the project's commands
Read the `## Commands` section of `CLAUDE.md` (and the package manifest to
confirm). Use THEIR commands verbatim, in non-interactive form (`vitest run`,
never bare `vitest`). Include only steps whose commands exist: typecheck, lint,
test (each test command they have), build. Any stack works, the workflow just
runs the commands; only the setup steps (Node/pnpm vs Python vs Go) come from
the Stack section.

Worked example (pnpm monorepo; adapt setup steps to the actual stack):
```yaml
name: checks
on:
  pull_request:
  push:
    branches: [main]
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }
      - run: pnpm install --frozen-lockfile
      - run: pnpm typecheck
      - run: pnpm lint
      - run: pnpm test          # must be the non-watch form
      - run: pnpm build
```
Notes while generating:
- Tests that need infrastructure (a real database) either get a service block
  (e.g. a `services: postgres:` entry) or stay excluded with an HONEST comment
  in the yaml ("DB-gated tests run locally, see CLAUDE.md"), never silently skipped.
- Secrets: CI must need none for checks. If a test demands one, that is a
  finding to fix, not a secret to paste into GitHub.

## Land it like any other change
The workflow file goes through the normal discipline, never directly to main:
1. Branch `chore/ci-setup`, write the file, show it to the user (`code -r` per
   the editor rule), confirm.
2. Commit; `code-reviewer` reviews it like any change (it is executable config);
   integrate with `/merge` when the user says so.
3. After the first PR runs, VERIFY: `gh run list --limit 1` shows the workflow
   green. A CI that never ran is as unverified as the tests it guards.

## Optional hardening (offer, don't push)
Make the check REQUIRED so a red PR physically cannot merge (turns the CI from
advice into an enforced gate):
```
gh api repos/{owner}/{repo}/branches/main/protection -X PUT --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["checks"] },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
JSON
```
Say honestly: branch protection on private repos needs a paid GitHub plan on
some account types; if the API refuses, the workflow still runs and reports,
it just can't block, /merge's local gate remains the backstop.

## Rules for yourself
- Verify (integration) only; never add deploy steps, deployment is a human
  decision outside CI.
- The project's commands are the source of truth; never invent scripts that
  don't exist in the manifest.
- One honest workflow beats a clever matrix; start minimal, grow when the
  project does.
