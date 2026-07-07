#!/usr/bin/env bash
# Tests for bin/secret-scan.sh, the commit-time secret gate.
# Scans STAGED content for secrets only (narrower than privacy-scan: code commits
# legitimately contain emails/paths; secrets never). Run: bash tests/secret-scan.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN="$TEST_DIR/../bin/secret-scan.sh"
pass=0; fail=0

# Helper: make a temp git repo, stage given file content, run the scan there.
run_staged() { # run_staged <filename> <content> -> echoes "<rc>\t<out>"
  local d rc out
  d="$(mktemp -d)"
  ( cd "$d" && git init -q && printf '%s\n' "$2" > "$1" && git add "$1" ) >/dev/null 2>&1
  out="$(cd "$d" && bash "$SCAN" 2>&1)"; rc=$?
  rm -rf "$d"
  printf '%s\t%s' "$rc" "$out"
}
check() { # check <name> <expected_rc> <filename> <content>
  local got rc; got="$(run_staged "$3" "$4")"; rc="${got%%$'\t'*}"
  if [[ "$rc" == "$2" ]]; then echo "ok   - $1"; pass=$((pass+1));
  else echo "FAIL - $1 (expected rc=$2, got rc=$rc)"; fail=$((fail+1)); fi
}

check "clean code passes"                    0 app.ts   'export function add(a: number, b: number) { return a + b }'
check "email in code is ALLOWED (not a secret)" 0 authors.ts 'export const maintainer = "jane.doe@example.com"'
check "private key blocks"                   1 key.pem  '-----BEGIN RSA PRIVATE KEY-----'
check "api key assignment blocks"            1 conf.ts  'const API_KEY = "sk_live_abcdef123456789012"'
check "github token blocks"                  1 ci.yml   'token: ghp_ABCdef0123456789ABCdef0123456789ABCD'
check "aws key blocks"                       1 env.ts   'const key = "AKIAIOSFODNN7EXAMPLE"'
check "password assignment blocks"           1 db.ts    'const DB_PASSWORD = "hunter2secret"'
check "staged .env file blocks by NAME"      1 .env     'ANYTHING=at all'

# usage error: not a git repo
d="$(mktemp -d)"; ( cd "$d" && bash "$SCAN" ) >/dev/null 2>&1; rc=$?
rm -rf "$d"
if [[ $rc -eq 2 ]]; then echo "ok   - outside a git repo exits 2"; pass=$((pass+1)); else echo "FAIL - non-repo rc=$rc (want 2)"; fail=$((fail+1)); fi

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
