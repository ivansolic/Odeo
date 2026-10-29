#!/usr/bin/env bash
# Tests for scripts/odeo-legacy-hashes.txt, the list odeo-migrate-legacy.sh recognises Odeo's own
# old skill and agent copies by. The suite is named after the file with its extension kept
# (tests/<program>*.test.sh is how docs-claims-check pairs a program with its suite).
#
# This is the part that needs no git history, so it also runs in a published snapshot: the list
# exists, every line is "<kind> <name> <sha256>", it is sorted and unique, and it names every
# skill and agent THIS tree ships (hashed here, independently of the generator). That the list
# also holds every OLD version is proven where the history is, by
# .claude/maintainer/tests/legacy-hashes.test.sh.
#
# Observed failing (2026-10-29), each mutant checked to differ from the original:
#   M1 a line removed that names a shipped skill        -> 1 FAIL (shipped now but not in the list)
#   M2 a malformed line appended                        -> 2 FAIL (format, and the order)
#   M3 a duplicate line added                           -> 1 FAIL (sorted and unique)
#   M4 one hash digit changed                           -> 1 FAIL (shipped now but not in the list)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$ROOT/scripts/odeo-legacy-hashes.txt"
fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

[ -s "$LIST" ] && ok "list exists and is not empty" || bad "scripts/odeo-legacy-hashes.txt missing or empty"
bad_lines="$(grep -vE '^#|^$' "$LIST" | grep -vcE '^(skill|agent) [a-z0-9][a-z0-9-]* [0-9a-f]{64}$')"
[ "$bad_lines" = "0" ] && ok "every line is '<kind> <name> <sha256>'" || bad "$bad_lines malformed line(s) in the list"
body="$(grep -vE '^#|^$' "$LIST")"
[ "$body" = "$(printf '%s\n' "$body" | LC_ALL=C sort -u)" ] && ok "list is sorted and unique" || bad "list is not sorted/unique"
for f in "$ROOT"/skills/*/SKILL.md "$ROOT"/agents/*.md "$ROOT/docs/agent-rubric.md"; do
  rel="${f#"$ROOT"/}"
  case "$rel" in skills/*) n="${rel#skills/}"; n="skill ${n%/SKILL.md}";; docs/*) n="agent agent-rubric";; *) n="${rel#agents/}"; n="agent ${n%.md}";; esac
  h="$({ shasum -a 256 "$f" 2>/dev/null || sha256sum "$f"; } | awk '{print $1}')"
  grep -qxF -- "$n $h" "$LIST" && ok "shipped now: $rel" || bad "shipped now but not in the list: $rel"
done

[ "$fail" -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
