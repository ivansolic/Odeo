# Plan: USR-004 Change output language at any time
approved: yes (human, 2026-07-31)
model_plan:
  judgment: session strongest effort high
  builder: sonnet tier (harness-resolved) effort high; NOTE this session builds IN-THREAD
    on the session model, not a dispatched sonnet builder, because the builder-agent
    worktree cannot be created from a non-git session root.
arch_review: clean (v3, 2026-07-31)

## Header
Goal: a `/language` command that shows the effective output language and the level that set it, and changes it for either the project or the global default, in the same canonical `output_language: <code>` line the resolver and the no-leak guardrail already read, with no hand-editing of any file.

Serves: PRD-001's outcome, a non-English PM/builder runs the whole lifecycle in their language after a single setup choice while code and mechanics stay English. This story covers R5(c): the change-anytime command that keeps the setting from being a one-shot install decision.

Architecture context (inherited, not redecided):
- Deterministic logic lives in `bin/*.sh` with self-contained `tests/*.test.sh`; style is `set -uo pipefail`, exit 0 clean / 1 violation-or-refusal / 2 usage error, `mktemp` fixtures, `tr -d '\r'` for CRLF, TDD RED-first for logic. A user-facing command is a skill at `skills/<name>/SKILL.md` and must conform to `docs/skill-authoring-standard.md`.
- The setting is ONE line, `output_language: <code>`. Project level: `<project>/CLAUDE.md`. Global level: `${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}`. Precedence project > global > `en`, implemented by `bin/resolve-language.sh` (USR-002, shipped, 12 tests).
- The allowlist `en de hr fr` is USR-002's. Each script carries its own literal copy (repo convention: files stand alone, no cross-sourcing), and the sets must stay identical.
- `install.sh` calls `bin/set-global-language.sh` for the one-time global question (USR-003, shipped, 8 tests). That writer is idempotent by design.
- Guardrail split `[E]` enforced vs `[I]` instructed lives in AGENTS.md; skills reference guardrails, never restate them.
- `bin/*.sh` is copied to `~/bin` by `install.sh`, so skills may call the scripts by bare name (the `/merge` idiom: "in `~/bin` or `bin/`").

Constraints (verbatim from the story + inherited):
- "A command (e.g. `/language`) shows the current effective language and its scope (project or global)."
- "`/language <code>` with a code in {en, de, hr, fr} sets the language; an unsupported code is rejected and the allowed set is listed."
- "The command can target either the project override or the global default; the next generated artifact reflects the change."
- "The change is written in the same canonical form as setup (`output_language: <code>`), so the resolver and the no-leak guardrail read it identically."
- "Changing the language requires no manual file editing."
- Inherited: USR-003's install-time behavior ("asked exactly once", never silently overwrite) and its 8 tests must keep passing unchanged; the two write paths must not fork the allowlist or the line format (enforced by `tests/language-allowlist-agreement.test.sh`, Task 4b); machine surfaces stay English; English-only code comments; no em/en dashes in any text; no version-pinned model names.
- DO NOT build: USR-005 prose localization (generators actually writing in the language) or USR-006 mismatch warning. This story ends at "the resolver returns the new code".

## Design decisions (resolved, so the builder does not guess)

1. **The central tension (global writer refuses to overwrite).** `bin/set-global-language.sh` is EXTENDED with an explicit opt-in flag `--overwrite`, not replaced and not forked. Without the flag its behavior is byte-for-byte what USR-003 shipped: an existing `^output_language:` line is left alone and it exits 0 "already set". `install.sh` never passes the flag, so "asked exactly once / never silently overwrite" is preserved BY CONSTRUCTION, and USR-003's 8 tests keep passing untouched. Rejected alternatives: a second `change-global-language.sh` (forks the allowlist and the line format across two writers of the same line, exactly what the story forbids); folding show+set into one new `bin/language.sh` (would duplicate or orphan the shipped installer call site and risk a USR-003 regression for no gain).

