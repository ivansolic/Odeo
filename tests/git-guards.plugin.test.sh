#!/usr/bin/env bash
# Tests that the git hooks written by scripts/install-git-guards.sh find Odeo's scripts in a
# plugin install, including when git runs in the user's own terminal, where the plugin's
# programs are NOT on PATH. Lookup order under test: PATH, then the newest version in
# ~/.claude/plugins/cache/*/odeo/*/scripts (an update leaves the old version there for a
# grace period), then the same caches' bin/ (the Odeo 0.2.x layout), then the directory
# the hooks were installed from (a plugin loaded in place from a clone), and never a path
# relative to the repo (case 10: a project's own script is not Odeo's gate). Case 9 runs a hook written by the 0.2.x installer (bin/ lookups only)
# against a current-layout cache, which reaches the program through the bin/ wrapper.
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 no cache lookup          -> 3 FAIL (cases 2, 3, 4). Case 1 stays green under M1 because
#                                  the install-time dir IS the newest version; case 1 is
#                                  attributed by M2, not M1.
#   M2 cache read oldest first  -> 4 FAIL (cases 1, 2, 3, 4)
#   M3 no install-time dir      -> 1 FAIL (case 5)
#   M4 no install-time config dir -> 1 FAIL (case 7)
# Observed failing (2026-09-29), after the move to scripts/:
#   M5 no scripts/ glob in the cache lookup -> 5 FAIL (cases 1, 2, 3, 4, 7)
#   M6 no bin/ glob in the cache lookup     -> 1 FAIL (case 8)
#   M7 bin/ wrapper does not forward        -> 2 FAIL (case 9)
#   M8 repo-relative scripts/ and bin/ fallback restored (the 0.3.0 review's finding)
#                                           -> 4 FAIL (case 10)
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

# new_repo <name> <installer>: a repo with no scripts/, hooks installed by <installer>
new_repo() {
  local r="$TMP/$1"
  git init -q "$r" && git -C "$r" commit -q --allow-empty -m init
  ( cd "$r" && HOME="$HOME_T" PATH="$CLEAN_PATH" bash "$2" >/dev/null )
  printf '%s' "$r"
}

commit_in() { # commit_in <repo>: a commit from a "user terminal" (clean PATH); prints rc
  ( cd "$1" && echo x >> f && git add f && HOME="$HOME_T" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>"$TMP/err"; echo $? )
}

# Layout: a copied install with an OLD version (0.2.x layout, bin/) and a NEW one
# (scripts/) in the cache; the installer is run from the NEW version, as /new-project would.
HOME_T="$TMP/home"
cache="$HOME_T/.claude/plugins/cache/odeo/odeo"
stub "$cache/0.1.0/bin" old 0; sleep 1; stub "$cache/0.2.0/scripts" new 0
cp "$ROOT/scripts/install-git-guards.sh" "$cache/0.2.0/scripts/"

# 1) terminal commit: the newest cached version is used, not the old one
repo="$(new_repo r1 "$cache/0.2.0/scripts/install-git-guards.sh")"
: > "$LOG"; rc="$(commit_in "$repo")"
assert_eq "commit succeeds" 0 "$rc"
assert_eq "newest cached secret-scan ran" "secret-scan.sh new" "$(cat "$LOG")"

# 2) the plugin updates: 0.3.0 appears, the hook follows it with no reinstall
stub "$cache/0.3.0/scripts" newer 0
: > "$LOG"; commit_in "$repo" >/dev/null
assert_eq "hook follows a plugin update" "secret-scan.sh newer" "$(cat "$LOG")"

# 3) the scanner blocks: the commit is refused
stub "$cache/0.3.0/scripts" newer 1
rc="$(commit_in "$repo")"
[ "$rc" != 0 ] && ok "blocking secret-scan refuses the commit" || bad "commit went through a blocking scan"
stub "$cache/0.3.0/scripts" newer 0

# 4) pre-push to the public remote (publish marker set) finds publish-guard in the cache
git init -q --bare "$TMP/public.git"; git -C "$repo" remote add origin "$TMP/public.git"
git -C "$repo" switch -q -c feature/x
# contract A runs only in a project that publishes through a snapshot, which this marks
mkdir -p "$repo/docs"; printf 'docs/plans/\n' > "$repo/docs/internal-paths.txt"
: > "$LOG"
( cd "$repo" && HOME="$HOME_T" PATH="$CLEAN_PATH" CLAUDE_PUBLISH_SNAPSHOT=1 git push -q origin feature/x 2>"$TMP/err" )
assert_contains "pre-push used the cached publish-guard" "publish-guard.sh newer" "$(cat "$LOG")"

# 5) in-place plugin (a clone, no cache): the install-time directory is used
rm -rf "$HOME_T/.claude/plugins"
inplace="$TMP/clone/scripts"; stub "$inplace" inplace 0; cp "$ROOT/scripts/install-git-guards.sh" "$inplace/"
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
stub "$ccache/0.2.0/scripts" cfg-new 0; cp "$ROOT/scripts/install-git-guards.sh" "$ccache/0.2.0/scripts/"
r="$TMP/r7"; git init -q "$r" && git -C "$r" commit -q --allow-empty -m init
( cd "$r" && HOME="$HOME_T" PATH="$CLEAN_PATH" CLAUDE_CONFIG_DIR="$cfg" bash "$ccache/0.2.0/scripts/install-git-guards.sh" >/dev/null )
sleep 1; stub "$ccache/0.3.0/scripts" cfg-newer 0; rm -rf "$ccache/0.2.0"   # updated, old one swept
: > "$LOG"; commit_in "$r" >/dev/null
assert_eq "config dir remembered from install time" "secret-scan.sh cfg-newer" "$(cat "$LOG")"

