#!/usr/bin/env bash
# docs-claims-check.sh, the anchor against MEASUREMENT DECAY (advisory-by-default gate).
#
# Documents drift from the system they describe, silently, because nothing re-derives
# their claims. Measured in this repo: the README claimed "31 assertions" when there were
# 818, and listed 6 of 21 bin scripts while reading as an exhaustive tree. Each was caught
# by a human happening to look, which is not a mechanism.
#
# This re-derives the COUNTABLE claims from the tree and fails when a document disagrees.
# Scope is deliberately narrow and stated rather than implied: it checks numbers, never
# judgment. "The design layer is optional" is prose no script can verify; "22 executables"
# is not. A checker that pretended to verify meaning would be the more dangerous thing,
# because a green result would stop anyone from reading.
#
# Usage:   docs-claims-check.sh [--assertions]   (run from the repo root)
#          --assertions also runs the full suite to verify the assertion count. It is
#          off by default because it takes minutes, and a slow gate gets skipped.
# Exit:    0 every claim matches · 1 a claim drifted, or an expected claim is missing · 2 usage
set -uo pipefail
LC_ALL=C; export LC_ALL

WITH_ASSERTIONS=0
for a in "$@"; do
  case "$a" in
    --assertions) WITH_ASSERTIONS=1 ;;
    *) echo "usage: docs-claims-check.sh [--assertions]" >&2; exit 2 ;;
  esac
done

[[ -f README.md ]] || { echo "docs-claims-check: run from the repo root (no README.md here)" >&2; exit 2; }

fail=0
found_any=0

# claim <label> <measured> <regex-with-one-capture>
# Pulls the DOCUMENTED number out of README with the given pattern and compares it to the
# MEASURED one. A pattern that matches nothing is itself a failure: if a claim disappears
# or is reworded, this check must say "I no longer verify that" rather than quietly verify
# fewer things every release, which is how a green check rots into decoration.
claim() {
  local label="$1" measured="$2" re="$3" documented
  documented="$(grep -oE "$re" README.md 2>/dev/null | grep -oE '[0-9]+' | head -1)"
  if [[ -z "$documented" ]]; then
    echo "MISSING: README no longer carries a '$label' claim this check knows how to read."
    echo "         Either restore the claim, or delete this check line so the gap is explicit."
    fail=1
    return
  fi
  found_any=1
  if [[ "$documented" != "$measured" ]]; then
    echo "DRIFTED: $label , README says $documented, the tree has $measured"
    fail=1
  else
    echo "ok: $label = $measured"
  fi
}

# --- the measurements, each derived from the tree, never hardcoded -------------------
n_exec=0
for f in bin/*; do [[ -f "$f" ]] && n_exec=$((n_exec+1)); done
n_agents=$(ls agents/*.md 2>/dev/null | wc -l | tr -d ' ')
n_suites=$(ls tests/*.test.sh 2>/dev/null | wc -l | tr -d ' ')

claim "bin executables" "$n_exec"   '← [0-9]+ executables'
claim "test suites"     "$n_suites" '← [0-9]+ suites'

# Programs with their own suite: the README states this as "N of the M programs", and it
# is the claim most likely to rot, because adding either a program or a suite moves it.
n_have=0
for p in bin/*; do
  b=$(basename "$p"); b="${b%.sh}"; b="${b%.py}"
  ls tests/"$b"*.test.sh >/dev/null 2>&1 && n_have=$((n_have+1))
done
claim "programs with their own suite" "$n_have" '[0-9]+ of the [0-9]+ programs'

if [[ "$WITH_ASSERTIONS" -eq 1 ]]; then
  total=0
  for f in tests/*.test.sh; do
    n=$(bash "$f" 2>&1 | grep -cE '^ok')
    total=$((total+n))
  done
  claim "assertions" "$total" '[0-9]+ assertions'
else
  echo "skipped: assertion count (re-run with --assertions; it runs every suite)"
fi

if [[ "$found_any" -eq 0 ]]; then
  echo "docs-claims-check: REFUSED, not one known claim was found in README.md." >&2
  echo "Either the document was gutted or every pattern here is stale; both need a human." >&2
  exit 1
fi

if [[ "$fail" -ne 0 ]]; then
  echo ""
  echo "docs-claims-check: a documented claim no longer matches the tree." >&2
  echo "Fix the NUMBER in the document, never this check, unless the check is what is wrong." >&2
  exit 1
fi
echo ""
echo "docs-claims-check: every countable claim matches the tree."
exit 0
