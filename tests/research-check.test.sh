#!/usr/bin/env bash
# Tests for scripts/research-check.sh, the mechanical check a research report runs before
# review (skills/research/SKILL.md step 5b).
#
# One GOOD report is built below; every other case is that report with ONE mutation, so a
# case that turns red is attributable to its mutation alone. The mutations are the defect
# classes the RES-002 review rounds 4 to 7 found by hand.
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
assert_contains "M4b says the quotes were not checked" "quotes: not checked" "$out"

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
assert_contains "M7 names F1 and note 2" "F1: quote term 'daily' not inside a quote of note 2" "$out"
assert_absent "M7 does not blame note 1, which quotes it" "not inside a quote of note 1" "$out"

mutate m8 "
  <!-- terms: feature X; every plan|all plans -->" ""
run "$TMP/m8.md"
assert_exit "M8 Verified without key terms fails" 1 "$code"
assert_contains "M8 names F1" "F1: Verified but no quote terms" "$out"

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
assert_contains "I2 says why" "cannot read report" "$out"
printf '# not a report\n\nno findings here\n' > "$TMP/bare.md"
run "$TMP/bare.md"
assert_exit "I3 a report without Findings and Notes exits 2" 2 "$code"
assert_contains "I3 says why" "no '## Findings' with a '### Notes' list" "$out"
run "$GOOD" --sources "$TMP/no-such-dir"
assert_exit "I4 a missing sources dir exits 2" 2 "$code"
assert_contains "I4 says why" "does not exist" "$out"

# --- R: a report in the shape of a real one (wrapped notes, backtick code quotes, a C
# finding, ### sub-headings, a table). It lives in tests/fixtures, which is public, so the
# suite reads nothing internal and is the same on every clone.
FX="$ROOT/tests/fixtures/research"
run "$FX/report-real-shape.md" --sources "$FX/sources"
assert_exit "R1 the real-shaped report passes with its sources" 0 "$code"
assert_contains "R1 counts it" "4 findings, 4 notes" "$out"
assert_contains "R1 checks every quote" "quotes: 8/8 verbatim" "$out"

# --- N: the ways round 1 of review made the check pass without checking (each was red
# on 25b2a85, before the fix) ---------------------------------------------------------
mutate n1 "- **F1** Tool A" "- **Finding 1** Tool A"
python3 -I - "$TMP/n1.md" <<'PY'
import re, sys
p = sys.argv[1]; t = open(p).read()
t = re.sub(r"- \*\*([FC])(\d)\*\*", r"- **Finding \2**", t)
t = re.sub(r"\(([^()]*)\)", lambda m: "(" + re.sub(r"\b[FC]\d\b", "item", m.group(1)) + ")" if re.search(r"\b[FC]\d\b", m.group(1)) else m.group(0), t)
t = re.sub(r"(?m)^- [FC]\d: ", "- item: ", t)
open(p, "w").write(t)
PY
run "$TMP/n1.md"
assert_exit "N1 no finding parsed means the check did not run" 2 "$code"
assert_contains "N1 says why" "no findings parsed" "$out"

run "$GOOD" --sources ""
assert_exit "N2 an empty --sources value exits 2" 2 "$code"
assert_contains "N2 says why" "--sources needs a directory" "$out"

mkdir -p "$TMP/self"; cp "$GOOD" "$TMP/self/report.md"; cp -R "$SRC/." "$TMP/self/"
run "$TMP/self/report.md" --sources "$TMP/self"
assert_exit "N3 a sources dir holding the report itself exits 2" 2 "$code"
assert_contains "N3 says why" "contains the report" "$out"
mkdir -p "$TMP/withres"; cp -R "$SRC/." "$TMP/withres/"; cp "$GOOD" "$TMP/withres/RES-777-other.md"
run "$GOOD" --sources "$TMP/withres"
assert_exit "N3b a sources dir holding a RES report exits 2" 2 "$code"
assert_contains "N3b says why" "contains a research report" "$out"

python3 -I - "$GOOD" "$TMP/n4.md" <<'PY'
import re, sys
t = open(sys.argv[1]).read()
head, notes = t.split("### Notes", 1)
notes, tail = notes.split("## Numbers", 1)
notes = re.sub(r'"([^"]*)"', "“\\1”", notes)
open(sys.argv[2], "w").write(head + "### Notes" + notes + "## Numbers" + tail)
PY
run "$TMP/n4.md" --sources "$SRC"
assert_exit "N4 sources given but no checkable quote found exits 2" 2 "$code"
assert_contains "N4 says why" "no checkable quotes" "$out"

