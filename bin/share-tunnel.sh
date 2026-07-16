#!/usr/bin/env bash
#
# share-tunnel.sh, a time-boxed public tunnel (enforced guardrail).
#
# Exposes a local port through a cloudflared quick tunnel that SHUTS ITSELF
# DOWN when the TTL expires, a forgotten share cannot stay public. Announces
# the exact expiry time up front, records the share in docs/prototypes/.shares
# (so /start can remind about it), and confirms shutdown.
#
# Usage:   share-tunnel.sh <port> [minutes]     (default TTL: 60 minutes)
# Env:     SHARE_TTL_SECONDS overrides the TTL exactly (used by tests)
# Exit:    0 tunnel ran and closed · 2 usage error · 3 cloudflared missing
# Used by: the /prototype share step (and anything else that exposes localhost).

set -uo pipefail

PORT="${1:-}"; MIN="${2:-60}"
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || ! [[ "$MIN" =~ ^[0-9]+$ ]] || [[ "$MIN" -lt 1 ]]; then
  echo "Usage: share-tunnel.sh <port> [minutes>=1]" >&2
  exit 2
fi
command -v cloudflared >/dev/null 2>&1 || {
  echo "share-tunnel: cloudflared is not installed (brew install cloudflared)" >&2
  exit 3
}

TTL="${SHARE_TTL_SECONDS:-$((MIN * 60))}"
end=$(( $(date +%s) + TTL ))
expiry="$(date -r "$end" '+%Y-%m-%d %H:%M' 2>/dev/null || date -d "@$end" '+%Y-%m-%d %H:%M')"
echo "share-tunnel: exposing http://127.0.0.1:$PORT, auto-off at $expiry (${MIN} min)"

LOG="$(mktemp)"
cloudflared tunnel --url "http://127.0.0.1:$PORT" --no-autoupdate >"$LOG" 2>&1 &
pid=$!
( sleep "$TTL"; kill "$pid" 2>/dev/null ) >/dev/null 2>&1 &
watchdog=$!

# Wait for the public URL to appear in cloudflared's output (max 30s)
url=""
i=0
while [[ $i -lt 30 ]]; do
  url="$(grep -hoE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" 2>/dev/null | head -1 || true)"
  [[ -n "$url" ]] && break
  kill -0 "$pid" 2>/dev/null || break
  sleep 1; i=$((i + 1))
done

if [[ -n "$url" ]]; then
  echo "share-tunnel: PUBLIC URL: $url"
  echo "share-tunnel: expires $expiry, extend by re-running; stop early by killing this process."
  if top="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    mkdir -p "$top/docs/prototypes"
    echo "$(date '+%Y-%m-%d %H:%M') | tunnel | port $PORT | $url | expires $expiry" \
      >> "$top/docs/prototypes/.shares"
  fi
else
  echo "share-tunnel: no public URL after 30s, log: $LOG" >&2
fi

wait "$pid" 2>/dev/null || true
kill "$watchdog" 2>/dev/null || true
echo "share-tunnel: tunnel CLOSED (TTL reached or stopped), nothing public remains."
exit 0
