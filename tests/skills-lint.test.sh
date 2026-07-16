#!/usr/bin/env bash
# Tests for bin/skills-lint.sh, the system's own consistency gate.
# Each check gets one violating fixture (expect exit 1) and the clean fixture
# passes; finally the REAL repo must pass. Run: bash tests/skills-lint.test.sh
set -uo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT="$TEST_DIR/../bin/skills-lint.sh"
pass=0; fail=0

check() { # check <name> <want_rc> <root>
  ( bash "$LINT" "$3" ) >/dev/null 2>&1; local rc=$?
  if [[ $rc -eq $2 ]]; then echo "ok   - $1"; pass=$((pass+1));
  else echo "FAIL - $1 (rc=$rc want=$2)"; fail=$((fail+1)); fi
}

mkskill() { # mkskill <root> <name> <frontmatter-extra> <body>
  mkdir -p "$1/skills/$2"
  printf -- '---\ndescription: %s\n%s---\n%s\n' "$4" "$3" "${5:-body}" > "$1/skills/$2/SKILL.md"
}

clean_root() { # a minimal root that passes every check
  local d; d="$(mktemp -d)"
  mkdir -p "$d/bin" "$d/agents" "$d/global" "$d/docs"
  touch "$d/bin/privacy-scan.sh"
  mkskill "$d" alpha "" "Use when the user wants alpha things."
  mkskill "$d" beta "disable-model-invocation: true\n" "Explicit command, any description."
  printf -- '---\nname: code-reviewer\n---\nOnly you write the verdict.\n## History\n' > "$d/agents/code-reviewer.md"
  printf -- 'baseline\n' > "$d/global/CLAUDE.md"
  printf -- 'baseline\n' > "$d/AGENTS.md"
  printf -- 'map\n' > "$d/docs/system-map.md"
  echo "$d"
}

# 0. Clean fixture passes
d="$(clean_root)"; check "clean fixture passes" 0 "$d"; rm -rf "$d"

# C1: auto-invoked skill without "Use when" -> fail
d="$(clean_root)"; mkskill "$d" gamma "" "Does gamma things, invoked by the model."
check "C1 flags auto skill without Use-when" 1 "$d"; rm -rf "$d"

# C2: tunnel mention without teardown -> fail; with teardown -> pass
d="$(clean_root)"; mkskill "$d" share "disable-model-invocation: true\n" "Shares things." "Start a cloudflared tunnel for the user."
check "C2 flags tunnel without teardown" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" share "disable-model-invocation: true\n" "Shares things." "Start a cloudflared tunnel. On stop sharing, kill it (teardown)."
check "C2 passes tunnel with teardown" 0 "$d"; rm -rf "$d"

# C3: a doc-producing skill (prd) without editor-open -> fail
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md"
check "C3 flags prd without editor-open" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" prd "disable-model-invocation: true\n" "Writes PRDs." "Save to docs/prds/PRD-NNN.md then open with code -r <file>."
check "C3 passes prd with editor-open" 0 "$d"; rm -rf "$d"

# C4: "Mode A" without "with me" in the same file -> fail
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "Pick Mode A or Mode B. for me is one of them."
check "C4 flags Mode A without with-me pairing" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" delta "disable-model-invocation: true\n" "Builds things." "with me (Mode A) or for me (Mode B)."
check "C4 passes paired mode names" 0 "$d"; rm -rf "$d"

# C5: referencing a script that doesn't exist -> fail
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run ghost-script.sh first."
check "C5 flags missing referenced script" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" eps "disable-model-invocation: true\n" "Uses scripts." "Run privacy-scan.sh first."
check "C5 passes existing script reference" 0 "$d"; rm -rf "$d"

# C6: reviewer agent without the single-verdict contract -> fail
d="$(clean_root)"; printf -- '---\nname: pm-reviewer\n---\nScores documents.\n' > "$d/agents/pm-reviewer.md"
check "C6 flags reviewer without verdict contract" 1 "$d"; rm -rf "$d"

# C7: em dash in a skill -> fail
d="$(clean_root)"; mkskill "$d" zeta "disable-model-invocation: true\n" "Dashy skill." "This uses an em dash — forbidden."
check "C7 flags em dash" 1 "$d"; rm -rf "$d"

# C8: person credit -> fail; third-party plugin name -> fail
d="$(clean_root)"; mkskill "$d" eta "disable-model-invocation: true\n" "Credits people." "Based on Teresa Torres."
check "C8 flags person credit" 1 "$d"; rm -rf "$d"
d="$(clean_root)"; mkskill "$d" theta "disable-model-invocation: true\n" "Mentions plugins." "Also works with pm-skills."
check "C8 flags third-party plugin name" 1 "$d"; rm -rf "$d"

# C9: missing description -> fail
d="$(clean_root)"; mkdir -p "$d/skills/iota"; printf -- '---\n---\nNo description here.\n' > "$d/skills/iota/SKILL.md"
check "C9 flags missing description" 1 "$d"; rm -rf "$d"

# FINAL: the real repo must pass its own lint
check "the actual repo passes its own invariants" 0 "$TEST_DIR/.."

echo ""; echo "passed: $pass, failed: $fail"; [[ $fail -eq 0 ]]
