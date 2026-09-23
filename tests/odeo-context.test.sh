#!/usr/bin/env bash
# Tests for hooks/odeo-context.sh: the plugin's SessionStart and SubagentStart hook.
#
# It replaces what install.sh used to write into ~/.claude/CLAUDE.md. Claude Code caps each
# hook's additionalContext at 10,000 characters and measures every hook separately
# (code.claude.com/docs/en/hooks, "capped at 10,000 characters"), so the whole
# global/CLAUDE.md is delivered as numbered parts, one hook registration per part. The
# guarantees under test are OUTCOMES: the parts rejoin to exactly the file, no part is over
# budget, hooks.json registers enough parts, and nothing ever blocks a session (exit 0).
#
# Observed failing (2026-09-23), each mutant checked to differ from the original:
#   M1 drop the `^` anchor on the marker grep           -> 1 FAIL (case 3)
#   M2 user_has_baseline always false                   -> 2 FAIL (case 2)
#   M3 no leading-comment strip                         -> 2 FAIL (cases 1, 1b)
#   M4 language nudge regardless of scope               -> 1 FAIL (case 4)
#   M5 budget raised from 9500 to 20000                 -> 3 FAIL (cases 1, 6)
#   M6 `exit 1` after the missing-baseline warning      -> 1 FAIL (case 5)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/hooks/odeo-context.sh"
JSON="$ROOT/hooks/hooks.json"
BUDGET=9500                                # below the documented 10,000 cap, with margin
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_exit() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi; }
assert_contains() { case "$3" in *"$2"*) ok "$1";; *) bad "$1 (missing '$2')";; esac; }
assert_absent() { case "$3" in *"$2"*) bad "$1 (unexpected '$2')";; *) ok "$1";; esac; }
assert_empty() { if [ -z "$2" ]; then ok "$1"; else bad "$1 (expected no output)"; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
MARKER="## Security Baseline (non-negotiable, applies to ALL code)"
NUDGE="output language is not set"

# ctx <json>: prints "<event>\n<additionalContext><<END>>" for one hook output ("" for no
# output), or INVALID when it is not the documented JSON shape. The <<END>> sentinel keeps
# trailing newlines, which a command substitution would otherwise strip.
ctx() {
  printf '%s' "$1" | python3 -c '
import json, sys
raw = sys.stdin.read()
if not raw.strip():
    sys.exit(0)
try:
    d = json.loads(raw)["hookSpecificOutput"]
    sys.stdout.write(d["hookEventName"] + "\n" + d["additionalContext"] + "<<END>>")
except Exception:
    sys.stdout.write("INVALID")'
}

# 1) no user global: parts rejoin to EXACTLY global/CLAUDE.md minus its header comment,
#    each part is within budget, carries the right event, and the part after the last is empty
expected="$TMP/expected.md"
awk 'NR==1 && /^<!--/{s=1} s{if(/-->/)s=0; next} {print}' "$ROOT/global/CLAUDE.md" > "$expected"
rejoined="$TMP/rejoined.md"; : > "$rejoined"
n=0; over=0; wrong_event=0
for part in 1 2 3 4 5 6; do
  out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$HOOK" baseline "$part" SubagentStart)"; rc=$?
  [ "$rc" = 0 ] || bad "part $part exits $rc"
  c="$(ctx "$out")"
  [ -z "$c" ] && break
  [ "$c" = "INVALID" ] && { bad "part $part is not valid hook JSON"; break; }
  n=$part
  [ "${c%%$'\n'*}" = "SubagentStart" ] || wrong_event=1
  body="${c#*$'\n'}"; body="${body%<<END>>}"
  [ "$(printf '%s' "$body" | python3 -c 'import sys; print(len(sys.stdin.read()))')" -le "$BUDGET" ] || over=1
  printf '%s\n' "$body" | sed '1,/^$/d' >> "$rejoined"    # drop the per-part header + blank line
done
[ "$n" -ge 2 ] && ok "baseline delivered in $n parts" || bad "expected at least 2 parts, got $n"
[ "$over" = 0 ] && ok "every part within $BUDGET chars" || bad "a part exceeds $BUDGET chars"
[ "$wrong_event" = 0 ] && ok "hookEventName echoes the event" || bad "wrong hookEventName"
if cmp -s "$expected" "$rejoined"; then ok "parts rejoin to exactly the whole file"
else bad "parts do not rejoin to the whole file"; diff "$expected" "$rejoined" | head -5; fi
# 1b) the install-era header comment is not delivered
first="$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$HOOK" baseline 1 SessionStart)")"
assert_absent "install-era header comment stripped" "copy it to ~/.claude/CLAUDE.md" "$first"
assert_contains "part header names the source" "Odeo global baseline" "$first"

