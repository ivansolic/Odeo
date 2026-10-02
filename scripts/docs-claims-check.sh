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
# Exit:    0 every claim matches (a skipped case's assertions are added back from its
#            `SKIP <n>` line, so the count is the same on every machine)
#          1 a claim drifted, an expected claim is missing, a suite failed, or a suite printed
#            a skip line without a count · 2 usage
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
claim_fail=0      # a claim DRIFTED or went MISSING: the document (or this check) needs fixing
suite_fail=0      # a suite exited non-zero: the suite needs fixing, the README may be right
skip_fail=0       # a suite skipped without a count: the suite needs fixing, same reason
found_any=0

# claim <label> <measured> <regex-with-one-capture> [unverifiable-reason]
# Pulls the DOCUMENTED number out of README with the given pattern and compares it to the
# MEASURED one. A pattern that matches nothing is itself a failure: if a claim disappears
# or is reworded, this check must say "I no longer verify that" rather than quietly verify
# fewer things every release, which is how a green check rots into decoration.
#
# THE FOURTH ARGUMENT marks a number that is no measurement: the assertion total of a run in
# which a suite failed or skipped without a count. It is printed as UNVERIFIED rather than
# judged, so a correct README is never called drifted; the run is already red through the
# failing suite, so this never lets a run pass. (It once also excused any run that skipped a
# case, which let real drift through; skipped cases now declare their count instead.) MISSING
# stays fatal, because a claim that vanished from the README is rot whatever this run measured.
claim() {
  local label="$1" measured="$2" re="$3" unverifiable="${4:-}" documented
  documented="$(grep -oE "$re" README.md 2>/dev/null | grep -oE '[0-9]+' | head -1)"
  if [[ -z "$documented" ]]; then
    echo "MISSING: README no longer carries a '$label' claim this check knows how to read."
    echo "         Either restore the claim, or delete this check line so the gap is explicit."
    fail=1; claim_fail=1
    return
  fi
  found_any=1
  if [[ "$documented" == "$measured" ]]; then
    echo "ok: $label = $measured"
  elif [[ -n "$unverifiable" ]]; then
    echo "UNVERIFIED: $label , README says $documented, this run measured $measured"
    echo "            $unverifiable"
    echo "            Not judged: this run did not measure it completely, so its number is not"
    echo "            evidence about the README. Do not edit either one from this run."
  else
    echo "DRIFTED: $label , README says $documented, the tree has $measured"
    fail=1; claim_fail=1
  fi
}

