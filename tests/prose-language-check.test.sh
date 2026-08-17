#!/usr/bin/env bash
# Tests for bin/prose-language-check.sh, the SOFT prose-language check (USR-006).
#
# THREE FILE-WIDE INVARIANTS. Each exists because a case would otherwise pass for the
# wrong reason, and the third one is what makes every "red alone" mutation claim in the
# plan attributable at all.
#
# (i) NO case invokes the script without a CLAUDE_GLOBAL_CONFIG="$tmpglobal" prefix.
#     The script resolves the expected code through resolve-language.sh, which defaults
#     that path to $HOME/.claude/CLAUDE.md, so an unprefixed call reads the developer's
#     real global config AND can make an assertion pass for the wrong reason.
#
# (ii) NO case asserts a bare zero. Every en=0 claim is paired either with a nonzero
#     assertion on the SAME document (de >= n, so a region that collapsed to empty
#     fails) or with an expected status that IS the collapse (NO-PROSE: K1, K2).
#     Reason: en=0 is satisfied both by an exclusion working and by the whole region
#     vanishing, and the second is the defect class USR-005 shipped.
#
# (iii) THE DOCUMENT SHELL IS NAMED. Frontmatter: only the B and D documents and their
#     controls carry one, plus K2 (whose block is the unterminated one its case exists
#     for). Headings: no document places a COUNTED line immediately after an ATX heading
#     except K5; every B and D heading is followed by a BLANK line. K5 is the one
#     exception to "no heading": exactly one heading (## Ueberblick, which carries no
#     token from any WORDS_* list) and one counted line. The exact-count documents
#     (K6, K7, K8, F1..F4c) and the E and G documents are bare prose or bare word lists
#     with no frontmatter, no fence and no heading at all.
#
# Groups: A, B, D, E, F, G, H, K. There is no group C, so no case id collides with the
# plan's contracts C1..C4; I and J are skipped only to keep the letters visually
# distinct, so H followed by K is not a lost group.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/bin/prose-language-check.sh"
fail=0
assert_eq()       { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_exit()     { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }
assert_absent()   { case "$3" in *"$2"*) echo "FAIL: $1 (unexpected '$2')"; fail=1;; *) echo "ok: $1";; esac; }
assert_ge()       { if [ "$3" -ge "$2" ] 2>/dev/null; then echo "ok: $1"; else echo "FAIL: $1 (expected >= $2, got '$3')"; fail=1; fi; }
assert_le()       { if [ "$3" -le "$2" ] 2>/dev/null; then echo "ok: $1"; else echo "FAIL: $1 (expected <= $2, got '$3')"; fail=1; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
tmpglobal="$TMP/global-CLAUDE.md"
printf '# no setting here\n' > "$tmpglobal"

# A project directory whose CLAUDE.md carries the given code (or none).
mkproj() { # mkproj <dir> [<code>]
  mkdir -p "$1"
  if [ "$#" -ge 2 ]; then printf '# fixture\n\n## Conventions\noutput_language: %s\n' "$2" > "$1/CLAUDE.md"; fi
}
DE="$TMP/proj-de";  mkproj "$DE" de
EN="$TMP/proj-en";  mkproj "$EN" en
HR="$TMP/proj-hr";  mkproj "$HR" hr
BARE="$TMP/proj-bare"; mkproj "$BARE"

# run <project-dir> <file>...  sets OUT and RC as GLOBALS. It deliberately does not
# print, because $(run ...) would execute it in a subshell and the RC set there would
# never reach the parent, which is a broken instrument reporting a real-looking number.
OUT=""; RC=0
run() { local p="$1"; shift; OUT="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$SCRIPT" "$p" "$@" 2>&1)"; RC=$?; }
# field <output> <key> -> the value of key= on the first field line
field() { printf '%s\n' "$1" | grep -m1 '^prose-language: ' | tr ' ' '\n' | grep -m1 "^$2=" | cut -d= -f2; }
# status <output> -> the STATUS token of the first field line
status() { printf '%s\n' "$1" | grep -m1 '^prose-language: ' | awk '{print $2}'; }

# German prose paragraph, 12+ WORDS_DE occurrences, ZERO WORDS_EN, pure ASCII.
de_prose() {
  printf 'Die Sitzung wird nach einer Frist beendet und der Zugriff auf das Konto\n'
  printf 'wird gesperrt, weil ein unbeaufsichtigter Bildschirm ein Risiko ist und\n'
  printf 'weil die Vorgabe es fuer jedes Konto mit Kundendaten verlangt.\n'
}
SIX='the of and that with is'   # six WORDS_EN tokens, the payload every B case moves

# ---------------------------------------------------------------------------
# A. Resolver agreement: expected= always comes from resolve-language.sh.
# ---------------------------------------------------------------------------
doc="$TMP/a.md"; de_prose > "$doc"
run "$HR" "$doc"; out="$OUT"; assert_eq "A1 project hr resolves to expected=hr" "hr" "$(field "$out" expected)"
printf '# G\noutput_language: fr\n' > "$tmpglobal"
run "$BARE" "$doc"; out="$OUT"; assert_eq "A2 no project file, global fr reaches the resolver" "fr" "$(field "$out" expected)"
printf '# no setting here\n' > "$tmpglobal"
run "$BARE" "$doc"; out="$OUT"; assert_eq "A3 neither: expected=en" "en" "$(field "$out" expected)"

# ---------------------------------------------------------------------------
# B. Region isolation, seven cases, each PAIRED with a control. Shared shell per
#    invariant (iii): frontmatter, a German H1, a BLANK line after every heading,
#    and German prose with 12+ WORDS_DE and zero WORDS_EN.
#    The case hides SIX English tokens in ONE excluded position; the control puts the
#    same six in plain prose. en=0 alone would also pass on a collapsed region, so
#    every case also asserts de >= 12 and detected=de (invariant ii).
# ---------------------------------------------------------------------------
b_shell() { # b_shell <file> <payload-line-or-empty> ; payload is inserted verbatim
  {
    printf -- '---\nid: PRD-800\ntitle: Session timeout\nstatus: draft\ndate: 2026-08-13\n---\n\n'
    printf '# PRD-800: Sitzungsablauf\n\n'
    de_prose
    [ -n "${1:-}" ] && printf '%s\n' "$1"
    printf '\n'
    de_prose
  }
}
b_case() { # b_case <id> <desc> <builder-fn>
  local id="$1" desc="$2" fn="$3" f="$TMP/$1.md" o
  "$fn" "$f"
  run "$DE" "$f"; o="$OUT"
  assert_eq   "$id $desc: en=0 (the exclusion removed it)"      "0"  "$(field "$o" en)"
  assert_ge   "$id $desc: de >= 12 (region did not collapse)"   12   "$(field "$o" de)"
  assert_eq   "$id $desc: detected=de"                          "de" "$(field "$o" detected)"
  assert_exit "$id $desc: exit 0"                               0    "$RC"
}
b_control() { # b_control <id> ; the same shell with the six tokens as plain prose
  local id="$1" f="$TMP/$1-control.md" o
  b_shell "$SIX" > "$f"
  run "$DE" "$f"; o="$OUT"
  assert_ge "$id control: the same six tokens DO count as plain prose (en >= 6)" 6 "$(field "$o" en)"
}

b1() { { printf -- '---\nid: PRD-800\ntitle: Session timeout\nsummary: %s\nstatus: draft\n---\n\n' "$SIX"; printf '# PRD-800: Sitzungsablauf\n\n'; de_prose; printf '\n'; de_prose; } > "$1"; }
b2() { { printf -- '---\nid: PRD-800\ntitle: Session timeout\nstatus: draft\n---\n\n'; printf '# PRD-800: Sitzungsablauf\n\n'; printf 'Die Frist ist kurz und das Konto wird gesperrt.\n'; printf '\n```\n%s\n```\n\n' "$SIX"; de_prose; de_prose; } > "$1"; }
b3() { b_shell "Der Wert \`$SIX\` steht im Kopf." > "$1"; }
b4() { { printf -- '---\nid: PRD-800\ntitle: Session timeout\nstatus: draft\n---\n\n'; printf '# PRD-800: Sitzungsablauf\n\n'; printf '## %s\n\n' "$SIX"; de_prose; printf '\n'; de_prose; } > "$1"; }
b5() { b_shell "| $SIX | und mehr |" > "$1"; }
b6() { b_shell "Siehe [Notiz](../notes/the-of-and-that-with-is.md) im Anhang." > "$1"; }
b7() { b_shell "Siehe https://example.test/the-of-and-that-with-is im Anhang." > "$1"; }

b_case B1 "frontmatter field value"      b1; b_control B1
b_case B2 "inside a backtick fence"      b2; b_control B2
b_case B3 "inside an inline code span"   b3; b_control B3
b_case B4 "inside an ATX heading"        b4; b_control B4
b_case B5 "inside a table row"           b5; b_control B5
b_case B6 "inside a RELATIVE link target" b6; b_control B6
b_case B7 "a BARE url in prose"          b7; b_control B7

# ---------------------------------------------------------------------------
# D. Tilde fences. B2 repeated with ~~~, same shape and same assertions, because a
#    builder can easily implement only one fence marker.
# ---------------------------------------------------------------------------
d1() { { printf -- '---\nid: PRD-800\ntitle: Session timeout\nstatus: draft\n---\n\n'; printf '# PRD-800: Sitzungsablauf\n\n'; printf 'Die Frist ist kurz und das Konto wird gesperrt.\n'; printf '\n~~~\n%s\n~~~\n\n' "$SIX"; de_prose; de_prose; } > "$1"; }
b_case D1 "inside a tilde fence" d1; b_control D1

# ---------------------------------------------------------------------------
# E. The other two lists, so none ships untested. Bare prose, no shell.
# ---------------------------------------------------------------------------
fr="$TMP/e-fr.md"
printf 'La session est fermee apres un delai et le compte est protege, parce que\n' > "$fr"
printf 'un ecran sans surveillance est un risque pour tous les clients et pour\n' >> "$fr"
printf 'la societe, et parce que la regle le demande dans tous les cas.\n' >> "$fr"
run "$DE" "$fr"; out="$OUT"
assert_eq "E1 French prose under a de project warns" "WARN" "$(status "$out")"
assert_eq "E1 detected=fr" "fr" "$(field "$out" detected)"
# Croatian needs a denser sample here, and the honest cause is MOSTLY VOCABULARY with a
# smaller structural component, not the structural claim alone. Measured: this sample's
# first three lines already score hr=15 and WARN, so the original failure was mainly that
# the first draft's words were not in the list. The structural part is real but smaller
# than a first reading suggests: the exclusion set removes Croatian's highest-frequency
# tokens (je se i a u o to do on no ne si sa), and this sample carries 15 counted tokens
# out of 36 words against German's 19 out of 33, so a uniform MIN_HITS is slightly less
# sensitive for Croatian. Recorded at the one place a maintainer meets it, sized to what
# was measured rather than to the direction of the effect.
hr="$TMP/e-hr.md"
printf 'Ako korisnik nije aktivan, sesija koja je otvorena zatvara se nakon roka, a\n' > "$hr"
printf 'pristup prema podacima blokira se prije nego ga bilo koji drugi korisnik\n' >> "$hr"
printf 'iskoristi. Ovo pravilo vrijedi za svaki racun i za sve klijente, jer bez\n' >> "$hr"
printf 'njega ekran bez nadzora ostaje otvoren. Zato smo odlucili da ova mjera bude\n' >> "$hr"
printf 'ukljucena od pocetka, kao dio pravila koja su ranije bila dogovorena, i da\n' >> "$hr"
printf 'kroz nju prolaze svi zahtjevi prema kojima se pristup odobrava ili odbija.\n' >> "$hr"
run "$EN" "$hr"; out="$OUT"
assert_eq "E2 Croatian prose under an en project warns" "WARN" "$(status "$out")"
assert_eq "E2 detected=hr" "hr" "$(field "$out" detected)"

# ---------------------------------------------------------------------------
# F. The decision rule, one case per clause. Synthetic bare word lists on purpose,
#    so the arithmetic is exact and no prose judgment enters.
# ---------------------------------------------------------------------------
words() { # words <file> <n-de> <n-en>
  local f="$1" nde="$2" nen="$3" i=0
  : > "$f"
  while [ "$i" -lt "$nde" ]; do printf 'und ' >> "$f"; i=$((i+1)); done
  i=0
  while [ "$i" -lt "$nen" ]; do printf 'the ' >> "$f"; i=$((i+1)); done
  printf '\n' >> "$f"
}
f_case() { # f_case <id> <n-de> <n-en> <want-status> <want-counted>
  local f="$TMP/$1.md" o; words "$f" "$2" "$3"
  run "$DE" "$f"; o="$OUT"
  assert_eq "$1 ($2 de + $3 en): status $4" "$4" "$(status "$o")"
  assert_eq "$1 counted=$5" "$5" "$(field "$o" counted)"
  assert_exit "$1 exit 0" 0 "$RC"
}
f_case F1  0 20 WARN         20
f_case F2  0 11 LOW-EVIDENCE 11
f_case F3 20  8 OK           28
f_case F4a 6  6 OK           12
f_case F4b 5  7 WARN         12
f_case F4c 0 12 WARN         12
run "$DE" "$TMP/F2.md"; o="$OUT"; assert_absent "F2 prints no WARN even at a 100 percent rival" "WARN" "$o"
run "$DE" "$TMP/F3.md"; o="$OUT"; assert_eq "F3 en=8" "8" "$(field "$o" en)"

# ---------------------------------------------------------------------------
# G. Exit codes, usage, and the AC3 core. Content never yields non-zero; a malformed
#    invocation yields 2, meaning THE CHECK DID NOT RUN.
# ---------------------------------------------------------------------------
g() { CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$SCRIPT" "$@" >/dev/null 2>&1; echo $?; }
assert_eq "G1 no arguments -> 2"                  "2" "$(g)"
assert_eq "G2 one argument only -> 2"             "2" "$(g "$DE")"
assert_eq "G3 project dir does not exist -> 2"    "2" "$(g "$TMP/nope" "$TMP/a.md")"
assert_eq "G4 file does not exist -> 2"           "2" "$(g "$DE" "$TMP/nope.md")"
assert_eq "G5 a directory passed as a file -> 2"  "2" "$(g "$DE" "$DE")"
assert_eq "G6 an argument beginning with - -> 2"  "2" "$(g "$DE" --quiet "$TMP/a.md")"
if [ "$(id -u)" = "0" ]; then echo "skip: G7 unreadable file (running as root reads anything)"
else unread="$TMP/unread.md"; de_prose > "$unread"; chmod 000 "$unread"
  assert_eq "G7 an unreadable file -> 2" "2" "$(g "$DE" "$unread")"; chmod 644 "$unread"; fi
run "$DE" "$TMP/B1.md" "$TMP/e-fr.md"; out="$OUT"
assert_exit "G8 multi-file with one warning still exits 0" 0 "$RC"
assert_contains "G8 the summary carries the contract" "warnings never fail" "$out"
assert_contains "G8 the summary counts both files"    "2 file(s) checked, 1 warning(s)" "$out"
assert_eq "G9 the source contains no 'exit 1' literal, which is how never-1 is proven" \
  "0" "$(grep -c 'exit 1' "$SCRIPT")"

# C3 routing, which run() cannot see because it merges 2>&1. A caller that pipes stdout to
# a log and lets stderr reach the user depends on this split.
w_out="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$SCRIPT" "$DE" "$TMP/e-fr.md" 2>/dev/null)"
w_err="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$SCRIPT" "$DE" "$TMP/e-fr.md" 2>&1 >/dev/null)"
assert_absent  "G10 a WARN field line is NOT on stdout" "WARN" "$w_out"
assert_contains "G10 a WARN field line IS on stderr"    "WARN" "$w_err"
assert_contains "G10 the summary stays on stdout"       "warnings never fail" "$w_out"
o_out="$(CLAUDE_GLOBAL_CONFIG="$tmpglobal" bash "$SCRIPT" "$DE" "$TMP/B1.md" 2>/dev/null)"
assert_contains "G11 an OK field line IS on stdout" "prose-language: OK" "$o_out"

