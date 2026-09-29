#!/usr/bin/env bash
#
# install-git-guards.sh, installs the enforced git hooks into the CURRENT repo.
#
#   pre-push   : refuses a direct push to main/master (except the push that creates it on
#                a remote without it), AND, in a repository that publishes through a
#                snapshot, (contract A) refuses any push to the public remote unless
#                CLAUDE_PUBLISH_SNAPSHOT=1
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
# A project that publishes through a snapshot (it carries docs/internal-paths.txt) is marked
# in its repo config, so the pre-push hook's contract A holds whatever the checkout looks like.
if [ -f "$(git rev-parse --show-toplevel 2>/dev/null)/docs/internal-paths.txt" ]; then
  git config odeo.publishesSnapshot true
fi
mkdir -p "$hooks_dir"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# hook_preamble: the shebang plus odeo_tool, shared by both hooks. Git runs hooks from
# the user's own terminal too, where a plugin's programs are NOT on PATH, and a copied
# plugin lives in a per-version cache directory that an update replaces. So a tool is
# looked up: PATH, then the newest cached Odeo version (in CLAUDE_CONFIG_DIR, the config
# dir at install time, and ~/.claude, since a user may run Claude with CLAUDE_CONFIG_DIR
# while git runs from a shell without it), then the directory these hooks were installed
# from (baked in; stable for a plugin loaded in place from a clone). Never a path relative
# to the repo: a project's own scripts/secret-scan.sh would then stand in for Odeo's gate
# and silence the missing-gate warning. Each cache is searched as scripts/ first and bin/
# second: bin/ is the 0.2.x layout, kept only so a hook written now still works against an
# old cached version (so after a downgrade to 0.2.x, a newer cached scripts/ still wins).
# Limit: with CLAUDE_CODE_SUBPROCESS_ENV_SCRUB set, CLAUDE_CONFIG_DIR may not reach this
# installer, so the baked config dir falls back to ~/.claude; the install-time directory
# still works until an update sweeps that version.
hook_preamble() {
  echo '#!/usr/bin/env bash'
  printf 'ODEO_BIN_AT_INSTALL=%q\n' "$SCRIPT_DIR"
  printf 'ODEO_CONFIG_AT_INSTALL=%q\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  cat <<'PREAMBLE'
odeo_tool() { # odeo_tool <name>: prints the path of an Odeo script, nothing if not found
  local name="$1" c
  c="$(command -v "$name" 2>/dev/null || true)"
  [ -n "$c" ] && [ -x "$c" ] && { printf '%s' "$c"; return 0; }
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
# Enforced guardrails:
#   (1) no direct push to main/master (any remote), with ONE exception: the push that
#       CREATES main/master on a remote that has none (git reports the remote sha as all
#       zeros). That is how a new project seeds its empty GitHub repo; without it a new
#       project could never get the main a PR merges into. Deleting it is not creating it.
#   (2) PUSH CONTRACT A (only in a project that publishes through a snapshot, see
#       contract_a below): the working repo is NEVER pushed to the PUBLIC remote;
#       the public repo is published only from a clean snapshot (publish-snapshot.sh).
#       So any push to the public remote is refused unless CLAUDE_PUBLISH_SNAPSHOT=1
#       (set only by publish-snapshot.sh), and even then the pushed tree is re-scanned
#       for internal paths (defense-in-depth, fail closed). This covers every ref-shape
#       (branch, force, tag, multi-ref) at once, since it keys off the remote, not the ref.
set -uo pipefail
remote_name="${1:-}"
public_remote="${CLAUDE_PUBLIC_REMOTE:-origin}"
# Contract A belongs to a REPOSITORY that publishes through a snapshot, not to whatever its
# working tree looks like at push time. install-git-guards.sh records that as the repo
# config odeo.publishesSnapshot (the shared git dir, so every worktree and a bare clone see
# it), and nothing in a checkout can switch it off: a sparse checkout, a deleted
# docs/internal-paths.txt, an old commit without it, or GIT_DIR from outside once did.
# The file in the working tree, and an explicit CLAUDE_PUBLIC_REMOTE, can only switch it ON.
# Every other project, including everything init-project.sh scaffolds, pushes to its own
# origin normally: before this scoping, every Odeo project refused every push to origin.
contract_a=0
# git's own boolean parser decides, and only two outcomes mean off: the key is unset
# (exit 1) or git reads it as false. Everything else, including a value git cannot parse
# (exit 128, e.g. a typo) and a bare key without '=' (true to git), keeps the guard on.
# Re-parsing the raw string ourselves missed a new spelling each review round.
mark="$(git config --bool --get odeo.publishesSnapshot 2>/dev/null)"; mark_rc=$?
if [ "$mark_rc" -ne 1 ] && [ "$mark" != "false" ]; then contract_a=1; fi
[ -n "${CLAUDE_PUBLIC_REMOTE:-}" ] && contract_a=1
project_top="$(git rev-parse --show-toplevel 2>/dev/null || true)"
# Seeing the list makes the mark STICKY (written once, in the shared git config), so a repo
# that gained it after install stays guarded when a later checkout lacks it.
if [ -n "$project_top" ] && [ -f "$project_top/docs/internal-paths.txt" ]; then
  contract_a=1
  git config odeo.publishesSnapshot true 2>/dev/null || true
fi

guard="$(odeo_tool publish-guard.sh)"

zero_sha=0000000000000000000000000000000000000000
while read -r _local_ref local_sha remote_ref remote_sha; do
  case "$remote_ref" in
    refs/heads/main|refs/heads/master)
      if [ "$remote_sha" = "$zero_sha" ] && [ "$local_sha" != "$zero_sha" ]; then
        echo "pre-push: creating ${remote_ref#refs/heads/} on a remote that has none (one-time seed); later pushes to it are refused." >&2
      else
      echo "pre-push: REFUSED, direct push to ${remote_ref#refs/heads/} is blocked." >&2
      echo "Work on a branch and integrate through /odeo:merge (PR + your approval)." >&2
      exit 1
      fi ;;
  esac
  # The PUSHED commit can carry the list while the checkout does not (an unmarked repo that
  # gained it in a commit, then checked out an older one): that also marks and guards.
  if [ "$contract_a" = 0 ] && [ "$local_sha" != "$zero_sha" ] \
     && git cat-file -e "$local_sha:docs/internal-paths.txt" 2>/dev/null; then
    contract_a=1
    git config odeo.publishesSnapshot true 2>/dev/null || true
  fi
  if [ "$contract_a" = 1 ] && [ "$remote_name" = "$public_remote" ]; then
    if [ "${CLAUDE_PUBLISH_SNAPSHOT:-}" != "1" ]; then
      echo "pre-push: REFUSED, the working repo is never pushed to '$public_remote'." >&2
      echo "Publish via scripts/publish-snapshot.sh; raw pushes to the public remote are blocked (contract A)." >&2
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

if [ "$(git config --bool --get odeo.publishesSnapshot 2>/dev/null)" = "true" ]; then
  echo "install-git-guards: pre-push (no direct main + contract A public-remote guard) + pre-commit (secret scan) installed."
else
  echo "install-git-guards: pre-push (no direct main) + pre-commit (secret scan) installed; contract A switches on if this repo gains docs/internal-paths.txt."
fi
