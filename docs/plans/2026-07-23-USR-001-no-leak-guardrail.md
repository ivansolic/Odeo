# Plan: USR-001 No-leak guardrail for machine surfaces
approved: yes
model_plan:
  judgment: Opus 4.8 (session, strongest tier)
  builder: sonnet tier (per AGENTS.md tier map)
arch_review: clean (v2, 2026-07-23; v1 had 2 blocking + 2 important, all resolved)

## Header
Goal: A deterministic check (`bin/language-guard.sh`) that fails closed when any
  non-ASCII or non-allowlisted token appears in a machine-read surface, so turning
  on a non-English output language can never corrupt project mechanics or break gates.
Serves: PRD-001 R6 (the `[E]` enforced no-leak guardrail) and its success metric
  "zero mechanics leakage". This is the feasibility backstop for the whole
  output-language feature: if machine surfaces can leak, the language option is unsafe
  to ship.
Architecture context: bash + markdown repo, no build step (CLAUDE.md). Deterministic
  gates live in `bin/*.sh` and are exercised by self-contained `tests/*.test.sh` that
  build their own fixtures with `mktemp`. The established gate contract (from
  `bin/coverage-check.sh`, `bin/spec-gate.sh`, `bin/merge-gate.sh`): exit 0 = clean,
  exit 1 = violation with a named reason on stderr, exit 2 = usage error;
  `set -uo pipefail`; frontmatter parsed between the first two `---` lines only;
  `tr -d '\r'` for CRLF portability; allowlists over blocklists. This plan INHERITS
  that contract and does not redecide it.
