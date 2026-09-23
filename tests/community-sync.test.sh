#!/usr/bin/env bash
# Tests for bin/community-sync.sh, the community-knowledge refresh (/sync-community).
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
# HOW TO MUTATION-PROVE THIS FILE. Use this recipe verbatim; escape `\$` on BOTH sides.
#   perl -0pi -e 's/mv "\$COMMUNITY_DIR" "\$stale" 2>\/dev\/null/rm -rf "\$COMMUNITY_DIR" 2>\/dev\/null/g' bin/community-sync.sh
# Expected: FOUR failures, the canary line among them. Leaving the replacement side
# unescaped makes perl interpolate an undefined variable, producing `rm -rf ""`, which
# deletes nothing and exits 0. That no-op mutant still reddens cases 3 and 4 (no
# `.stale-*` is created because the `mv` never ran), which reads exactly like proof the
# mutation reached live code, so the surviving canary line looks vacuous when it is simply
# telling the truth. Three rounds were spent "fixing" a correct assertion because of it.
# A mutation recipe that can silently become a no-op is the same vacuity class this suite
# exists to catch, one level further out: in the instrument doing the checking.
#
# Run: bash tests/community-sync.test.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com
export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com
export GIT_TERMINAL_PROMPT=0

# The classifier under test, extracted from bin/community-sync.sh so this runs the REAL logic. The
# markers are named; a drift must fail loud rather than silently verify a paraphrase.
block="$(awk '/^# BEGIN community-refresh/,/^# END community-refresh$/' "$ROOT/bin/community-sync.sh")"
lines=$(printf '%s\n' "$block" | wc -l | tr -d ' ')
if [[ -z "$block" || "$lines" -gt 95 ]] || ! printf '%s' "$block" | grep -q 'stale-'; then
  echo "FAIL - instrument broken: extracted $lines lines; the markers in bin/community-sync.sh moved."
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
  local mirror="$1" home
  # mktemp, not a counter: run() is called as `h=$(run ...)`, a subshell, so a counter
  # incremented here never reaches the parent and every home collides on the same name,
  # nesting one mirror inside another. That is the same subshell trap as the HOMES array,
  # and it bit again while applying a review nitpick that suggested exactly a counter.
  home="$(mktemp -d "$TMP/home-XXXXXX")"
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

# run_with_canaries <mirror> -> like run(), but plants the canaries FIRST.
# Kept separate on purpose. Planting them inside run() committed a file into every fixture,
# which put each mirror one commit AHEAD of upstream, so `merge --ff-only` could not succeed
# anywhere: the classification cases went dead while still printing ok, because
# `grep -q refreshed` matches the substring of "could not be refreshed". A fixture change
# that silently disables the cases it runs through is the exact shape lessons.md 2026-08-18
# names (green because the mechanism never ran). The two concerns now use two fixtures.
run_with_canaries() {
  local mirror="$1"
  printf 'canary-tracked\n' > "$mirror/canary-tracked.md"
  ( cd "$mirror" && git add canary-tracked.md && git commit -qm canary ) >/dev/null 2>&1
  printf 'canary-untracked\n' > "$mirror/canary-untracked.md"
  local h; h="$(run "$mirror")"
  # The marker lives OUTSIDE the mirror on purpose. Identifying canary homes by the
  # canaries themselves means a command that destroys them makes the home INVISIBLE to
  # the check instead of failing it: the guard would go quiet exactly when it should
  # shout. Measured: with the move-aside mutated to `rm -Rf`, the canary assertion
  # printed ok. Same vacuity class as the fixture bug above, one level up.
  : > "$h/.claude/.canary-home"
  echo "$h"
}

# canaries_survive <home> -> 0 if BOTH canaries are still reachable somewhere under
# ~/.claude, in place or in a moved-aside copy, WITH THEIR CONTENT INTACT.
#
# This asserts an OUTCOME, and that is the whole point. The previous guard grepped the
# source for `rm -rf`; review walked past it with `rm -fr`, then past the widened pattern
# with `git -C "$DIR" clean -xfd`, which no scenario caught either because no fixture had
# an untracked file. Two rounds of adding spellings to a denylist is the instance-patch
# shape this repo's own lessons.md forbids.
#
# The CONTENT is read back, not just the path, because destruction has two shapes and this
# helper used to cover one. Testing `-f` alone, it claimed to catch destruction "whatever it
# is called" while a command that emptied or overwrote the file IN PLACE (a truncating
# redirect, `git checkout --force`) left the name behind and passed. Reading the content
# closes that half, so the claim and the mechanism now describe the same thing.
#
# What it still cannot witness, stated rather than implied: the canaries are two files, one
# tracked and one untracked, inside the mirror. Destruction of something else under
# ~/.claude, or in a mirror state no scenario below builds, is outside their reach.
canaries_survive() {
  local home="$1" t=0 u=0
  while IFS= read -r f; do grep -qx 'canary-tracked' "$f" 2>/dev/null && t=1
  done < <(find "$home/.claude" -name 'canary-tracked.md' 2>/dev/null)
  while IFS= read -r f; do grep -qx 'canary-untracked' "$f" 2>/dev/null && u=1
  done < <(find "$home/.claude" -name 'canary-untracked.md' 2>/dev/null)
  [[ "$t" -eq 1 && "$u" -eq 1 ]]
}


