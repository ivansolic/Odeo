#!/usr/bin/env bash
# Tests for scripts/install-git-guards.sh: the installed pre-push hook, PUSH CONTRACT A.
set -uo pipefail
INSTALLER="$(cd "$(dirname "$0")/.." && pwd)/scripts/install-git-guards.sh"
fail=0
assert_exit() { if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi; }
assert_contains() { case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac; }

# Throwaway git identity so fixture commits succeed with no global identity present.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
repo="$TMP/repo"; bare="$TMP/bare.git"
mkdir -p "$repo"
git init -q "$repo"
git init -q --bare "$bare"

# Fixture denylist used by the hook's defense-in-depth guard.
deny="$TMP/deny.txt"; printf 'docs/plans/\ndocs/evals/\n' > "$deny"
export CLAUDE_INTERNAL_PATHS="$deny"

# This repo PUBLISHES through a snapshot (it carries docs/internal-paths.txt), so contract A
# applies to it; a plain project without that file is covered at the end.
mkdir -p "$repo/docs"; cp "$deny" "$repo/docs/internal-paths.txt"

# The hook finds the guard next to the installer it was written by (ODEO_BIN_AT_INSTALL).

# Install the hooks into the repo under test.
( cd "$repo" && bash "$INSTALLER" ) >/dev/null 2>&1
# The INSTALLER marks this publishing repo, before any hook has run (a hook that sees the
# list marks it too, which once hid an installer that did not).
[ "$(git -C "$repo" config --bool --get odeo.publishesSnapshot)" = "true" ] \
  && echo "ok: the installer marks a publishing repo" || { echo "FAIL: the installer did not mark the publishing repo"; fail=1; }

# (a) pre-push installed and executable
[ -x "$repo/.git/hooks/pre-push" ] && { echo "ok: pre-push installed +x"; } || { echo "FAIL: pre-push not installed +x"; fail=1; }
# (b) the main/master refusal is preserved
assert_contains "main/master refusal preserved" "refs/heads/main" "$(cat "$repo/.git/hooks/pre-push")"

# Build a clean commit and a dirty (internal-path) commit.
( cd "$repo" && echo x > README.md && git add README.md && git commit -q -m c1 )
clean_sha="$(cd "$repo" && git rev-parse HEAD)"
( cd "$repo" && mkdir -p docs/plans && echo x > docs/plans/x.md && git add docs/plans/x.md && git commit -q -m c2 )
dirty_sha="$(cd "$repo" && git rev-parse HEAD)"
zero=0000000000000000000000000000000000000000

# helper: run the installed hook. $1=remote_name $2=marker("" or 1). stdin = ref lines.
hook() {
  local rn="$1" marker="$2"; shift 2
  ( cd "$repo" && env CLAUDE_INTERNAL_PATHS="$deny" ${marker:+CLAUDE_PUBLISH_SNAPSHOT=$marker} \
      .git/hooks/pre-push "$rn" "file://$bare" )
}

# (c) push a feature branch to public origin WITHOUT the marker -> REFUSED
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook origin "" 2>&1)"; rc=$?
assert_exit "public push, no marker -> refused" 1 "$rc"
assert_contains "explains publish-snapshot path" "publish-snapshot" "$out"

# (d) same WITH marker + clean tree -> allowed
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook origin 1 2>&1)"; rc=$?
assert_exit "public push, marker + clean tree -> allowed" 0 "$rc"

# (e) WITH marker but an internal path in the pushed tree -> REFUSED (defense-in-depth)
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$dirty_sha" "$zero" | hook origin 1 2>&1)"; rc=$?
assert_exit "public push, marker + internal path -> refused" 1 "$rc"

# (f) contract A covers every ref-shape: force-push (same ref line) and a tag, no marker -> both REFUSED
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$clean_sha" | hook origin "" 2>&1)"; rc=$?
assert_exit "force-push to public, no marker -> refused" 1 "$rc"
out="$(printf 'refs/tags/v1 %s refs/tags/v1 %s\n' "$clean_sha" "$zero" | hook origin "" 2>&1)"; rc=$?
assert_exit "tag push to public, no marker -> refused" 1 "$rc"

