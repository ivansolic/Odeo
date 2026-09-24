#!/usr/bin/env bash
#
# merge-gate.sh, the deterministic /odeo:merge gate (enforced guardrail).
#
# Refuses the merge path unless the mechanical preconditions hold:
#   1. not on main/master (integration happens from a story branch)
#   2. clean working tree (no uncommitted work sneaks into a merge)
#   3. EVERY review record carrying this branch in docs/evals/ approves, declares its
#      model_tier, and (from RC_CUTOFF on) names the commit it reviewed
#   4. do-not-touch boundaries respected (delegates to boundary-check.sh if present)
#
# It cannot verify judgment (was the review GOOD?), that stays with the reviewers
# and the human gate. It verifies existence, deterministically.
#
# Usage:   merge-gate.sh [base-ref]      (default: main)
# Exit:    0 all preconditions hold · 1 refused (reason printed) · 2 usage error
# Used by: /odeo:merge (must run this and stop on non-zero before any rebase/merge).

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
# Checked BEFORE the generic clean-tree precondition so the accurate, by-name message wins:
# an untracked record is the case a human is most likely to hit, and "commit or stash" does
# not tell them WHICH file. Any untracked, non-ignored file under docs/evals is a refusal. Ignored junk (.DS_Store, Thumbs.db) is excluded by
# --exclude-standard, which is what keeps this from re-breaking macOS and Windows.
stray="$(git ls-files --others --exclude-standard docs/evals 2>/dev/null)"
if [[ -n "$stray" ]]; then
  echo "merge-gate: REFUSED, untracked file(s) under docs/evals:" >&2
  printf '%s\n' "$stray" | sed 's/^/  /' >&2
  echo "A review record must be COMMITTED to count, and an uncommitted one could hide a" >&2
  echo "refusal from the gate. Commit it, or remove it if it is not a record." >&2
  exit 1
fi

# --untracked-files=normal on the CLI beats a repo/global `status.showUntrackedFiles=no`.
# Without it a user config could hide untracked work from this check, and (once enumeration
# became tracked-only) an untracked REQUEST CHANGES record went completely invisible.
# This flag is NOT made redundant by the docs/evals check above: that one only looks in
# docs/evals, so without this flag untracked CODE anywhere else would merge (case 56).
if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
  echo "merge-gate: REFUSED, uncommitted changes present. Commit or stash first." >&2
  exit 1
fi

# 3. Review record exists for this branch: exact STRING equality against the record's
#    FRONTMATTER `branch:` field, the same way bin/spec-gate.sh enrols records.
#    A `grep -rl "^branch: $branch$"` was wrong three ways and each one failed OPEN:
#      - `$` does not match before `\r` on system grep, so a CRLF record was invisible
#        to enumeration and a sibling APPROVE carried the gate (behaviour also varied
#        with whichever grep was on PATH, so it did not reproduce everywhere);
#      - the branch was interpolated as a REGEX, so on `fix/a.b` a record naming
#        `fix/aXb` satisfied the gate;
#      - it matched a `branch:` line ANYWHERE in the file, body included, while every
#        other field is read from frontmatter only.
#    frontmatter_field lowercases, so the comparison lowercases the branch too.
branch_lc="$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]')"
records=""
unparseable=""
# Every TRACKED entry, any name, symlinks included. Two deliberate choices:
#   - no `-name '*.md'` filter: the old grep had none, so a `z-refuse.txt` carrying a
#     refusal used to be seen, and re-adding a filter would fail OPEN;
#   - `git ls-files`, not `find`: find walks the filesystem, so a GITIGNORED file was
#     invisible to the clean-tree check above but visible to the tripwire below, and every
#     merge was blocked. `.DS_Store` is the real instance, since Finder creates one in any
#     folder a human opens. Tracked-only excludes junk by construction while keeping
#     symlinks and non-.md records, which a name filter would not. Nothing is lost: an
#     untracked non-ignored file is already refused by the clean-tree check.
while IFS= read -r -d '' r; do
  [[ -n "$r" ]] || continue

  # TRIPWIRE (fail-closed), on PARSEABILITY, not on matching a branch line. Enrolling by
  # frontmatter closed the CRLF/regex/body holes, but a record the parser CANNOT read then
  # silently did not enrol, so a malformed REFUSAL hid behind a sibling APPROVE. Keying the
  # tripwire on a literal `branch: <x>` line was itself evadable by padding, a tab, or
  # uppercase. Keying it on "frontmatter does not parse" is immune to all of that at once,
  # and it never fires on a record that parsed and merely lacks a branch field (PM and
  # design records), even one quoting a branch line in its body.
  # KEPT IN SYNC with frontmatter_field above (and bin/spec-gate.sh): both must agree
  # on what "parseable" means, or the tripwire would skip a file the reader can read, or
  # refuse one it cannot, and guarantee 3 would silently reopen.
  if [[ ! -r "$r" ]]; then
    echo "merge-gate: REFUSED, cannot read $r (sparse checkout, skip-worktree, permissions?)." >&2
    echo "The gate cannot judge a record it cannot open; make it readable or untrack it." >&2
    exit 1
  fi
  if ! awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit 1; next }
    /^---[[:space:]]*$/ { found=1; exit 0 }
    END { exit !found }
  ' "$r" 2>/dev/null; then
    unparseable="${unparseable}${r}"$'\n'
    continue
  fi

  # A duplicated `branch:` key is checked before enrolment: a decoy first line makes the
  # record enrol under the wrong branch, and its verdict is then never read.
  nbranch="$(awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    index($0, "branch:") == 1 { n++ }
    END { print n+0 }
  ' "$r" 2>/dev/null || echo 0)"
  if [[ "$nbranch" -gt 1 ]]; then
    echo "merge-gate: REFUSED, $nbranch 'branch:' lines in the frontmatter ($r)." >&2
    echo "A decoy first line makes a record enrol under the wrong branch and hides its" >&2
    echo "verdict. Exactly one branch: line; re-run the reviewer." >&2
    exit 1
  fi

  [[ "$(frontmatter_field "$r" "branch")" == "$branch_lc" ]] && records="${records}${r}"$'\n'
