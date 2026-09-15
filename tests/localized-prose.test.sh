#!/usr/bin/env bash
# Tests for USR-005: the deterministic evidence that prose follows the output
# language while machine surfaces stay English.
#
# What this file proves, and what it deliberately does NOT:
#   AC3 in full        this repo's own override beats a non-English global default
#   AC4 in full        the no-leak guard passes the named generated-shaped fixture,
#                      and FIRES when a machine surface on that same fixture is mutated
#   AC1 wiring only    the canonical rule exists and the per-file wiring is linted.
#                      No script here can assert that a body is GERMAN (the detector is
#                      USR-006). AC1's generated-output half is proven by the live
#                      procedure in docs/checklists/language-live-check.md, read by a
#                      human at the gate.
#
# FILE-WIDE INVARIANT: no case may invoke resolve-language.sh or language-status.sh
# without a CLAUDE_GLOBAL_CONFIG="$tmpglobal" prefix. Both default that path to
# $HOME/.claude/CLAUDE.md (resolve-language.sh:37, language-status.sh:42), so an
# unprefixed call reads the developer's real global config. That breaks the convention
# that tests never touch it AND lets an assertion pass for the wrong reason: with the
# project override winning, `en project` prints either way, so the case designed to
# separate a winning override from a coinciding fallback would prove nothing.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
assert_eq()       { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_exit()     { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
tmpglobal="$TMP/global-CLAUDE.md"
GUARD="$ROOT/bin/language-guard.sh"
FIXTURE="$ROOT/tests/fixtures/language-de-project"
PRD="$FIXTURE/docs/prds/PRD-901-login.md"

# ---------------------------------------------------------------------------
# 1. AC3, resolution: a non-English GLOBAL default loses to this repo's override.
# ---------------------------------------------------------------------------
for code in de hr fr; do
  printf '# G\noutput_language: %s\n' "$code" > "$tmpglobal"
  got="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$ROOT/bin/resolve-language.sh" "$ROOT" 2>&1)"
  assert_eq "global '$code' loses to this repo's own override (resolve)" "en" "$got"
done

# ---------------------------------------------------------------------------
# 2. AC3, scope: the SCOPE word is what proves the override won rather than the
#    fallback coinciding. `en default` would also carry the code `en`.
# ---------------------------------------------------------------------------
printf '# G\noutput_language: de\n' > "$tmpglobal"
got="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$ROOT/bin/language-status.sh" "$ROOT" 2>&1)"
assert_eq "global 'de': scope is project, not default" "en project" "$got"
printf '# G\noutput_language: hr\n' > "$tmpglobal"
got="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$ROOT/bin/language-status.sh" "$ROOT" 2>&1)"
assert_eq "global 'hr': scope is project, not default" "en project" "$got"
printf '# G\noutput_language: fr\n' > "$tmpglobal"
got="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$ROOT/bin/language-status.sh" "$ROOT" 2>&1)"
assert_eq "global 'fr': scope is project, not default" "en project" "$got"

# ---------------------------------------------------------------------------
# 2b. POSITIVE CONTROL for cases 1 and 2. Without it those six assertions cannot
#     tell "the en override beat a German global" from "no global was ever read":
#     both produce `en project`. Point the SAME env var at the SAME temp global from
#     a directory with no override of its own, and the German must come through. If
#     this case ever prints `en default`, cases 1 and 2 are proving nothing.
# ---------------------------------------------------------------------------
printf '# G\noutput_language: de\n' > "$tmpglobal"
got="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$ROOT/bin/language-status.sh" "$TMP" 2>&1)"
assert_eq "control: the temp global IS read where no project override exists" "de global" "$got"

# ---------------------------------------------------------------------------
# 3. AC3, storage: exactly one setting line, and its value is en.
# ---------------------------------------------------------------------------
assert_eq "this repo's CLAUDE.md carries exactly one output_language line" \
  "1" "$(grep -c '^output_language:' "$ROOT/CLAUDE.md" | tr -d ' ')"
assert_eq "and its value is en" \
  "en" "$(awk -F':[[:space:]]*' '/^output_language:/{print $2; exit}' "$ROOT/CLAUDE.md" | tr -d '[:space:]')"

# ---------------------------------------------------------------------------
# 4. AC4, the named fixture: a whole generated-shaped artifact with a GERMAN body
#    and a GERMAN H1, run together with the branch and commit tokens of a
#    localized run. This is the named AC4 evidence.
# ---------------------------------------------------------------------------
out="$(bash "$GUARD" "$PRD" --branch feature/usr-005-localized-prose \
  --commit "feat(language): honor the output language in generated prose" 2>&1)"; rc=$?
assert_exit "guard passes the German-body fixture PRD with localized-run tokens" 0 "$rc"
assert_contains "guard reports machine surfaces clean" "machine surfaces clean" "$out"

