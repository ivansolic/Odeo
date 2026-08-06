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
# Fixtures carry a well-formed PRE-CUTOFF date by default, so cases that are not about
# the reviewed_commit cutoff keep testing exactly what they claim. The gate refuses a
# record with no `date:` (a missing date must never exempt one from the anchor), so the
# date is part of a minimal valid record, not decoration.
PRE_CUTOFF_DATE='2026-07-21'
record() { # record <repo> <branch-field> <frontmatter-verdict> [body] [tier-lines]
  local body="${4:-## Verdict
$3}" tier="${5:-model_tier: strong}"
  ( cd "$1" && mkdir -p docs/evals && printf -- '---\nartifact: code\nbranch: %s\ndate: %s\nverdict: %s\n%s\n---\n%s\n' "$2" "$PRE_CUTOFF_DATE" "$3" "$tier" "$body" > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
}
record_no_verdict() { # record_no_verdict <repo> <branch-field>
  ( cd "$1" && mkdir -p docs/evals && printf -- '---\nartifact: code\nbranch: %s\ndate: %s\n---\n## Verdict\nAPPROVE\n' "$2" "$PRE_CUTOFF_DATE" > docs/evals/code-review.md && git add -A ) >/dev/null 2>&1
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

# --- EVERY matching record must approve (a PASS must not mask a sibling refusal) ---
# named_record <repo> <filename> <branch-field> <verdict> [extra-frontmatter-lines]
# Supplies a pre-cutoff `date:` ONLY when the caller did not pass its own, so cases that
# exercise the cutoff control their own date and cases that do not stay valid records.
named_record() {
  local extra="${5:-}" datel=""
  case "$extra" in *date:*) : ;; *) datel="date: $PRE_CUTOFF_DATE" ;; esac
  ( cd "$1" && mkdir -p docs/evals \
    && printf -- '---\nartifact: x\nbranch: %s\n%s\nverdict: %s\nmodel_tier: strong\n%s\n---\n## Verdict\n%s\n' \
       "$3" "$datel" "$4" "$extra" "$4" > "docs/evals/$2" && git add -A ) >/dev/null 2>&1
}

# 8. Two matching records, one APPROVE and one REQUEST CHANGES -> refuse.
#    The refuser sorts LAST alphabetically, so a "first/newest wins" gate would pass it.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
named_record "$d" "z-refuse.md"  "feature/x" "REQUEST CHANGES"
commit_at "$d" "$T3" recs
check "refuses when ANY matching record does not approve (refuser last)" 1 "$d"; rm -rf "$d"

# 9. Same, refuser sorting FIRST, so neither ordering can hide it.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-refuse.md"  "feature/x" "REQUEST CHANGES"
named_record "$d" "z-approve.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" recs
check "refuses when ANY matching record does not approve (refuser first)" 1 "$d"; rm -rf "$d"

# 10. Two matching records, both approving -> pass (must not over-refuse).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
named_record "$d" "z-pass.md"    "feature/x" "PASS"
commit_at "$d" "$T3" recs
check "passes when EVERY matching record approves" 0 "$d"; rm -rf "$d"

# 11. A refusing record for ANOTHER branch must not be pulled in.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "mine.md"  "feature/x"     "APPROVE"
named_record "$d" "other.md" "feature/other" "REQUEST CHANGES"
commit_at "$d" "$T3" recs
check "ignores a refusing record naming a different branch" 0 "$d"; rm -rf "$d"

# 12. A SECOND record missing model_tier -> refuse (every record is checked).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: x\nbranch: feature/x\nverdict: APPROVE\n---\nbody\n' > docs/evals/z-notier.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses when a SECOND record lacks model_tier" 1 "$d"; rm -rf "$d"

# --- reviewed_commit: the review must describe the code being merged ---
# Required only on records dated on/after the cutoff, so older records stay valid
# without a hand migration.

# 13. Post-cutoff record whose reviewed_commit is the code being merged -> pass.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $sha"
commit_at "$d" "$T3" rec
check "passes when reviewed_commit matches the merged code" 0 "$d"; rm -rf "$d"

# 14. Post-cutoff record with NO reviewed_commit -> refuse.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05"
commit_at "$d" "$T3" rec
check "refuses a post-cutoff record with no reviewed_commit" 1 "$d"; rm -rf "$d"

# 15. Pre-cutoff record with no reviewed_commit -> pass (no migration needed).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-07-21"
commit_at "$d" "$T3" rec
check "exempts a pre-cutoff record from reviewed_commit" 0 "$d"; rm -rf "$d"

