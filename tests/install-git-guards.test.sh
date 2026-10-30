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
#
# The refresh that keeps what it replaces (USR-010). Observed failing (2026-10-30), each mutant
# checked to differ from the original:
#   I1  pre-commit overwritten without keeping a copy         -> 8 FAIL
#   I2  the old hook deleted instead of moved aside           -> 8 FAIL
#   I3  a pre-push always moved aside                         -> 6 FAIL
#   I4  a pre-push never moved aside                          -> 6 FAIL
#   I5  substring match instead of a whole token              -> 2 FAIL
#   I6  a symlinked pre-commit not treated as different       -> 1 FAIL (a link to identical content)
#   I7  the new pre-commit names a removed script             -> 1 FAIL
#   I8  the list not read (one name hard-coded)               -> 6 FAIL
#   I9  list lines used without validation                    -> 2 FAIL
#   I10 the dot in a name not made literal                    -> 1 FAIL (boundary-checkXsh)
#   I11 the new hook ignores the secret scan result           -> 1 FAIL (the planted secret is committed)
#   I12 hooks directory fixed to .git/hooks                   -> 3 FAIL (both core.hooksPath cases)
#   I13 a missing list not reported                           -> 1 FAIL
#   I14 the new hook not executable                           -> 6 FAIL
#   I15 an existing aside file overwritten: SURVIVES. The branch only fires when two runs share
#       the same second and the same pid, which no test can arrange without faking both.
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

# --- the refresh keeps what it replaces (PRD-002 R8, USR-010) -----------------------------
# A hook that still calls a script the release no longer ships is refreshed by running this
# installer (the session-start check names it and the command). The installer used to
# overwrite pre-commit without a trace; now it moves a pre-commit that differs, and a
# pre-push that mentions a removed script, aside as <hook>.odeo-old-<YYYYmmddHHMMSS>-<pid>
# in the same hooks directory, and deletes nothing. A pre-push that mentions none is left alone.
LIST="$(cd "$(dirname "$INSTALLER")" && pwd)/odeo-removed-scripts.txt"
removed_names() { grep -vE '^#|^$' "$LIST"; }
asides() { ls -1 "$1" 2>/dev/null | grep -E "^$2\.odeo-old-[0-9]{14}-[0-9]+\$"; }  # asides <hooks-dir> <hook>
same() { [ -f "$1" ] && [ -f "$2" ] && cmp -s "$1" "$2"; }   # both are files with equal bytes
names_removed() { local n; while IFS= read -r n; do grep -aq -- "$n" "$1" && return 0; done <<< "$(removed_names)"; return 1; }
SECRET="AKIA""IOSFODNN7EXAMPLE"   # built in two pieces: this file must not trip the secret scan itself
ch="$TMP/clean-home"; mkdir -p "$ch"