# (g) push to a NON-public remote is not subject to the public refusal -> allowed
out="$(printf 'refs/heads/feature/x %s refs/heads/feature/x %s\n' "$clean_sha" "$zero" | hook backup "" 2>&1)"; rc=$?
assert_exit "push to non-public remote -> allowed" 0 "$rc"

# preserved (1): a direct push to an EXISTING main is still refused (on any remote)
old_sha=1111111111111111111111111111111111111111
out="$(printf 'refs/heads/main %s refs/heads/main %s\n' "$clean_sha" "$old_sha" | hook backup "" 2>&1)"; rc=$?
assert_exit "direct push to main -> refused" 1 "$rc"
assert_contains "main refusal message" "direct push to main" "$out"
out="$(printf 'refs/heads/master %s refs/heads/master %s\n' "$clean_sha" "$old_sha" | hook backup "" 2>&1)"; rc=$?
assert_exit "direct push to an existing master -> refused" 1 "$rc"
# Observed failing (2026-09-28), each mutant checked to differ and parse: seeding allowed
# whatever the remote sha -> 3 FAIL (existing main/master pushes pass); deleting treated as
# seeding -> 1 FAIL (the delete case).
# (1b) the ONE exception: the push that CREATES main on a remote that has none (the remote
#      sha is all zeros), so a new project can seed its empty GitHub repo. Every later push
#      to main is still refused above.
out="$(printf 'refs/heads/main %s refs/heads/main %s\n' "$clean_sha" "$zero" | hook backup "" 2>&1)"; rc=$?
assert_exit "the push that creates main on an empty remote -> allowed" 0 "$rc"
# ... but deleting main is not creating it
out="$(printf '(delete) %s refs/heads/main %s\n' "$zero" "$old_sha" | hook backup "" 2>&1)"; rc=$?
assert_exit "deleting main on the remote -> refused" 1 "$rc"
# ... and contract A still applies: seeding the PUBLIC remote without the marker is refused
out="$(printf 'refs/heads/main %s refs/heads/main %s\n' "$clean_sha" "$zero" | hook origin "" 2>&1)"; rc=$?
assert_exit "creating main on the public remote without the marker -> refused" 1 "$rc"

echo
# Observed failing (2026-09-28): the hook not reading odeo.publishesSnapshot -> the three (y)
# cases; the installer not setting it -> the install-time mark check (the (y) cases stay green
# then, because the hook marks the repo itself). Each mutant checked to differ.
# (y) contract A belongs to the REPOSITORY, not to the working tree: a project marked as
#     publishing at install time stays guarded however its checkout looks at push time
#     (security review of the working-tree check: sparse checkouts, a deleted file, --git-dir
#     from outside, an old commit without the file all turned it off)
feat_line="$(printf 'refs/heads/feature/q %s refs/heads/feature/q %s\n' "$clean_sha" "$zero")"
mv "$repo/docs/internal-paths.txt" "$TMP/ip.bak"
out="$(printf '%s\n' "$feat_line" | hook origin "" 2>&1)"; rc=$?
assert_exit "publishing repo, internal-paths.txt missing from the checkout -> still refused" 1 "$rc"
mv "$TMP/ip.bak" "$repo/docs/internal-paths.txt"
mkdir -p "$TMP/emptywt"
rc="$(cd "$TMP" && printf '%s\n' "$feat_line" | env CLAUDE_INTERNAL_PATHS="$deny" GIT_DIR="$repo/.git" GIT_WORK_TREE="$TMP/emptywt" "$repo/.git/hooks/pre-push" origin "file://$bare" >/dev/null 2>&1; echo $?)"
assert_exit "publishing repo pushed via GIT_DIR from outside -> still refused" 1 "$rc"
rc="$(cd "$TMP" && printf '%s\n' "$feat_line" | env CLAUDE_INTERNAL_PATHS="$deny" GIT_DIR="$repo/.git" "$repo/.git/hooks/pre-push" origin "file://$bare" >/dev/null 2>&1; echo $?)"
assert_exit "publishing repo, hook run where rev-parse has no work tree -> still refused" 1 "$rc"

