---
artifact: scripts/skills-lint.sh C17 (plan_layers + comparison) + tests/skills-lint.test.sh C17 cases + docs/invariants.md C17 row (commit e5e1b49)
type: code
branch: feature/plan-human-layer
reviewed_commit: d995419
artifact_version: 1
date: 2026-10-01
scorer: code-reviewer
model: claude-opus-5-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 1, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
---

## Artifact

Commit `e5e1b49` on `feature/plan-human-layer`, read at HEAD `d995419` (clean tree). Scope:
lint C17 in `scripts/skills-lint.sh`, its four test cases and the `clean_root` fixture change
in `tests/skills-lint.test.sh`, and the C17 row in `docs/invariants.md`. The prose commits
(`dfb1946`, `d995419`) are out of scope except for the marker check below.

## Checks performed

- Marker lines: `global/CLAUDE.md:30` and `docs/plan-format.md:21` are byte-identical,
  `Plan layers: Summary, Why, Explanation, Technical, Review Focus, Verification, Out of scope`.
- `skills-lint.sh` on the worktree: "all invariants hold".
- Both files are on `docs/public-paths.txt` (`global/`, `docs/plan-format.md`), so the
  published snapshot that CI lints carries them; C17 cannot fail CI by absence.
- `set -uo pipefail` without `-e`: a non-matching grep inside `$(plan_layers ...)` returns 1
  harmlessly, so the missing cases reach `viol` instead of aborting the script.
- Probed `plan_layers` on edge inputs: CRLF line -> `A, B` (the `\r` is `[[:space:]]`, stripped);
  two different lines -> first only; `Plan layers:` with an empty or blank list -> empty;
  indented line -> empty (fail-closed); `A,B` vs `A, B` -> differ.
- Portability: `[[:space:]]`, `\{1,\}` are POSIX BRE; `grep -m` is supported by GNU and BSD grep.
  No GNU-only or BSD-only construct.

## Findings

### Important
- `scripts/skills-lint.sh:288` and `docs/invariants.md:25`: the invariant row and the code
  comment both say each file carries ONE `Plan layers:` line, but `grep -m1` takes the first
  and ignores any later one. A second, different line (a revised list added above or below the
  old one, an example in a code fence) passes unnoticed, and the model reading that file then
  sees two contradicting lists. Stated invariant not held. Fix: count first, e.g.
  `n="$(grep -c '^Plan layers:' "$f")"`, and `viol C17 "<file> carries $n 'Plan layers:' lines, want 1"`
  when `n` is not 1; add a test case with a duplicate line in `docs/plan-format.md`.

### Nitpicks
- `scripts/skills-lint.sh:293`: when `global/CLAUDE.md` is absent the message says it
  "carries no 'Plan layers:' line"; the plan-format message says "is missing or carries no".
  Use the same wording for both. Fail-closed on absence is the right behavior.
- `scripts/skills-lint.sh:293-294`: an empty list (`Plan layers:` with nothing after it)
  is reported as "carries no 'Plan layers:' line", which misdirects. Separate "absent" from
  "empty" if the count check above is added.
- `docs/invariants.md:25`: "equal (whitespace aside)" is slightly loose; runs are collapsed to
  one space, so `A,B` and `A, B` still differ. Fail-closed direction, harmless; say "whitespace
  runs collapsed" if precision matters.
- `docs/invariants.md:25`: the C17 row sits between C15 and C16. Move it after C16.

## Points the author asked to challenge

- grep -m1: not acceptable as-is, because the invariant text promises "one". See Important.
- sed normalisation, BSD vs GNU: portable, verified constructs are POSIX.
- Names only, not prose: honestly stated in both the comment and invariants.md. Accepted limit.
- global/CLAUDE.md absent: flagged (fail-closed), correct; only the wording is off.

## Scores

correctness 1/2 · security 2/2 · performance 2/2 · readability 2/2 · testing 2/2 ·
conventions 2/2 -> total 11/12 (threshold: >=9, no zero)

## Ceiling

12/12 is reachable: enforcing the "one line" invariant with a count and a duplicate-line test
closes the only correctness gap.

## Verdict

APPROVE WITH COMMENTS
