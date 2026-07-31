#!/usr/bin/env bash
# Tests for bin/set-project-language.sh: the PROJECT-level output-language writer.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/set-project-language.sh"
RESOLVER="$ROOT/bin/resolve-language.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }
assert_true() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }
file_mode() { stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
NOGLOBAL="$TMP/absent-global.md"   # so the resolver reads the PROJECT line only

lines()  { grep -c '^output_language:' "$1/CLAUDE.md"; }
value()  { grep -m1 '^output_language:' "$1/CLAUDE.md" | sed -E 's/^output_language:[[:space:]]*//'; }
resolve() { CLAUDE_GLOBAL_CONFIG="$NOGLOBAL" bash "$RESOLVER" "$1"; }

# 1) INSERT at the ## Conventions anchor
d="$TMP/c1"; mkdir -p "$d"; printf '# P\n## Conventions\n- x\n' > "$d/CLAUDE.md"
out="$("$SCRIPT" "$d" de 2>&1)"; rc=$?
assert_exit "insert at anchor -> 0" 0 "$rc"
assert_eq "exactly one line" 1 "$(lines "$d")"
assert_eq "value de" "de" "$(value "$d")"
assert_true "line sits after ## Conventions" "[ \"\$(grep -n '^output_language:' \"$d/CLAUDE.md\" | cut -d: -f1)\" -gt \"\$(grep -n '^## Conventions' \"$d/CLAUDE.md\" | cut -d: -f1)\" ]"
assert_eq "resolver reads de" "de" "$(resolve "$d")"

# 2) UPDATE in place, surrounding content preserved
d="$TMP/c2"; mkdir -p "$d"; printf '# P\noutput_language: en\n## Conventions\n- x\n' > "$d/CLAUDE.md"
before_lines="$(wc -l < "$d/CLAUDE.md")"
out="$("$SCRIPT" "$d" de 2>&1)"; rc=$?
assert_exit "update in place -> 0" 0 "$rc"
assert_eq "still exactly one line" 1 "$(lines "$d")"
assert_eq "value now de" "de" "$(value "$d")"
assert_eq "total line count unchanged" "$before_lines" "$(wc -l < "$d/CLAUDE.md")"
assert_true "other content preserved" "grep -q '^# P' \"$d/CLAUDE.md\" && grep -q '^- x' \"$d/CLAUDE.md\""

# 3) NO DUPLICATE ON REPEATED SETS (the story's explicit requirement)
d="$TMP/c3"; mkdir -p "$d"; printf '# P\n## Conventions\n' > "$d/CLAUDE.md"
for code in de fr hr; do
  "$SCRIPT" "$d" "$code" >/dev/null 2>&1
  assert_eq "after setting $code: still one line" 1 "$(lines "$d")"
done
assert_eq "final value hr" "hr" "$(value "$d")"
assert_eq "resolver reads hr" "hr" "$(resolve "$d")"

# 4) NO ANCHOR, NO LINE -> appended
d="$TMP/c4"; mkdir -p "$d"; printf '# P\n' > "$d/CLAUDE.md"
out="$("$SCRIPT" "$d" fr 2>&1)"; rc=$?
assert_exit "append with no anchor -> 0" 0 "$rc"
assert_eq "one line appended" 1 "$(lines "$d")"
assert_eq "resolver reads fr" "fr" "$(resolve "$d")"

# 4b) file with NO trailing newline still gets a well-formed line
d="$TMP/c4b"; mkdir -p "$d"; printf '# P' > "$d/CLAUDE.md"
"$SCRIPT" "$d" de >/dev/null 2>&1
assert_eq "no-trailing-newline: one line" 1 "$(lines "$d")"
assert_eq "no-trailing-newline: resolver reads de" "de" "$(resolve "$d")"

# 5) COLLAPSE pre-existing duplicates
d="$TMP/c5"; mkdir -p "$d"; printf '# P\noutput_language: fr\noutput_language: de\n' > "$d/CLAUDE.md"
out="$("$SCRIPT" "$d" hr 2>&1)"; rc=$?
assert_exit "collapse duplicates -> 0" 0 "$rc"
assert_eq "duplicates collapsed to one" 1 "$(lines "$d")"
assert_eq "value hr" "hr" "$(value "$d")"

# 6) INVALID code refused, file untouched
d="$TMP/c6"; mkdir -p "$d"; printf '# P\noutput_language: de\n' > "$d/CLAUDE.md"
cp "$d/CLAUDE.md" "$TMP/c6.orig"
out="$("$SCRIPT" "$d" klingon 2>&1)"; rc=$?
assert_exit "invalid code -> 1" 1 "$rc"
assert_contains "names the bad code" "klingon" "$out"
assert_contains "lists the allowed set" "en de hr fr" "$out"
assert_true "file byte-identical after refusal" "cmp -s \"$d/CLAUDE.md\" \"$TMP/c6.orig\""

# 7) MISSING CLAUDE.md refused, nothing created
d="$TMP/c7"; mkdir -p "$d"
out="$("$SCRIPT" "$d" de 2>&1)"; rc=$?
assert_exit "missing CLAUDE.md -> 1" 1 "$rc"
assert_contains "mentions CLAUDE.md" "CLAUDE.md" "$out"
assert_true "nothing created" "[ ! -f \"$d/CLAUDE.md\" ]"

# 8) USAGE errors
out="$("$SCRIPT" 2>&1)"; rc=$?
assert_exit "no args -> 2" 2 "$rc"; assert_contains "usage on no args" "usage" "$out"
out="$("$SCRIPT" "$TMP/c1" 2>&1)"; rc=$?
assert_exit "one arg -> 2" 2 "$rc"
out="$("$SCRIPT" "$TMP/c1" de extra 2>&1)"; rc=$?
assert_exit "three args -> 2" 2 "$rc"
out="$("$SCRIPT" "$TMP/nope" de 2>&1)"; rc=$?
assert_exit "nonexistent dir -> 2" 2 "$rc"; assert_contains "says not found" "not found" "$out"

# 9) MODE PRESERVED (mv would have replaced the file with a 600 temp)
d="$TMP/c9"; mkdir -p "$d"; printf '# P\noutput_language: en\n' > "$d/CLAUDE.md"; chmod 644 "$d/CLAUDE.md"
"$SCRIPT" "$d" de >/dev/null 2>&1
assert_eq "mode still 644" "644" "$(file_mode "$d/CLAUDE.md")"

# 10) all four codes round-trip on fresh fixtures
for code in en de hr fr; do
  d="$TMP/c10-$code"; mkdir -p "$d"; printf '# P\n## Conventions\n' > "$d/CLAUDE.md"
  out="$("$SCRIPT" "$d" "$code" 2>&1)"; rc=$?
  assert_exit "round-trip $code -> 0" 0 "$rc"
  assert_eq "$code: one line with the code" "$code" "$(value "$d")"
done

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
