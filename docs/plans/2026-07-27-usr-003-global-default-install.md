# Plan: USR-003 Set a global default language at plugin install
approved: yes (human, 2026-07-27)
model_plan:
  judgment: session strongest effort high
  builder: sonnet tier (harness-resolved) effort high; NOTE this session builds in-thread
    (non-git session root blocks the builder-agent worktree), so the build runs on the
    session model, not a dispatched sonnet builder.
arch_review: clean (v1, 2026-07-27). architecture-reviewer CLEAN-WITH-NITS: the load-bearing
  claim (resolver already reads ${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}; installer only
  writes, no resolver change) verified against resolve-language.sh:37,48,60-62. Findings folded
  below: IMPORTANT-1 (install.sh set -u/-e handling for the new --lang path); NIT-1 (grep runs
  against $GLOBAL_CONFIG only); NIT-2 (assert exactly-one line on skip); NIT-3 (flag-parse order
  independence). Risk 4 narrower than first stated (step 4 cp's, does not symlink ~/.claude/CLAUDE.md
  even under --link), guard kept as a cheap fail-safe. OPEN for the human at the gate: confirm
  the --link behavior (skip-with-note).

## Header
Goal: at plugin install / first run, ask the user their output language exactly once (English default, plus de/hr/fr, skippable), store it as the GLOBAL default that `bin/resolve-language.sh` already reads, and never re-ask on re-install or per project.

Serves: PRD-001 outcome, a non-English PM/builder runs the whole Odeo lifecycle in their language after a single setup choice, while code and mechanics stay English. This story covers R5(a): the one-time GLOBAL install prompt.

Architecture context (inherited, not redecided):
- Tooling is deterministic POSIX-bash scripts in `bin/` with matching test scripts in `tests/*.test.sh`; style is `set -uo pipefail`, `LC_ALL=C` for character classes, `tr -d '\r'` for CRLF, exit 0/1/2, `mktemp` fixtures, TDD RED-first for logic. Guardrail rules are split `[E]` enforced vs `[I]` instructed in AGENTS.md.
- Preferences are stored as a single `output_language: <code>` line. The GLOBAL default lives in the user config at `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`, which is EXACTLY the path `bin/resolve-language.sh` (USR-002, already shipped) reads for the global precedence level. USR-003 WRITES that line; it does not change how it is read.
- The allowlist of codes (`en de hr fr`) is USR-002's. This story must not fork it; the new helper carries its own literal copy in the same spirit as `resolve-language.sh` and `init-project.sh` (each file self-contained, no cross-file sourcing), and the set must be identical.
- `install.sh` is the install entrypoint. It is `set -euo pipefail`, idempotent by design ("Safe to re-run"), and step 4 is where the global baseline `~/.claude/CLAUDE.md` is placed. The install prompt hooks in immediately AFTER step 4, because the file it writes into must exist first.

Constraints (verbatim from the story + inherited):
- "On plugin install / first run, the user is asked for a language exactly once; the offered set is English (default), German, Croatian, French."
- "Skipping resolves to English."
- "The choice is stored as the GLOBAL default (user level), not inside any single project."
- "A project with no `output_language` line inherits this global default."
- "The install prompt is not shown again during later project setups."
- Inherited: machine surfaces stay English (the value is a code, ASCII, allowlisted); no version-pinned model names; English-only code comments; no em/en dashes in any text; TDD RED-first for the deterministic helper.
- DO NOT build: USR-004's `/language` change command (this plan makes the write helper reusable so USR-004 can call it, but adds no `/language` command); USR-005 prose localization; USR-006 mismatch warning; any change to `bin/resolve-language.sh` read logic; any change to `bin/init-project.sh` (its per-project prompt is USR-002 and must not be re-triggered or duplicated).

## Design decisions (resolved, so the builder does not guess)

1. **Where the global default is stored:** the `output_language:` line in the user config at `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`. This is the SAME location `resolve-language.sh` reads today for its global precedence level. No resolver change is needed; USR-002 explicitly deferred the WRITE of this line to USR-003. We reuse the exact env-overridable path so tests never touch the real `$HOME`.

