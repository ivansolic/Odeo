#!/usr/bin/env bash
# Integration: the GLOBAL default written by set-global-language.sh is inherited by a
# project with no output_language line (via resolve-language.sh), asked exactly once.
# Composes two already-unit-tested scripts; proves USR-003's acceptance end to end.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SETGL="$ROOT/bin/set-global-language.sh"
RESOLVE="$ROOT/bin/resolve-language.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# A project WITHOUT an output_language line (the story's "project with no line").
proj="$TMP/proj"; mkdir -p "$proj"; printf '## Conventions\nno language line here\n' > "$proj/CLAUDE.md"

# 1) write the global default
cfg="$TMP/global.md"; printf '# Global Instructions\n' > "$cfg"
rc=$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SETGL" de >/dev/null 2>&1; echo $?)
assert_exit "write global de -> 0" 0 "$rc"

# 2+3) a project with no line inherits the global default
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$RESOLVE" "$proj")"; rc=$?
assert_exit "resolve inherits -> 0" 0 "$rc"
assert_eq "project with no line inherits global de" "de" "$out"

# 4) asked once: a second write is refused, the default is unchanged
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SETGL" fr 2>&1)"; rc=$?
assert_exit "second write -> 0" 0 "$rc"
assert_contains "second write refused (already set)" "already set" "$out"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$RESOLVE" "$proj")"
assert_eq "still resolves de (not overwritten to fr)" "de" "$out"

# 5) skipping records English: a skip-write resolves to en
cfg2="$TMP/global2.md"; printf '# Global Instructions\n' > "$cfg2"
CLAUDE_GLOBAL_CONFIG="$cfg2" "$SETGL" en >/dev/null 2>&1
out="$(CLAUDE_GLOBAL_CONFIG="$cfg2" "$RESOLVE" "$proj")"
assert_eq "skip -> en inherited" "en" "$out"

# 6) a PROJECT line still wins over the global (precedence not broken by the write)
projde="$TMP/projfr"; mkdir -p "$projde"; printf 'output_language: fr\n' > "$projde/CLAUDE.md"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$RESOLVE" "$projde")"
assert_eq "project line overrides global" "fr" "$out"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
