#!/usr/bin/env bash
# Tests for bin/merge-gate.sh, the /merge deterministic gate.
# Run: bash tests/merge-gate.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$TEST_DIR/../bin/merge-gate.sh"
pass=0; fail=0

make_repo() { local d; d="$(mktemp -d)"; ( cd "$d" && git init -q -b main && echo a > a.txt && git add -A && git commit -qm init ) >/dev/null 2>&1; echo "$d"; }
check() { # check <name> <expected_rc> <repo> [args...]
  local name="$1" want="$2" repo="$3"; shift 3
  ( cd "$repo" && bash "$GATE" "$@" ) >/dev/null 2>&1; local rc=$?
  if [[ $rc -eq $want ]]; then echo "ok   - $name"; pass=$((pass+1)); else echo "FAIL - $name (rc=$rc want=$want)"; fail=$((fail+1)); fi
}

# 1. On main -> refuse
d="$(make_repo)"; check "refuses on main" 1 "$d"; rm -rf "$d"

# 2. On branch, NO review record -> refuse
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git commit -aqm c ) >/dev/null 2>&1
check "refuses without a review record" 1 "$d"; rm -rf "$d"

# 3. On branch WITH review record for the branch -> pass
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && mkdir -p docs/evals && echo rec > "docs/evals/code-feature-x.md" && echo b >> a.txt && git add -A && git commit -qm c ) >/dev/null 2>&1
check "passes with review record" 0 "$d"; rm -rf "$d"

# 4. Dirty working tree -> refuse (uncommitted work must not merge)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && mkdir -p docs/evals && echo rec > "docs/evals/code-feature-x.md" && git add -A && git commit -qm c && echo dirty >> a.txt ) >/dev/null 2>&1
check "refuses dirty working tree" 1 "$d"; rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
