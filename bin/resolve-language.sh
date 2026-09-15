#!/usr/bin/env bash
# resolve-language.sh, deterministic output-language resolver.
#
# Reads the effective output language for a project by applying a three-level
# precedence: project CLAUDE.md, global CLAUDE.md, then falls back to "en".
# Echoes exactly one valid code (en|de|hr|fr) and exits 0.
# This script READS a stored preference and localizes nothing; machine surfaces
# always stay English regardless of the resolved code.
#
# Usage:
#   resolve-language.sh <project-dir>
#
# Exit codes:
#   0  effective code written to stdout
#   2  usage error (wrong number of args, or project dir not found)
#
# Consumed by bin/init-project.sh and future stories (USR-005 prose localization)
# as the single source of truth for the effective language.
#
# Global config path is overridable via CLAUDE_GLOBAL_CONFIG so tests never
# touch the real $HOME/.claude/CLAUDE.md (matches the CLAUDE_TEMPLATES_DIR
# override pattern already in init-project.sh).
set -uo pipefail

usage() { echo "usage: resolve-language.sh <project-dir>" >&2; exit 2; }

[ "$#" -eq 1 ] || usage

PROJECT_DIR="$1"
[ -d "$PROJECT_DIR" ] || { echo "resolve-language: project dir not found: $PROJECT_DIR" >&2; exit 2; }

# Valid language codes. Kept as a literal list here; init-project.sh carries its
# own copy so neither file depends on the other (two files, not over-engineered).
VALID="en de hr fr"

# Global config path: env override for tests, then the real user config.
GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}"

# read_lang FILE
# Reads the first output_language: line from FILE, normalizes the value
# (strip CR, strip surrounding whitespace, lowercase), and prints it only if
# it is a recognized code. Prints nothing and returns 0 for any other outcome
# (file absent, no matching line, invalid value), so the caller can fall through.
read_lang() {
  local file="$1"
  [ -f "$file" ] || return 0
  local raw
  raw="$(grep -m1 -E '^output_language:' "$file" 2>/dev/null || true)"
  [ -n "$raw" ] || return 0
  local val
  val="$(printf '%s' "$raw" | sed -E 's/^output_language:[[:space:]]*//' \
        | tr -d '\r' | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[[:space:]]+$//')"
  local c
  for c in $VALID; do [ "$val" = "$c" ] && { printf '%s' "$c"; return 0; }; done
  return 0   # invalid value: echo nothing, caller falls through to next level
}

# Apply precedence: project -> global -> en.
lang="$(read_lang "$PROJECT_DIR/CLAUDE.md")"
[ -n "$lang" ] || lang="$(read_lang "$GLOBAL_CONFIG")"
[ -n "$lang" ] || lang="en"
printf '%s\n' "$lang"
exit 0
