#!/usr/bin/env bash
#
# second-opinion.sh, the ONLY sanctioned path for a paid cross-model review.
#
# Runs an external vendor CLI (an argument, never a baked-in name) over ONE
# artifact, non-interactively and READ-ONLY, and captures the raw transcript with
# provenance. It NEVER simulates: a missing or unauthenticated vendor CLI stops
# the run. It NEVER sends before the payload passes privacy-scan.sh. The vendor's
# findings inform; OUR reviewer still owns the verdict (see second-opinion-protocol.md).
#
# Usage:
#   second-opinion.sh <target> <payload-file> [--vendor NAME] [--model ID] [--mode review|adversarial]
#     target       code | plan | pm | design   (picks the default vendor)
#     payload-file the artifact/diff to review (a file; scanned before any send)
#     --vendor     override the default vendor for the target
#     --model      request a specific vendor model (else the vendor default)
#     --mode       review (default) or adversarial (think-like-an-attacker, read-only)
# Env:
#   SECOND_OPINION_TIMEOUT   override the per-run timeout in seconds (tests use this)
# Exit: 0 ok · 1 privacy-scan blocked the payload · 2 usage/setup error ·
#       3 vendor CLI missing / unauthenticated / run failed · 124 vendor timed out
#
# Raw transcripts land in docs/second-opinion-logs/ (gitignored); the committed
# eval record references only the path + sha256 (see the protocol).

set -uo pipefail

usage() { echo "Usage: second-opinion.sh <code|plan|pm|design> <payload-file> [--vendor NAME] [--model ID] [--mode review|adversarial]" >&2; exit 2; }

# --- parse args ---
TARGET="${1:-}"; PAYLOAD="${2:-}"
[[ -n "$TARGET" && -n "$PAYLOAD" && "$TARGET" != --* && "$PAYLOAD" != --* ]] || usage
shift 2 || usage
VENDOR=""; MODEL=""; MODE="review"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vendor) VENDOR="${2:-}"; shift 2 || usage ;;
    --model)  MODEL="${2:-}";  shift 2 || usage ;;
    --mode)   MODE="${2:-}";   shift 2 || usage ;;
    *) echo "second-opinion: unknown argument '$1'" >&2; usage ;;
  esac
done

case "$TARGET" in code|plan|pm|design) : ;; *) echo "second-opinion: target must be code|plan|pm|design, got '$TARGET'" >&2; usage ;; esac
case "$MODE" in review|adversarial) : ;; *) echo "second-opinion: mode must be review|adversarial, got '$MODE'" >&2; usage ;; esac
[[ -f "$PAYLOAD" ]] || { echo "second-opinion: payload file not found: $PAYLOAD" >&2; exit 2; }

# --- resolve the vendor (argument first, else the per-target default) ---
if [[ -z "$VENDOR" ]]; then
  case "$TARGET" in
    design) VENDOR="gemini" ;;   # multimodal target
    *)      VENDOR="codex"  ;;   # code | plan | doc
  esac
fi
case "$VENDOR" in codex|gemini) : ;; *) echo "second-opinion: unknown vendor '$VENDOR' (known: codex, gemini)" >&2; exit 2 ;; esac

# --- vendor must be present AND answer a probe; never simulate ---
command -v "$VENDOR" >/dev/null 2>&1 || { echo "second-opinion: vendor CLI '$VENDOR' is not installed, cannot get a second opinion (install it, then retry)" >&2; exit 3; }
if ! CLI_VERSION="$("$VENDOR" --version 2>/dev/null)"; then
  echo "second-opinion: vendor CLI '$VENDOR' did not respond to --version (broken or not usable); refusing to send" >&2
  exit 3
fi

# --- pre-send gate: the payload is scanned BEFORE it can leave the machine ---
SCAN=""
for cand in "$HOME/bin/privacy-scan.sh" "$(dirname "$0")/privacy-scan.sh"; do
  [[ -x "$cand" || -f "$cand" ]] && { SCAN="$cand"; break; }
done
[[ -n "$SCAN" ]] || { echo "second-opinion: privacy-scan.sh not found; refusing to send without the pre-send gate" >&2; exit 2; }
scan_out="$(bash "$SCAN" "$PAYLOAD" 2>&1)"; scan_rc=$?
if [[ $scan_rc -eq 1 ]]; then
  echo "second-opinion: privacy-scan BLOCKED the payload, nothing was sent:" >&2
  printf '%s\n' "$scan_out" | sed 's/^/    /' >&2
  exit 1
elif [[ $scan_rc -ne 0 ]]; then
  echo "second-opinion: privacy-scan could not run (rc=$scan_rc), refusing to send:" >&2
  printf '%s\n' "$scan_out" | sed 's/^/    /' >&2
  exit 2
fi

