#!/usr/bin/env bash
#
# install.sh, Install Claude Cofounder onto this machine.
#
# Copies (or symlinks) the system into the locations Claude Code reads:
#   ~/.claude/CLAUDE.md                  global baseline instructions
#   ~/.claude-templates/                 project templates + presets
#   ~/.claude/skills/                    user-level skills (e.g. TDD)
#   ~/bin/init-project.sh                project scaffolder
#
# Usage:
#   ./install.sh           copy files (robust; re-run after `git pull` to update)
#   ./install.sh --link    symlink instead of copy (live: `git pull` = updated)
#
# Safe to re-run. It will NOT overwrite an existing ~/.claude/CLAUDE.md.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINK=false
[[ "${1:-}" == "--link" ]] && LINK=true

place() { # place <src> <dest>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if $LINK; then ln -s "$src" "$dest"; else cp -R "$src" "$dest"; fi
}

echo "Installing Claude Cofounder from: $REPO_DIR"
[[ "$LINK" == true ]] && echo "  (symlink mode, git pull will update live)"

# 1. Templates (organized into agents/ commands/ tasks/ docs/ presets/)
echo "  → templates → ~/.claude-templates/"
rm -rf ~/.claude-templates
if $LINK; then
  ln -s "$REPO_DIR/project-templates" ~/.claude-templates
else
  cp -R "$REPO_DIR/project-templates" ~/.claude-templates
fi

# 2. User-level skills
echo "  → skills → ~/.claude/skills/"
mkdir -p ~/.claude/skills
for skill in "$REPO_DIR"/skills/*/; do
  [[ -d "$skill" ]] && place "$skill" ~/.claude/skills/"$(basename "$skill")"
done

# 3. Project scaffolder + privacy guard
echo "  → init-project.sh → ~/bin/"
place "$REPO_DIR/bin/init-project.sh" ~/bin/init-project.sh
chmod +x ~/bin/init-project.sh 2>/dev/null || true
echo "  → privacy-scan.sh → ~/bin/"
place "$REPO_DIR/bin/privacy-scan.sh" ~/bin/privacy-scan.sh
chmod +x ~/bin/privacy-scan.sh 2>/dev/null || true

# 3b. Privacy deny-list (your own private terms; gitignored by living in ~/.claude)
#     Never overwrite an existing one. Seed a commented sample so it is discoverable.
if [[ ! -f ~/.claude/privacy-denylist.txt ]]; then
  echo "  → privacy deny-list sample → ~/.claude/privacy-denylist.txt"
  mkdir -p ~/.claude
  cat > ~/.claude/privacy-denylist.txt <<'DENY'
# Privacy deny-list, one term per line. privacy-scan.sh blocks any of these from
# being published (e.g. via /contribute-lesson). Case-insensitive. '#' = comment.
# Add YOUR private terms: employer name, internal product/tool names, etc.
# This file lives in ~/.claude and is never committed to any repo.
#
# Examples (delete and replace with your own):
# my-employer-name
# internal-product-codename
DENY
fi

# 4. Global baseline, never clobber an existing personal global
echo "  → global baseline → ~/.claude/CLAUDE.md"
mkdir -p ~/.claude
if [[ -e ~/.claude/CLAUDE.md ]]; then
  cp "$REPO_DIR/global/CLAUDE.md" ~/.claude/claude-cofounder-baseline.md
  echo "    ! ~/.claude/CLAUDE.md already exists, left untouched."
  echo "      Baseline saved to ~/.claude/claude-cofounder-baseline.md, merge what you want."
else
  cp "$REPO_DIR/global/CLAUDE.md" ~/.claude/CLAUDE.md
fi

# 4b. Community knowledge base (shared, read-only secondary source)
#     Pulled into ~/.claude/community-knowledge so Claude can consult it alongside
#     each project's local knowledge/. Opt-in by nature: contribute with
#     /contribute-lesson. Graceful if the repo is not reachable yet.
COMMUNITY_KNOWLEDGE_REPO="${COMMUNITY_KNOWLEDGE_REPO:-https://github.com/ivansolic/claude-cofounder-knowledge.git}"
COMMUNITY_DIR="$HOME/.claude/community-knowledge"
echo "  → community knowledge → $COMMUNITY_DIR"
if [[ -d "$COMMUNITY_DIR/.git" ]]; then
  git -C "$COMMUNITY_DIR" pull --ff-only -q 2>/dev/null \
    && echo "    refreshed." \
    || echo "    ! could not refresh (offline?), kept the existing copy."
else
  if git clone -q "$COMMUNITY_KNOWLEDGE_REPO" "$COMMUNITY_DIR" 2>/dev/null; then
    echo "    cloned."
  else
    echo "    ! community knowledge repo not reachable yet, skipped (set up later)."
    echo "      It will populate on the next install.sh once the repo is published."
  fi
fi

# 5. Shell profile, PATH + auto-verify (idempotent)
PROFILE="$HOME/.bash_profile"; [[ "${SHELL:-}" == *zsh* ]] && PROFILE="$HOME/.zshrc"
echo "  → shell profile → $PROFILE"
grep -q 'HOME/bin' "$PROFILE" 2>/dev/null || echo 'export PATH="$HOME/bin:$PATH"' >> "$PROFILE"
grep -q 'CLAUDE_CODE_AUTO_VERIFY' "$PROFILE" 2>/dev/null || echo 'export CLAUDE_CODE_AUTO_VERIFY=1' >> "$PROFILE"

cat <<'DONE'

✅ Claude Cofounder installed.

ONE more step, install the PM skills (these are a separate plugin you fetch
once; you always get the maintained version). Start Claude, then paste:

  /plugin marketplace add phuryn/pm-skills
  /plugin install pm-execution@pm-skills
  /plugin install pm-product-discovery@pm-skills
  /plugin install pm-product-strategy@pm-skills
  /plugin install pm-market-research@pm-skills
  /plugin install pm-data-analytics@pm-skills
  /plugin install pm-marketing-growth@pm-skills
  /plugin install pm-go-to-market@pm-skills
  /plugin install pm-toolkit@pm-skills
  /reload-plugins

Then reload your shell:  source ~/.bash_profile   (or ~/.zshrc)

Start a project:  init-project.sh my-app && cd my-app && claude
Inside Claude:    /setup-project

Full guide: INSTALL.md   ·   Concepts: BEGINNERS-GUIDE.md   ·   Daily use: WORKFLOW.md
DONE