old="$TMP/old-pre-commit"
printf '#!/bin/sh\n# my own commit checks\n"$HOME/bin/merge-gate.sh" || exit 1\nnpm run lint\n' > "$old"
rf="$TMP/refresh"; git init -q "$rf"; cp "$old" "$rf/.git/hooks/pre-commit"; chmod +x "$rf/.git/hooks/pre-commit"
out="$( cd "$rf" && HOME="$ch" bash "$INSTALLER" 2>&1 )"; rc=$?
assert_exit "a refresh over an old pre-commit succeeds" 0 "$rc"
n_aside="$(asides "$rf/.git/hooks" pre-commit | wc -l | tr -d ' ')"
[ "$n_aside" = 1 ] && ok "the old pre-commit was moved aside to pre-commit.odeo-old-<time>-<pid>" || bad "expected one pre-commit.odeo-old-* file, found $n_aside"
aside="$rf/.git/hooks/$(asides "$rf/.git/hooks" pre-commit | head -1)"
same "$old" "$aside" && ok "the moved copy is byte-identical to the old hook" || bad "the moved copy differs from the old hook"
assert_contains "the output says what was moved" "pre-commit.odeo-old-" "$out"
assert_contains "the output still says the secret scan is installed" "pre-commit (secret scan) installed" "$out"
names_removed "$rf/.git/hooks/pre-commit" && bad "the new pre-commit still names a removed script" || ok "the new pre-commit names no removed script"
[ -x "$rf/.git/hooks/pre-commit" ] && ok "the new pre-commit is executable" || bad "the new pre-commit is not executable"
# end to end: the refreshed hook still blocks a planted secret on `git commit`, and lets a clean commit through
( cd "$rf" && printf 'const key = "%s"\n' "$SECRET" > leak.ts && git add leak.ts )
rc="$( cd "$rf" && HOME="$ch" git commit -q -m leak >/dev/null 2>&1; echo $? )"
[ "$rc" != 0 ] && ok "git commit with a planted secret is refused after the refresh" || bad "a planted secret was committed after the refresh"
( cd "$rf" && git rm -q --cached leak.ts && rm leak.ts && printf 'hello\n' > ok.txt && git add ok.txt )
rc="$( cd "$rf" && HOME="$ch" git commit -q -m clean >/dev/null 2>&1; echo $? )"
assert_exit "a clean commit passes after the refresh" 0 "$rc"
# running it again changes nothing: the hook is current, so there is nothing to keep
( cd "$rf" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
[ "$(asides "$rf/.git/hooks" pre-commit | wc -l | tr -d ' ')" = 1 ] && ok "a second run moves nothing (the hook is current)" || bad "a second run moved the current hook aside"

# a fresh repo has nothing to move
fresh="$TMP/fresh"; git init -q "$fresh"; ( cd "$fresh" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
[ -z "$(asides "$fresh/.git/hooks" pre-commit)" ] && ok "a fresh install moves nothing" || bad "a fresh install left an aside file"

# a pre-commit that is a symlink is moved aside as the link, its target untouched
sl="$TMP/symlinked"; git init -q "$sl"; printf '#!/bin/sh\nmerge-gate.sh\n' > "$TMP/shared-hook"; chmod +x "$TMP/shared-hook"
ln -s "$TMP/shared-hook" "$sl/.git/hooks/pre-commit"
( cd "$sl" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
a="$sl/.git/hooks/$(asides "$sl/.git/hooks" pre-commit | head -1)"
{ [ -L "$a" ] && [ "$(readlink "$a")" = "$TMP/shared-hook" ]; } && ok "a symlinked pre-commit is moved aside as the link" || bad "the symlinked pre-commit was not kept as a link"
[ ! -L "$sl/.git/hooks/pre-commit" ] && grep -q 'secret-scan.sh' "$sl/.git/hooks/pre-commit" && ok "the new pre-commit is a regular file" || bad "the new pre-commit is still the symlink"
grep -q 'merge-gate.sh' "$TMP/shared-hook" && ok "the symlink's target was not written through" || bad "the symlink's target was overwritten"
# ... even when the link already points at a file with exactly the new content: the link itself
# is the user's arrangement, so it is kept, not silently replaced
cp "$sl/.git/hooks/pre-commit" "$TMP/shared-same"; chmod +x "$TMP/shared-same"
rm "$sl/.git/hooks/pre-commit"; ln -s "$TMP/shared-same" "$sl/.git/hooks/pre-commit"; rm -f "$sl"/.git/hooks/pre-commit.odeo-old-*
( cd "$sl" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
a="$sl/.git/hooks/$(asides "$sl/.git/hooks" pre-commit | head -1)"
{ [ -L "$a" ] && [ ! -L "$sl/.git/hooks/pre-commit" ]; } && ok "a link to identical content is kept aside too, not silently replaced" || bad "a symlinked pre-commit with identical content was replaced without a copy"

# pre-push: one that mentions a removed script is moved aside, one that does not is left alone
pp="$TMP/pp-removed"; git init -q "$pp"; printf '#!/bin/sh\nexec boundary-check.sh "$@"\n' > "$pp/.git/hooks/pre-push"; chmod +x "$pp/.git/hooks/pre-push"
cp "$pp/.git/hooks/pre-push" "$TMP/pp-original"
out="$( cd "$pp" && HOME="$ch" bash "$INSTALLER" 2>&1 )"
[ ! -e "$pp/.git/hooks/pre-push" ] && ok "a pre-push that calls boundary-check.sh is no longer in place" || bad "the pre-push naming boundary-check.sh is still the active hook"
a="$pp/.git/hooks/$(asides "$pp/.git/hooks" pre-push | head -1)"
same "$TMP/pp-original" "$a" && ok "it was kept byte-identical as pre-push.odeo-old-<time>-<pid>" || bad "the moved pre-push is missing or differs"
assert_contains "the output names the moved pre-push" "pre-push.odeo-old-" "$out"
assert_contains "and says why" "boundary-check.sh" "$out"
for text in 'echo mine' 'cp merge-gate.sh.bak /tmp' 'my-boundary-check.sh' 'boundary-checkXsh' 'echo publish-guard.sh secret-scan.sh'; do
  keep="$TMP/pp-keep"; rm -rf "$keep"; git init -q "$keep"; printf '#!/bin/sh\n%s\n' "$text" > "$keep/.git/hooks/pre-push"
  cp "$keep/.git/hooks/pre-push" "$TMP/pp-keep-original"
  ( cd "$keep" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
  { cmp -s "$TMP/pp-keep-original" "$keep/.git/hooks/pre-push" && [ -z "$(asides "$keep/.git/hooks" pre-push)" ]; } \
    && ok "a pre-push saying '$text' is left in place" || bad "a pre-push saying '$text' was moved or changed"
done

# core.hooksPath inside the project: that directory is the one refreshed
hp="$TMP/hookspath"; git init -q "$hp"; mkdir -p "$hp/.githooks"; git -C "$hp" config core.hooksPath .githooks
cp "$old" "$hp/.githooks/pre-commit"; printf '#!/bin/sh\nmerge-gate.sh\n' > "$hp/.githooks/pre-push"
( cd "$hp" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
[ -n "$(asides "$hp/.githooks" pre-commit)" ] && [ -n "$(asides "$hp/.githooks" pre-push)" ] && ok "core.hooksPath inside the repo: both old hooks moved aside there" || bad "core.hooksPath inside the repo: the old hooks were not moved aside in .githooks"
{ [ -x "$hp/.githooks/pre-commit" ] && [ ! -e "$hp/.git/hooks/pre-commit" ]; } && ok "the new pre-commit is written where core.hooksPath points, not in .git/hooks" || bad "the new pre-commit went to the wrong directory"
# core.hooksPath outside the project: handled the same way, nothing is written under .git/hooks
op="$TMP/hookspath-out"; git init -q "$op"; mkdir -p "$TMP/shared-hooks"; git -C "$op" config core.hooksPath "$TMP/shared-hooks"
cp "$old" "$TMP/shared-hooks/pre-commit"
( cd "$op" && HOME="$ch" bash "$INSTALLER" ) >/dev/null 2>&1
{ [ -x "$TMP/shared-hooks/pre-commit" ] && [ -n "$(asides "$TMP/shared-hooks" pre-commit)" ] && [ ! -e "$op/.git/hooks/pre-commit" ]; } \
  && ok "core.hooksPath outside the repo: written and kept there as before" || bad "core.hooksPath outside the repo is not handled as before"

# the list drives it: an installer copy with no list still installs pre-commit, says it could
# not check pre-push, and leaves that hook alone; a damaged line is skipped loudly
nl="$TMP/no-list"; mkdir -p "$nl/scripts"; cp "$INSTALLER" "$nl/scripts/"
nr="$TMP/nolist-repo"; git init -q "$nr"; printf '#!/bin/sh\nmerge-gate.sh\n' > "$nr/.git/hooks/pre-push"
out="$( cd "$nr" && HOME="$ch" bash "$nl/scripts/install-git-guards.sh" 2>&1 )"; rc=$?
assert_exit "no list: the installer still succeeds" 0 "$rc"
[ -x "$nr/.git/hooks/pre-commit" ] && ok "no list: pre-commit is still installed" || bad "no list: pre-commit was not installed"
assert_contains "no list: it says it could not check pre-push" "could not check pre-push" "$out"
assert_contains "no list: the pre-push is left in place" "merge-gate.sh" "$(cat "$nr/.git/hooks/pre-push")"
printf 'retired-tool.sh\nBad Name.sh\n../escape.sh\n.*\n' > "$nl/scripts/odeo-removed-scripts.txt"
dr="$TMP/damaged-list-repo"; git init -q "$dr"; printf '#!/bin/sh\nBad Name.sh; ../escape.sh; echo x\n' > "$dr/.git/hooks/pre-push"
out="$( cd "$dr" && HOME="$ch" bash "$nl/scripts/install-git-guards.sh" 2>&1 )"; rc=$?
assert_exit "a damaged list line: the installer still succeeds" 0 "$rc"
assert_contains "a damaged list line is skipped loudly" "odeo-removed-scripts.txt" "$out"
[ -e "$dr/.git/hooks/pre-push" ] && ok "an invalid list line never becomes a pattern" || bad "a pre-push was moved aside because of an invalid list line"
printf '#!/bin/sh\nretired-tool.sh\n' > "$dr/.git/hooks/pre-push"
( cd "$dr" && HOME="$ch" bash "$nl/scripts/install-git-guards.sh" ) >/dev/null 2>&1
[ ! -e "$dr/.git/hooks/pre-push" ] && ok "a name from the list is acted on" || bad "the list was not read"

# outside a git repo: exit 2
rc="$( cd "$TMP" && GIT_CEILING_DIRECTORIES="$TMP" bash "$INSTALLER" >/dev/null 2>&1; echo $? )"
assert_exit "not a git repo -> 2" 2 "$rc"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
