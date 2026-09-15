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

cat > "$hooks_dir/pre-push" <<'HOOK'
#!/usr/bin/env bash
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

guard=""
for c in "$(command -v publish-guard.sh 2>/dev/null || true)" "$HOME/bin/publish-guard.sh" "bin/publish-guard.sh"; do
  [ -n "$c" ] && [ -x "$c" ] && { guard="$c"; break; }
done

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
chmod +x "$hooks_dir/pre-push"

cat > "$hooks_dir/pre-commit" <<'HOOK'
#!/usr/bin/env bash
# Enforced guardrail: staged secrets block the commit (secret-scan.sh).
scan="$(command -v secret-scan.sh || true)"
[ -z "$scan" ] && [ -x "$HOME/bin/secret-scan.sh" ] && scan="$HOME/bin/secret-scan.sh"
[ -z "$scan" ] && [ -x "bin/secret-scan.sh" ] && scan="bin/secret-scan.sh"
if [ -n "$scan" ]; then
  "$scan" || exit 1
else
  echo "pre-commit WARNING: secret-scan.sh not found, committing WITHOUT the secret gate." >&2
  echo "Install it (Odeo install.sh) to restore the guardrail." >&2
fi
exit 0
HOOK
chmod +x "$hooks_dir/pre-commit"

echo "install-git-guards: pre-push (no direct main + contract A public-remote guard) + pre-commit (secret scan) installed."
