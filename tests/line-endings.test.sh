#!/usr/bin/env bash
# Guards .gitattributes: no tracked script or parsed file may carry CRLF line endings.
#
# The failure this prevents is total, not cosmetic. Git on Windows defaults to
# core.autocrlf=true and rewrites LF to CRLF on CHECKOUT; a CRLF bash script does not
# execute ("set: pipefail: invalid option name", "syntax error near unexpected token `in'").
# .gitattributes alone is a rule with no mechanism, so this test is the mechanism.
#
# Run: bash tests/line-endings.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# 1) .gitattributes exists and pins the executable/parsed types to LF.
if [ -f .gitattributes ]; then ok ".gitattributes present"; else bad ".gitattributes missing (a Windows checkout would CRLF everything)"; fi
for pat in '\*\.sh' '\*\.md' '\*\.txt' '\*\.py'; do
  if grep -qE "^${pat}[[:space:]]+text[[:space:]]+eol=lf" .gitattributes 2>/dev/null; then
    ok "$(printf '%s' "$pat" | tr -d '\\') pinned to eol=lf"
  else
    bad "$(printf '%s' "$pat" | tr -d '\\') not pinned to eol=lf"
  fi
done

# 2) No tracked file of an executed or parsed type currently contains a CR.
#    Checked against the WORKING TREE, which is what actually runs.
crlf=""
while IFS= read -r -d '' f; do
  [ -f "$f" ] || continue
  case "$f" in *.sh|*.py|*.md|*.txt|*.json|*.yml|LICENSE) ;; *) continue ;; esac
  # LC_ALL=C so the byte test is not locale-dependent.
  if LC_ALL=C grep -qU $'\r' "$f" 2>/dev/null; then crlf="${crlf}${f} "; fi
done < <(git ls-files -z)
if [ -z "$crlf" ]; then
  ok "no tracked script or parsed file contains CR"
else
  bad "CRLF found in: $crlf"
  echo "  Fix: git add --renormalize . && git commit  (and check your core.autocrlf)" >&2
fi

# 3) The shebang line of every tracked script is clean, since that is what breaks first.
shebang_bad=""
while IFS= read -r -d '' f; do
  case "$f" in *.sh) ;; *) continue ;; esac
  [ -f "$f" ] || continue
  if LC_ALL=C head -1 "$f" | grep -qU $'\r'; then shebang_bad="${shebang_bad}${f} "; fi
done < <(git ls-files -z)
if [ -z "$shebang_bad" ]; then ok "every script shebang is CR-free"; else bad "CR in shebang of: $shebang_bad"; fi

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
