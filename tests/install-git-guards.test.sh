#!/usr/bin/env bash
# Tests for scripts/install-git-guards.sh: it installs the pre-commit secret scan into a
# user's project and NO pre-push hook (PRD-002 R4, USR-009). The repo-only installer that
# keeps this repository's pre-push guard is tested by
# .claude/maintainer/tests/install-git-guards.test.sh; where the pre-commit hook finds its
# scanner is tested by tests/git-guards.plugin.test.sh.
#
# Mutation recipe (the mutant must go RED, then restore):
#   M1 put the pre-push writer back into scripts/install-git-guards.sh   -> 4 FAIL
#      (copy the pre-push block of .claude/maintainer/install-git-guards.sh)
set -uo pipefail
INSTALLER="$(cd "$(dirname "$0")/.." && pwd)/scripts/install-git-guards.sh"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

repo="$TMP/repo"; git init -q "$repo"
out="$( cd "$repo" && bash "$INSTALLER" 2>&1 )"; rc=$?
assert_exit "installs into a git repo" 0 "$rc"
[ -x "$repo/.git/hooks/pre-commit" ] && ok "pre-commit installed +x" || bad "pre-commit not installed +x"
[ ! -e "$repo/.git/hooks/pre-push" ] && ok "no pre-push hook is written" || bad "a pre-push hook was written"
assert_contains "the summary names only the secret scan" "pre-commit (secret scan) installed" "$out"
case "$out" in *pre-push*) bad "the summary still mentions pre-push";; *) ok "the summary does not mention pre-push";; esac

# a project that carries docs/internal-paths.txt gets no push guard either, and no mark
pub="$TMP/pub"; git init -q "$pub"; mkdir -p "$pub/docs"; printf 'docs/plans/\n' > "$pub/docs/internal-paths.txt"
( cd "$pub" && bash "$INSTALLER" ) >/dev/null 2>&1
[ ! -e "$pub/.git/hooks/pre-push" ] && ok "a publishing-shaped project gets no pre-push hook" || bad "a pre-push hook was written for a publishing-shaped project"
[ -z "$(git -C "$pub" config --get odeo.publishesSnapshot)" ] && ok "no publishesSnapshot mark is written" || bad "a publishesSnapshot mark was written"

# a pre-push hook a user already has is left alone
mine="$TMP/mine"; git init -q "$mine"; printf '#!/bin/sh\necho mine\n' > "$mine/.git/hooks/pre-push"
( cd "$mine" && bash "$INSTALLER" ) >/dev/null 2>&1
assert_contains "an existing pre-push hook is not touched" "echo mine" "$(cat "$mine/.git/hooks/pre-push")"

# outside a git repo: exit 2
rc="$( cd "$TMP" && GIT_CEILING_DIRECTORIES="$TMP" bash "$INSTALLER" >/dev/null 2>&1; echo $? )"
assert_exit "not a git repo -> 2" 2 "$rc"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
