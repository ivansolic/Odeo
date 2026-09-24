#!/usr/bin/env bash
#
# spec-gate.sh, the /odeo:build entry gate for spec artifacts (enforced guardrail).
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
# Used by: /odeo:build (ENFORCED step 0, before the mode question).

set -uo pipefail

[[ $# -ge 1 ]] || { echo "Usage: spec-gate.sh <artifact.md> [...]" >&2; exit 2; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "spec-gate: not a git repository" >&2; exit 2; }

# Resolve arguments to PHYSICAL absolute paths BEFORE anchoring at the repo
# root (pwd -P on both sides, or the /var -> /private/var symlink on macOS
# breaks the containment check)
ARTIFACTS=()
for p in "$@"; do
  if [[ -L "$p" ]]; then
    echo "spec-gate: artifact is a symlink (target can drift after review): $p" >&2; exit 2
  elif [[ -f "$p" ]]; then
    ARTIFACTS+=("$(cd "$(dirname "$p")" && pwd -P)/$(basename "$p")")
  else
    echo "spec-gate: artifact not found: $p" >&2; exit 2
  fi
done
cd "$(git rev-parse --show-toplevel)"
TOP="$(pwd -P)"

# Fail CLOSED on artifacts outside this repository, an enforced gate consumed
# via exit code must never pass vacuously (git checks go quiet outside the tree).
for abs in "${ARTIFACTS[@]}"; do
  case "$abs" in
    "$TOP"/*) : ;;
    *) echo "spec-gate: artifact outside this repository: $abs" >&2; exit 2 ;;
  esac
done

# Records participate in gates only COMMITTED: a hand-edited working copy must
# never flip a verdict or coverage (content and timestamp must share a source).
if [[ -n "$(git status --porcelain -- docs/evals 2>/dev/null)" ]]; then
  echo "spec-gate: REFUSED, docs/evals/ has uncommitted changes." >&2
  echo "Records enter gates only committed; commit the reviewer's record first." >&2
  exit 1
fi

# Kept in sync with merge-gate.sh's verdict parsing, same contract, both gates.
record_tokens() { # record_tokens <record-file> -> frontmatter artifact:/covers: tokens, one per line
  awk '
    NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ { exit }
    /^(artifact|covers):/ { sub(/^(artifact|covers):[[:space:]]*/, ""); print }
  ' "$1" | tr -s ' \t' '\n' | tr -d '\r'
}

covers_id() { # covers_id <record-file> <id> -> 0 if a frontmatter token EQUALS id
  local t
  while IFS= read -r t; do
    [[ "$t" == "$2" ]] && return 0
  done < <(record_tokens "$1")
  return 1
}


