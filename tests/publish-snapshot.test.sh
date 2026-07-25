#!/usr/bin/env bash
# Tests for bin/publish-snapshot.sh: the clean-snapshot builder (the real publish path).
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/publish-snapshot.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_true() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
repo="$TMP/repo"; mkdir -p "$repo"; git init -q "$repo"

deny="$TMP/deny.txt"; printf '.claude/\ndocs/plans/\ndocs/evals/\n' > "$deny"
allow="$TMP/allow.txt"; printf 'README.md\nskills/\ndocs/checklists/review-calibration.md\n' > "$allow"

build() { ( cd "$repo" && CLAUDE_INTERNAL_PATHS="$deny" CLAUDE_PUBLIC_PATHS="$allow" "$SCRIPT" ) ; }

# Seed a tree with public AND internal files, all committed.
(
  cd "$repo"
  mkdir -p skills/x docs/checklists docs/plans docs/evals .claude/tasks
  echo pub > README.md
  echo skill > skills/x/SKILL.md
  echo cal > docs/checklists/review-calibration.md
  echo plan > docs/plans/p.md
  echo eval > docs/evals/e.md
  echo todo > .claude/tasks/todo.md
  git add -A && git commit -q -m seed
)
clean_head="$(cd "$repo" && git rev-parse HEAD)"

# 1) clean build -> exit 0; snapshot HAS public, LACKS internal
snap="$(build 2>/dev/null)"; rc=$?
assert_exit "clean build -> 0" 0 "$rc"
assert_true "snapshot has README.md" "[ -f \"$snap/README.md\" ]"
assert_true "snapshot has review-calibration.md" "[ -f \"$snap/docs/checklists/review-calibration.md\" ]"
assert_true "snapshot LACKS docs/plans" "[ ! -e \"$snap/docs/plans\" ]"
assert_true "snapshot LACKS docs/evals" "[ ! -e \"$snap/docs/evals\" ]"
assert_true "snapshot LACKS .claude" "[ ! -e \"$snap/.claude\" ]"

# 3) re-run over the same clean HEAD -> exit 0 (fresh temp dir)
snap2="$(build 2>/dev/null)"; rc=$?
assert_exit "re-run clean -> 0" 0 "$rc"
assert_true "second snapshot is a different dir" "[ \"$snap\" != \"$snap2\" ]"

# 2) a private datum in a public file -> exit 3 (advisory), snapshot KEPT
( cd "$repo" && printf 'contact alice@corp.example see /Users/alice/x.txt\n' >> README.md && git add README.md && git commit -q -m secret )
snap3="$(build 2>/dev/null)"; rc=$?
assert_exit "privacy finding -> 3 (advisory)" 3 "$rc"
assert_true "snapshot KEPT for review" "[ -d \"$snap3\" ]"
( cd "$repo" && git reset --hard "$clean_head" >/dev/null 2>&1 )

# 4) a NEW committed-but-unclassified dir (fail-closed) -> exit 1, no publishable snapshot
( cd "$repo" && mkdir -p docs/postmortems && echo pm > docs/postmortems/p.md && git add -A && git commit -q -m postmortem )
snap4="$(build 2>/dev/null)"; rc=$?
assert_exit "unclassified dir -> 1 (fail-closed)" 1 "$rc"
assert_true "no publishable snapshot emitted" "[ -z \"$snap4\" ] || [ ! -d \"$snap4\" ]"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
