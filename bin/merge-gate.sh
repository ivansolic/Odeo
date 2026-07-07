#!/usr/bin/env bash
#
# merge-gate.sh, the deterministic /merge gate (enforced guardrail).
#
# Refuses the merge path unless the mechanical preconditions hold:
#   1. not on main/master (integration happens from a story branch)
#   2. clean working tree (no uncommitted work sneaks into a merge)
#   3. a review record exists for this branch in docs/evals/ (review happened)
#   4. do-not-touch boundaries respected (delegates to boundary-check.sh if present)
#
# It cannot verify judgment (was the review GOOD?), that stays with the reviewers
# and the human gate. It verifies existence, deterministically.
#
# Usage:   merge-gate.sh [base-ref]      (default: main)
# Exit:    0 all preconditions hold · 1 refused (reason printed) · 2 usage error
# Used by: /merge (must run this and stop on non-zero before any rebase/merge).

set -uo pipefail

BASE_REF="${1:-main}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "merge-gate: not a git repository" >&2; exit 2; }

branch="$(git rev-parse --abbrev-ref HEAD)"

# 1. Not on main
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  echo "merge-gate: REFUSED, you are on '$branch'. Merges run from the story branch." >&2
  exit 1
fi

# 2. Clean working tree
if [[ -n "$(git status --porcelain)" ]]; then
  echo "merge-gate: REFUSED, uncommitted changes present. Commit or stash first." >&2
  exit 1
fi

# 3. Review record exists for this branch (slug match in docs/evals/)
slug="$(printf '%s' "$branch" | tr '/' '-' )"
short="${branch##*/}"
record="$(ls docs/evals/ 2>/dev/null | grep -iE "(${slug}|${short})" || true)"
if [[ -z "$record" ]]; then
  echo "merge-gate: REFUSED, no review record found in docs/evals/ for '$branch'." >&2
  echo "Run code-reviewer (and design-reviewer if UI) first; review = eval record." >&2
  exit 1
fi

# 4. Boundaries (if the checker and a map exist)
checker="$(command -v boundary-check.sh || true)"
[[ -z "$checker" && -x "bin/boundary-check.sh" ]] && checker="bin/boundary-check.sh"
[[ -z "$checker" && -x "$HOME/bin/boundary-check.sh" ]] && checker="$HOME/bin/boundary-check.sh"
if [[ -n "$checker" ]]; then
  if ! "$checker" "$BASE_REF"; then
    echo "merge-gate: REFUSED, do-not-touch boundary violated (see above)." >&2
    exit 1
  fi
fi

echo "merge-gate: preconditions hold (branch '$branch', record: $(printf '%s' "$record" | head -1))."
exit 0