# --- the measurements, each derived from the tree, never hardcoded -------------------
n_exec=0
for f in scripts/*; do [[ -f "$f" ]] && n_exec=$((n_exec+1)); done
n_agents=$(ls agents/*.md 2>/dev/null | wc -l | tr -d ' ')
n_suites=$(ls tests/*.test.sh 2>/dev/null | wc -l | tr -d ' ')

claim "scripts programs" "$n_exec"   '← [0-9]+ executables'
claim "test suites"     "$n_suites" '← [0-9]+ suites'

# Programs with their own suite: the README states this as "N of the M programs", and it
# is the claim most likely to rot, because adding either a program or a suite moves it.
n_have=0
for p in scripts/*; do
  b=$(basename "$p"); b="${b%.sh}"; b="${b%.py}"
  ls tests/"$b"*.test.sh >/dev/null 2>&1 && n_have=$((n_have+1))
done
claim "programs with their own suite" "$n_have" '[0-9]+ of the [0-9]+ programs'

if [[ "$WITH_ASSERTIONS" -eq 1 ]]; then
  total=0
  skipped_cases=0; skipped_asserts=0; skip_lines=""
  # THE SUITE'S EXIT CODE IS READ, not only its output. It used to be discarded, which was
  # survivable only by accident: a broken suite reported a wrong total, the total mismatched,
  # and the run went red for the wrong reason. A broken instrument must never read as a clean
  # bill, and it is not an environment difference, so nothing excuses it.
  # STDIN IS /dev/null. Run in the background with stdin left open, a suite that read from it
  # waited forever and the whole check was killed at a 30-minute limit with no output.
  for f in tests/*.test.sh; do
    out=$(bash "$f" 2>&1 </dev/null); rc=$?
    n=$(printf '%s\n' "$out" | grep -cE '^ok')
    total=$((total+n))
    if [[ "$rc" -ne 0 ]]; then
      echo "SUITE FAILED: $f exited $rc, so the assertion count below is not a measurement."
      fail=1; suite_fail=$((suite_fail+1))
    fi
    # A SKIPPED CASE IS ADDED BACK. A suite that cannot run a case prints `SKIP <n> - <reason>`,
    # n being the assertions the case makes when it runs, so ok + n is the same on every
    # machine and the README carries one number. A SKIP without a count would make the total
    # depend on the machine again, so it is a broken suite, not an excuse. Any casing of "skip"
    # is read, so `skip -` or `skip:` is refused as uncounted instead of vanishing from the
    # total. n starts at 1: a 0 skips nothing, and a leading zero is octal to bash 3.2 arithmetic.
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      if [[ "$line" =~ ^SKIP\ ([1-9][0-9]*)\ -\  ]]; then
        skipped_cases=$((skipped_cases+1)); skipped_asserts=$((skipped_asserts+BASH_REMATCH[1]))
        skip_lines="$skip_lines      $f: $line"$'\n'
      else
        echo "UNCOUNTED SKIP: $f prints a skip line without a valid count ('$line'); write SKIP <n> - <reason>."
        fail=1; skip_fail=$((skip_fail+1))
      fi
    done <<< "$(printf '%s\n' "$out" | grep -iE '^skip')"
  done
  # The note shows what was added back and WHY, in the suites' own words: a fixed list of causes
  # once named one that did not apply and sent the reader to install a tool that was never
  # missing, so the reasons are quoted, never summarised here.
  if [[ "$skipped_cases" -gt 0 ]]; then
    echo "note: $skipped_asserts assertion(s) in $skipped_cases skipped case(s) were added back:"
    printf '%s' "$skip_lines"
  fi
  total=$((total+skipped_asserts))
  # A FAILED SUITE, OR A SKIP WITHOUT A COUNT, MAKES THE TOTAL NO MEASUREMENT. Either one leaves
  # assertions out of the total, so judging it would call a correct README drifted and bury the
  # suite's own remedy under "Fix the NUMBER". The run stays red through the suite (fail=1
  # above); only the number is withheld.
  count_reason=""
  if [[ "$suite_fail" -gt 0 || "$skip_fail" -gt 0 ]]; then
    count_reason="a suite failed or skipped without a count, so this total is not a measurement."
  fi
  claim "assertions" "$total" '[0-9]+ assertions' "$count_reason"
else
  echo "skipped: assertion count (re-run with --assertions; it runs every suite)"
fi

if [[ "$found_any" -eq 0 ]]; then
  echo "docs-claims-check: REFUSED, not one known claim was found in README.md." >&2
  echo "Either the document was gutted or every pattern here is stale; both need a human." >&2
  exit 1
fi

# The footer names the cause that actually occurred. A broken suite with a correct README used
# to end on "Fix the NUMBER in the document", sending the reader to edit the one file that was
# right; each cause now gets its own remedy, and both print when both occurred.
if [[ "$fail" -ne 0 ]]; then
  echo ""
  if [[ "$suite_fail" -gt 0 ]]; then
    echo "docs-claims-check: $suite_fail suite(s) exited non-zero, so fix the suite, not the document." >&2
  fi
  if [[ "$skip_fail" -gt 0 ]]; then
    echo "docs-claims-check: $skip_fail skip line(s) carry no count, so fix the suite, not the document." >&2
  fi
  if [[ "$claim_fail" -ne 0 ]]; then
    echo "docs-claims-check: a documented claim no longer matches the tree." >&2
    echo "Fix the NUMBER in the document, never this check, unless the check is what is wrong." >&2
  fi
  exit 1
fi
echo ""
# Reaching this line means every claim was measured: an UNVERIFIED claim arises only with a
# failed suite, and that exits 1 above, so the summary has one form.
echo "docs-claims-check: every countable claim matches the tree."
exit 0
