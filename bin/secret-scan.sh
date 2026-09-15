#!/usr/bin/env bash
#
# secret-scan.sh, the commit-time secret gate (enforced guardrail).
#
# Scans STAGED changes for secrets and blocks the commit path when found.
# Narrower than privacy-scan.sh on purpose: code commits legitimately contain
# emails and file paths; they must never contain credentials.
#
# Checks:
#   - staged file NAMES that must never be committed (.env and variants)
#   - private key blocks, known token formats (GitHub, AWS, Slack, Google, sk-)
#   - credential assignments (API_KEY/SECRET/TOKEN/PASSWORD = "value")
#
# Exit codes: 0 clean · 1 secrets found (BLOCK) · 2 usage error (not a git repo)
# Used by: /commit-push (hard gate) and the pre-commit hook (install-git-guards.sh).

set -uo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "secret-scan: not a git repository" >&2
  exit 2
}

# Always scan from the repo root: pathspecs are cwd-relative, so a scan invoked
# from a subdirectory would silently see only that subtree (and miss staged
# secrets elsewhere). Anchoring here also anchors the exclude globs.
cd "$(git rev-parse --show-toplevel)"

findings=0

# 1. Forbidden file names in the stage (.env and friends)
forbidden_names="$(git diff --cached --name-only --diff-filter=ACM | grep -E '(^|/)\.env(\..+)?$' || true)"
if [[ -n "$forbidden_names" ]]; then
  echo "BLOCK [env-file staged]:"
  printf '%s\n' "$forbidden_names" | sed 's/^/    /'
  findings=$((findings + 1))
fi

# 2. Content of staged changes (added lines only)
staged_added() { # staged_added [extra git pathspecs...]
  git diff --cached --unified=0 --diff-filter=ACM -- . "$@" \
    | grep -E '^\+' | grep -vE '^\+\+\+' || true
}
scan() { # scan <label> <regex> [extra pathspecs...]
  local label="$1" regex="$2"; shift 2
  local hits
  hits="$(staged_added "$@" | grep -nEi -e "$regex" || true)"
  if [[ -n "$hits" ]]; then
    echo "BLOCK [$label]:"
    printf '%s\n' "$hits" | sed 's/^/    /'
    findings=$((findings + 1))
  fi
}

# Test files legitimately assign harmless literals to password:/token: keys
# (fixtures, wrong-guess specs). The blunt ASSIGNMENT heuristic skips them;
# the hard format rules below still cover tests, a real key is a leak anywhere.
TEST_EXCLUDES=(
  ':(exclude,glob)**/*.spec.*'  ':(exclude,glob)**/*.test.*'
  ':(exclude,glob)**/*.e2e-spec.*'
  ':(exclude,glob)**/*_spec.*'  ':(exclude,glob)**/*_test.*'
  ':(exclude,glob)**/test_*.*'
  ':(exclude,glob)**/test/**'   ':(exclude,glob)**/tests/**'
  ':(exclude,glob)**/__tests__/**' ':(exclude,glob)**/__fixtures__/**'
)

scan "private-key"       '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'
scan "token"             '(ghp_|gho_|ghu_|ghs_|github_pat_)[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_]{16,}|sk_(live|test)_[A-Za-z0-9]{10,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{20,}'
scan "credential-assignment" '[A-Za-z0-9_]*(api[_-]?key|secret|token|password|passwd|access[_-]?key|client[_-]?secret)[A-Za-z0-9_]*["'"'"' ]*[:=][ ]*["'"'"'][^"'"'"']{6,}' "${TEST_EXCLUDES[@]}"

if [[ $findings -gt 0 ]]; then
  {
    echo ""
    echo "secret-scan: $findings finding group(s) in the STAGED changes. Commit blocked."
    echo "Remove the secret (use environment variables or a secrets manager), unstage"
    echo "the file, and if the value was real, treat it as leaked: rotate it."
  } >&2
  exit 1
fi

echo "secret-scan: staged changes clean."
exit 0
