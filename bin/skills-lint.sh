#!/usr/bin/env bash
#
# skills-lint.sh, the system's own consistency gate (enforced guardrail).
#
# Checks the mechanical invariants in docs/invariants.md over skills/, agents/,
# AGENTS.md, global/CLAUDE.md, and docs/system-map.md. Every check exists
# because its bug class actually happened; see the invariants file for the map.
#
# Usage:   skills-lint.sh [root]      (default: the repo this script lives in)
# Exit:    0 clean · 1 violations (each printed as "LINT [id] file: reason")
# Used by: tests/skills-lint.test.sh, the repo CI, and /improve after skill edits.

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
fail=0
viol() { echo "LINT [$1] $2"; fail=1; }

SKILLS=()
while IFS= read -r f; do SKILLS+=("$f"); done < <(ls "$ROOT"/skills/*/SKILL.md 2>/dev/null)
AGENTS=()
while IFS= read -r f; do AGENTS+=("$f"); done < <(ls "$ROOT"/agents/*.md 2>/dev/null)

# C1. Model-invocable skills must contain "Use when" (routing floor)
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -q "disable-model-invocation: true" "$f" && continue
  grep -q "Use when" "$f" \
    || viol C1 "$f: model-invocable skill has no 'Use when' trigger in its text"
done

# C2. Tunnel mention => exposure lifecycle owned
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -qiE "cloudflared|ngrok|localtunnel" "$f" || continue
  grep -qiE "stop sharing|teardown" "$f" \
    || viol C2 "$f: mentions a tunnel but has no teardown contract"
done

# C3. Spec-document producers reference the editor-open rule
for name in prd stories critique research; do
  f="$ROOT/skills/$name/SKILL.md"
  [[ -f "$f" ]] || continue
  grep -qE "code -r|code --add" "$f" \
    || viol C3 "$f: produces human-read documents but never opens them (code -r)"
done

# C4. Mode aliases always paired with their plain names (per file)
for f in "${SKILLS[@]:+${SKILLS[@]}}" "${AGENTS[@]:+${AGENTS[@]}}" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md"; do
  [[ -f "$f" ]] || continue
  if grep -q "Mode A" "$f" && ! grep -qiE "with[- ]me" "$f"; then
    viol C4 "$f: says 'Mode A' but never 'with me'"
  fi
  if grep -q "Mode B" "$f" && ! grep -qiE "for[- ]me" "$f"; then
    viol C4 "$f: says 'Mode B' but never 'for me'"
  fi
done

# C5. Every referenced *.sh exists (bin/ or repo root)
refs="$(grep -rhoE '\b[a-z][a-z0-9_-]*\.sh\b' "$ROOT/skills" "$ROOT/agents" 2>/dev/null | sort -u)"
for r in $refs; do
  [[ -f "$ROOT/bin/$r" || -f "$ROOT/$r" ]] \
    || viol C5 "referenced script does not exist: $r (searched bin/ and repo root)"
done

# C6. Reviewer agents carry the single-verdict contract
for name in code-reviewer design-reviewer pm-reviewer skill-reviewer; do
  f="$ROOT/agents/$name.md"
  [[ -f "$f" ]] || continue
  { grep -q "Only you" "$f" && grep -q "History" "$f"; } \
    || viol C6 "$f: missing the single-verdict contract ('Only you' + History)"
done

# C7. No em/en dashes in the system's instruction files
dash_hits="$(grep -rlE $'—|–' "$ROOT/skills" "$ROOT/agents" "$ROOT/AGENTS.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $dash_hits; do
  viol C7 "$f: contains an em/en dash (style rule: commas, colons, periods)"
done

# C8. No person credits, no third-party plugin names
PERSONS='Podmajersky|Yifrah|Teresa Torres|Marty Cagan|Ron Jeffries|Bill Wake|Clayton Christensen|Osterwalder|April Dunford|Dave McClure|John Doerr|Andy Grove|Ash Maurya|Gary Klein|Kahneman|Karpathy'
PLUGINS='pm-skills|phuryn'
cred_hits="$(grep -rlE "$PERSONS" "$ROOT/skills" "$ROOT/agents" "$ROOT/docs/system-map.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $cred_hits; do
  viol C8 "$f: credits a person by name (attribution policy: frameworks only)"
done
plug_hits="$(grep -rliE "$PLUGINS" "$ROOT/skills" "$ROOT/agents" "$ROOT/docs/system-map.md" "$ROOT/global/CLAUDE.md" 2>/dev/null || true)"
for f in $plug_hits; do
  viol C8 "$f: names a third-party plugin"
done

# C9. Every SKILL.md declares a non-empty description
for f in "${SKILLS[@]:+${SKILLS[@]}}"; do
  grep -qE '^description: .+' "$f" \
    || viol C9 "$f: missing or empty 'description:' frontmatter"
done

if [[ $fail -eq 0 ]]; then
  echo "skills-lint: all invariants hold."
  exit 0
fi
echo "skills-lint: violations found (see docs/invariants.md for the rules)." >&2
exit 1