mutate n5 "<!-- terms: feature X; every plan|all plans -->" "<!-- terms: feature X; abc1234 -->"
run "$TMP/n5.md"
assert_exit "N5 a term found only in a locator fails" 1 "$code"
assert_contains "N5 note 2's locator does not count" "F1: quote term 'abc1234' not inside a quote of note 2" "$out"

mutate n6 "<!-- terms: feature X; every plan|all plans -->" "<!-- terms: every plan Tool B -->"
run "$TMP/n6.md"
assert_exit "N6 a term spanning two quotes fails" 1 "$code"
assert_contains "N6 names note 1" "F1: quote term 'every plan Tool B' not inside a quote of note 1" "$out"

mutate n7 "<!-- terms: feature X; every plan|all plans -->" "<!-- terms: magic flag -->"
python3 -I - "$TMP/n7.md" <<'PY'
import sys
p = sys.argv[1]; t = open(p).read()
t = t.replace('limits table: "5 seats".', 'limits table: "5 seats"; flag: "magic flag".')
t = t.replace('line 9: `MAX_SEATS = 10`.', 'line 9: `MAX_SEATS = 10`; line 12: "magic flag".')
open(p, "w").write(t)
PY
run "$TMP/n7.md" --sources "$SRC"
assert_exit "N7 a short quote that carries a term is checked against the sources" 1 "$code"
assert_contains "N7 names the invented quote" 'quote not found verbatim: "magic flag"' "$out"

mutate n8 "1. Acme docs, acme.dev/docs/features:" '1. Acme docs, acme.dev/docs/features (the 27" page):'
run "$TMP/n8.md"
assert_exit "N8 an odd number of quote marks fails" 1 "$code"
assert_contains "N8 names note 1" "note 1: odd number of '\"'" "$out"

mutate n9 "1. Acme docs, acme.dev/docs/features:" "1. Acme docs at acme.dev/docs/features:"
run "$TMP/n9.md"
assert_exit "N9 a Verified note without a source header fails" 1 "$code"
assert_contains "N9 names note 1" "note 1: no '<source>, <locator>: ' header" "$out"

mutate n10 "2. Acme source, github.com" "2. Acme Docs, github.com"
python3 -I - "$TMP/n10.md" <<'PY'
import sys
p = sys.argv[1]; t = open(p).read()
t = t.replace("1. Acme docs, acme.dev", "1. acme  docs, acme.dev"); open(p, "w").write(t)
PY
run "$TMP/n10.md"
assert_exit "N10 one source named in two spellings is still one source" 1 "$code"
assert_contains "N10 names F1" "F1: Verified on notes from one source" "$out"

mutate n11 "2. Acme source, github.com" "1. Acme source, github.com"
run "$TMP/n11.md"
assert_exit "N11 a duplicate note number fails" 1 "$code"
assert_contains "N11 names note 1" "note 1: duplicate note number" "$out"

mutate n12 '"Tool B
   runs job Y daily"' '"Tool B
   runs job Y 日本語 daily"'
# N12 exercises a narrow output encoding only where the en_US.ISO8859-1 locale exists
# (macOS has it); elsewhere Python falls back to UTF-8 and the case passes trivially.
out="$(LC_ALL=en_US.ISO8859-1 LANG=en_US.ISO8859-1 bash "$SCRIPT" "$TMP/n12.md" --sources "$SRC" 2>&1)"; code=$?
assert_exit "N12 a non-ASCII misquote in a narrow locale is a violation, not a crash" 1 "$code"
assert_contains "N12 the violation is printed" "note 1: quote not found verbatim" "$out"
assert_absent "N12 no traceback" "Traceback" "$out"

mutate n13 "- C1: 5 seats (note 1) against 10 seats (note 2)." "- (no conflicts)"
run "$TMP/n13.md"
assert_exit "N13 a conflict missing from Unverified fails" 1 "$code"
assert_contains "N13 names C1" "C1: conflict but not listed under Unverified" "$out"

mutate n14 "changelog disagree on the plan limit (C1)." "changelog disagree on the plan limit (C1), as a C3 model would."
run "$TMP/n14.md"
assert_exit "N14 an F/C-like word outside a citation is not a reference" 0 "$code"
assert_absent "N14 no unknown-finding report" "unknown finding" "$out"

