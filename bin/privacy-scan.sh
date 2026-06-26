#!/usr/bin/env bash
#
# privacy-scan.sh, deterministic privacy guard.
#
# Scans a file (or stdin) for private/sensitive data that must not be published:
# emails, secrets/keys/tokens, private-key headers, absolute user paths, IPv4
# addresses, and the user's own deny-list terms. Prints findings and exits:
#   0 = clean   1 = findings (BLOCK)   2 = usage error
#
# Usage:
#   privacy-scan.sh <file>       scan a file
#   privacy-scan.sh -            scan stdin
#   echo "..." | privacy-scan.sh scan stdin
#
# Deny-list: one term per line in $CLAUDE_PRIVACY_DENYLIST
# (default ~/.claude/privacy-denylist.txt); '#' starts a comment.
#
# This is a safety net UNDER model sanitization + human approval, not a guarantee.
# Regex cannot catch every leak (paraphrased secrets, novel formats); it errs
# toward over-flagging on purpose, false positives are cheap given the override.

set -uo pipefail

DENYLIST="${CLAUDE_PRIVACY_DENYLIST:-$HOME/.claude/privacy-denylist.txt}"

# --- read input ---
if [[ $# -ge 1 && "$1" != "-" ]]; then
  if [[ ! -f "$1" ]]; then
    echo "privacy-scan: file not found: $1" >&2
    exit 2
  fi
  CONTENT="$(cat -- "$1")"
  SRC="$1"
else
  CONTENT="$(cat)"
  SRC="(stdin)"
fi

findings=0

report() { # report <category> <grep-output>
  local category="$1" hits="$2"
  if [[ -n "$hits" ]]; then
    echo "BLOCK [$category]:"
    printf '%s\n' "$hits" | sed 's/^/    /'
    findings=$((findings + 1))
  fi
}

grep_content() { # grep_content <regex>  (case-insensitive, line-numbered)
  # -e guards against patterns that start with '-' (e.g. "-----BEGIN ... KEY-----")
  printf '%s\n' "$CONTENT" | grep -nEi -e "$1" || true
}

# --- emails (allowlist GitHub noreply) ---
emails="$(grep_content '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
  | grep -viE '@users\.noreply\.github\.com' || true)"
report "email" "$emails"

# --- private-key headers ---
report "private-key" "$(grep_content '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----')"

# --- secret/key/token assignments ---
report "secret-assignment" "$(grep_content '[A-Za-z0-9_]*(api[_-]?key|secret|token|password|passwd|access[_-]?key|client[_-]?secret|bearer)[A-Za-z0-9_]*["'\'' ]*[:=]')"

# --- known token prefixes / formats ---
report "token" "$(grep_content '(ghp_|gho_|ghu_|ghs_|github_pat_)[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{16,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{20,}')"

# --- absolute user paths ---
report "local-path" "$(grep_content '/(Users|home)/[A-Za-z0-9._-]+/')"

# --- IPv4 addresses ---
report "ipv4" "$(grep_content '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')"

# --- user deny-list terms ---
if [[ -f "$DENYLIST" ]]; then
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    term="${raw%%#*}"                       # strip comment
    term="$(printf '%s' "$term" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [[ -z "$term" ]] && continue
    hits="$(printf '%s\n' "$CONTENT" | grep -nFi -- "$term" || true)"
    report "deny-list term: $term" "$hits"
  done < "$DENYLIST"
fi

# --- verdict ---
if [[ $findings -gt 0 ]]; then
  {
    echo ""
    echo "privacy-scan: $findings category/categories flagged in $SRC."
    echo "Redact these, or explicitly confirm each is a generic example (not real"
    echo "data), before publishing. Nothing should leave the machine until clear."
  } >&2
  exit 1
fi

echo "privacy-scan: clean ($SRC)."
exit 0
