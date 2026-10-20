---
artifact: scripts/research-check.sh + tests/research-check.test.sh + bin/research-check.sh + skills/research/SKILL.md steps 3, 4b, 5b + README.md
type: code
branch: chore/research-one-fact-rule
reviewed_commit: 25b2a85
artifact_version: 1
date: 2026-10-20
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 0, conventions: 1 }
total: 8/12
verdict: REQUEST CHANGES
---

## Artifact

Commit `25b2a85` on `chore/research-one-fact-rule`: new `scripts/research-check.sh` (bash
wrapper, embedded python3), `tests/research-check.test.sh` (41 assertions), the
`bin/research-check.sh` compatibility wrapper (byte-identical pattern to the other wrappers),
README counts, research skill steps 3, 4b and 5b. No plan file exists for this change; the
ledger entry (`.claude/tasks/todo.md`, "Change B") is intent, not a contract.

## Top findings

Critical
- `tests/research-check.test.sh:180-186` (R1) reads `docs/research/RES-002-platform-support.md`.
  `docs/research/` is on `docs/internal-paths.txt`, `tests/` is public. Reproduced by
  extracting `git archive 25b2a85 scripts tests` alone: R1 goes red 4 times (exit 2, "cannot
  read report"). The published suite is red on every public clone, and README's "the number
  is the same on every machine" becomes false. R1 also breaks the first time RES-002 gains
  the key-terms comments the skill now requires. Fix: replace R1 with a committed,
  real-shaped fixture under `tests/fixtures/research/` (wrapped multi-line notes, backtick
  code quotes, C findings, nested sub-question headings), and keep the RES-002 run as an
  internal dogfood check outside the counted suite.

Important (each reproduced on 25b2a85 with a planted input)
- Silent "did not run" that exits 0: a report whose findings do not match the bullet regex
  (`- **Finding 1** ...`) parses 0 findings and exits 0; `--sources ""` exits 0 as "not
  checked"; typographic quotes give "quotes: 0/0 verbatim" and exit 0.
- `--sources` self-match: a sources dir containing the report (or `.`, or `docs/research`)
  verifies every fabricated quote against the report itself, exit 0.
- Key terms can be satisfied by text the quote check never verifies: backtick spans
  (including locators such as `src/plans.rs`) and quotes under 12 chars count for terms but
  are never checked verbatim; terms are matched on the space-joined quotes, so a term can
  straddle two quotes; one unbalanced `"` (an inch mark) inverts pairing and turns locator
  text into "quote".
- Same-source heuristic vacuous on a note without a comma (`1. Acme docs: "..."`): the whole
  note becomes the "source", so two notes from one source pass as two. Also case-sensitive.
- Duplicate note numbers silently overwrite in the dict; the first note's quotes are never
  checked (duplicate finding ids ARE flagged, notes are not).
- A python exception exits 1, the "violations" code, not 2 (reproduced: UnicodeEncodeError
  under a latin-1 locale).
- Test header's FILE-WIDE INVARIANT ("no case asserts only an exit code") does not hold:
  I2 (line 168), I4 (line 174) and M4b (line 119) assert only an exit code.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 0/2 ·
conventions 1/2 -> total 8/12 (threshold: >=9, no zero)

## Ceiling

12/12 reachable: nothing structurally caps this change; the meaning-level limits the header
documents (same fact vs shared word) are out of scope for a mechanical check and are not
scored against it.

## Regression

First code record for this branch; no previous total.