# --- P: round 2 of review found the parser still read what it did not understand as
# clean. Notes now parse FAIL CLOSED: one header grammar, no typographic quote marks, and
# a sources dir that holds a copy of the report's text is refused (each red on 56ded01
# except P5, which locks the relaxation). P1 runs once per typographic mark, so dropping
# any one of the five from the script turns its own P1 line red.
for mark in '“' '”' '„' '«' '»'; do
  mutate p1 '"Tool B
   runs job Y daily"' "${mark}Tool B
   runs job Y daily${mark}"
  run "$TMP/p1.md" --sources "$SRC"
  assert_exit "P1 [$mark] a typographic quote mark outside a quote fails" 1 "$code"
  assert_contains "P1 [$mark] names note 1" "note 1: typographic quote mark" "$out"
done

mkdir -p "$TMP/copy"; cp -R "$SRC/." "$TMP/copy/"; cp "$GOOD" "$TMP/copy/draft.md"
run "$GOOD" --sources "$TMP/copy"
assert_exit "P2 a sources dir holding a renamed copy of the report exits 2" 2 "$code"
assert_contains "P2 says why" "holds the text of note" "$out"

mutate p3 '1. Acme docs, acme.dev/docs/features: "Tool A ships feature X on every plan"' '1. Acme docs, page "Plans: overview" says feature X on every plan "Tool A ships"'
run "$TMP/p3.md"
assert_exit "P3 a colon inside the first quote is not a header" 1 "$code"
assert_contains "P3 names note 1" "note 1: no '<source>, <locator>: ' header" "$out"

mutate p4 "- F2: one source." "- F2: one source (note 7)."
run "$TMP/p4.md"
assert_exit "P4 a missing note cited outside Findings fails" 1 "$code"
assert_contains "P4 names the section and note" "Unverified: cites missing note 7" "$out"

mutate p5 "1. Acme docs, acme.dev" '1. Acme `acme-cli` docs, acme.dev'
run "$TMP/p5.md"
assert_exit "P5 a code span inside a note's source name is allowed" 0 "$code"
assert_contains "P5 still parses both notes" "3 findings, 2 notes" "$out"

out="$(perl -e 'alarm 20; exec @ARGV' bash "$SCRIPT" "$GOOD" --sources / 2>&1)"; code=$?
assert_exit "P6 --sources / is refused before walking the filesystem" 2 "$code"
assert_contains "P6 says why" "contains the report itself" "$out"

mkdir -p "$TMP/lowres"; cp -R "$SRC/." "$TMP/lowres/"; printf 'x\n' > "$TMP/lowres/res-777-other.md"
run "$GOOD" --sources "$TMP/lowres"
assert_exit "P7 a lower-case res-NNN report in sources exits 2" 2 "$code"
assert_contains "P7 says why" "contains a research report" "$out"

mutate p8 '"Tool B
   runs job Y daily"' '"Tool B says the “sync” job runs daily"'
mkdir -p "$TMP/curly"; cp -R "$SRC/." "$TMP/curly/"
printf 'Tool B says the “sync” job runs daily.\n' > "$TMP/curly/blog.md"
run "$TMP/p8.md" --sources "$TMP/curly"
assert_exit "P8 a source's own curly quotes inside a straight quote pass" 0 "$code"
assert_contains "P8 the nested quote is checked verbatim" "quotes: 3/3 verbatim" "$out"

# --- Q: round 3 of review found note CITATIONS read as clean when the parser did not
# understand them (a qualifier, a section outside the checked list). Every parenthesis
# outside the Notes list is now scanned, and a "note" in one that is not a number list is a
# violation (each red on 053f4ef except Q7, which locks what stays allowed).
# Mutations of scripts/research-check.sh, each run on a copy, with the cases they redden:
#   drop one mark from TYPOGRAPHIC -> that mark's P1 (2 lines); check typographic marks in
#   the whole note body -> P8 (1); keep code spans and link targets in paren_texts -> Q7 (2);
#   drop the ", <qualifier>" tail from NOTE_LIST -> Q2 name, Q8 (2); allow digits in that tail
#   -> Q9 (2); never append the
#   unreadable-citation violation -> Q6 (2); scan only Answer, Implications, Numbers and
#   Unverified -> Q3, Q4, Q5 (6); drop re.I from NOTE_WORD -> Q4 (2).
mutate q1 "Tool A has feature X (verified, F1);" "Tool A has feature X (verified, F1, note 9);"
run "$TMP/q1.md"
assert_exit "Q1 a missing note cited in Answer fails" 1 "$code"
assert_contains "Q1 names the section and note" "Answer: cites missing note 9" "$out"

