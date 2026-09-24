#!/usr/bin/env bash
#
# focus-check.sh, the /focus session edit fence (Claude Code PreToolUse hook).
#
# Reads a PreToolUse event on stdin. When a focus zone is set (the project's
# .claude/focus-zone holds ONE absolute directory), it DENIES an Edit/Write/
# MultiEdit/NotebookEdit whose target path is outside that zone. Otherwise it
# stays NEUTRAL (prints nothing, exits 0, normal permission flow decides).
#
# Design:
#   - It ONLY ever DENIES; it never grants, so it can never override or weaken
#     normal permissions (no bypass).
#   - It FAILS OPEN on any error (no python3, unreadable state, unparseable
#     input): a convenience fence must never trap you. The permanent DO-NOT-TOUCH
#     boundary-check remains the hard guard.
#   - Paths are physically resolved (pwd -P) so ".." cannot escape the zone.
#
# Wired by the plugin's hooks/hooks.json (PreToolUse, matcher
# Edit|Write|MultiEdit|NotebookEdit). Deny = JSON permissionDecision on stdout +
# exit 0; neutral = no output + exit 0. Enforced on Claude Code; advisory on hosts
# without PreToolUse hooks (portability backlog).

set -uo pipefail

command -v python3 >/dev/null 2>&1 || exit 0   # cannot parse -> fail open

INPUT="$(cat)"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
ZONE_FILE="$ROOT/.claude/focus-zone"
[[ -f "$ZONE_FILE" ]] || exit 0                 # no fence active -> neutral

ZONE_RAW="$(head -n1 "$ZONE_FILE" 2>/dev/null | tr -d '\r')"
[[ -n "$ZONE_RAW" ]] || exit 0                  # empty state -> neutral
ZONE="$(cd "$ZONE_RAW" 2>/dev/null && pwd -P)" || exit 0
[[ -n "$ZONE" ]] || exit 0                      # zone dir gone -> fail open

# Target path from the event (robust JSON parse; empty on any trouble).
FP="$(printf '%s' "$INPUT" | python3 -c 'import sys, json
try:
    ti = (json.load(sys.stdin).get("tool_input") or {})
    print(ti.get("file_path") or ti.get("notebook_path") or "")
except Exception:
    print("")' 2>/dev/null)"
[[ -n "$FP" ]] || exit 0                         # nothing to judge -> neutral

# Physically resolve the target by resolving its deepest EXISTING ancestor and
# re-appending the not-yet-existing tail (a Write may target a new nested path).
# This normalizes macOS /var -> /private/var and defeats ".." escapes.
p="$FP"; tail=""
while [[ ! -e "$p" && "$p" == */* ]]; do
  tail="/$(basename "$p")$tail"; p="$(dirname "$p")"
done
if [[ -d "$p" ]]; then
  RP="$(cd "$p" 2>/dev/null && pwd -P)$tail" || exit 0
elif [[ -e "$p" ]]; then
  RP="$(cd "$(dirname "$p")" 2>/dev/null && pwd -P)/$(basename "$p")$tail" || exit 0
else
  RP="$p$tail"   # Edit/Write send an absolute file_path per the tool contract;
                 # an unexpected relative path lands here and is judged as-is (deny-safe).
fi

# Inside the zone (the dir itself or under it) -> neutral; normal flow decides.
# Literal compare (prefix-strip), never a glob match, so a zone path containing
# glob metacharacters (? * [ ]) can never be misinterpreted.
[[ "$RP" == "$ZONE" || "${RP#"$ZONE/"}" != "$RP" ]] && exit 0

# Outside the zone -> DENY. json.dumps escapes the paths safely (passed as argv).
python3 -c 'import json, sys
print(json.dumps({"hookSpecificOutput": {
  "hookEventName": "PreToolUse",
  "permissionDecision": "deny",
  "permissionDecisionReason": sys.argv[1]}}))' \
  "focus is on $ZONE; this edit targets $RP outside it. Run /focus off to edit elsewhere."
exit 0
