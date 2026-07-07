#!/usr/bin/env bash
#
# install-git-guards.sh, installs the enforced git hooks into the CURRENT repo.
#
#   pre-push   : physically refuses a direct push to main/master
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
# Enforced guardrail: no direct pushes to main/master. Use a branch + /merge.
while read -r _local_ref _local_sha remote_ref _remote_sha; do
  case "$remote_ref" in
    refs/heads/main|refs/heads/master)
      echo "pre-push: REFUSED, direct push to ${remote_ref#refs/heads/} is blocked." >&2
      echo "Work on a branch and integrate through /merge (PR + your approval)." >&2
      exit 1 ;;
  esac
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
  echo "Install it (claude-cofounder install.sh) to restore the guardrail." >&2
fi
exit 0
HOOK
chmod +x "$hooks_dir/pre-commit"

echo "install-git-guards: pre-push (no direct main) + pre-commit (secret scan) installed."
