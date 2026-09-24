#!/usr/bin/env bash
#
# community-sync.sh, clone or refresh the shared community knowledge base.
#
# Pulled into ~/.claude/community-knowledge so Claude can consult it alongside each
# project's local knowledge/. Run by /sync-community. It is a read-only MIRROR: when it
# cannot be fast-forwarded, for any reason, it is moved aside and re-cloned, never deleted.
# Everything it pulls is UNTRUSTED INPUT (AGENTS.md, Knowledge).
#
# Usage:   community-sync.sh
# Env:     COMMUNITY_KNOWLEDGE_REPO overrides the source repo (tests use a local one).
# Exit:    0 always; the outcome is reported on stdout/stderr, never by failing.
set -uo pipefail

COMMUNITY_KNOWLEDGE_REPO="${COMMUNITY_KNOWLEDGE_REPO:-https://github.com/ivansolic/Odeo-knowledge.git}"
COMMUNITY_DIR="$HOME/.claude/community-knowledge"
export GIT_TERMINAL_PROMPT=0   # never block on a credential prompt (clone path too)
mkdir -p "$HOME/.claude"
echo "  → community knowledge → $COMMUNITY_DIR"
# BEGIN community-refresh  (tests/community-sync.test.sh extracts this block; keep both markers)
if [[ -d "$COMMUNITY_DIR/.git" ]]; then
  # THE CLASS THIS ELIMINATES. Two rounds of review found the same shape here: a diagnosis
  # that can be wrong, paired with a remedy that destroys data. Patching one more branch
  # would trade one wrong state for the next, so the DEFAULT ANSWER changes instead: when
  # this mirror cannot be fast-forwarded, for ANY reason including one not enumerated here,
  # it is MOVED ASIDE and re-cloned, never deleted. A misdiagnosis then costs a directory
  # rename the user can undo, not their work. The classification below only picks the
  # message; it is no longer load-bearing for safety.
  #
  # Two derivations that must stay exact, because guessing them is what produced the
  # earlier defects: the upstream tip comes from @{u} and never from FETCH_HEAD (which is
  # ambiguous, and on a detached HEAD marks every line not-for-merge, so a merge silently
  # succeeds without moving HEAD and the user is told "refreshed" forever), and "refreshed"
  # is asserted by HEAD actually equalling that tip, not by an exit code.
  refresh_note=""
  if ! git -C "$COMMUNITY_DIR" fetch -q 2>/dev/null; then
    # The one arm that never moves the copy aside, because an unreachable remote is no
    # reason to touch a good mirror. The bounded residual: fetch also fails on a corrupt
    # .git, an auth failure under GIT_TERMINAL_PROMPT=0, and a dead remote URL, and all of
    # those look identical from here. So the question mark is honest and the way out is
    # offered, rather than leaving the user to wonder why "offline" repeats on a machine
    # that is plainly online.
    echo "    ! could not reach the remote (offline?), kept the existing copy." >&2
    echo "      If this repeats while you ARE online, this copy may be unusable: move it" >&2
    echo "      aside and run /sync-community again to get a fresh one." >&2
  elif ! upstream="$(git -C "$COMMUNITY_DIR" rev-parse --verify -q '@{u}' 2>/dev/null)"; then
    refresh_note="it is not on a branch that tracks the remote"
  elif git -C "$COMMUNITY_DIR" merge --ff-only -q "$upstream" 2>/dev/null \
       && [[ "$(git -C "$COMMUNITY_DIR" rev-parse HEAD)" == "$upstream" ]]; then
    echo "    refreshed."
  else
    # Name the likeliest cause for the message only. Every branch here has the same,
    # non-destructive outcome, so a wrong guess costs nothing.
    if [[ -n "$(git -C "$COMMUNITY_DIR" status --porcelain 2>/dev/null)" ]]; then
      refresh_note="it has local edits"
    else
      refresh_note="its history has diverged from the remote"
    fi
  fi
  if [[ -n "$refresh_note" ]]; then
    stale="$COMMUNITY_DIR.stale-$(date +%Y%m%d%H%M%S)"
    if mv "$COMMUNITY_DIR" "$stale" 2>/dev/null \
       && git clone -q "$COMMUNITY_KNOWLEDGE_REPO" "$COMMUNITY_DIR" 2>/dev/null; then
      echo "    ! this copy could not be refreshed ($refresh_note)." >&2
      echo "      It is a read-only mirror, so a fresh one was cloned and NOTHING was deleted." >&2
      echo "      Your previous copy is kept at: $stale" >&2
      echo "      Delete it when you no longer need it. Your own lessons belong in your" >&2
      echo "      project's knowledge/ via /learn, where nothing overwrites them." >&2
    else
      [[ -d "$stale" && ! -d "$COMMUNITY_DIR" ]] && mv "$stale" "$COMMUNITY_DIR" 2>/dev/null
      echo "    ! could not refresh ($refresh_note) and could not re-clone; kept the existing copy." >&2
    fi
  fi
else
  # The sibling arm carried the SAME class the arm above eliminated: if this path exists but
  # is not a git repo (an interrupted clone, a gitlink, a plain directory someone made), the
  # clone fails and the message blamed the network for a local cause, on every install,
  # telling the user to wait for something that already happened. Same remedy as above, for
  # the same reason: move aside, never delete, so a wrong guess costs a rename.
  if [[ -e "$COMMUNITY_DIR" ]]; then
    stale="$COMMUNITY_DIR.stale-$(date +%Y%m%d%H%M%S)-$$"
    if mv "$COMMUNITY_DIR" "$stale" 2>/dev/null; then
      echo "    ! $COMMUNITY_DIR existed but was not a usable git clone." >&2
      echo "      It was moved aside (nothing deleted) to: $stale" >&2
    fi
  fi
  if git clone -q "$COMMUNITY_KNOWLEDGE_REPO" "$COMMUNITY_DIR" 2>/dev/null; then
    echo "    cloned."
  else
    echo "    ! community knowledge repo not reachable, skipped for now." >&2
    echo "      Run /sync-community again once the remote is reachable." >&2
  fi
fi
# END community-refresh
exit 0