done < <(git ls-files -z docs/evals | LC_ALL=C sort -z -u)
records="${records%$'\n'}"
unparseable="${unparseable%$'\n'}"

if [[ -n "$unparseable" ]]; then
  echo "merge-gate: REFUSED, docs/evals contains file(s) whose frontmatter does not parse:" >&2
  printf '%s\n' "$unparseable" | sed 's/^/  /' >&2
  echo "The gate cannot tell which branch such a file reviews, so it cannot be skipped:" >&2
  echo "a malformed REFUSAL would hide behind a sibling approval. Frontmatter must OPEN" >&2
  echo "the file and close with '---'. Re-run the reviewer to regenerate it." >&2
  exit 1
fi

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
  checked="${checked:-}${checked:+, }${record}"
  n_checked=$(( ${n_checked:-0} + 1 ))

  # --- no duplicate keys ---
  # frontmatter_field takes the FIRST match, so a duplicated key lets a benign value
  # shadow a real one. Generic on purpose: a bespoke check for `verdict:` alone left the
  # same hole on `date:` (pre-cutoff first skips the anchor) and `model_tier:` (strong
  # first bypasses the fast-tier floor).
  dup="$(awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    {
      for (i = 1; i <= 5; i++) {
        split("branch date verdict model_tier reviewed_commit", k, " ")
        if (index($0, k[i] ":") == 1) n[k[i]]++
      }
    }
    END { for (key in n) if (n[key] > 1) printf "%s(%d) ", key, n[key] }
  ' "$record")"
  if [[ -n "$dup" ]]; then
    echo "merge-gate: REFUSED, duplicated frontmatter key(s) in $record: $dup" >&2
    echo "Each of branch/date/verdict/model_tier/reviewed_commit appears exactly once;" >&2
    echo "a duplicate lets one value shadow another. Re-run the reviewer." >&2
    exit 1
  fi
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
    # The anchor must name an IMMUTABLE commit. A symbolic ref (`HEAD`, a branch name)
    # resolves fine and then never goes stale, which is a permanent bypass, and `HEAD`
    # is the likeliest wrong value because reviewers are told to run `rev-parse HEAD`.
    case "$reviewed" in
      *[!0-9a-f]* | "" )
        echo "merge-gate: REFUSED, 'reviewed_commit: $reviewed' is not a commit sha ($record)." >&2
        echo "Use the hex sha the reviewer read (7 to 40 hex chars), never a ref like HEAD" >&2
        echo "or a branch name: a moving ref can never go stale, so it proves nothing." >&2
        exit 1 ;;
    esac
    if [[ "${#reviewed}" -lt 7 || "${#reviewed}" -gt 40 ]]; then
      echo "merge-gate: REFUSED, 'reviewed_commit: $reviewed' is not 7 to 40 hex chars ($record)." >&2
      exit 1
    fi
    # ^{commit} is load-bearing: `rev-parse --verify` alone accepts a tree or blob sha.
    if ! git rev-parse --verify --quiet "${reviewed}^{commit}" >/dev/null; then
      echo "merge-gate: REFUSED, 'reviewed_commit: $reviewed' is not a commit in this repo ($record)." >&2
      exit 1
    fi
    if ! git merge-base --is-ancestor "$reviewed" HEAD 2>/dev/null; then
      echo "merge-gate: REFUSED, 'reviewed_commit: $reviewed' is not an ancestor of HEAD ($record)." >&2
      echo "The review sits on a different line of history than what you are merging." >&2
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
[[ -z "$checker" && -x "$(dirname "${BASH_SOURCE[0]}")/boundary-check.sh" ]] && checker="$(dirname "${BASH_SOURCE[0]}")/boundary-check.sh"
if [[ -n "$checker" ]]; then
  if ! "$checker" "$BASE_REF"; then
    echo "merge-gate: REFUSED, do-not-touch boundary violated (see above)." >&2
    exit 1
  fi
fi

echo "merge-gate: preconditions hold (branch '$branch', ${n_checked:-0} record(s) checked: ${checked:-none})."
exit 0
