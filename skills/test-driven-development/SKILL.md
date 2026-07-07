---
name: test-driven-development
description: Use when implementing backend logic, API endpoints, services/controllers, data validation, business rules, calculations, data transformations, or bug fixes, anything with clear, checkable input/output. Write a failing test before implementation code, then make it pass (RED-GREEN-REFACTOR). Do NOT use for UI component layout/styling, visual exploration where the design isn't settled, throwaway prototypes, generated code, config files, or trivial one-line fixes.
---

# Test-Driven Development (lite)

Turn each acceptance criterion into a failing test first, then write the minimal
code to make it pass. The core discipline (from the RED-GREEN-REFACTOR tradition):
**if you didn't watch the test fail, you don't know that it tests the right thing.**

This is the *lite* variant, judgment over dogma. Apply it where it pays off,
skip it where it gets in the way.

## When this applies, and when it doesn't

**Apply it** (code with clear, checkable rules):
- Backend services, controllers, handlers
- API endpoints and their request/response contracts
- Validation, business logic, calculations, data transforms
- Bug fixes, write a test that reproduces the bug *first*, then fix it

**Skip it** (don't force test-first here):
- UI component layout, templates, styling, visual design
- Exploratory UI work where you don't yet know what it should look like
- Throwaway prototypes, generated code, configuration files
- Trivial one-line fixes

When it's genuinely unclear which side something falls on, ask the user rather
than forcing TDD onto UI/exploratory work.

## The cycle: RED → GREEN → REFACTOR

**RED, write one failing test**
- Start from an acceptance criterion. One behavior per test; if a criterion says
  "and", split it into separate tests.
- Name the test for the behavior it proves.
- Prefer real code over mocks; mock only true external dependencies (network, DB
  when not under test, third-party APIs).

**Verify RED, watch it fail**
- Run the test and confirm it fails for the RIGHT reason (the feature is missing),
  not because of a typo, bad import, or setup error.
- If it passes immediately, the test proves nothing, the behavior already exists
  or the test is wrong. Fix the test before continuing.

**GREEN, minimal code to pass**
- Write the simplest code that makes the test pass. No extra features, no
  speculative generality, no gold-plating.

**Verify GREEN**
- Confirm the test passes AND that no other tests broke.
- If something else breaks, fix the implementation, **never weaken or edit a test
  just to make it pass.**

**REFACTOR**
- Clean up while green: remove duplication, improve names, extract helpers.
- Don't add behavior during refactor. Re-run the tests afterward to stay green.

## Test commands
- Use the test commands defined in this project's `CLAUDE.md` (the **Commands**
  section), e.g. the unit-test, backend-test, and e2e commands listed there.
- If they aren't filled in yet, infer them from the project's manifest (e.g.
  `package.json` scripts, `Makefile`, `pyproject.toml`) and confirm with the user.
- `CLAUDE_CODE_AUTO_VERIFY=1` already runs these automatically after codegen.
  TDD adds one thing on top: the test must **exist and have failed first**.

## Red flags, stop if you catch any of these
- Production code written before its test → delete it and start from the test
- A brand-new test that passes on its first run → it isn't proving anything; fix it
- Can't explain why a test failed → understand it before writing more code
- "I'll just write the code first, it's faster" / "I already tested it manually"
  → that's not TDD; the test must fail before the code exists
- Testing a mock's behavior instead of the real code's behavior
- Adding test-only methods to production classes

## Report
When a unit is done, state which acceptance criteria are now covered by tests,
and show the red → green transition (the failing run, then the passing run).
