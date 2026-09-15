#!/usr/bin/env bash
# Tests for bin/coverage-check.sh, deterministic PRD-requirement coverage gate.
set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/coverage-check.sh"
fail=0
assert_exit() { # desc expected actual
  if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1 (expected exit $2, got $3)"; fail=1; fi
}
assert_contains() { # desc needle haystack
  case "$3" in *"$2"*) echo "ok: $1";; *) echo "FAIL: $1 (missing '$2')"; fail=1;; esac
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/prds" "$TMP/stories"

cat > "$TMP/prds/PRD-009-demo.md" <<'MD'
---
id: PRD-009
---
## 6. Requirements & acceptance criteria
- **R1 , alpha.**
- **R2 , beta.**
- **R3 , gamma.**
## 7. Risks
- a prose mention of R2 here must NOT be counted as a requirement definition
MD

story() { # file prd covers
  cat > "$TMP/stories/$1" <<MD
---
id: X
prd: $2
covers: $3
---
# body
MD
}

# 1) all requirements covered -> pass
story USR-A.md PRD-009 "R1 R2"
story USR-B.md PRD-009 "R3"
out="$("$SCRIPT" "$TMP/prds/PRD-009-demo.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "all requirements covered -> pass" 0 "$rc"
assert_contains "reports all covered" "all 3 requirements covered" "$out"

# 2) an uncovered requirement -> fail, names it
rm "$TMP/stories/USR-B.md"
out="$("$SCRIPT" "$TMP/prds/PRD-009-demo.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "uncovered requirement -> fail" 1 "$rc"
assert_contains "names the missing requirement" "R3" "$out"

# 3) a story for another PRD does not count
story USR-C.md PRD-999 "R3"
out="$("$SCRIPT" "$TMP/prds/PRD-009-demo.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "story for another PRD is ignored" 1 "$rc"

# 4) missing PRD id in the doc -> usage error (exit 2)
cat > "$TMP/prds/PRD-bad.md" <<'MD'
## 6. Requirements
- **R1 , alpha.**
MD
out="$("$SCRIPT" "$TMP/prds/PRD-bad.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "no id in PRD -> exit 2" 2 "$rc"

# 5) R1 does not satisfy R10 (whole-token match, not substring)
cat > "$TMP/prds/PRD-010-nums.md" <<'MD'
---
id: PRD-010
---
## Requirements
- **R1 , one.**
- **R10 , ten.**
MD
story USR-N.md PRD-010 "R1"
out="$("$SCRIPT" "$TMP/prds/PRD-010-nums.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "R1 does not satisfy R10 (whole token) -> fail" 1 "$rc"
assert_contains "names R10 missing" "R10" "$out"
story USR-N.md PRD-010 "R1 R10"
out="$("$SCRIPT" "$TMP/prds/PRD-010-nums.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "R1 and R10 both covered -> pass" 0 "$rc"

# 6) language independence: non-English PRD (no English 'Requirements' heading) resolves by ID
cat > "$TMP/prds/PRD-012-de.md" <<'MD'
---
id: PRD-012
---
## Anforderungen
- **R1 , deutschsprachige Anforderung.**
- **R2 , noch eine Anforderung.**
MD
story USR-D.md PRD-012 "R1 R2"
out="$("$SCRIPT" "$TMP/prds/PRD-012-de.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "non-English PRD resolves by ID -> pass" 0 "$rc"

# 7) an inline/prose bold reference (not a list item) is not a requirement definition
cat > "$TMP/prds/PRD-013-prose.md" <<'MD'
---
id: PRD-013
---
## Requirements
- **R1 , real.**
Note: as discussed in **R2** we might also consider it (prose, not a definition).
MD
story USR-P.md PRD-013 "R1"
out="$("$SCRIPT" "$TMP/prds/PRD-013-prose.md" "$TMP/stories" 2>&1)"; rc=$?
assert_exit "inline bold **R2** (not a list item) is not counted -> pass" 0 "$rc"
assert_contains "only the one list-item requirement counts" "all 1 requirements" "$out"

exit $fail
