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

# 1. Project templates (project-specific scaffolding: CLAUDE.md, tasks, docs, design, knowledge)
echo "  → project templates → ~/.claude-templates/"
rm -rf ~/.claude-templates
if $LINK; then
  ln -s "$REPO_DIR/project-templates" ~/.claude-templates
else
  cp -R "$REPO_DIR/project-templates" ~/.claude-templates
fi

# 2. Skills, user-level (the plugin-equivalent for the GitHub install path).
#    Includes the workflow skills (build, merge, learn, ...) and the auto-apply
#    skills (test-driven-development, ux-design). Available in every project.
echo "  → skills → ~/.claude/skills/"
mkdir -p ~/.claude/skills
for skill in "$REPO_DIR"/skills/*/; do
  [[ -d "$skill" ]] && place "$skill" ~/.claude/skills/"$(basename "$skill")"
done

# 2b. Agents, user-level (architect, builder, analyst, reviewers, debugger). Available everywhere.
rm -f ~/.claude/agents/developer.md   # renamed to builder; remove the stale copy
echo "  → agents → ~/.claude/agents/"
mkdir -p ~/.claude/agents
for agent in "$REPO_DIR"/agents/*.md; do
  [[ -f "$agent" ]] && place "$agent" ~/.claude/agents/"$(basename "$agent")"
done

# 2c. System docs (authoring standard, eval framework, system map), referenced by
#     reviewers and /guide from any project.
echo "  → system docs → ~/.claude/claude-cofounder-docs/"
mkdir -p ~/.claude/claude-cofounder-docs
for doc in "$REPO_DIR"/docs/*.md; do
  [[ -f "$doc" ]] && place "$doc" ~/.claude/claude-cofounder-docs/"$(basename "$doc")"
done
mkdir -p ~/.claude/claude-cofounder-docs/checklists
for doc in "$REPO_DIR"/docs/checklists/*.md; do
  [[ -f "$doc" ]] && place "$doc" ~/.claude/claude-cofounder-docs/checklists/"$(basename "$doc")"
done

# 3. Scaffolder + guard scripts (all of bin/: init-project, privacy-scan,
#    secret-scan, boundary-check, merge-gate, install-git-guards)
echo "  → bin scripts → ~/bin/"
for script in "$REPO_DIR"/bin/*.sh; do
  [[ -f "$script" ]] || continue
  place "$script" ~/bin/"$(basename "$script")"
  chmod +x ~/bin/"$(basename "$script")" 2>/dev/null || true
done

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

✅ Claude Cofounder installed (commands, agents, skills, and the PM skills).

Reload your shell:  source ~/.bash_profile   (or ~/.zshrc)

Start a project:  init-project.sh my-app && cd my-app && claude
Inside Claude:    /setup-project   then  /brainstorm  or  /prd

The PM phase uses our first-party skills (/brainstorm /prd /critique /stories ...).
NOTE: if a third-party PM plugin is installed alongside, plain-language
requests can route to either set (a mixed system). For the single-system
experience, open /plugin in a Claude session and uninstall other PM packages
(INSTALL.md Step 7).

Full guide: INSTALL.md   ·   Concepts: BEGINNERS-GUIDE.md   ·   Daily use: WORKFLOW.md
DONE
