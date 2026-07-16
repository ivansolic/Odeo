#!/usr/bin/env bash
#
# spec-gate.sh, the /build entry gate for spec artifacts (enforced guardrail).
#
# A story or PRD may enter the build ONLY with a fresh, passing eval record:
#   1. the artifact file exists and has NO uncommitted changes
#   2. a record in docs/evals/ covers it (frontmatter `artifact:` or `covers:`
#      names its PRD-NNN / USR-NNN / RES-NNN id, exact token match)
#   3. that record's frontmatter verdict approves (PASS / APPROVE family)
#   4. the record is NEWER than the artifact's last commit, edit the spec and
#      the old review no longer counts; re-run pm-reviewer to pass again
#
# This walls the review loop's exit: fix -> re-review is the only way through.
# The verdict parsing contract matches merge-gate.sh (frontmatter only, exact
# vocabulary, deny by default).
#
# Usage:   spec-gate.sh <artifact.md> [more artifacts...]
# Exit:    0 all artifacts covered · 1 refused (reasons printed) · 2 usage error
# Used by: /build (ENFORCED step 0, before the mode question).

set -uo pipefail

[[ $# -ge 1 ]] || { echo "Usage: spec-gate.sh <artifact.md> [...]" >&2; exit 2; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "spec-gate: not a git repository" >&2; exit 2; }

# Resolve arguments to absolute paths BEFORE anchoring at the repo root
ARTIFACTS=()
for p in "$@"; do
  if [[ -f "$p" ]]; then
    ARTIFACTS+=("$(cd "$(dirname "$p")" && pwd)/$(basename "$p")")
  else
    echo "spec-gate: artifact not found: $p" >&2; exit 2
  fi
done
cd "$(git rev-parse --show-toplevel)"

frontmatter_verdict() { # frontmatter_verdict <record-file> -> prints normalized verdict
  local v
  v="$(awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    /^verdict:/ { sub(/^verdict:[[:space:]]*/, ""); print; exit }
  ' "$1")"
  v="$(printf '%s' "$v" | tr '[:lower:]' '[:upper:]' | tr -d '\r')"
  v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

fail=0
for abs in "${ARTIFACTS[@]}"; do
  rel="${abs#"$(pwd)"/}"
  base="$(basename "$rel" .md)"

  # The id token: PRD-NNN / USR-NNN / RES-NNN prefix, else the full basename
  if [[ "$base" =~ ^((PRD|USR|RES)-[0-9]+) ]]; then id="${BASH_REMATCH[1]}"; else id="$base"; fi

  # 1. No uncommitted edits, an unreviewed change must not ride an old PASS
  if [[ -n "$(git status --porcelain -- "$rel")" ]]; then
    echo "spec-gate: REFUSED, $rel has uncommitted changes. Commit them and re-run the reviewer." >&2
    fail=1; continue
  fi

  # 2. A record covers this id (exact token on an artifact:/covers: line;
  #    the [^0-9-] tail stops USR-001 from matching inside USR-001-008)
  records="$(grep -rlE "^(artifact|covers):.*${id}([^0-9-]|$)" docs/evals/ 2>/dev/null || true)"
  if [[ -z "$records" ]]; then
    echo "spec-gate: REFUSED, no eval record in docs/evals/ covers '$id'." >&2
    echo "Run pm-reviewer on the artifact first (review = eval record with artifact:/covers:)." >&2
    fail=1; continue
  fi

  # newest matching record by git commit time
  record=""; rec_time=0
  while IFS= read -r r; do
    t="$(git log -1 --format=%ct -- "$r" 2>/dev/null || echo 0)"
    [[ "$t" -gt "$rec_time" ]] && { rec_time="$t"; record="$r"; }
  done <<< "$records"

  # 3. Verdict must approve (deny by default)
  verdict="$(frontmatter_verdict "$record")"
  case "$verdict" in
    APPROVE|"APPROVE WITH COMMENTS"|PASS) : ;;
    "")
      echo "spec-gate: REFUSED, record for '$id' has no frontmatter verdict ($record)." >&2
      fail=1; continue ;;
    *)
      echo "spec-gate: REFUSED, latest review for '$id' did not pass (verdict: $verdict, $record)." >&2
      echo "Fix the named gaps and re-run pm-reviewer, the record regenerates, never edit it by hand." >&2
      fail=1; continue ;;
  esac

  # 4. Freshness: the review must postdate the artifact's last change
  art_time="$(git log -1 --format=%ct -- "$rel" 2>/dev/null || echo 0)"
  if [[ "$rec_time" -lt "$art_time" ]]; then
    echo "spec-gate: REFUSED, '$id' changed AFTER its review ($record is older than $rel)." >&2
    echo "Re-run pm-reviewer so the record covers what you are about to build." >&2
    fail=1; continue
  fi
done

if [[ $fail -eq 0 ]]; then
  echo "spec-gate: all artifacts carry a fresh, passing review."
  exit 0
fi
exit 1
