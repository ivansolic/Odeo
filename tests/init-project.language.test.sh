#!/usr/bin/env bash
# Tests for the output-language wiring in bin/init-project.sh.
# Covers the non-interactive flag path only (no TTY harness available).
# TDD: run this FIRST (RED), then implement to GREEN.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/init-project.sh"
fail=0
assert_exit() { # desc expected actual
  if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi
}
assert_contains() { # desc needle haystack
  case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Set a throwaway git identity so the git commits inside init-project.sh work
# regardless of the runner's git config (CI machines often have no identity).
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

# Stage a minimal CLAUDE_TEMPLATES_DIR with all REQUIRED_TEMPLATES.
# CLAUDE.md carries a Conventions anchor with the output_language: placeholder
# so the sed-replace branch in init-project.sh fires (Task 2 primary path).
TMPL="$TMP/templates"
mkdir -p "$TMPL/tasks" "$TMPL/docs" "$TMPL/design" "$TMPL/knowledge"
cp "$(cd "$(dirname "$0")/.." && pwd)/project-templates/CLAUDE.md" "$TMPL/CLAUDE.md"
touch "$TMPL/tasks/todo.md"
touch "$TMPL/tasks/lessons.md"
touch "$TMPL/docs/ADR-TEMPLATE.md"
touch "$TMPL/design/tokens.json"
touch "$TMPL/design/README.md"
touch "$TMPL/knowledge/README.md"

# All cases run non-interactively (stdin redirected from /dev/null) so the
# TTY check in init-project.sh takes the non-interactive branch. Each case
# runs in its own subdirectory so projects don't collide.

# ---------------------------------------------------------------------------
# Case 1: --no-ui --language de -> project CLAUDE.md has exactly one
# output_language: de line.
# ---------------------------------------------------------------------------
CASE1="$TMP/runs/case1"
mkdir -p "$CASE1"
(cd "$CASE1" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" myproject --no-ui --language de \
  </dev/null >/dev/null 2>&1); rc=$?
assert_exit "case1: --language de runs successfully" 0 "$rc"
count="$(grep -c '^output_language: de' "$CASE1/myproject/CLAUDE.md" 2>/dev/null || echo 0)"
if [ "$count" = "1" ]; then echo "ok: case1: output_language: de written exactly once"; else echo "FAIL: case1: expected 1 line, got $count"; fail=1; fi

# ---------------------------------------------------------------------------
# Case 2: --no-ui with no --language flag -> project CLAUDE.md contains
# exactly one output_language: en line (skip/default -> English).
# ---------------------------------------------------------------------------
CASE2="$TMP/runs/case2"
mkdir -p "$CASE2"
(cd "$CASE2" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" myproject --no-ui \
  </dev/null >/dev/null 2>&1); rc=$?
assert_exit "case2: no --language flag runs successfully" 0 "$rc"
count="$(grep -c '^output_language: en' "$CASE2/myproject/CLAUDE.md" 2>/dev/null || echo 0)"
if [ "$count" = "1" ]; then echo "ok: case2: output_language: en written by default"; else echo "FAIL: case2: expected 1 en line, got $count"; fail=1; fi

# ---------------------------------------------------------------------------
# Case 3: --language klingon -> exit non-zero, message to stderr, no project
# directory created (fail fast on a bad explicit flag value).
# ---------------------------------------------------------------------------
CASE3="$TMP/runs/case3"
mkdir -p "$CASE3"
out="$(cd "$CASE3" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" myproject --no-ui --language klingon \
  </dev/null 2>&1)"; rc=$?
assert_exit "case3: invalid --language exits non-zero" 1 "$rc"
assert_contains "case3: stderr mentions the bad language" "klingon" "$out"
if [ ! -d "$CASE3/myproject" ]; then echo "ok: case3: no project dir created on bad flag"; else echo "FAIL: case3: project dir should NOT have been created"; fail=1; fi

# ---------------------------------------------------------------------------
# Case 4: Exactly one output_language: line written (asked once, written once).
# Using grep -c '^output_language:' to count all forms, must be exactly 1.
# ---------------------------------------------------------------------------
CASE4="$TMP/runs/case4"
mkdir -p "$CASE4"
(cd "$CASE4" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" myproject --no-ui --language fr \
  </dev/null >/dev/null 2>&1); rc=$?
assert_exit "case4: --language fr runs successfully" 0 "$rc"
count="$(grep -c '^output_language:' "$CASE4/myproject/CLAUDE.md" 2>/dev/null || echo 0)"
if [ "$count" = "1" ]; then echo "ok: case4: exactly one output_language: line in CLAUDE.md"; else echo "FAIL: case4: expected exactly 1, got $count"; fail=1; fi

# ---------------------------------------------------------------------------
# Case 5: --language with NO following value -> exit non-zero, stderr says it
# needs a value, no project directory created (arch-review BLOCKING-1).
# ---------------------------------------------------------------------------
CASE5="$TMP/runs/case5"
mkdir -p "$CASE5"
out="$(cd "$CASE5" && CLAUDE_TEMPLATES_DIR="$TMPL" bash "$SCRIPT" myproject --no-ui --language \
  </dev/null 2>&1)"; rc=$?
assert_exit "case5: --language with no value exits non-zero" 1 "$rc"
assert_contains "case5: stderr says it needs a value" "value" "$out"
if [ ! -d "$CASE5/myproject" ]; then echo "ok: case5: no project dir created when --language has no value"; else echo "FAIL: case5: project dir should NOT have been created"; fail=1; fi

exit $fail
