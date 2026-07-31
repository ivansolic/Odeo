#!/usr/bin/env bash
# Integration (USR-004 acceptance): the output language can be CHANGED at any time,
# at either scope, with no duplicate line, and the resolver reflects it immediately.
# Composes bin/{set-project-language,set-global-language,language-status,resolve-language}.sh.
set -uo pipefail
BIN="$(cd "$(dirname "$0")/.." && pwd)/bin"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_true() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

proj="$TMP/project"; mkdir -p "$proj"
printf '# P\n## Conventions\noutput_language: en\n' > "$proj/CLAUDE.md"
cfg="$TMP/global.md"; printf '# G\noutput_language: en\n' > "$cfg"

resolve() { CLAUDE_GLOBAL_CONFIG="$cfg" bash "$BIN/resolve-language.sh" "$proj"; }
status()  { CLAUDE_GLOBAL_CONFIG="$cfg" bash "$BIN/language-status.sh" "$proj"; }
plines()  { grep -c '^output_language:' "$proj/CLAUDE.md"; }
gvalue()  { grep -m1 '^output_language:' "$cfg" | sed -E 's/^output_language:[[:space:]]*//'; }

# 1) change the PROJECT scope: takes effect immediately, scope reported as project
out="$("$BIN/set-project-language.sh" "$proj" de 2>&1)"; rc=$?
assert_exit "project change -> 0" 0 "$rc"
assert_eq "resolver reflects de" "de" "$(resolve)"
assert_eq "status says de project" "de project" "$(status)"

# 2) change AGAIN (the story's "at any time"): still exactly one line
out="$("$BIN/set-project-language.sh" "$proj" fr 2>&1)"; rc=$?
assert_exit "second project change -> 0" 0 "$rc"
assert_eq "resolver reflects fr" "fr" "$(resolve)"
assert_eq "still exactly one project line" 1 "$(plines)"

# 3) change the GLOBAL default while a project override exists: the project still
#    wins (precedence by design). This is the masking case the skill must report.
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$BIN/set-global-language.sh" hr --overwrite 2>&1)"; rc=$?
assert_exit "global change -> 0" 0 "$rc"
assert_eq "global value is hr" "hr" "$(gvalue)"
assert_eq "project still wins (resolver)" "fr" "$(resolve)"
assert_eq "project still wins (status)" "fr project" "$(status)"

# 4) drop the project line -> the global default takes over, scope reported global
awk '!/^output_language:/' "$proj/CLAUDE.md" > "$TMP/t" && mv "$TMP/t" "$proj/CLAUDE.md"
assert_eq "global default takes over" "hr" "$(resolve)"
assert_eq "status says hr global" "hr global" "$(status)"

# 5) neither level set -> the built-in en fallback, scope default
cfg2="$TMP/global2.md"; printf '# G\n' > "$cfg2"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg2" bash "$BIN/language-status.sh" "$proj")"
assert_eq "nothing set -> en default" "en default" "$out"
assert_eq "resolver -> en" "en" "$(CLAUDE_GLOBAL_CONFIG="$cfg2" bash "$BIN/resolve-language.sh" "$proj")"

# 6) a refusal changes nothing, at either scope
printf '# P\n## Conventions\noutput_language: fr\n' > "$proj/CLAUDE.md"
cp "$proj/CLAUDE.md" "$TMP/proj.orig"; cp "$cfg" "$TMP/cfg.orig"
out="$("$BIN/set-project-language.sh" "$proj" klingon 2>&1)"; rc=$?
assert_exit "invalid project code -> 1" 1 "$rc"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$BIN/set-global-language.sh" klingon --overwrite 2>&1)"; rc=$?
assert_exit "invalid global code -> 1" 1 "$rc"
assert_true "project file untouched" "cmp -s \"$proj/CLAUDE.md\" \"$TMP/proj.orig\""
assert_true "global file untouched" "cmp -s \"$cfg\" \"$TMP/cfg.orig\""

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
