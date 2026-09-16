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

# 16) THE REAL TREE, against the REAL lists. Every case above uses hermetic fixtures, which
#     is right for the guard's logic and is exactly why nothing here noticed a new root file
#     classified nowhere. Measured: install.ps1 shipped unclassified, and publish-snapshot.sh
#     deletes the snapshot when this check exits 1, so the Windows entry point would have
#     reached no user and taken the whole release with it.
#     A path may be public or internal; what it may not be is UNSTATED. So this asserts only
#     that. Internal BLOCK lines are expected (the working tree holds .claude/, docs/evals/)
#     and are not what is counted here.
#     The fixture lists exported at the top of this file are UNSET for this case: with them
#     in scope the guard reads the hermetic four-line allowlist and calls most of the repo
#     unclassified, which looks like the very defect this case exists to find.
#     The tree is written to a FILE and its size asserted before the guard reads it. Piping
#     `git ls-tree` straight in hides the pipeline's exit status inside a command
#     substitution, and on an EMPTY feed the guard prints "clean (0 files checked)" and exits
#     0: a failing git and a spotless repo would have been the same green line. Measured.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tree_list="$TMP/real-tree.nul"
  if ! git -C "$REPO_ROOT" ls-tree -r -z --name-only HEAD > "$tree_list" 2>/dev/null; then
    echo "FAIL: could not list the tracked tree, so the classification case did not run"; fail=1
  fi
  n_paths=$(tr -cd '\0' < "$tree_list" | wc -c | tr -d ' ')
  if [ "${n_paths:-0}" -ge 50 ]; then
    echo "ok: the real tree feeds $n_paths tracked paths into the guard"
  else
    echo "FAIL: only ${n_paths:-0} tracked paths reached the guard; this repo has hundreds, so"
    echo "       the classification case below would pass on an empty read"
    fail=1
  fi
  real_out="$( cd "$REPO_ROOT" && env -u CLAUDE_INTERNAL_PATHS -u CLAUDE_PUBLIC_PATHS "$SCRIPT" --require-allowlist - < "$tree_list" 2>&1 )"
  unclassified="$(printf '%s\n' "$real_out" | grep 'unclassified path' || true)"
  if [ -z "$unclassified" ]; then
    echo "ok: every tracked path in the real tree is classified public or internal"
  else
    echo "FAIL: tracked paths are in neither docs/public-paths.txt nor docs/internal-paths.txt:"
    printf '%s\n' "$unclassified" | sed 's/^/       /'
    echo "       (publish-snapshot.sh deletes the snapshot on this, so a release stops here)"
    fail=1
  fi
  #  The instrument must be able to SEE an unclassified path. Planted into the SAME FILE the
  #  case above reads, not through a different feed: a probe piped in separately proves the
  #  guard works on something, never that the tree it actually read was non-empty.
  cp "$tree_list" "$TMP/real-tree-plus-probe.nul"
  printf 'definitely/unclassified-probe.md\0' >> "$TMP/real-tree-plus-probe.nul"
  planted="$( cd "$REPO_ROOT" && env -u CLAUDE_INTERNAL_PATHS -u CLAUDE_PUBLIC_PATHS "$SCRIPT" --require-allowlist - < "$TMP/real-tree-plus-probe.nul" 2>&1 )"
  case "$planted" in
    *unclassified-probe*) echo "ok: and the same read reports a planted unclassified path" ;;
    *) echo "FAIL: the real-tree check cannot detect an unclassified path at all"; fail=1 ;;
  esac
else
  echo "FAIL: not inside a git work tree, so the real-tree classification case could not run"
  fail=1
fi

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
