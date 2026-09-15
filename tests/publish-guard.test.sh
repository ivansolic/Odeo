#!/usr/bin/env bash
# Tests for bin/publish-guard.sh: deterministic guard against publishing internal artifacts.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/publish-guard.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Hermetic fixture lists (tests do not depend on the repo's real lists).
DENY="$TMP/deny.txt"; ALLOW="$TMP/allow.txt"
cat > "$DENY" <<'EOF'
# denylist fixture
.claude/
docs/evals/
docs/plans/
docs/prds/
docs/stories/
docs/research/
docs/checklists/dogfood-protocol.md
EOF
cat > "$ALLOW" <<'EOF'
# allowlist fixture
README.md
skills/
docs/checklists/review-calibration.md
docs/plans-summary.md
EOF
export CLAUDE_INTERNAL_PATHS="$DENY"
export CLAUDE_PUBLIC_PATHS="$ALLOW"

mkfile() { mkdir -p "$(dirname "$1")"; printf '%s' "${2:-x}" > "$1"; }

# 1) clean dir (only public files) -> exit 0, "clean"
d="$TMP/c1"; mkfile "$d/README.md"; mkfile "$d/skills/x/SKILL.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "clean dir -> 0" 0 "$rc"; assert_contains "says clean" "clean" "$out"

# 2) docs/plans/p.md (dir-prefix) -> exit 1, names it
d="$TMP/c2"; mkfile "$d/README.md"; mkfile "$d/docs/plans/p.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "docs/plans -> 1" 1 "$rc"; assert_contains "names plans" "docs/plans/p.md" "$out"

# 3) docs/evals/EVR-1.md -> exit 1
d="$TMP/c3"; mkfile "$d/docs/evals/EVR-1.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "docs/evals -> 1" 1 "$rc"; assert_contains "names evals" "docs/evals/EVR-1.md" "$out"

# 4) .claude/tasks/todo.md (covered by the .claude/ prefix) -> exit 1
d="$TMP/c4"; mkfile "$d/.claude/tasks/todo.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit ".claude/ prefix -> 1" 1 "$rc"; assert_contains "names claude tasks" ".claude/tasks/todo.md" "$out"

# 5) NEGATIVE: review-calibration.md present, no denylisted file -> exit 0
d="$TMP/c5"; mkfile "$d/docs/checklists/review-calibration.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "review-calibration not denied -> 0" 0 "$rc"

# 6) NEGATIVE: docs/plans-summary.md (NOT under docs/plans/) -> exit 0
d="$TMP/c6"; mkfile "$d/docs/plans-summary.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "plans-summary not matched by docs/plans/ -> 0" 0 "$rc"

# 6b) NON-ASCII denylisted name read via find -print0 must still match -> exit 1
d="$TMP/c6b"; mkdir -p "$d/docs/plans"; touch "$d/docs/plans/r$(printf '\303\251')sum.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "non-ascii name under docs/plans/ -> 1" 1 "$rc"

# 7) stdin NUL list mode (no dir) including docs/stories/s.md -> exit 1
out="$(printf 'docs/examples/e.md\0docs/stories/s.md\0' | "$SCRIPT" - 2>&1)"; rc=$?
assert_exit "stdin list denylisted -> 1" 1 "$rc"; assert_contains "names story" "docs/stories/s.md" "$out"

# 8) privacy ADVISORY: public README with a private datum, no denylisted file -> exit 3
d="$TMP/c8"; mkfile "$d/README.md" 'contact alice@corp.example and see /Users/alice/notes.txt'
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "privacy finding advisory -> 3" 3 "$rc"
# 8b) denylisted file PLUS a privacy finding -> exit 1 (denylist is the hard gate, wins)
mkfile "$d/docs/plans/p.md"
out="$("$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "denylist wins over privacy -> 1" 1 "$rc"

# 9) env override: lists come only from the pointed-at file
altdeny="$TMP/altdeny.txt"; printf 'docs/foo/\n' > "$altdeny"
d="$TMP/c9"; mkfile "$d/docs/foo/x.md"
out="$(CLAUDE_INTERNAL_PATHS="$altdeny" "$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "env-override denylist matches docs/foo -> 1" 1 "$rc"
d2="$TMP/c9b"; mkfile "$d2/docs/plans/p.md"
out="$(CLAUDE_INTERNAL_PATHS="$altdeny" "$SCRIPT" "$d2" 2>&1)"; rc=$?
assert_exit "real docs/plans NOT flagged under alt denylist -> 0" 0 "$rc"

# 10) usage: nonexistent dir -> exit 2; missing denylist -> exit 2
out="$("$SCRIPT" "$TMP/does-not-exist" 2>&1)"; rc=$?
assert_exit "nonexistent dir -> 2" 2 "$rc"
out="$(CLAUDE_INTERNAL_PATHS="$TMP/no-such-list.txt" "$SCRIPT" "$TMP/c1" 2>&1)"; rc=$?
assert_exit "missing denylist -> 2" 2 "$rc"

# 11) allowlist: --require-allowlist, dir fully covered -> exit 0
d="$TMP/c11"; mkfile "$d/README.md"; mkfile "$d/skills/x/SKILL.md"
out="$("$SCRIPT" --require-allowlist "$d" 2>&1)"; rc=$?
assert_exit "allowlist covers all -> 0" 0 "$rc"

# 12) allowlist catches the forgotten-internal-dir (v3 fail-closed) -> exit 1, unclassified
d="$TMP/c12"; mkfile "$d/README.md"; mkfile "$d/docs/postmortems/p.md"
out="$("$SCRIPT" --require-allowlist "$d" 2>&1)"; rc=$?
assert_exit "unclassified path -> 1" 1 "$rc"
assert_contains "names unclassified path" "docs/postmortems/p.md" "$out"
assert_contains "says unclassified" "unclassified" "$out"

# 13) precedence + opt-in
d="$TMP/c13"; mkfile "$d/docs/plans/p.md"; mkfile "$d/docs/postmortems/q.md"
out="$("$SCRIPT" --require-allowlist "$d" 2>&1)"; rc=$?
assert_exit "deny + unclassified -> 1" 1 "$rc"
d2="$TMP/c13b"; mkfile "$d2/docs/postmortems/q.md"
out="$("$SCRIPT" "$d2" 2>&1)"; rc=$?
assert_exit "no allowlist mode: unclassified path allowed -> 0" 0 "$rc"

# 14) Nit-1: a padded denylist entry must NOT go inert (whitespace is trimmed)
padded="$TMP/padded-deny.txt"; printf '   docs/plans/   \n' > "$padded"
d="$TMP/c14"; mkfile "$d/docs/plans/p.md"
out="$(CLAUDE_INTERNAL_PATHS="$padded" "$SCRIPT" "$d" 2>&1)"; rc=$?
assert_exit "padded denylist entry still matches -> 1" 1 "$rc"

# 15) Nit-2: --require-allowlist is honored even when it follows the dir arg
d="$TMP/c15"; mkfile "$d/README.md"; mkfile "$d/docs/postmortems/p.md"
out="$("$SCRIPT" "$d" --require-allowlist 2>&1)"; rc=$?
assert_exit "flag after dir still enforces allowlist -> 1" 1 "$rc"
assert_contains "names unclassified (flag-after-dir)" "docs/postmortems/p.md" "$out"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
