#!/usr/bin/env bash
# Tests for bin/merge-gate.sh, the /merge deterministic gate.
# Covers: branch guard, dirty tree, record existence by EXACT branch field,
# record freshness (newer than last code commit), and verdict check.
# Run: bash tests/merge-gate.test.sh
set -uo pipefail
# Fake, throwaway git identity for the temp repos these tests build. Not a real
# address (example.com is reserved, RFC 2606); never committed to a real repo or
# pushed. Makes fixture commits work regardless of the runner's git config (CI has
# none), so a missing ambient identity cannot masquerade as a gate failure.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$TEST_DIR/../bin/merge-gate.sh"
pass=0; fail=0

T1='2026-01-01T10:00:00'; T2='2026-01-01T11:00:00'; T3='2026-01-01T12:00:00'
commit_at() { # commit_at <repo> <time> <msg>
  ( cd "$1" && GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -qm "$3" ) >/dev/null 2>&1
}
make_repo() { local d; d="$(mktemp -d)"; ( cd "$d" && git init -q -b main && echo a > a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T1" init; echo "$d"; }
record() { # record <repo> <branch-field> <frontmatter-verdict> [body] [tier-lines]
  local body="${4:-## Verdict
$3}" tier="${5:-model_tier: strong}"
  ( cd "$1" && mkdir -p docs/evals && printf -- '---\nartifact: code\nbranch: %s\nverdict: %s\n%s\n---\n%s\n' "$2" "$3" "$tier" "$body" > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
}
record_no_verdict() { # record_no_verdict <repo> <branch-field>
  ( cd "$1" && mkdir -p docs/evals && printf -- '---\nartifact: code\nbranch: %s\n---\n## Verdict\nAPPROVE\n' "$2" > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
}
check() { local name="$1" want="$2" repo="$3"; ( cd "$repo" && bash "$GATE" ) >/dev/null 2>&1; local rc=$?
  if [[ $rc -eq $want ]]; then echo "ok   - $name"; pass=$((pass+1)); else echo "FAIL - $name (rc=$rc want=$want)"; fail=$((fail+1)); fi; }

# 1. On main -> refuse
d="$(make_repo)"; check "refuses on main" 1 "$d"; rm -rf "$d"

# 2. Branch, no record at all -> refuse
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
check "refuses without any record" 1 "$d"; rm -rf "$d"

# 3. Record exists but for a DIFFERENT branch -> refuse (exact branch-field match)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/OTHER" "APPROVE"; commit_at "$d" "$T3" rec
check "refuses record for another branch" 1 "$d"; rm -rf "$d"

# 4. Fresh matching record with APPROVE -> pass
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE"; commit_at "$d" "$T3" rec
check "passes: matching + fresh + approved" 0 "$d"; rm -rf "$d"

# 5. STALE record (code committed AFTER the review) -> refuse
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x ) >/dev/null 2>&1
record "$d" "feature/x" "APPROVE"; commit_at "$d" "$T2" rec
( cd "$d" && echo newer >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T3" code-after-review
check "refuses stale record (code changed after review)" 1 "$d"; rm -rf "$d"

# 6. Matching + fresh record but verdict REQUEST CHANGES -> refuse
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "REQUEST CHANGES"; commit_at "$d" "$T3" rec
check "refuses REQUEST CHANGES verdict" 1 "$d"; rm -rf "$d"

# 6b. Frontmatter APPROVE but body honestly documents a RESOLVED "REQUEST CHANGES"
#     history -> must PASS (the gate reads ONLY the frontmatter verdict; scrubbing
#     reviewer prose to satisfy a grep must never be necessary again)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" '## Verdict
APPROVE (was REQUEST CHANGES in v1; all findings resolved)
## History
v1 verdict: REQUEST CHANGES — register endpoint unthrottled. Fixed in a1b2c3.'
commit_at "$d" "$T3" rec
check "passes: APPROVE frontmatter with resolved REQUEST-CHANGES history in body" 0 "$d"; rm -rf "$d"

# 6c. Record with NO verdict field in frontmatter -> refuse (deny by default)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record_no_verdict "$d" "feature/x"; commit_at "$d" "$T3" rec
check "refuses record without a frontmatter verdict field" 1 "$d"; rm -rf "$d"

# 6d. APPROVE WITH COMMENTS in frontmatter -> pass (non-blocking approval)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE WITH COMMENTS"; commit_at "$d" "$T3" rec
check "passes APPROVE WITH COMMENTS" 0 "$d"; rm -rf "$d"

# 6e. PASS verdict (pm-reviewer style) in frontmatter -> pass
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "PASS"; commit_at "$d" "$T3" rec
check "passes PASS verdict" 0 "$d"; rm -rf "$d"

# 6f. Non-vocabulary verdict values must NOT pass on prefix (regression:
#     "APPROVE-PENDING-FIXES" and "PASSABLE BUT BROKEN" once matched APPROVE*/PASS*)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE-PENDING-FIXES"; commit_at "$d" "$T3" rec
check "refuses APPROVE-PENDING-FIXES (prefix is not approval)" 1 "$d"; rm -rf "$d"

d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "PASSABLE BUT BROKEN"; commit_at "$d" "$T3" rec
check "refuses PASSABLE BUT BROKEN" 1 "$d"; rm -rf "$d"

# 6g. Frontmatter must OPEN the file (regression: a body-only record with a
#     setext heading '---' and a loose 'verdict: APPROVE' line passed the parse)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- 'Review Title\n---\nbranch: feature/x\nverdict: APPROVE\n' > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses record whose '---' is a setext heading, not frontmatter" 1 "$d"; rm -rf "$d"

# 6h. Verdict line with a trailing comment -> refuse (the contract is value-only;
#     fail closed rather than guess what the comment means)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE  # but actually pending"; commit_at "$d" "$T3" rec
check "refuses verdict with trailing comment (value-only contract)" 1 "$d"; rm -rf "$d"

# 6i. Judgment record on a FAST tier -> refuse (quality floor)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: fast"; commit_at "$d" "$T3" rec
check "refuses fast-tier judgment record" 1 "$d"; rm -rf "$d"

# 6j. FAST tier WITH explicit human waiver -> pass (loud override)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: fast
model_waiver: human"; commit_at "$d" "$T3" rec
check "passes fast tier with model_waiver: human" 0 "$d"; rm -rf "$d"

# 6k. Record WITHOUT model_tier -> refuse (deny by default; re-run reviewer)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: code\nbranch: feature/x\nverdict: APPROVE\n---\nbody\n' > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses record without model_tier" 1 "$d"; rm -rf "$d"

# 6l. UNKNOWN tier vocabulary -> refuse (allowlist, not blocklist)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: banana"; commit_at "$d" "$T3" rec
check "refuses unknown model_tier vocabulary" 1 "$d"; rm -rf "$d"

d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: fast (haiku)"; commit_at "$d" "$T3" rec
check "refuses annotated tier value" 1 "$d"; rm -rf "$d"

d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: haiku"; commit_at "$d" "$T3" rec
check "refuses vendor word as tier (haiku)" 1 "$d"; rm -rf "$d"

# 6m. Casing tolerance: FAST + HUMAN waiver passes (normalization pinned)
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE" "" "model_tier: FAST
model_waiver: HUMAN"; commit_at "$d" "$T3" rec
check "passes FAST tier with HUMAN waiver (case-folded)" 0 "$d"; rm -rf "$d"

# 7. Dirty working tree -> refuse
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T2" code
record "$d" "feature/x" "APPROVE"; commit_at "$d" "$T3" rec
( cd "$d" && echo dirty >> a.txt ) >/dev/null 2>&1
check "refuses dirty working tree" 1 "$d"; rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
