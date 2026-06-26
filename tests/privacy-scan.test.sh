#!/usr/bin/env bash
#
# Tests for bin/privacy-scan.sh, the deterministic privacy guard.
# Feeds known-clean and known-dirty content, asserts exit codes (0 clean, 1 block)
# and that findings name the right category. Run: bash tests/privacy-scan.test.sh

set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN="$TEST_DIR/../bin/privacy-scan.sh"

pass=0
fail=0

# run <content>  -> echoes "<exit_code>\t<output>"
run() {
  local f rc out
  f="$(mktemp)"
  printf '%s\n' "$1" > "$f"
  out="$(bash "$SCAN" "$f" 2>&1)"
  rc=$?
  rm -f "$f"
  printf '%s\t%s' "$rc" "$out"
}

expect_exit() { # expect_exit <name> <expected> <content>
  local got; got="$(run "$3")"; local rc="${got%%$'\t'*}"
  if [[ "$rc" == "$2" ]]; then echo "ok   - $1"; pass=$((pass+1));
  else echo "FAIL - $1 (expected exit $2, got $rc)"; fail=$((fail+1)); fi
}

expect_block_mentions() { # expect_block_mentions <name> <substr> <content>
  local got; got="$(run "$3")"; local rc="${got%%$'\t'*}"; local out="${got#*$'\t'}"
  if [[ "$rc" == "1" && "$out" == *"$2"* ]]; then echo "ok   - $1"; pass=$((pass+1));
  else echo "FAIL - $1 (rc=$rc, out missing '$2')"; fail=$((fail+1)); fi
}

# --- clean content passes ---
expect_exit "clean prose passes" 0 "This is a generic lesson about caching. Use a TTL and invalidate on write."

# --- emails ---
expect_block_mentions "real email blocks" "email" "Contact jane.doe@example.com for details."
expect_exit "github noreply email is allowlisted" 0 "Commits use 12345+jane@users.noreply.github.com as author."

# --- secrets ---
expect_block_mentions "secret assignment blocks" "secret" "Set API_KEY=sk_live_abcdef123456 in the env."
expect_exit "private key header blocks" 1 "-----BEGIN RSA PRIVATE KEY-----"
expect_exit "github token prefix blocks" 1 "token ghp_ABCdef0123456789ABCdef0123456789ABCD"

# --- local paths ---
expect_block_mentions "absolute user path blocks" "path" "Edit the file at /Users/jane/code/secret-project/app.ts"

# --- ipv4 ---
expect_exit "ipv4 blocks" 1 "Connect to the server at 10.0.12.34 on port 5432."

# --- deny-list (user-configured) ---
DENY="$(mktemp)"; printf '# my private terms\nacmecorp\nfleetview\n' > "$DENY"
deny_run() { local f out rc; f="$(mktemp)"; printf '%s\n' "$2" > "$f"; out="$(CLAUDE_PRIVACY_DENYLIST="$DENY" bash "$SCAN" "$f" 2>&1)"; rc=$?; rm -f "$f"; printf '%s\t%s' "$rc" "$out"; }
got="$(deny_run x "We built this for AcmeCorp internal tools.")"; rc="${got%%$'\t'*}"; out="${got#*$'\t'}"
if [[ "$rc" == "1" && "$out" == *"acmecorp"* ]]; then echo "ok   - deny-list term blocks (case-insensitive)"; pass=$((pass+1)); else echo "FAIL - deny-list term (rc=$rc, out='$out')"; fail=$((fail+1)); fi
got="$(deny_run x "A generic example with no private terms.")"; rc="${got%%$'\t'*}"
if [[ "$rc" == "0" ]]; then echo "ok   - clean content with deny-list set still passes"; pass=$((pass+1)); else echo "FAIL - clean with deny-list (rc=$rc)"; fail=$((fail+1)); fi
rm -f "$DENY"

# --- usage error ---
bash "$SCAN" /no/such/file >/dev/null 2>&1; [[ $? -eq 2 ]] && { echo "ok   - missing file exits 2"; pass=$((pass+1)); } || { echo "FAIL - missing file exit code"; fail=$((fail+1)); }

echo ""
echo "passed: $pass, failed: $fail"
[[ $fail -eq 0 ]]
