#!/usr/bin/env bash
# Tests for .claude/maintainer/gen-legacy-hashes.sh and the list it writes,
# scripts/odeo-legacy-hashes.txt (what odeo-migrate-legacy.sh recognises Odeo's copies by).
#
# Two kinds of case. (A) The generator on a SYNTHETIC repository, so its behaviour is pinned
# by outcome and does not depend on this repo's history: every version at a shipped path across
# ALL refs, the root commit, the working tree, name-bound pairs, bad names dropped, a shallow
# clone refused. (B) The COMMITTED list against this repository: not missing
# any version reachable here (the regenerate-and-diff proof, as a subset check because other
# clones carry other refs, so an extra line is history this clone has pruned, never a defect;
# a missing line is a skill version migrate would fail to recognise).
#
# Observed failing (2026-10-29), each mutant checked to differ from the original:
#   M1 git log without --all (one branch only)        -> 2 FAIL (case 1: the branch-only version is missing, the count is short)
#   M2 git log --diff-filter=M instead of AM          -> 3 FAIL (case 1: the root commit's version and the deleted skill are missing)
#   M3 no working-tree step                           -> 2 FAIL (case 1: the uncommitted version is missing, the count is short)
#   M4 the blob id listed instead of its sha256       -> 6 FAIL (case 1: wrong hashes; case 3: nothing committed matches)
#   M5 every pair listed as kind "skill"              -> 3 FAIL (case 1: a version appears under another name/kind; case 3)
#   M6 the name filter removed (any path accepted)    -> 2 FAIL (case 1: a non-slug name reached the list)
#   M7 no shallow-clone refusal                       -> 1 FAIL (case 2)
#   M8 the committed list loses one line              -> 1 FAIL (case 3: a version reachable here is missing from it)
# (the list's own shape, and that it names everything shipped now, is tests/odeo-legacy-hashes.txt.test.sh)
# (git log needs no --root: log shows root commits by default, so that flag was dropped as dead.)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
GEN_SRC="$ROOT/.claude/maintainer/gen-legacy-hashes.sh"
LIST="$ROOT/scripts/odeo-legacy-hashes.txt"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
has() { if grep -qxF -- "$3" <<<"$2"; then ok "$1"; else bad "$1 (missing line: $3)"; fi; }
lacks() { if grep -qxF -- "$3" <<<"$2"; then bad "$1 (unexpected line: $3)"; else ok "$1"; fi; }
sha() { printf '%s' "$1" | { shasum -a 256 2>/dev/null || sha256sum; } | awk '{print $1}'; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# 1) a synthetic repository: the generator copy lives at .claude/maintainer/ inside it, because
#    it finds the repository from its own location
R="$TMP/repo"; git init -q -b main "$R"; mkdir -p "$R/.claude/maintainer" "$R/skills/alpha" "$R/agents" "$R/docs"
cp "$GEN_SRC" "$R/.claude/maintainer/gen-legacy-hashes.sh"
printf 'alpha v1\n' > "$R/skills/alpha/SKILL.md"; printf 'scout v1\n' > "$R/agents/scout.md"
printf 'rubric v1\n' > "$R/docs/agent-rubric.md"
mkdir -p "$R/skills/Bad_Name" "$R/skills/has.dot"; printf 'bad\n' > "$R/skills/Bad_Name/SKILL.md"; printf 'dot\n' > "$R/skills/has.dot/SKILL.md"
printf 'notes\n' > "$R/skills/alpha/rubric.md"                     # a companion file is not hashed
git -C "$R" add -A; git -C "$R" commit -q -m root                  # v1 lives in the ROOT commit
printf 'alpha v2\n' > "$R/skills/alpha/SKILL.md"; git -C "$R" commit -qam v2
git -C "$R" checkout -q -b side; printf 'alpha v3 on a branch\n' > "$R/skills/alpha/SKILL.md"
git -C "$R" commit -qam v3; git -C "$R" checkout -q main
mkdir -p "$R/skills/gone"; printf 'gone v1\n' > "$R/skills/gone/SKILL.md"; git -C "$R" add -A; git -C "$R" commit -qm gone
git -C "$R" rm -q -r skills/gone; git -C "$R" commit -qm "remove gone"
printf 'alpha v4 uncommitted\n' > "$R/skills/alpha/SKILL.md"       # working tree only
out="$(bash "$R/.claude/maintainer/gen-legacy-hashes.sh" 2>/dev/null)"; rc=$?
assert_exit "generator runs on a synthetic repo" 0 "$rc"
for v in "alpha v1" "alpha v2" "alpha v3 on a branch" "alpha v4 uncommitted"; do
  has "skill alpha: '$v' is listed" "$out" "skill alpha $(sha "$v
")"
done
has "agent scout is listed under its kind" "$out" "agent scout $(sha 'scout v1
')"
has "docs/agent-rubric.md is listed as an agent" "$out" "agent agent-rubric $(sha 'rubric v1
')"
has "a deleted skill's version is still listed" "$out" "skill gone $(sha 'gone v1
')"
lacks "a version is not listed under another name" "$out" "skill scout $(sha 'scout v1
')"
lacks "a version is not listed under another kind" "$out" "agent alpha $(sha 'alpha v2
')"
case "$out" in *Bad_Name*|*has.dot*|*"$(sha 'bad
')"*|*"$(sha 'dot
')"*) bad "a non-slug skill name reached the list";; *) ok "non-slug names are dropped";; esac
case "$out" in *"$(sha 'notes
')"*) bad "a companion file was hashed";; *) ok "only SKILL.md is hashed";; esac
[ "$(printf '%s\n' "$out" | grep -vc '^#')" = "7" ] && ok "exactly the expected entries (7)" \
  || bad "unexpected entry count: $(printf '%s\n' "$out" | grep -vc '^#') (expected 7)"
[ "$out" = "$(bash "$R/.claude/maintainer/gen-legacy-hashes.sh" 2>/dev/null)" ] && ok "output is deterministic" || bad "output differs between two runs"
mkdir -p "$R/scripts"; bash "$R/.claude/maintainer/gen-legacy-hashes.sh" --write 2>/dev/null
[ "$(cat "$R/scripts/odeo-legacy-hashes.txt")" = "$out" ] && ok "--write puts the same list in scripts/" || bad "--write differs from stdout"
bash "$R/.claude/maintainer/gen-legacy-hashes.sh" --bogus >/dev/null 2>&1; assert_exit "unknown flag -> 2" 2 "$?"

# 2) a shallow clone has incomplete history: refused, not silently partial
git clone -q --depth 1 "file://$R" "$TMP/shallow" 2>/dev/null
mkdir -p "$TMP/shallow/.claude/maintainer"; cp "$GEN_SRC" "$TMP/shallow/.claude/maintainer/"
bash "$TMP/shallow/.claude/maintainer/gen-legacy-hashes.sh" >/dev/null 2>&1; assert_exit "shallow clone -> 2" 2 "$?"

# 3) the real repository: the generator agrees with the committed list on everything reachable
#    here (skipped where the history is partial: a snapshot or shallow clone)
if [ "$(git -C "$ROOT" rev-parse --is-shallow-repository 2>/dev/null)" = "false" ]; then
  regen="$(bash "$GEN_SRC" 2>/dev/null | grep -v '^#')"
  committed="$(grep -v '^#' "$LIST")"
  missing="$(comm -23 <(printf '%s\n' "$regen" | LC_ALL=C sort -u) <(printf '%s\n' "$committed" | LC_ALL=C sort -u))"
  [ -z "$missing" ] && ok "committed list holds every version reachable in this clone" \
    || bad "committed list is missing $(printf '%s\n' "$missing" | wc -l | tr -d ' ') version(s); run gen-legacy-hashes.sh --write"
else
  echo "skip: this clone is shallow or has no history; the regenerate check does not apply"
fi

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
