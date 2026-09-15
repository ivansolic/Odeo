#!/usr/bin/env bash
# Tests for bin/install-git-guards.sh: the installed pre-push hook, PUSH CONTRACT A.
set -uo pipefail
INSTALLER="$(cd "$(dirname "$0")/.." && pwd)/bin/install-git-guards.sh"
GUARD="$(cd "$(dirname "$0")/.." && pwd)/bin/publish-guard.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

# Throwaway git identity so fixture commits succeed with no global identity present.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
repo="$TMP/repo"; bare="$TMP/bare.git"
mkdir -p "$repo"
git init -q "$repo"
git init -q --bare "$bare"

# Fixture denylist used by the hook's defense-in-depth guard.
deny="$TMP/deny.txt"; printf 'docs/plans/\ndocs/evals/\n' > "$deny"
export CLAUDE_INTERNAL_PATHS="$deny"

# Make the guard findable from the repo (the hook looks for bin/publish-guard.sh).
mkdir -p "$repo/bin"; cp "$GUARD" "$repo/bin/publish-guard.sh"; chmod +x "$repo/bin/publish-guard.sh"

# Install the hooks into the repo under test.
( cd "$repo" && bash "$INSTALLER" ) >/dev/null 2>&1

# (a) pre-push installed and executable
[ -x "$repo/.git/hooks/pre-push" ] && { echo "ok: pre-push installed +x"; } || { echo "FAIL: pre-push not installed +x"; fail=1; }
# (b) the main/master refusal is preserved
assert_contains "main/master refusal preserved" "refs/heads/main" "$(cat "$repo/.git/hooks/pre-push")"

# Build a clean commit and a dirty (internal-path) commit.
( cd "$repo" && echo x > README.md && git add README.md && git commit -q -m c1 )
clean_sha="$(cd "$repo" && git rev-parse HEAD)"
( cd "$repo" && mkdir -p docs/plans && echo x > docs/plans/x.md && git add docs/plans/x.md && git commit -q -m c2 )
dirty_sha="$(cd "$repo" && git rev-parse HEAD)"
zero=0000000000000000000000000000000000000000

# helper: run the installed hook. $1=remote_name $2=marker("" or 1). stdin = ref lines.
hook() {
  local rn="$1" marker="$2"; shift 2
  ( cd "$repo" && env CLAUDE_INTERNAL_PATHS="$deny" ${marker:+CLAUDE_PUBLISH_SNAPSHOT=$marker} \
      .git/hooks/pre-push "$rn" "file://$bare" )
}

# (c) push a feature branch to public origin WITHOUT the marker -> REFUSED
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook origin "" 2>&1)"; rc=$?
assert_exit "public push, no marker -> refused" 1 "$rc"
assert_contains "explains publish-snapshot path" "publish-snapshot" "$out"

# (d) same WITH marker + clean tree -> allowed
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook origin 1 2>&1)"; rc=$?
assert_exit "public push, marker + clean tree -> allowed" 0 "$rc"

# (e) WITH marker but an internal path in the pushed tree -> REFUSED (defense-in-depth)
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$dirty_sha" "$zero" | hook origin 1 2>&1)"; rc=$?
assert_exit "public push, marker + internal path -> refused" 1 "$rc"

# (f) contract A covers every ref-shape: force-push (same ref line) and a tag, no marker -> both REFUSED
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$clean_sha" | hook origin "" 2>&1)"; rc=$?
assert_exit "force-push to public, no marker -> refused" 1 "$rc"
out="$(printf 'refs/tags/v1 %s refs/tags/v1 %s\n' "$clean_sha" "$zero" | hook origin "" 2>&1)"; rc=$?
assert_exit "tag push to public, no marker -> refused" 1 "$rc"

# (g) push to a NON-public remote is not subject to the public refusal -> allowed
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook backup "" 2>&1)"; rc=$?
assert_exit "push to non-public remote -> allowed" 0 "$rc"

# preserved (1): a direct push to main is still refused (on any remote)
out="$(printf 'refs/heads/main %s refs/heads/main %s\n' "$clean_sha" "$zero" | hook backup "" 2>&1)"; rc=$?
assert_exit "direct push to main -> refused" 1 "$rc"
assert_contains "main refusal message" "direct push to main" "$out"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
