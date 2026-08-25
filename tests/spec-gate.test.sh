#!/usr/bin/env bash
# Tests for bin/spec-gate.sh, the /build entry gate for spec artifacts.
# A story/PRD may enter the build only with a FRESH, PASSING eval record that
# covers it. Run: bash tests/spec-gate.test.sh
set -uo pipefail
# Fake, throwaway git identity for the temp repos these tests build. Not a real
# address (example.com is reserved, RFC 2606); never committed to a real repo or
# pushed. Makes fixture commits work regardless of the runner's git config (CI has
# none), so a missing ambient identity cannot masquerade as a gate failure.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
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
record() { # record <repo> <artifact-line> <verdict> <commit-time> [filename] [body] [tier-lines]
  local f="${5:-rec.md}" body="${6:-body}" tier="${7:-model_tier: strong}"
  ( cd "$1" && printf -- '---\n%s\nverdict: %s\n%s\n---\n%s\n' "$2" "$3" "$tier" "$body" > "docs/evals/$f" && git add -A ) >/dev/null 2>&1
  commit_at "$1" "$4" "record $f"
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

# 10. DIRTY RECORD BYPASS (critical regression): committed REQUEST CHANGES,
#     verdict hand-edited to PASS without committing -> must refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" "REQUEST CHANGES" "$T3"
( cd "$d" && printf -- '---\nartifact: USR-001\nverdict: PASS\n---\nbody\n' > docs/evals/rec.md )
check "refuses uncommitted record edits (dirty-evals bypass)" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 11. artifact OUTSIDE the repo -> fail closed (2), never 0
d="$(make_repo)"; outside="$(mktemp -d)"; printf 'x\n' > "$outside/USR-001-x.md"
check "fails closed on artifact outside the repo" 2 "$d" "$outside/USR-001-x.md"; rm -rf "$d" "$outside"

# 12. subdir invocation works (path resolution)
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" PASS "$T3"
( cd "$d" && mkdir -p sub )
( cd "$d/sub" && bash "$GATE" ../docs/stories/USR-001-login.md ) >/dev/null 2>&1; rc=$?
if [[ $rc -eq 0 ]]; then echo "ok   - passes when invoked from a subdirectory"; pass=$((pass+1));
else echo "FAIL - subdir invocation (rc=$rc want=0)"; fail=$((fail+1)); fi
rm -rf "$d"

# 13. newest record wins: older PASS + newer FAIL -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T1"; record "$d" "artifact: USR-001" PASS "$T2" old.md
record "$d" "artifact: USR-001" "REQUEST CHANGES" "$T3" new.md
check "newer non-passing record beats an older PASS" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 13b. THE SIBLING HOLE: older REQUEST CHANGES + newer PASS -> refuse. Selecting only the
#      newest record hid a sibling rejection behind a later PASS, the same class merge-gate
#      closed. EVERY record covering the id must approve, not just the freshest.
d="$(make_repo)"; story "$d" USR-001-login "$T1"; record "$d" "artifact: USR-001" "REQUEST CHANGES" "$T2" old.md
record "$d" "artifact: USR-001" PASS "$T3" new.md
check "an older sibling REQUEST CHANGES is not hidden by a newer PASS" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 13c. the tier floor holds per-record too: newest PASS is strong, an older sibling PASS ran
#      on a fast tier with no waiver -> refuse. A fast-tier judgment must not ride in behind
#      a strong newest.
d="$(make_repo)"; story "$d" USR-001-login "$T1"
record "$d" "artifact: USR-001" PASS "$T2" old.md "body" "model_tier: fast"
record "$d" "artifact: USR-001" PASS "$T3" new.md "body" "model_tier: strong"
check "a fast-tier sibling is not hidden by a newer strong PASS" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 13d. two clean records, both PASS, both strong -> pass. The loop must not refuse on record
#      COUNT: when every sibling genuinely approves and clears the tier floor, the gate passes.
d="$(make_repo)"; story "$d" USR-001-login "$T1"; record "$d" "artifact: USR-001" PASS "$T2" old.md
record "$d" "artifact: USR-001" PASS "$T3" new.md
check "two clean passing records still pass" 0 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 14. LEFT token boundary: XUSR-001 must not cover USR-001
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: XUSR-001" PASS "$T3"
check "refuses XUSR-001 record for USR-001 (left boundary)" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 15. covers: in the BODY only (e.g. a History quote) must not count
d="$(make_repo)"; story "$d" USR-001-login "$T2"
record "$d" "artifact: OTHER-9" PASS "$T3" rec.md "history says: covers: USR-001"
check "ignores covers: lines in the record body" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 16. record with NO verdict in frontmatter -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"
( cd "$d" && printf -- '---\nartifact: USR-001\n---\nverdict: PASS\n' > docs/evals/rec.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses record without a frontmatter verdict" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 17. RES ids work like the others
d="$(make_repo)"
( cd "$d" && mkdir -p docs/research && printf 'res\n' > docs/research/RES-002-market.md && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" res
record "$d" "artifact: RES-002" PASS "$T3"
check "passes a fresh PASS RES record" 0 "$d" docs/research/RES-002-market.md; rm -rf "$d"

# 18. GITIGNORED artifact (never committed) must refuse, not pass vacuously
d="$(make_repo)"
( cd "$d" && echo "docs/stories/USR-009-*" > .gitignore && git add .gitignore ) >/dev/null 2>&1; commit_at "$d" "$T1" gitignore
( cd "$d" && printf 'ghost story\n' > docs/stories/USR-009-ghost.md ) >/dev/null 2>&1
record "$d" "artifact: USR-009" PASS "$T3"
check "refuses a gitignored, never-committed artifact" 1 "$d" docs/stories/USR-009-ghost.md; rm -rf "$d"

# 19. symlink artifact -> refuse (target can drift after review)
d="$(make_repo)"; story "$d" USR-001-login "$T2"; record "$d" "artifact: USR-001" PASS "$T3"
( cd "$d" && ln -s "$(pwd)/docs/stories/USR-001-login.md" docs/stories/USR-001-link.md )
check "refuses a symlink artifact" 2 "$d" docs/stories/USR-001-link.md; rm -rf "$d"

# 20. FAST-tier judgment record -> refuse; with waiver -> pass
d="$(make_repo)"; story "$d" USR-001-login "$T2"
record "$d" "artifact: USR-001" PASS "$T3" rec.md body "model_tier: fast"
check "refuses fast-tier PM record" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

d="$(make_repo)"; story "$d" USR-001-login "$T2"
record "$d" "artifact: USR-001" PASS "$T3" rec.md body "model_tier: fast
model_waiver: human"
check "passes fast tier with human waiver" 0 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 21. record without model_tier -> refuse
d="$(make_repo)"; story "$d" USR-001-login "$T2"
( cd "$d" && printf -- '---\nartifact: USR-001\nverdict: PASS\n---\nbody\n' > docs/evals/rec.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses PM record without model_tier" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

# 22. unknown tier vocabulary -> refuse (allowlist)
d="$(make_repo)"; story "$d" USR-001-login "$T2"
record "$d" "artifact: USR-001" PASS "$T3" rec.md body "model_tier: flash"
check "refuses unknown tier vocabulary" 1 "$d" docs/stories/USR-001-login.md; rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
