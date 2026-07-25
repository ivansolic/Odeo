#!/usr/bin/env bash
# publish-guard.sh: deterministic guard against publishing internal artifacts.
#
# Given a directory (the materialized publish tree) or a NUL-delimited path list
# on stdin, it enforces two tiers plus an advisory:
#   - DENYLIST (docs/internal-paths.txt): any internal path present is a HARD
#     block (exit 1). This is the internal-artifact leak gate.
#   - ALLOWLIST (docs/public-paths.txt), only with --require-allowlist: any path
#     that matches NEITHER list is UNCLASSIFIED and a HARD block (exit 1). This is
#     the fail-closed half: a future committed-but-internal path nobody denylists
#     cannot slip through, it blocks the publish until a human classifies it.
#   - PRIVACY (bin/privacy-scan.sh), advisory: a finding on a publishable file is
#     surfaced and exits 3 (human must review), never a silent pass, never a hard
#     fail (privacy-scan over-flags on purpose, e.g. docs that document the
#     patterns).
#
# Exit codes: 0 clean, 1 hard block (internal or unclassified path), 2 usage,
# 3 advisory privacy finding (review before publishing).
#
# Match rules (shared with both list files):
#   - a line ending in "/" is a DIRECTORY PREFIX; a line without one is an EXACT
#     repo-relative file path; "#" and blank lines are ignored.
# Paths are read NUL-delimited everywhere (find -print0 / read -d '' / callers
# must pipe `git ls-tree -r -z`) so a non-ASCII name cannot defeat the match.
#
# usage: publish-guard.sh [--require-allowlist] <dir>
#        publish-guard.sh [--require-allowlist] -      (NUL-delimited list on stdin)
set -uo pipefail
export LC_ALL=C

usage() {
  echo "usage: publish-guard.sh [--require-allowlist] <dir> | -  (or pipe a NUL-delimited path list)" >&2
  exit 2
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRIVACY="$ROOT/bin/privacy-scan.sh"

REQUIRE_ALLOWLIST=0; POSITIONAL=""; HAVE_POS=0
for a in "$@"; do
  case "$a" in
    --require-allowlist) REQUIRE_ALLOWLIST=1 ;;
    *) POSITIONAL="$a"; HAVE_POS=1 ;;
  esac
done

DENYLIST="${CLAUDE_INTERNAL_PATHS:-$ROOT/docs/internal-paths.txt}"
[ -f "$DENYLIST" ] || { echo "publish-guard: denylist not found: $DENYLIST" >&2; exit 2; }
ALLOWLIST="${CLAUDE_PUBLIC_PATHS:-$ROOT/docs/public-paths.txt}"
if [ "$REQUIRE_ALLOWLIST" = 1 ]; then
  [ -f "$ALLOWLIST" ] || { echo "publish-guard: allowlist not found: $ALLOWLIST" >&2; exit 2; }
fi

# Mode: a directory argument, or '-' / no argument for a NUL list on stdin.
MODE=""; DIR=""
if [ "$HAVE_POS" = 0 ] || [ "$POSITIONAL" = "-" ]; then
  [ -t 0 ] && usage
  MODE=stdin
else
  DIR="$POSITIONAL"
  [ -d "$DIR" ] || { echo "publish-guard: not a directory: $DIR" >&2; exit 2; }
  MODE=dir
fi

# Load a list file into two newline-delimited strings: exact files and dir prefixes.
DENY_EXACTS=""; DENY_PREFIXES=""; ALLOW_EXACTS=""; ALLOW_PREFIXES=""
load_list() { # $1=file ; prints "exacts\n\034\nprefixes" (0x1c separator)
  local file="$1" exacts="" prefixes="" line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    # trim leading/trailing whitespace so a padded entry cannot silently go inert
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    case "$line" in ''|'#'*) continue;; esac
    case "$line" in
      */) prefixes="${prefixes}${line}"$'\n' ;;
      *)  exacts="${exacts}${line}"$'\n' ;;
    esac
  done < "$file"
  printf '%s\034%s' "$exacts" "$prefixes"
}

_loaded="$(load_list "$DENYLIST")"
DENY_EXACTS="${_loaded%%$'\034'*}"; DENY_PREFIXES="${_loaded#*$'\034'}"
if [ "$REQUIRE_ALLOWLIST" = 1 ]; then
  _loaded="$(load_list "$ALLOWLIST")"
  ALLOW_EXACTS="${_loaded%%$'\034'*}"; ALLOW_PREFIXES="${_loaded#*$'\034'}"
fi

# match_list <candidate> <exacts> <prefixes> -> 0 if the candidate matches either.
match_list() {
  local c="$1" exacts="$2" prefixes="$3" p
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    [ "$c" = "$p" ] && return 0
  done <<EOF
$exacts
EOF
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$c" in "$p"*) return 0;; esac
  done <<EOF
$prefixes
EOF
  return 1
}

DENY=0; UNCLASSIFIED=0; PRIV=0; N=0

check_candidate() { # <repo-relative candidate> <abs path or "">
  local cand="$1" abs="$2" prc
  cand="${cand#./}"
  [ -n "$cand" ] || return 0
  N=$((N + 1))
  if match_list "$cand" "$DENY_EXACTS" "$DENY_PREFIXES"; then
    echo "publish-guard: BLOCK internal path present: $cand" >&2
    DENY=1
    return 0
  fi
  if [ "$REQUIRE_ALLOWLIST" = 1 ]; then
    if ! match_list "$cand" "$ALLOW_EXACTS" "$ALLOW_PREFIXES"; then
      echo "publish-guard: BLOCK unclassified path (not in public-paths.txt): $cand" >&2
      UNCLASSIFIED=1
      return 0
    fi
  fi
  # Privacy is advisory and only runs when a real file body is available (dir mode).
  if [ -n "$abs" ] && [ -f "$abs" ] && [ -x "$PRIVACY" ]; then
    "$PRIVACY" "$abs" >/dev/null 2>&1; prc=$?
    if [ "$prc" = 1 ]; then
      echo "publish-guard: privacy finding (review): $cand" >&2
      PRIV=1
    fi
  fi
  return 0
}

if [ "$MODE" = dir ]; then
  while IFS= read -r -d '' cand; do
    check_candidate "$cand" "$DIR/${cand#./}"
  done < <(cd "$DIR" && find . \( -type f -o -type l \) -print0)
else
  while IFS= read -r -d '' cand; do
    check_candidate "$cand" ""
  done
fi

if [ "$DENY" = 1 ] || [ "$UNCLASSIFIED" = 1 ]; then
  exit 1
elif [ "$PRIV" = 1 ]; then
  exit 3
fi
echo "publish-guard: clean ($N files checked)."
exit 0