mutate q2 "**One source** (note 1)" "**One source** (note 9, measured)"
run "$TMP/q2.md"
assert_exit "Q2 a qualified citation of a missing note in a finding fails" 1 "$code"
assert_contains "Q2 names F2 and the note" "F2: cites missing note 9" "$out"

mutate q3 "against 10 seats (note 2).

### Notes" "against 10 seats (note 2).

| Plan | Seats |
|---|---|
| Pro | 10 (note 9) |

### Notes"
run "$TMP/q3.md"
assert_exit "Q3 a missing note cited in a table under Findings fails" 1 "$code"
assert_contains "Q3 names the section and note" "Findings: cites missing note 9" "$out"

mutate q4 "Does Tool A have feature X?" "Does Tool A have feature X (Note 9)?"
run "$TMP/q4.md"
assert_exit "Q4 a missing note cited in Question, capitalised, fails" 1 "$code"
assert_contains "Q4 names the section and note" "Question: cites missing note 9" "$out"

mutate q5 "- acme.dev/docs/features;" "- acme.dev/docs/features (note 9);"
run "$TMP/q5.md"
assert_exit "Q5 a missing note cited in Sources fails" 1 "$code"
assert_contains "Q5 names the section and note" "Sources: cites missing note 9" "$out"

mutate q6 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, notes 1 and 2)."
run "$TMP/q6.md"
assert_exit "Q6 a note citation that is not a number list fails" 1 "$code"
assert_contains "Q6 names the section" "Implications for us: unreadable note citation" "$out"

mutate q7 "- Rely on feature X (F1, verified)." '- Rely on feature X (F1, verified; see [the docs](https://acme.dev/notes/3) and `notes.rs`).'
run "$TMP/q7.md"
assert_exit "Q7 a link target or code span with \"notes\" is not a citation" 0 "$code"
assert_absent "Q7 no citation report" "note citation" "$out"

mutate q8 "**Verified** (notes 1, 2)" "**Verified** (notes 1,
  2, both read; 2026-10-20)"
run "$TMP/q8.md" --sources "$SRC"
assert_exit "Q8 a qualified two-note citation still verifies" 0 "$code"
assert_contains "Q8 the quote terms were still checked" "quotes: 3/3 verbatim" "$out"

# Round 4: a number after the comma tail was read as qualifier text, so "(notes 1, and 9)"
# skipped note 9. A qualifier after a comma now holds no digit; one with a digit follows ";".
mutate q9 "**One source** (note 1)" "**One source** (notes 1, and 9)"
run "$TMP/q9.md"
assert_exit "Q9 a number hidden in a comma qualifier fails" 1 "$code"
assert_contains "Q9 names F2" "F2: unreadable note citation" "$out"

# --- S: round-4 and round-5 nitpicks. Headings and the text above the first "## " are
# scanned too, an unclosed parenthesis is read to the end of its paragraph, and the message
# names every allowed form. Each case is red on c8ced0a except S1, S2 and S8 to S12. S1,
# S2 and S10 to S12 lock what stays allowed; S1 and S2 redden the mutations "scan the Notes
# list too" and "do not blank nested parentheses". S5 reddens no listed mutation now: it
# stays as a regression lock for parentheses nested inside a link address.
# Mutations, each run on a copy, with the cases they redden: scan the Notes list too -> S1
#   (2); do not blank nested parentheses -> S2 (1); drop the heading line from each section
#   -> S3 (2); drop the "Title" part -> S4 (2); skip unclosed parentheses -> S6 (2); drop
#   "reword" from the message -> S7 (1); split the note segment on ")" as well as ";" -> S9
#   (2). Link mutations are listed with S10 to S12 below.
mutate s1 "2. Acme source, github.com/acme/a" "2. Acme source (release notes), github.com/acme/a"
run "$TMP/s1.md"
assert_exit "S1 a parenthesis inside the Notes list is not a citation" 0 "$code"
assert_absent "S1 no citation report" "note citation" "$out"

mutate s2 "**Verified** (notes 1, 2)" "**Verified** (notes 1, 2 (both read 2026-10-20))"
run "$TMP/s2.md" --sources "$SRC"
assert_exit "S2 a nested parenthesis after the note list is allowed" 0 "$code"
assert_contains "S2 the quote terms were still checked" "quotes: 3/3 verbatim" "$out"

