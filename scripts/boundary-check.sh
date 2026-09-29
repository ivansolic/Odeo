#!/usr/bin/env bash
#
# boundary-check.sh, the DO-NOT-TOUCH gate (enforced guardrail).
#
# Compares this branch's changed files (committed since <base-ref> AND anything
# uncommitted) against the DO-NOT-TOUCH boundaries declared in
# docs/codebase-map.md, and BLOCKS if any boundary path was touched.
#
# Boundary source: lines formatted "- <path>" under a heading containing
# "DO-NOT-TOUCH" in docs/codebase-map.md. No map or no such section = nothing
# to enforce (exit 0 with a note).
#
# Usage:   boundary-check.sh [base-ref]     (default base-ref: main)
# Exit:    0 clean/nothing-to-enforce · 1 boundary touched (BLOCK) · 2 usage error
# Used by: /odeo:build (before presenting a builder's result) and /odeo:merge.

set -uo pipefail

BASE_REF="${1:-main}"
MAP="docs/codebase-map.md"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "boundary-check: not a git repository" >&2
  exit 2
}

if [[ ! -f "$MAP" ]]; then
  echo "boundary-check: no $MAP, nothing to enforce."
  exit 0
fi

# Extract "- path" lines under the DO-NOT-TOUCH heading (until the next heading).
boundaries="$(awk '/^#+ .*DO-NOT-TOUCH/{on=1; next} /^#+ /{on=0} on && /^- /{sub(/^- +/,""); print $1}' "$MAP")"
if [[ -z "$boundaries" ]]; then
  echo "boundary-check: no DO-NOT-TOUCH entries in $MAP, nothing to enforce."
  exit 0
fi

# Changed files: committed vs base + uncommitted (staged and not).
changed="$( { git diff --name-only "$BASE_REF"...HEAD 2>/dev/null; git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only 2>/dev/null; } | sort -u )"
[[ -z "$changed" ]] && { echo "boundary-check: no changes vs $BASE_REF."; exit 0; }

violations=""
while IFS= read -r b; do
  [[ -z "$b" ]] && continue
  hits="$(printf '%s\n' "$changed" | grep -E "^${b}" || true)"
  [[ -n "$hits" ]] && violations+="$b:"$'\n'"$(printf '%s\n' "$hits" | sed 's/^/    /')"$'\n'
done <<< "$boundaries"

if [[ -n "$violations" ]]; then
  {
    echo "BLOCK [do-not-touch]: this branch changes protected paths:"
    printf '%s' "$violations"
    echo "These boundaries come from $MAP (confirmed at onboarding). Route around"
    echo "them, or get an explicit human decision to change the boundary first."
  } >&2
  exit 1
fi

echo "boundary-check: clean, no protected paths touched."
exit 0