# ---------------------------------------------------------------------------
# H. The lists themselves. Extraction WITHOUT sourcing (sourcing runs the argument
#    parsing and exits 2). The instrument is proven BEFORE any negative claim, and it
#    uses the SAME membership helper as those claims, or a matcher that never matches
#    would satisfy all of them while the instrument check stayed green.
# ---------------------------------------------------------------------------
list_of() { sed -n "s/^WORDS_$1=\"\(.*\)\"$/\1/p" "$SCRIPT"; }
has() { case " $1 " in *" $2 "*) return 0;; *) return 1;; esac; }
for c in DE EN FR HR; do
  assert_eq "H one assignment site for WORDS_$c" "1" "$(grep -c "^WORDS_$c=" "$SCRIPT")"
done
assert_eq "H one assignment site for MIN_HITS" "1" "$(grep -c '^MIN_HITS=' "$SCRIPT")"
assert_eq "H MIN_HITS is 12" "12" "$(sed -n 's/^MIN_HITS=\([0-9]*\).*/\1/p' "$SCRIPT")"
L_DE="$(list_of DE)"; L_EN="$(list_of EN)"; L_FR="$(list_of FR)"; L_HR="$(list_of HR)"
# instrument, same helper as the negative claims below
for pair in "DE:und:$L_DE" "EN:the:$L_EN" "FR:les:$L_FR" "HR:koji:$L_HR"; do
  c="${pair%%:*}"; rest="${pair#*:}"; tok="${rest%%:*}"; lst="${rest#*:}"
  if has "$lst" "$tok"; then echo "ok: H instrument: WORDS_$c is non-empty and holds '$tok'"
  else echo "FAIL: H instrument: WORDS_$c missing '$tok', so every set claim below is vacuous"; fail=1; fi
