#!/usr/bin/env bash
# Tests for bin/resolve-language.sh, the deterministic effective-language resolver.
# Covers all 12 cases from the plan: precedence, fallback, normalization,
# invalid-value degrade, duplicate lines, usage errors, and directory errors.
# TDD: run this FIRST (RED while the script is absent), then implement to GREEN.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/resolve-language.sh"
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
# Case 1: Project override wins over global.
# Project CLAUDE.md has output_language: de, global has output_language: fr.
# Expected: echoes de, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case1"
printf 'output_language: de\n' > "$TMP/case1/CLAUDE.md"
printf 'output_language: fr\n' > "$TMP/global-case1.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/global-case1.md" "$SCRIPT" "$TMP/case1" 2>&1)"; rc=$?
assert_exit "project override wins over global -> exit 0" 0 "$rc"
assert_contains "project override echoes de" "de" "$out"

# ---------------------------------------------------------------------------
# Case 2: Falls back to global when no project line.
# Project CLAUDE.md has no output_language: line, global has output_language: hr.
# Expected: echoes hr, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case2"
printf '## Conventions\nsome other content\n' > "$TMP/case2/CLAUDE.md"
printf 'output_language: hr\n' > "$TMP/global-case2.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/global-case2.md" "$SCRIPT" "$TMP/case2" 2>&1)"; rc=$?
assert_exit "falls back to global when no project line -> exit 0" 0 "$rc"
assert_contains "global fallback echoes hr" "hr" "$out"

# ---------------------------------------------------------------------------
# Case 3: Falls back to en when neither level present.
# Project CLAUDE.md exists without the line; CLAUDE_GLOBAL_CONFIG points at a
# nonexistent file. Expected: echoes en, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case3"
printf '## Conventions\n' > "$TMP/case3/CLAUDE.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$SCRIPT" "$TMP/case3" 2>&1)"; rc=$?
assert_exit "falls back to en when neither present -> exit 0" 0 "$rc"
assert_contains "double fallback echoes en" "en" "$out"

# ---------------------------------------------------------------------------
# Case 4: No CLAUDE.md at all in project dir (skip case).
# Expected: echoes en, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case4"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$SCRIPT" "$TMP/case4" 2>&1)"; rc=$?
assert_exit "no CLAUDE.md -> echoes en, exit 0" 0 "$rc"
assert_contains "no CLAUDE.md echoes en" "en" "$out"

# ---------------------------------------------------------------------------
# Case 5: All four valid codes round-trip.
# For each of en/de/hr/fr as a project line -> echoes that code, exit 0.
# ---------------------------------------------------------------------------
for code in en de hr fr; do
  mkdir -p "$TMP/case5-$code"
  printf 'output_language: %s\n' "$code" > "$TMP/case5-$code/CLAUDE.md"
  out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$SCRIPT" "$TMP/case5-$code" 2>&1)"; rc=$?
  assert_exit "code $code round-trips -> exit 0" 0 "$rc"
  assert_contains "code $code echoed back" "$code" "$out"
done

# ---------------------------------------------------------------------------
# Case 6: Invalid project value degrades to global.
# Project has output_language: klingon, global has output_language: fr.
# Expected: echoes fr, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case6"
printf 'output_language: klingon\n' > "$TMP/case6/CLAUDE.md"
printf 'output_language: fr\n' > "$TMP/global-case6.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/global-case6.md" "$SCRIPT" "$TMP/case6" 2>&1)"; rc=$?
assert_exit "invalid project value degrades to global -> exit 0" 0 "$rc"
assert_contains "degraded to global echoes fr" "fr" "$out"

# ---------------------------------------------------------------------------
# Case 7: Invalid at both levels degrades to en.
# Project has output_language: xx, global has output_language: yy.
# Expected: echoes en, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case7"
printf 'output_language: xx\n' > "$TMP/case7/CLAUDE.md"
printf 'output_language: yy\n' > "$TMP/global-case7.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/global-case7.md" "$SCRIPT" "$TMP/case7" 2>&1)"; rc=$?
assert_exit "invalid at both levels degrades to en -> exit 0" 0 "$rc"
assert_contains "both invalid echoes en" "en" "$out"

# ---------------------------------------------------------------------------
# Case 8: Whitespace, uppercase, and CR are normalized.
# Line written as "output_language:   DE " with trailing CR simulated via $'\r'.
# Expected: echoes de, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case8"
printf 'output_language:   DE \r\n' > "$TMP/case8/CLAUDE.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$SCRIPT" "$TMP/case8" 2>&1)"; rc=$?
assert_exit "whitespace/uppercase/CR tolerated -> exit 0" 0 "$rc"
assert_contains "normalized to de" "de" "$out"

# ---------------------------------------------------------------------------
# Case 9: First line wins on duplicates.
# Two project lines: output_language: fr then output_language: de.
# Expected: echoes fr, exit 0.
# ---------------------------------------------------------------------------
mkdir -p "$TMP/case9"
printf 'output_language: fr\noutput_language: de\n' > "$TMP/case9/CLAUDE.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$SCRIPT" "$TMP/case9" 2>&1)"; rc=$?
assert_exit "first line wins on duplicates -> exit 0" 0 "$rc"
assert_contains "first duplicate echoes fr" "fr" "$out"

# ---------------------------------------------------------------------------
# Case 10: Usage error, no args.
# Expected: exit 2, stderr contains 'usage'.
# ---------------------------------------------------------------------------
out="$("$SCRIPT" 2>&1)"; rc=$?
assert_exit "no args -> exit 2" 2 "$rc"
assert_contains "no args stderr contains usage" "usage" "$out"

# ---------------------------------------------------------------------------
# Case 11: Usage error, too many args.
# Expected: exit 2.
# ---------------------------------------------------------------------------
out="$("$SCRIPT" a b 2>&1)"; rc=$?
assert_exit "too many args -> exit 2" 2 "$rc"

# ---------------------------------------------------------------------------
# Case 12: Nonexistent project dir.
# Expected: exit 2, stderr contains 'not found'.
# ---------------------------------------------------------------------------
out="$("$SCRIPT" "$TMP/nope" 2>&1)"; rc=$?
assert_exit "nonexistent project dir -> exit 2" 2 "$rc"
assert_contains "nonexistent dir stderr contains not found" "not found" "$out"

exit $fail
