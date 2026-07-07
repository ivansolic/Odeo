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

# 3. Review record exists for this branch, EXACT match on the record's
#    "branch:" field (content, not filename), so an unrelated record can't pass.
records="$(grep -rl "^branch: ${branch}\$" docs/evals/ 2>/dev/null || true)"
if [[ -z "$records" ]]; then
  echo "merge-gate: REFUSED, no review record in docs/evals/ carries 'branch: $branch'." >&2
  echo "Run code-reviewer (and design-reviewer if UI) first; review = eval record" >&2
  echo "(records must include a 'branch:' field, see the eval framework)." >&2
  exit 1
fi

# Pick the newest matching record (by git commit time).
record=""; rec_time=0
while IFS= read -r r; do
  t="$(git log -1 --format=%ct -- "$r" 2>/dev/null || echo 0)"
  [[ "$t" -gt "$rec_time" ]] && { rec_time="$t"; record="$r"; }
done <<< "$records"

# 3b. Verdict check: an existing record that requested changes does not pass.
if grep -qiE 'REQUEST CHANGES|(^|[[:space:]])verdict:? *FAIL' "$record"; then
  echo "merge-gate: REFUSED, the latest review for '$branch' did not approve" >&2
  echo "($record). Fix the findings and re-run the reviewer." >&2
  exit 1
fi

# 3c. Freshness: the review must be newer than the last CODE commit, a review
#     of older code does not cover what you are merging now.
last_code="$(git log -1 --format=%ct -- . ":(exclude)docs/evals" 2>/dev/null || echo 0)"
if [[ "$rec_time" -lt "$last_code" ]]; then
  echo "merge-gate: REFUSED, the review record is OLDER than the last code change." >&2
  echo "The code moved after the review; re-run the reviewer so it covers what merges." >&2
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