mutate s3 "## Numbers" "## Numbers (note 9)"
run "$TMP/s3.md"
assert_exit "S3 a missing note cited in a heading fails" 1 "$code"
assert_contains "S3 names the section and note" "Numbers: cites missing note 9" "$out"

mutate s4 "# RES-900: fixture" "# RES-900: fixture (note 9)"
run "$TMP/s4.md"
assert_exit "S4 a missing note cited above the first section fails" 1 "$code"
assert_contains "S4 names the title part and note" "Title: cites missing note 9" "$out"

mutate s5 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, see [wiki](https://w.org/Foo_(bar)), note 9)."
run "$TMP/s5.md"
assert_exit "S5 a link address with parentheses does not hide a citation" 1 "$code"
assert_contains "S5 names the section and note" "Implications for us: cites missing note 9" "$out"

mutate s6 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, verified; note 9."
run "$TMP/s6.md"
assert_exit "S6 an unclosed parenthesis with a note fails" 1 "$code"
assert_contains "S6 names the section" "Implications for us: unreadable note citation" "$out"

mutate s7 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, verified; a note on pricing)."
run "$TMP/s7.md"
assert_exit "S7 prose with note in a parenthesis fails" 1 "$code"
assert_contains "S7 the message names the semicolon form" "(note N; <qualifier>)" "$out"
assert_contains "S7 the message offers rewording" "reword" "$out"

mutate s8 "- Rely on feature X (F1, verified)." "- Rely on [wiki](https://w.org/a and X (F1, verified) then (note 8) end)."
run "$TMP/s8.md"
assert_exit "S8 a link missing its closing parenthesis does not hide a citation" 1 "$code"
assert_contains "S8 names the section and note" "Implications for us: cites missing note 8" "$out"

mutate s9 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, note 1, a (b (c) d) e 9)."
run "$TMP/s9.md"
assert_exit "S9 text after a two-deep nested parenthesis is still read" 1 "$code"
assert_contains "S9 names the section" "Implications for us: unreadable note citation" "$out"

# Round 2 found the link-address regex too tight after round 1 found it too loose, the same
# class twice: a hand-made copy of CommonMark. The checker no longer decides where a link
# address ends. It skips the parenthesis right after "]" and blanks only the text directly
# inside it, so a title or a <> address cannot matter, and a citation nested inside a broken
# link is still read (S8). Mutations: never treat "(" after "]" as a link -> Q7, S10, S11,
#   S12 (8); blank nothing inside a link -> S12 (2); also blank parentheses nested inside a
#   link -> S8 (2).
mutate s10 "- Rely on feature X (F1, verified)." '- Rely on feature X (F1, verified) per [docs](https://a.dev/x "release notes").'
run "$TMP/s10.md"
assert_exit "S10 a link title holding notes is not a citation" 0 "$code"
assert_absent "S10 no citation report" "note citation" "$out"

mutate s11 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, verified) per [docs](<https://a.dev/release notes>)."
run "$TMP/s11.md"
assert_exit "S11 an angle-bracket address holding notes is not a citation" 0 "$code"
assert_absent "S11 no citation report" "note citation" "$out"

mutate s12 "- Rely on feature X (F1, verified)." "- Rely on feature X (F1, verified, see [d](https://a.dev/notes/(v2)))."
run "$TMP/s12.md"
assert_exit "S12 a link address with its own parentheses, inside a citation, is not read" 0 "$code"
assert_absent "S12 no citation report" "note citation" "$out"

# Round 3 found that every "(" after "]" counted as a link, so a citation written right
# after a bracket was skipped. A link address never starts with the word note and a space,
# so such a parenthesis is read as a citation. Mutation: drop that test -> S13, S14 (4).
mutate s13 "- Rely on feature X (F1, verified)." "- Rely on feature X [F1](note 9)."
run "$TMP/s13.md"
assert_exit "S13 a citation right after a bracket is read" 1 "$code"
assert_contains "S13 names the section and note" "Implications for us: cites missing note 9" "$out"

mutate s14 "- Rely on feature X (F1, verified)." "- Rely on feature X [F1](Notes 1 and 9)."
run "$TMP/s14.md"
assert_exit "S14 a malformed citation right after a bracket fails" 1 "$code"
assert_contains "S14 names the section" "Implications for us: unreadable note citation" "$out"

exit "$fail"
