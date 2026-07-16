#!/usr/bin/env bash
# Tests for bin/spec-gate.sh, the /build entry gate for spec artifacts.
# A story/PRD may enter the build only with a FRESH, PASSING eval record that
# covers it. Run: bash tests/spec-gate.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$TEST_DIR/../bin/spec-gate.sh"
pass=0; fail=0

T1='2026-01-01T10:00:00'; T2='2026-01-01T11:00:00'; T3='2026-01-01T12:00:00'
commit_at() { ( cd "$1" && GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -qm "$3" ) >/dev/null 2>&1; }
make_repo() { local d; d="$(mktemp -d)"; ( cd "$d" && git init -q -b main && mkdir -p docs/stories docs/prds docs/evals && echo seed > seed.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T1" init; echo "$d"; }
story() { # story <repo> <id-slug> <commit-time>
  ( cd "$1" && printf 'story body\n' > "docs/stories/$2.md" && git add -A ) >/dev/null 2>&1
  commit_at "$1" "$3" "story $2"
}
record() { # record <repo> <artifact-line> <verdict> <commit-time>
  ( cd "$1" && printf -- '---\n%s\nverdict: %s\n---\nbody\n' "$2" "$3" > docs/evals/rec.md && git add -A ) >/dev/null 2>&1
  commit_at "$1" "$4" record
}
check() { local name="$1" want="$2" repo="$3"; shift 3
  ( cd "$repo" && bash "$GATE" "$@" ) >/dev/null 2>&1; local rc=$?
  if [[ $rc -eq $want ]]; then echo "ok   - $name"; pass=$((pass+1)); else echo "FAIL - $name (rc=$rc want=$want)"; fail=$((fail+1)); fi; }

# usage
d="$(make_repo)"; check "no args -> usage error (2)" 2 "$d"; rm -rf "$d"
d="$(make_repo)"; check "nonexistent artifact -> error (2)" 2 "$d" docs/stories/USR-404-ghost.md; rm -rf "$d"

# 1. story with no record at all -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"
check "refuses story without any eval record" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 2. record for a DIFFERENT id -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-002" PASS "$T3"
check "refuses record for another id" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 3. fresh PASS via artifact: -> pass
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" PASS "$T3"
check "passes fresh PASS record (artifact:)" 0 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 4. fresh PASS via covers: list (story sets) -> pass
d="$(make_repo)"; story "$d" USR-003-crud "$T2"; record "$d" "covers: USR-001 USR-002 USR-003 USR-004" PASS "$T3"
check "passes when covers: lists the id" 0 "$d" docs/stories/USR-003-crud.md; rm -rf "$d"

# 4b. covers of USR-001-008 style set must NOT match USR-003 by accident
d="$(make_repo)"; story "$d" USR-003-crud "$T2"; record "$d" "artifact: USR-001-008" PASS "$T3"
check "refuses set-NAME record that doesn't list the id" 1 "$d" docs/stories/USR-003-crud.md; rm -rf "$d"

# 5. verdict FAIL -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" FAIL "$T3"
check "refuses FAIL verdict" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 6. STALE: story committed AFTER the record -> refuse
d="$(make_repo)"; record "$d" "artifact: USR-001" PASS "$T2"; story "$d" USR-001-login "$T3"
check "refuses stale record (spec changed after review)" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 7. uncommitted changes to the artifact -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" PASS "$T3"
( cd "$d" && echo tweak >> docs/stories/USR-001-login.md )
check "refuses uncommitted spec changes" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 8. several paths, one uncovered -> refuse (all must hold)
d="$(make_repo)"; story "$d" USR-001-login "$T2"; story "$d" USR-002-list "$T2"
record "$d" "covers: USR-001" PASS "$T3"
check "refuses when one of several stories is uncovered" 1 "$d" docs/stories/USR-001-login.md docs/stories/USR-002-list.md; rm -rf "$d"

# 9. PRD works the same way
d="$(make_repo)"
( cd "$d" && printf 'prd body\n' > docs/prds/PRD-001-core.md && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" prd
record "$d" "artifact: PRD-001" PASS "$T3"
check "passes a fresh PASS PRD record" 0 "$d" docs/prds/PRD-001-core.md; rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
