#!/usr/bin/env bash
# Tests for scripts/research-check.sh, the mechanical check a research report runs before
# review (skills/research/SKILL.md step 5b).
#
# One GOOD report is built below; every other case is that report with ONE mutation, so a
# case that turns red is attributable to its mutation alone. The mutations are the defect
# classes the RES-002 review rounds 4 to 7 found by hand (docs/evals/RES-002.md).
#
# FILE-WIDE INVARIANT: no case asserts only an exit code. Each violation case also asserts
# the finding id or note number the script names, so a script that fails for the wrong
# reason (a parse error, say) cannot pass a case.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/scripts/research-check.sh"
fail=0
assert_exit()     { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }
assert_absent()   { case "$3" in *"$2"*) echo "FAIL: $1 (unexpected '$2')"; fail=1;; *) echo "ok: $1";; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
GOOD="$TMP/good.md"
cat > "$GOOD" <<'EOF'
---
id: RES-900
---

# RES-900: fixture

## Question

Does Tool A have feature X?

## Answer

Tool A has feature X (verified, F1); Tool B does Y (one source, F2); the docs and the
changelog disagree on the plan limit (C1).

## Findings

- **F1** Tool A ships feature X on every plan. **Verified** (notes 1, 2)
  <!-- terms: feature X; every plan|all plans -->
- **F2** Tool B runs job Y daily. **One source** (note 1)
- **C1** The plan limit is a **conflict**: 5 seats (note 1) against 10 seats (note 2).

### Notes

1. Acme docs, acme.dev/docs/features: "Tool A ships feature X on every plan" and "Tool B
   runs job Y daily"; limits table: "5 seats".
2. Acme source, github.com/acme/a at `abc1234`, `src/plans.rs` line 3: "feature X is
   enabled for all plans"; line 9: `MAX_SEATS = 10`.

## Numbers

None.

## Unverified

- F2: one source.
- C1: 5 seats (note 1) against 10 seats (note 2).

## Implications for us

- Rely on feature X (F1, verified).

## Sources (accessed 2026-10-20)

- acme.dev/docs/features; github.com/acme/a at `abc1234`
EOF

SRC="$TMP/sources"; mkdir -p "$SRC/repo/src"
printf '# Features\n\nTool A ships feature X on every plan.\n\nTool B runs   job Y daily.\n\n| Plan | 5 seats |\n' > "$SRC/features.md"
printf '// plans\n// line 2\n// feature X is enabled for all plans\nconst MAX_SEATS = 10;\n' > "$SRC/repo/src/plans.rs"

# mutate <name> <python-replacement-old> <new>: GOOD with exactly one replacement.
mutate() {
  python3 -I - "$GOOD" "$TMP/$1.md" "$2" "$3" <<'PY'
import sys
src, dst, old, new = sys.argv[1:5]
t = open(src).read()
assert t.count(old) == 1, ("fixture drift", old)
open(dst, "w").write(t.replace(old, new))
PY
}
run() { out="$(bash "$SCRIPT" "$@" 2>&1)"; code=$?; }

# --- G: the good report ------------------------------------------------------------
run "$GOOD" --sources "$SRC"
assert_exit "G1 good report with sources exits 0" 0 "$code"
assert_contains "G1 says every quote was found" "quotes: 3/3 verbatim" "$out"
assert_contains "G1 counts its findings" "3 findings, 2 notes" "$out"

run "$GOOD"
assert_exit "G2 good report without sources exits 0" 0 "$code"
assert_contains "G2 says quotes were not checked, not that they passed" "quotes: not checked" "$out"

# --- M: one mutation each --------------------------------------------------------------
mutate m1 "**One source** (note 1)" "**Verified** (note 1)"
run "$TMP/m1.md"
assert_exit "M1 Verified with one note fails" 1 "$code"
assert_contains "M1 names F2" "F2: Verified needs two notes" "$out"

mutate m2 "2. Acme source, github.com" "2. Acme docs, github.com"
run "$TMP/m2.md"
assert_exit "M2 Verified on two notes of the same source fails" 1 "$code"
assert_contains "M2 names F1" "F1: Verified on notes from one source (Acme docs)" "$out"

mutate m3 "- F2: one source." "- (none)"
run "$TMP/m3.md"
assert_exit "M3 one-source finding missing from Unverified fails" 1 "$code"
assert_contains "M3 names F2" "F2: one source but not listed under Unverified" "$out"

