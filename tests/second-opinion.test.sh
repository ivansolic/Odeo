#!/usr/bin/env bash
# Tests for bin/second-opinion.sh (the paid cross-model review wrapper).
# Uses a FAKE vendor CLI on PATH, no network, no real vendor needed.
# Run: bash tests/second-opinion.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SO="$TEST_DIR/../bin/second-opinion.sh"
pass=0; fail=0
ok()  { echo "ok   - $1"; pass=$((pass+1)); }
bad() { echo "FAIL - $1"; fail=$((fail+1)); }

# fake_vendor <dir> <name> <sleep-seconds> : a CLI that answers --version and,
# on a real call, drains stdin, prints a model line + a finding, then exits.
fake_vendor() {
  local dir="$1" name="$2" nap="$3"
  cat > "$dir/$name" <<FAKE
#!/usr/bin/env bash
if [[ "\${1:-}" == "--version" ]]; then echo "$name 9.9.9-fake"; exit 0; fi
cat >/dev/null            # drain the prompt on stdin
sleep $nap
echo "model: fake-frontier-1"
echo "Finding: code | correctness | app.js:10 | High | unchecked input"
exit 0
FAKE
  chmod +x "$dir/$name"
}

# --- arg validation ---
bash "$SO" >/dev/null 2>&1;                 [[ $? -eq 2 ]] && ok "no args -> usage error (2)"       || bad "no args rc"
bash "$SO" bogus /tmp/x >/dev/null 2>&1;    [[ $? -eq 2 ]] && ok "bad target -> usage error (2)"    || bad "bad target rc"
pf="$(mktemp)"; echo "clean diff, nothing secret" > "$pf"
bash "$SO" code /no/such/file >/dev/null 2>&1; [[ $? -eq 2 ]] && ok "missing payload -> usage (2)"  || bad "missing payload rc"

# --- vendor CLI missing -> 3 (codex/gemini are not installed here) ---
bash "$SO" code "$pf" --vendor codex >/dev/null 2>&1
[[ $? -eq 3 ]] && ok "missing vendor CLI -> exit 3 (never simulates)" || bad "missing vendor rc"

# --- privacy-scan blocks a payload with a secret BEFORE any send -> 1 ---
fakebin="$(mktemp -d)"; fake_vendor "$fakebin" codex 0
secretpf="$(mktemp)"
printf -- '-----BEGIN RSA PRIVATE KEY-----\nMIIEabc123\n-----END RSA PRIVATE KEY-----\n' > "$secretpf"
out="$(PATH="$fakebin:$PATH" bash "$SO" code "$secretpf" --vendor codex 2>&1)"; rc=$?
[[ $rc -eq 1 ]] && ok "privacy-scan blocks the payload -> exit 1" || bad "privacy block rc=$rc"
echo "$out" | grep -q "BLOCKED" && ok "block message shown, nothing sent" || bad "no BLOCKED message"
rm -f "$secretpf"

# --- happy path: fake vendor answers, provenance + raw log written -> 0 ---
work="$(mktemp -d)"; ( cd "$work" && git init -q )
cleanpf="$work/change.diff"; echo "def add(a, b): return a + b" > "$cleanpf"
out="$(cd "$work" && PATH="$fakebin:$PATH" bash "$SO" code "$cleanpf" --vendor codex 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "happy path exits 0" || bad "happy path rc=$rc"
echo "$out" | grep -q "vendor=codex" && ok "reports the vendor" || bad "vendor not reported"
echo "$out" | grep -q "model=fake-frontier-1" && ok "parses the actual vendor model" || bad "model not parsed"
echo "$out" | grep -q "sha256=" && ok "stamps an output hash" || bad "no hash"
ls "$work/docs/second-opinion-logs/"*.log >/dev/null 2>&1 && ok "raw transcript written (gitignored dir)" || bad "no raw log"
prov="$(ls "$work/docs/second-opinion-logs/"*.provenance 2>/dev/null | head -1)"
[[ -n "$prov" ]] && grep -q "vendor_model: fake-frontier-1" "$prov" && ok "provenance file records vendor_model" || bad "provenance missing/incomplete"

# --- vendor returns nothing -> not a usable opinion -> 3 ---
fakeempty="$(mktemp -d)"
cat > "$fakeempty/codex" <<'FAKE'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then echo "codex 9.9.9-fake"; exit 0; fi
cat >/dev/null; exit 0
FAKE
chmod +x "$fakeempty/codex"
( cd "$work" && PATH="$fakeempty:$PATH" bash "$SO" code "$cleanpf" --vendor codex >/dev/null 2>&1 )
[[ $? -eq 3 ]] && ok "empty vendor output -> exit 3" || bad "empty output rc"
rm -rf "$fakeempty"

# --- model parser ignores the word "model" in prose (provenance not corrupted) ---
fakeprose="$(mktemp -d)"
cat > "$fakeprose/codex" <<'FAKE'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then echo "codex 9.9.9-fake"; exit 0; fi
cat >/dev/null
echo "The data model here looks wrong; no explicit model line is emitted."
echo "Finding: code | correctness | app.js:1 | Low | naming"
exit 0
FAKE
chmod +x "$fakeprose/codex"
( cd "$work" && PATH="$fakeprose:$PATH" bash "$SO" code "$cleanpf" --vendor codex --model asked-model >/dev/null 2>&1 )
prov2="$(ls -t "$work/docs/second-opinion-logs/"*.provenance 2>/dev/null | head -1)"
if [[ -n "$prov2" ]] && ! grep -qE "vendor_model: (here|wrong|looks)" "$prov2"; then
  ok "model parser does not capture a prose word (falls back to requested)"
else
  bad "model parser captured prose from '$prov2'"
fi
rm -rf "$fakeprose"

# --- timeout: a vendor that hangs is killed -> 124 ---
fakeslow="$(mktemp -d)"; fake_vendor "$fakeslow" codex 30
start=$(date +%s)
( cd "$work" && PATH="$fakeslow:$PATH" SECOND_OPINION_TIMEOUT=2 bash "$SO" code "$cleanpf" --vendor codex >/dev/null 2>&1 )
rc=$?; elapsed=$(( $(date +%s) - start ))
[[ $rc -eq 124 ]] && ok "hanging vendor times out -> exit 124" || bad "timeout rc=$rc"
[[ $elapsed -lt 15 ]] && ok "timeout fired fast (${elapsed}s, not 30s)" || bad "timeout too slow (${elapsed}s)"

rm -rf "$fakebin" "$fakeslow" "$work"; rm -f "$pf"
echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