# Observed failing (2026-09-28), each mutant checked to differ and parse: contract A
# everywhere again -> 2 FAIL (the plain-project pushes, the original bug); internal-paths
# ignored -> 7 FAIL (every publishing-project contract A case); an explicit public remote
# ignored -> 1 FAIL. The last case makes its own commit: chained on the one before, it went
# red under that mutant only because nothing was left to push.
# (z) contract A belongs to projects that publish through a snapshot. A PLAIN project (no
#     docs/internal-paths.txt, the shape init-project.sh scaffolds) pushes to its own origin
#     normally; before this, every Odeo project refused every push to origin.
plain="$TMP/plain"; plainbare="$TMP/plain.git"; git init -q "$plain"; git init -q --bare "$plainbare"
( cd "$plain" && bash "$INSTALLER" ) >/dev/null 2>&1
( cd "$plain" && echo x > f && git add f && git commit -q -m init && git remote add origin "$plainbare" )
( cd "$plain" && git switch -q -c feature/y && git push -q origin feature/y ) >/dev/null 2>&1; rc=$?
assert_exit "plain project: a feature branch reaches its own origin" 0 "$rc"
( cd "$plain" && git switch -q main 2>/dev/null || git switch -q master; git push -q origin HEAD:refs/heads/main ) >/dev/null 2>&1; rc=$?
assert_exit "plain project: the first push of main seeds the empty origin" 0 "$rc"
( cd "$plain" && echo y >> f && git commit -qam more && git push -q origin HEAD:refs/heads/main ) >/dev/null 2>&1; rc=$?
assert_exit "plain project: a later push to main is still refused" 1 "$rc"
( cd "$plain" && git switch -q feature/y && echo z >> f && git commit -qam z && CLAUDE_PUBLIC_REMOTE=origin git push -q origin feature/y ) >/dev/null 2>&1; rc=$?
assert_exit "plain project that names a public remote explicitly: contract A applies" 1 "$rc"
# its own new commit, so it never depends on whether the case above pushed feature/y
( cd "$plain" && mkdir -p docs && printf 'docs/plans/\n' > docs/internal-paths.txt && echo w >> f && git commit -qam w && git push -q origin feature/y ) >/dev/null 2>&1; rc=$?
assert_exit "adding docs/internal-paths.txt switches contract A on, no reinstall" 1 "$rc"

# Observed failing (2026-09-28): the hook not writing the mark -> both (x) cases.
# (x) the mark is STICKY: a repo that gains docs/internal-paths.txt after the hooks were
#     installed is marked by the hook itself on the next push, and stays guarded when the
#     file later leaves the checkout (an old commit, an orphan branch)
late="$TMP/late"; latebare="$TMP/late.git"; git init -q "$late"; git init -q --bare "$latebare"
( cd "$late" && bash "$INSTALLER" ) >/dev/null 2>&1
( cd "$late" && echo x > f && git add f && git commit -q -m init && git remote add origin "$latebare" && git switch -q -c feature/l ) >/dev/null 2>&1
( cd "$late" && mkdir -p docs && printf 'docs/plans/\n' > docs/internal-paths.txt && git add -A && git commit -qm list && git push -q origin feature/l ) >/dev/null 2>&1
assert_exit "the hook marks a repo that gained the list" "true" "$(git -C "$late" config --get odeo.publishesSnapshot)"
( cd "$late" && git switch -q --orphan bare-branch ) >/dev/null 2>&1   # empties index and tree
[ ! -e "$late/docs/internal-paths.txt" ] && ok_orphan=1 || ok_orphan=0
assert_exit "the orphan checkout really lacks the list (instrument)" 1 "$ok_orphan"
( cd "$late" && echo o > o && git add o && git commit -qm orphan && git push -q origin bare-branch ) >/dev/null 2>&1; rc=$?
assert_exit "a marked repo pushing an orphan branch without the list -> refused" 1 "$rc"
# (w) deleting a main the remote does not have reaches the hook as zero/zero: refused, not
#     mistaken for the seed
out="$(printf '(delete) %s refs/heads/main %s\n' "$zero" "$zero" | hook backup "" 2>&1)"; rc=$?
assert_exit "deleting a non-existent main (zero/zero) -> refused" 1 "$rc"

