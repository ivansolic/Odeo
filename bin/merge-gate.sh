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
# Deterministic collation: the cutoff comparison sorts ISO dates as strings, and `<`
# inside [[ ]] is locale-collated. Matches bin/{language,publish}-guard.sh.
LC_ALL=C
export LC_ALL

BASE_REF="${1:-main}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "merge-gate: not a git repository" >&2; exit 2; }

branch="$(git rev-parse --abbrev-ref HEAD)"

# KEPT IN SYNC with bin/spec-gate.sh (same helper, same contract).
frontmatter_field() { # frontmatter_field <file> <field> -> prints normalized value
  local v
  v="$(awk -v fld="$2" '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    index($0, fld ":") == 1 { sub("^[^:]*:[[:space:]]*", ""); print; exit }
  ' "$1")"
  v="$(printf '%s' "$v" | tr '[:upper:]' '[:lower:]' | tr -d '\r')"
  v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

# Run from the repo root: the record grep and freshness pathspecs are
# cwd-relative, and a subdir invocation must see the same truth as a root one.
cd "$(git rev-parse --show-toplevel)"

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

# 3b. EVERY matching record must approve. Checking only one (the "newest") let a
#     PASS mask a sibling REQUEST CHANGES, and with records committed together the
#     tie-break fell to filesystem enumeration order, so the outcome depended on
#     file NAMES. Demonstrated: with one APPROVE and one REQUEST CHANGES present,
#     two of four naming orders passed. Loop, and refuse on the first non-approval.
#     Verdicts are read ONLY from frontmatter (between the first two '---' lines);
#     reviewer prose in the body (e.g. an honest "was REQUEST CHANGES, now resolved"
#     history) must never flip the gate. Deny by default: no verdict does not pass.
#
#     REVIEWED_COMMIT cutoff: records dated on/after $RC_CUTOFF must declare the
#     commit they reviewed, and the gate verifies no CODE moved since. Older records
#     are exempt, so shipping this needed no hand migration of existing records.
RC_CUTOFF="2026-08-05"

while IFS= read -r record; do
  [[ -n "$record" ]] || continue

  # --- verdict ---
  verdict="$(frontmatter_field "$record" "verdict" | tr '[:lower:]' '[:upper:]')"
  case "$verdict" in
    APPROVE|"APPROVE WITH COMMENTS"|PASS) : ;;
    "")
      echo "merge-gate: REFUSED, no 'verdict:' field in the record's frontmatter ($record)." >&2
      echo "Re-run the reviewer; a record must declare one clean frontmatter verdict." >&2
      exit 1 ;;
    *)
      echo "merge-gate: REFUSED, a review for '$branch' did not approve (verdict: $verdict)." >&2
      echo "($record). Fix the findings and re-run the reviewer, never edit the record by hand." >&2
      echo "Every record carrying 'branch: $branch' must approve, not just one." >&2
      exit 1 ;;
  esac

  # --- model tier floor: judgment must not ride a fast tier silently ---
  tier="$(frontmatter_field "$record" "model_tier")"
  waiver="$(frontmatter_field "$record" "model_waiver")"
  case "$tier" in
    strong|strongest) : ;;
    fast)
      if [[ "$waiver" != "human" ]]; then
        echo "merge-gate: REFUSED, judgment record was produced on a FAST-tier model ($record)." >&2
        echo "Re-run the reviewer on a strong tier, or add an explicit 'model_waiver: human' line." >&2
        exit 1
      fi ;;
    "")
      echo "merge-gate: REFUSED, record has no 'model_tier:' field ($record)." >&2
      echo "Re-run the reviewer; records declare the tier that judged (fast|strong|strongest)." >&2
      exit 1 ;;
    *)
      echo "merge-gate: REFUSED, unknown model_tier '$tier' ($record)." >&2
      echo "Vocabulary is exactly: fast | strong | strongest (tier words, never vendor names)." >&2
      exit 1 ;;
  esac

  # --- content anchor: does this review describe the code being merged? ---
  rec_date="$(frontmatter_field "$record" "date")"
  reviewed="$(frontmatter_field "$record" "reviewed_commit")"

  # The cutoff is FAIL-CLOSED: a missing or malformed date must never exempt a record,
  # or omitting one field would bypass the anchor. Only a well-formed YYYY-MM-DD
  # strictly before the cutoff is exempt. (Before this: no `date:` was exempt, and
  # `05-08-2026` sorted below the cutoff so it was exempt too. Both were bypasses.)
  if [[ -z "$rec_date" ]]; then
    echo "merge-gate: REFUSED, record has no 'date:' field ($record)." >&2
    echo "Every record declares the date it was written (docs/eval-framework.md);" >&2
    echo "without it the reviewed_commit requirement could be bypassed by omission." >&2
    exit 1
  fi
  case "$rec_date" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) : ;;
    *)
      echo "merge-gate: REFUSED, malformed 'date: $rec_date' ($record)." >&2
      echo "Records use ISO YYYY-MM-DD; any other form cannot be compared to the cutoff." >&2
      exit 1 ;;
  esac

  if [[ ! "$rec_date" < "$RC_CUTOFF" ]]; then
    if [[ -z "$reviewed" ]]; then
      echo "merge-gate: REFUSED, record has no 'reviewed_commit:' field ($record)." >&2
      echo "Records dated $RC_CUTOFF or later must name the commit they reviewed, so the" >&2
      echo "gate can verify the review covers the code being merged (timestamps cannot)." >&2
      exit 1
    fi
    if ! git rev-parse --verify --quiet "${reviewed}^{commit}" >/dev/null; then
      echo "merge-gate: REFUSED, 'reviewed_commit: $reviewed' is not a commit in this repo ($record)." >&2
      exit 1
    fi
    if ! git diff --quiet "$reviewed" HEAD -- . ':(exclude)docs/evals'; then
      echo "merge-gate: REFUSED, code changed after the reviewed commit ($record)." >&2
      echo "Reviewed $reviewed, but non-evals files differ at HEAD." >&2
      echo "Re-run the reviewer so the record covers what merges; never re-date a record." >&2
      exit 1
    fi
  fi
done <<< "$records"

# 3d. Freshness (ordering, kept as a cheap backstop alongside the content anchor
#     above): the newest record must not predate the last CODE commit.
rec_time=0
while IFS= read -r r; do
  [[ -n "$r" ]] || continue
  t="$(git log -1 --format=%ct -- "$r" 2>/dev/null || echo 0)"
  [[ "$t" -gt "$rec_time" ]] && rec_time="$t"
done <<< "$records"
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