done
for pair in "DE:$L_DE:EN:$L_EN" "DE:$L_DE:FR:$L_FR" "DE:$L_DE:HR:$L_HR" \
            "EN:$L_EN:FR:$L_FR" "EN:$L_EN:HR:$L_HR" "FR:$L_FR:HR:$L_HR"; do
  a="${pair%%:*}"; r="${pair#*:}"; la="${r%%:*}"; r="${r#*:}"; b="${r%%:*}"; lb="${r#*:}"
  clash=""
  for w in $la; do if has "$lb" "$w"; then clash="$w"; break; fi; done
  assert_eq "H $a and $b are disjoint" "" "$clash"
done
for c in DE EN FR HR; do
  eval "lst=\$L_$c"; bad=""; n=0; dup=""
  for w in $lst; do
    n=$((n+1))
    case "$w" in [a-z][a-z]*) : ;; *) bad="$w"; break;; esac
    case "$w" in *[^a-z]*) bad="$w"; break;; esac
  done
  assert_eq "H WORDS_$c entries all match lowercase two-or-more" "" "$bad"
  assert_ge "H WORDS_$c holds at least 50 entries" 50 "$n"
  seen=" "; for w in $lst; do if has "$seen" "$w"; then dup="$w"; break; fi; seen="$seen$w "; done
  assert_eq "H WORDS_$c has no duplicate" "" "$dup"