# --- build the prompt: framing + read-only + filesystem boundary + the artifact ---
PROMPT="$(mktemp)"
trap 'rm -f "$PROMPT"' EXIT
{
  echo "You are giving an INDEPENDENT SECOND OPINION as an external reviewer."
  echo "Review ONLY the artifact content below. This is READ-ONLY: reason about"
  echo "problems; do not propose to edit, run, or access anything."
  echo "Filesystem boundary: do NOT read or access any files or paths (never"
  echo "~/.claude, agents/, or repo internals). Everything you may use is below."
  [[ "$MODE" == "adversarial" ]] && echo "ADVERSARIAL MODE: think like an attacker and a skeptic; show how this FAILS."
  echo "Return STRUCTURED findings, one per issue: target, class, file:line, severity, why."
  echo ""
  echo "=== ARTIFACT (target: $TARGET) ==="
  cat -- "$PAYLOAD"
} > "$PROMPT"

# --- per-vendor invocation (the ONLY place a vendor name shapes a command) ---
# Flags are designed to the documented CLIs; verify against the installed CLI
# version on first real use. The prompt is delivered on stdin to avoid ARG_MAX.
VCMD=()
case "$VENDOR" in
  codex)  VCMD=(codex exec --sandbox read-only); [[ -n "$MODEL" ]] && VCMD+=(--model "$MODEL") ;;
  gemini) VCMD=(gemini); [[ -n "$MODEL" ]] && VCMD+=(-m "$MODEL"); VCMD+=(-p) ;;
esac

# --- logs (gitignored) live at the repo root; fall back to a temp dir ---
if TOP="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  LOGDIR="$TOP/docs/second-opinion-logs"
else
  LOGDIR="$(mktemp -d)"
fi
mkdir -p "$LOGDIR"
STAMP="$(date '+%Y%m%d-%H%M%S')"
RAW="$LOGDIR/${TARGET}-${VENDOR}-${STAMP}.log"
TIMEDOUT="$RAW.timedout"

# --- run under a timeout (watchdog, portable), prompt on stdin ---
TIMEOUT="${SECOND_OPINION_TIMEOUT:-$([[ "$MODE" == adversarial ]] && echo 600 || echo 330)}"
echo "second-opinion: sending $TARGET to $VENDOR (${MODEL:-vendor default model}, $MODE, timeout ${TIMEOUT}s)"
start=$(date +%s)
"${VCMD[@]}" < "$PROMPT" > "$RAW" 2>&1 &
vpid=$!
# Poll (no long-lived orphan sleep): tick every 1s until the vendor exits or the
# timeout elapses, then TERM and, after a grace second, KILL.
waited=0
while kill -0 "$vpid" 2>/dev/null; do
  if [[ $waited -ge $TIMEOUT ]]; then
    : > "$TIMEDOUT"
    kill -TERM "$vpid" 2>/dev/null; sleep 1; kill -KILL "$vpid" 2>/dev/null
    break
  fi
  sleep 1; waited=$((waited + 1))
done
wait "$vpid" 2>/dev/null; vrc=$?
dur=$(( $(date +%s) - start ))

if [[ -e "$TIMEDOUT" ]]; then
  rm -f "$TIMEDOUT"
  echo "second-opinion: '$VENDOR' timed out after ${TIMEOUT}s (partial log: $RAW)" >&2
  exit 124
fi
if [[ $vrc -ne 0 ]]; then
  echo "second-opinion: '$VENDOR' run failed (rc=$vrc, log: $RAW)" >&2
  exit 3
fi
if [[ ! -s "$RAW" ]]; then
  echo "second-opinion: '$VENDOR' returned no output (log: $RAW); not a usable second opinion" >&2
  exit 3
fi

# --- provenance: version, actual model, duration, hash, timestamp ---
sha() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'; else sha256sum "$1" | awk '{print $1}'; fi; }
OUT_SHA="$(sha "$RAW")"
# actual model as the vendor reported it, best-effort parse; fall back to requested/unknown
# Parse only a line whose KEY is model (line-anchored), never the word in prose.
ACTUAL_MODEL="$(sed -nE 's/^[[:space:]]*"?[Mm]odel"?[[:space:]]*[:=][[:space:]]*"?([A-Za-z0-9._-]+).*/\1/p' "$RAW" 2>/dev/null | head -1 || true)"
[[ -n "$ACTUAL_MODEL" ]] || ACTUAL_MODEL="${MODEL:-unknown}"
PROV="$RAW.provenance"
{
  echo "vendor: $VENDOR"
  echo "cli_version: $CLI_VERSION"
  echo "vendor_model: $ACTUAL_MODEL"
  echo "mode: $MODE"
  echo "target: $TARGET"
  echo "duration_seconds: $dur"
  echo "output_sha256: $OUT_SHA"
  echo "timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "raw_log: $RAW"
} > "$PROV"

echo "second-opinion: DONE, vendor=$VENDOR model=$ACTUAL_MODEL ${dur}s sha256=$OUT_SHA"
echo "second-opinion: raw transcript: $RAW"
echo "second-opinion: provenance: $PROV"
echo "second-opinion: findings inform only, OUR reviewer authors the comparison and keeps the verdict."
exit 0
