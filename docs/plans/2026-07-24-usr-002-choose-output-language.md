# Plan: USR-002 Choose output language at setup
approved: yes
model_plan:
  judgment: session strongest effort high
  builder: sonnet -> (harness-resolved sonnet tier) effort high
arch_review: clean (v3, 2026-07-24; v1 had 1 blocking + 2 important, v2 fixed them, v3 fixed one stale verify grep the reviewer pre-approved)

## Header
Goal: a PM/builder picks their output language once at project setup (default
  English, skippable), stored as one canonical CLAUDE.md line, with a
  deterministic resolver that scripts and setup use to find the effective code.
Serves: PRD-001 outcome, a non-English PM/builder runs the Odeo lifecycle in
  their language after a single setup choice, while mechanics stay English.
  This story covers R1 (resolution by precedence) and R5 (the per-project setup
  prompt, R5b only).
Architecture context: this repo's tooling is deterministic POSIX-bash gates in
  `bin/` with matching test scripts in `tests/` (style: `set -uo pipefail`,
  `LC_ALL=C` for character classes, `tr -d '\r'` for CRLF, exit 0/1/2). Storage
  of preferences is a CLAUDE.md line (per-project) mirroring the existing
  frontmatter/config conventions. Project scaffolding lives in
  `bin/init-project.sh`; the interactive configuration lives in
  `skills/setup-project/SKILL.md`. USR-001 already shipped `bin/language-guard.sh`
  which protects machine surfaces; `output_language` MUST NOT be a machine
  surface it reads (it lives in prose/config, not frontmatter enums).
Constraints (verbatim from story + inherited):
  - "asks for the language exactly once; the offered set is English (default),
    German, Croatian, French."
  - "Skipping the question resolves to English."
  - "written as one line in the project's CLAUDE.md in the exact form
    `output_language: <code>`, where `<code>` is one of `en`, `de`, `hr`, `fr`."
  - "A global default can be set once and is used when a project has no line."
  - "The effective language resolves by precedence: the project line, else the
    global default, else English."
  - "Editing the CLAUDE.md line (or re-running setup) changes the effective
    language on the next generation."
  - Machine surfaces stay English (R3): the resolver READS a value, it localizes
    nothing. No version-pinned model names. English-only code comments. No
    em/en dashes in any text. TDD for the resolver (logic with clear rules).
  - DO NOT build: USR-003 global-install prompt, USR-004 `/language` command,
    USR-005 prose localization, USR-006 mismatch warning.

## Precedence rules and CLAUDE.md line format (the contract, exact)

