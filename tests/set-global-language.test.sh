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

# --- USR-004 cases (--overwrite, the explicit change path). Cases 1 to 8 above are
# --- USR-003's regression suite and must never be edited. These are inserted BEFORE
# --- the summary block on purpose: anything after `exit "$fail"` would never run.

# 9) --overwrite CHANGES an existing value
cfg="$TMP/c9.md"; printf '# G\noutput_language: fr\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" de --overwrite 2>&1)"; rc=$?
assert_exit "overwrite existing -> 0" 0 "$rc"
assert_eq "exactly one line" 1 "$(grep -c '^output_language:' "$cfg")"
assert_eq "value changed to de" "output_language: de" "$(grep '^output_language:' "$cfg")"
assert_contains "surrounding content kept" "# G" "$(cat "$cfg")"
assert_contains "says changed" "changed" "$out"

# 10) --overwrite on a config with NO line still writes fresh
cfg="$TMP/c10.md"; printf '# G\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" hr --overwrite 2>&1)"; rc=$?
assert_exit "overwrite with no existing line -> 0" 0 "$rc"
assert_eq "one hr line" "output_language: hr" "$(grep '^output_language:' "$cfg")"

# 11) --overwrite collapses pre-existing duplicates
cfg="$TMP/c11.md"; printf '# G\noutput_language: fr\noutput_language: de\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" hr --overwrite 2>&1)"; rc=$?
assert_exit "collapse duplicates -> 0" 0 "$rc"
assert_eq "duplicates collapsed" 1 "$(grep -c '^output_language:' "$cfg")"
assert_eq "value hr" "output_language: hr" "$(grep '^output_language:' "$cfg")"

# 12) flag order independence
cfg="$TMP/c12.md"; printf '# G\noutput_language: fr\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" --overwrite de 2>&1)"; rc=$?
assert_exit "flag before code -> 0" 0 "$rc"
assert_eq "value de (flag first)" "output_language: de" "$(grep '^output_language:' "$cfg")"

# 13) --overwrite with an invalid code refuses and touches nothing
cfg="$TMP/c13.md"; printf '# G\noutput_language: fr\n' > "$cfg"; cp "$cfg" "$TMP/c13.orig"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" klingon --overwrite 2>&1)"; rc=$?
assert_exit "invalid code with flag -> 1" 1 "$rc"
assert_contains "names the bad code" "klingon" "$out"
assert_contains "lists allowed set" "en de hr fr" "$out"
if cmp -s "$cfg" "$TMP/c13.orig"; then echo "ok: config byte-identical after refusal"; else echo "FAIL: config changed on refusal"; fail=1; fi

# 14) unknown flag is a usage error
cfg="$TMP/c14.md"; printf '# G\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" --nope de 2>&1)"; rc=$?
assert_exit "unknown flag -> 2" 2 "$rc"
assert_contains "usage on unknown flag" "usage" "$out"

# 15) a symlinked global config is refused BEFORE any write (--link install would
#     otherwise mutate the repo's tracked global/CLAUDE.md through the link)
printf '# G\noutput_language: fr\n' > "$TMP/real.md"
ln -sf "$TMP/real.md" "$TMP/link.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/link.md" "$SCRIPT" de --overwrite 2>&1)"; rc=$?
assert_exit "symlinked config -> 1" 1 "$rc"
assert_contains "says symlink" "symlink" "$out"
assert_eq "target file untouched" "output_language: fr" "$(grep '^output_language:' "$TMP/real.md")"

# 16) REGRESSION, restated on purpose: WITHOUT the flag an existing value is still
#     left alone. Duplicates case 2 deliberately, as the guard against a future
#     default-flip that would break USR-003's "asked exactly once".
cfg="$TMP/c16.md"; printf '# G\noutput_language: fr\n' > "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" de 2>&1)"; rc=$?
assert_exit "no flag on existing value -> 0" 0 "$rc"
assert_eq "value still fr" "output_language: fr" "$(grep '^output_language:' "$cfg")"
assert_contains "says already set" "already set" "$out"

# 17) symlink + NO existing line + --overwrite -> still refused before any write.
#     This is the REAL --link shape: the repo's tracked global/CLAUDE.md carries no
#     output_language: line, so case 15 (symlink + existing line) did not cover it.
printf '# G\n' > "$TMP/real17.md"
ln -sf "$TMP/real17.md" "$TMP/link17.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/link17.md" "$SCRIPT" de --overwrite 2>&1)"; rc=$?
assert_exit "symlink + no line + flag -> 1" 1 "$rc"
assert_contains "says symlink (no-line case)" "symlink" "$out"
assert_eq "target still has no language line" 0 "$(grep -c '^output_language:' "$TMP/real17.md")"

# 18) symlink + NO existing line + NO flag -> also refused. This is the one place the
#     no-flag path deliberately DIFFERS from what USR-003 shipped (it used to append
#     through the link into a tracked file). Safer, unreachable from install.sh (which
#     skips symlinks before calling), and pinned here so the delta is not accidental.
printf '# G\n' > "$TMP/real18.md"
ln -sf "$TMP/real18.md" "$TMP/link18.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/link18.md" "$SCRIPT" de 2>&1)"; rc=$?
assert_exit "symlink + no line + no flag -> 1" 1 "$rc"
assert_eq "target untouched (no-flag case)" 0 "$(grep -c '^output_language:' "$TMP/real18.md")"

# 19) an unwritable config must FAIL, not report a false success. Before the fix this
#     printed "set to de" and exited 0 with nothing written, so the caller (and
#     /language --global) believed the change had landed.
cfg="$TMP/c19.md"; printf '# G\n' > "$cfg"; chmod 444 "$cfg"
out="$(CLAUDE_GLOBAL_CONFIG="$cfg" "$SCRIPT" de 2>&1)"; rc=$?
chmod 644 "$cfg"
assert_exit "unwritable config (append path) -> 1" 1 "$rc"
assert_eq "nothing was written" 0 "$(grep -c '^output_language:' "$cfg")"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