# The fixture's own SHAPE is asserted here, because the guard never reads below the
# closing --- and would therefore exit 0 for an all-ASCII body too. A first draft of
# this fixture wrote German in ASCII transliteration (Inaktivitaet), which would have
# made the case above prove nothing: the point is that NON-ASCII prose passes a guard
# that ASCII-checks every machine surface. Asserting a committed fixture's property is
# not a language detector (that is USR-006), it is a guard against silent regression.
# The number 6 is LOAD-BEARING, not incidental: USR-006 gate decision G3 rewrites this
# fixture's three German section headings to English, and its safety argument is that
# the headings carry no letters while 5 prose lines plus the H1 do. A failure here means
# one of exactly two things, and both need a deliberate answer rather than a nudge to the
# number: either the fixture's German prose was reduced, which must be restored or the
# count re-derived on purpose, or a heading gained a non-ASCII letter, which violates
# USR-005 design decision 3 (a localized PRD keeps English section headings).
# Do NOT delete the body half as redundant: it is the in-suite positive control for the
# frontmatter half's negative claim, which would otherwise pass on a broken instrument.
# letter_lines FILE REGION, REGION is body|frontmatter. PRINTS the number of lines in
# that region carrying at least one non-ASCII LETTER. One site for the character class,
# so the two assertions below cannot drift apart. It PRINTS a count and must never be
# used as a predicate: grep -c exits 1 on zero matches, which this file's pipefail would
# turn into a failure of the wrong kind.
#
# THE CLASS: $'[\303-\305][\200-\277]' matches U+00C0 to U+017F, the Latin-1 Supplement
# plus Latin Extended-A. It covers the German and French letters AND the Croatian ones
# (c-caron, c-acute, s-caron, z-caron, d-stroke) that a Latin-1-only $'\303[\200-\277]'
# would miss, which is what case R2 exists to pin. It REJECTS U+2019, U+00A0, U+250C,
# U+1F600, U+2013 and TAB, which is what case R1 exists to pin.
# What it replaced and why: $'[\200-\377]' matched every byte at or above 0x80, so a
# fully transliterated German body carrying a curly apostrophe, an NBSP or box-drawing
# bytes satisfied it. Three such wrong-reason passes were demonstrated. The old comment
# called that class "UTF-8 LEAD BYTES", which was wrong in the other direction:
# continuation bytes are in it too. Claim no wider than the mechanism.
# Verified on both grep binaries present here (the ugrep on PATH and /usr/bin/grep),
# FROM A SCRIPT FILE, because an inline $'...' pattern passed through a tool command
# layer can arrive mangled and then silently match nothing.
# Honest caveat, written rather than left to be rediscovered: it is a letter BLOCK
# range, not a letter class, so the multiplication and division signs (U+00D7, U+00F7)
# match too. A fixture translated outside those two blocks (Greek, Cyrillic) fails
# LOUDLY rather than silently, which is the safe direction.
letter_lines() {
  case "$2" in
    body)        awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$1" ;;
    frontmatter) awk '/^---$/{n++; next} n==1{print}' "$1" ;;
    *)           echo "letter_lines: bad region '$2'" >&2; return 2 ;;
  esac | LC_ALL=C grep -c $'[\303-\305][\200-\277]'
}
body_nonascii="$(letter_lines "$PRD" body)"
fm_nonascii="$(letter_lines "$PRD" frontmatter)"
assert_eq "the fixture body carries non-ASCII letters on exactly 6 lines" "6" "$body_nonascii"
assert_eq "and the fixture frontmatter carries none" "0" "$fm_nonascii"

# ---------------------------------------------------------------------------
# 4b. The letter class itself, two clauses, one case each. These exist because the
#     class shipped in USR-005 counted non-ASCII BYTES while three surfaces claimed
#     LETTERS, and three wrong-reason passes were demonstrated on it. R1 is the
#     REJECTION clause, R2 the ACCEPTANCE clause. They use SEPARATE documents on
#     purpose: sharing one would put five letters in R2's count and break both
#     mutation-attribution claims in this task's verify block.
# ---------------------------------------------------------------------------
# R1: nothing here is a letter, so the count must be 0. The four noise lines carry,
# one each, U+2019 (curly apostrophe), U+00A0 (NBSP), U+250C (box drawing, inside a
# fence) and a TAB indent. The TAB line is aimed at the OTHER class named in the old
# comment, [^ -~], which DOES match TAB: mutation 3 below uses it to catch the
# plausible "just use [^ -~]" fix. Under the byte class this task replaces,
# $'[\200-\377]', R1 reports 3 and not 4, because TAB is 0x09 and is not in it.
r1="$TMP/r1-noise.md"
{
  printf -- '---\nid: PRD-999\ntitle: Session timeout\nstatus: draft\n---\n\n'
  printf 'Angemeldete Nutzer verlassen ihren Arbeitsplatz ohne sich abzumelden.\n'
  printf 'Das betrifft geteilte Rechner in Grossraumbueros und an Empfangstresen.\n'
  printf 'Ein Hinweis kurz davor ist nicht Teil dieser Aenderung.\n'
  printf 'curly \xe2\x80\x99 apostrophe\n'
  printf 'nbsp \xc2\xa0 here\n'
  printf '```\nbox \xe2\x94\x8c drawing\n```\n'
  printf '\ttab indented line\n'
} > "$r1"
assert_eq "R1 rejection: no letter in the noise document" "0" "$(letter_lines "$r1" body)"