# 16. Code changed AFTER the reviewed_commit -> refuse. This is the hole timestamps
#     cannot see: the record is newer than the code but reviewed an earlier state.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
( cd "$d" && echo c >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T3" more-code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $sha"
commit_at "$d" "$T3" rec
check "refuses when code changed after reviewed_commit" 1 "$d"; rm -rf "$d"

# 17. An evals-only commit after reviewed_commit must NOT count as a code change.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $sha"
commit_at "$d" "$T3" rec-only
check "an evals-only commit does not invalidate reviewed_commit" 0 "$d"; rm -rf "$d"

# 18. Unresolvable reviewed_commit sha -> refuse (deny by default).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
commit_at "$d" "$T3" rec
check "refuses an unresolvable reviewed_commit" 1 "$d"; rm -rf "$d"

# 18b. ...and it must refuse because the SHA does not resolve, not because git diff
#      happened to error. Without asserting the message this case passed even with the
#      whole rev-parse block deleted.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
commit_at "$d" "$T3" rec
out="$( cd "$d" && bash "$GATE" 2>&1 )"
case "$out" in
  *"is not a commit in this repo"*) echo "ok   - names the unresolvable sha as the reason"; pass=$((pass+1)) ;;
  *) echo "FAIL - names the unresolvable sha as the reason (got: $(printf '%s' "$out" | grep -m1 REFUSED))"; fail=$((fail+1)) ;;
esac
rm -rf "$d"

# --- the cutoff must be fail-closed: no date and no malformed date may EXEMPT ---
# Each of these carries a VALID reviewed_commit where noted, so the refusal must come
# from the date handling itself and not merely from a missing anchor.

# 19. No `date:` at all -> refuse. Otherwise omitting one field bypasses the anchor.
#     Written directly, since named_record now supplies a date when the caller omits one.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: x\nbranch: feature/x\nverdict: APPROVE\nmodel_tier: strong\n---\nbody\n' > docs/evals/r.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses a record with no date: field" 1 "$d"; rm -rf "$d"

# 20. Malformed date in a form that sorts BEFORE the cutoff (DD-MM-YYYY) -> refuse.
#     A valid anchor is present, so only the malformed date can cause the refusal.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 05-08-2026
reviewed_commit: $sha"
commit_at "$d" "$T3" rec
check "refuses a malformed date that would sort pre-cutoff" 1 "$d"; rm -rf "$d"

# 21. Malformed date with single-digit parts, valid anchor -> refuse on the format.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-8-5
reviewed_commit: $sha"
commit_at "$d" "$T3" rec
check "refuses a malformed date (single-digit month/day)" 1 "$d"; rm -rf "$d"

# 22. Non-date junk -> refuse.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
sha="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: today
reviewed_commit: $sha"
commit_at "$d" "$T3" rec
check "refuses a non-date value in date:" 1 "$d"; rm -rf "$d"

# 23. Regression guard: a WELL-FORMED pre-cutoff date is still exempt (no over-refusal).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-07-21"
commit_at "$d" "$T3" rec
check "still exempts a well-formed pre-cutoff date" 0 "$d"; rm -rf "$d"

# --- enumeration must not depend on line endings, regex, or body text ---

# 24. A CRLF record that REFUSES must still be seen. With a grep `$` anchor its
#     `branch:` line ends in \r, so on system grep the record is invisible and the
#     sibling APPROVE carries the gate. Enumeration must read frontmatter, not regex.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\r\nartifact: x\r\nbranch: feature/x\r\ndate: 2026-07-21\r\nverdict: REQUEST CHANGES\r\nmodel_tier: strong\r\n---\r\nbody\r\n' > docs/evals/z-refuse.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "sees a CRLF record that refuses" 1 "$d"; rm -rf "$d"

# 25. A CRLF record alone that APPROVES must still be FOUND (not "no record"), so the
#     fix cannot pass case 24 by making CRLF records merely unreadable.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\r\nartifact: x\r\nbranch: feature/x\r\ndate: 2026-07-21\r\nverdict: APPROVE\r\nmodel_tier: strong\r\n---\r\nbody\r\n' > docs/evals/only.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "accepts a CRLF record that approves" 0 "$d"; rm -rf "$d"

