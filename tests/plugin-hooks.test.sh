#!/usr/bin/env bash
# Tests the tool hooks in hooks/hooks.json (the focus fence and the end-of-turn sweep).
#
# In a plugin install they cannot stay in the project template's .claude/settings.json:
# those commands found the scripts through PATH, and Claude Code puts a plugin's bin/ on
# the Bash tool's PATH only, so they would silently do nothing. hooks.json runs them via
# ${CLAUDE_PLUGIN_ROOT} instead. focus-check is inert without a focus zone, so it runs in
# every project; session-end-check is gated to Odeo projects (.claude/tasks/todo.md),
# because a Stop hook fires after every reply and would otherwise report in all projects.
#
# Each case runs the EXACT command string from hooks.json, with the two variables Claude
# Code provides to hook processes (CLAUDE_PLUGIN_ROOT, CLAUDE_PROJECT_DIR).
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 drop the Odeo-project gate on Stop      -> 1 FAIL (case 2, silent outside)
#   M2 narrow the matcher to Edit|Write        -> 1 FAIL (case 1, matcher)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }
assert_empty() { if [ -z "$2" ]; then ok "$1"; else bad "$1 (unexpected output: ${2:0:80})"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# hook_cmd <event> <script>: the single hooks.json command for <event> that runs <script>
hook_cmd() {
  python3 - "$ROOT/hooks/hooks.json" "$1" "$2" <<'EOF'
import json, sys
hooks = json.load(open(sys.argv[1]))["hooks"].get(sys.argv[2], [])
cmds = [(g.get("matcher", ""), h["command"]) for g in hooks for h in g["hooks"] if sys.argv[3] in h["command"]]
assert len(cmds) == 1, cmds
print(cmds[0][0]); print(cmds[0][1])
EOF
}
run_hook() { # run_hook <command> <plugin-root> <project-dir> [stdin]
  ( cd "$3" && printf '%s' "${4:-}" | CLAUDE_PLUGIN_ROOT="$2" CLAUDE_PROJECT_DIR="$3" bash -c "$1" 2>&1 )
}

# 1) focus-check: registered on the edit tools, and a set zone DENIES an edit outside it
spec="$(hook_cmd PreToolUse focus-check.sh)" || { bad "PreToolUse focus-check not registered exactly once"; spec=$'\n'; }
matcher="${spec%%$'\n'*}"; cmd="${spec#*$'\n'}"
[ "$matcher" = "Edit|Write|MultiEdit|NotebookEdit" ] && ok "focus-check matcher covers the edit tools" || bad "focus-check matcher is '$matcher'"
proj="$TMP/proj"; mkdir -p "$proj/.claude" "$proj/zone" "$proj/elsewhere"; git init -q "$proj"
printf '%s\n' "$(cd "$proj/zone" && pwd -P)" > "$proj/.claude/focus-zone"
event="{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$(cd "$proj/elsewhere" && pwd -P)/a.ts\"}}"
assert_contains "edit outside the zone is denied" '"deny"' "$(run_hook "$cmd" "$ROOT" "$proj" "$event")"
event="{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$(cd "$proj/zone" && pwd -P)/a.ts\"}}"
assert_empty "edit inside the zone is neutral" "$(run_hook "$cmd" "$ROOT" "$proj" "$event")"
rm "$proj/.claude/focus-zone"
assert_empty "no zone: neutral in any project" "$(run_hook "$cmd" "$ROOT" "$proj" "$event")"

# 2) session-end-check: runs only in an Odeo project (stub root proves whether it ran)
spec="$(hook_cmd Stop session-end-check.sh)" || { bad "Stop session-end-check not registered exactly once"; spec=$'\n'; }
cmd="${spec#*$'\n'}"
fake="$TMP/fake-root"; mkdir -p "$fake/bin"
printf '#!/usr/bin/env bash\necho SWEEP-RAN\n' > "$fake/bin/session-end-check.sh"; chmod +x "$fake/bin/session-end-check.sh"
plain="$TMP/plain"; mkdir -p "$plain"
assert_empty "Stop sweep silent outside Odeo projects" "$(run_hook "$cmd" "$fake" "$plain")"
odeo="$TMP/odeo"; mkdir -p "$odeo/.claude/tasks"; touch "$odeo/.claude/tasks/todo.md"
assert_contains "Stop sweep runs in an Odeo project" "SWEEP-RAN" "$(run_hook "$cmd" "$fake" "$odeo")"

# 3) the project template no longer registers them (no double run, no PATH dependency)
tmpl="$(cat "$ROOT/project-templates/claude-settings.json")"
case "$tmpl" in *focus-check*|*session-end-check*) bad "project template still wires the hooks";; *) ok "project template leaves the hooks to the plugin";; esac
python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$ROOT/project-templates/claude-settings.json" \
  && ok "project template is valid JSON" || bad "project template is not valid JSON"

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