# 1. Normal mirror refreshes, and HEAD actually moves. Asserting the MESSAGE alone would
#    have passed on the detached-HEAD bug, where git reported success without moving HEAD.
h=$(run "$(mkmirror m1)")
# ANCHORED: an unanchored `refreshed` also matches "could not be refreshed", which is how
# this case stayed green while the fixture had disabled it.
grep -qE '^ *refreshed\.$' "$TMP/out" && ok "a normal mirror reports refreshed" || bad "normal mirror: $(cat "$TMP/out")"
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
# The missing half: "no stale copy" plus "offline in the output" are both TRUE after the
# copy is deleted outright, so an assertion named "keeps the existing copy in place" stayed
# green while the copy was gone. Verified by injecting a delete into the offline arm.
[[ -z "$(ls -d "$h/.claude"/community-knowledge.stale-* 2>/dev/null)" ]] \
  && [[ -d "$h/.claude/community-knowledge/.git" ]] \
  && grep -q 'offline' "$TMP/out" \
  && ok "offline keeps the existing copy in place and says so" \
  || bad "offline did not keep the copy untouched: $(cat "$TMP/out")"

# 6. THE INVARIANT, asserted independently of every classification above: no path deletes
#    the user's copy. If a future state is misclassified, this is what keeps it survivable.
# THE INVARIANT, now asserted by OUTCOME over every scenario above rather than by grepping
# the source for command spellings. The text check is kept only as a cheap early warning,
# and is explicitly NOT the guarantee: it cannot be, as two rounds of evasion showed.
# A dedicated canary pass over the two states that actually touch the mirror, so the
# invariant has fixtures of its own instead of borrowing the classification ones.
cm=$(mkmirror c1); echo "edit" >> "$cm/f.md"; run_with_canaries "$cm" >/dev/null
cm=$(mkmirror c2); ( cd "$cm" && echo mine > f.md && git commit -qam "c2 diverge" ) >/dev/null 2>&1
run_with_canaries "$cm" >/dev/null
# c1 and c2 both land on the SAME move-aside site, so they were two fixtures deep on one
# path. The offline arm is the one whose entire contract is "touch nothing", and it had no
# canary at all.
cm=$(mkmirror c3); git -C "$cm" remote set-url origin /nonexistent-remote
run_with_canaries "$cm" >/dev/null

all_survived=1
# The homes are DISCOVERED from disk, not accumulated in a variable: run() is called as
# `h=$(run ...)`, a command substitution, which is a subshell, so an array appended inside
# it never reaches this scope. That is lessons.md 2026-08-13 verbatim (a helper either
# prints its result or sets a variable, never both), and it cost a green-looking run here
# before the set -u tripwire caught it.
n_homes=0
for hh in "$TMP"/home-*; do
  [[ -d "$hh" ]] || continue
  # Only homes that were given canaries can be judged on them.
  [[ -f "$hh/.claude/.canary-home" ]] || continue
  n_homes=$((n_homes+1))
  canaries_survive "$hh" || all_survived=0
done
[[ "$n_homes" -ge 3 ]] || { echo "FAIL - instrument broken: found $n_homes canary homes, expected 3"; fail=$((fail+1)); }
[[ "$all_survived" -eq 1 ]] \
  && ok "no scenario destroyed the user's files (both canaries survive every path)" \
  || bad "a scenario destroyed a canary: a misdiagnosis would cost the user's work"

# Names exactly what it matches, and nothing wider: four spellings, chosen because each
# appeared in a real mutation. It is a typo-catcher, not a class guard. The class guard is
# the canary block above, which is why this line may stay narrow without lying.
printf '%s' "$block" | grep -qiE 'rm +-[a-zA-Z]*r|git +(-C +[^ ]+ +)?clean|-delete' \
  && bad "early warning: the block contains a destructive-looking command; check the canaries above" \
  || ok "early warning: none of the four spellings it knows (not a class guarantee; the canaries above are)"

echo ""
if [[ "$fail" -eq 0 ]]; then echo "community-refresh: all $pass assertions passed."; else echo "community-refresh: $fail FAILURE(S) above."; fi
exit "$fail"