# 26. The branch name must be compared as a STRING, not a regex. On branch fix/a.b a
#     record naming fix/aXb must NOT satisfy the gate.
d="$(make_repo)"; ( cd "$d" && git checkout -qb fix/a.b && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "fix/aXb" "APPROVE"
commit_at "$d" "$T3" rec
check "does not treat the branch name as a regex" 1 "$d"; rm -rf "$d"

# 27. A `branch:` line in the BODY must not enrol a record (frontmatter only).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "mine.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: x\nbranch: feature/other\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nbranch: feature/x\n' > docs/evals/body.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "ignores a branch: line in the body" 0 "$d"; rm -rf "$d"

# --- the anchor must name an immutable commit ---

# 28. `reviewed_commit: HEAD` -> refuse. A moving ref can never go stale, and it is the
#     likeliest wrong value since reviewers are told to run `git rev-parse --short HEAD`.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: HEAD"
commit_at "$d" "$T3" rec
check "refuses a symbolic reviewed_commit (HEAD)" 1 "$d"; rm -rf "$d"

# 29. A branch NAME as the anchor -> refuse (same reason).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: feature/x"
commit_at "$d" "$T3" rec
check "refuses a branch name as reviewed_commit" 1 "$d"; rm -rf "$d"

# 30. A TREE sha (valid object, not a commit) -> refuse. Guards the ^{commit} peel,
#     which a plain --verify does not enforce.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
tree="$( cd "$d" && git rev-parse HEAD^{tree} )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $tree"
commit_at "$d" "$T3" rec
check "refuses a tree sha as reviewed_commit" 1 "$d"; rm -rf "$d"

# 31. A commit that is NOT an ancestor of HEAD -> refuse (a review of another line).
d="$(make_repo)"; ( cd "$d" && git checkout -qb other && echo o > o.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" sidecommit
side="$( cd "$d" && git rev-parse HEAD )"
( cd "$d" && git checkout -q main && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $side"
commit_at "$d" "$T3" rec
check "refuses a reviewed_commit that is not an ancestor of HEAD" 1 "$d"; rm -rf "$d"

# --- per-record coverage of the anchor, and duplicate fields ---

# 32. A SECOND record's stale anchor must be caught (the first one is fine).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
old="$( cd "$d" && git rev-parse HEAD )"
( cd "$d" && echo c >> a.txt && git add -A ) >/dev/null 2>&1; commit_at "$d" "$T3" more
new="$( cd "$d" && git rev-parse HEAD )"
named_record "$d" "a-ok.md"   "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $new"
named_record "$d" "z-stale.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $old"
commit_at "$d" "$T3" recs
check "catches a stale anchor on a SECOND record" 1 "$d"; rm -rf "$d"

# 33. Two `verdict:` lines -> refuse, whichever order (an approval must not shadow one).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: x\nbranch: feature/x\ndate: 2026-07-21\nverdict: APPROVE\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/r.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses two verdict: lines (approval first)" 1 "$d"; rm -rf "$d"

# 34. Cutoff pinned from BELOW too: the day before the cutoff stays exempt.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-04"
commit_at "$d" "$T3" rec
check "exempts the day before the cutoff" 0 "$d"; rm -rf "$d"

# --- a record the parser cannot read must REFUSE, never be skipped ---
# Enumerating by frontmatter fixed the CRLF/regex/body holes but introduced a worse one:
# an unparseable record simply did not enrol, so its refusal became invisible behind a
# sibling APPROVE. The old grep-based gate refused these. Each case pairs a malformed
# REFUSAL with a valid APPROVE, so only a fail-closed tripwire can catch it.

# 35. Frontmatter does not OPEN the file (title line above ---), carrying a refusal.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- 'Review Title\n---\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z-malformed.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses an unparseable record that names the branch" 1 "$d"; rm -rf "$d"

# 36. Two `branch:` lines, decoy first, so frontmatter_field reads the wrong one.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/decoy\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z-two-branch.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses a record with two branch: lines" 1 "$d"; rm -rf "$d"

# 37. Two `date:` lines, pre-cutoff first, would skip the anchor entirely.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\ndate: 2026-08-05\nverdict: APPROVE\nmodel_tier: strong\n---\nb\n' > docs/evals/r.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses two date: lines" 1 "$d"; rm -rf "$d"

# 38. Two `model_tier:` lines, strong first, would bypass the fast-tier floor.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: APPROVE\nmodel_tier: strong\nmodel_tier: fast\n---\nb\n' > docs/evals/r.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "refuses two model_tier: lines" 1 "$d"; rm -rf "$d"

# 39. A SYMLINKED record must not be invisible (`find -type f` alone misses it).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals real && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > real/r.md && ln -s ../../real/r.md docs/evals/z-link.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "sees a symlinked record that refuses" 1 "$d"; rm -rf "$d"

# 40. Non-ancestor with an IDENTICAL tree, so only the ancestor check can refuse it.
#     Case 31's fixture differed in content, so deleting merge-base left the suite green.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && git branch side && git checkout -q side && GIT_AUTHOR_DATE="$T2" GIT_COMMITTER_DATE="$T2" git commit -q --amend -m amended-same-tree && git checkout -q feature/x ) >/dev/null 2>&1
side="$( cd "$d" && git rev-parse side )"
named_record "$d" "r.md" "feature/x" "APPROVE" "date: 2026-08-05
reviewed_commit: $side"
commit_at "$d" "$T3" rec
check "refuses a non-ancestor even with an identical tree" 1 "$d"; rm -rf "$d"

# 41. The branch comparison must be EQUALITY, not substring: on branch `feature/x` a
#     record naming `feature/xyz` must not enrol (guards `==` becoming a glob match).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/xyz" "APPROVE"
commit_at "$d" "$T3" rec
check "does not enrol a superstring branch name" 1 "$d"; rm -rf "$d"

# 42. The success line must name the records it checked (it once printed an empty
#     variable left behind by the loop's final EOF read).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
named_record "$d" "z-pass.md"    "feature/x" "PASS"
commit_at "$d" "$T3" recs
out="$( cd "$d" && bash "$GATE" 2>&1 )"
case "$out" in
  *"2 record(s) checked"*a-approve.md*z-pass.md*) echo "ok   - success line names every record checked"; pass=$((pass+1)) ;;
  *) echo "FAIL - success line names every record checked (got: $(printf '%s' "$out" | tail -1))"; fail=$((fail+1)) ;;
esac
rm -rf "$d"

# --- the tripwire must not depend on how the branch line is spelled ---
# Matching the literal LINE let internal whitespace and case evade it, which brought the
# v2 Critical straight back. The tripwire now fires on "frontmatter does not parse",
# which is independent of spacing, case, and whether a branch line is present at all.

# 43. Two spaces after `branch:` in a malformed record + a sibling APPROVE -> refuse.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- 'Title\n---\nbranch:  feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses a malformed record with padded branch value" 1 "$d"; rm -rf "$d"

# 44. A TAB instead of a space -> refuse.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- 'Title\n---\nbranch:\tfeature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses a malformed record with a tab before the value" 1 "$d"; rm -rf "$d"

# 45. UPPERCASE branch value in a malformed record -> refuse (pins the case handling).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- 'Title\n---\nbranch: FEATURE/X\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "refuses a malformed record with an uppercase branch value" 1 "$d"; rm -rf "$d"

# 46. A NON-.md refusing record must not be masked by a name filter. The old grep gate
#     had no filter and refused this; a filter on the tripwire scan would fail open.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z-refuse.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "sees a non-.md record that refuses" 1 "$d"; rm -rf "$d"

# 47. A record that PARSES but merely lacks a branch field must NOT trip the wire, even
#     when it quotes an exact branch line in its body (PM and design records have no
#     branch field, so they are exactly what reaches this path).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "mine.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nartifact: PRD-007\ndate: 2026-07-21\nverdict: PASS\nmodel_tier: strong\n---\nExample frontmatter:\n```\nbranch: feature/x\n```\n' > docs/evals/prd.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "does not trip on a branchless record quoting a branch line" 0 "$d"; rm -rf "$d"

# --- untracked junk under docs/evals must not block a merge ---
# `find` walks the filesystem, so a gitignored file is invisible to the clean-tree check
# but visible to the tripwire, and every merge is blocked. .DS_Store is the real instance:
# Finder creates it in any folder a human opens. Enumerating tracked files excludes junk
# by construction, and keeps symlinks and non-.md records, which a name filter would not.

# 48. A gitignored .DS_Store in docs/evals must NOT block the merge.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE"
( cd "$d" && printf '.DS_Store\n' > .gitignore && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
( cd "$d" && printf 'binary junk' > docs/evals/.DS_Store ) >/dev/null 2>&1
check "ignores gitignored junk under docs/evals" 0 "$d"; rm -rf "$d"

# 49. An UNTRACKED unparseable file is caught by the clean-tree check instead, so nothing
#     is lost: it still refuses, just with the accurate reason.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && printf 'not a record\n' > docs/evals/stray.md ) >/dev/null 2>&1
check "refuses an untracked stray file (via the clean-tree check)" 1 "$d"; rm -rf "$d"

# 50. A TRACKED unparseable record still refuses (the guarantee must survive the change).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-approve.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf 'Title\n---\nbranch: feature/x\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nb\n' > docs/evals/z.md && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
check "still refuses a TRACKED unparseable record" 1 "$d"; rm -rf "$d"

# --- an untracked record must never be invisible, whatever git is configured to report ---
# Enumerating tracked files was justified by "an untracked file is refused by the clean-tree
# check". That holds only under git's DEFAULT untracked reporting. With
# status.showUntrackedFiles=no the clean-tree check goes blind too, and an untracked
# REQUEST CHANGES record became completely invisible: a fail-OPEN regression against the
# previous `find` version, which refused it.

# 51. Untracked refusing record + status.showUntrackedFiles=no -> still refuse.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "code-x.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && git config status.showUntrackedFiles no && mkdir -p docs/evals \
  && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nx\n' > docs/evals/design-x.md ) >/dev/null 2>&1
check "refuses an untracked record even with showUntrackedFiles=no" 1 "$d"; rm -rf "$d"

# 52. Same, but the untracked stray is unparseable junk rather than a record: still refuse,
#     so the reason cannot depend on being able to read it.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "code-x.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && git config status.showUntrackedFiles no && printf 'not a record\n' > docs/evals/stray.md ) >/dev/null 2>&1
check "refuses untracked junk even with showUntrackedFiles=no" 1 "$d"; rm -rf "$d"

# 53. A GITIGNORED file stays ignored even with the stray check in place (case 48 must not
#     regress into refusing .DS_Store again).
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE"
( cd "$d" && printf '.DS_Store\n' > .gitignore && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
( cd "$d" && git config status.showUntrackedFiles no && printf 'junk' > docs/evals/.DS_Store ) >/dev/null 2>&1
check "still ignores gitignored junk with showUntrackedFiles=no" 0 "$d"; rm -rf "$d"

# 54. A record with a non-ASCII filename must enumerate. `git ls-files` C-quotes such paths
#     when core.quotePath is on (the default), which made the gate refuse every merge.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: APPROVE\nmodel_tier: strong\n---\nx\n' > "docs/evals/code-café.md" && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" rec
check "enumerates a record with a non-ASCII filename" 0 "$d"; rm -rf "$d"

# 55. ...and a refusing one with a non-ASCII name must still refuse on its VERDICT, not be
#     mistaken for an unparseable file.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "a-ok.md" "feature/x" "APPROVE"
( cd "$d" && mkdir -p docs/evals && printf -- '---\nbranch: feature/x\ndate: 2026-07-21\nverdict: REQUEST CHANGES\nmodel_tier: strong\n---\nx\n' > "docs/evals/code-résumé.md" && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T3" recs
out="$( cd "$d" && bash "$GATE" 2>&1 )"
case "$out" in
  *"did not approve"*) echo "ok   - non-ASCII record refuses on its verdict"; pass=$((pass+1)) ;;
  *) echo "FAIL - non-ASCII record refuses on its verdict (got: $(printf '%s' "$out" | grep -m1 REFUSED))"; fail=$((fail+1)) ;;
esac
rm -rf "$d"

# 56. An untracked file OUTSIDE docs/evals, with showUntrackedFiles=no -> refuse.
#     This pins the CLI flag specifically. The stray check only sees docs/evals, so without
#     this case, reverting `--untracked-files=normal` left the suite green while UNCOMMITTED
#     CODE could merge. The two guards are redundant only inside docs/evals.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && git config status.showUntrackedFiles no && printf 'new code\n' > src-new.go ) >/dev/null 2>&1
check "refuses untracked code outside docs/evals (showUntrackedFiles=no)" 1 "$d"; rm -rf "$d"

# 57. The docs/evals stray check must produce its BY-NAME message, not the generic
#     clean-tree one, or the documented "refused explicitly, by name" is not observable.
d="$(make_repo)"; ( cd "$d" && git checkout -qb feature/x && echo b >> a.txt && git add -A ) >/dev/null 2>&1
commit_at "$d" "$T2" code
named_record "$d" "r.md" "feature/x" "APPROVE"
commit_at "$d" "$T3" rec
( cd "$d" && printf 'stray\n' > docs/evals/design-x.md ) >/dev/null 2>&1
out="$( cd "$d" && bash "$GATE" 2>&1 )"
case "$out" in
  *"untracked file(s) under docs/evals"*design-x.md*) echo "ok   - stray record refused by name"; pass=$((pass+1)) ;;
  *) echo "FAIL - stray record refused by name (got: $(printf '%s' "$out" | grep -m1 REFUSED))"; fail=$((fail+1)) ;;
esac
rm -rf "$d"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