2. **Scope is reported by a NEW reader, the resolver is untouched.** `bin/resolve-language.sh` stays read-only (USR-002's shipped behavior, 12 tests, and other callers depend on its "one code on stdout" contract). The new `bin/language-status.sh <project-dir>` prints `<code> <scope>`. The CODE always comes from invoking `resolve-language.sh`, so the two can never disagree on the value; only the SCOPE is derived locally, with a `read_lang` copy that uses the resolver's exact normalize + allowlist rules. That matters for the degrade case: an invalid project value must report scope `global`, not `project`. A test matrix asserts agreement between the two scripts on every fixture.

3. **Project write updates in place.** `bin/set-project-language.sh <project-dir> <code>` mirrors `init-project.sh`'s three branches in the same order (replace an existing line / insert after the `^## Conventions` anchor / append), with an IDENTICAL branch order, anchor regex, and emitted line. One divergence is DELIBERATE and must not be "harmonized" away: the replace mechanism differs, `init-project.sh` uses `sed` (rewrites every matching line) while this writer uses `awk` to keep the first and DROP any further ones, so a hand-edited duplicate collapses to exactly one. That is a superset of the sed behavior and never conflicts with it; a future reader must not delete the collapse or edit the do-not-touch scaffolder to match. It writes THROUGH the target (`cat "$tmp" > "$TARGET"`), not `mv`, so the file keeps its mode.

4. **Scope selection UX: `--global` flag, project is the default.** `/language <code>` targets the project; `/language <code> --global` targets the global default. Project is the safer default (blast radius is one repo, trivially reversible) AND the semantically honest one: because project > global, a project-scope change always takes effect immediately, while a global change can be silently masked by an existing project line. The masked case is handled explicitly: after a `--global` change the skill re-runs `language-status.sh` and, if the scope still reads `project`, tells the user their project line still wins.

5. **Non-interactive / CI safety.** `/language` has NO interactive prompt at any layer: all three scripts are fully argument-driven, so nothing can hang. Exit codes: 0 success, 1 refusal (unknown code, missing project `CLAUDE.md`, symlinked global config, write failure), 2 usage error. Every test overrides `CLAUDE_GLOBAL_CONFIG` so no test touches the real `$HOME`.

6. **The `[E]` no-leak guardrail is unaffected.** The stored value is one of `en de hr fr`, ASCII, allowlisted, in a line that is not frontmatter and not a machine enum `language-guard.sh` checks. `bin/language-guard.sh` and `tests/language-guard.test.sh` are DO-NOT-TOUCH; the full suite green (which includes that test file) is the proof.

7. **Symlinked global config is refused on write.** Under a `--link` install `~/.claude/CLAUDE.md` is a symlink to the repo's tracked `global/CLAUDE.md`; writing through it would mutate a committed file. `set-global-language.sh` refuses with exit 1 before ANY write when the target is a symlink. This cannot regress install (install.sh already skips symlinks before calling) and no existing test uses a symlink.

## Architecture review (findings and resolutions)
- v1 CHANGES-REQUIRED, 0 blocking, 4 IMPORTANT + 5 NIT. Verified against the shipped code, not against the plan's claims: all 8 existing set-global-language cases pass unmodified under the new arg parse (walked case by case); install.sh cannot smuggle the flag (all three call sites pass one quoted arg, so even `ODEO_INSTALL_LANG="de --overwrite"` fails the allowlist), so USR-003 holds by construction; the `read_lang` copy is character-identical to `bin/resolve-language.sh` lines 44 to 57; no awk path can truncate the target (awk writes to `$tmp` and a non-zero exit removes it before `TARGET` is opened); skills-lint C1/C5/C7/C9 satisfied (C1 is skipped by `disable-model-invocation`, C7 does not scan WORKFLOW.md and the row uses a middle dot, not a dash).
- v2 CHANGES-REQUIRED, 0 blocking, 2 must-change + 6 nits. v2 resolutions: I1 insert-before-summary-block wording in four places; I2 Task 4b allowlist-agreement test; I3 skill Rules forbid creating a missing CLAUDE.md; I4 scope-word mapping; NIT 1 to 5 as described in each location.
- v3 resolutions: Task 4b extended to close two coverage holes the v2 guard had, the fifth copy (`bin/init-project.sh`, checked textually since it is do-not-touch) and `language-status.sh`'s own list (via a SCOPE assertion, because a code accepted only there reports the wrong LEVEL while the code still looks right); RED-by-mutation now REQUIRED for the guard (a guard never seen failing is false confidence), with two named mutations; `ok:`-count confirmation changed to the runtime command (counting in the file always yields 1); the sed-vs-awk divergence warning moved into the code comment where a future reader will actually see it; the duplicated collapse sentence, the file-map ordering, the self-narrating Rules bullet, and the unlinked constraint all fixed.

## File map (before any tasks)
- `bin/language-status.sh` CREATE: prints `<code> <scope>` (scope: `project` | `global` | `default`) for a project dir; code delegated to `resolve-language.sh`, scope derived locally; exit 0/2.
- `tests/language-status.test.sh` CREATE: RED-first tests for show-current, scope per level, invalid-value degrade, normalization, duplicates, resolver agreement, usage errors.
- `bin/set-project-language.sh` CREATE: writes/updates the single project-level `output_language:` line in `<project-dir>/CLAUDE.md`; always leaves exactly one; exit 0/1/2.
- `tests/set-project-language.test.sh` CREATE: RED-first tests for insert, in-place update, no-duplicate-on-repeat, duplicate collapse, invalid code, missing CLAUDE.md, mode preservation, usage errors.
- `bin/set-global-language.sh` MODIFY: add opt-in `--overwrite` (replace in place) + a pre-write symlink refusal; default no-flag path unchanged (USR-003 idempotence).
- `tests/set-global-language.test.sh` MODIFY (cases 1 to 8 must not be edited): new cases for overwrite, flag order, unknown flag, duplicate collapse, symlink refusal. INSERT them immediately BEFORE the summary block at `tests/set-global-language.test.sh:65-67` (`echo` / `ALL PASS` / `exit "$fail"`), NEVER after `exit "$fail"`: cases placed after it never execute and the file still prints ALL PASS, so the whole `--overwrite` path would ship unverified with every gate reporting success. Confirm with `bash tests/set-global-language.test.sh | grep -c '^ok:'` run BEFORE and AFTER the edit; the count MUST rise. (Counting in the FILE always yields 1: `echo "ok: $1"` appears once, in the helper on line 6.)
- `tests/language-change-anytime.test.sh` CREATE: AC-level integration across the three scripts plus the resolver (change at either scope, masking, no duplicates).
- `tests/language-allowlist-agreement.test.sh` CREATE: behavioral invariant that every script accepts/rejects exactly the same code set (closes the five-copies drift risk mechanically instead of by convention).
- `skills/language/SKILL.md` CREATE: the `/language` explicit command (show / set project / set global), conforming to `docs/skill-authoring-standard.md`.
- `docs/system-map.md` MODIFY: one row in the "1. Setup & onboarding" table (authoring standard: a command not on the map does not exist).
- `WORKFLOW.md` MODIFY: one row in the "what do I want to do" table (PRD-001 names discoverability as a usability risk).
- `docs/public-paths.txt` NO CHANGE EXPECTED (verify only): `bin/`, `tests/`, `skills/` are already public directory prefixes; `docs/system-map.md` and `WORKFLOW.md` are already listed. The builder confirms with `publish-guard --require-allowlist` and STOPS if any path is unclassified rather than editing the lists.

## Tasks

### Task 1: `bin/language-status.sh`, the effective language plus its scope
- Scrutiny: judgment (scope must follow the resolver's precedence semantics, including the invalid-value degrade, or the command lies to the user about where the setting lives).
- Test first (RED before the script exists): create `tests/language-status.test.sh` in the established style (`set -uo pipefail`, `SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/language-status.sh"`, `mktemp -d` + `trap`), with the helpers as in `tests/set-global-language.test.sh` lines 6 to 8, which defines all three (`assert_exit` / `assert_eq` / `assert_contains`; note `tests/resolve-language.test.sh` has only two of them). Every case sets `CLAUDE_GLOBAL_CONFIG`. Cases:
  1. project `de` + global `fr` -> stdout exactly `de project`, exit 0.
  2. project CLAUDE.md present without the line + global `hr` -> `hr global`.
  3. project without the line + global file absent -> `en default`.
  4. project dir with NO CLAUDE.md + global absent -> `en default`.
  5. project `klingon` + global `fr` -> `fr global` (scope follows the resolver's degrade, not mere line presence). This case is the reason the script exists.
  6. project line written as `output_language:   DE \r` -> `de project` (normalization).
  7. project has `output_language: fr` then `output_language: de` -> `fr project` (first line wins).
  8. all four codes as a project line -> `<code> project` each.
  9. resolver agreement: for the fixture dirs of cases 1, 2, 3, 5, 6, assert the FIRST field of `language-status.sh` output equals the full output of `bin/resolve-language.sh` on the same dir with the same `CLAUDE_GLOBAL_CONFIG`.
  10. usage: no args -> exit 2 + `usage`; two args -> exit 2; nonexistent dir -> exit 2 + `not found`.
  Run -> RED (script absent).
- Implement `bin/language-status.sh` exactly:
```bash
#!/usr/bin/env bash
# language-status.sh, reports the EFFECTIVE output language and WHERE it is set.
#
# The read side of the /language command. bin/resolve-language.sh answers WHICH
# code is effective; this script adds WHICH LEVEL set it (the scope), which the
# resolver deliberately does not expose. The CODE is always taken from
# resolve-language.sh, so the two can never disagree on the value; only the
# scope is derived here, with the resolver's exact normalize and allowlist rules.
#
# Usage:
#   language-status.sh <project-dir>
#
# Output, exactly one line on stdout:
#   <code> <scope>       scope: project | global | default
#     project  the project CLAUDE.md carries a valid output_language: line
#     global   no valid project line; the global config carries a valid one
#     default  neither level has a valid line, the built-in en fallback applies
#
# Exit codes:
#   0  status written to stdout
#   2  usage error (wrong arg count, project dir not found, resolver missing)
#
# CLAUDE_GLOBAL_CONFIG overrides the global config path (same as
# resolve-language.sh), so tests never touch the real $HOME/.claude/CLAUDE.md.
set -uo pipefail

usage() { echo "usage: language-status.sh <project-dir>" >&2; exit 2; }

[ "$#" -eq 1 ] || usage

PROJECT_DIR="$1"
[ -d "$PROJECT_DIR" ] || { echo "language-status: project dir not found: $PROJECT_DIR" >&2; exit 2; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$HERE/resolve-language.sh"
[ -f "$RESOLVER" ] || { echo "language-status: resolver not found: $RESOLVER" >&2; exit 2; }

# Valid codes. Literal, self-contained list (same convention as
# resolve-language.sh and set-global-language.sh). MUST stay identical to
# USR-002's allowlist.
VALID="en de hr fr"
GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"

# read_lang FILE, same rules as resolve-language.sh: first ^output_language:
# line, strip CR, trim, lowercase, print only a recognized code.
read_lang() {
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
  return 0
}

# The code comes from the resolver: single source of truth for precedence.
code="$(CLAUDE_GLOBAL_CONFIG="$GLOBAL_CONFIG" bash "$RESOLVER" "$PROJECT_DIR")" \
  || { echo "language-status: resolver failed for $PROJECT_DIR" >&2; exit 2; }
code="$(printf '%s' "$code" | tr -d '\r\n')"

if [ -n "$(read_lang "$PROJECT_DIR/CLAUDE.md")" ]; then
  scope=project
elif [ -n "$(read_lang "$GLOBAL_CONFIG")" ]; then
  scope=global
else
  scope=default
fi

printf '%s %s\n' "$code" "$scope"
exit 0
```
- Verify: `bash tests/language-status.test.sh` GREEN; `chmod +x bin/language-status.sh`; `bash -n bin/language-status.sh` clean.
- Consumes: `bin/resolve-language.sh` (existing, unmodified).
- Produces: the `<code> <scope>` stdout contract used by Task 4 and the skill in Task 5.
- Commit: `feat(language): report the effective output language and its scope`

### Task 2: `bin/set-project-language.sh`, the project-level change path
- Scrutiny: judgment (in-place update of a user config file; a wrong branch either duplicates the line or clobbers surrounding content).
- Test first (RED before the script exists): create `tests/set-project-language.test.sh` in the same style, with a portable mode helper `file_mode() { stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null; }`. Cases:
  1. INSERT at the anchor: CLAUDE.md containing `# P`, `## Conventions`, `- x`; set `de` -> exit 0, `grep -c '^output_language:'` equals 1, the line sits after the `## Conventions` line, `bin/resolve-language.sh <dir>` (with `CLAUDE_GLOBAL_CONFIG` pointing at an absent file) prints `de`.
  2. UPDATE in place: CLAUDE.md with `output_language: en`; set `de` -> exactly one line, value `de`, total `wc -l` unchanged, the other content lines still present (`grep -q '^# P'`).
  3. NO DUPLICATE ON REPEATED SETS (the story's explicit requirement): on ONE fixture run set `de`, then `fr`, then `hr` in sequence; after each run assert `grep -c '^output_language:'` equals 1; final value `hr` and resolver prints `hr`.
  4. NO ANCHOR, NO LINE: CLAUDE.md containing only `# P` -> appended, exactly one line, resolver prints the code.
  5. COLLAPSE pre-existing duplicates: CLAUDE.md with `output_language: fr` and `output_language: de` on separate lines; set `hr` -> exactly one line, value `hr`.
  6. INVALID code `klingon` -> exit 1, stderr names `klingon` and lists `en de hr fr`, and the file is byte-identical to a `cp`-saved copy (`cmp -s`).
  7. MISSING CLAUDE.md in an existing dir -> exit 1, stderr mentions `CLAUDE.md`, and `[ ! -f "$dir/CLAUDE.md" ]` (nothing created).
  8. USAGE: 0 args -> exit 2 + `usage`; 1 arg -> exit 2; 3 args -> exit 2; nonexistent dir -> exit 2 + `not found`.
  9. MODE PRESERVED: `chmod 644` the fixture, set `de`, `file_mode` still `644`.
  10. All four codes round-trip on fresh fixtures -> exit 0, exactly one line with the matching code.
  Run -> RED (script absent).
- Implement `bin/set-project-language.sh` exactly:
```bash
#!/usr/bin/env bash
# set-project-language.sh, writer of the PROJECT-level output-language override.
#
# Updates (or inserts) the single canonical `output_language: <code>` line in a
# project CLAUDE.md, the exact line bin/resolve-language.sh reads for the project
# precedence level. It always leaves EXACTLY ONE such line, so repeated calls
# change the value instead of stacking duplicates.
#
# Unlike bin/set-global-language.sh (idempotent by default, which is what
# protects the install-time "asked exactly once" guarantee), this script IS a
# change path: overwriting an existing project value is its job, because the
# project override is the per-repo setting /language changes.
#
# Only records WHICH language to write prose in; machine surfaces (filenames,
# frontmatter keys, commit types, code) stay English regardless of the code.
#
# Usage:
#   set-project-language.sh <project-dir> <code>     # code in: en de hr fr
#
# Exit codes:
#   0  the project CLAUDE.md now carries exactly one line with <code>
#   1  invalid code, no CLAUDE.md in <project-dir>, or the write failed
#   2  usage error (wrong arg count, or project dir not found)
set -uo pipefail

usage() { echo "usage: set-project-language.sh <project-dir> <code>  (code: en de hr fr)" >&2; exit 2; }

[ "$#" -eq 2 ] || usage
PROJECT_DIR="$1"
CODE="$2"

[ -d "$PROJECT_DIR" ] || { echo "set-project-language: project dir not found: $PROJECT_DIR" >&2; exit 2; }

# Valid codes. Literal, self-contained list; MUST stay identical to USR-002's.
VALID="en de hr fr"
valid=0
for c in $VALID; do [ "$CODE" = "$c" ] && valid=1; done
if [ "$valid" -ne 1 ]; then
  echo "set-project-language: unknown language: $CODE (allowed: $VALID)" >&2
  exit 1
fi

TARGET="$PROJECT_DIR/CLAUDE.md"
if [ ! -f "$TARGET" ]; then
  echo "set-project-language: no CLAUDE.md in $PROJECT_DIR (run /setup-project first, or set the global default instead)" >&2
  exit 1
fi

tmp="$(mktemp)" || { echo "set-project-language: could not create a temp file" >&2; exit 1; }

# Same three branches, in the same order, and the same anchor and emitted line as
# bin/init-project.sh, so both writers produce an identical canonical line.
# ONE DELIBERATE DIVERGENCE: init-project.sh replaces with sed (rewrites EVERY
# matching line); this writer uses awk to keep the FIRST and drop the rest, so a
# hand-edited duplicate collapses. That is a superset, never a conflict. Do not
# "harmonize" the two, and do not remove the collapse.
if grep -qE '^output_language:' "$TARGET"; then
  # Replace at the position of the FIRST line and drop any further ones, so a
  # hand-edited file with duplicates collapses to exactly one.
  if ! awk -v line="output_language: $CODE" '
    /^output_language:/ { if (!seen) { print line; seen=1 } ; next }
    { print }
  ' "$TARGET" > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: rewrite failed for $TARGET" >&2; exit 1
  fi
elif grep -qE '^## Conventions' "$TARGET"; then
  if ! awk -v line="output_language: $CODE" '
    { print }
    /^## Conventions/ && !done { print ""; print line; done=1 }
  ' "$TARGET" > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: insert failed for $TARGET" >&2; exit 1
  fi
else
  # No line and no anchor: append. resolve-language.sh reads the first
  # ^output_language: match anywhere, so a trailing line is read fine.
  if ! { cat "$TARGET" && printf '\noutput_language: %s\n' "$CODE"; } > "$tmp"; then
    rm -f "$tmp"; echo "set-project-language: append failed for $TARGET" >&2; exit 1
  fi
fi

# Write THROUGH the original path so the file keeps its mode (mv would replace
# it with a 600 temp file) and so a symlinked CLAUDE.md is followed rather than
# replaced. The temp file is complete before this runs.
# Not atomic: a failure mid-write leaves a truncated file. Accepted for a
# one-line config edit, because mv would clobber the mode and break the symlink
# case; the tradeoff is stated here rather than left invisible.
if ! cat "$tmp" > "$TARGET"; then
  rm -f "$tmp"; echo "set-project-language: could not write $TARGET" >&2; exit 1
fi
rm -f "$tmp"
echo "set-project-language: project output language set to $CODE."
exit 0
```
- Verify: `bash tests/set-project-language.test.sh` GREEN; `chmod +x bin/set-project-language.sh`; `bash -n bin/set-project-language.sh` clean; `bash tests/init-project.language.test.sh` still GREEN (proves the shared line format was not disturbed).
- Consumes: `bin/resolve-language.sh` (read-only, in the test assertions only).
- Produces: the project-scope write path used by Task 4 and the skill in Task 5.
- Commit: `feat(language): add a project-level output-language writer`

### Task 3: opt-in `--overwrite` on `bin/set-global-language.sh` (the USR-003 tension)
- Scrutiny: judgment (touching the script that carries USR-003's "asked exactly once" guarantee; the default path must stay behaviorally identical).
- Test first (RED): add cases to `tests/set-global-language.test.sh`, INSERTED immediately BEFORE the file's summary block (`echo` / `if [ "$fail" = 0 ] ... ALL PASS` / `exit "$fail"`). NEVER place them after `exit "$fail"`: they would never run, the file would still print ALL PASS, and the `--overwrite` and symlink paths would ship unverified with a green suite. After editing, confirm with `bash tests/set-global-language.test.sh | grep -c '^ok:'` run BEFORE and AFTER; the count MUST rise (counting in the FILE always yields 1, the helper on line 6). Do NOT edit cases 1 to 8; they are USR-003's regression suite and must keep passing verbatim.
  9. `--overwrite` CHANGES an existing value: cfg `# G` + `output_language: fr`; run `de --overwrite` -> exit 0, exactly one line, value `de`, `# G` still present, stdout contains `changed`.
  10. `--overwrite` on a config with NO line -> exit 0, exactly one `output_language: hr` line (the fresh path still works with the flag).
  11. `--overwrite` COLLAPSES duplicates: cfg with `output_language: fr` and `output_language: de` -> `hr --overwrite` -> exactly one line, value `hr`.
  12. FLAG ORDER independence: `--overwrite de` behaves the same as `de --overwrite` -> exit 0, value `de`.
  13. `--overwrite` with an invalid code (`klingon --overwrite`) -> exit 1, stderr names it and lists `en de hr fr`, config byte-identical (`cmp -s` against a saved copy).
  14. UNKNOWN flag: `--nope de` -> exit 2 + `usage`.
  15. SYMLINK refusal: real file `real.md` with `output_language: fr`, `ln -s real.md link.md`; `CLAUDE_GLOBAL_CONFIG=link.md ... de --overwrite` -> exit 1, stderr mentions `symlink`, `real.md` still `fr`.
  16. REGRESSION restated explicitly: with the flag ABSENT on a config that has `output_language: fr`, `de` still leaves `fr` and says `already set` (this duplicates case 2 on purpose, as the guard against a future default-flip).
  Run -> RED for 9 to 15 (flag unknown today: current parsing gives exit 2 on 2 args, so 9, 10, 11, 12, 13, 15 fail).
- Implement, three edits to `bin/set-global-language.sh`, nothing else:
  (a) Header: document the flag. Replace the Usage block with:
```bash
# Usage:
#   set-global-language.sh <code>                # code in: en de hr fr
#   set-global-language.sh <code> --overwrite    # CHANGE an existing value
#
# Without --overwrite it is idempotent by design (see above): an existing line is
# left alone. --overwrite is the explicit opt-in the /language command uses to
# CHANGE the global default; install.sh never passes it, so the install-time
# "asked exactly once, never silently overwritten" guarantee is unaffected.
```
  (b) Replace the arg handling (`usage()` line, `[ "$#" -eq 1 ] || usage`, `CODE="$1"`) with:
```bash
usage() { echo "usage: set-global-language.sh <code> [--overwrite]  (code: en de hr fr)" >&2; exit 2; }

CODE=""
OVERWRITE=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --overwrite) OVERWRITE=1; shift ;;
    -*)          usage ;;
    *)           [ -z "$CODE" ] || usage   # a second bare token is a usage error
                 CODE="$1"; shift ;;
  esac
done
[ -n "$CODE" ] || usage
```
  (c) Replace the idempotence-gate block with:
```bash
# Idempotence gate (USR-003's "asked exactly once"): WITHOUT --overwrite an
# existing line is left exactly as it is. The grep runs against $GLOBAL_CONFIG
# ONLY; this script takes no project-dir argument and never inspects a project
# CLAUDE.md, so the gate can never be confused by a project-level line.
HAS_LINE=0
if [ -f "$GLOBAL_CONFIG" ] && grep -qE '^output_language:' "$GLOBAL_CONFIG"; then
  HAS_LINE=1
fi
if [ "$HAS_LINE" -eq 1 ] && [ "$OVERWRITE" -ne 1 ]; then
  echo "set-global-language: global output language already set, leaving it unchanged."
  exit 0
fi

# About to write. Refuse a symlinked config: under a --link install
# ~/.claude/CLAUDE.md points at the repo's tracked global/CLAUDE.md, and writing
# through it would mutate a committed file.
if [ -L "$GLOBAL_CONFIG" ]; then
  echo "set-global-language: $GLOBAL_CONFIG is a symlink (--link install); refusing to rewrite it. Set the language for this project instead." >&2
  exit 1
fi

if [ "$HAS_LINE" -eq 1 ]; then
  # --overwrite: replace at the position of the FIRST line, drop any further
  # ones, and write THROUGH the path so the file keeps its mode. Not atomic
  # (a failure mid-write leaves a truncated file); accepted for a one-line
  # config edit, same tradeoff as set-project-language.sh.
  tmp="$(mktemp)" || { echo "set-global-language: could not create a temp file" >&2; exit 1; }
  if ! awk -v line="output_language: $CODE" '
    /^output_language:/ { if (!seen) { print line; seen=1 } ; next }
    { print }
  ' "$GLOBAL_CONFIG" > "$tmp"; then
    rm -f "$tmp"; echo "set-global-language: rewrite failed for $GLOBAL_CONFIG" >&2; exit 1
  fi
  if ! cat "$tmp" > "$GLOBAL_CONFIG"; then
    rm -f "$tmp"; echo "set-global-language: could not write $GLOBAL_CONFIG" >&2; exit 1
  fi
  rm -f "$tmp"
  echo "set-global-language: global output language changed to $CODE."
  exit 0
fi
```
  The existing fresh-write tail (`mkdir -p`, ensure file, append, "set to") stays exactly as it is.
- Verify: `bash tests/set-global-language.test.sh` GREEN including all 8 original cases; `bash -n bin/set-global-language.sh` clean; `grep -n 'ODEO_INSTALL_LANG\|set-global-language.sh' install.sh` shows the three call sites still pass NO flag (install.sh is not modified).
- Consumes: nothing new.
- Produces: `set-global-language.sh <code> --overwrite`, the global-scope change path for Task 4 and the skill in Task 5.
- Commit: `feat(language): allow an explicit opt-in overwrite of the global default`

### Task 4: AC-level integration test across both scopes
- Scrutiny: mechanical (composes three tested units; an integration assertion, no new production code).
- Test first: create `tests/language-change-anytime.test.sh`, same style, all scripts resolved from `$(cd "$(dirname "$0")/.." && pwd)/bin`. Cases:
  1. Fixture project CLAUDE.md with `# P`, `## Conventions`, `output_language: en`; global cfg `# G` + `output_language: en`. `set-project-language.sh $proj de` -> exit 0; `resolve-language.sh $proj` prints `de`; `language-status.sh $proj` prints `de project`.
  2. Change again: `set-project-language.sh $proj fr` -> resolver prints `fr`, `grep -c '^output_language:' $proj/CLAUDE.md` equals 1 (change anytime, still no duplicate).
  3. Global change while a project override exists: `set-global-language.sh hr --overwrite` -> exit 0, global line is `hr`; `resolve-language.sh $proj` STILL prints `fr` and `language-status.sh $proj` still prints `fr project` (the masking case the skill must report).
  4. Remove the project line (in the TEST, with `awk '!/^output_language:/' file > tmp && mv tmp file`) -> `resolve-language.sh $proj` prints `hr`, `language-status.sh $proj` prints `hr global`.
  5. Fresh global cfg with no line + project with no line -> `en default` and resolver `en`.
  6. Refusal changes nothing: save copies of both files; `set-project-language.sh $proj klingon` -> exit 1; `set-global-language.sh klingon --overwrite` -> exit 1; both files `cmp -s` identical to their copies.
  This composes already-tested units, so it may pass on first run; RED-first discipline was applied to the new logic in Tasks 1 to 3. State that in the commit body.
- Implement: no production code (test-only).
- Verify: `bash tests/language-change-anytime.test.sh` GREEN; full suite `for t in tests/*.test.sh; do bash "$t" >/dev/null 2>&1 || echo "FAILED: $t"; done` prints no `FAILED:` line.
- Consumes: Tasks 1, 2, 3 plus `bin/resolve-language.sh`.
- Produces: the AC evidence the success signal below points at.
- Commit: `test(language): prove the language changes at either scope with no duplicate line`

### Task 4b: allowlist agreement across all five copies (converts a convention into a guard)
- Scrutiny: judgment (this is the ONLY mechanical defense against the five-copies drift; without it, adding a code later silently half-works).
- Why: after this story the code set lives as a literal in `bin/resolve-language.sh`, `bin/set-global-language.sh`, `bin/set-project-language.sh`, `bin/language-status.sh`, and as a `case` (different syntax) in `bin/init-project.sh`. The plan asserts "the sets must stay identical" but before this task nothing enforced it. The failure mode is quiet, not loud: a writer accepts a code the resolver then degrades away, so the user is told "set to es" and keeps getting English documents. The repo's convention is that a bug class that can happen gets a mechanical check.
- Test first: create `tests/language-allowlist-agreement.test.sh` in the established style. For each code in `en de hr fr` plus two invalid controls (`klingon`, `es`), assert IDENTICAL accept/reject behavior across the writers and readers, on `mktemp` fixtures with `CLAUDE_GLOBAL_CONFIG` overridden:
  1. VALID codes: `set-project-language.sh $proj <code>` exit 0 AND `set-global-language.sh <code> --overwrite` exit 0 AND `resolve-language.sh` returns that exact code AND `language-status.sh` first field equals it.
  2. INVALID codes: `set-project-language.sh $proj <code>` exit 1 AND `set-global-language.sh <code> --overwrite` exit 1, both listing the allowed set; and when planted BY HAND as a project line (with a valid global line present), `resolve-language.sh` degrades past it (never echoes it) AND `language-status.sh` reports scope `global`, never `project`. That scope assertion is what covers `language-status.sh`'s own copy of the list: a code accepted there but not by the resolver would report the wrong LEVEL while the code still looked right (exactly the lie Task 1's Scrutiny note exists to prevent).
  3. The accepted set is EXACTLY four: for a fixed candidate list (`en de hr fr es it klingon EN`), the count accepted by each writer is 4 and the accepting subset is the same for both writers. Note `EN` is REJECTED by both writers (they are case-sensitive because they produce the canonical form) while `resolve-language.sh` normalizes case when READING; assert only writer-vs-writer agreement for `EN`, never writer-vs-reader. If a code is ever added deliberately, this test is the canary: update the expected set HERE and in all five files named above, in the same commit.
  4. THE FIFTH COPY, `bin/init-project.sh` (do-not-touch here, so checked textually rather than by invoking the scaffolder, which would create a whole project tree): assert `grep -qE '^[[:space:]]*en\|de\|hr\|fr\)' bin/init-project.sh` and `grep -q '(allowed: en de hr fr)' bin/init-project.sh`. Either failing means the scaffolder's accepted set has drifted from the writers'.
  RED via mutation (required, not optional): a guard that has never been seen failing is false confidence. Before committing, add `es` to `VALID` in `bin/set-project-language.sh` ONLY, run `bash tests/language-allowlist-agreement.test.sh`, and confirm it FAILS naming `es` (cases 2 and 3 must both fail). Then `git checkout -- bin/set-project-language.sh` and confirm GREEN. Repeat with `es` added to `bin/language-status.sh`'s `VALID` ONLY and confirm case 2's SCOPE assertion fails (this is the hole that made the first draft of this guard toothless). Record both observations in the commit body. Cases 1 to 4 have no RED-before-implement phase because they test an invariant over already-implemented scripts; the mutation IS their RED, and it proves the guard can actually catch a divergence.
- Implement: no production code (test-only).
- Verify: `bash tests/language-allowlist-agreement.test.sh` GREEN; full suite green.
- Consumes: Tasks 1, 2, 3 plus `bin/resolve-language.sh`.
- Produces: the guard that makes "one allowlist intent, five copies" safe to live with.
- Commit: `test(language): assert every language script accepts the same code set`

### Task 5: the `/language` command (skill) and the docs map
- Scrutiny: standard (authoring-standard conformance and exact script invocations; scored by skill-reviewer).
- Test first: no unit test applies to a markdown skill (repo convention: skills are verified by `bin/skills-lint.sh` plus skill-reviewer). The deterministic checks in Verify below stand in; do not fabricate a test.
- Implement (a): create `skills/language/SKILL.md` with exactly this content:
```markdown
---
description: Show or change the language your generated documents are written in (PRDs, stories, plans, reviews). "/language" reports the current language and where it is set; "/language de" sets it for this project; "/language de --global" changes your default for all projects. Supported codes: en, de, hr, fr. Explicit command; code, filenames, commit messages, and every machine-read field stay English. Example: "/language hr".
disable-model-invocation: true
---

# Language (show or change the output language)

Set which language the system WRITES your documents in, at any time, without
editing a file by hand. The preference is one line, `output_language: <code>`,
the same line the resolver reads; this command shows it and changes it.

## When to use (and when not)
- You want to know which language your documents come out in right now, and which
  level set it: this project, or your global default.
- You want to change it: for this project only (the default), or everywhere
  (`--global`).
- Not for documents that already exist: the setting applies to newly generated
  prose, never retro-translates.
- Not for code, comments, filenames, branch names, commit types, or frontmatter
  fields. Those stay English, and `language-guard.sh` is the enforced gate for it
  (see AGENTS.md).
- Supported codes: `en`, `de`, `hr`, `fr`. Anything else is refused by the script.
  Relay its refusal message unchanged, whatever it is; never pick a code for the user.

## Process
The scripts live in `~/bin` (or `bin/` in this repo). The project is the repo root:
`root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`.

**Show, `/language` with no argument:**
1. Run `language-status.sh "$root"`. It prints one line, `<code> <scope>`, where
   scope is `project`, `global`, or `default` (the built-in English fallback).
2. Report it plainly: name the language and where it comes from, for example
   "German (de), set for this project", "Croatian (hr), inherited from your global
   default", or "English (en), the default, nothing is set".

**Set for this project, `/language <code>` (the default scope):**
1. Run `set-project-language.sh "$root" <code>`. A non-zero exit is a refusal:
   relay its message unchanged and stop.
2. Re-run `language-status.sh "$root"` and report the new state.

**Set your global default, `/language <code> --global`:**
1. Run `set-global-language.sh <code> --overwrite`. The flag is what allows a
   CHANGE; without it the writer deliberately leaves an existing value alone,
   which is what keeps the install-time question a one-time question.
2. Re-run `language-status.sh "$root"`. If the scope still reads `project`, say
   so: this project's own line still wins, and offer `/language <code>` to change
   it here too.

**Scope words map to the flag, they are never passed to a script.** "global",
"globally", "everywhere", "all projects", "my default" mean `--global`, anywhere in
the user's message. "here", "this project", "this repo", or no scope word at all
mean the default project scope. Pass ONLY the code to the script; passing a scope
word as an argument produces a confusing usage error.

If the user names a language instead of a code, map only these; pass anything else
through unchanged so the script refuses it:

| The user says | Code |
|---|---|
| English | `en` |
| German, Deutsch | `de` |
| Croatian, Hrvatski | `hr` |
| French, Francais | `fr` |

## Worked example
Working in `~/code/shop`, whose CLAUDE.md carries `output_language: en`, with a
global default of `de`:

- "/language" -> `language-status.sh ~/code/shop` prints `en project` -> "English
  (en), set for this project. Your global default is separate."
- "/language hr" -> `set-project-language.sh ~/code/shop hr` prints "project
  output language set to hr", status now prints `hr project` -> "Croatian (hr)
  from now on, in this project. Documents already written stay as they are."
- "/language hr" again -> CLAUDE.md still has exactly one `output_language:` line;
  the value is replaced, never appended.
- "/language klingon" -> the script exits 1 with "unknown language: klingon
  (allowed: en de hr fr)". Relay it; do not guess a code.
- "/language de" in a directory with NO `CLAUDE.md` -> the script exits 1 with "no
  CLAUDE.md in <dir>". Do NOT create the file. Say: "This project has no CLAUDE.md
  yet, so there is nothing to set the language on. Want me to run /setup-project? It
  configures the project and asks for the language as part of setup. If you would
  rather not configure this project, /language de --global changes your default for
  all projects instead." Then wait for the answer.
- "/language German everywhere" -> "everywhere" is a scope word, so this is
  `set-global-language.sh de --overwrite`; only `de` reaches the script.
- "/language fr --global" -> `set-global-language.sh fr --overwrite` changes the
  global default, and status still prints `hr project`, so: "Your default for new
  projects is French now. This project still has Croatian; run /language fr here
  if you want to change that too."

## Output
- No document. The change is one line: `output_language: <code>` in this project's
  `CLAUDE.md` (project scope) or in your global config `~/.claude/CLAUDE.md`
  (global scope). Exactly one such line per file.
- The next generated document (PRD, story, plan, review write-up) follows it.

## Rules
- The scripts own validation and the write. Never hand-edit either file to help
  the command along, and never widen the code set here.
- If this project has no `CLAUDE.md`, do not create one and do not write the line
  yourself. Relay the refusal, then OFFER to run `/setup-project` for the user (it
  configures the project properly and asks for the language as part of setup), and
  name `/language <code> --global` as the alternative if they do not want to
  configure this project at all. Wait for their answer; never run setup unasked.
  That file is `/setup-project`'s artifact.
- A `--global` change refuses a symlinked global config (a `--link` install points
  it at a tracked repo file). Relay the refusal and offer project scope instead.
- Machine surfaces stay English whatever the code is; the guardrails in AGENTS.md
  hold as written (referenced here, not restated).
```
- Implement (b): `docs/system-map.md`, append as the LAST row of the "## 1. Setup & onboarding" table (after the `/focus` row):
```
| `/language` | Show or change the language generated documents are written in: `/language` reports the current language and where it is set, `/language de` sets this project, `/language de --global` sets your default for all projects (en, de, hr, fr). |
```
- Implement (c): `WORKFLOW.md`, insert immediately AFTER the line `| Configure a new project (stack, commands) | \`/setup-project\` (once per project, first thing) |`:
```
| Change the language of generated documents | `/language` (shows it) · `/language de` (this project) · `/language de --global` (all projects) |
```
- Verify: `bash bin/skills-lint.sh .` exit 0 (C5 requires every referenced `.sh` to exist, so Tasks 1 to 3 must be committed first; C7 forbids em/en dashes; C9 requires the description); confirm the three script names resolve: `for s in language-status.sh set-project-language.sh set-global-language.sh resolve-language.sh; do test -f "bin/$s" || echo "MISSING $s"; done` prints nothing; `grep -n '/language' docs/system-map.md WORKFLOW.md` shows both rows; full suite green (command in Task 4); `git ls-tree -r -z --name-only HEAD | bin/publish-guard.sh --require-allowlist -` reports no unclassified path.
- Consumes: the three script contracts from Tasks 1 to 3.
- Produces: the user-facing `/language` command.
- Commit: `feat(language): add the /language command and map it in the docs`

## Success signal (every acceptance criterion mapped to a concrete check)
| Acceptance criterion | Check |
|---|---|
| A command shows the current effective language AND its scope | `bin/language-status.sh` prints `<code> <scope>`; `tests/language-status.test.sh` cases 1, 2, 3, 4 (project / global / default), case 5 (invalid project value reports `global`, not `project`), case 9 (agrees with the resolver on every fixture) |
| `/language <code>` with a code in {en, de, hr, fr} sets it | project: `tests/set-project-language.test.sh` cases 1, 2, 10; global: `tests/set-global-language.test.sh` cases 9, 10, 12 |
| An unsupported code is rejected and the allowed set is listed | `tests/set-project-language.test.sh` case 6 and `tests/set-global-language.test.sh` cases 5 (existing) and 13, all assert exit 1 + `klingon` + `en de hr fr` + file unchanged |
| Can target either the project override or the global default | `--global` routes to `set-global-language.sh --overwrite`, default routes to `set-project-language.sh`; `tests/language-change-anytime.test.sh` cases 1, 3, 4 exercise both, including the project-masks-global case |
| The next generated artifact reflects the change | `bin/resolve-language.sh` (the single input every generator reads) returns the new code: integration cases 1, 2, 4. Generators actually writing prose in it is USR-005, out of scope, stated honestly |
| Written in the same canonical form as setup | both writers emit `output_language: <code>` and nothing else; `tests/init-project.language.test.sh` still green (USR-002 format untouched); `bin/language-guard.sh` tests still green (guardrail reads it identically) |
| No manual file editing required | every path is a script invocation from the skill; no step in `skills/language/SKILL.md` tells the user or the agent to edit a file |
| No duplicate second line on repeated sets | `tests/set-project-language.test.sh` case 3 (three sequential sets, count stays 1) and case 5 (pre-existing duplicates collapse); `tests/set-global-language.test.sh` case 11 |
| USR-003 regression: asked once, never silently overwritten | `tests/set-global-language.test.sh` cases 1 to 8 pass UNMODIFIED, plus case 16 (no flag still leaves an existing value alone); `install.sh` is not modified and passes no flag |
| Non-interactive / CI safe | no script prompts; exit codes 0/1/2 asserted in every test file; full suite runs unattended |
| The five copies of the allowlist cannot silently diverge | `tests/language-allowlist-agreement.test.sh` (Task 4b) drives the four scripts behaviorally and checks the fifth (`bin/init-project.sh`) textually; `tests/language-status.test.sh` case 8 covers the one remaining direction (a code dropped from `language-status.sh` alone). Task 4b's two required mutations prove the guard can fail. A future added code that is missed in one file breaks the suite instead of half-working. |
| The new test cases actually run (not stranded after `exit`) | `bash tests/set-global-language.test.sh \| grep -c '^ok:'` rises after the edit; cases 9 to 16 appear BEFORE the summary block at lines 65 to 67 |
| Suite + lint green, publish classification clean | `for t in tests/*.test.sh; do bash "$t" >/dev/null 2>&1 || echo "FAILED: $t"; done` prints nothing; `bash bin/skills-lint.sh .` exit 0; `git ls-tree -r -z --name-only HEAD | bin/publish-guard.sh --require-allowlist -` reports no unclassified path |

## Do-not-touch boundaries
- `bin/resolve-language.sh`: READ-ONLY. USR-002's shipped precedence behavior with 12 tests; other callers depend on its "one code on stdout" contract. Scope is added beside it, never inside it.
- `bin/language-guard.sh` and `tests/language-guard.test.sh`: DO NOT TOUCH. The stored value stays an ASCII allowlisted code in a non-frontmatter line, so the `[E]` no-leak guardrail is unaffected; the full suite green is the proof.
- `install.sh`: DO NOT MODIFY. The `--overwrite` flag exists precisely so the installer's call sites need no change.
- `tests/set-global-language.test.sh` cases 1 to 8: never edit (new cases are INSERTED before the summary block, see the file map). They are USR-003's guarantee.
- `tests/global-default-inherit.test.sh`: DO NOT MODIFY. It is the end-to-end half of USR-003's "asked exactly once" (writer to resolver) and passes unchanged under these edits; naming it here prevents a future builder from "adjusting" it.
- `bin/init-project.sh` and `tests/init-project.language.test.sh`: DO NOT MODIFY (USR-002's scaffold-time write).
- `skills/setup-project/SKILL.md`: DO NOT MODIFY. Its I2 step already says "Do not add a change-anytime command here"; `/language` is a separate skill.
- `project-templates/CLAUDE.md`, `global/CLAUDE.md`: unchanged.
- `docs/internal-paths.txt`, `docs/public-paths.txt`: no edit expected. If `publish-guard --require-allowlist` reports an unclassified path, STOP and flag it instead of editing the lists.
- Do not build USR-005 or USR-006.

## Risks / open questions
1. **Duplicated update-or-insert logic** now exists in `bin/init-project.sh` (scaffold time) and `bin/set-project-language.sh` (change time), and the code set is a literal in four scripts plus a `case` in a fifth. This matches the repo's self-contained-file convention, and `init-project.sh` is do-not-touch here. CLOSED MECHANICALLY, not left open: Task 4b adds `tests/language-allowlist-agreement.test.sh`, which fails loudly if any script's accepted code set diverges. Remaining (accepted) exposure is the WRITE MECHANISM, not the code set: see design decision 3 for the one deliberate divergence. A shared-writer refactor stays optional future cleanup, no longer a silent-drift risk.
2. **Missing project `CLAUDE.md` is refused (exit 1), not created.** Rationale: `CLAUDE.md` is the project's config artifact owned by `/setup-project`; silently creating a one-line file would leave a structureless config that later setup steps would have to reconcile. The refusal message names both ways forward. OPEN for the human: is refusing right, or should `/language <code>` create a minimal `CLAUDE.md`?
3. **Symlinked global config is refused on write** (`--link` installs). The user keeps project scope, so `/language` still works, but "no manual editing" is not fully true for that install shape. Accepted limitation, consistent with the guard USR-003 put in `install.sh`. Flag if the human wants a different behavior (for example writing to a separate global config file).
4. **Default scope = project.** If the human prefers global as the default at the gate, only `skills/language/SKILL.md` changes; the scripts are unaffected.
5. **Flag name `--overwrite`.** If review prefers `--force`, it is a rename in three places (script header, arg parse, skill step 1) plus the new test cases.
6. **`language-status.sh` copies `read_lang`** from the resolver because the resolver must not change. Drift risk is contained: the CODE always comes from the resolver, and case 9 asserts agreement across the fixture matrix including the degrade and normalization cases. If the resolver's rules ever change, that case fails loudly.
7. **A `--global` change masked by a project line** cannot be prevented deterministically (precedence is by design). Handled as UX: the skill re-runs the status and reports the masking. A user who ignores the message may think nothing happened.
8. **`./install.sh` re-run.** `bin/*.sh` reaches `~/bin` only via `install.sh`, so `/language` works outside this repo only after a re-run. That mutates the user's `$HOME`: the builder must ASK before running it and must not run it unprompted.
9. **"The next generated artifact reflects the change"** is verified at the resolver boundary only. Generated prose actually appearing in the language is USR-005; do not claim it in the review record.