done
EXCL="a i o u y an in so am was also will man hat war bin des du je se ne si sa to do on no de en fr hr what why how where who"
hit=""
for w in $EXCL; do
  for c in DE EN FR HR; do eval "lst=\$L_$c"; if has "$lst" "$w"; then hit="$w in WORDS_$c"; break 2; fi; done
done
assert_eq "H no exclusion-set token appears in any list" "" "$hit"

# ---------------------------------------------------------------------------
# K. Region edge cases. K1 and K2 are the two documented exemptions from invariant
#    (ii): the empty region IS their expectation, so they cannot be an over-drop
#    instrument. K5..K8 are bare per invariant (iii).
# ---------------------------------------------------------------------------
k1="$TMP/K1.md"; printf '```\nthe of and that with is\n```\n' > "$k1"
run "$DE" "$k1"; out="$OUT"
assert_eq "K1 a document that is only a fence: NO-PROSE" "NO-PROSE" "$(status "$out")"
assert_eq "K1 counted=0" "0" "$(field "$out" counted)"
assert_eq "K1 detected=none" "none" "$(field "$out" detected)"
assert_exit "K1 exit 0" 0 "$RC"

k2="$TMP/K2.md"; { printf -- '---\nid: PRD-801\ntitle: No closing delimiter\n'; de_prose; } > "$k2"
run "$DE" "$k2"; out="$OUT"
assert_eq "K2 unterminated frontmatter: NO-PROSE" "NO-PROSE" "$(status "$out")"
assert_eq "K2 counted=0" "0" "$(field "$out" counted)"
assert_exit "K2 exit 0" 0 "$RC"

