#!/usr/bin/env bash
# publish-guard.sh reads the lists of the PROJECT being checked, not of wherever the guard
# itself is installed.
#
# The guard used to resolve docs/internal-paths.txt and docs/public-paths.txt next to its
# own bin/. Run from a plugin install (or an old ~/bin copy), that is the plugin's lists
# (or none), so a project's pre-push hook checked the push against Odeo's classification
# instead of its own: an internal path of that project could pass, a public one could be
# refused. Found because tests/install-git-guards.test.sh failed only on a machine with the
# plugin installed. Precedence under test: explicit env override, then the lists at the
# git top level of the current directory, then the guard's own root.
#
# Observed failing (2026-09-24), each mutant checked to differ from the original:
#   MA allowlist from the guard root (the reviewer's surviving mutant) -> 5 FAIL (3b-3e)
#   MC lists always from the guard root                               -> 10 FAIL
#   MB snapshot strips with its own denylist                          -> 2 FAIL (3e)
#   (Handing the resolved pair to the guard by env was dropped: that mutant stayed green,
#   because the guard resolves the same pair from the same directory by itself.)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unset CLAUDE_INTERNAL_PATHS CLAUDE_PUBLIC_PATHS

# The guard installed somewhere else (a plugin root) with ITS OWN lists
tool="$TMP/plugin-root"; mkdir -p "$tool/bin" "$tool/docs"
cp "$ROOT/bin/publish-guard.sh" "$ROOT/bin/privacy-scan.sh" "$tool/bin/"
printf 'tool-internal/\n' > "$tool/docs/internal-paths.txt"
printf 'README.md\ntool-internal/\nsecret/\ntool-only.md\n' > "$tool/docs/public-paths.txt"
GUARD="$tool/bin/publish-guard.sh"

# A project with DIFFERENT lists
proj="$TMP/project"; mkdir -p "$proj/docs"; git init -q "$proj"
printf 'secret/\n' > "$proj/docs/internal-paths.txt"
printf 'README.md\ntool-internal/\n' > "$proj/docs/public-paths.txt"

check() { # check <dir> <path> [--require-allowlist]: runs the guard from <dir>, prints rc
  ( cd "$1" && printf '%s\0' "$2" | "$GUARD" ${3:-} - >/dev/null 2>&1; echo $? )
}

# 1) inside the project: the PROJECT's denylist applies
assert_exit "project-internal path refused" 1 "$(check "$proj" secret/plan.md)"
# 2) ... and the guard's own denylist does not
assert_exit "a path only the tool calls internal passes" 0 "$(check "$proj" tool-internal/a.md)"
# 3) the project's allowlist applies too
assert_exit "a path the project never classified is refused under --require-allowlist" 1 \
  "$(check "$proj" unlisted.md --require-allowlist)"
assert_exit "a path the project lists as public passes under --require-allowlist" 0 \
  "$(check "$proj" tool-internal/a.md --require-allowlist)"
# 3b) the ALLOWLIST is the project's too: a path only the tool calls public is refused
assert_exit "a path only the tool's allowlist lists is refused in the project" 1 \
  "$(check "$proj" tool-only.md --require-allowlist)"
# 3c) a project with a denylist but no allowlist never borrows the tool's allowlist
half="$TMP/half"; mkdir -p "$half/docs"; git init -q "$half"; printf 'secret/\n' > "$half/docs/internal-paths.txt"
assert_exit "project denylist without allowlist -> allowlist not found (2)" 2 \
  "$(check "$half" README.md --require-allowlist)"
# 3d) --print-lists reports the resolved pair, so publish-snapshot.sh strips with the same
#     denylist the guard then checks against
real() { ( cd "$(dirname "$1")" 2>/dev/null && printf '%s/%s' "$(pwd -P)" "$(basename "$1")" ); }
got="$(cd "$proj" && "$GUARD" --print-lists 2>/dev/null)"
assert_exit "--print-lists names the project's denylist" "$(real "$proj/docs/internal-paths.txt")" "$(real "$(sed -n 1p <<<"$got")")"
assert_exit "--print-lists names the project's allowlist" "$(real "$proj/docs/public-paths.txt")" "$(real "$(sed -n 2p <<<"$got")")"

# 3e) publish-snapshot.sh run from the plugin copy in a project with its own lists: the
#     project's internal path is STRIPPED by the same list the guard checks, so the snapshot
#     is produced and the internal file is not in it
cp "$ROOT/bin/publish-snapshot.sh" "$tool/bin/"
snapproj="$TMP/snapproj"; mkdir -p "$snapproj/docs" "$snapproj/secret"; git init -q "$snapproj"
printf 'secret/\n' > "$snapproj/docs/internal-paths.txt"
printf 'README.md\ndocs/internal-paths.txt\ndocs/public-paths.txt\n' > "$snapproj/docs/public-paths.txt"
echo hello > "$snapproj/README.md"; echo plan > "$snapproj/secret/x.md"
( cd "$snapproj" && git add -A && git -c user.name=t -c user.email=t@example.com commit -qm c )
snapout="$TMP/snapout"
( cd "$snapproj" && "$tool/bin/publish-snapshot.sh" "$snapout" >/dev/null 2>&1 ); rc=$?
case "$rc" in 0|3) ok "snapshot from the plugin copy succeeds in a project with its own lists ($rc)";;
  *) bad "snapshot from the plugin copy failed ($rc)";; esac
[ -f "$snapout/README.md" ] && [ ! -e "$snapout/secret/x.md" ] && ok "the project's internal file is stripped, the public one kept" \
  || bad "snapshot content wrong (README present: $([ -f "$snapout/README.md" ] && echo y || echo n), secret present: $([ -e "$snapout/secret/x.md" ] && echo y || echo n))"

# 4) from a subdirectory of the project, still the project's lists
mkdir -p "$proj/sub/deeper"
assert_exit "subdirectory resolves the project top level" 1 "$(check "$proj/sub/deeper" secret/x.md)"
# 5) a project without lists: the guard's own lists are the fallback
bare="$TMP/bare"; mkdir -p "$bare"; git init -q "$bare"
assert_exit "no project lists -> the tool's denylist" 1 "$(check "$bare" tool-internal/a.md)"
# 6) outside any repository: the guard's own lists
out="$TMP/nowhere"; mkdir -p "$out"
assert_exit "outside a repo -> the tool's denylist" 1 "$(GIT_CEILING_DIRECTORIES="$TMP" check "$out" tool-internal/a.md)"
# 7) an explicit override still wins over the project
printf 'other/\n' > "$TMP/override.txt"
rc="$(cd "$proj" && printf '%s\0' secret/plan.md | CLAUDE_INTERNAL_PATHS="$TMP/override.txt" "$GUARD" - >/dev/null 2>&1; echo $?)"
assert_exit "env override beats the project list" 0 "$rc"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