# 2) user global carries the baseline: no part is emitted, for either event
cfg="$TMP/own.md"; printf '# Mine\n%s\n- rules\n' "$MARKER" > "$cfg"
assert_empty "own baseline -> SessionStart part 1 empty" "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" baseline 1 SessionStart)"
assert_empty "own baseline -> SubagentStart part 1 empty" "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" baseline 1 SubagentStart)"

# 3) a marker quoted mid-line does not count (it must be the user's own heading)
cfg="$TMP/quoted.md"; printf '# Mine\nsee "%s" upstream\n' "$MARKER" > "$cfg"
assert_contains "quoted marker still injects" "Global Instructions" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" baseline 1 SessionStart)")"

# 4) language: unset and invalid ask once, a valid global line stays silent
assert_contains "no language -> nudge" "$NUDGE" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$HOOK" language SessionStart)")"
assert_contains "nudge names the writer" "set-global-language.sh" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$HOOK" language SessionStart)")"
cfg="$TMP/bad-lang.md"; printf '# Mine\noutput_language: klingon\n' > "$cfg"
assert_contains "invalid language -> nudge" "$NUDGE" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" language SessionStart)")"
cfg="$TMP/lang.md"; printf '# Mine\noutput_language: de\n' > "$cfg"
assert_empty "language set -> silent" "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" language SessionStart)"

# 5) broken install (no global/CLAUDE.md, no language scripts): says so, still exit 0
fake="$TMP/fake-plugin"; mkdir -p "$fake/hooks"; cp "$HOOK" "$fake/hooks/"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$fake/hooks/odeo-context.sh" baseline 1 SessionStart)"; rc=$?
assert_exit "missing baseline -> still 0" 0 "$rc"
assert_contains "names the missing baseline" "baseline file not found" "$(ctx "$out")"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$fake/hooks/odeo-context.sh" language SessionStart)"; rc=$?
assert_exit "missing language check -> still 0" 0 "$rc"
assert_contains "names the missing language check" "language check unavailable" "$(ctx "$out")"

# 6) an oversized single section is split by lines, never emitted over budget
big="$TMP/big-plugin"; mkdir -p "$big/hooks" "$big/global"; cp "$HOOK" "$big/hooks/"
{ echo "# G"; echo "## Huge"; for i in $(seq 1 400); do echo "- rule line $i padded to a realistic length for a baseline"; done; } > "$big/global/CLAUDE.md"
over=0; got=0
for part in 1 2 3 4 5 6; do
  c="$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$big/hooks/odeo-context.sh" baseline "$part" SessionStart)")"
  [ -z "$c" ] && break; got=$part
  [ "$(b="${c#*$'\n'}"; printf '%s' "${b%<<END>>}" | python3 -c 'import sys; print(len(sys.stdin.read()))')" -le "$BUDGET" ] || over=1
done
[ "$over" = 0 ] && ok "oversized section split within budget ($got parts)" || bad "oversized section emitted over budget"

# 7) hooks.json registers every part the real file needs, for BOTH events, and the
#    language question for the main session only (a subagent must not ask the user)
python3 - "$JSON" "$n" <<'EOF' && ok "hooks.json registers parts 1..$n for both events, language on SessionStart only" || { bad "hooks.json registration"; }
import json, re, sys
hooks = json.load(open(sys.argv[1]))["hooks"]
need = int(sys.argv[2])
def cmds(event):
    return [h["command"] for g in hooks.get(event, []) for h in g["hooks"]]
for event in ("SessionStart", "SubagentStart"):
    parts = {int(m.group(1)) for c in cmds(event)
             for m in [re.search(r'odeo-context\.sh" baseline (\d+) ' + event + r'$', c)] if m}
    assert set(range(1, need + 1)) <= parts, (event, parts)
    assert all("${CLAUDE_PLUGIN_ROOT}/hooks/odeo-context.sh" in c for c in cmds(event))
assert any(c.endswith("language SessionStart") for c in cmds("SessionStart"))
assert not any("language" in c for c in cmds("SubagentStart"))
EOF
if [ -x "$HOOK" ]; then ok "hook is executable"; else bad "hook is not executable"; fi

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
