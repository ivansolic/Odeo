#!/usr/bin/env bash
#
# odeo-migrate-legacy.sh, move an old install.sh install out of the plugin's way.
#
# install.sh copied (or symlinked) Odeo into the home directory. With the plugin installed
# as well, those copies load a second time: every skill and agent twice, and old scripts
# on PATH ahead of the plugin's. This moves exactly what install.sh placed there into one
# ~/.claude/odeo-legacy-<timestamp>/ folder, keeping the relative layout, so undoing it is
# a move back. Nothing is ever deleted.
#
# What moves: ~/.claude/skills/<name> and ~/.claude/agents/<name>.md for every skill and
# agent this plugin ships, ~/bin/<script> for every script in its bin/, ~/.claude/odeo-docs
# and ~/.claude-templates. What never moves: ~/.claude/CLAUDE.md (the user's own), the
# community-knowledge mirror, the privacy deny-list, and anything with a name Odeo does
# not ship. A user's own skill that happens to share an Odeo name is moved too (by name,
# the only thing install.sh left to go by), which the dry run shows first.
#
# Usage:   odeo-migrate-legacy.sh            dry run: list what would move (the default)
#          odeo-migrate-legacy.sh --apply    move it
# Exit:    0 done or nothing to do · 1 a move failed (stops, nothing further moved) · 2 usage
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
case "${1:-}" in
  "") ;;
  --apply) APPLY=true ;;
  *) echo "usage: odeo-migrate-legacy.sh [--apply]" >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { echo "usage: odeo-migrate-legacy.sh [--apply]" >&2; exit 2; }

# candidates: prints every install.sh-placed path (relative to $HOME) that exists now
candidates() {
  local d n f
  for d in "$ROOT"/skills/*/; do
    n="$(basename "$d")"; f=".claude/skills/$n"
    { [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; } && echo "$f"
  done
  for d in "$ROOT"/agents/*.md "$ROOT/docs/agent-rubric.md"; do
    n="$(basename "$d")"; f=".claude/agents/$n"
    { [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; } && echo "$f"
  done
  for d in "$ROOT"/bin/*; do
    n="$(basename "$d")"; f="bin/$n"
    { [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; } && echo "$f"
  done
  for f in .claude/odeo-docs .claude-templates; do
    { [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; } && echo "$f"
  done
  return 0
}

items="$(candidates)"
if [ -z "$items" ]; then
  echo "odeo-migrate-legacy: nothing to migrate, no install.sh copies found in $HOME."
  exit 0
fi

if ! $APPLY; then
  echo "odeo-migrate-legacy: dry run. These install.sh copies would move aside (nothing is deleted):"
  printf '%s\n' "$items" | sed "s|^|  ~/|"
  echo "Run again with --apply to move them into ~/.claude/odeo-legacy-<timestamp>/."
  exit 0
fi

legacy="$HOME/.claude/odeo-legacy-$(date +%Y%m%d%H%M%S)-$$"
moved=0
while IFS= read -r f; do
  mkdir -p "$legacy/$(dirname "$f")" || { echo "odeo-migrate-legacy: cannot create $legacy" >&2; exit 1; }
  if ! mv "$HOME/$f" "$legacy/$f"; then
    echo "odeo-migrate-legacy: could not move ~/$f; stopped after $moved item(s), all kept in $legacy" >&2
    exit 1
  fi
  moved=$((moved + 1))
done <<EOF
$items
EOF
echo "odeo-migrate-legacy: moved $moved install.sh item(s) to $legacy"
echo "Nothing was deleted. To undo, move them back; delete that folder once the plugin works for you."
