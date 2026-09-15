#!/usr/bin/env bash
# Tests for bin/boundary-check.sh, the DO-NOT-TOUCH path gate.
# Reads boundaries from docs/codebase-map.md (lines "- <path>" under the
# "## DO-NOT-TOUCH" heading) and fails if the branch's changed files touch them.
# Run: bash tests/boundary-check.test.sh
set -uo pipefail
# Fake, throwaway git identity for the temp repos these tests build. Not a real
# address (example.com is reserved, RFC 2606); never committed to a real repo or
# pushed. Makes fixture commits work regardless of the runner's git config (CI has
# none), so a missing ambient identity cannot masquerade as a gate failure.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$TEST_DIR/../bin/boundary-check.sh"
pass=0; fail=0

make_repo() { # make_repo <boundaries-block or empty> -> echoes repo dir
  local d; d="$(mktemp -d)"
  ( cd "$d" && git init -q -b main \
    && mkdir -p src/legacy src/app docs \
    && echo "old" > src/legacy/billing.ts && echo "app" > src/app/main.ts \
    && { [[ -n "$1" ]] && printf '%s\n' "$1" > docs/codebase-map.md || true; } \
    && git add -A && git commit -qm init ) >/dev/null 2>&1
  echo "$d"
}
BOUNDS=$'# Map\n## DO-NOT-TOUCH (proposed)\n- src/legacy/\n- vendor/\n## Open questions\n- none'

# 1. change outside boundaries -> pass
d="$(make_repo "$BOUNDS")"
( cd "$d" && git checkout -qb f1 && echo "x" >> src/app/main.ts && git commit -aqm c ) >/dev/null 2>&1
( cd "$d" && bash "$CHECK" main ) >/dev/null 2>&1; rc=$?
[[ $rc -eq 0 ]] && { echo "ok   - change outside boundaries passes"; pass=$((pass+1)); } || { echo "FAIL - outside change rc=$rc"; fail=$((fail+1)); }
rm -rf "$d"

# 2. change INSIDE a boundary -> block
d="$(make_repo "$BOUNDS")"
( cd "$d" && git checkout -qb f2 && echo "x" >> src/legacy/billing.ts && git commit -aqm c ) >/dev/null 2>&1
( cd "$d" && bash "$CHECK" main ) >/dev/null 2>&1; rc=$?
[[ $rc -eq 1 ]] && { echo "ok   - boundary touch blocks"; pass=$((pass+1)); } || { echo "FAIL - boundary touch rc=$rc (want 1)"; fail=$((fail+1)); }
rm -rf "$d"

# 3. no codebase-map -> pass with note (nothing to enforce)
d="$(make_repo "")"
( cd "$d" && git checkout -qb f3 && echo "x" >> src/legacy/billing.ts && git commit -aqm c ) >/dev/null 2>&1
( cd "$d" && bash "$CHECK" main ) >/dev/null 2>&1; rc=$?
[[ $rc -eq 0 ]] && { echo "ok   - no map = nothing to enforce, passes"; pass=$((pass+1)); } || { echo "FAIL - no-map rc=$rc"; fail=$((fail+1)); }
rm -rf "$d"

# 4. uncommitted (working tree) boundary touch also blocks
d="$(make_repo "$BOUNDS")"
( cd "$d" && git checkout -qb f4 && echo "x" >> src/legacy/billing.ts ) >/dev/null 2>&1
( cd "$d" && bash "$CHECK" main ) >/dev/null 2>&1; rc=$?
[[ $rc -eq 1 ]] && { echo "ok   - uncommitted boundary touch blocks"; pass=$((pass+1)); } || { echo "FAIL - uncommitted rc=$rc (want 1)"; fail=$((fail+1)); }
rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
