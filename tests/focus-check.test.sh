#!/usr/bin/env bash
# Tests for bin/focus-check.sh (the /focus PreToolUse edit fence).
# Feeds fake PreToolUse JSON on stdin; the hook always exits 0 and either prints
# a deny decision (outside the zone) or nothing (neutral). Run:
#   bash tests/focus-check.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$TEST_DIR/../bin/focus-check.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

work="$(mktemp -d)"
mkdir -p "$work/.claude" "$work/src" "$work/other"
echo "$work/src" > "$work/.claude/focus-zone"

# run <json> -> echoes "<rc>\t<stdout+stderr>"
run() { local out rc; out="$(printf '%s' "$1" | CLAUDE_PROJECT_DIR="$work" bash "$HOOK" 2>&1)"; rc=$?; printf '%s\t%s' "$rc" "$out"; }
json() { printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2"; }

expect_neutral() { # name json
  local g; g="$(run "$2")"; local rc="${g%%$'\t'*}" out="${g#*$'\t'}"
  if [[ "$rc" == "0" && "$out" != *deny* ]]; then ok "$1"; else bad "$1 (rc=$rc, out=$out)"; fi
}
expect_deny() { # name json
  local g; g="$(run "$2")"; local rc="${g%%$'\t'*}" out="${g#*$'\t'}"
  if [[ "$rc" == "0" && "$out" == *'"deny"'* ]]; then ok "$1"; else bad "$1 (rc=$rc, out=$out)"; fi
}

# --- with a zone set ---
expect_neutral "inside the zone -> neutral"            "$(json Write "$work/src/a.ts")"
expect_deny    "outside the zone -> deny"              "$(json Write "$work/other/b.ts")"
expect_deny    "the zone dir's parent -> deny"         "$(json Edit  "$work/README.md")"
expect_deny    "'..' escape is physically resolved"    "$(json Write "$work/src/../other/c.ts")"
expect_neutral "a nested new file inside the zone"     "$(json Write "$work/src/deep/new/d.ts")"
expect_neutral "no file_path (e.g. a non-path tool)"   '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"ls"}}'
expect_neutral "malformed JSON -> fail open (neutral)" 'this is not json'

# --- no zone set -> always neutral ---
rm -f "$work/.claude/focus-zone"
expect_neutral "no focus zone -> neutral"              "$(json Write "$work/other/anything.ts")"

# --- empty zone file -> neutral ---
printf '\n' > "$work/.claude/focus-zone"
expect_neutral "empty focus-zone file -> neutral"      "$(json Write "$work/other/x.ts")"

rm -rf "$work"

# --- glob metacharacters in the zone path are matched LITERALLY, not as a glob ---
work2="$(mktemp -d)"
mkdir -p "$work2/.claude" "$work2/a[b]c" "$work2/abc"
printf '%s\n' "$work2/a[b]c" > "$work2/.claude/focus-zone"
g_run() { printf '%s' "$1" | CLAUDE_PROJECT_DIR="$work2" bash "$HOOK" 2>&1; }
out="$(g_run "$(json Write "$work2/a[b]c/x.ts")")"
if [[ "$out" != *deny* ]]; then ok "glob-metachar zone: inside is neutral"; else bad "glob zone inside (out=$out)"; fi
# 'abc' would match the class [b] if treated as a glob; literally it is outside -> deny
out="$(g_run "$(json Write "$work2/abc/y.ts")")"
if [[ "$out" == *'"deny"'* ]]; then ok "glob-metachar zone: sibling denied (literal, not glob)"; else bad "glob zone sibling (out=$out)"; fi
rm -rf "$work2"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
