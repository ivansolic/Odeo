#!/usr/bin/env bash
# Guards .gitattributes: no tracked file that is executed or parsed may carry CRLF.
#
# The failure this prevents is total, not cosmetic. Git on Windows defaults to
# core.autocrlf=true and rewrites LF to CRLF on CHECKOUT; a CRLF bash script does not
# execute ("set: pipefail: invalid option name", "syntax error near unexpected token `in'").
# .gitattributes alone is a rule with no mechanism, so this test is the mechanism.
#
# It asks GIT, not grep. `git ls-files --eol` reports the worktree state per file and
# `git check-attr eol` resolves the effective attribute, so there is no `grep -U`
# portability question and no way for a missing flag to make the check pass silently.
# Both are behavioural: they survive reformatting of .gitattributes and catch a nested one.
#
# Run: bash tests/line-endings.test.sh
set -uo pipefail
LC_ALL=C
export LC_ALL
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# 0) The test must be running somewhere it can actually see files. Without this, an empty
#    or non-git tree reported ALL PASS with a CRLF script sitting right there, and INSTALL
#    points users at this test as their diagnostic.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  bad "not inside a git work tree, so nothing could be checked"
  echo; echo "SOME FAILED"; exit 1
fi
n_tracked="$(git ls-files | wc -l | tr -d ' ')"
if [ "${n_tracked:-0}" -ge 50 ]; then
  ok "scanning $n_tracked tracked files"
else
  bad "only ${n_tracked:-0} tracked files visible; this repo has hundreds, so the scan is not seeing the tree"
fi

# 1) The pins resolve by BEHAVIOUR, for every type the toolchain executes or parses.
#    Asserting the attribute rather than the text of .gitattributes means a reformat,
#    a reordering, or a nested .gitattributes cannot make this pass vacuously.
missing=""
for probe in probe.sh probe.py probe.md probe.txt probe.json probe.yml probe.yaml LICENSE; do
  eol="$(git check-attr eol -- "$probe" 2>/dev/null | sed 's/.*: eol: //')"
  [ "$eol" = "lf" ] || missing="${missing}${probe}(${eol:-unset}) "
done
if [ -z "$missing" ]; then
  ok "eol=lf resolves for every executed/parsed type"
else
  bad "eol=lf does NOT resolve for: $missing"
  echo "  Add the pattern to .gitattributes; a type left unpinned gets CRLF on a Windows checkout." >&2
fi

# 1b) `* text=auto` must still cover types NOT explicitly pinned, so a file type added
#     later (a Makefile, a .rb, a .toml) is normalized instead of silently inheriting the
#     platform default. The explicit pins resolve without it, so nothing else notices it
#     is gone.
unpinned="$(git check-attr text -- probe-unpinned.rb 2>/dev/null | sed 's/.*: text: //')"
if [ "$unpinned" = "auto" ]; then
  ok "unpinned types still inherit text=auto"
else
  bad "an unpinned type resolves text=${unpinned:-unset}; '* text=auto' is missing"
  echo "  Without it, a newly added file type gets no normalization at all." >&2
fi

# 2) No tracked file currently has CRLF (or mixed) endings in the WORKTREE, which is what
#    actually runs. `w/` is the worktree column; `i/` is the index.
offenders="$(git ls-files --eol 2>/dev/null | awk '$2 ~ /^w\/(crlf|mixed)$/ { print $NF }')"
if [ -z "$offenders" ]; then
  ok "no tracked file has CRLF or mixed endings in the worktree"
else
  bad "CRLF/mixed endings in: $(printf '%s' "$offenders" | tr '\n' ' ')"
  echo "  Recover with: commit or stash first, then" >&2
  echo "    git rm --cached -r . && git reset --hard      # discards uncommitted changes" >&2
  echo "  or clone again. NOTE: 'git add --renormalize' does NOT help here, because the" >&2
  echo "  committed blobs are already LF; only the checkout is CRLF." >&2
fi

# 3) The canary: prove the detector can FIRE. A guard never observed failing is worth
#    nothing, and check 2 would otherwise pass silently if the reporting ever changed.
canary=".line-endings-canary.tmp"
printf 'x\r\n' > "$canary"
git add --intent-to-add "$canary" >/dev/null 2>&1
if git ls-files --eol "$canary" 2>/dev/null | awk '$2 ~ /^w\/(crlf|mixed)$/ { found=1 } END { exit !found }'; then
  ok "detector fires on a planted CRLF file"
else
  bad "detector did NOT fire on a planted CRLF file, so check 2 proves nothing"
fi
git rm -q --cached "$canary" >/dev/null 2>&1
rm -f "$canary"

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
