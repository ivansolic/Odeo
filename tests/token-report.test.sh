#!/usr/bin/env bash
#
# Tests for bin/token-report.py, the per-agent token/cost reporter.
# Feeds a synthetic transcript, asserts exit codes, per-agent rows, token math,
# and that a cost column appears only when both prices are passed.
# Run: bash tests/token-report.test.sh

set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="$TEST_DIR/../bin/token-report.py"
pass=0
fail=0

# write_fixture <path> : a transcript with main (2 turns) + 2 subagents + noise.
# Token math: billed input incl cache = 465, output = 200, total tokens = 665.
write_fixture() {
  cat > "$1" <<'EOF'
{"type":"assistant","message":{"usage":{"input_tokens":100,"output_tokens":50,"cache_creation_input_tokens":10,"cache_read_input_tokens":20}}}
{"type":"assistant","message":{"usage":{"input_tokens":200,"output_tokens":100,"cache_read_input_tokens":30}}}
{"type":"user","toolUseResult":{"agentId":"aaa","prompt":"Review code for Task 1\nmore","usage":{"input_tokens":40,"output_tokens":20,"cache_read_input_tokens":5}}}
{"type":"user","toolUseResult":{"agentId":"bbb","prompt":"Explore the repo\nmore","usage":{"input_tokens":60,"output_tokens":30}}}
{"type":"user","toolUseResult":"a plain string, not an agent, must be skipped"}
{"type":"user","message":{"content":"a normal user message, no usage"}}
this line is not json and must be skipped
EOF
}

# run <args...> -> echoes "<exit_code>\t<output>"
run() {
  local out rc
  out="$(python3 "$TOOL" "$@" 2>&1)"
  rc=$?
  printf '%s\t%s' "$rc" "$out"
}

expect_exit() { # expect_exit <name> <expected> <args...>
  local name="$1" want="$2"; shift 2
  local got; got="$(run "$@")"; local rc="${got%%$'\t'*}"
  if [[ "$rc" == "$want" ]]; then echo "ok   - $name"; pass=$((pass+1));
  else echo "FAIL - $name (expected exit $want, got $rc)"; fail=$((fail+1)); fi
}

expect_contains() { # expect_contains <name> <substr> <args...>
  local name="$1" sub="$2"; shift 2
  local got; got="$(run "$@")"; local rc="${got%%$'\t'*}"; local out="${got#*$'\t'}"
  if [[ "$rc" == "0" && "$out" == *"$sub"* ]]; then echo "ok   - $name"; pass=$((pass+1));
  else echo "FAIL - $name (rc=$rc, out missing '$sub')"; fail=$((fail+1)); fi
}

expect_missing() { # expect_missing <name> <substr> <args...>
  local name="$1" sub="$2"; shift 2
  local got; got="$(run "$@")"; local out="${got#*$'\t'}"
  if [[ "$out" != *"$sub"* ]]; then echo "ok   - $name"; pass=$((pass+1));
  else echo "FAIL - $name (out unexpectedly contains '$sub')"; fail=$((fail+1)); fi
}

# --- happy path over a synthetic transcript ---
FIX="$(mktemp)"; write_fixture "$FIX"
expect_exit      "valid transcript exits 0"          0 "$FIX"
expect_contains  "shows the main session row"        "main" "$FIX"
expect_contains  "labels subagent A by its prompt"   "Review code for Task 1" "$FIX"
expect_contains  "labels subagent B by its prompt"   "Explore the repo" "$FIX"
expect_contains  "token math: total tokens = 665"    "665" "$FIX"

# --- unpriced vs priced ---
expect_contains  "unpriced says tokens only"         "tokens only" "$FIX"
expect_missing   "unpriced has no cost line"         "estimated cost" "$FIX"
expect_contains  "priced prints estimated cost"      "estimated cost:" "$FIX" --input-price 3 --output-price 15
expect_contains  "priced adds a cost column header"  "cost" "$FIX" --input-price 3 --output-price 15

# --- input validation ---
expect_exit      "only one price is a usage error"   2 "$FIX" --input-price 3
expect_exit      "missing path is a usage error"     2 "/no/such/transcript.jsonl"
rm -f "$FIX"

# --- no usage data -> exit 1 ---
EMPTY="$(mktemp)"; printf 'this is not json\n{"type":"system"}\n' > "$EMPTY"
expect_exit      "no usage data exits 1"             1 "$EMPTY"
rm -f "$EMPTY"

# --- directory argument picks the newest .jsonl ---
DIR="$(mktemp -d)"; write_fixture "$DIR/session.jsonl"
expect_exit      "directory arg finds the transcript" 0 "$DIR"
rm -rf "$DIR"

# --- hostile input: valid JSON that is not a usage-shaped object must not crash ---
HOSTILE="$(mktemp)"
cat > "$HOSTILE" <<'EOF'
{"type":"assistant","message":{"usage":{"input_tokens":10,"output_tokens":5}}}
[1,2,3]
"just a string"
42
true
null
{"type":"assistant","message":{"usage":null}}
{"type":"user","toolUseResult":{"agentId":"zzz","usage":{"input_tokens":"lots","output_tokens":-9}}}
EOF
expect_exit      "hostile JSON lines do not crash"    0 "$HOSTILE"
expect_missing   "hostile input leaks no traceback"   "Traceback" "$HOSTILE"
rm -f "$HOSTILE"

# --- unreadable file is a usage error (skipped if still readable, e.g. as root) ---
UNREAD="$(mktemp)"; write_fixture "$UNREAD"; chmod 000 "$UNREAD"
if [[ ! -r "$UNREAD" ]]; then
  expect_exit    "unreadable file is a usage error"   2 "$UNREAD"
else
  echo "skip - unreadable file test (file still readable as this user)"
fi
chmod 644 "$UNREAD"; rm -f "$UNREAD"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