k3="$TMP/K3.md"; { de_prose; de_prose; printf '```\n'; printf 'the of and that with is and the of\n'; } > "$k3"
run "$DE" "$k3"; out="$OUT"
assert_eq "K3 unterminated fence drops the tail: en=0" "0" "$(field "$out" en)"
assert_ge "K3 and the head survived: de >= 12" 12 "$(field "$out" de)"

k4="$TMP/K4.md"; b_shell "$SIX" > "$TMP/k4-lf.md"
awk '{printf "%s\r\n", $0}' "$TMP/k4-lf.md" > "$k4"
run "$DE" "$TMP/k4-lf.md"; o_lf="$OUT"; run "$DE" "$k4"; o_cr="$OUT"
for k in counted de en fr hr; do
  assert_eq "K4 CRLF matches LF on $k" "$(field "$o_lf" "$k")" "$(field "$o_cr" "$k")"
done
assert_ge "K4 de >= 12 (a doubly collapsed pair would pass on equality alone)" 12 "$(field "$o_cr" de)"
assert_ge "K4 en >= 6 (inherited from B1's control)" 6 "$(field "$o_cr" en)"

k5="$TMP/K5.md"; printf '## Ueberblick\nund mit von\n' > "$k5"
run "$DE" "$k5"; out="$OUT"
assert_eq "K5 a heading drops ONE line, not the next one: de=3" "3" "$(field "$out" de)"

k6="$TMP/K6.md"; printf 'und mit von `the of` und mit von `and that` und mit von\n' > "$k6"
run "$DE" "$k6"; out="$OUT"
assert_eq "K6 shortest-span deletion keeps the text between spans: de=9" "9" "$(field "$out" de)"
assert_eq "K6 and both spans are gone: en=0" "0" "$(field "$out" en)"

k7="$TMP/K7.md"; printf 'und mit von `zu zum zur\n' > "$k7"
run "$DE" "$k7"; out="$OUT"
assert_eq "K7 an unpaired backtick deletes nothing: de=6" "6" "$(field "$out" de)"

# K8: the leak decision 5 ADMITS, as a tested bound rather than an arithmetic argument.
# for-Schleife -> for; if-then-else -> if, then; Read-Only-Modus -> only. Exactly 4.
# en = 4 EXACTLY, not <= 4: en=0 would mean the leak is no longer exercised at all.
k8="$TMP/K8.md"; { de_prose; de_prose; printf 'Die for-Schleife, das if-then-else und der Read-Only-Modus bleiben.\n'; } > "$k8"
run "$DE" "$k8"; out="$OUT"
assert_eq "K8 the admitted leak is exactly 4 English hits" "4" "$(field "$out" en)"
assert_ge "K8 de >= 12" 12 "$(field "$out" de)"
assert_eq "K8 status OK" "OK" "$(status "$out")"
assert_eq "K8 detected=de" "de" "$(field "$out" detected)"

