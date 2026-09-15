#!/usr/bin/env bash
# language-guard.sh, deterministic no-leak gate for machine surfaces.
#
# Checks that every machine-read surface in the given paths and tokens is
# ASCII and, where applicable, matches the project's allowlist vocabulary.
# Machine-read and language-independent: it keys off tokens, never prose.
# Prose body text (below the closing --- of frontmatter) is never read.
#
# Usage:
#   language-guard.sh [--branch <name>] [--commit <msg>] <path> [<path>...]
#   At least one path or one of --branch/--commit is required.
#
# Exit codes:
#   0  all checked surfaces are clean
#   1  one or more violations found (names and surfaces printed to stderr)
#   2  usage error (no args, or a path that does not exist)
#
# Consumed by: callers that want to enforce machine-surface language purity
#   before a merge, commit, or CI gate. Standalone; not wired into other gates.

set -uo pipefail

# ---------------------------------------------------------------------------
# Allowlists (the single definition; callers rely on these exact values)
# ---------------------------------------------------------------------------

# Conventional-commit types from AGENTS.md / global CLAUDE.md.
COMMIT_TYPES="feat fix chore docs refactor test style perf"

# The only closed enum in frontmatter: model_tier. verdict/status are free-text
# (they get the ASCII rule only, not a closed-list check, so the guard never
# out-stricts the gates it protects, per arch-review BLOCKING-2).
FRONTMATTER_ENUM_FIELDS="model_tier"
MODEL_TIER_VALUES="fast strong strongest"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
  echo "usage: language-guard.sh [--branch <name>] [--commit <msg>] <path> [<path>...]" >&2
  exit 2
}

# is_ascii TOKEN
# Returns 0 (true) if TOKEN contains only printable ASCII (0x20-0x7E).
# Uses LC_ALL=C so the character class is locale-independent (fail-closed core).
is_ascii() {
  printf '%s' "$1" | LC_ALL=C grep -q '[^ -~]' && return 1
  return 0
}

# matches_ascii_pattern TOKEN PATTERN
# Returns 0 (true) if TOKEN fully matches the ERE PATTERN under LC_ALL=C,
# so character ranges like [a-z] are interpreted as ASCII-only regardless of
# the runner's locale (which may cause [a-z] to collate beyond ASCII letters).
matches_ascii_pattern() {
  printf '%s' "$1" | LC_ALL=C grep -qE "^($2)$"
}

# viol FILE SURFACE REASON
# Records a violation: prints the message to stderr and sets fail=1.
viol() {
  echo "language-guard: FAIL, $1 $2: $3" >&2
  fail=1
}

# check_frontmatter PATH
# Reads only the YAML frontmatter (between the first two --- lines) of a .md
# file. Checks each top-level key (no leading whitespace) for ASCII + slug
# form, and checks model_tier values against the closed enum.
# Indented/nested lines (children of keys like model_plan:) are skipped.
check_frontmatter() {
  local path="$1"
  local in_fm=0

  while IFS= read -r raw; do
    # Strip CR for CRLF portability.
    local line
    line="$(printf '%s' "$raw" | tr -d '\r')"

    if [ "$in_fm" -eq 0 ]; then
      # First line must open the frontmatter block.
      case "$line" in ---) in_fm=1; continue ;; esac
      # No opening ---, no frontmatter to check.
      return
    fi

    # Closing --- ends the frontmatter; stop reading.
    case "$line" in ---) return ;; esac

    # Skip indented/nested lines (children of e.g. model_plan:).
    # A top-level key has NO leading whitespace, matching ^([^:[:space:]][^:]*):
    case "$line" in
      [[:space:]]* | "") continue ;;
    esac

    # Extract the key: everything before the first colon.
    local key value
    case "$line" in
      *:*) key="${line%%:*}"; value="${line#*:}" ;;
      *) continue ;; # no colon, not a key-value line
    esac
    value="${value# }" # strip one leading space after the colon

    # Key must be ASCII and match the identifier pattern ^[a-z0-9_-]+$.
    if ! is_ascii "$key"; then
      viol "$path" "frontmatter field name" "non-ASCII key: $key"
      continue
    fi
    # Use matches_ascii_pattern so [a-z0-9_-] is evaluated under LC_ALL=C,
    # preventing UTF-8 locale collation from admitting uppercase characters.
    if ! matches_ascii_pattern "$key" "[a-z0-9_-]+"; then
      viol "$path" "frontmatter field name" "invalid key: $key"
      continue
    fi

    # For the model_tier enum field, check the value against the closed list.
    if [ "$key" = "model_tier" ]; then
      local lval
      lval="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]' | tr -d '\r')"
      local ok=0
      local t
      for t in $MODEL_TIER_VALUES; do
        [ "$lval" = "$t" ] && { ok=1; break; }
      done
      if [ "$ok" -eq 0 ]; then
        viol "$path" "frontmatter enum value" "model_tier '$value' not in: $MODEL_TIER_VALUES"
      fi
      continue
    fi

    # All other field values: ASCII rule only (no closed-list check).
    if ! is_ascii "$value"; then
      viol "$path" "frontmatter field value" "non-ASCII value in field '$key'"
    fi

  done < "$path"
}

