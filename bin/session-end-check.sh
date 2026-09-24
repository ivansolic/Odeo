#!/usr/bin/env bash
#
# session-end-check.sh, advisory end-of-session sweep (Stop hook).
#
# Warns when things that should not outlive a working session are still alive:
# public tunnels, dev servers, extra git worktrees. Advisory only: it prints,
# it never blocks, and it ALWAYS exits 0 (a broken check must not trap the user
# in a session).
#
# Wired by the plugin's hooks/hooks.json Stop hook, gated to Odeo projects.

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

  # 5. The ledger backup has fallen behind the ledger.
  #    This is the only check here that speaks about something git cannot recover: todo.md and
  #    lessons.md are gitignored, so nothing else in this repo would notice them going stale
  #    or the backup silently failing.
  #    It asks ledger-backup.sh --check, which is OFFLINE (it reads a local stamp) and writes
  #    nothing, so a Stop hook can afford it. Exit 3 means no backup location is recorded, and
  #    that stays SILENT on purpose: a user who never asked for a backup should not be told
  #    about one every session. The warning exists for the user who HAS one and believes it
  #    is working.
  #    Exit 1 (behind) AND exit 2 (the check could not decide) both count as speech. Reacting
  #    to 1 alone moved the silence rather than removing it: with an unreadable mtime the
  #    program refuses, correctly, saying silence would be a lie, and then this hook discarded
  #    stderr and printed nothing, so the user's seat looked exactly like "all fine". Exit 3
  #    stays silent, because nobody asked for a backup.
  lb="$(dirname "$0")/ledger-backup.sh"
  if [[ -n "$root" && -x "$lb" ]]; then
    lb_out="$("$lb" --check "$root" 2>&1)"; lb_rc=$?
    if [[ "$lb_rc" -eq 1 || "$lb_rc" -eq 2 ]]; then
      say "$(printf '%s' "$lb_out" | head -n1 | sed 's/^ledger-backup: //')"
      if [[ "$lb_rc" -eq 2 ]]; then
        say "  (the backup check could not run, so whether the ledger is safe is UNKNOWN)"
      else
        say "  (todo.md and lessons.md are gitignored, so git is not carrying them: run /retro, or ledger-backup.sh)"
      fi
    fi
  fi
fi

exit 0
