#!/usr/bin/env bash
# coverage-check.sh, deterministic PRD-requirement coverage gate.
#
# Verifies that every requirement ID (R1..Rn) DEFINED in a PRD's Requirements
# section is claimed by at least one story's `covers:` frontmatter field. Exits 1
# if any requirement is uncovered. Machine-read and language-independent: it keys
# off requirement IDs and the `covers:` field, never on prose, so it works
# whatever language the artifacts are written in.
#
# usage: coverage-check.sh <prd-file> <stories-dir>
set -euo pipefail

usage() { echo "usage: coverage-check.sh <prd-file> <stories-dir>" >&2; exit 2; }
[ "$#" -eq 2 ] || usage
PRD="$1"; STORIES="$2"
[ -f "$PRD" ] || { echo "coverage-check: PRD not found: $PRD" >&2; exit 2; }
[ -d "$STORIES" ] || { echo "coverage-check: stories dir not found: $STORIES" >&2; exit 2; }

prd_id="$(grep -m1 -E '^id:[[:space:]]*' "$PRD" | sed -E 's/^id:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\r' || true)"
[ -n "$prd_id" ] || { echo "coverage-check: no 'id:' frontmatter in $PRD" >&2; exit 2; }

# Requirement IDs are recognised language-independently: a requirement is a LIST
# ITEM whose bold token is R<n> (e.g. "- **R1 , ...", the form /odeo:prd emits). Inline
# or prose references like "see R6" or "as in **R2**" are not list-item bold
# definitions, so they are not miscounted. Keying off the R<n> token, not the
# heading language, is what lets this work on non-English PRDs.
req_ids="$(grep -oE '^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]+' "$PRD" | grep -oE 'R[0-9]+' | sort -u || true)"
[ -n "$req_ids" ] || { echo "coverage-check: no requirement definitions ('- **R<n>') found in $PRD" >&2; exit 2; }

# Union of `covers:` IDs from stories whose `prd:` matches this PRD id.
covered="$(
  for f in "$STORIES"/*.md; do
    [ -f "$f" ] || continue
    sprd="$(grep -m1 -E '^prd:[[:space:]]*' "$f" | sed -E 's/^prd:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\r' || true)"
    [ "$sprd" = "$prd_id" ] || continue
    # `covers:` is inline and space-separated on one line (e.g. `covers: R1 R5`);
    # -m1 reads that single line, a multi-line YAML list would under-count.
    grep -m1 -E '^covers:[[:space:]]*' "$f" | grep -oE 'R[0-9]+' || true
  done | sort -u
)"

missing=""
while IFS= read -r r; do
  [ -n "$r" ] || continue
  printf '%s\n' "$covered" | grep -qx "$r" || missing="$missing $r"
done <<EOF
$req_ids
EOF

count="$(printf '%s\n' "$req_ids" | grep -c . || true)"
if [ -n "$missing" ]; then
  echo "COVERAGE FAIL: $prd_id has uncovered requirements:$missing" >&2
  echo "(each requirement needs a story with a matching 'covers:' field)" >&2
  exit 1
fi
echo "coverage: $prd_id, all $count requirements covered"