2. **Prompt hook point + write mechanism:** a new reusable helper `bin/set-global-language.sh` does the idempotent write (validate code, insert-or-skip the line). `install.sh` calls it once, right after step 4 places `~/.claude/CLAUDE.md`. Keeping the write in a helper (a) keeps `install.sh` thin, (b) is independently testable with `mktemp` fixtures, and (c) gives USR-004 a ready call site later.

3. **"Asked exactly once, never re-asked" (idempotence):** the helper is the single gatekeeper. If the global config already contains an `^output_language:` line, the helper writes nothing and reports "already set" (exit 0). So re-running `install.sh` never re-prompts. Skipping in the prompt still writes `output_language: en`, so a subsequent install also sees a line and does not re-ask. Per-project setups (`init-project.sh`, `/setup-project`) are untouched: they write the PROJECT line only and never read/prompt the global.

4. **Non-interactive / CI safety:** the prompt lives in `install.sh` and is guarded by `[ -t 0 ]`, the same idiom `init-project.sh` uses. In a non-interactive install the branch writes `output_language: en` without reading, so install never hangs. An explicit escape hatch is provided: `install.sh --lang <code>` (and `ODEO_INSTALL_LANG`) sets it without prompting.

5. **The allowed set:** `en de hr fr`, identical to USR-002. Default (skip / Enter / unrecognized) resolves to `en`, matching `init-project.sh`.

## File map (before any tasks)
- `bin/set-global-language.sh`   CREATE: reusable, idempotent writer of the global `output_language:` line into `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`; validates the code against `en de hr fr`; skips if a line already exists (never re-asks); exit 0/1/2.
- `tests/set-global-language.test.sh`   CREATE: TDD RED-first tests for the helper (write, idempotent skip, invalid code, usage errors, config-absent).
- `install.sh`   MODIFY: after step 4 (global baseline placement), add a one-time global-language step: parse a new `--lang <code>` flag + `ODEO_INSTALL_LANG` env; prompt only when interactive and not already set; delegate the write to `bin/set-global-language.sh` (called by absolute `$REPO_DIR/bin/...` path, not via PATH). Add a `--link` symlink guard (see Risk 4).
- `docs/public-paths.txt`   NO CHANGE NEEDED (verify only): `bin/` and `tests/` are already public directory prefixes, so both new files are classified public automatically; `install.sh` is already listed. The builder must confirm `publish-guard --require-allowlist` stays clean.

## Tasks

