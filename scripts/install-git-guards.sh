#!/usr/bin/env bash
#
# install-git-guards.sh, installs the enforced git hooks into the CURRENT repo.
#
#   pre-commit : runs secret-scan.sh over the staged changes; secrets block commit
#
# It writes NO pre-push hook: the push guard is not installed into users' projects (PRD-002
# R4). This repository's own push guard is written by .claude/maintainer/install-git-guards.sh.
#
# It is also the refresh the session-start check offers for a git hook that calls a script the
# release no longer ships (scripts/odeo-removed-scripts.txt, PRD-002 R8): what it replaces is
# KEPT, never deleted. A pre-commit that differs from the one it writes (an old Odeo hook, a
# hook the user wrote, a symlink) is moved to pre-commit.odeo-old-<YYYYmmddHHMMSS>-<pid> in the
# same hooks directory first, and a pre-push that mentions a removed script is moved aside the
# same way. A pre-push that mentions none is the user's own and stays untouched. Hook files are
# only read for this, never run. With core.hooksPath set, that directory is the one refreshed.
#
# Hooks live in .git/hooks (not versioned), so each clone runs this once.
# init-project.sh runs it automatically for new projects.
#
# Usage: install-git-guards.sh   (inside a git repo)
# Exit:  0 installed · 2 not a git repo

set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "install-git-guards: not a git repository" >&2; exit 2; }

hooks_dir="$(git rev-parse --git-path hooks)"
mkdir -p "$hooks_dir"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# hook_preamble: the shebang plus odeo_tool, the lookup the hook uses. Git runs hooks from
# the user's own terminal too, where a plugin's programs are NOT on PATH, and a copied
# plugin lives in a per-version cache directory that an update replaces. So a tool is
# looked up: the newest cached Odeo version (in CLAUDE_CONFIG_DIR, the config
# dir at install time, and ~/.claude, since a user may run Claude with CLAUDE_CONFIG_DIR
# while git runs from a shell without it), then the directory these hooks were installed
# from (baked in; stable for a plugin loaded in place from a clone). Never PATH and never a
# path relative to the repo: both can hold a script of the same name that the user or the
# project put there (direnv PATH_add, node_modules/.bin, "." in PATH, a project's own
# scripts/), which would stand in for Odeo's gate and silence the missing-gate warning.
# ODEO_HOOKS_VERSION marks this layout; the session-start hook names older Odeo hooks.
# Each cache is searched as scripts/ first and bin/ second: bin/ is the 0.2.x layout, kept
# only so a hook written now still works against an old cached version (so after a
# downgrade to 0.2.x, a newer cached scripts/ still wins).
# Limit: with CLAUDE_CODE_SUBPROCESS_ENV_SCRUB set, CLAUDE_CONFIG_DIR may not reach this
# installer, so the baked config dir falls back to ~/.claude; the install-time directory
# still works until an update sweeps that version. The same miss happens when a plugin
# loaded in place from a clone is moved: the hook then warns instead of scanning,
# and the session-start nudge names the hook for a refresh.
hook_preamble() {
  echo '#!/usr/bin/env bash'
  echo 'ODEO_HOOKS_VERSION=2'
  printf 'ODEO_BIN_AT_INSTALL=%q\n' "$SCRIPT_DIR"
  printf 'ODEO_CONFIG_AT_INSTALL=%q\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  cat <<'PREAMBLE'
odeo_tool() { # odeo_tool <name>: prints the path of an Odeo script, nothing if not found
  local name="$1" c
  # newest first: after an update the old version stays in the cache for a grace period.
  # scripts/ is where the programs live; bin/ is where Odeo 0.2.x kept them.
  while IFS= read -r c; do
    [ -x "$c/$name" ] && { printf '%s' "$c/$name"; return 0; }
  done < <(ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/scripts \
                   "$ODEO_CONFIG_AT_INSTALL"/plugins/cache/*/odeo/*/scripts \
                   "$HOME"/.claude/plugins/cache/*/odeo/*/scripts 2>/dev/null
           ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/bin \
                   "$ODEO_CONFIG_AT_INSTALL"/plugins/cache/*/odeo/*/bin \
                   "$HOME"/.claude/plugins/cache/*/odeo/*/bin 2>/dev/null)
  [ -x "$ODEO_BIN_AT_INSTALL/$name" ] && printf '%s' "$ODEO_BIN_AT_INSTALL/$name"
  return 0
}
PREAMBLE
}

