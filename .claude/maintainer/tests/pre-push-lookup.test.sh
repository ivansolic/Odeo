#!/usr/bin/env bash
# The pre-push hook written by .claude/maintainer/install-git-guards.sh (repo-only, USR-009):
# (1) finds publish-guard.sh in the newest cached Odeo version, from a user terminal where
# the plugin's programs are not on PATH (moved here from tests/git-guards.plugin.test.sh case
# 4); (2) a current hook is not reported as outdated by the session-start check, and a newer
# hook version is not called older (moved from tests/odeo-context.test.sh, where the shipped
# installer no longer writes a pre-push hook).
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 no cache lookup in the pre-push hook's odeo_tool -> case 1 FAIL
#   M2 hook_version in hooks/odeo-context.sh compares with -eq instead of -lt -> case 2 FAIL
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
INSTALLER="$ROOT/.claude/maintainer/install-git-guards.sh"
HOOK="$ROOT/hooks/odeo-context.sh"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unset CLAUDE_CONFIG_DIR
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
CLEAN_PATH="$(dirname "$(command -v git)"):/usr/bin:/bin"
LOG="$TMP/calls.log"

# 1) pre-push to the public remote (publish marker set) finds publish-guard in the cache
H="$TMP/home"; cache="$H/.claude/plugins/cache/odeo/odeo/0.3.0/scripts"; mkdir -p "$cache"
for s in secret-scan.sh publish-guard.sh; do
  printf '#!/usr/bin/env bash\ncat >/dev/null\necho "%s cached" >> "%s"\nexit 0\n' "$s" "$LOG" > "$cache/$s"; chmod +x "$cache/$s"
done
repo="$TMP/repo"; git init -q "$repo" && git -C "$repo" commit -q --allow-empty -m init
( cd "$repo" && HOME="$H" PATH="$CLEAN_PATH" bash "$INSTALLER" >/dev/null )
git init -q --bare "$TMP/public.git"; git -C "$repo" remote add origin "$TMP/public.git"
git -C "$repo" switch -q -c feature/x
mkdir -p "$repo/docs"; printf 'docs/plans/\n' > "$repo/docs/internal-paths.txt"
: > "$LOG"
( cd "$repo" && HOME="$H" PATH="$CLEAN_PATH" CLAUDE_PUBLISH_SNAPSHOT=1 git push -q origin feature/x 2>"$TMP/err" )
assert_contains "pre-push used the cached publish-guard" "publish-guard.sh cached" "$(cat "$LOG")"

# 2) the session-start check: current pre-push and pre-commit are silent; a NEWER version is
#    not called older (the nudge would offer a downgrade)
ch="$TMP/clean-home"; mkdir -p "$ch/.claude"
norepo="$TMP/no-repo"; mkdir -p "$norepo"
gr="$TMP/guarded"; git init -q "$gr"
( cd "$gr" && HOME="$ch" bash "$INSTALLER" >/dev/null )
legacy() { CLAUDE_PROJECT_DIR="$1" GIT_CEILING_DIRECTORIES="$TMP" HOME="$ch" "$HOOK" legacy SessionStart; }
[ -z "$(legacy "$gr")" ] && ok "current pre-push and pre-commit -> silent" || bad "current hooks were reported"
sed 's/^ODEO_HOOKS_VERSION=2$/ODEO_HOOKS_VERSION=3/' "$gr/.git/hooks/pre-push" > "$TMP/v3"
cp "$TMP/v3" "$gr/.git/hooks/pre-push"; cp "$TMP/v3" "$gr/.git/hooks/pre-commit"
[ -z "$(legacy "$gr")" ] && ok "a newer hook version -> silent" || bad "a newer hook version was reported"
printf '#!/usr/bin/env bash\nodeo_tool() {\n  ls -1td "$HOME"/.claude/plugins/cache/*/odeo/*/bin\n}\n' > "$gr/.git/hooks/pre-push"
assert_contains "an old 0.2.x pre-push hook -> refresh nudge" "install-git-guards.sh" "$(legacy "$gr")"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
