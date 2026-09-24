#!/usr/bin/env bash
# publish-snapshot.sh: build a clean PUBLIC snapshot of the tracked HEAD tree.
#
# This is the ONLY sanctioned publish path. It materializes tracked HEAD content
# (never history), strips the denylist (docs/internal-paths.txt), then verifies
# fail-closed with publish-guard --require-allowlist:
#   - internal OR unclassified path  -> verification FAILED, snapshot removed, exit 1
#   - privacy finding (advisory)     -> surfaced, snapshot KEPT, exit 3 (human reviews)
#   - clean                          -> prints the snapshot dir on stdout, exit 0
#
# The human sets CLAUDE_PUBLISH_SNAPSHOT=1 to push ONLY after confirming any exit-3
# findings; the pre-push hook (contract A) refuses every other push to the public remote.
#
# usage: publish-snapshot.sh [output-dir]   (output-dir defaults to a fresh mktemp -d)
# exit:  0 clean · 1 verification failed · 2 usage/error · 3 advisory privacy finding
set -uo pipefail
export LC_ALL=C

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "publish-snapshot: not a git repository" >&2; exit 2; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GUARD="$ROOT/bin/publish-guard.sh"
[ -x "$GUARD" ] || { echo "publish-snapshot: publish-guard.sh not found or not executable: $GUARD" >&2; exit 2; }
# The strip and the check must read the SAME lists, and the guard owns the rule for which
# lists apply (the project's, when it carries them), so the strip asks it instead of copying
# the rule: stripping with this script's own lists while the guard checked the project's
# failed every snapshot in a project with its own classification. The guard's later check
# runs from this same directory, so it resolves the same pair on its own.
DENYLIST="$("$GUARD" --print-lists | sed -n 1p)"
[ -f "$DENYLIST" ] || { echo "publish-snapshot: denylist not found: $DENYLIST" >&2; exit 2; }

OUT="${1:-$(mktemp -d)}"
mkdir -p "$OUT"

# Materialize ONLY tracked HEAD content (git archive copies no history).
if ! git archive --format=tar HEAD | ( cd "$OUT" && tar -xf - ); then
  echo "publish-snapshot: git archive/extract failed" >&2
  rm -rf -- "$OUT"; exit 2
fi

# Strip the denylist from the materialized tree (single source of truth).
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  # trim leading/trailing whitespace so a padded entry cannot silently go inert
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  case "$line" in ''|'#'*) continue;; esac
  case "$line" in
    */) rm -rf -- "$OUT/${line%/}" ;;
    *)  rm -f  -- "$OUT/$line" ;;
  esac
done < "$DENYLIST"

# Verify fail-closed: denylist + allowlist are HARD (exit 1); privacy is ADVISORY (exit 3).
guard_out="$("$GUARD" --require-allowlist "$OUT" 2>&1)"; grc=$?
case "$grc" in
  0)
    echo "publish-snapshot: clean snapshot ready." >&2
    printf '%s\n' "$OUT"; exit 0 ;;
  3)
    printf '%s\n' "$guard_out" >&2
    echo "publish-snapshot: the privacy findings above are ADVISORY. Review each (often a doc that documents the patterns); once confirmed generic, set CLAUDE_PUBLISH_SNAPSHOT=1 to publish. Snapshot KEPT at: $OUT" >&2
    printf '%s\n' "$OUT"; exit 3 ;;
  1)
    printf '%s\n' "$guard_out" >&2
    echo "publish-snapshot: verification FAILED (internal or unclassified path present); snapshot removed. Classify the path in docs/internal-paths.txt or docs/public-paths.txt, then retry." >&2
    rm -rf -- "$OUT"; exit 1 ;;
  *)
    printf '%s\n' "$guard_out" >&2
    echo "publish-snapshot: guard error (exit $grc); snapshot removed." >&2
    rm -rf -- "$OUT"; exit 2 ;;
esac