# The list of removed scripts, read the same way hooks/odeo-context.sh reads it. A line that is
# not shaped like a script name is skipped with a message on stderr (a name becomes part of a
# grep pattern below, so nothing else may get through); a missing list is reported by the
# caller and is not an error: pre-commit is still installed.
REMOVED_LIST="$SCRIPT_DIR/odeo-removed-scripts.txt"
removed_scripts() {
  local line re='^[a-z0-9][a-z0-9._-]*\.sh$'
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in ''|'#'*) continue ;; esac
    if [[ "$line" =~ $re ]]; then printf '%s\n' "$line"
    else printf 'install-git-guards: skipped a line of odeo-removed-scripts.txt that is not a script name: %q\n' "$line" >&2
    fi
  done < "$REMOVED_LIST"
}

# hook_removed <hook> <names>: the first removed script the hook's text mentions as a whole
# token ("bin/merge-gate.sh" counts, "my-merge-gate.sh.bak" does not); nothing when none. The
# hook is only READ. Same matching as hooks/odeo-context.sh, whose session-start message
# points here.
hook_removed() {
  local n before='(^|[^A-Za-z0-9._-])' after='($|[^A-Za-z0-9._-]|[.]($|[^A-Za-z0-9_-]))'
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    if grep -aqE -- "$before${n//./[.]}$after" "$1" 2>/dev/null; then printf '%s' "$n"; return 0; fi
  done <<< "$2"
  return 0
}

# move_aside <hook> <reason>: keeps the hook as <hook>.odeo-old-<time>-<pid> next to it. A moved
# link stays a link, and an existing file of that name is never overwritten.
STAMP="$(date +%Y%m%d%H%M%S)-$$"
move_aside() {
  local to="$hooks_dir/$1.odeo-old-$STAMP"
  if [ -e "$to" ] || [ -L "$to" ]; then
    echo "install-git-guards: $to already exists; not overwriting it." >&2; exit 1
  fi
  mv "$hooks_dir/$1" "$to"
  echo "install-git-guards: moved the old $1 aside to $to ($2). Nothing was deleted."
}

# The new hook is written beside the old one first, so the old one can be compared and kept.
new_hook="$hooks_dir/pre-commit.odeo-new-$$"
trap 'rm -f "$new_hook"' EXIT
{ hook_preamble; cat <<'HOOK'
# Enforced guardrail: staged secrets block the commit (secret-scan.sh).
scan="$(odeo_tool secret-scan.sh)"
if [ -n "$scan" ]; then
  "$scan" || exit 1
else
  echo "pre-commit WARNING: secret-scan.sh not found, committing WITHOUT the secret gate." >&2
  echo "Reinstall the Odeo plugin to restore the guardrail." >&2
fi
exit 0
HOOK
} > "$new_hook"
chmod +x "$new_hook"

# keep what is replaced: any pre-commit that differs from the new one, a symlink always
if [ -L "$hooks_dir/pre-commit" ] || { [ -e "$hooks_dir/pre-commit" ] && ! cmp -s "$hooks_dir/pre-commit" "$new_hook"; }; then
  move_aside pre-commit "it differs from the secret-scan hook installed now; merge any checks of your own back in by hand"
fi
mv "$new_hook" "$hooks_dir/pre-commit"

# a pre-push that mentions a removed script no longer runs the check it was written for
if [ -e "$hooks_dir/pre-push" ] || [ -L "$hooks_dir/pre-push" ]; then
  if [ ! -f "$REMOVED_LIST" ]; then
    echo "install-git-guards: could not check pre-push for removed scripts ($REMOVED_LIST not found); it was left in place."
  else
    hit="$(hook_removed "$hooks_dir/pre-push" "$(removed_scripts)")"
    [ -z "$hit" ] || move_aside pre-push "it mentions $hit, which this Odeo release no longer ships"
  fi
fi

echo "install-git-guards: pre-commit (secret scan) installed."