Constraints (from the story + AGENTS.md):
  - "Running the check on a project whose mechanics are clean exits 0 (pass), even
    when prose in the project is non-English."
  - "The check exits non-zero (fail) when a non-allowlisted or non-ASCII token
    appears in any machine surface: a frontmatter field name or enum value, a
    filename, a directory name, a git branch name, a conventional-commit type or
    scope, or a code identifier."
  - "The failure message names the offending file and which surface failed."
  - "With the check in place, merge-gate, spec-gate, and skills-lint still pass on a
    clean non-English project."
  - Story verification note: built TDD; first a failing test that plants a non-English
    enum value (e.g. `verdict: PROSAO`) and a non-ASCII identifier, then implement.
    Allowlists: conventional-commit types, known frontmatter enums
    (verdict / status / model_tier), filename pattern `^[a-z0-9-]+$`.
  - Dev-rigor style: TDD-lite. This is logic with clear rules (a deterministic gate),
    so test-first is MANDATORY here: write the failing test, watch it fail, then implement.
  - Style: no em/en dashes anywhere; English-only comments; small single-purpose functions.
  - PROSE IS EXPLICITLY OUT OF SCOPE (that is USR-006/R7's soft warning). This guard
    must never inspect prose body text.
  - Scope discipline: this plan is ONLY the guard script + its tests + minimal wiring.
    It does NOT plan the setting, resolution, prose localization, or `/language`
    (USR-002..006).
Do-not-touch boundaries: no `docs/codebase-map.md` exists in this repo, so there are
  no declared DO-NOT-TOUCH paths. The plan still leaves every existing gate script
  untouched (see Task 4 wiring, which only ADDS a doc/reference, no edits to other
  gates' logic).

## File map (before any tasks)
- bin/language-guard.sh          CREATE: the deterministic no-leak gate. Owns the
                                 machine-surface allowlist checks; exit 0/1/2.
- tests/language-guard.test.sh   CREATE: self-contained TDD tests (mktemp fixtures),
                                 same shape as tests/coverage-check.test.sh.
- docs/system-map.md             MODIFY: register the guard in the "what exists"
                                 registry alongside the other bin/*.sh gates
                                 (coverage-check/spec-gate/merge-gate). NOT
                                 docs/invariants.md, that file is the skills-lint C<n>
                                 registry and language-guard is a standalone gate, not a
                                 skills-lint check (arch-review NOTE-5). Read system-map
                                 first; match its row format.

## Scope contract: what a "machine surface" is HERE (the exact rules the builder implements)

The guard takes a list of paths (files and/or directories) plus optional explicit
tokens, and checks ONLY these surfaces. Each rule below is exact; the builder does
not invent additional surfaces.

Allowlists (define once at top of script, English-only comments):
- COMMIT_TYPES: `feat fix chore docs refactor test style perf` (from AGENTS.md /
  global CLAUDE.md Conventional Commits list).
- FRONTMATTER_ENUM_FIELDS: ONLY `model_tier` -> `fast` `strong` `strongest`
  (compare lowercased). This is the single controlled vocabulary that is genuinely
  canonical, enumerated IDENTICALLY in `bin/merge-gate.sh` and `bin/spec-gate.sh`,
  so there is one real source to agree with.
  DELIBERATELY NOT enumerated (arch-review BLOCKING-2): `verdict` and `status`. Their
  value lists are NOT a closed set in the gates (merge-gate treats any non-approving
  string as "did not pass"), so a hardcoded list here would make the guard STRICTER
  than the gates it protects (e.g. reject a legitimate English `verdict: NEEDS WORK`).
  The guard's job on these fields is LANGUAGE, not approval: their values are subject
  ONLY to the global ASCII rule below, like every other free-text value. A `model_tier`
  value outside its list = violation, surface "frontmatter enum value".
- FILENAME_SLUG (arch-review IMPORTANT-3): the WHOLE basename must be ASCII and match
  `^[A-Za-z0-9._-]+$` (this alone rejects a non-ASCII filename, the real leak). ADD a
  lowercase-slug check `^[a-z0-9-]+$` ONLY to the human-authored slug TAIL, defined as
  the basename with (a) any leading ISO date `YYYY-MM-DD-`, (b) any leading ID token
  `(PRD|USR|RES|ADR)-NNN-` OR range `(PRD|USR|RES|ADR)-NNN-NNN-` (case-insensitive),
  and (c) the final extension, all stripped. So `2026-07-23-USR-001-no-leak-guardrail.md`
  and `USR-001-006-output-language.md` PASS (their tails are `no-leak-guardrail` and
  `output-language`). A non-ASCII basename, or a tail with uppercase/underscore/other,
  = violation, surface "filename".
- IDENTIFIER surface (arch-review BLOCKING-1): only TOP-LEVEL frontmatter keys are
  checked, a line with NO leading whitespace matching `^([^:[:space:]][^:]*):`. Indented
  / nested YAML lines (e.g. the children under `model_plan:`) are continuation, NOT
  keys, and are SKIPPED, not treated as field names. A checked top-level key must
  match `^[a-z0-9_-]+$` and be ASCII, else violation, surface "frontmatter field name".
  (This is the "code identifier" surface as it appears in this repo's machine-read
  structure: YAML keys. The repo has no source-code files, so identifiers are checked
  where they actually exist.)

Surfaces checked FROM ARGUMENTS (not read from files), because they are git/VCS state,
not file content:
- `--branch <name>`: the branch name must be ASCII and match
  `^[a-zA-Z0-9._/-]+$` (git-legal ASCII branch characters). Non-ASCII or illegal
  char = violation, surface "git branch name". Optional; skipped if not passed.
- `--commit <message>`: the leading `type(scope): ` header is parsed. `type` must be
  in COMMIT_TYPES; `scope` (if present, inside the parens) must match
  `^[a-z0-9-]+$` and be ASCII. A bad type or non-ASCII/illegal scope = violation,
  surface "conventional-commit type" or "conventional-commit scope". Optional.

Surfaces checked FROM PATHS:
- For each directory path given, the directory NAME (basename) must match
  `^[a-z0-9._-]+$` and be ASCII, else violation, surface "directory name".
- For each `.md` file path given, read ONLY its frontmatter (the block between the
  first two `---` lines, exactly like spec-gate/merge-gate parse it) and apply the
  frontmatter FIELD NAME and ENUM VALUE rules above. The filename slug rule applies
  to every file path. Frontmatter body/prose below the closing `---` is NEVER read.
- Non-`.md` file paths (e.g. `bin/*.sh` from the corpus commitment) get filename-only
  treatment: the slug rule, no frontmatter read (arch-review NOTE-B). The awk
  `NR==1 must be ^---$` guard makes this safe anyway, but state it so the builder does
  not parse a shell script's leading lines as frontmatter.

Global ASCII rule (fail-closed core): any checked token containing a byte outside
`0x20-0x7E` (printable ASCII) is a violation regardless of which surface, with the
surface name attached. Implement with a portable test, `LC_ALL=C grep -q '[^ -~]'`,
never a locale-dependent `[[:alpha:]]` class.

Usage:
  language-guard.sh [--branch <name>] [--commit <msg>] <path> [<path>...]
  At least one path OR one of --branch/--commit is required, else exit 2.
  A path that does not exist -> exit 2 (usage error), matching coverage-check's
  "not found -> exit 2" behavior.

Invocation surface (arch-review open question, resolved): the guard accepts arbitrary
caller-supplied paths, and it MUST exit 0 clean on the repo's own real corpus, in
particular `docs/plans/*.md` (nested `model_plan:` keys, date-prefixed names),
`docs/evals/*.md` (range-prefixed names like `USR-001-006-...`), `skills/`, and `bin/`.
The RED tests below include fixtures mirroring each of these shapes so a clean,
English, convention-following file can never fail (USR-001 AC #1, PRD-001 R6 AC).

## Tasks

### Task 1: Failing tests for the guard (RED)
- Scrutiny: standard
- Test first: CREATE `tests/language-guard.test.sh`, modeled EXACTLY on
  `tests/coverage-check.test.sh` (same header, same `assert_exit` / `assert_contains`
  helpers, `set -uo pipefail`, `SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/language-guard.sh"`,
  `TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT`, final `exit $fail`). Write these
  cases (each builds its own fixture):
    1. CLEAN + non-English PROSE passes -> exit 0. Fixture: a `docs/prds/PRD-001-demo.md`
       with valid frontmatter (`id: PRD-001`, `status: draft`) and a body written in
       Croatian prose (non-ASCII letters in the BODY only). Assert exit 0
       and output contains the pass string chosen in Task 2 (keep them in sync).
    2. Non-English ENUM VALUE fails -> exit 1, names file + surface. Fixture: a record
       file with `verdict: PROSAO` in frontmatter. Assert exit 1; assert output
       contains the filename and the substring "enum".
    3. Non-ASCII FRONTMATTER FIELD NAME fails -> exit 1. Fixture: a file whose
       frontmatter has a key containing a non-ASCII byte. Assert exit 1; output
       contains "field name".
    4. Bad FILENAME SLUG fails -> exit 1. Fixture: a file named with uppercase +
       underscore + non-ASCII in the slug. Assert exit 1; output contains the
       filename and "filename".
    5. Non-ASCII DIRECTORY NAME fails -> exit 1. Fixture: a non-ASCII dir name. Pass
       the dir path. Assert exit 1; output contains "directory".
    6. Bad COMMIT TYPE fails -> exit 1. `--commit "napravi(auth): x"`. Assert exit 1;
       output contains "commit type".
    7. Non-ASCII COMMIT SCOPE fails -> exit 1. `--commit "feat(prijavā): x"`. Assert
       exit 1; output contains "scope".
    8. Non-ASCII BRANCH fails -> exit 1. `--branch "feature/prijavā"`. Assert exit 1;
       output contains "branch".
    9. Valid branch + commit + clean files pass -> exit 0.
       `--branch feature/login --commit "feat(auth): add login"` plus a clean file.
   10. Usage: no args -> exit 2. Nonexistent path -> exit 2.
   11. ASCII values pass: `model_tier: strong` passes; `verdict: NEEDS WORK` and
       `status: In Progress` PASS too (only model_tier is a closed list; other fields
       get the ASCII rule only, so a clearly non-slug value must still pass) -> exit 0
       (guards against over-strict rejection and against out-stricting the gates,
       arch-review BLOCKING-2 + NOTE-A).
   12. Nested frontmatter keys pass (arch-review BLOCKING-1). Fixture: a plan-shaped
       file with `model_plan:` and indented children (`  judgment: x`, `  builder: y`).
       The indented lines must NOT be treated as field names. Assert exit 0.
   13. Date-prefixed and range-prefixed filenames pass (arch-review IMPORTANT-3).
       Fixtures named `2026-07-23-USR-001-no-leak-guardrail.md` and
       `USR-001-006-output-language.md`, both clean ASCII. Assert exit 0.
   14. Commit scope is optional (arch-review IMPORTANT-4): `--commit "feat: no scope"`
       and `--commit "chore(deps): x"` both pass -> exit 0.
- Implement: none in this task (script does not exist yet).
- Verify: `bash tests/language-guard.test.sh` runs and FAILS (script missing). This
  is the RED state; record it.
- Consumes: the gate contract from `bin/coverage-check.sh` (test harness shape).
- Produces: the exact behavioral spec Task 2 must satisfy; the exact pass-string and
  failure-substrings ("enum", "field name", "filename", "directory", "commit type",
  "scope", "branch") that Task 2's stderr messages must contain.
- Commit: `test(language-guard): failing spec for machine-surface no-leak gate`

### Task 2: Implement bin/language-guard.sh (GREEN)
- Scrutiny: judgment (fail-closed correctness + the ASCII/locale portability is the
  riskiest part; give it the hardest look).
- Test first: already written in Task 1; do NOT weaken any assertion. If a case is
  wrong, fix it explicitly and say so, never soften it to pass.
- Implement: CREATE `bin/language-guard.sh` following the coverage-check.sh header
  and style conventions. Exact structure:
    - Shebang `#!/usr/bin/env bash`; header comment block (purpose, usage, exit codes,
      "machine-read and language-independent: keys off tokens, never prose"), then
      `set -uo pipefail` (use `-uo pipefail`, NOT `-e`, so a single violation does not
      abort the scan before all files are reported).
    - `usage()` -> prints the usage line to stderr, `exit 2`.
    - Define the allowlists as the exact arrays/strings named in the Scope contract.
    - Argument parse loop: consume `--branch <name>` and `--commit <msg>`; collect the
      rest as PATHS. Empty PATHS AND no --branch/--commit -> usage/exit 2. A path that
      is not `-e` -> "language-guard: path not found: <p>" to stderr, exit 2.
    - Helper `is_ascii()`: `printf '%s' "$1" | LC_ALL=C grep -q '[^ -~]' && return 1; return 0`.
    - Helper `viol()`: `echo "language-guard: FAIL, <file> <surface>: <reason>" >&2; fail=1`.
    - Frontmatter reader: reuse the awk pattern from spec-gate.sh (NR==1 must be
      `^---$`; stop at next `^---$`). For each line, consider it a key ONLY if it has
      NO leading whitespace and matches `^([^:[:space:]][^:]*):` (top-level key);
      indented/nested lines (children of e.g. `model_plan:`) are SKIPPED, never keys
      (arch-review BLOCKING-1). For a top-level key: check it matches `^[a-z0-9_-]+$`
      and is_ascii -> else viol "frontmatter field name". If the key is `model_tier`
      (the ONLY enum field), lowercase the value and check membership in
      `fast|strong|strongest` -> else viol "frontmatter enum value". All other field
      values get the global ASCII rule only (no closed-list check), so the guard never
      out-stricts the gates (arch-review BLOCKING-2).
    - Filename slug: whole basename is_ascii and `^[A-Za-z0-9._-]+$` -> else viol
      "filename". Then strip a leading ISO date `YYYY-MM-DD-`, a leading
      `(PRD|USR|RES|ADR)-NNN-` or `(PRD|USR|RES|ADR)-NNN-NNN-` (case-insensitive), and
      the final extension; the remaining TAIL must match `^[a-z0-9-]+$` -> else viol
      "filename". So date-/range-/ID-prefixed repo names pass (arch-review IMPORTANT-3).
    - Directory: basename matches `^[a-z0-9._-]+$` and is_ascii -> else viol
      "directory name".
    - Branch (if --branch): is_ascii and `^[a-zA-Z0-9._/-]+$` -> else viol "git branch
      name".
    - Commit (if --commit): parse `^([a-z]+)(\(([^)]*)\))?: `; the scope group is
      OPTIONAL (both `feat: x` and `chore(deps): x` are valid, arch-review IMPORTANT-4).
      type in COMMIT_TYPES -> else viol "conventional-commit type"; IF a scope is
      present, it must be is_ascii and `^[a-z0-9-]+$` -> else viol
      "conventional-commit scope". No parseable `type: ` / `type(scope): ` header ->
      viol "conventional-commit type".
    - End: `if [[ $fail -eq 0 ]]; then echo "language-guard: machine surfaces clean."; exit 0; fi; exit 1`.
  Comments English only; no em/en dashes; small helpers.
- Verify: `bash tests/language-guard.test.sh` -> all "ok:", exit 0 (GREEN). Then
  `bash -n bin/language-guard.sh` exits 0.
- Consumes: the failure-substring contract from Task 1; the frontmatter-parse awk
  idiom from `bin/spec-gate.sh` and the CRLF/`tr -d '\r'` idiom from
  `bin/coverage-check.sh`.
- Produces: `bin/language-guard.sh` with the CLI
  `language-guard.sh [--branch <name>] [--commit <msg>] <path>...`, exit 0/1/2.
- Commit: `feat(language-guard): deterministic no-leak gate for machine surfaces`

### Task 3: Regression, existing gates stay green on a clean non-English project
- Scrutiny: standard
- Test first: no NEW test file; this PROVES the story's fourth acceptance criterion.
  If any suite fails, STOP; do not edit the neighbor's test to pass.
- Implement: none (verification-only task).
- Verify: `for t in tests/*.test.sh; do echo "== $t"; bash "$t" || echo "SUITE FAILED: $t"; done`
  Expected: no "SUITE FAILED"; skills-lint, spec-gate, merge-gate green.
- Consumes: the whole `tests/` suite.
- Produces: evidence the guard is additive (no regression).
- Commit: none (verification gate the reviewer re-runs).

### Task 4: Register the guard in the system map
- Scrutiny: mechanical
- Test first: none (documentation).
- Implement:
    - READ `docs/system-map.md` first for its row format, then REGISTER
      `bin/language-guard.sh` alongside the other bin/*.sh gates
      (coverage-check/spec-gate/merge-gate): what it does (deterministic no-leak gate
      for machine surfaces), its exit-code contract, and that it is standalone /
      explicitly invoked. NOT `docs/invariants.md` (that is the skills-lint C<n>
      registry; language-guard is not a skills-lint check, arch-review NOTE-5).
      Match the file's style; no em/en dashes.
    - Do NOT modify `skills-lint.sh`, `merge-gate.sh`, `spec-gate.sh`, or
      `coverage-check.sh` logic. The guard is standalone (like coverage-check).
- Verify: `grep -n language-guard docs/system-map.md` shows the entry; re-run
  `bash tests/skills-lint.test.sh` -> green.
- Consumes: `bin/language-guard.sh` from Task 2.
- Produces: a system-map entry; a discoverable entry point.
- Commit: `docs(system-map): register the language-guard no-leak gate`

## Risks / open questions (arch-review v1 resolutions folded in)
- Wiring point (RESOLVED, standalone): the guard ships standalone and explicitly
  invoked, mirroring `coverage-check.sh` (also not auto-wired). Auto-wiring R6 into
  `/commit-push` or `/build` touches flow files owned by USR-002..006 and is a separate
  approved change later. Because it is standalone, discoverability matters, hence
  Task 4 registers it in `docs/system-map.md`.
- Enum vocabulary (RESOLVED, BLOCKING-2): only `model_tier` is a closed list (canonical
  in both gates). `verdict`/`status` get the ASCII rule only, so the guard cannot
  out-strict the gates. A shared single-source vocabulary file for all gates is a
  possible later refactor, not this story.
- Nested frontmatter keys (RESOLVED, BLOCKING-1): only top-level keys are checked;
  indented lines are skipped. Fixture case 12 locks it.
- Filename prefixes (RESOLVED, IMPORTANT-3): date/ID/range prefixes are stripped before
  the lowercase-tail check; whole basename still must be ASCII. Fixture case 13 locks it.
- "Code identifier" surface: no product source in this bash+markdown repo, so
  identifiers are YAML frontmatter field names (where identifiers actually exist). A
  future product-source identifier scanner is a separate story.
- Locale portability: the fail-closed ASCII core must use `LC_ALL=C grep '[^ -~]'`,
  never a locale-sensitive class. Task 2's judgment-scrutiny point.
