#!/usr/bin/env bash
#
# install-git-guards.sh, installs the enforced git hooks into the CURRENT repo.
#
#   pre-push   : refuses a direct push to main/master, AND (contract A) refuses any
#                push to the public remote unless CLAUDE_PUBLISH_SNAPSHOT=1
#   pre-commit : runs secret-scan.sh over the staged changes; secrets block commit
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

# hook_preamble: the shebang plus odeo_tool, shared by both hooks. Git runs hooks from
# the user's own terminal too, where a plugin's bin/ is NOT on PATH (Claude Code adds it to
# the Bash tool only), and a copied plugin lives in a per-version cache directory that an
# update replaces. So a tool is looked up: PATH, then the newest cached Odeo version (in
# CLAUDE_CONFIG_DIR, the config dir at install time, and ~/.claude, since a user may run
# Claude with CLAUDE_CONFIG_DIR while git runs from a shell without it), then the
# directory these hooks were installed from (baked in; stable for a plugin loaded in place
# from a clone), then the repo's own bin/. Limit: with CLAUDE_CODE_SUBPROCESS_ENV_SCRUB set,
# CLAUDE_CONFIG_DIR may not reach this installer, so the baked config dir falls back to
# ~/.claude; the install-time bin dir still works until an update sweeps that version.
hook_preamble() {
  echo '#!/usr/bin/env bash'
  printf 'ODEO_BIN_AT_INSTALL=%q\n' "$SCRIPT_DIR"
  printf 'ODEO_CONFIG_AT_INSTALL=%q\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  cat <<'PREAMBLE'
odeo_tool() { # odeo_tool <name>: prints the path of an Odeo script, nothing if not found
  local name="$1" c
  c="$(command -v "$name" 2>/dev/null || true)"
  [ -n "$c" ] && [ -x "$c" ] && { printf '%s' "$c"; return 0; }
  # newest first: after an update the old version stays in the cache for a grace period
  while IFS= read -r c; do
    [ -x "$c/$name" ] && { printf '%s' "$c/$name"; return 0; }
  done < <(ls -1td "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/odeo/*/bin \
                   "$ODEO_CONFIG_AT_INSTALL"/plugins/cache/*/odeo/*/bin \
                   "$HOME"/.claude/plugins/cache/*/odeo/*/bin 2>/dev/null)
  for c in "$ODEO_BIN_AT_INSTALL" "bin"; do
    [ -x "$c/$name" ] && { printf '%s' "$c/$name"; return 0; }
  done
  return 0
}
PREAMBLE
}

{ hook_preamble; cat <<'HOOK'
# Enforced guardrails:
#   (1) no direct push to main/master (any remote)
#   (2) PUSH CONTRACT A: the working repo is NEVER pushed to the PUBLIC remote;
#       the public repo is published only from a clean snapshot (publish-snapshot.sh).
#       So any push to the public remote is refused unless CLAUDE_PUBLISH_SNAPSHOT=1
#       (set only by publish-snapshot.sh), and even then the pushed tree is re-scanned
#       for internal paths (defense-in-depth, fail closed). This covers every ref-shape
#       (branch, force, tag, multi-ref) at once, since it keys off the remote, not the ref.
set -uo pipefail
remote_name="${1:-}"
public_remote="${CLAUDE_PUBLIC_REMOTE:-origin}"

guard="$(odeo_tool publish-guard.sh)"

while read -r _local_ref local_sha remote_ref _remote_sha; do
  case "$remote_ref" in
    refs/heads/main|refs/heads/master)
      echo "pre-push: REFUSED, direct push to ${remote_ref#refs/heads/} is blocked." >&2
      echo "Work on a branch and integrate through /merge (PR + your approval)." >&2
      exit 1 ;;
  esac
  if [ "$remote_name" = "$public_remote" ]; then
    if [ "${CLAUDE_PUBLISH_SNAPSHOT:-}" != "1" ]; then
      echo "pre-push: REFUSED, the working repo is never pushed to '$public_remote'." >&2
      echo "Publish via bin/publish-snapshot.sh; raw pushes to the public remote are blocked (contract A)." >&2
      exit 1
    fi
    # marker set (publish-snapshot.sh): defense-in-depth. Skip deletions (all-zero sha).
    case "$local_sha" in
      0000000000000000000000000000000000000000) continue ;;
    esac
    if [ -z "$guard" ]; then
      echo "pre-push: REFUSED, publish-guard.sh not found for the public-remote safety check." >&2
      exit 1
    fi
    git ls-tree -r -z --name-only "$local_sha" | "$guard" -
    pst=( "${PIPESTATUS[@]}" ); lst=${pst[0]}; gst=${pst[1]}
    if [ "$lst" -ne 0 ]; then
      echo "pre-push: REFUSED, could not enumerate the pushed tree for '$public_remote' (fail closed)." >&2
      exit 1
    fi
    if [ "$gst" -ne 0 ]; then
      echo "pre-push: REFUSED, an internal path is present in the tree pushed to '$public_remote'." >&2
      exit 1
    fi
  fi
done
exit 0
HOOK
} > "$hooks_dir/pre-push"
chmod +x "$hooks_dir/pre-push"

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

echo "install-git-guards: pre-push (no direct main + contract A public-remote guard) + pre-commit (secret scan) installed."
