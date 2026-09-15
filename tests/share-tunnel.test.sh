#!/usr/bin/env bash
# Tests for bin/share-tunnel.sh (time-boxed tunnel) and bin/session-end-check.sh.
# Uses a FAKE cloudflared on PATH, no network. Run: bash tests/share-tunnel.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARE="$TEST_DIR/../bin/share-tunnel.sh"
ENDCHECK="$TEST_DIR/../bin/session-end-check.sh"
pass=0; fail=0
ok()   { echo "ok   - $1"; pass=$((pass+1)); }
bad()  { echo "FAIL - $1"; fail=$((fail+1)); }

# --- arg validation ---
bash "$SHARE" >/dev/null 2>&1;        [[ $? -eq 2 ]] && ok "no args -> usage error (2)"        || bad "no args rc"
bash "$SHARE" abc >/dev/null 2>&1;    [[ $? -eq 2 ]] && ok "non-numeric port -> usage error"   || bad "bad port rc"
bash "$SHARE" 3001 0 >/dev/null 2>&1; [[ $? -eq 2 ]] && ok "zero minutes -> usage error"       || bad "zero min rc"

# --- cloudflared missing -> 3 (PATH stripped to a bare dir) ---
emptybin="$(mktemp -d)"
for t in bash grep date mktemp sleep kill head awk git wc tr; do
  p="$(command -v $t)" && ln -s "$p" "$emptybin/$t" 2>/dev/null
done
PATH="$emptybin" bash "$SHARE" 3001 1 >/dev/null 2>&1
[[ $? -eq 3 ]] && ok "missing cloudflared -> exit 3" || bad "missing cloudflared rc"
rm -rf "$emptybin"

# --- fake cloudflared: URL announced, .shares recorded, TTL kills it ---
work="$(mktemp -d)"
( cd "$work" && git init -q )
fakebin="$(mktemp -d)"
cat > "$fakebin/cloudflared" <<'FAKE'
#!/usr/bin/env bash
echo "INF Starting tunnel"
echo "INF +  https://fake-test-tunnel.trycloudflare.com  +"
sleep 30
FAKE
chmod +x "$fakebin/cloudflared"

start=$(date +%s)
out="$(cd "$work" && PATH="$fakebin:$PATH" SHARE_TTL_SECONDS=2 bash "$SHARE" 3001 1 2>&1)"
rc=$?; elapsed=$(( $(date +%s) - start ))

[[ $rc -eq 0 ]] && ok "fake tunnel run exits 0" || bad "fake tunnel rc=$rc"
echo "$out" | grep -q "PUBLIC URL: https://fake-test-tunnel.trycloudflare.com" \
  && ok "announces the public URL" || bad "URL not announced"
echo "$out" | grep -q "auto-off at" && ok "announces expiry up front" || bad "no expiry announcement"
echo "$out" | grep -q "CLOSED" && ok "confirms shutdown" || bad "no shutdown confirmation"
[[ $elapsed -lt 15 ]] && ok "TTL killed the tunnel (${elapsed}s, not 30s)" || bad "TTL did not kill (${elapsed}s)"
grep -q "tunnel | port 3001 | https://fake-test-tunnel.trycloudflare.com" "$work/docs/prototypes/.shares" 2>/dev/null \
  && ok "share recorded in docs/prototypes/.shares" || bad ".shares record missing"
rm -rf "$work" "$fakebin"

# --- session-end-check: advisory, always exit 0 ---
bash "$ENDCHECK" >/dev/null 2>&1 && ok "session-end-check exits 0" || bad "session-end-check nonzero"

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