# R2: exactly two lines carry letters. This case PASSES under the old byte class too,
# and that is deliberate: it exists to block the plausible WRONG fix. A Latin-1-only
# $'\303[\200-\277]' reports 1, not 2, because the Croatian letters lead with 0xC4
# and 0xC5. It carries NONE of R1's four noise lines.
# NOTE on the escapes above and below: they are written as LITERAL backslash-x
# sequences on purpose, so bash printf emits raw bytes at run time. Writing the
# characters directly double-encodes them (0xe2 becomes C3 A2), and C3 is inside this
# file's letter class, which made R1 count 3 and made R2 pass for the WRONG reason
# during authoring. Keep them as escapes.
r2="$TMP/r2-letters.md"
{
  printf -- '---\nid: PRD-998\ntitle: Session timeout\nstatus: draft\n---\n\n'
  printf 'Angemeldete Nutzer verlassen ihren Arbeitsplatz ohne sich abzumelden.\n'
  printf 'Das betrifft geteilte Rechner in Grossraumbueros und an Empfangstresen.\n'
  printf 'German letters: M\xc3\xa4dchen und Stra\xc3\x9fe.\n'
  printf 'Croatian letters: \xc4\x8d \xc4\x87 \xc5\xa1 \xc5\xbe \xc4\x91.\n'
} > "$r2"
assert_eq "R2 acceptance: both letter lines counted" "2" "$(letter_lines "$r2" body)"

# ---------------------------------------------------------------------------
# 5. AC4, mutation 1: a non-ASCII frontmatter VALUE on that same artifact must
#    FIRE. Without this, case 4 could be passing vacuously.
# ---------------------------------------------------------------------------
mut1="$TMP/PRD-901-login.md"
{ head -n 4 "$PRD"; printf 'owner: Jos\xc3\xa9 Alvarez\n'; tail -n +5 "$PRD"; } > "$mut1"
out="$(bash "$GUARD" "$mut1" 2>&1)"; rc=$?
assert_exit "guard FIRES on a non-ASCII frontmatter value" 1 "$rc"
assert_contains "and names the frontmatter field value" "frontmatter field value" "$out"

# ---------------------------------------------------------------------------
# 6. AC4, mutation 2: a non-ASCII FILENAME must FIRE. Genuinely new coverage:
#    among USR-001's 19 cases there is no non-ASCII filename case at all
#    (tests/language-guard.test.sh:79 is an ASCII bad slug, :94 is a directory).
# ---------------------------------------------------------------------------
mut2="$TMP/$(printf 'PRD-902-l\xc3\xb6gin.md')"
cp "$PRD" "$mut2"
out="$(bash "$GUARD" "$mut2" 2>&1)"; rc=$?
assert_exit "guard FIRES on a non-ASCII filename" 1 "$rc"
assert_contains "and names the filename" "filename" "$out"

# ---------------------------------------------------------------------------
# 7. AC1, wiring only: the canonical rule exists and cannot silently vanish.
#    Each required token gets its OWN grep, because a combined -e count is
#    satisfied by several lines all matching the same token.
# ---------------------------------------------------------------------------
assert_eq "AGENTS.md carries exactly one Guardrails 7 section heading" \
  "1" "$(grep -c '^### 7\. Output language' "$ROOT/AGENTS.md" | tr -d ' ')"
section="$(awk '/^### 7\. Output language/,0' "$ROOT/AGENTS.md")"
for tok in '[E]' '[I]' 'resolve-language.sh' 'language-guard.sh' 'output_language'; do
  case "$section" in
    *"$tok"*) echo "ok: section 7 states '$tok'";;
    *) echo "FAIL: section 7 is missing '$tok'"; fail=1;;
  esac
done
assert_contains "the global baseline carries the rule" "output_language" "$(cat "$ROOT/global/CLAUDE.md")"
assert_eq "the global baseline carries NO setting line (USR-003's one-time ask must survive)" \
  "0" "$(grep -c '^output_language:' "$ROOT/global/CLAUDE.md" | tr -d ' ')"
bash "$ROOT/bin/skills-lint.sh" "$ROOT" >/dev/null 2>&1
assert_exit "skills-lint C13 confirms the per-file wiring" 0 "$?"

echo ""
if [ "$fail" -eq 0 ]; then echo "localized-prose: all assertions passed."; else echo "localized-prose: FAILURES above."; fi
exit "$fail"
