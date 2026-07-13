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
  ( cd "$d" && git init -q && mkdir -p "$(dirname "$1")" && printf '%s\n' "$2" > "$1" && git add "$1" ) >/dev/null 2>&1
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

# Test fixtures: the credential-ASSIGNMENT heuristic must not fire on test files
# (spec/e2e fixtures legitimately write password:/token: literals), while the
# hard format rules (sk_live_, ghp_, private keys, .env names) stay global,
# a REAL secret pasted into a test is still a leak.
check "password literal in a .spec file is ALLOWED"   0 auth.spec.ts      "it('rejects', () => login({ password: 'not my password' }))"
check "token literal under test/ is ALLOWED"          0 test/session.ts   "const fixture = { token: 'tok-residual-123456' }"
check "token literal in an e2e-spec is ALLOWED"       0 app.e2e-spec.ts   "await request(app).send({ password: 'wrong horse battery' })"
check "REAL sk_live token in a .spec file still BLOCKS" 1 pay.spec.ts     "const k = 'sk_live_abcdef123456789012'"
check "private key in a test file still BLOCKS"       1 test/key.spec.ts  '-----BEGIN RSA PRIVATE KEY-----'

# Subdirectory invocation must scan the WHOLE staged set, not the cwd subtree
# (regression: cwd-relative pathspec let root-level secrets pass when the scan
# ran from a subdir, e.g. via /commit-push or an agent in a package folder).
d="$(mktemp -d)"
( cd "$d" && git init -q && mkdir -p sub \
  && echo 'const t = "ghp_ABCdef0123456789ABCdef0123456789ABCD"' > root-leak.ts \
  && git add root-leak.ts ) >/dev/null 2>&1
( cd "$d/sub" && bash "$SCAN" ) >/dev/null 2>&1; rc=$?
rm -rf "$d"
if [[ $rc -eq 1 ]]; then echo "ok   - subdir invocation still catches root-level secrets"; pass=$((pass+1));
else echo "FAIL - subdir invocation missed a root-level secret (rc=$rc, want 1)"; fail=$((fail+1)); fi

# Non-JS test files are also fixtures (Ruby/Python naming)
check "password literal in a _spec.rb file is ALLOWED" 0 auth_spec.rb "creds = { password: 'wrong guess here' }"
check "password literal in test_*.py is ALLOWED"        0 test_auth.py "creds = { 'password': 'wrong guess here' }"

# usage error: not a git repo
d="$(mktemp -d)"; ( cd "$d" && bash "$SCAN" ) >/dev/null 2>&1; rc=$?
rm -rf "$d"
if [[ $rc -eq 2 ]]; then echo "ok   - outside a git repo exits 2"; pass=$((pass+1)); else echo "FAIL - non-repo rc=$rc (want 2)"; fail=$((fail+1)); fi

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