Canonical line (written into a project's `CLAUDE.md`, one line, its own line):
    output_language: <code>
where `<code>` is exactly one of: `en` `de` `hr` `fr` (lowercase ASCII).

Resolution precedence, evaluated by `bin/resolve-language.sh <project-dir>`:
  1. Project override: the first `^output_language:` line in
     `<project-dir>/CLAUDE.md`, if present AND its value is a valid code.
  2. Global default: the first `^output_language:` line in the user global
     CLAUDE.md at `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`, if present
     AND valid. (Uses an env-overridable path so tests never touch the real
     `$HOME`; matches the `CLAUDE_TEMPLATES_DIR` override pattern already in
     `init-project.sh`. USR-003 will WRITE this line; USR-002 only READS it.)
  3. Fallback: `en`.
The resolver echoes exactly the effective code and a trailing newline, exit 0.

Value normalization (deterministic, order matters):
  - Read the value after the first colon, strip CR (`tr -d '\r'`), strip
    surrounding whitespace, lowercase it (`tr '[:upper:]' '[:lower:]'`).
  - A malformed/unknown value at a level (e.g. `output_language: klingon`) is
    treated as ABSENT at that level, resolution falls through to the next level.
    Rationale: never echo an invalid code; degrade to the safe default. This is
    a deliberate design choice, flagged in Risks for the human to confirm.
  - Only the FIRST `output_language:` line at each level is considered; a
    duplicate later line is ignored (matches `grep -m1` convention in the repo).

Usage / errors (mirrors coverage-check.sh + language-guard.sh style):
  - No argument, or more than one argument -> usage to stderr, exit 2.
  - `<project-dir>` does not exist or is not a directory -> error to stderr,
    exit 2.
  - `<project-dir>` exists but has no CLAUDE.md, or CLAUDE.md has no valid
    line -> NOT an error, fall through to global then `en`, exit 0.

## Success signal (observable, binary)
- `bash tests/resolve-language.test.sh` exits 0 (all cases pass), including:
  project override wins; falls back to global; falls back to `en`; skip/no-line
  is `en`; invalid value degrades; usage errors exit 2.
- Running `bin/init-project.sh <name>` (interactive TTY) asks the language once
  and writes exactly one `output_language: <code>` line into the project's
  CLAUDE.md; non-interactive run writes `output_language: en`.
- `skills/setup-project/SKILL.md` documents the single language question and the
  canonical line so the setup skill asks it during `/setup-project`.
- `bash tests/language-guard.test.sh` still exits 0 (the new line does not
  appear in any frontmatter machine surface, so the guard is unaffected).

## File map (before any tasks)
- bin/resolve-language.sh          CREATE: deterministic effective-language
    resolver; `resolve-language.sh <project-dir>` echoes the code, exit 0;
    usage/dir errors exit 2. Owns precedence + normalization. No dependencies.
- tests/resolve-language.test.sh   CREATE: test script for resolve-language.sh,
    same harness style as tests/coverage-check.test.sh (assert_exit /
    assert_contains, mktemp sandbox, CLAUDE_GLOBAL_CONFIG override).
- bin/init-project.sh              MODIFY: add the one-time language prompt
    (English default, skippable, offered set en/de/hr/fr) and append the
    `output_language:` line to the scaffolded CLAUDE.md; add a `--language
    <code>` flag and a non-interactive default of `en`. Owns scaffold-time write.
- project-templates/CLAUDE.md      MODIFY: add a commented placeholder anchor in
    the `## Conventions` section so the written line has a documented home
    (`output_language:` alongside `dev_rigor:` / `teach_me_as_i_go:`).
- skills/setup-project/SKILL.md    MODIFY: add the language question to the
    interview (new step, English default, skippable) and record that it writes
    the canonical `output_language: <code>` line into CLAUDE.md Conventions.

## Tasks

### Task 1: resolve-language resolver + tests (TDD)
- Scrutiny: judgment (precedence + normalization + fail-closed degrade is the
  logical core of the story; get this exactly right).
- Test first (dev_rigor for this repo's bash gates is TDD): CREATE
  `tests/resolve-language.test.sh`, run it, watch it FAIL (script absent ->
  non-zero). Use the exact harness of `tests/coverage-check.test.sh`:
  `set -uo pipefail`; `SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/resolve-language.sh"`;
  `assert_exit` and `assert_contains` helpers; `TMP="$(mktemp -d)"` +
  `trap 'rm -rf "$TMP"' EXIT`. Cases (each asserts exit code and, where noted,
  the echoed code via `assert_contains`):
    1. Project override wins over global: project CLAUDE.md has
       `output_language: de`, global (a temp file via `CLAUDE_GLOBAL_CONFIG`) has
       `output_language: fr` -> echoes `de`, exit 0.
    2. Falls back to global when no project line: project CLAUDE.md has no
       `output_language:` line, global has `output_language: hr` -> echoes `hr`,
       exit 0.
    3. Falls back to `en` when neither present: project CLAUDE.md exists without
       the line, `CLAUDE_GLOBAL_CONFIG` points at a nonexistent file -> echoes
       `en`, exit 0.
    4. No CLAUDE.md at all in project dir -> echoes `en`, exit 0 (skip case).
    5. All four valid codes round-trip: for each of en/de/hr/fr as a project
       line -> echoes that code, exit 0.
    6. Invalid project value degrades to global: project `output_language:
       klingon`, global `output_language: fr` -> echoes `fr`, exit 0.
    7. Invalid at both levels degrades to en: project `output_language: xx`,
       global `output_language: yy` -> echoes `en`, exit 0.
    8. Whitespace/uppercase/CR tolerated: a line written as
       `output_language:   DE ` (trailing CR simulated with `$'\r'`) -> echoes
       `de`, exit 0.
    9. First line wins on duplicates: two project lines `output_language: fr`
       then `output_language: de` -> echoes `fr`, exit 0.
   10. Usage error, no args: `"$SCRIPT"` with no argument -> exit 2, stderr
       contains `usage`.
   11. Usage error, too many args: `"$SCRIPT" a b` -> exit 2.
   12. Nonexistent project dir: `"$SCRIPT" "$TMP/nope"` -> exit 2, stderr
       contains `not found` (or the chosen message; assert on the substring the
       implementation prints).
  For cases needing a global file, export `CLAUDE_GLOBAL_CONFIG="$TMP/global.md"`
  per case and write the fixture; for the "no global" case point it at
  `"$TMP/absent.md"` and do not create the file. NEVER read the real
  `$HOME/.claude/CLAUDE.md` in tests.
- Implement: CREATE `bin/resolve-language.sh`. Exact shape:
    - Shebang `#!/usr/bin/env bash`; header comment (English) describing purpose,
      usage, exit codes, and that it READS a value and localizes nothing.
    - `set -uo pipefail` (match language-guard.sh, which needs to keep running
      after non-fatal greps; do NOT use `-e` so a no-match grep does not abort).
    - `usage() { echo "usage: resolve-language.sh <project-dir>" >&2; exit 2; }`
    - `[ "$#" -eq 1 ] || usage`
    - `PROJECT_DIR="$1"`;
      `[ -d "$PROJECT_DIR" ] || { echo "resolve-language: project dir not found: $PROJECT_DIR" >&2; exit 2; }`
    - `VALID="en de hr fr"`
    - `GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"`
    - A helper that reads and normalizes the first line from a file:
      ```
      read_lang() { # FILE -> echoes a valid code or nothing
        local file="$1"
        [ -f "$file" ] || return 0
        local raw
        raw="$(grep -m1 -E '^output_language:' "$file" 2>/dev/null || true)"
        [ -n "$raw" ] || return 0
        local val
        val="$(printf '%s' "$raw" | sed -E 's/^output_language:[[:space:]]*//' \
              | tr -d '\r' | tr '[:upper:]' '[:lower:]' \
              | sed -E 's/[[:space:]]+$//')"
        local c
        for c in $VALID; do [ "$val" = "$c" ] && { printf '%s' "$c"; return 0; }; done
        return 0   # invalid -> echo nothing, caller falls through
      }
      ```
    - Resolution:
      ```
      lang="$(read_lang "$PROJECT_DIR/CLAUDE.md")"
      [ -n "$lang" ] || lang="$(read_lang "$GLOBAL_CONFIG")"
      [ -n "$lang" ] || lang="en"
      printf '%s\n' "$lang"
      exit 0
      ```
    - `chmod +x bin/resolve-language.sh` after creating it.
  Comments English only; no dashes-as-punctuation in comments; no model names.
- Verify:
    - `bash tests/resolve-language.test.sh; echo "exit=$?"` -> all lines `ok:`,
      final `exit=0`.
    - `bash bin/resolve-language.sh 2>&1; echo $?` -> prints usage, `2`.
- Consumes: nothing (leaf utility). Reads `CLAUDE_GLOBAL_CONFIG` env override.
- Produces: `bin/resolve-language.sh <project-dir>` -> stdout = effective code
  (`en|de|hr|fr`), exit 0; exit 2 on usage/dir error. Consumed by Task 2 and by
  future stories (USR-005 prose localization) as the single source of truth for
  the effective language.
- Commit: `feat(lang): add deterministic output-language resolver with precedence`

### Task 2: wire the setup-time prompt into init-project.sh
- Scrutiny: standard (bash prompt wiring, mirrors the existing UI-question and
  git-email-question patterns already in the file).
- Test first (dev_rigor TDD; this is scriptable I/O, so keep it under test):
  Add cases to a small CREATE test `tests/init-project.language.test.sh`
  (same harness). Because `init-project.sh` requires `~/.claude-templates`, the
  test sets `CLAUDE_TEMPLATES_DIR="$TMP/templates"` and stages the minimal
  REQUIRED_TEMPLATES set (empty files are enough: CLAUDE.md with a Conventions
  anchor line, tasks/todo.md, tasks/lessons.md, docs/ADR-TEMPLATE.md,
  design/tokens.json, design/README.md, knowledge/README.md). Run from inside
  `$TMP`. Cases:
    1. Non-interactive `--no-ui --language de` (stdin not a TTY): after the run,
       `grep -c '^output_language: de' <project>/CLAUDE.md` is `1`.
    2. Non-interactive with no `--language` flag: the project CLAUDE.md contains
       exactly one `output_language: en` line (skip/default -> English).
    3. Invalid `--language klingon` -> exit non-zero, message to stderr, no
       project created (fail fast on a bad explicit flag).
    4. Exactly one line: `grep -c '^output_language:' <project>/CLAUDE.md` is `1`
       (asked once, written once).
    5. `--language` with NO following value -> exit non-zero, stderr says it needs
       a value, no project created (arch-review BLOCKING-1 missing-value case).
  Interactive TTY prompting is NOT unit-tested here (no TTY in the harness); the
  non-interactive path plus the flag give deterministic coverage. Run the test,
  watch cases 1 to 4 FAIL before the change.
- Implement: MODIFY `bin/init-project.sh`:
    - **Convert the arg loop from `for arg in "$@"` to `while [ "$#" -gt 0 ]` +
      `shift` (arch-review BLOCKING-1).** A `for arg` loop cannot consume the value
      token of a two-token `--language <code>` flag. Rewrite as:
      ```
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --no-ui)     UI=no; shift ;;
          --ui)        UI=yes; shift ;;
          --no-design) DESIGN=no; shift ;;
          --language)  [ "$#" -ge 2 ] || { echo "--language needs a value (en|de|hr|fr)" >&2; exit 1; }
                       LANGUAGE="$2"; shift 2 ;;
          -*)          echo "Unknown option: $1" >&2; exit 1 ;;
          *)           PROJECT_NAME="$1"; shift ;;
        esac
      done
      ```
      PRESERVE every existing flag and the `-*` unknown-option arm and the
      positional PROJECT_NAME capture exactly as they are today; only the loop
      SHAPE changes. Add a `LANGUAGE=""` default (empty = ask/default). Validate a
      provided value against `en de hr fr`; on invalid: `echo "Unknown language:
      $LANGUAGE (allowed: en de hr fr)" >&2; exit 1` BEFORE any directory is
      created. A `--language` with no following value exits non-zero (handled in
      the case above).
    - After the existing UI resolution block and before `echo "Creating
      project"`, resolve the language:
      ```
      if [[ -z "$LANGUAGE" ]]; then
        if [[ -t 0 ]]; then
          echo ""
          echo "  Output language for generated docs (PRDs, stories, plans, reviews)."
          echo "  Code and mechanics always stay English."
          read -r -p "  Language? [E]nglish (default) / [d]e German / [h]r Croatian / [f]r French: " _lang_ans || _lang_ans=""
          case "$_lang_ans" in
            [Dd]*) LANGUAGE=de ;;
            [Hh]*) LANGUAGE=hr ;;
            [Ff]*) LANGUAGE=fr ;;
            *)     LANGUAGE=en ;;   # Enter/skip/English -> en
          esac
        else
          LANGUAGE=en   # non-interactive default
        fi
      fi
      ```
    - After the template copy of `CLAUDE.md` and before the final `git add -A`,
      write the line IDEMPOTENTLY into the Conventions section. If the template
      already carries an `output_language:` placeholder line (added in Task 3),
      replace it in place; else append under `## Conventions`. Exact code:
      ```
      # Persist the chosen output language as the canonical single line.
      # Machine surfaces stay English; this only tells generators which language
      # to write user-facing prose in (resolved by bin/resolve-language.sh).
      # Both branches use mktemp + mv for consistency (arch-review IMPORTANT-2);
      # under init-project.sh's `set -e`, a failed awk/sed aborts before mv, so no
      # half-written CLAUDE.md.new is ever left in the scaffold for `git add -A`.
      if grep -qE '^output_language:' CLAUDE.md; then
        tmp_claude="$(mktemp)"
        sed -E "s/^output_language:.*/output_language: ${LANGUAGE}/" CLAUDE.md > "$tmp_claude"
        mv "$tmp_claude" CLAUDE.md
      elif grep -qE '^## Conventions' CLAUDE.md; then
        tmp_claude="$(mktemp)"
        awk -v line="output_language: ${LANGUAGE}" '
          { print }
          /^## Conventions/ && !done { print ""; print line; done=1 }
        ' CLAUDE.md > "$tmp_claude"
        mv "$tmp_claude" CLAUDE.md
      else
        printf '\noutput_language: %s\n' "${LANGUAGE}" >> CLAUDE.md
      fi
      ```
      Note (arch-review NOTE-4): a project started from a PRESET
      (`~/.claude-templates/presets/*.md`) may carry a CLAUDE.md WITHOUT the
      Task-3 anchor, so the append branch is the LOAD-BEARING path for preset
      users, not a rare fallback. Task 2 case 2 (no-anchor append -> exactly one
      line) is the primary coverage, and re-running setup on such a project must
      still yield exactly one `output_language:` line (the sed-replace branch then
      handles the second run).
    - Do NOT add USR-004 `/language` references (out of scope).
- Verify:
    - `bash tests/init-project.language.test.sh; echo "exit=$?"` -> all `ok:`,
      `exit=0`.
- Consumes: `en de hr fr` value set (same list as Task 1; keep the list literal
  in each script, do not over-engineer a shared source for two files).
- Produces: a scaffolded project whose CLAUDE.md carries exactly one canonical
  `output_language:` line, resolvable by Task 1's script.
- Commit: `feat(setup): prompt for output language once and write the CLAUDE.md line`

### Task 3: document the line in the CLAUDE.md template + setup-project skill
- Scrutiny: mechanical (documentation/anchor edits; no logic).
- Test first: none required (pure docs/template text; test-after N/A by nature).
  The behavioral guarantee is covered by Task 2 case 4 and Task 1.
- Implement:
    - MODIFY `project-templates/CLAUDE.md`, in the `## Conventions` section,
      directly under the `teach_me_as_i_go:` bullet, add a documentation comment
      line followed by the canonical machine line at COLUMN 0 (value only, no
      trailing prose on the value line), arch-review IMPORTANT-3:
      ```
      Output language for generated user-facing prose (PRDs, stories, plans, reviews); one of en|de|hr|fr; set by /setup-project. Code, comments, filenames, and all machine-read fields stay English regardless.
      output_language: en
      ```
      The canonical line is EXACTLY `output_language: en` at column 0 (value only),
      so the resolver's `^output_language:` grep and Task 2's `^output_language:`
      sed both match it, and the sed-replace loses no prose (there is none on that
      line). The documentation sentence above does NOT start with `output_language:`
      at column 0, so it is never matched or counted. `en` is the safe default if
      setup is skipped. (This resolves the v1 contradiction where a `- ` bullet
      form matched neither the resolver nor the writer.)
    - MODIFY `skills/setup-project/SKILL.md`: add a short interview step grouped
      with the other preference questions (right after the talk-to-you step I,
      before Security & Data J). Label it as a deliberate sub-step of the
      preferences group (arch-review NOTE-5: `I2` is intentional, do not "fix" the
      numbering; it keeps the language pref beside the other Conventions prefs):
      ```
      **I2. Output language for generated docs**
      > "Which language should I WRITE your documents in, PRDs, user stories,
      >  plans, review write-ups? Code, comments, filenames, and commit messages
      >  always stay English. English (default), German, Croatian, or French?"
      Record it in the CLAUDE.md Conventions section as the single canonical line
      `output_language: <code>` where <code> is one of en|de|hr|fr (default en if
      skipped). Same line `bin/init-project.sh` writes at scaffold time;
      re-running setup updates it. Do not add a change-anytime command here.
      ```
    - Do NOT touch any machine-read frontmatter, gate token, or the language-guard
      allowlists (the line is prose config, not a frontmatter enum).
- Verify:
    - `grep -c '^output_language:' project-templates/CLAUDE.md` -> `1` (column-0
      canonical line; the prose sentence above is not matched).
    - `grep -n 'I2. Output language' skills/setup-project/SKILL.md` -> one hit.
    - `bash tests/language-guard.test.sh; echo "exit=$?"` -> `exit=0`.
- Consumes: the line format from the contract section above.
- Produces: the documented home for the line; the setup skill's question wording.
- Commit: `docs(lang): document output_language line in CLAUDE.md template and setup skill`

## Task order and parallelism
Sequential: Task 1 (resolver) -> Task 3 (template anchor, so Task 2's `sed`
replaces rather than appends) -> Task 2 (init-project wiring). Task 2's case 2
still covers the no-anchor append path. One builder, one session.

## Risks / open questions (confirmed defaults; override at the gate)
1. Global config path: resolver reads `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/
   CLAUDE.md}`. PRD-001 open question #1 leans this way; USR-003 will WRITE it.
   Confirm the path now so USR-003 need not move it. Lookup path only, not a
   product-architecture change.
2. Invalid-value handling: degrades to the next level (ultimately `en`) rather
   than erroring; keeps generation safe. Story text ("resolves ... else English")
   supports degrade. Judgment call, flagged.
3. Codes only, no full names: USR-002 ACs pin the stored form to the code, so the
   plan stores/resolves codes only (PRD open question #2 about name-input is not
   adopted here).
4. Interactive TTY prompt not unit-tested (no TTY harness in-repo); coverage via
   non-interactive path + `--language` flag. Defer an expect-style harness.
5. R4 (public Odeo repo resolves to `en`) is NOT in USR-002's covers (R1+R5); not
   implemented here by design, it belongs to another story.

## Explicitly NOT built (guardrail)
- USR-003 global-install prompt (writing the global line). Resolver only READS it.
- USR-004 `/language` change command.
- USR-005 prose localization (skills/agents writing in the language).
- USR-006 prose-language mismatch warning.
Each is left as a clean seam; the resolver is the shared entry point they call.
