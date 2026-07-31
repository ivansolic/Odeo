#!/usr/bin/env bash
# Invariant: every copy of the output-language allowlist agrees.
#
# The code set `en de hr fr` is a literal in bin/{resolve-language,set-global-language,
# set-project-language,language-status}.sh and a `case` arm in bin/init-project.sh. This
# test is the ONLY mechanical defense against those five copies drifting. The failure it
# prevents is quiet, not loud: a writer that accepts a code the resolver then degrades away
# tells the user "set to es" and keeps producing English documents.
#
# The four scripts are driven behaviorally; init-project.sh (do-not-touch here) is checked
# textually, because invoking the scaffolder would create a whole project tree.
#
# This guard has been OBSERVED FAILING (mutation RED, recorded in the commit body): adding
# `es` to VALID in set-project-language.sh alone fails cases 2 and 3, and adding it to
# language-status.sh alone fails case 2's SCOPE assertion. A guard never seen failing is
# false confidence.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/bin"
fail=0
assert_eq() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected '$2', got '$3')"; fail=1; fi; }
assert_true() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

EXPECTED="en de hr fr"          # the one intended set; update HERE and in all five files together
CANDIDATES="en de hr fr es it klingon EN"

fresh_proj() { # fresh_proj <name> -> echoes a project dir with an anchor, no language line
  local d="$TMP/$1"; mkdir -p "$d"; printf '# P\n## Conventions\n' > "$d/CLAUDE.md"; printf '%s' "$d"
}
fresh_cfg() { local f="$TMP/$1.md"; printf '# G\n' > "$f"; printf '%s' "$f"; }

# 1) Every EXPECTED code is accepted by BOTH writers and read back identically by the
#    resolver and the scope reporter.
for code in $EXPECTED; do
  p="$(fresh_proj "p-$code")"; g="$(fresh_cfg "g-$code")"
  "$BIN/set-project-language.sh" "$p" "$code" >/dev/null 2>&1
  pr=$?
  CLAUDE_GLOBAL_CONFIG="$g" "$BIN/set-global-language.sh" "$code" --overwrite >/dev/null 2>&1
  gr=$?
  assert_eq "project writer accepts $code" 0 "$pr"
  assert_eq "global writer accepts $code" 0 "$gr"
  assert_eq "resolver returns $code" "$code" "$(CLAUDE_GLOBAL_CONFIG="$g" bash "$BIN/resolve-language.sh" "$p")"
  assert_eq "status first field is $code" "$code" "$(CLAUDE_GLOBAL_CONFIG="$g" bash "$BIN/language-status.sh" "$p" | awk '{print $1}')"
done

# 2) Every INVALID code is refused by BOTH writers, and when planted BY HAND as a project
#    line (with a VALID global line present) the resolver degrades past it AND the scope
#    reporter says `global`, never `project`. That scope assertion is what covers
#    language-status.sh's own copy of the list: a code accepted only there would report the
#    wrong LEVEL while the code still looked right.
for code in es it klingon; do
  p="$(fresh_proj "bad-$code")"; g="$(fresh_cfg "badg-$code")"
  printf 'output_language: fr\n' >> "$g"

  out="$("$BIN/set-project-language.sh" "$p" "$code" 2>&1)"; pr=$?
  assert_eq "project writer refuses $code" 1 "$pr"
  assert_true "project refusal lists the set ($code)" "case \"\$(printf '%s' \"$out\")\" in *'$EXPECTED'*) true;; *) false;; esac"

  out="$(CLAUDE_GLOBAL_CONFIG="$g" "$BIN/set-global-language.sh" "$code" --overwrite 2>&1)"; gr=$?
  assert_eq "global writer refuses $code" 1 "$gr"
  assert_true "global refusal lists the set ($code)" "case \"\$(printf '%s' \"$out\")\" in *'$EXPECTED'*) true;; *) false;; esac"

  printf 'output_language: %s\n' "$code" >> "$p/CLAUDE.md"
  assert_eq "resolver degrades past planted $code" "fr" "$(CLAUDE_GLOBAL_CONFIG="$g" bash "$BIN/resolve-language.sh" "$p")"
  assert_eq "scope is global, not project, for planted $code" "fr global" "$(CLAUDE_GLOBAL_CONFIG="$g" bash "$BIN/language-status.sh" "$p")"
done

# 3) The accepted set is EXACTLY the expected four, and both writers accept the SAME subset.
#    `EN` is rejected by both writers (they are case-sensitive because they produce the
#    canonical form) while resolve-language.sh normalizes case when READING, so this
#    asserts writer-vs-writer agreement only, never writer-vs-reader.
p_accept=""; g_accept=""
for code in $CANDIDATES; do
  p="$(fresh_proj "m-p-$code")"; g="$(fresh_cfg "m-g-$code")"
  "$BIN/set-project-language.sh" "$p" "$code" >/dev/null 2>&1 && p_accept="$p_accept $code"
  CLAUDE_GLOBAL_CONFIG="$g" "$BIN/set-global-language.sh" "$code" --overwrite >/dev/null 2>&1 && g_accept="$g_accept $code"
done
p_accept="${p_accept# }"; g_accept="${g_accept# }"
assert_eq "project writer accepts exactly the expected set" "$EXPECTED" "$p_accept"
assert_eq "global writer accepts exactly the expected set" "$EXPECTED" "$g_accept"
assert_eq "both writers accept the SAME subset" "$p_accept" "$g_accept"

# 4) THE FIFTH COPY: bin/init-project.sh is do-not-touch here, so it is checked textually
#    rather than by invoking the scaffolder (which would create a whole project tree).
assert_true "init-project.sh case arm still en|de|hr|fr" "grep -qE '^[[:space:]]*en\|de\|hr\|fr\)' \"$BIN/init-project.sh\""
assert_true "init-project.sh message still lists the set" "grep -q '(allowed: $EXPECTED)' \"$BIN/init-project.sh\""

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