# KEPT IN SYNC with bin/merge-gate.sh (same helper, same contract).
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
  rel="${abs#"$TOP"/}"
  base="$(basename "$rel" .md)"

  # The id token: PRD-NNN / USR-NNN / RES-NNN prefix, else the full basename
  if [[ "$base" =~ ^((PRD|USR|RES)-[0-9]+) ]]; then id="${BASH_REMATCH[1]}"; else id="$base"; fi

  # 1. No uncommitted edits, an unreviewed change must not ride an old PASS
  if [[ -n "$(git status --porcelain -- "$rel")" ]]; then
    echo "spec-gate: REFUSED, $rel has uncommitted changes. Commit them and re-run the reviewer." >&2
    fail=1; continue
  fi

  # 2. A record covers this id: exact STRING equality against frontmatter
  #    artifact:/covers: tokens (no regex, no boundary hacks, body lines never
  #    count, so USR-001 cannot match inside USR-001-008 or XUSR-001)
  records=""
  while IFS= read -r r; do
    covers_id "$r" "$id" && records="${records}${r}"$'\n'
  done < <(find docs/evals -type f -name '*.md' 2>/dev/null | sort)
  records="${records%$'\n'}"
  if [[ -z "$records" ]]; then
    echo "spec-gate: REFUSED, no eval record in docs/evals/ covers '$id'." >&2
    echo "Run pm-reviewer on the artifact first (review = eval record with artifact:/covers:)." >&2
    fail=1; continue
  fi

  # Newest matching record by git commit time. Kept ONLY for the freshness check (step 4)
  # and the committed-record guard just below; the VERDICT and TIER checks deliberately do
  # NOT use it. Line 55 refuses the whole run if docs/evals is dirty, so every enrolled
  # record here is committed and unmodified, and this time is a real one for each.
  record=""; rec_time=0
  while IFS= read -r r; do
    t="$(git log -1 --format=%ct -- "$r" 2>/dev/null || echo 0)"
    [[ "$t" -gt "$rec_time" ]] && { rec_time="$t"; record="$r"; }
  done <<< "$records"

  if [[ -z "$record" ]]; then
    echo "spec-gate: REFUSED, no COMMITTED record covers '$id' (matches exist only uncommitted)." >&2
    fail=1; continue
  fi

  # 3. EVERY enrolled record must approve AND clear the tier floor (deny by default). Checking
  #    only the newest let an older sibling REQUEST CHANGES, or an older fast-tier PASS, hide
  #    behind a later strong PASS, the same hole merge-gate closed. The loop refuses the
  #    ARTIFACT (bad=1; break -> fail=1; continue), it does not exit, because spec-gate
  #    verdicts every artifact passed to it in one run. Order is irrelevant when all must pass.
  bad=0
  while IFS= read -r r; do
    [[ -n "$r" ]] || continue
    verdict="$(frontmatter_verdict "$r")"
    case "$verdict" in
      APPROVE|"APPROVE WITH COMMENTS"|PASS) : ;;
      "")
        echo "spec-gate: REFUSED, record for '$id' has no frontmatter verdict ($r)." >&2
        bad=1; break ;;
      *)
        echo "spec-gate: REFUSED, a review for '$id' did not pass (verdict: $verdict, $r)." >&2
        echo "EVERY record covering '$id' must approve, not just the newest. Fix the named gaps and re-run pm-reviewer, the record regenerates, never edit it by hand." >&2
        bad=1; break ;;
    esac

    # 3b. Model tier floor (same contract as merge-gate): no silent fast-tier judgment.
    tier="$(frontmatter_field "$r" "model_tier")"
    waiver="$(frontmatter_field "$r" "model_waiver")"
    case "$tier" in
      strong|strongest) : ;;
      fast)
        if [[ "$waiver" != "human" ]]; then
          echo "spec-gate: REFUSED, judgment for '$id' ran on a FAST-tier model ($r)." >&2
          echo "Re-run pm-reviewer on a strong tier, or add 'model_waiver: human' explicitly." >&2
          bad=1; break
        fi ;;
      "")
        echo "spec-gate: REFUSED, record for '$id' has no 'model_tier:' field ($r)." >&2
        echo "Re-run pm-reviewer; records declare the tier that judged (fast|strong|strongest)." >&2
        bad=1; break ;;
      *)
        echo "spec-gate: REFUSED, unknown model_tier '$tier' for '$id' ($r)." >&2
        echo "Vocabulary is exactly: fast | strong | strongest." >&2
        bad=1; break ;;
    esac
  done <<< "$records"
  [[ "$bad" -eq 1 ]] && { fail=1; continue; }

  # 4. Freshness: the review must postdate the artifact's last change.
  #    No commit history (gitignored / never committed) = refuse, a file git
  #    cannot see has no reviewable state (porcelain is blind to ignored files).
  art_time="$(git log -1 --format=%ct -- "$rel" 2>/dev/null || true)"
  if [[ -z "$art_time" || "$art_time" == "0" ]]; then
    echo "spec-gate: REFUSED, '$rel' has no commit history (gitignored or never committed)." >&2
    echo "Specs enter the build only committed; commit it, review it, then build." >&2
    fail=1; continue
  fi
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
