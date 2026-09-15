#!/usr/bin/env bash
# Tests for bin/language-guard.sh, deterministic no-leak gate for machine surfaces.
# All 14 cases mirror the plan's Task 1 spec exactly. TDD: run this FIRST (RED),
# then implement language-guard.sh until all cases are GREEN.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/language-guard.sh"
fail=0
assert_exit() { # desc expected actual
  if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi
}
assert_contains() { # desc needle haystack
  case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# Case 1: Clean + non-English PROSE passes (exit 0).
# The body is Croatian prose with non-ASCII letters, but frontmatter is clean.
# Verifies the guard never reads prose body text (out of scope).
# ---------------------------------------------------------------------------
mkdir -p "$TMP/docs/prds"
cat > "$TMP/docs/prds/PRD-001-demo.md" <<'MD'
---
id: PRD-001
status: draft
---
Ovo je tijelo na hrvatskom jeziku s dijakriticima: č š ž đ ć.
Sve je u redu jer je tijelo izvan opsega provjere.
MD
out="$(bash "$SCRIPT" "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "clean + non-English prose passes" 0 "$rc"
assert_contains "clean pass string present" "machine surfaces clean" "$out"

# ---------------------------------------------------------------------------
# Case 2: Non-English ENUM VALUE fails (exit 1).
# Fixture has `verdict: PROSAO` in frontmatter; verdict is a free-text field
# subject to the ASCII rule only, and "PROSAO" is pure ASCII so it must PASS
# -- BUT we test a non-ASCII enum value for model_tier to trigger the violation.
# Wait: plan case 2 says `verdict: PROSAO` -> exit 1. PROSAO is ASCII.
# Re-reading: the case is about a non-ASCII enum value that fails.
# `verdict` is NOT a closed enum (only model_tier is). So the fixture should
# have `model_tier: brzo` (not in the allowlist fast|strong|strongest) to test
# the enum check, and/or a non-ASCII value for any field to test the ASCII rule.
# Per the plan: "Non-English ENUM VALUE fails -> exit 1, names file + surface."
# The illustrative value `verdict: PROSAO` in the plan is ASCII, but the intent
# is a value outside the closed enum for model_tier. We use `model_tier: brzo`.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/docs/evals"
cat > "$TMP/docs/evals/eval-bad-enum.md" <<'MD'
---
verdict: PROSAO
model_tier: brzo
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/evals/eval-bad-enum.md" 2>&1)"; rc=$?
assert_exit "non-allowed enum value fails" 1 "$rc"
assert_contains "names the file" "eval-bad-enum.md" "$out"
assert_contains "names the surface 'enum'" "enum" "$out"

# ---------------------------------------------------------------------------
# Case 3: Non-ASCII FRONTMATTER FIELD NAME fails (exit 1).
# The frontmatter key itself contains a non-ASCII byte.
# ---------------------------------------------------------------------------
# Write the fixture with separate printf calls so the non-ASCII byte (UTF-8
# encoded "c" with caron = klj + U+010D = 0xC4 0x8D) lands correctly.
{ printf '%s\n' '---'; printf '%b: value\n' 'klju\xc4\x8d';
  printf '%s\n' 'status: draft'; printf '%s\n' '---'; printf '%s\n' 'body'; } \
  > "$TMP/docs/evals/eval-bad-key.md"
out="$(bash "$SCRIPT" "$TMP/docs/evals/eval-bad-key.md" 2>&1)"; rc=$?
assert_exit "non-ASCII frontmatter field name fails" 1 "$rc"
assert_contains "names the surface 'field name'" "field name" "$out"

# ---------------------------------------------------------------------------
# Case 4: Bad FILENAME SLUG fails (exit 1).
# File named with uppercase + underscore in the human-authored slug tail.
# ---------------------------------------------------------------------------
cat > "$TMP/docs/prds/PRD-002-Bad_Name.md" <<'MD'
---
id: PRD-002
status: draft
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/prds/PRD-002-Bad_Name.md" 2>&1)"; rc=$?
assert_exit "bad filename slug fails" 1 "$rc"
assert_contains "names the file" "PRD-002-Bad_Name.md" "$out"
assert_contains "names the surface 'filename'" "filename" "$out"

# ---------------------------------------------------------------------------
# Case 5: Non-ASCII DIRECTORY NAME fails (exit 1).
# A directory with a non-ASCII byte in its name.
# ---------------------------------------------------------------------------
BADDIR="$TMP/$(printf 'dir\xc4\x8d')"
mkdir -p "$BADDIR"
out="$(bash "$SCRIPT" "$BADDIR" 2>&1)"; rc=$?
assert_exit "non-ASCII directory name fails" 1 "$rc"
assert_contains "names the surface 'directory'" "directory" "$out"

# ---------------------------------------------------------------------------
# Case 6: Bad COMMIT TYPE fails (exit 1).
# A non-English commit type not in the COMMIT_TYPES allowlist.
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" --commit "napravi(auth): x" "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "bad commit type fails" 1 "$rc"
assert_contains "names the surface 'commit type'" "commit type" "$out"

# ---------------------------------------------------------------------------
# Case 7: Non-ASCII COMMIT SCOPE fails (exit 1).
# Scope contains a non-ASCII letter (ā = U+0101).
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" --commit "feat(prijavā): x" "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "non-ASCII commit scope fails" 1 "$rc"
assert_contains "names the surface 'scope'" "scope" "$out"

# ---------------------------------------------------------------------------
# Case 8: Non-ASCII BRANCH NAME fails (exit 1).
# Branch name contains a non-ASCII letter (ā = U+0101).
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" --branch "feature/prijavā" "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "non-ASCII branch name fails" 1 "$rc"
assert_contains "names the surface 'branch'" "branch" "$out"

# ---------------------------------------------------------------------------
# Case 9: Valid branch + commit + clean file all pass (exit 0).
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" --branch "feature/login" --commit "feat(auth): add login" \
  "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "valid branch + commit + clean file passes" 0 "$rc"
assert_contains "clean pass string present" "machine surfaces clean" "$out"

# ---------------------------------------------------------------------------
# Case 10: Usage errors (exit 2).
# a) No arguments at all.
# b) A path that does not exist.
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" 2>&1)"; rc=$?
assert_exit "no args exits 2" 2 "$rc"

out="$(bash "$SCRIPT" "$TMP/does-not-exist.md" 2>&1)"; rc=$?
assert_exit "nonexistent path exits 2" 2 "$rc"

# ---------------------------------------------------------------------------
# Case 11: ASCII free-text values pass even when not slug-shaped (exit 0).
# `model_tier: strong` -> valid enum; `verdict: NEEDS WORK` and
# `status: In Progress` -> ASCII-only, not enum-checked, must pass.
# Guards against over-strict rejection (arch-review BLOCKING-2 + NOTE-A).
# ---------------------------------------------------------------------------
cat > "$TMP/docs/evals/eval-ascii-values.md" <<'MD'
---
verdict: NEEDS WORK
status: In Progress
model_tier: strong
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/evals/eval-ascii-values.md" 2>&1)"; rc=$?
assert_exit "ASCII free-text values pass (no over-strict rejection)" 0 "$rc"

# ---------------------------------------------------------------------------
# Case 12: Nested frontmatter keys pass (exit 0).
# A plan-shaped file with `model_plan:` and indented children must not fail
# because the indented children are continuation lines, not top-level keys.
# Locks arch-review BLOCKING-1 fix.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/docs/plans"
cat > "$TMP/docs/plans/2026-07-23-USR-001-nested.md" <<'MD'
---
id: PLAN-001
model_plan:
  judgment: strong
  builder: sonnet
arch_review: clean
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/plans/2026-07-23-USR-001-nested.md" 2>&1)"; rc=$?
assert_exit "nested frontmatter children do not fail field-name check" 0 "$rc"

# ---------------------------------------------------------------------------
# Case 13: Date-prefixed and range-prefixed filenames pass (exit 0).
# Both `2026-07-23-USR-001-no-leak-guardrail.md` and
# `USR-001-006-output-language.md` must pass after prefix stripping.
# Locks arch-review IMPORTANT-3 fix.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/docs/plans" "$TMP/docs/stories"
cat > "$TMP/docs/plans/2026-07-23-USR-001-no-leak-guardrail.md" <<'MD'
---
id: PLAN-001
status: draft
---
MD
cat > "$TMP/docs/stories/USR-001-006-output-language.md" <<'MD'
---
id: USR-001
status: draft
---
MD
out="$(bash "$SCRIPT" \
  "$TMP/docs/plans/2026-07-23-USR-001-no-leak-guardrail.md" \
  "$TMP/docs/stories/USR-001-006-output-language.md" 2>&1)"; rc=$?
assert_exit "date-prefixed and range-prefixed filenames pass" 0 "$rc"

# ---------------------------------------------------------------------------
# Case 14: Commit scope is optional (exit 0).
# `feat: no scope` and `chore(deps): x` both pass.
# Locks arch-review IMPORTANT-4 fix.
# ---------------------------------------------------------------------------
out="$(bash "$SCRIPT" --commit "feat: no scope" \
  "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "commit without scope passes" 0 "$rc"

out="$(bash "$SCRIPT" --commit "chore(deps): x" \
  "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "commit with ASCII scope passes" 0 "$rc"

# ---------------------------------------------------------------------------
# Locale-safety tests (Cases 15-18): uppercase-only ASCII must be rejected
# regardless of the runner's locale. These pin the fix for the locale bug:
# case patterns like *[!a-z0-9_-]* are locale-sensitive and fail open under a
# UTF-8 locale (e.g. en_US.UTF-8 makes [a-z] collate to include uppercase).
#
# Each case runs BOTH under the default environment AND under en_US.UTF-8 (and
# de_AT.UTF-8 if available) to catch a regression regardless of CI locale.
# ---------------------------------------------------------------------------

# Helper: run the guard under a specific locale and assert exit code + substring.
assert_locale() {
  # desc locale expected_exit expected_substr command_args...
  local desc="$1" test_locale="$2" want_exit="$3" want_substr="$4"
  shift 4
  local out rc
  out="$(LC_ALL="$test_locale" bash "$SCRIPT" "$@" 2>&1)"; rc=$?
  assert_exit "$desc [locale=$test_locale]" "$want_exit" "$rc"
  assert_contains "$desc: surface '$want_substr' present [locale=$test_locale]" "$want_substr" "$out"
}

# Collect the UTF-8 locales we want to exercise (skip any not installed).
# Capture all locales first to avoid a broken-pipe from locale -a under pipefail
# (grep -q exits early after a match, causing locale -a to get SIGPIPE, which
# makes the pipe exit non-zero and trips set -o pipefail).
UTF8_LOCALES=""
all_locales="$(locale -a 2>/dev/null)"
for l in en_US.UTF-8 de_AT.UTF-8; do
  if printf "%s\n" "$all_locales" | grep -qxF "$l" 2>/dev/null; then
    UTF8_LOCALES="$UTF8_LOCALES $l"
  fi
done

# Case 15: Frontmatter key with bare uppercase ASCII (Id:) must fail.
# A regression would show as the key passing under a UTF-8 locale.
cat > "$TMP/docs/prds/PRD-003-locale-key.md" <<'MD'
---
Id: x
status: draft
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/prds/PRD-003-locale-key.md" 2>&1)"; rc=$?
assert_exit "uppercase frontmatter key (Id:) fails (default locale)" 1 "$rc"
assert_contains "uppercase key: surface 'field name'" "field name" "$out"

for l in $UTF8_LOCALES; do
  assert_locale "uppercase frontmatter key (Id:) fails" "$l" 1 "field name" \
    "$TMP/docs/prds/PRD-003-locale-key.md"
done

# Case 16: Filename slug tail with bare uppercase ASCII (BadName) must fail.
# PRD-002-BadName.md: after stripping the PRD-002- prefix, tail is "BadName".
cat > "$TMP/docs/prds/PRD-002-BadName.md" <<'MD'
---
id: PRD-002
status: draft
---
MD
out="$(bash "$SCRIPT" "$TMP/docs/prds/PRD-002-BadName.md" 2>&1)"; rc=$?
assert_exit "uppercase slug tail (BadName) fails (default locale)" 1 "$rc"
assert_contains "uppercase slug: surface 'filename'" "filename" "$out"

for l in $UTF8_LOCALES; do
  assert_locale "uppercase slug tail (BadName) fails" "$l" 1 "filename" \
    "$TMP/docs/prds/PRD-002-BadName.md"
done

# Case 17: Directory with bare uppercase ASCII name (BadDir) must fail.
LOCALE_BADDIR="$TMP/BadDir"
mkdir -p "$LOCALE_BADDIR"
out="$(bash "$SCRIPT" "$LOCALE_BADDIR" 2>&1)"; rc=$?
assert_exit "uppercase directory name (BadDir) fails (default locale)" 1 "$rc"
assert_contains "uppercase dir: surface 'directory'" "directory" "$out"

for l in $UTF8_LOCALES; do
  assert_locale "uppercase directory name (BadDir) fails" "$l" 1 "directory" \
    "$LOCALE_BADDIR"
done

# Case 18: Commit scope with bare uppercase ASCII (Auth) must fail.
out="$(bash "$SCRIPT" --commit "feat(Auth): x" "$TMP/docs/prds/PRD-001-demo.md" 2>&1)"; rc=$?
assert_exit "uppercase commit scope (Auth) fails (default locale)" 1 "$rc"
assert_contains "uppercase scope: surface 'scope'" "scope" "$out"

for l in $UTF8_LOCALES; do
  assert_locale "uppercase commit scope (Auth) fails" "$l" 1 "scope" \
    --commit "feat(Auth): x" "$TMP/docs/prds/PRD-001-demo.md"
done

# Case 19: branch/commit-only invocation (NO path) must run, not crash under set -u.
out="$(bash "$SCRIPT" --branch feature/ok 2>&1)"; rc=$?
assert_exit "branch-only, clean, passes" 0 "$rc"
out="$(bash "$SCRIPT" --commit "feat(auth): x" 2>&1)"; rc=$?
assert_exit "commit-only, clean, passes" 0 "$rc"
out="$(bash "$SCRIPT" --branch "feature/prijavā" 2>&1)"; rc=$?
assert_exit "branch-only, bad, fails" 1 "$rc"
assert_contains "branch-only bad: surface 'branch'" "branch" "$out"
out="$(bash "$SCRIPT" --commit "feat(Auth): x" 2>&1)"; rc=$?
assert_exit "commit-only, bad scope, fails" 1 "$rc"
assert_contains "commit-only bad: surface 'scope'" "scope" "$out"

exit $fail
