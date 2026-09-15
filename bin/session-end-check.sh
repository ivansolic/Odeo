#!/usr/bin/env bash
#
# session-end-check.sh, advisory end-of-session sweep (Stop hook).
#
# Warns when things that should not outlive a working session are still alive:
# public tunnels, dev servers, extra git worktrees. Advisory only: it prints,
# it never blocks, and it ALWAYS exits 0 (a broken check must not trap the user
# in a session).
#
# Wired by the project template's .claude/settings.json Stop hook.

set -u

warned=0
say() { [[ $warned -eq 0 ]] && echo "session-end check:"; warned=1; echo "  $1"; }

# 1. Public tunnels (the real exposure)
tunnels="$(pgrep -fl 'cloudflared tunnel' 2>/dev/null || true)"
if [[ -n "$tunnels" ]]; then
  say "⚠ a cloudflared tunnel is STILL RUNNING, its public URL is live."
  say "  (share-tunnel.sh TTL will close it eventually; to stop now: pkill -f 'cloudflared tunnel')"
fi

# 2. Dev servers still listening on common dev ports
servers="$(lsof -iTCP:3000-3999 -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $1 " on :" substr($9, index($9, ":") + 1)}' | sort -u)"
if [[ -n "$servers" ]]; then
  while IFS= read -r s; do say "dev server still listening: $s"; done <<< "$servers"
fi

# 3. Extra worktrees (fine if intentional, worth knowing about)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  extra="$(git worktree list 2>/dev/null | tail -n +2)"
  if [[ -n "$extra" ]]; then
    n="$(printf '%s\n' "$extra" | wc -l | tr -d ' ')"
    say "$n extra git worktree(s) exist (git worktree list), fine if builds are in flight."
  fi

  # 4. A /focus edit fence still active (carries into the next session otherwise)
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$root" && -s "$root/.claude/focus-zone" ]]; then
    say "a /focus edit fence is still active on $(head -n1 "$root/.claude/focus-zone"); run /focus off to lift it."
  fi
fi

exit 0
