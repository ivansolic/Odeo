#!/usr/bin/env bash
# The build half is gone: every item in docs/removed-items.txt is untracked, the list has
# the counts the story names, and hooks/hooks.json no longer carries the community reminder
# or the focus fence (PRD-002 R2, USR-009).
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 git checkout dev-phase-archive -- skills/build                       -> 1 FAIL
#   M2 remove the "skill deploy" line from docs/removed-items.txt            -> 1 FAIL (count)
#   M3 re-add a "community" SessionStart entry to hooks/hooks.json           -> 1 FAIL
#   M4 re-add the PreToolUse focus-check.sh entry to hooks/hooks.json        -> 1 FAIL
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

LIST=docs/removed-items.txt
[ -f "$LIST" ] || { bad "$LIST is missing"; exit 1; }

n_skill=0; n_agent=0; n_script=0
while read -r kind name extra; do
  case "$kind" in ''|'#'*) continue ;; esac
  case "$kind" in
    skill)  path="skills/$name/"; n_skill=$((n_skill + 1)) ;;
    agent)  path="agents/$name.md"; n_agent=$((n_agent + 1)) ;;
    script) path="scripts/$name"; n_script=$((n_script + 1)) ;;
    file)   path="$name" ;;
    hook)   continue ;;
    *)      bad "unknown kind '$kind' in $LIST"; continue ;;
  esac
  if [ -n "$(git ls-files -- "$path")" ] || [ -e "$path" ]; then bad "still present: $kind $name"
  else ok "gone: $kind $name"; fi
done < "$LIST"

[ "$n_skill" -eq 20 ] && ok "20 skills listed" || bad "expected 20 skills listed, found $n_skill"
[ "$n_agent" -eq 7 ] && ok "7 agents listed" || bad "expected 7 agents listed, found $n_agent"
[ "$n_script" -eq 4 ] && ok "4 scripts listed" || bad "expected 4 scripts listed, found $n_script"

while read -r kind name extra; do
  [ "$kind" = hook ] || continue
  if grep -q -- "$name" hooks/hooks.json; then bad "hooks/hooks.json still carries: $name"
  else ok "hooks/hooks.json has no $name entry"; fi
done < "$LIST"

if grep -qx 'docs/removed-items.txt' docs/internal-paths.txt; then ok "the list is classified internal"
else bad "docs/removed-items.txt is not in docs/internal-paths.txt"; fi

exit "$fail"