# ---------------------------------------------------------------------------
# AC. The story's own evidence, over the two NAMED samples in the committed German
#     fixture project. These use the real fixture, not a temp document, because the
#     story asks for "one matching and one mismatching sample".
# ---------------------------------------------------------------------------
FX="$ROOT/tests/fixtures/language-de-project"
P901="$FX/docs/prds/PRD-901-login.md"
P904="$FX/docs/prds/PRD-904-checkout.md"
P905="$FX/docs/prds/PRD-905-api-quota.md"
S901="$FX/docs/stories/USR-901-login-timeout.md"

# AC1: the mismatching sample warns AND names the artifact.
run "$FX" "$P904"; o="$OUT"
assert_eq       "AC1 the mismatching sample warns"        "WARN" "$(status "$o")"
assert_contains "AC1 the field line names the artifact"   "$P904" "$o"
assert_eq       "AC1 expected=de"                         "de" "$(field "$o" expected)"
assert_eq       "AC1 detected=en"                         "en" "$(field "$o" detected)"
assert_contains "AC1 the plain-language line says nothing is blocked" "nothing is blocked" "$o"
assert_exit     "AC1 exit 0"                              0 "$RC"

# AC2: the matching sample does not warn, and cannot pass for LACK OF EVIDENCE. The last
# two assertions are the point twice over: LOW-EVIDENCE would satisfy "no warning is
# shown" while proving nothing about German, and they double as the collapsed-region
# companion for this case.
run "$FX" "$P901"; o="$OUT"
assert_absent "AC2 the matching sample prints no WARN" "WARN" "$o"
assert_eq     "AC2 status OK"                          "OK" "$(status "$o")"
assert_eq     "AC2 detected=de"                        "de" "$(field "$o" detected)"
assert_ge     "AC2 counted >= 12 (not LOW-EVIDENCE for the wrong reason)" 12 "$(field "$o" counted)"

# AC3: exit stays 0, including a multi-file run carrying one warning and one OK.
run "$FX" "$P901"; assert_exit "AC3 matching sample exits 0" 0 "$RC"
run "$FX" "$P904"; assert_exit "AC3 mismatching sample exits 0" 0 "$RC"
run "$FX" "$P904" "$P901"; o="$OUT"
assert_exit     "AC3 both files in one invocation exit 0" 0 "$RC"
assert_contains "AC3 one WARN line" "WARN" "$o"
assert_contains "AC3 one OK line"   "OK"   "$o"
assert_contains "AC3 the summary counts them" "2 file(s) checked, 1 warning(s)" "$o"

# AC4: German prose embedding English TECHNICAL terms must not warn. This en=0 is a
# property of THIS FIXTURE, whose English technical terms are bare single-word nouns and
# whose dense English sits in excluded regions. Attribution to a single exclusion is not
# this case's job but B1..B7's, because every region mutation reddens this case together
# with its B case. Design decision 5 states what the mechanism does and does not deliver.
run "$FX" "$P905"; o="$OUT"
assert_eq "AC4 status OK"        "OK" "$(status "$o")"
assert_eq "AC4 detected=de"      "de" "$(field "$o" detected)"
assert_ge "AC4 counted >= 12"    12   "$(field "$o" counted)"
assert_eq "AC4 en=0"             "0"  "$(field "$o" en)"
# Paired control: the fixture's fenced English sentence, as PLAIN PROSE, must count. This
# is what makes en=0 above attributable to the exclusions rather than to a typo in the
# word list.
ctl="$TMP/ac4-control.md"
# A verbatim copy is correct now. It was not before: the fenced lines used to be
# `# NOTE: ...` comments, and once the FENCE rule is mutated off the heading rule drops them
# anyway, so the mutation had no measurable effect and the recorded proof did not reproduce.
# (In the unmutated script the fence rule drops those lines FIRST; the heading rule is the
# shadow only under the mutation. The distinction is the whole point in a comment that records
# a false proof.) The fixture's fenced block is plain prose now, which is what makes fence-off
# move en from 0 to 27.
awk '/^```/{f=!f; next} f{print}' "$P905" > "$ctl"
run "$FX" "$ctl"; o="$OUT"
assert_ge "AC4 control: the same English DOES count as plain prose (en >= 8)" 8 "$(field "$o" en)"

# The English-on-purpose story warns, and that is CORRECT. An English document really does
# live in this German fixture project (USR-005 design decision 10 keeps USR-901 English so
# a German plan cannot be mimicry), so the check's honest limit is recorded as a case
# instead of discovered later. Nobody may silence this warning by translating that story.
run "$FX" "$S901"; o="$OUT"
assert_eq "AC the English-on-purpose story warns, correctly" "WARN" "$(status "$o")"
assert_eq "AC and it is detected as en" "en" "$(field "$o" detected)"

# The new fixtures must keep USR-001's [E] machine-surface gate green.
for nf in "$P904" "$P905"; do
  g_out="$(bash "$ROOT/bin/language-guard.sh" "$nf" 2>&1)"; g_rc=$?
  assert_exit "AC language-guard passes $(basename "$nf")" 0 "$g_rc"
  assert_contains "AC language-guard reports clean for $(basename "$nf")" "machine surfaces clean" "$g_out"
