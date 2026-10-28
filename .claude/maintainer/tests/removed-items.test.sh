#!/usr/bin/env bash
# The build half is gone: every item in docs/removed-items.txt is untracked, existed at the
# git tag `dev-phase-archive` (so the list names real items only, and each is restorable),
# the list has the counts the story names, and hooks/hooks.json no longer carries the
# community reminder or the focus fence (PRD-002 R2, USR-009).
#
# Maintainer tooling, not a shipped suite: it reads docs/removed-items.txt, which is
# internal and absent from the published repository.
#
# Without the tag (a shallow clone) the archive cases print `SKIP <n> - <reason>`, which
# scripts/docs-claims-check.sh adds back so the assertion total is the same on every machine.
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 git checkout dev-phase-archive -- skills/build                       -> 1 FAIL
#   M2 remove the "skill deploy" line from docs/removed-items.txt            -> 1 FAIL (count)
#   M3 re-add a "community" SessionStart entry to hooks/hooks.json           -> 1 FAIL
#   M4 re-add the PreToolUse focus-check.sh entry to hooks/hooks.json        -> 1 FAIL
#   M5 typo in the list: "skill deploy" -> "skill depoly"                    -> 1 FAIL (archive)
#   M6 an invented extra line "file docs/nonexistent-extra.md"               -> 2 FAIL (count, archive)
#   M7 drop the "hook community" line                                        -> 1 FAIL (count)
#   M8 drop the "file project-templates/design/" line                        -> 1 FAIL (count)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT" || exit 2
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

LIST=docs/removed-items.txt
TAG=dev-phase-archive
[ -f "$LIST" ] || { bad "$LIST is missing"; exit 1; }

have_tag=0
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null 2>&1 && have_tag=1

# at_archive <path>: the path (file or directory) existed at the archive tag
at_archive() { git cat-file -e "$TAG:${1%/}" 2>/dev/null; }

n_skill=0; n_agent=0; n_script=0; n_file=0; n_hook=0; skipped=0
while read -r kind name extra; do
  case "$kind" in ''|'#'*) continue ;; esac
  case "$kind" in
    skill)  path="skills/$name/"; n_skill=$((n_skill + 1)) ;;
    agent)  path="agents/$name.md"; n_agent=$((n_agent + 1)) ;;
    script) path="scripts/$name"; n_script=$((n_script + 1)) ;;
    file)   path="$name"; n_file=$((n_file + 1)) ;;
    hook)   n_hook=$((n_hook + 1))
            if [ "$have_tag" -eq 1 ]; then
              if git show "$TAG:hooks/hooks.json" 2>/dev/null | grep -q -- "$name"; then ok "existed at $TAG: hook $name"
              else bad "hook $name was not in hooks/hooks.json at $TAG"; fi
            else skipped=$((skipped + 1)); fi
            continue ;;
    *)      bad "unknown kind '$kind' in $LIST"; continue ;;
  esac
  if [ -n "$(git ls-files -- "$path")" ] || [ -e "$path" ]; then bad "still present: $kind $name"
  else ok "gone: $kind $name"; fi
  if [ "$have_tag" -eq 1 ]; then
    if at_archive "$path"; then ok "existed at $TAG: $kind $name"
    else bad "not at $TAG (typo or invented item): $kind $name"; fi
  else skipped=$((skipped + 1)); fi
done < "$LIST"

[ "$skipped" -eq 0 ] || echo "SKIP $skipped - tag $TAG is absent here, so existence at the archive was not checked"

[ "$n_skill" -eq 20 ] && ok "20 skills listed" || bad "expected 20 skills listed, found $n_skill"
[ "$n_agent" -eq 7 ] && ok "7 agents listed" || bad "expected 7 agents listed, found $n_agent"
[ "$n_script" -eq 4 ] && ok "4 scripts listed" || bad "expected 4 scripts listed, found $n_script"
[ "$n_file" -eq 7 ] && ok "7 files listed" || bad "expected 7 files listed, found $n_file"
[ "$n_hook" -eq 2 ] && ok "2 hooks listed" || bad "expected 2 hooks listed, found $n_hook"

while read -r kind name extra; do
  [ "$kind" = hook ] || continue
  if grep -q -- "$name" hooks/hooks.json; then bad "hooks/hooks.json still carries: $name"
  else ok "hooks/hooks.json has no $name entry"; fi
done < "$LIST"

if grep -qx 'docs/removed-items.txt' docs/internal-paths.txt; then ok "the list is classified internal"
else bad "docs/removed-items.txt is not in docs/internal-paths.txt"; fi

exit "$fail"