mutate m4 '"Tool B
   runs job Y daily"' '"Tool B
   runs job Y hourly"'
run "$TMP/m4.md" --sources "$SRC"
assert_exit "M4 a quote not in the sources fails" 1 "$code"
assert_contains "M4 names note 1" "note 1: quote not found verbatim" "$out"
run "$TMP/m4.md"
assert_exit "M4b the same misquote without sources is not checked, exit 0" 0 "$code"

mutate m5 "(verified, F1)" "(verified, F9)"
run "$TMP/m5.md"
assert_exit "M5 Answer citing an unknown finding fails" 1 "$code"
assert_contains "M5 names F9 and the section" "Answer: unknown finding F9" "$out"

mutate m6 "daily. **One source** (note 1)" "daily. (note 1)"
run "$TMP/m6.md"
assert_exit "M6 a finding with no confidence word fails" 1 "$code"
assert_contains "M6 names F2" "F2: 0 confidence words" "$out"

mutate m7 "<!-- terms: feature X; every plan|all plans -->" "<!-- terms: feature X; daily -->"
run "$TMP/m7.md"
assert_exit "M7 a key term outside one note's quotes fails" 1 "$code"
assert_contains "M7 names F1 and note 2" "F1: key term 'daily' not inside a quote of note 2" "$out"
assert_absent "M7 does not blame note 1, which quotes it" "not inside a quote of note 1" "$out"

mutate m8 "
  <!-- terms: feature X; every plan|all plans -->" ""
run "$TMP/m8.md"
assert_exit "M8 Verified without key terms fails" 1 "$code"
assert_contains "M8 names F1" "F1: Verified but no key terms" "$out"

mutate m9 "daily. **One source** (note 1)" "daily. **One source** **Verified** (note 1)"
run "$TMP/m9.md"
assert_exit "M9 two confidence words fail" 1 "$code"
assert_contains "M9 names F2" "F2: 2 confidence words" "$out"

mutate m10 "**Verified** (notes 1, 2)" "**Verified** (notes 1, 3)"
run "$TMP/m10.md"
assert_exit "M10 citing a missing note fails" 1 "$code"
assert_contains "M10 names note 3" "F1: cites missing note 3" "$out"

mutate m11 "(F1, verified)" "(F1, F7, verified)"
run "$TMP/m11.md"
assert_exit "M11 Implications citing an unknown finding fails" 1 "$code"
assert_contains "M11 names the section" "Implications for us: unknown finding F7" "$out"

mutate m12 "- **F2** Tool B" "- **F1** Tool B"
run "$TMP/m12.md"
assert_exit "M12 a duplicate finding id fails" 1 "$code"
assert_contains "M12 names F1" "F1: duplicate finding id" "$out"

# --- I: invocations that must say the check did not run (exit 2) -------------------
run
assert_exit "I1 no argument exits 2" 2 "$code"
assert_contains "I1 prints usage" "usage: research-check.sh" "$out"
run "$TMP/does-not-exist.md"
assert_exit "I2 a missing report exits 2" 2 "$code"
printf '# not a report\n\nno findings here\n' > "$TMP/bare.md"
run "$TMP/bare.md"
assert_exit "I3 a report without Findings and Notes exits 2" 2 "$code"
assert_contains "I3 says why" "no '## Findings' with a '### Notes' list" "$out"
run "$GOOD" --sources "$TMP/no-such-dir"
assert_exit "I4 a missing sources dir exits 2" 2 "$code"

# --- R: the real report it was built for -------------------------------------------
# RES-002 predates the key-terms comment, so its Verified findings MUST be reported for
# missing terms, and NOTHING else may be: that proves the parser reads a real report
# (counts) and that every other check passes on it.
run "$ROOT/docs/research/RES-002-platform-support.md"
assert_exit "R1 RES-002 fails only on the missing key-terms comments" 1 "$code"
assert_contains "R1 counts RES-002" "44 findings, 25 notes" "$out"
other="$(printf '%s\n' "$out" | grep '^research-check: ' | grep -v -e 'Verified but no key terms' -e ' findings, ' || true)"
assert_exit "R1 no violation other than missing key terms" "" "$other"
nterms="$(printf '%s\n' "$out" | grep -c 'Verified but no key terms')"
assert_exit "R1 all 17 Verified findings are named" 17 "$nterms"

exit "$fail"