done

# K9: a LONGER fence wrapping a SHORTER one. The marker toggle used to be a bare flip, so
# the inner ``` closed the outer ```` and the example inside became prose. Measured then:
# en=16 on a correct German artifact. Only a matching-or-longer marker closes a fence now.
k9="$TMP/K9.md"
{ de_prose; de_prose; printf '````\n'; printf '```\n%s and the of and that\n```\n' "$SIX"; printf '````\n'; de_prose; } > "$k9"
run "$DE" "$k9"; o="$OUT"
assert_eq "K9 a shorter inner fence does not close the outer one: en=0" "0" "$(field "$o" en)"
assert_ge "K9 and the German outside both fences survives: de >= 12" 12 "$(field "$o" de)"

# K10: a code span that OPENS on one line and CLOSES on the next. The inline deletions used
# to run per line, so such a span was never deleted and its content counted as prose.
k10="$TMP/K10.md"
{ de_prose; de_prose; printf 'Der Wert `%s\nand the of and` steht im Kopf.\n' "$SIX"; } > "$k10"
run "$DE" "$k10"; o="$OUT"
assert_eq "K10 a code span across two lines is still deleted: en=0" "0" "$(field "$o" en)"
assert_ge "K10 and the surrounding German survives: de >= 12" 12 "$(field "$o" de)"

# K11: the heading rule without awk interval expressions. Up to three leading spaces still
# make a heading, four do not, and seven hashes are not a heading. Intervals were the first
# {n,m} use in bin/ and the awk on the stated portability floor treats them literally, which
# would have silently killed exclusion 4 on installed machines.
k11a="$TMP/K11a.md"; printf '   ## %s\nund mit von zu zum zur\n' "$SIX" > "$k11a"
run "$DE" "$k11a"; o="$OUT"
assert_eq "K11a three leading spaces still make a heading: en=0" "0" "$(field "$o" en)"
assert_eq "K11a and only the heading line went: de=6" "6" "$(field "$o" de)"
k11b="$TMP/K11b.md"; printf '####### %s\nund mit von\n' "$SIX" > "$k11b"
run "$DE" "$k11b"; o="$OUT"
assert_ge "K11b seven hashes are NOT a heading, so the line counts: en >= 6" 6 "$(field "$o" en)"

# K12: THE OVER-DROP DIRECTION of rules 6 to 8, which no case bounded before. Round 2's
# Critical: scoping the inline deletions to the whole region let a stray backtick pair with a
# LATER span's opening backtick and delete every line between them. Measured then: a correct
# German body fell from de=47 to de=5, and an English body under a de project fell from
# WARN en=26 to LOW-EVIDENCE en=0, which silences AC1 outright. K7 names the claim this case
# tests but its fixture is ONE line, so it passes on a document too small to expose the
# mechanism. Paragraph records plus the odd-backtick guard bound it, and this case is what
# reddens if either is removed.
k12="$TMP/K12.md"
{ printf 'Der Wert ` steht hier.\n'; de_prose; de_prose; printf 'Der Code `%s` bleibt.\n' "$SIX"; } > "$k12"
run "$DE" "$k12"; o="$OUT"
assert_ge "K12 a stray backtick does not eat the German bulk behind it: de >= 24" 24 "$(field "$o" de)"
assert_eq "K12 and the document still reads as German: status OK" "OK" "$(status "$o")"
# The paragraph holds an ODD number of backticks, so NO span is deleted anywhere in it: C1
# step 6's "an unpaired backtick deletes nothing", generalized from the line to the paragraph.
# The later span's six English tokens therefore COUNT, and that is the deliberate trade,
# leaving one span in place costs six hits, pairing across it costs the whole paragraph.
assert_eq "K12 the odd-backtick guard leaves the later span in place: en=6" "6" "$(field "$o" en)"

# K12b: the same three pieces separated by BLANK LINES, where the region-scoped deletion did
# the most damage (de=40 down to de=1). A code span cannot contain a blank line, so paragraph
# records make these three records: the stray backtick disables deletion in ITS paragraph
# only, and the ordinary span in the last paragraph is deleted normally.
k12b="$TMP/K12b.md"
{ printf 'Der Wert ` steht hier.\n\n'; de_prose; printf '\n'; de_prose; printf '\nDer Code `%s` bleibt.\n' "$SIX"; } > "$k12b"
run "$DE" "$k12b"; o="$OUT"
assert_ge "K12b blank lines do not let a deletion cross paragraphs: de >= 24" 24 "$(field "$o" de)"
assert_eq "K12b status OK" "OK" "$(status "$o")"
assert_eq "K12b and the span inside its own paragraph IS deleted: en=0" "0" "$(field "$o" en)"