# check_filename PATH
# Checks that the basename of PATH is fully ASCII and slug-shaped, with
# allowances for leading ISO date, ID prefix, and range prefix before the
# lowercase human-authored tail.
check_filename() {
  local path="$1"
  local base
  base="$(basename "$path")"

  # Whole basename must be ASCII and match ^[A-Za-z0-9._-]+$.
  if ! is_ascii "$base"; then
    viol "$path" "filename" "non-ASCII characters in filename: $base"
    return
  fi
  # Use matches_ascii_pattern so [A-Za-z0-9._-] is evaluated under LC_ALL=C,
  # preventing UTF-8 locale collation from widening the matched character set.
  if ! matches_ascii_pattern "$base" "[A-Za-z0-9._-]+"; then
    viol "$path" "filename" "invalid characters in filename: $base"
    return
  fi

  # Strip the final extension to get the stem.
  local stem="${base%.*}"
  # If stripping the extension yields the same string (no dot), stem = base.
  [ "$stem" = "$base" ] && stem="$base"

  # Strip an optional leading ISO date YYYY-MM-DD-.
  local tail="$stem"
  case "$tail" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*)
      tail="${tail#[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-}" ;;
  esac

  # Strip an optional leading ID range PREFIX-NNN-NNN- (e.g. USR-001-006-),
  # then a plain ID prefix PREFIX-NNN- (e.g. PRD-001-), case-insensitive.
  # The range form must come first (it is more specific).
  local norm
  norm="$(printf '%s' "$tail" | tr '[:upper:]' '[:lower:]')"
  case "$norm" in
    prd-[0-9]*-[0-9]*-*|usr-[0-9]*-[0-9]*-*|res-[0-9]*-[0-9]*-*|adr-[0-9]*-[0-9]*-*)
      # Range form: strip PREFIX-NNN-NNN- (two numeric segments).
      # Strip the word prefix (e.g. "usr-").
      tail="${tail#*-}" # removes "USR-"
      tail="${tail#*-}" # removes first numeric group "001-"
      tail="${tail#*-}" # removes second numeric group "006-"
      ;;
    prd-[0-9]*-*|usr-[0-9]*-*|res-[0-9]*-*|adr-[0-9]*-*)
      # Plain form: strip PREFIX-NNN-.
      tail="${tail#*-}" # removes "PRD-"
      tail="${tail#*-}" # removes "001-"
      ;;
  esac

  # The remaining tail must match ^[a-z0-9-]+$.
  # Use matches_ascii_pattern so [a-z0-9-] is evaluated under LC_ALL=C,
  # preventing UTF-8 locale collation from admitting uppercase characters.
  if ! matches_ascii_pattern "$tail" "[a-z0-9-]+"; then
    viol "$path" "filename" "slug tail has invalid characters ('$tail' in '$base')"
  fi
}

# check_directory PATH
# Checks that the basename of a directory path is ASCII and slug-shaped.
check_directory() {
  local path="$1"
  local name
  name="$(basename "$path")"

  if ! is_ascii "$name"; then
    viol "$path" "directory name" "non-ASCII characters: $name"
    return
  fi
  # Use matches_ascii_pattern so [a-z0-9._-] is evaluated under LC_ALL=C,
  # preventing UTF-8 locale collation from admitting uppercase characters.
  if ! matches_ascii_pattern "$name" "[a-z0-9._-]+"; then
    viol "$path" "directory name" "invalid characters: $name"
  fi
}

