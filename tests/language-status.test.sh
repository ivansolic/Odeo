#!/usr/bin/env bash
# Tests for bin/language-status.sh: the effective output language AND its scope.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/language-status.sh"
RESOLVER="$ROOT/bin/resolve-language.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# proj <name> [line...] -> creates $TMP/<name>/CLAUDE.md with the given lines
proj() {
  local name="$1"; shift
  mkdir -p "$TMP/$name"
  { printf '# Project\n'; for l in "$@"; do printf '%s\n' "$l"; done; } > "$TMP/$name/CLAUDE.md"
  printf '%s' "$TMP/$name"
}
gcfg() { # gcfg <name> [line...] -> creates $TMP/<name>.md, echoes its path
  local name="$1"; shift
  { printf '# Global\n'; for l in "$@"; do printf '%s\n' "$l"; done; } > "$TMP/$name.md"
  printf '%s' "$TMP/$name.md"
}

# 1) project wins over global
p1="$(proj p1 'output_language: de')"; g1="$(gcfg g1 'output_language: fr')"
out="$(CLAUDE_GLOBAL_CONFIG="$g1" "$SCRIPT" "$p1" 2>&1)"; rc=$?
assert_exit "project+global -> 0" 0 "$rc"
assert_eq "project wins, scope project" "de project" "$out"

# 2) no project line -> global
p2="$(proj p2)"; g2="$(gcfg g2 'output_language: hr')"
out="$(CLAUDE_GLOBAL_CONFIG="$g2" "$SCRIPT" "$p2" 2>&1)"
assert_eq "no project line -> global scope" "hr global" "$out"

# 3) neither level -> default
p3="$(proj p3)"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$p3" 2>&1)"
assert_eq "neither level -> en default" "en default" "$out"

# 4) project dir with NO CLAUDE.md at all -> default
mkdir -p "$TMP/p4"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$TMP/p4" 2>&1)"
assert_eq "no project CLAUDE.md -> en default" "en default" "$out"

# 5) THE REASON THIS SCRIPT EXISTS: an invalid project value must degrade to global
#    scope, not report `project` (that would tell the user the wrong level).
p5="$(proj p5 'output_language: klingon')"; g5="$(gcfg g5 'output_language: fr')"
out="$(CLAUDE_GLOBAL_CONFIG="$g5" "$SCRIPT" "$p5" 2>&1)"
assert_eq "invalid project value -> global scope, not project" "fr global" "$out"

# 6) normalization: padding, uppercase, CR
mkdir -p "$TMP/p6"; printf '# Project\noutput_language:   DE \r\n' > "$TMP/p6/CLAUDE.md"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$TMP/p6" 2>&1)"
assert_eq "normalizes padding/case/CR" "de project" "$out"

# 7) first line wins on duplicates
p7="$(proj p7 'output_language: fr' 'output_language: de')"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$p7" 2>&1)"
assert_eq "first duplicate line wins" "fr project" "$out"

# 8) all four codes round-trip with scope project
for code in en de hr fr; do
  pd="$(proj "p8-$code" "output_language: $code")"
  out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$pd" 2>&1)"
  assert_eq "code $code -> '$code project'" "$code project" "$out"
done

# 9) RESOLVER AGREEMENT: the first field must equal resolve-language.sh's output
#    on the same fixture with the same global config (they can never disagree).
agree() { # agree <label> <project-dir> <global-cfg>
  local label="$1" pd="$2" gc="$3" status_code resolver_code
  status_code="$(CLAUDE_GLOBAL_CONFIG="$gc" "$SCRIPT" "$pd" 2>/dev/null | awk '{print $1}')"
  resolver_code="$(CLAUDE_GLOBAL_CONFIG="$gc" bash "$RESOLVER" "$pd" 2>/dev/null)"
  assert_eq "resolver agreement: $label" "$resolver_code" "$status_code"
}
agree "case 1" "$p1" "$g1"
agree "case 2" "$p2" "$g2"
agree "case 3" "$p3" "$TMP/absent-global.md"
agree "case 5 (degrade)" "$p5" "$g5"
agree "case 6 (normalize)" "$TMP/p6" "$TMP/absent-global.md"

# 10) usage errors
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" 2>&1)"; rc=$?
assert_exit "no args -> 2" 2 "$rc"; assert_contains "usage on no args" "usage" "$out"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$p1" extra 2>&1)"; rc=$?
assert_exit "two args -> 2" 2 "$rc"
out="$(CLAUDE_GLOBAL_CONFIG="$TMP/absent-global.md" "$SCRIPT" "$TMP/nope" 2>&1)"; rc=$?
assert_exit "nonexistent dir -> 2" 2 "$rc"; assert_contains "says not found" "not found" "$out"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
