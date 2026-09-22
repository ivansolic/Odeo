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
for probe in probe.sh probe.py probe.ps1 probe.md probe.txt probe.json probe.yml probe.yaml LICENSE; do
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
# ONE detector, called by check 2 and by the canary below. The canary previously
# re-implemented detection inline, so replacing THIS awk with `{ }` still printed
# "detector fires" and ALL PASS with a CRLF file present: the canary did not guard the
# check it exists to guard.
#
# Two things it must catch:
#   w/crlf, w/mixed  -> the core.autocrlf case;
#   w/-text with attr/text -> a file git calls BINARY because it holds lone CRs. A CR-only
#     script does not run either, and `git ls-files --eol` alone would miss it, which made
#     the git-based detector NARROWER than the `grep -U` it replaced. attr/text (not
#     text=auto) keeps a real binary, which resolves attr/text=auto, from false-positiving.
#
# Split on TAB, because `--eol` separates the attribute column from the path with one, and
# `$NF` on whitespace truncated any path containing a space ("my script.sh" -> "script.sh").
crlf_offenders() { # crlf_offenders [repo-dir]
  git -C "${1:-.}" ls-files --eol 2>/dev/null | awk -F'\t' '
    { split($1, c, /[[:space:]]+/)
      if (c[2] == "w/crlf" || c[2] == "w/mixed") { print $NF; next }
      if (c[2] == "w/-text" && c[3] == "attr/text") { print $NF } }'
}
offenders="$(crlf_offenders)"
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
# Built in a THROWAWAY repo, never in this one. The earlier version added an
# intent-to-add entry here, so an interrupted run left the tree dirty (which then makes
# merge-gate refuse and the next run blame the canary), a read-only worktree or a stale
# index.lock produced a spurious RED, and a tracked canary path would have been deleted.
# A FAILED mktemp must refuse, never fall through. `git -C ""` is a documented no-op, so
# an empty $scratch does not disable the canary, it AIMS IT AT THIS REPOSITORY: `add -A`
# staged the real tree, the detector then found the file it had just staged, and called
# that proof. ALL PASS with a CRLF file present. The trap is armed only inside the else,
# so an empty path can never reach `rm -rf`.
scratch="$(mktemp -d 2>/dev/null)" || scratch=""
if [ -z "$scratch" ] || [ ! -d "$scratch" ]; then
  bad "could not create a scratch dir, so the detector could not be proven"
else
  trap 'rm -rf "$scratch"' EXIT
  git -C "$scratch" init -q . >/dev/null 2>&1
  # The pin is WRITTEN, not copied: the lone-CR arm needs `attr/text` to resolve inside the
  # scratch repo, so a silently failing `cp` would turn into a spurious RED.
  printf '*.sh text eol=lf\n' > "$scratch/.gitattributes"
  # One file per DETECTOR ARM, because the canary previously proved only the w/crlf arm:
  # deleting the lone-CR arm left the run green, the same shape as the defect this canary
  # exists to catch, one level down.
  printf 'x\r\ny\r\n' > "$scratch/canary-crlf.sh"   # w/crlf
  printf 'a\rb\rc\n'  > "$scratch/canary-cr.sh"     # w/-text + attr/text (lone CR)
  git -C "$scratch" add -A >/dev/null 2>&1
  n_fired="$(crlf_offenders "$scratch" | wc -l | tr -d ' ')"
  if [ "${n_fired:-0}" -eq 2 ]; then
    ok "both detector arms fire on planted files (same code path as check 2)"
  else
    bad "detector fired on ${n_fired:-0} of 2 planted files, so check 2 proves less than it claims"
  fi
fi

echo
if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
