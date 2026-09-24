#!/usr/bin/env bash
# Tests that the git hooks written by bin/install-git-guards.sh find Odeo's scripts in a
# plugin install, including when git runs in the user's own terminal, where the plugin's
# bin/ is NOT on PATH (Claude Code adds it only to the Bash tool). Lookup order under test:
# PATH, then the newest version in ~/.claude/plugins/cache/*/odeo/*/bin (an update leaves
# the old version there for a grace period), then the directory the hooks were installed
# from (a plugin loaded in place from a clone), then the repo's own bin/.
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 no cache lookup          -> 3 FAIL (cases 2, 3, 4). Case 1 stays green under M1 because
#                                  the install-time dir IS the newest version; case 1 is
#                                  attributed by M2, not M1.
#   M2 cache read oldest first  -> 4 FAIL (cases 1, 2, 3, 4)
#   M3 no install-time dir      -> 1 FAIL (case 5)
#   M4 no install-time config dir -> 1 FAIL (case 7)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_eq() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$2', got '$3')"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
CLEAN_PATH="$(dirname "$(command -v git)"):/usr/bin:/bin"
LOG="$TMP/calls.log"

# stub <dir> <label> <exit>: fake secret-scan.sh and publish-guard.sh that log who ran
stub() {
  mkdir -p "$1"
  for s in secret-scan.sh publish-guard.sh; do
    printf '#!/usr/bin/env bash\ncat >/dev/null\necho "%s %s" >> "%s"\nexit %s\n' "$s" "$2" "$LOG" "$3" > "$1/$s"
    chmod +x "$1/$s"
  done
}

# new_repo <name> <installer>: a repo with no bin/, hooks installed by <installer>
new_repo() {
  local r="$TMP/$1"
  git init -q "$r" && git -C "$r" commit -q --allow-empty -m init
  ( cd "$r" && HOME="$HOME_T" PATH="$CLEAN_PATH" bash "$2" >/dev/null )
  printf '%s' "$r"
}

commit_in() { # commit_in <repo>: a commit from a "user terminal" (clean PATH); prints rc
  ( cd "$1" && echo x >> f && git add f && HOME="$HOME_T" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>"$TMP/err"; echo $? )
}

# Layout: a copied install with an OLD and a NEW version in the cache; the installer is
# run from the NEW version, as /new-project would.
HOME_T="$TMP/home"
cache="$HOME_T/.claude/plugins/cache/odeo/odeo"
stub "$cache/0.1.0/bin" old 0; sleep 1; stub "$cache/0.2.0/bin" new 0
cp "$ROOT/bin/install-git-guards.sh" "$cache/0.2.0/bin/"

# 1) terminal commit: the newest cached version is used, not the old one
repo="$(new_repo r1 "$cache/0.2.0/bin/install-git-guards.sh")"
: > "$LOG"; rc="$(commit_in "$repo")"
assert_eq "commit succeeds" 0 "$rc"
assert_eq "newest cached secret-scan ran" "secret-scan.sh new" "$(cat "$LOG")"

# 2) the plugin updates: 0.3.0 appears, the hook follows it with no reinstall
stub "$cache/0.3.0/bin" newer 0
: > "$LOG"; commit_in "$repo" >/dev/null
assert_eq "hook follows a plugin update" "secret-scan.sh newer" "$(cat "$LOG")"

# 3) the scanner blocks: the commit is refused
stub "$cache/0.3.0/bin" newer 1
rc="$(commit_in "$repo")"
[ "$rc" != 0 ] && ok "blocking secret-scan refuses the commit" || bad "commit went through a blocking scan"
stub "$cache/0.3.0/bin" newer 0

# 4) pre-push to the public remote (publish marker set) finds publish-guard in the cache
git init -q --bare "$TMP/public.git"; git -C "$repo" remote add origin "$TMP/public.git"
git -C "$repo" switch -q -c feature/x
: > "$LOG"
( cd "$repo" && HOME="$HOME_T" PATH="$CLEAN_PATH" CLAUDE_PUBLISH_SNAPSHOT=1 git push -q origin feature/x 2>"$TMP/err" )
assert_contains "pre-push used the cached publish-guard" "publish-guard.sh newer" "$(cat "$LOG")"

# 5) in-place plugin (a clone, no cache): the install-time directory is used
rm -rf "$HOME_T/.claude/plugins"
inplace="$TMP/clone/bin"; stub "$inplace" inplace 0; cp "$ROOT/bin/install-git-guards.sh" "$inplace/"
repo="$(new_repo r5 "$inplace/install-git-guards.sh")"
: > "$LOG"; commit_in "$repo" >/dev/null
assert_eq "install-time dir used without a cache" "secret-scan.sh inplace" "$(cat "$LOG")"

# 6) nothing anywhere: warns, names the plugin as the fix, never runs a missing scanner
rm -rf "$TMP/clone"; : > "$LOG"
rc="$(commit_in "$repo")"
assert_eq "commit still succeeds (existing fail-open warning)" 0 "$rc"
assert_contains "warning names the Odeo plugin" "Odeo plugin" "$(cat "$TMP/err")"

# 7) a config dir outside ~/.claude (CLAUDE_CONFIG_DIR, documented for side-by-side
#    accounts): hooks installed with it set find a LATER version in that config's cache,
#    even when git runs from a terminal where CLAUDE_CONFIG_DIR is not set
cfg="$TMP/other-config"; ccache="$cfg/plugins/cache/odeo/odeo"
stub "$ccache/0.2.0/bin" cfg-new 0; cp "$ROOT/bin/install-git-guards.sh" "$ccache/0.2.0/bin/"
r="$TMP/r7"; git init -q "$r" && git -C "$r" commit -q --allow-empty -m init
( cd "$r" && HOME="$HOME_T" PATH="$CLEAN_PATH" CLAUDE_CONFIG_DIR="$cfg" bash "$ccache/0.2.0/bin/install-git-guards.sh" >/dev/null )
sleep 1; stub "$ccache/0.3.0/bin" cfg-newer 0; rm -rf "$ccache/0.2.0"   # updated, old one swept
: > "$LOG"; commit_in "$r" >/dev/null
assert_eq "config dir remembered from install time" "secret-scan.sh cfg-newer" "$(cat "$LOG")"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
