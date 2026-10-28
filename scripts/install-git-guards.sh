#!/usr/bin/env bash
#
# install-git-guards.sh, installs the enforced git hooks into the CURRENT repo.
#
#   pre-commit : runs secret-scan.sh over the staged changes; secrets block commit
#
# It writes NO pre-push hook: the push guard is not installed into users' projects (PRD-002
# R4). This repository's own push guard is written by .claude/maintainer/install-git-guards.sh.
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
} > "$hooks_dir/pre-commit"
chmod +x "$hooks_dir/pre-commit"

echo "install-git-guards: pre-commit (secret scan) installed."
