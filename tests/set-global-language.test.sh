#!/usr/bin/env bash
# Tests for bin/set-global-language.sh: idempotent writer of the GLOBAL output-language default.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/set-global-language.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# 1) fresh write into a config with no line
cfg="$TMP/c1.md"; printf '# Global Instructions\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" de 2>&1)"; rc=$?
assert_exit "fresh write -> 0" 0 "$rc"
assert_eq "one output_language line" 1 "$(grep -c '^output_language:' "$cfg")"
assert_eq "line is de" "output_language: de" "$(grep '^output_language:' "$cfg")"

# 2) idempotent skip: existing line is left unchanged
cfg="$TMP/c2.md"; printf '# G\noutput_language: fr\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" de 2>&1)"; rc=$?
assert_exit "idempotent skip -> 0" 0 "$rc"
assert_eq "still exactly one line" 1 "$(grep -c '^output_language:' "$cfg")"
assert_eq "still fr (not overwritten)" "output_language: fr" "$(grep '^output_language:' "$cfg")"
assert_contains "says already set" "already set" "$out"

# 3) skip-writes-en (a skip records English, so it is not re-asked later)
cfg="$TMP/c3.md"; printf '# G\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" en 2>&1)"; rc=$?
assert_exit "write en -> 0" 0 "$rc"
assert_eq "one en line" "output_language: en" "$(grep '^output_language:' "$cfg")"

# 4) all four codes round-trip (fresh config each)
for code in en de hr fr; do
  cfg="$TMP/c4-$code.md"; printf '# G\n' > "$cfg"
  out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" "$code" 2>&1)"; rc=$?
  assert_exit "round-trip $code -> 0" 0 "$rc"
  assert_eq "$code: exactly one line" 1 "$(grep -c '^output_language:' "$cfg")"
  assert_eq "$code: matching code" "output_language: $code" "$(grep '^output_language:' "$cfg")"
done

# 5) invalid code -> exit 1, names it + lists allowed, config NOT modified
cfg="$TMP/c5.md"; printf '# G\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" klingon 2>&1)"; rc=$?
assert_exit "invalid code -> 1" 1 "$rc"
assert_contains "names the bad code" "klingon" "$out"
assert_contains "lists the allowed set" "en de hr fr" "$out"
assert_eq "config untouched (no line)" 0 "$(grep -c '^output_language:' "$cfg")"

# 6) missing code arg -> exit 2 usage
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/c6.md" "$SCRIPT" 2>&1)"; rc=$?
assert_exit "no arg -> 2" 2 "$rc"
assert_contains "usage on no arg" "usage" "$out"

# 7) too many args -> exit 2
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/c7.md" "$SCRIPT" de fr 2>&1)"; rc=$?
assert_exit "too many args -> 2" 2 "$rc"

# 8) config file absent (parent dir exists) -> created with one line
cfg="$TMP/sub/c8.md"; mkdir -p "$TMP/sub"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" hr 2>&1)"; rc=$?
assert_exit "absent config -> 0 (created)" 0 "$rc"
assert_eq "created with one hr line" "output_language: hr" "$(grep '^output_language:' "$cfg" 2>/dev/null)"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
