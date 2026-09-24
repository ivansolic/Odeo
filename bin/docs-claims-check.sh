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
# Exit:    0 every claim this run could measure matches (some may be reported UNVERIFIED: this
#            machine could not run the whole suite, so its number is not evidence either way)
#          1 a claim drifted, an expected claim is missing, or a suite failed · 2 usage
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
n_unverified=0

# claim <label> <measured> <regex-with-one-capture> [unverifiable-reason]
# Pulls the DOCUMENTED number out of README with the given pattern and compares it to the
# MEASURED one. A pattern that matches nothing is itself a failure: if a claim disappears
# or is reworded, this check must say "I no longer verify that" rather than quietly verify
# fewer things every release, which is how a green check rots into decoration.
#
# THE FOURTH ARGUMENT EXISTS BECAUSE A MISMATCH IS NOT ALWAYS DRIFT. When this run could not
# measure the claim completely, its number is not evidence about the README in either direction,
# and treating it as evidence was actively harmful: a machine that ran MORE of the suite than
# the author's counted HIGHER, got `DRIFTED` and exit 1, and was then told "Fix the NUMBER in
# the document, never this check" , i.e. instructed to edit a correct README and break it for
# everyone else. The old note bounded the error one way only (it said the count can read LOW),
# which is exactly the asymmetry that made the high reading look like a documentation bug.
# So an incomplete measurement reports UNVERIFIED and does not fail. It is NOT silence: the
# reason is printed, and MISSING stays fatal, because a claim that vanished from the README is
# rot no matter what this machine could run.
claim() {
  local label="$1" measured="$2" re="$3" unverifiable="${4:-}" documented
  documented="$(grep -oE "$re" README.md 2>/dev/null | grep -oE '[0-9]+' | head -1)"
  if [[ -z "$documented" ]]; then
    echo "MISSING: README no longer carries a '$label' claim this check knows how to read."
    echo "         Either restore the claim, or delete this check line so the gap is explicit."
    fail=1
    return
  fi
  found_any=1
  if [[ "$documented" == "$measured" ]]; then
    echo "ok: $label = $measured"
  elif [[ -n "$unverifiable" ]]; then
    n_unverified=$((n_unverified+1))
    echo "UNVERIFIED: $label , README says $documented, this run measured $measured"
    echo "            $unverifiable"
    echo "            Not a failure: this machine did not run the whole suite, so its number"
    echo "            is not evidence about the README. Do not edit either one from this run."
  else
    echo "DRIFTED: $label , README says $documented, the tree has $measured"
    fail=1
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
  n_skipped=0
  # THE SUITE'S EXIT CODE IS READ, not only its output. It used to be discarded, which was
  # survivable only by accident: a broken suite reported a wrong total, the total mismatched,
  # and the run went red for the wrong reason. The unverified outcome removed that accident and
  # left the worst case green, measured: a suite that ERRORS reports fewer `ok` lines, the
  # mismatch is excused as unverified, and a machine that skips anything (here, every machine)
  # ends at exit 0 under the summary line. A broken instrument must never read as a clean bill,
  # and it is not an environment difference, so no skip excuses it.
  for f in tests/*.test.sh; do
    out=$(bash "$f" 2>&1); rc=$?
    n=$(printf '%s\n' "$out" | grep -cE '^ok')
    s=$(printf '%s\n' "$out" | grep -cE '^SKIP')
    total=$((total+n))
    n_skipped=$((n_skipped+s))
    if [[ "$rc" -ne 0 ]]; then
      echo "SUITE FAILED: $f exited $rc, so the assertion count below is not a measurement."
      fail=1
    fi
  done
  # A suite may SKIP checks, so this total is environment-dependent in a way the other claims
  # are not. Saying so turns a confusing "the README drifted" into "this machine ran fewer
  # assertions", which are opposite problems: one needs the document fixed, the other needs a
  # different machine or shell.
  # The note names CAUSES, plural, and only causes that occur. Measured reasons a suite skips
  # here: the case cannot run as the current user (six root guards in ledger-backup.test.sh,
  # where an unreadable file is readable anyway), or the shell refuses what the case needs
  # (bash 3.2 makes SHELLOPTS readonly). It once named only a missing optional tool (pwsh, for
  # the since-removed install.ps1 suite), which made it FALSE on an ordinary run: a note that
  # names a cause that does not apply sends the reader to install a tool that was never missing.
  # Counted in SKIP LINES, not assertions: a suite reports one line per skipped case, so this
  # says how much went unverified, never how much the total is short by. Which is also why the
  # error runs in BOTH directions and the claim below is not failed when there is any skip at
  # all: a skipped case holds an unknown number of assertions, so a machine that runs it counts
  # HIGHER than the README, not lower.
  skip_reason=""
  if [[ "$n_skipped" -gt 0 ]]; then
    skip_reason="$n_skipped check(s) were SKIPPED here (the case cannot run as this user, or this shell refuses what it needs)."
    echo "note: $n_skipped check(s) were SKIPPED here (the case cannot run as this user, or"
    echo "      this shell refuses what it needs), so the count"
    echo "      below can read LOW or HIGH on this machine without the README being wrong."
  fi
  claim "assertions" "$total" '[0-9]+ assertions' "$skip_reason"
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
# THE SUMMARY MUST NOT OUTLIVE THE RUN IT SUMMARISES. "every countable claim matches the tree"
# printed above an UNVERIFIED line is precisely the kind of stale claim this program exists to
# catch, made by this program, at the place a reader looks when they stop reading.
if [[ "$n_unverified" -gt 0 ]]; then
  echo "docs-claims-check: every claim this run could measure matches; $n_unverified UNVERIFIED (see above)."
else
  echo "docs-claims-check: every countable claim matches the tree."
fi
exit 0
