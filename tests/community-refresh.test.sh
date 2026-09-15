#!/usr/bin/env bash
# Tests for install.sh's community-knowledge refresh.
#
# WHY THIS EXISTS. This block was wrong in three states across two commits, each time as
# the same shape: a diagnosis that can be wrong, paired with a remedy that destroys data.
# Nothing pinned it, so each fix was verified by hand and the next state was found by a
# reviewer rather than by the suite.
#
# The contract has two halves, and the SECOND is the one that matters:
#   1. each state is classified correctly (offline, no-upstream, diverged, local edits)
#   2. NO state destroys the user's copy. A wrong classification must cost a rename the
#      user can undo, never their work. That is what makes a missed state survivable, and
#      it is asserted separately from the classification so it holds even if 1 regresses.
#
# Run: bash tests/community-refresh.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export GIT_TERMINAL_PROMPT=0

# The classifier under test, extracted from install.sh so this runs the REAL logic. The
# markers are named; a drift must fail loud rather than silently verify a paraphrase.
block="$(awk '/^# BEGIN community-refresh/,/^# END community-refresh$/' "$ROOT/install.sh")"
lines=$(printf '%s\n' "$block" | wc -l | tr -d ' ')
if [[ -z "$block" || "$lines" -gt 70 ]] || ! printf '%s' "$block" | grep -q 'stale-'; then
  echo "FAIL - instrument broken: extracted $lines lines; the markers in install.sh moved."
  exit 1
fi
ok "instrument: extracted the refresh block ($lines lines)"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
UP="$TMP/up"
mkdir -p "$UP" && ( cd "$UP" && git init -qb main && echo v1 > f.md && git add -A && git commit -qm v1 ) >/dev/null 2>&1

# mkmirror <name> -> a clone that is exactly ONE commit BEHIND upstream.
# The "behind" part is the point and was wrong in the first draft of this file: a mirror
# cloned from an already-advanced upstream is up to date, so `merge --ff-only` is a no-op
# that SUCCEEDS, and every case below silently tested the refresh path instead of the one
# it named. Advancing upstream after each clone is what makes the fixtures exercise the
# states they claim to.
mkmirror() {
  local d="$TMP/$1"
  git clone -q "$UP" "$d" >/dev/null 2>&1
  ( cd "$UP" && echo "v-$1" > f.md && git commit -qam "advance for $1" ) >/dev/null 2>&1
  echo "$d"
}

# run <mirror> -> runs the REAL block with HOME pointed at a fake home containing it
run() {
  local mirror="$1" home="$TMP/home-$RANDOM"
  mkdir -p "$home/.claude"
  mv "$mirror" "$home/.claude/community-knowledge"
  ( set +e
    HOME="$home"
    COMMUNITY_KNOWLEDGE_REPO="$UP"
    COMMUNITY_DIR="$home/.claude/community-knowledge"
    eval "$block"
  ) >"$TMP/out" 2>&1
  echo "$home"
}


# 1. Normal mirror refreshes, and HEAD actually moves. Asserting the MESSAGE alone would
#    have passed on the detached-HEAD bug, where git reported success without moving HEAD.
h=$(run "$(mkmirror m1)")
grep -q 'refreshed' "$TMP/out" && ok "a normal mirror reports refreshed" || bad "normal mirror: $(cat "$TMP/out")"
mirror_head="$(git -C "$h/.claude/community-knowledge" rev-parse HEAD)"
upstream_at_run="$(git -C "$h/.claude/community-knowledge" rev-parse '@{u}')"
[[ "$mirror_head" == "$upstream_at_run" ]] \
  && ok "and HEAD really advanced to the upstream tip" || bad "HEAD did not move despite the message"

# 2. DETACHED HEAD: the state that silently reported "refreshed" forever while never
#    updating. It must be recognized, not celebrated.
m=$(mkmirror m2); git -C "$m" checkout -q --detach HEAD
h=$(run "$m")
grep -q 'not on a branch that tracks' "$TMP/out" && ok "a detached HEAD is named, not reported as refreshed" \
  || bad "detached HEAD misreported: $(cat "$TMP/out")"

# 3. LOCAL EDITS are preserved, not discarded, and the old copy is kept by name.
m=$(mkmirror m3); echo "my edit" >> "$m/f.md"
h=$(run "$m")
stale=$(ls -d "$h/.claude"/community-knowledge.stale-* 2>/dev/null | head -1)
[[ -n "$stale" && -f "$stale/f.md" ]] && grep -q 'my edit' "$stale/f.md" \
  && ok "local edits survive: the old copy is moved aside, not deleted" \
  || bad "the user's edit was lost (no stale copy holding it)"
[[ -d "$h/.claude/community-knowledge/.git" ]] && ok "and a fresh mirror is in place" || bad "no fresh mirror after move-aside"

# 4. DIVERGED history: committed work must survive too. This is the case whose remedy used
#    to be `rm -rf` with no save path at all.
m=$(mkmirror m4); ( cd "$m" && echo mine > f.md && git commit -qam "my commit" ) >/dev/null 2>&1
h=$(run "$m")
stale=$(ls -d "$h/.claude"/community-knowledge.stale-* 2>/dev/null | head -1)
# Capture the log BEFORE testing it: `git log ... | grep -q` exits on first match, which
# SIGPIPEs git, and under `set -o pipefail` that makes the pipeline fail even though the
# commit is there. The first draft of this case failed for exactly that reason while the
# code under test was correct, which is the "instrument, not the finding" trap.
stale_log="$(git -C "$stale" log --oneline 2>/dev/null || true)"
[[ -n "$stale" && "$stale_log" == *"my commit"* ]] \
  && ok "a diverged mirror's commit survives in the moved-aside copy" \
  || bad "committed work was destroyed by the diverged path"

# 5. OFFLINE keeps the copy untouched: no move, no re-clone, nothing lost.
m=$(mkmirror m5); echo "edit" >> "$m/f.md"; git -C "$m" remote set-url origin /nonexistent-remote
h=$(run "$m")
[[ -z "$(ls -d "$h/.claude"/community-knowledge.stale-* 2>/dev/null)" ]] \
  && grep -q 'offline' "$TMP/out" \
  && ok "offline keeps the existing copy in place and says so" \
  || bad "offline did not keep the copy untouched: $(cat "$TMP/out")"

# 6. THE INVARIANT, asserted independently of every classification above: no path deletes
#    the user's copy. If a future state is misclassified, this is what keeps it survivable.
# The pattern covers the DESTRUCTIVE FAMILY, not one spelling of it. A literal `rm -rf`
# check read as a class guarantee while `rm -fr`, `rm -r`, `git clean -xfd` and
# `find -delete` all walked past it: the claim-wider-than-the-mechanism shape from
# lessons.md, in the very assertion whose job is to bound a class.
printf '%s' "$block" | grep -qE 'rm +-[a-zA-Z]*r|git +clean|-delete|> *"?\$COMMUNITY_DIR' \
  && bad "the refresh block can destroy the mirror; a misdiagnosis would cost the user's work" \
  || ok "no path in the block deletes or truncates the mirror (move-aside only)"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "community-refresh: all $pass assertions passed."; else echo "community-refresh: $fail FAILURE(S) above."; fi
exit "$fail"
