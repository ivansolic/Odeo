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
body_nonascii="$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$PRD" | LC_ALL=C grep -c '[^ -~]')"
fm_nonascii="$(awk '/^---$/{n++; next} n==1{print}' "$PRD" | LC_ALL=C grep -c '[^ -~]')"
if [ "$body_nonascii" -gt 0 ]; then echo "ok: the fixture body carries non-ASCII letters ($body_nonascii lines)"
else echo "FAIL: the fixture body is all ASCII, so the guard case above proves nothing"; fail=1; fi
assert_eq "and the fixture frontmatter carries none" "0" "$fm_nonascii"

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
