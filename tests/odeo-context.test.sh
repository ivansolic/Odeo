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
#   M7 legacy check ignores ~/.claude/odeo-docs          -> 1 FAIL (case 4b)
#   M8 apply the dialog value every session             -> 2 FAIL (case 4c, clobbers /language)
#   M9 no first-run keep of an existing language        -> 3 FAIL (case 4c)
#   M10 no state on a refused write                     -> 1 FAIL (case 4d, repeats)
# Observed failing (2026-09-29), after the move to scripts/:
#   M11 no outdated-guard check                         -> 3 FAIL (case 4e)
#   M12 an Odeo hook counts as outdated even with scripts/ -> 2 FAIL (case 4e)
#   M13 no ${CLAUDE_PLUGIN_ROOT} substitution           -> 5 FAIL (cases 1, 4, 4b)
#   M14 any hook counts as Odeo's                       -> 1 FAIL (case 4e, foreign hook)
#   M15 ~/bin shims not checked                         -> 1 FAIL (case 4e, shim)
#   M16 root passed with awk -v instead of ENVIRON       -> 1 FAIL (case 1a)
#   M17 outdated = "no scripts/ glob" instead of "no ODEO_HOOKS_VERSION=2" -> 1 FAIL (case 4e, 0.3.0 hook)
#   M18 a current hook's find check dropped            -> 1 FAIL (case 4e, moved clone)
#   M19 exact version match instead of a number        -> 2 FAIL (case 4e, newer version)
#   M20 baked values used without the plain-path filter -> 1 FAIL (case 4e, space in path)
#   M21 recorded config root dropped from hook_finds (the round-3 bug) -> 1 FAIL (case 4e, config X)
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
unset CLAUDE_CONFIG_DIR   # a real config dir with a cached Odeo would answer instead of the fixtures
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
# ... with every ${CLAUDE_PLUGIN_ROOT} replaced by the plugin root: hook output is not
# substituted by Claude Code, so the hook does it (program paths in the baseline).
awk 'NR==1 && /^<!--/{s=1} s{if(/-->/)s=0; next} {print}' "$ROOT/global/CLAUDE.md" \
  | R="$ROOT" perl -pe 's/\$\{CLAUDE_PLUGIN_ROOT\}/$ENV{R}/g' > "$expected"
grep -q 'CLAUDE_PLUGIN_ROOT' "$ROOT/global/CLAUDE.md" && ok "instrument: the baseline names a plugin-root path" \
  || bad "instrument: the baseline has no \${CLAUDE_PLUGIN_ROOT} path, so the substitution below is untested"
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
grep -q 'CLAUDE_PLUGIN_ROOT' "$rejoined" && bad "a literal \${CLAUDE_PLUGIN_ROOT} reached the context" \
  || ok "no literal \${CLAUDE_PLUGIN_ROOT} reaches the context"
grep -qF "$ROOT/scripts/resolve-language.sh" "$rejoined" && ok "the baseline names the real program path" \
  || bad "the baseline does not name $ROOT/scripts/resolve-language.sh"
if cmp -s "$expected" "$rejoined"; then ok "parts rejoin to exactly the whole file"
else bad "parts do not rejoin to the whole file"; diff "$expected" "$rejoined" | head -5; fi
# 1a) a root whose path holds a backslash sequence is placed literally (awk -v would turn
#     \t into a tab; the 0.3.0 review measured it)
odd="$TMP/odd\\troot"; mkdir -p "$odd/hooks" "$odd/global"; cp "$HOOK" "$odd/hooks/"
printf 'run ${CLAUDE_PLUGIN_ROOT}/scripts/x.sh\n' > "$odd/global/CLAUDE.md"
c="$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$odd/hooks/odeo-context.sh" baseline 1 SessionStart)")"
case "$c" in *"$odd/scripts/x.sh"*) ok "a backslash in the root path stays literal";;
  *) bad "the root path was altered on the way into the context";; esac
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
assert_contains "nudge names the writer by its path" "$ROOT/scripts/set-global-language.sh" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$TMP/absent.md" "$HOOK" language SessionStart)")"
cfg="$TMP/bad-lang.md"; printf '# Mine\noutput_language: klingon\n' > "$cfg"
assert_contains "invalid language -> nudge" "$NUDGE" "$(ctx "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" language SessionStart)")"
cfg="$TMP/lang.md"; printf '# Mine\noutput_language: de\n' > "$cfg"
assert_empty "language set -> silent" "$(CLAUDE_GLOBAL_CONFIG="$cfg" "$HOOK" language SessionStart)"