# Observed failing (2026-09-28, round 3): the pushed tree not read -> the (v) case; the mark
# read as a literal string -> the (u) case; the latch line removed -> the mark check after
# (v); only git's own `true` counting -> the invalid-value case (the bare key without '='
# reads as true to git, so it is covered by git's parser, not by our spelling list). Each mutant checked to
# differ and parse.
# (v) the PUSHED commit carries the list, but the checkout never did while pushing: an
#     unmarked repo gains the list in a commit, checks out an older commit, pushes the branch
#     that has the list. The hook reads the pushed tree, so contract A applies.
v="$TMP/v"; vbare="$TMP/v.git"; git init -q "$v"; git init -q --bare "$vbare"
( cd "$v" && bash "$INSTALLER" ) >/dev/null 2>&1
( cd "$v" && echo x > f && git add f && git commit -q -m init && git remote add origin "$vbare" \
  && git switch -q -c feat && mkdir -p docs && printf 'docs/plans/\n' > docs/internal-paths.txt \
  && mkdir -p docs/plans && echo p > docs/plans/p.md && git add -A && git commit -q -m list \
  && git checkout -q HEAD~1 ) >/dev/null 2>&1
[ ! -e "$v/docs/internal-paths.txt" ] && vi=1 || vi=0
assert_exit "the old checkout really lacks the list (instrument)" 1 "$vi"
( cd "$v" && git push -q origin feat ) >/dev/null 2>&1; rc=$?
assert_exit "a pushed branch that carries the list is guarded whatever is checked out" 1 "$rc"
# only the pushed-tree path could have marked it here: the checkout never had the list
assert_exit "the pushed-tree path marks the repo" "true" "$(git -C "$v" config --bool --get odeo.publishesSnapshot)"
# (u) a mark written as another git boolean (yes, 1) still counts
u="$TMP/u"; git init -q "$u"; ( cd "$u" && bash "$INSTALLER" ) >/dev/null 2>&1; git -C "$u" config odeo.publishesSnapshot yes
out="$(cd "$u" && printf 'refs/heads/feature/q %s refs/heads/feature/q %s\n' "$clean_sha" "$zero" | env CLAUDE_INTERNAL_PATHS="$deny" .git/hooks/pre-push origin "file://$bare" 2>&1)"; rc=$?
assert_exit "mark 'yes' counts as true" 1 "$rc"
# a value that is no git boolean (a hand-edited typo) fails CLOSED; only an explicit false is off
git -C "$u" config odeo.publishesSnapshot maybe
out="$(cd "$u" && printf 'refs/heads/feature/q %s refs/heads/feature/q %s\n' "$clean_sha" "$zero" | env CLAUDE_INTERNAL_PATHS="$deny" .git/hooks/pre-push origin "file://$bare" 2>&1)"; rc=$?
assert_exit "an invalid mark value keeps contract A on" 1 "$rc"
# a bare key with no '=' means true to git; `git config --get` prints nothing for it
git -C "$u" config --unset odeo.publishesSnapshot; printf '[odeo]\n\tpublishesSnapshot\n' >> "$u/.git/config"
out="$(cd "$u" && printf 'refs/heads/feature/q %s refs/heads/feature/q %s\n' "$clean_sha" "$zero" | env CLAUDE_INTERNAL_PATHS="$deny" .git/hooks/pre-push origin "file://$bare" 2>&1)"; rc=$?
assert_exit "a bare key without '=' counts as on" 1 "$rc"
git -C "$u" config --unset-all odeo.publishesSnapshot 2>/dev/null
git -C "$u" config odeo.publishesSnapshot false
out="$(cd "$u" && printf 'refs/heads/feature/q %s refs/heads/feature/q %s\n' "$clean_sha" "$zero" | env CLAUDE_INTERNAL_PATHS="$deny" .git/hooks/pre-push origin "file://$bare" 2>&1)"; rc=$?
assert_exit "an explicit false turns it off" 0 "$rc"

if [ "$fail" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$fail"
