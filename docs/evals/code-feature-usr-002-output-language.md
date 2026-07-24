---
artifact: USR-002
type: code
branch: feature/usr-002-output-language
artifact_version: 1
date: 2026-07-24
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: none
---

## Artifact: USR-002 output-language build (bin/resolve-language.sh, bin/init-project.sh wiring, template + skill docs)

Executes the approved plan `docs/plans/2026-07-24-usr-002-choose-output-language.md`
for story USR-002 (covers R1 + R5b). First CODE review on this branch; the prior
`USR-001-006-output-language.md` record is a pm-reviewer STORIES eval, a different
artifact, so there is no prior code baseline to regress against.

## Verification performed (not vibes)
- Ran `tests/resolve-language.test.sh` (12 cases) -> exit 0, all `ok:`.
- Ran `tests/init-project.language.test.sh` (5 cases) -> exit 0, all `ok:`.
- Ran `tests/language-guard.test.sh` -> exit 0 (new line does not touch machine surfaces).
- Ran the full suite (14 test scripts) with a throwaway git identity -> 14/14 green.
  Confirmed the identity dependency is expected (init-project + gate tests build
  temp git repos), not a defect.
- Adversarial resolver edge cases by hand: `french` -> `en` (exact-match only,
  no false substring), indented `  output_language:` -> ignored (correct `^` anchor),
  tab-separated value -> parsed, empty value -> degrades to `en`, trailing comment
  `de # german` -> degrades to `en` (fail-closed, safe).
- Idempotent write: append branch (preset, no anchor) yields exactly 1 line;
  sed-replace branch on an already-written file keeps exactly 1 line. No two
  `output_language:` lines are reachable, no temp file lands in the scaffold
  (mktemp writes to $TMPDIR, outside the project, and never reaches `git add -A`).
- set -e / arg-loop interaction: passing two positional args does not abort. The
  `*)` arm orders `[[ -z ... ]] && ...; shift` so the trailing `shift` is the last
  command and returns 0 even when the `&&` short-circuits to 1. Ordering is correct.

## Scores (rubric, 0-2)
- **Correctness: 2** — Precedence project -> global -> en is exact; invalid-degrade
  falls through per the contract; normalization (CR strip, trim, lowercase) matches
  the plan and the tests; `grep -m1` gives first-line-wins; the `--language` two-token
  flag is consumed correctly by the while/case/shift conversion; missing-value guard
  and pre-mkdir validation fail fast before any directory is created. No off-by-one,
  no unhandled empty/absent-file path (both `[ -f ]` guarded).
- **Security: 2** — No injection surface: `LANGUAGE` is validated against the
  `en|de|hr|fr` allowlist BEFORE it is ever interpolated into the `sed`/`awk`
  program, so the code substituted into `sed -E "s/.../output_language: ${LANGUAGE}/"`
  can only be one of four safe literals. Allowlist over blocklist, deny-by-default
  degrade. No secrets, no PII, no user prose in logs. Resolver reads a value and
  localizes nothing; machine surfaces stay English (guard test green).
- **Performance: 2** — Leaf utilities, a couple of greps/seds on a small file.
  No loops over unbounded input, no N+1, nothing in a hot path. N/A ceiling
  reached.
- **Readability: 2** — Small single-purpose functions (`read_lang`, `usage`),
  English-only comments, no dead code, no TODOs. The header comments state
  purpose/usage/exit codes and the arch-review rationale for the loop conversion
  and the mktemp+mv choice. No em/en dashes.
- **Testing: 2** — Tests lock behavior, not implementation: they assert exit codes
  and echoed codes across all three precedence levels, invalid-degrade at each
  level, duplicate-first-wins, normalization, and both usage/dir errors. The
  init-project tests assert exactly-one-line, fail-fast on bad and on missing flag
  value, and no-project-created on failure. Assertions are not weakened. See the
  one substring-assertion nitpick below (does not change the score: the exit-code
  assertions carry the real weight, and the round-trip loop covers each code
  distinctly).
- **Conventions: 2** — Matches repo bash style (`set -uo pipefail` for the
  non-`-e` resolver so a no-match grep never aborts; `set -euo pipefail` retained
  in init-project), `LC_ALL`-free but CR-normalized, exit 0/2 mirrors
  coverage-check/language-guard. Column-0 canonical line + I2 interview step match
  the plan. Conventional-commit messages, one logical change per commit, on a
  feature branch. TDD order honored (tests committed to fail first).

## Total: 12/12   ## Verdict: APPROVE  (threshold: >= 9/12, no criterion at 0)

## Ceiling
Achievable ceiling is **12/12** and it was reached. Performance is structurally
trivial here (leaf shell utilities on a tiny file) but the rubric scores it 2 for
"clean", not for sophistication, so it is not capped below max. No criterion is
structurally limited below 2 for this artifact.

## Round-by-round
- Round 1 (2026-07-24, opus-4-8[1m], strongest, high): 12/12 APPROVE. No prior
  code record for this branch, so no rubric movement to report. The build landed
  clean: every plan contract point (precedence, degrade, idempotent single-line
  write, fail-fast validation, machine-surface English) is implemented and proven
  by the suite and by hand-run adversarial cases.

## Findings

### Critical
None.

### Important
None.

### Nitpicks (optional, do not block merge)
1. `tests/resolve-language.test.sh` uses `assert_contains "en" "$out"` for the
   echoed code. `en` is a substring of many strings (and of the word "usage"
   etc.), so the substring assertion is looser than an exact-equality assertion
   would be. In practice the resolver echoes only the bare code plus a newline and
   the exit-code assertions co-gate every case, so no real hole exists. If you want
   the assertion to be self-evidently tight, switch to an exact-match helper
   (`[ "$out" = "$code" ]`) for the round-trip and precedence cases.
2. `project-templates/CLAUDE.md`: the documentation sentence sits BETWEEN two
   `- ` list items (after `teach_me_as_i_go:` and before `output_language: en`),
   so it renders as a paragraph interrupting a bulleted list. Behaviorally correct
   and deliberate (it must not start with `output_language:` at column 0 so grep
   never counts it), but a reader sees a slightly broken list. Optional: make the
   sentence an HTML comment or indent it under the preceding bullet so the list
   stays visually intact while the column-0 canonical line is preserved.
3. Resolver treats a value with a trailing inline comment (`output_language: de
   # german`) as invalid and degrades to `en`. This is safe fail-closed behavior
   and consistent with the "exact code only" contract, but a user who annotates
   the line by hand would silently lose their choice. Not in USR-002 scope;
   worth a one-line note in the template that the value line takes the bare code
   only. Flagging so a future story (USR-004 hand-edit path) does not rediscover it.

## What's good
- The `sed`/`awk` interpolation is safe by construction: `LANGUAGE` is allowlist
  validated before it can reach the substitution, closing the one real injection
  vector this change could have introduced.
- The `set -e` + `&&`-idiom ordering in the positional arm is subtle and correct;
  the trailing `shift` keeps a second positional arg from aborting the script.
- The idempotent write genuinely cannot produce a duplicate line on re-run, and
  the temp-file-outside-scaffold reasoning in the comment is accurate.
- Fail-fast validation runs before any `mkdir`, so a bad `--language` never leaves
  a half-created project behind. The tests assert exactly this.