# 4c) the plugin's userConfig dialog (CLAUDE_PLUGIN_OPTION_OUTPUT_LANGUAGE) is the first-run
#     prompt. The hook applies it to the global setting only when the dialog value CHANGES
#     (state in CLAUDE_PLUGIN_DATA), so /language keeps working and the last change wins.
lang_run() { # lang_run <global> <data-dir> <option>: runs the language hook, prints context
  ctx "$(CLAUDE_GLOBAL_CONFIG="$1" CLAUDE_PLUGIN_DATA="$2" CLAUDE_PLUGIN_OPTION_OUTPUT_LANGUAGE="$3" "$HOOK" language SessionStart)"
}
glang() { grep -m1 '^output_language:' "$1" 2>/dev/null | sed 's/^output_language: *//'; }
# first run, global unset: the dialog value is written, no chat question
g="$TMP/u1.md"; d="$TMP/data1"; mkdir -p "$d"; printf '# G\n' > "$g"
out="$(lang_run "$g" "$d" de)"
assert_contains "dialog value written to the global" "de" "$(glang "$g")"
assert_absent "no chat question when the dialog answered" "$NUDGE" "$out"
# unchanged dialog value + a later /language change: the user's change survives
perl -pi -e 's/^output_language: .*/output_language: hr/' "$g"
lang_run "$g" "$d" de >/dev/null
assert_contains "unchanged dialog value does not clobber /language" "hr" "$(glang "$g")"
# the dialog value changes in /config: it is applied
lang_run "$g" "$d" fr >/dev/null
assert_contains "changed dialog value is applied" "fr" "$(glang "$g")"
# first run with a language already set (an install.sh user): kept, difference named
g="$TMP/u2.md"; d="$TMP/data2"; mkdir -p "$d"; printf '# G\noutput_language: hr\n' > "$g"
out="$(lang_run "$g" "$d" en)"
assert_contains "existing global kept on first run" "hr" "$(glang "$g")"
assert_contains "the difference is named" "/odeo:language en --global" "$out"
lang_run "$g" "$d" en >/dev/null
assert_contains "still kept on the next session" "hr" "$(glang "$g")"
# an invalid dialog value is refused and reported, the global is untouched
g="$TMP/u3.md"; d="$TMP/data3"; mkdir -p "$d"; printf '# G\noutput_language: de\n' > "$g"
printf 'de' > "$d/synced-language"
out="$(lang_run "$g" "$d" klingon)"
assert_contains "invalid dialog value leaves the global" "de" "$(glang "$g")"
assert_contains "invalid dialog value is reported" "could not apply" "$out"

# 4d) a global the writer refuses (a symlink, a supported setup): warn ONCE per dialog
#     value and name the per-project way, never degrade every session with the same warning
real="$TMP/real-global.md"; printf '# G\n' > "$real"; g="$TMP/linked.md"; ln -s "$real" "$g"
d="$TMP/data4"; mkdir -p "$d"
out="$(lang_run "$g" "$d" de)"
assert_contains "refused write is reported" "could not apply" "$out"
assert_contains "names the per-project alternative" "/odeo:language de" "$out"
assert_empty "the same refusal is not repeated next session" "$(CLAUDE_GLOBAL_CONFIG="$g" CLAUDE_PLUGIN_DATA="$d" CLAUDE_PLUGIN_OPTION_OUTPUT_LANGUAGE=de "$HOOK" language SessionStart)"
[ -L "$g" ] && ok "symlinked global left a symlink" || bad "symlinked global was replaced"

# 4b) legacy install.sh copies: a one-time pointer to the migration, silent otherwise.
#     The legacy check also reads the project's git hooks, so it runs outside any repo here.
norepo="$TMP/no-repo"; mkdir -p "$norepo"
legacy() { CLAUDE_PROJECT_DIR="${2:-$norepo}" GIT_CEILING_DIRECTORIES="$TMP" HOME="$1" "$HOOK" legacy SessionStart; }
lh="$TMP/legacy-home"; mkdir -p "$lh/.claude/odeo-docs"
assert_contains "legacy copies -> migration nudge" "$ROOT/scripts/odeo-migrate-legacy.sh" "$(ctx "$(legacy "$lh")")"
lh="$TMP/legacy-bin"; mkdir -p "$lh/bin"; touch "$lh/bin/merge-gate.sh"
assert_contains "legacy ~/bin script -> nudge" "odeo-migrate-legacy.sh" "$(ctx "$(legacy "$lh")")"
ch="$TMP/clean-home"; mkdir -p "$ch/.claude"
assert_empty "clean home -> silent" "$(legacy "$ch")"

# 4e) git guards written before the move to scripts/ (they search only */odeo/*/bin) are
#     named once, with the command that refreshes them; current or foreign ones are not
gr="$TMP/guarded"; git init -q "$gr"
( cd "$gr" && HOME="$ch" bash "$ROOT/scripts/install-git-guards.sh" >/dev/null )
assert_empty "current hooks -> silent" "$(legacy "$ch" "$gr")"
old_hook() { printf '#!/usr/bin/env bash\nodeo_tool() {\n  ls -1td "$HOME"/.claude/plugins/cache/*/odeo/*/bin\n}\n' > "$1"; }
old_hook "$gr/.git/hooks/pre-commit"
out="$(ctx "$(legacy "$ch" "$gr")")"
assert_contains "a 0.2.x hook -> refresh nudge" "$ROOT/scripts/install-git-guards.sh" "$out"
assert_absent "no shim advice without an old shim" "--apply" "$out"
assert_contains "found from a subdirectory of the project" "install-git-guards.sh" \
  "$(mkdir -p "$gr/src/deep" && ctx "$(legacy "$ch" "$gr/src/deep")")"
