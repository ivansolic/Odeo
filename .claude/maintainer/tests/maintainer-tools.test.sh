#!/usr/bin/env bash
# The maintainer's own tools (merge gate, boundary check, code reviewer, merge command) are
# repo-only: tracked under .claude/, classified internal by the REAL publish lists, and no
# longer tracked at a path the plugin ships (PRD-002 R6, USR-008). The publish tests use
# fixture lists; this suite reads the repository's own docs/internal-paths.txt and
# docs/public-paths.txt, so a tool left at a shipping path is caught here.
#
# Mutation recipe (each mutant must go RED, then restore):
#   M1 git mv .claude/maintainer/merge-gate.sh scripts/merge-gate.sh      -> 2 FAIL
#   M2 remove the ".claude/" line from docs/internal-paths.txt            -> 6 FAIL
#   M3 git mv .claude/agents/code-reviewer.md agents/code-reviewer.md     -> 2 FAIL
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT" || exit 2
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# matches <path> <list-file>: the lists' rules (a line ending in "/" is a directory prefix,
# any other line is an exact path; "#" lines and blank lines are ignored).
matches() {
  local p="$1" f="$2" line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    case "$line" in
      */) case "$p" in "$line"*) return 0 ;; esac ;;
      *) [ "$p" = "$line" ] && return 0 ;;
    esac
  done < "$f"
  return 1
}

# New home of each tool, and the path it used to ship from.
NEW=(.claude/maintainer/merge-gate.sh .claude/maintainer/boundary-check.sh
     .claude/maintainer/tests/merge-gate.test.sh .claude/maintainer/tests/boundary-check.test.sh
     .claude/agents/code-reviewer.md .claude/skills/merge/SKILL.md)
OLD=(scripts/merge-gate.sh scripts/boundary-check.sh tests/merge-gate.test.sh
     tests/boundary-check.test.sh agents/code-reviewer.md skills/merge/SKILL.md)

for p in "${NEW[@]}"; do
  if git ls-files --error-unmatch -- "$p" >/dev/null 2>&1; then ok "tracked at its repo-only path: $p"
  else bad "not tracked at its repo-only path: $p"; fi
  if matches "$p" docs/internal-paths.txt; then ok "classified internal: $p"
  else bad "not classified internal by docs/internal-paths.txt: $p"; fi
  if matches "$p" docs/public-paths.txt; then bad "listed as public: $p"
  else ok "not listed as public: $p"; fi
done

for p in "${OLD[@]}"; do
  if git ls-files --error-unmatch -- "$p" >/dev/null 2>&1; then bad "still tracked at a shipping path: $p"
  else ok "no longer tracked at its shipping path: $p"; fi
done

exit "$fail"