### Task 1: The idempotent global-language writer `bin/set-global-language.sh`
- Scrutiny: judgment (idempotence + write logic is the heart of "asked once"; get it wrong and install re-prompts or corrupts the user's global config).
- Test first (TDD, RED before the script exists): create `tests/set-global-language.test.sh` in the exact style of `tests/resolve-language.test.sh` (`set -uo pipefail`, `mktemp -d`, `trap`, `assert_exit`/`assert_contains`, `SCRIPT=...bin/set-global-language.sh`). Every case overrides `CLAUDE_GLOBAL_CONFIG` so no real `$HOME` is touched. Cases:
  1. Fresh write into a config with no line -> exit 0, one `output_language: de` line.
  2. Idempotent skip: config already has `output_language: fr`; `set ... de` -> exit 0, file STILL `fr`, `grep -c '^output_language:' "$cfg"` equals `1` (NIT-2: assert the count so a future append-on-skip bug is caught), output says `already set`.
  3. Skip-writes-en: no line; `set ... en` -> exit 0, one `output_language: en` line.
  4. All four codes round-trip: en de hr fr each (fresh config) -> exit 0, `grep -c '^output_language:'` equals `1` and it is the matching code.
  5. Invalid code `klingon` -> exit 1, stderr names it + lists `en de hr fr`; config NOT modified.
  6. Missing code arg -> exit 2, stderr `usage`.
  7. Too many args (`de fr`) -> exit 2.
  8. Config file absent (parent dir exists) -> exit 0, file created with one `output_language: hr` line.
  Run -> RED (script absent).
- Implement `bin/set-global-language.sh`: `set -uo pipefail`; usage()->exit 2; require exactly 1 arg; validate against literal `VALID="en de hr fr"` (exit 1 on miss); `GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"`; idempotence gate: if the file exists and `grep -qE '^output_language:'`, print "already set" and exit 0; else `mkdir -p "$(dirname)"`, ensure file exists, append `\noutput_language: <code>\n`, exit 0. English comments; the header documents that it is the write counterpart to resolve-language.sh (same file/line/allowlist), idempotent by design, and that it only records prose language (machine surfaces stay English). NIT-1: the grep runs against `$GLOBAL_CONFIG` ONLY; the helper takes no project-dir argument and never inspects a project CLAUDE.md, so the gate can never be confused by a project-level line.
- Verify: `bash tests/set-global-language.test.sh` GREEN; `chmod +x`; `bash -n` clean.
- Commit: `feat(language): add idempotent global output-language writer`

### Task 2: Hook the one-time global prompt into `install.sh`
- Scrutiny: judgment ("asked once, never hangs CI, never re-asks"; interactive vs non-interactive branching + flag parsing must be exact; runs under `set -euo pipefail`).
- Test first: `install.sh` writes real `$HOME`-shaped paths and drives an interactive prompt, so a full end-to-end test is out of scope (matches `tests/init-project.language.test.sh`, which tests the non-interactive path only). Automated verification: (a) `bash -n install.sh`; (b) `grep -n "global output language (one-time)" install.sh` proves the step is present; (c) the real acceptance is Task 1 case 2 + Task 3 (writer idempotence + writer->resolver inherit). Do NOT fabricate an interactive-path test.
- Implement: add `--lang <code>` + `ODEO_INSTALL_LANG` parsing near the existing `--link` parse (value-consuming `while/case/shift`, preserving `--link`). Insert a new step immediately AFTER the step-4 global-baseline block: if `~/.claude/CLAUDE.md` already has an `^output_language:` line -> "already set", skip; elif `~/.claude/CLAUDE.md` is a SYMLINK (`[[ -L ]]`, i.e. `--link` install pointing at the tracked repo file) -> skip with a printed note (never mutate a tracked repo file, see Risk 4); elif `$INSTALL_LANG` set -> write it (invalid -> clean message + exit 1); elif interactive (`[[ -t 0 ]]`) -> prompt `[E]nglish default / [d]e / [h]r / [f]r`, map like init-project.sh, write; else (non-interactive) -> write `en` without prompting. ALL writes call the helper by absolute path `"$REPO_DIR/bin/set-global-language.sh"` (NOT via PATH: `~/bin` is only on PATH in a new shell post-install).
- IMPORTANT-1 (set -u / set -e safety, install.sh is `set -euo pipefail`): (a) initialize `INSTALL_LANG="${ODEO_INSTALL_LANG:-}"` BEFORE first reference, or `-u` aborts the install on the unset var; (b) the invalid-`--lang` path must print ONE clean line and do a deliberate `exit 1` (e.g. `"$REPO_DIR/bin/set-global-language.sh" "$INSTALL_LANG" || { echo "! invalid --lang '$INSTALL_LANG' (en|de|hr|fr)"; exit 1; }`), never a bare propagated failure that `-e` turns into an unexplained abort.
- NIT-3 (flag-parse order independence): the new `while/case/shift` loop must keep `--link` working and handle `--lang` in any order, so `./install.sh --lang de --link`, `./install.sh --link --lang de`, and bare `./install.sh` all work; `--lang` with no value -> clean `exit 1`.
- Verify: `bash -n install.sh` clean; `grep -n "global output language (one-time)" install.sh` matches; symlink-guard present (`grep -nE '\-L .*\.claude/CLAUDE\.md' install.sh`); `grep -n 'INSTALL_LANG="\${ODEO_INSTALL_LANG:-}"' install.sh` proves the -u-safe init; a quick arg-order smoke (`bash -n` plus a dry parse) shows `--link` and `--lang` coexist.
- Commit: `feat(install): ask output language once at install, store the global default`

### Task 3: Prove the inherit + not-re-asked acceptance end to end
- Scrutiny: mechanical (composes the two shipped scripts; an integration assertion, not new logic).
- Test first: add an integration test (a dedicated `tests/global-default-inherit.test.sh` in the same style, OR appended to Task 1's file; builder states which):
  1. `cfg` with only a header line; `set-global-language.sh de` -> exit 0.
  2. a project dir whose CLAUDE.md has NO `output_language:` line.
  3. `CLAUDE_GLOBAL_CONFIG="$cfg" bin/resolve-language.sh "$proj"` -> `de` (inherits global).
  4. second `set-global-language.sh fr` -> `already set`; re-resolve still `de` (not re-asked / not overwritten).
  5. fresh `cfg2`, `set-global-language.sh en`; a no-line project resolves to `en` (skip-defaults-to-English).
  This composes already-tested units, so it may pass immediately after being written (RED-first discipline was applied to Task 1's new logic; note this in the commit).
- Implement: no production code (test-only wiring).
- Verify: `bash tests/global-default-inherit.test.sh` GREEN; full suite `for t in tests/*.test.sh; do bash "$t"; done` all exit 0; `bash bin/skills-lint.sh .` exit 0; `git ls-tree -r -z --name-only HEAD | bin/publish-guard.sh --require-allowlist -` shows no unclassified path (publish stays fail-closed-clean).
- Commit: `test(language): prove projects inherit the global default and it is asked once`

## Success signal (every acceptance criterion mapped to a check)
- Asked once at install, set en(default)/de/hr/fr: install.sh step present (grep) + the four-way case with English default.
- Skipping resolves to English: Task 1 case 3 + Task 3 case 5.
- Stored as the GLOBAL default, not in any project: write targets `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`; no project file touched.
- Project with no line inherits the global default: Task 3 case 3 (writer -> resolver yields `de`).
- Not shown again on re-install / later project setup: Task 1 case 2 + Task 3 case 4 (idempotent skip); init-project.sh/setup-project unchanged.
- Non-interactive safety: Task 2 non-interactive branch writes `en`; `--lang`/`ODEO_INSTALL_LANG` for scripted non-English.
- Suite + lint green; publish classification clean.

## Do-not-touch boundaries
- `bin/resolve-language.sh`: READ-ONLY (its 12 tests are USR-002's shipped behavior).
- `bin/init-project.sh`, `skills/setup-project/SKILL.md`: DO NOT MODIFY (per-project prompt is USR-002; must not be duplicated or re-triggered).
- `bin/language-guard.sh` and its tests: untouched.
- `docs/public-paths.txt` / `docs/internal-paths.txt`: no edit expected (new files fall under public `bin/`, `tests/`). If publish-guard reports an unclassified path, STOP and flag rather than silently editing the lists.
- Do not build USR-004/005/006.

## Risks / open questions
1. Insertion point in the user's global CLAUDE.md: the helper APPENDS (no structural anchor), because the user global file has no guaranteed headings; resolve-language.sh reads the first `^output_language:` match anywhere, so an appended line is read correctly. Flag if the human wants a specific section.
2. install.sh mid-run PATH: the step MUST call `"$REPO_DIR/bin/set-global-language.sh"`, not bare `set-global-language.sh` (`~/bin` is on PATH only in a new shell post-install). A builder who ignores this ships an install that fails on a clean machine.
3. No TTY test harness: the interactive prompt path is not auto-tested (matches init-project.language.test.sh). Verified via the isolated helper (Task 1) + writer->resolver integration (Task 3). Do NOT fabricate an interactive test.
4. **`--link` install (the real correctness edge):** with `--link`, `~/.claude/CLAUDE.md` is a SYMLINK to the repo's tracked `global/CLAUDE.md`; a naive append would mutate a committed repo file. Task 2 adds a symlink guard (`[[ -L ~/.claude/CLAUDE.md ]]` -> skip with a note). Confirm this guard in review. OPEN for the human: is "skip under --link, tell the user to set it per-project or edit their own global file" the right behavior, or should --link write the global default elsewhere?