# a 0.3.0 hook already searches scripts/ but still looks up PATH first and has no version
# marker: it is outdated too
printf '#!/usr/bin/env bash\nodeo_tool() {\n  c="$(command -v "$1")"\n  ls -1td "$HOME"/.claude/plugins/cache/*/odeo/*/scripts\n}\n' > "$gr/.git/hooks/pre-commit"
assert_contains "a 0.3.0 hook (PATH first, no marker) -> refresh nudge" "install-git-guards.sh" "$(ctx "$(legacy "$ch" "$gr")")"
# a CURRENT hook that can no longer find its program (the clone it was installed from moved,
# no plugin cache) is outdated too: its version marker alone would read as fine
mv_src="$TMP/moved-clone"; mkdir -p "$mv_src"; cp "$ROOT/scripts/install-git-guards.sh" "$mv_src/"
gm="$TMP/guarded-moved"; git init -q "$gm"
( cd "$gm" && HOME="$ch" bash "$mv_src/install-git-guards.sh" >/dev/null ); rm -rf "$mv_src"
assert_contains "a current hook that finds nothing -> refresh nudge" "install-git-guards.sh" "$(ctx "$(legacy "$ch" "$gm")")"
# an install directory %q had to quote (a space) is not a plain path: it is not second-
# guessed (the hook itself finds it; reading it back would mean unquoting shell syntax)
sp_src="$TMP/clone with space"; mkdir -p "$sp_src"; cp "$ROOT/scripts/install-git-guards.sh" "$sp_src/"
gs="$TMP/guarded-space"; git init -q "$gs"
( cd "$gs" && HOME="$ch" bash "$sp_src/install-git-guards.sh" >/dev/null )
assert_empty "an install path that is not plain -> silent, no false alarm" "$(legacy "$ch" "$gs")"
# the config dir RECORDED at install time is searched too: hooks installed with
# CLAUDE_CONFIG_DIR=X from X's cache, that version swept for a newer one in X, and the
# session-start hook run without the variable still finds X's cache (no false alarm)
X="$TMP/config-x"; xc="$X/plugins/cache/odeo/odeo"; mkdir -p "$xc/0.3.1/scripts"
cp "$ROOT/scripts/install-git-guards.sh" "$xc/0.3.1/scripts/"
gx="$TMP/guarded-x"; git init -q "$gx"
( cd "$gx" && HOME="$ch" CLAUDE_CONFIG_DIR="$X" bash "$xc/0.3.1/scripts/install-git-guards.sh" >/dev/null )
rm -rf "$xc/0.3.1"; mkdir -p "$xc/0.3.2/scripts"
printf '#!/bin/sh\nexit 0\n' > "$xc/0.3.2/scripts/secret-scan.sh"; cp "$xc/0.3.2/scripts/secret-scan.sh" "$xc/0.3.2/scripts/publish-guard.sh"
chmod +x "$xc/0.3.2/scripts/"*.sh
assert_empty "a hook that finds its program in the recorded config dir -> silent" "$(legacy "$ch" "$gx")"
# a NEWER hook version is not called older (the nudge would offer a downgrade)
sed 's/^ODEO_HOOKS_VERSION=2$/ODEO_HOOKS_VERSION=3/' "$gr/.git/hooks/pre-push" > "$TMP/v3" && cp "$TMP/v3" "$gr/.git/hooks/pre-commit"
cp "$TMP/v3" "$gr/.git/hooks/pre-push"
assert_empty "a newer hook version -> silent" "$(legacy "$ch" "$gr")"
printf '#!/bin/sh\necho my own hook\n' > "$gr/.git/hooks/pre-commit"
assert_empty "a hook that is not Odeo's -> silent" "$(legacy "$ch" "$gr")"
sh="$TMP/shim-home"; mkdir -p "$sh/bin"
printf '#!/usr/bin/env bash\n# odeo-migrate-legacy shim: old\nls -1td "$HOME"/.claude/plugins/cache/*/odeo/*/bin\n' > "$sh/bin/secret-scan.sh"
out="$(ctx "$(legacy "$sh")")"
assert_contains "a 0.2.x ~/bin shim -> refresh nudge" "$ROOT/scripts/odeo-migrate-legacy.sh\" --apply" "$out"
assert_absent "no hook advice without an old hook" "install-git-guards" "$out"
printf '#!/usr/bin/env bash\n# odeo-migrate-legacy shim: current\nls -1td "$HOME"/.claude/plugins/cache/*/odeo/*/scripts\n' > "$sh/bin/secret-scan.sh"
assert_empty "a current shim -> silent" "$(legacy "$sh")"

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
assert any(c.endswith("legacy SessionStart") for c in cmds("SessionStart"))
assert not any("language" in c or "legacy" in c for c in cmds("SubagentStart"))
EOF
if [ -x "$HOOK" ]; then ok "hook is executable"; else bad "hook is not executable"; fi

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
