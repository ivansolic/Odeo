---
id: USR-001
title: No-leak guardrail for machine surfaces
prd: PRD-001
order: 1
depends_on: none
---

# USR-001: No-leak guardrail for machine surfaces

**Card:** As a maintainer, I want a deterministic check that Odeo's machine-read surfaces
stay English/ASCII regardless of the chosen output language, so that turning on another
language can never corrupt my project's mechanics or break gates, tooling, or collaboration.

## Acceptance criteria (observable, binary)
- Running the check on a project whose mechanics are clean exits 0 (pass), even when prose
  in the project is non-English.
- The check exits non-zero (fail) when a non-allowlisted or non-ASCII token appears in any
  machine surface: a frontmatter field name or enum value, a filename, a directory name, a
  git branch name, a conventional-commit type or scope, or a code identifier.
- The failure message names the offending file and which surface failed.
- With the check in place, merge-gate, spec-gate, and skills-lint still pass on a clean
  non-English project.

**Verification note (this repo):** `bin/language-guard.sh` + `tests/language-guard.test.sh`,
built TDD. First a failing test that plants a non-English enum value (e.g. `verdict: PROSAO`)
and a non-ASCII identifier; then implement to catch them. Allowlists: conventional-commit
types, known frontmatter enums (verdict / status / model_tier), filename pattern
`^[a-z0-9-]+$`.

## INVEST / size
Independent (needs no other story), ~1 day, testable by construction.