# check_branch NAME
# Checks that a branch name is ASCII and matches git-legal ASCII branch chars.
check_branch() {
  local name="$1"
  if ! is_ascii "$name"; then
    viol "--branch" "git branch name" "non-ASCII characters: $name"
    return
  fi
  # Use matches_ascii_pattern so [a-zA-Z0-9._/-] is evaluated under LC_ALL=C,
  # preventing UTF-8 locale collation from widening the matched character set.
  if ! matches_ascii_pattern "$name" "[a-zA-Z0-9._/-]+"; then
    viol "--branch" "git branch name" "invalid characters: $name"
  fi
}

# check_commit MESSAGE
# Parses the conventional-commit header: type(scope): ...
# type must be in COMMIT_TYPES; scope (if present) must be ASCII + ^[a-z0-9-]+$.
check_commit() {
  local msg="$1"

  # Match `type(scope): rest` or `type: rest`.
  # The leading type is lowercase letters; scope is optional.
  local ctype cscope has_scope
  has_scope=0

  # Try to extract "type(scope):" or "type:" from the start of the message.
  # We do it with case patterns to stay POSIX-portable.
  case "$msg" in
    *\(*\):\ *)
      # Has parentheses: type(scope): ...
      ctype="${msg%%(*}"
      local rest="${msg#*\(}"
      cscope="${rest%%\)*}"
      has_scope=1
      ;;
    *:\ *)
      # No parentheses: type: ...
      ctype="${msg%%:*}"
      cscope=""
      has_scope=0
      ;;
    *)
      # No recognizable header.
      viol "--commit" "conventional-commit type" "no parseable type header in: $msg"
      return
      ;;
  esac

  # Type must be in COMMIT_TYPES.
  local found=0
  local t
  for t in $COMMIT_TYPES; do
    [ "$ctype" = "$t" ] && { found=1; break; }
  done
  if [ "$found" -eq 0 ]; then
    viol "--commit" "conventional-commit type" "unknown type '$ctype' (allowed: $COMMIT_TYPES)"
  fi

  # If a scope was present, it must be ASCII and match ^[a-z0-9-]+$.
  if [ "$has_scope" -eq 1 ] && [ -n "$cscope" ]; then
    if ! is_ascii "$cscope"; then
      viol "--commit" "conventional-commit scope" "non-ASCII scope: $cscope"
      return
    fi
    # Use matches_ascii_pattern so [a-z0-9-] is evaluated under LC_ALL=C,
    # preventing UTF-8 locale collation from admitting uppercase characters.
    if ! matches_ascii_pattern "$cscope" "[a-z0-9-]+"; then
      viol "--commit" "conventional-commit scope" "invalid scope '$cscope'"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

branch_arg=""
commit_arg=""
PATHS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --branch)
      [ "$#" -ge 2 ] || usage
      branch_arg="$2"; shift 2 ;;
    --commit)
      [ "$#" -ge 2 ] || usage
      commit_arg="$2"; shift 2 ;;
    --) shift; PATHS+=("$@"); break ;;
    -*)
      usage ;;
    *)
      PATHS+=("$1"); shift ;;
  esac
done

# At least one path or one of --branch/--commit is required.
if [ "${#PATHS[@]}" -eq 0 ] && [ -z "$branch_arg" ] && [ -z "$commit_arg" ]; then
  usage
fi

# Validate that every path argument exists.
# The "${PATHS[@]+...}" form keeps this safe under `set -u` on bash 3.2 (macOS)
# when PATHS is empty, e.g. a branch/commit-only invocation with no path.
for p in "${PATHS[@]+"${PATHS[@]}"}"; do
  if [ ! -e "$p" ]; then
    echo "language-guard: path not found: $p" >&2
    exit 2
  fi
done

# ---------------------------------------------------------------------------
# Run checks
# ---------------------------------------------------------------------------

fail=0

# Check branch and commit tokens if provided.
# Empty --branch "" or --commit "" is treated as not-provided and skipped.
[ -n "$branch_arg" ] && check_branch "$branch_arg"
[ -n "$commit_arg" ] && check_commit "$commit_arg"

# Check each path. Safe under `set -u` on bash 3.2 when PATHS is empty.
for p in "${PATHS[@]+"${PATHS[@]}"}"; do
  if [ -d "$p" ]; then
    check_directory "$p"
  else
    # Filename slug check applies to all files.
    check_filename "$p"
    # Frontmatter check applies only to .md files.
    case "$p" in
      *.md) check_frontmatter "$p" ;;
    esac
  fi
done

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

if [ "$fail" -eq 0 ]; then
  echo "language-guard: machine surfaces clean."
  exit 0
fi
exit 1
