#!/usr/bin/env bash
# The published list of removed scripts (scripts/odeo-removed-scripts.txt) agrees with the
# maintainer's own record of the cut, the `script` lines of docs/removed-items.txt, and the
# git hooks this repository writes for itself never name a removed script (PRD-002 R8, USR-010).
#
# Maintainer tooling, not a shipped suite: docs/removed-items.txt is internal and absent from
# the published repository, so the list comparison prints `SKIP <n> - <reason>` there. The shape
# of the list itself is tested by tests/odeo-removed-scripts.test.sh, which does run everywhere.
#
# The maintainer-hook case lives here and not in tests/odeo-context.test.sh because the
# maintainer installer (.claude/maintainer/install-git-guards.sh) is repo-only: it writes the
# pre-push guard this repository keeps, and the session-start check must not call that hook a
# stale one just because it is not an Odeo installer's pre-commit.
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 a name removed from scripts/odeo-removed-scripts.txt                 -> 1 FAIL (list differs)
#   M2 a name added to scripts/odeo-removed-scripts.txt only                -> 1 FAIL (list differs)
#   M3 a `script` line added to docs/removed-items.txt only                 -> 1 FAIL (list differs)
#   M4 a removed name written into the maintainer installer's pre-push text -> 1 FAIL (named)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT" || exit 2
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

LIST=scripts/odeo-removed-scripts.txt
RECORD=docs/removed-items.txt

[ -f "$LIST" ] || { bad "$LIST is missing"; exit 1; }

if [ -f "$RECORD" ]; then
  from_record="$(awk '$1 == "script" { print $2 }' "$RECORD" | LC_ALL=C sort)"
  from_list="$(grep -vE '^#|^$' "$LIST" | LC_ALL=C sort)"
  if [ -n "$from_record" ] && [ "$from_record" = "$from_list" ]; then
    ok "the published list equals the script lines of $RECORD"
  else
    bad "the published list differs from the script lines of $RECORD"
    diff <(printf '%s\n' "$from_record") <(printf '%s\n' "$from_list") | sed 's/^/      /'
  fi
else
  echo "SKIP 1 - $RECORD is internal and absent here, so the list was not compared with the record"
fi

# The hooks this repository writes for itself: the session-start check reads every
# pre-commit/pre-push for a removed name, so a maintainer-written hook that carried one would
# be called stale in this very repository.
HOOK="$ROOT/hooks/odeo-context.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
home="$TMP/home"; mkdir -p "$home/.claude"
repo="$TMP/repo"; git init -q "$repo"
( cd "$repo" && HOME="$home" bash "$ROOT/.claude/maintainer/install-git-guards.sh" >/dev/null 2>&1 )
[ -x "$repo/.git/hooks/pre-push" ] && [ -x "$repo/.git/hooks/pre-commit" ] \
  && ok "instrument: the maintainer installer wrote both hooks into the fixture" \
  || bad "instrument: the maintainer installer did not write both hooks, so the case below tests nothing"
named=""
while IFS= read -r n; do
  [ -n "$n" ] || continue
  for h in pre-commit pre-push; do
    grep -aq -- "$n" "$repo/.git/hooks/$h" 2>/dev/null && named="$named $h:$n"
  done
done <<< "$(grep -vE '^#|^$' "$LIST")"
[ -z "$named" ] && ok "the maintainer-written hooks name no removed script" || bad "maintainer-written hooks name a removed script:$named"
out="$(CLAUDE_PROJECT_DIR="$repo" GIT_CEILING_DIRECTORIES="$TMP" HOME="$home" "$HOOK" legacy SessionStart 2>/dev/null)"
[ -z "$out" ] && ok "session start says nothing about this repository's own hooks" || bad "session start named the maintainer-written hooks: $out"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