# 8) only an Odeo 0.2.x version is cached (its programs in bin/): a current hook still
#    finds them, so a project set up now keeps its gate on a machine that has not updated
H8="$TMP/home8"; c8="$H8/.claude/plugins/cache/odeo/odeo"
stub "$c8/0.2.2/bin" legacy-layout 0
inst8="$TMP/inst8"; mkdir -p "$inst8"; cp "$ROOT/scripts/install-git-guards.sh" "$inst8/"
r8="$TMP/r8"; git init -q "$r8" && git -C "$r8" commit -q --allow-empty -m init
( cd "$r8" && HOME="$H8" PATH="$CLEAN_PATH" bash "$inst8/install-git-guards.sh" >/dev/null ); rm -rf "$inst8"
: > "$LOG"; ( cd "$r8" && echo x >> f && git add f && HOME="$H8" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>&1 )
assert_eq "current hook finds a 0.2.x cache (bin/)" "secret-scan.sh legacy-layout" "$(cat "$LOG")"

# 9) THE COMPATIBILITY PROMISE: a hook written by the 0.2.x installer (it only knows
#    */odeo/*/bin) keeps its gate once the cache holds only a current-layout version, whose
#    real programs are in scripts/ and whose bin/ holds the forwarding wrappers.
H9="$TMP/home9"; v9="$H9/.claude/plugins/cache/odeo/odeo/0.3.0"
stub "$v9/scripts" current-layout 0; mkdir -p "$v9/bin"; cp "$ROOT"/bin/secret-scan.sh "$ROOT"/bin/publish-guard.sh "$v9/bin/"
r9="$TMP/r9"; git init -q "$r9" && git -C "$r9" commit -q --allow-empty -m init
# The pre-commit hook the 0.2.2 installer wrote, verbatim except the two baked paths
# (the install-time dir is gone, as after a cache sweep). Copied, not regenerated from git
# history, because the published repo does not carry that history.
{ printf '#!/usr/bin/env bash\nODEO_BIN_AT_INSTALL=%q\nODEO_CONFIG_AT_INSTALL=%q\n' "$TMP/swept" "$H9/.claude"
  cat <<'OLDHOOK'
odeo_tool() { # odeo_tool <name>: prints the path of an Odeo script, nothing if not found
  local name="$1" c
  c="$(command -v "$name" 2>/dev/null || true)"
  [ -n "$c" ] && [ -x "$c" ] && { printf '%s' "$c"; return 0; }
  # newest first: after an update the old version stays in the cache for a grace period
  while IFS= read -r c; do
    [ -x "$c/$name" ] && { printf '%s' "$c/$name"; return 0; }
  done < <(ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/bin \
                   "$ODEO_CONFIG_AT_INSTALL"/plugins/cache/*/odeo/*/bin \
                   "$HOME"/.claude/plugins/cache/*/odeo/*/bin 2>/dev/null)
  for c in "$ODEO_BIN_AT_INSTALL" "bin"; do
    [ -x "$c/$name" ] && { printf '%s' "$c/$name"; return 0; }
  done
  return 0
}
# Enforced guardrail: staged secrets block the commit (secret-scan.sh).
scan="$(odeo_tool secret-scan.sh)"
if [ -n "$scan" ]; then
  "$scan" || exit 1
else
  echo "pre-commit WARNING: secret-scan.sh not found, committing WITHOUT the secret gate." >&2
  echo "Reinstall the Odeo plugin to restore the guardrail." >&2
fi
exit 0
OLDHOOK
} > "$r9/.git/hooks/pre-commit"; chmod +x "$r9/.git/hooks/pre-commit"
: > "$LOG"; rc9="$( cd "$r9" && echo x >> f && git add f && HOME="$H9" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>&1; echo $? )"
assert_eq "old hook: commit succeeds" 0 "$rc9"
assert_eq "old hook reaches scripts/ through the bin/ wrapper" "secret-scan.sh current-layout" "$(cat "$LOG")"
stub "$v9/scripts" current-layout 1
rc9="$( cd "$r9" && echo x >> f && git add f && HOME="$H9" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>&1; echo $? )"
[ "$rc9" != 0 ] && ok "old hook: a blocking scan still blocks through the wrapper" || bad "old hook committed through a blocking scan"

# 10) a project's OWN scripts/ or bin/ is never taken for Odeo's: with Odeo nowhere to be
#     found, a project script named secret-scan.sh must not stand in as the secret gate (it
#     would silence the warning and gate nothing); the hook warns instead
H10="$TMP/home10"; mkdir -p "$H10"
inst10="$TMP/inst10"; mkdir -p "$inst10"; cp "$ROOT/scripts/install-git-guards.sh" "$inst10/"
for d in scripts bin; do
  r10="$TMP/r10-$d"; git init -q "$r10" && git -C "$r10" commit -q --allow-empty -m init
  stub "$r10/$d" "project-own-$d" 0
  ( cd "$r10" && HOME="$H10" PATH="$CLEAN_PATH" bash "$inst10/install-git-guards.sh" >/dev/null )
done
rm -rf "$inst10"
for d in scripts bin; do
  r10="$TMP/r10-$d"; : > "$LOG"
  ( cd "$r10" && echo x >> f && git add f && HOME="$H10" PATH="$CLEAN_PATH" git commit -q -m c >/dev/null 2>"$TMP/err10" )
  assert_eq "a project's own $d/secret-scan.sh is not run as the gate" "" "$(cat "$LOG")"
  assert_contains "the missing gate is still announced ($d/)" "WITHOUT the secret gate" "$(cat "$TMP/err10")"
done

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
