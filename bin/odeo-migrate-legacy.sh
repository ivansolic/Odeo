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
# One exception keeps a guard alive: projects scaffolded before the plugin carry a
# pre-commit / pre-push hook that calls ~/bin/secret-scan.sh and ~/bin/publish-guard.sh.
# When one of those moves, a small SHIM takes its place that runs the newest plugin copy,
# so those projects keep their secret scan and follow plugin updates. With no plugin to
# be found the shim BLOCKS (exit 1) and says so: a guard that vanished must not pass.
#
# Usage:   odeo-migrate-legacy.sh            dry run: list what would move (the default)
#          odeo-migrate-legacy.sh --apply    move it
# Exit:    0 done or nothing to do · 1 a move failed (stops, nothing further moved) · 2 usage
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHIM_NAMES="secret-scan.sh publish-guard.sh"   # what pre-plugin git hooks call in ~/bin
SHIM_MARKER="odeo-migrate-legacy shim"

# Every "what Odeo ships" name comes from the root this runs in, so it must be a plugin
# root. A copy in ~/bin (install.sh put one there) would take $HOME for the root and move
# the user's own files while leaving the real duplicates in place.
if [ ! -f "$ROOT/.claude-plugin/plugin.json" ]; then
  echo "odeo-migrate-legacy: this copy is not inside the Odeo plugin ($ROOT); refusing." >&2
  echo "Run the plugin's copy: inside Claude it is on PATH as odeo-migrate-legacy.sh." >&2
  exit 2
fi
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
    { [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; } || continue
    # our own shim, recognised by its line 2 only (a stale copy of THIS script contains the
    # marker text too, and must move like any other install.sh copy)
    [ ! -L "$HOME/$f" ] && sed -n 2p "$HOME/$f" 2>/dev/null | grep -q "$SHIM_MARKER" && continue
    echo "$f"
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

# write_shim <name>: ~/bin/<name> runs the newest plugin copy of <name>, else blocks
write_shim() {
  { echo '#!/usr/bin/env bash'
    echo "# $SHIM_MARKER: a pre-plugin project's git hook calls ~/bin/$1; this runs the"
    echo "# newest Odeo plugin copy instead. Delete this file if you no longer use those projects."
    printf 'fallback=%q\n' "$ROOT/bin"
    printf 'config_at_migration=%q\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    cat <<'SHIM'
name="$(basename "$0")"
# run_if <path>: execs a candidate, never this shim itself (that would loop forever)
run_if() { [ -x "$1" ] && ! [ "$1" -ef "$0" ] && exec "$1" "${@:2}"; return 0; }
while IFS= read -r d; do
  run_if "$d/$name" "$@"
done < <(ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/bin \
               "$config_at_migration"/plugins/cache/*/odeo/*/bin \
               "$HOME"/.claude/plugins/cache/*/odeo/*/bin 2>/dev/null)
run_if "$fallback/$name" "$@"
echo "$name: the Odeo plugin was not found, so this guard cannot run and BLOCKS." >&2
echo "Reinstall the Odeo plugin, or delete ~/bin/$name if you no longer need it." >&2
exit 1
SHIM
  } > "$HOME/bin/$1" && chmod +x "$HOME/bin/$1"
}

legacy="$HOME/.claude/odeo-legacy-$(date +%Y%m%d%H%M%S)-$$"
moved=0
while IFS= read -r f; do
  mkdir -p "$legacy/$(dirname "$f")" || { echo "odeo-migrate-legacy: cannot create $legacy" >&2; exit 1; }
  if ! mv "$HOME/$f" "$legacy/$f"; then
    echo "odeo-migrate-legacy: could not move ~/$f; stopped after $moved item(s), all kept in $legacy" >&2
    exit 1
  fi
  moved=$((moved + 1))
  case " $SHIM_NAMES " in
    *" ${f#bin/} "*) [ "${f%%/*}" = bin ] && { write_shim "${f#bin/}" \
        || { echo "odeo-migrate-legacy: could not write the ~/$f shim; the original is in $legacy" >&2; exit 1; }; } ;;
  esac
done <<EOF
$items
EOF
echo "odeo-migrate-legacy: moved $moved install.sh item(s) to $legacy"
echo "Nothing was deleted. To undo, move them back; delete that folder once the plugin works for you."
for n in $SHIM_NAMES; do
  grep -q "$SHIM_MARKER" "$HOME/bin/$n" 2>/dev/null \
    && echo "~/bin/$n is now a shim that runs the plugin's copy, so projects created before the plugin keep their git guards."
done
exit 0