# K12c: RULE 8 in the same direction, as an EXACT count rather than a bound, because the loss
# is a single token and any >= assertion loose enough to hold would sit above it. C1 step 8
# deletes the URL run up to the next whitespace, `)` or `>`, and a newline is whitespace, so
# region scoping made the run swallow the line break plus the first word of the next line.
# de=6 EXACTLY: measured 5 while the deletion crossed the newline, and "und" is the word it ate.
k12c="$TMP/K12c.md"; printf 'Siehe https://example.com/pfad\nund mit von zu zum zur\n' > "$k12c"
run "$DE" "$k12c"; o="$OUT"
assert_eq "K12c a bare URL stops at the newline, so the next line survives whole: de=6" "6" "$(field "$o" de)"

# K12d: RULE 7. A `](` with no closing paren on its own line, and an ordinary parenthesis far
# below it. Region scoping let the link-target deletion run from the `](` all the way to that
# later `)`, taking every German line between them (measured: de=44 down to de=6). The paren
# below is the whole point of the fixture, without it rule 7 never matches and the case would
# pass while pinning nothing, which is how the first draft of it passed.
k12d="$TMP/K12d.md"
{ printf 'Siehe [die Vorgabe](\n'; de_prose; de_prose; printf 'Das ist kurz (fertig).\n'; } > "$k12d"
run "$DE" "$k12d"; o="$OUT"
assert_ge "K12d an unclosed link target does not reach a paren on a later line: de >= 24" 24 "$(field "$o" de)"
assert_eq "K12d status OK" "OK" "$(status "$o")"

# K12e: the OTHER direction of the same change, and the one that moved this repo's own
# AGENTS.md from counted=1028 to counted=1031, which is a CORRECTION and not a regression.
# When a line opens a span it does not close, per-line pairing pairs the WRONG backticks: it
# deletes the prose sitting between the real closing backtick and the next span's opener, and
# counts the code as prose. This fixture is the shape at AGENTS.md:190-191, one span crossing
# the line break plus two ordinary spans behind it. On AGENTS.md the old pairing deleted the
# three English function words `the`, `because` and `only`, and counted eight code tokens
# (git, rev, parse, short, head, code, reviewer, bash) that are in no list, so the visible
# delta is exactly +3 with no term of it in doubt.
#
# de=9 EXACTLY, and the attributing evidence is the PREDECESSOR SCRIPT rather than a one-line
# mutation: measured de=5 at 916b6c9, because per-line pairing deletes "und mit von" and "zu"
# as if they were code. A mutation that only reverts RS cannot attribute this case, because
# both lines here carry an odd number of backticks, so the odd-backtick guard suppresses the
# deletion and the case reads 9 for a different reason. Stated so nobody later "confirms" it
# with that mutation and records a pass that proves nothing.
k12e="$TMP/K12e.md"
{ printf 'Der Befehl (`git rev-parse --short\n'; printf 'HEAD`) steht und mit von `code-reviewer` zu `Bash`; und mit von zu\n'; } > "$k12e"
run "$DE" "$k12e"; o="$OUT"
assert_eq "K12e a span crossing the line break pairs correctly, so the prose behind it survives: de=9" "9" "$(field "$o" de)"
assert_eq "K12e and none of the three spans is counted: en=0" "0" "$(field "$o" en)"

# K13: a NON-LATIN body. The tokenizer keeps ASCII letters only, so a Hebrew document
# tokenizes to nothing and used to report `NO-PROSE counted=0 detected=none`, the identical
# line a document with a legitimately empty prose region reports (K1). A reader could not tell
# "nothing to check" from "I could not read this", and this is the one case where a clean line
# is not evidence of anything. Written with \x escapes so this test file stays ASCII; the
# bytes are the Hebrew letters alef to yod.
k13="$TMP/K13.md"
printf '\xd7\x90\xd7\x91\xd7\x92 \xd7\x93\xd7\x94\xd7\x95 \xd7\x96\xd7\x97\xd7\x98 \xd7\x99\xd7\x90\xd7\x91\n' > "$k13"
run "$DE" "$k13"; o="$OUT"
assert_eq   "K13 a non-Latin body is UNREADABLE, not NO-PROSE" "UNREADABLE" "$(status "$o")"
assert_eq   "K13 counted=0"     "0"    "$(field "$o" counted)"
assert_eq   "K13 detected=none" "none" "$(field "$o" detected)"
assert_exit "K13 exit 0" 0 "$RC"
# The contrast is what gives the status above its meaning: a region that really is empty
# still reports NO-PROSE. K1 covers the fence shape, this one is whitespace only.
k13b="$TMP/K13b.md"; printf '   \n\t\n' > "$k13b"
run "$DE" "$k13b"; o="$OUT"
assert_eq "K13b a whitespace-only region stays NO-PROSE" "NO-PROSE" "$(status "$o")"

echo ""
if [ "$fail" -eq 0 ]; then echo "prose-language-check: all assertions passed."; else echo "prose-language-check: FAILURES above."; fi
exit "$fail"
