#!/usr/bin/env bash
#
# install.sh, Install Odeo onto this machine.
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
INSTALL_LANG="${ODEO_INSTALL_LANG:-}"   # optional non-interactive global-language default (en|de|hr|fr)
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --link) LINK=true; shift ;;
    --lang) [[ "$#" -ge 2 ]] || { echo "--lang needs a value (en|de|hr|fr)" >&2; exit 1; }
            INSTALL_LANG="$2"; shift 2 ;;
    *) echo "install: unknown option: $1 (use --link and/or --lang <code>)" >&2; exit 1 ;;
  esac
done

place() { # place <src> <dest>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if $LINK; then ln -s "$src" "$dest"; else cp -R "$src" "$dest"; fi
}

echo "Installing Odeo from: $REPO_DIR"
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
echo "  → system docs → ~/.claude/odeo-docs/"
mkdir -p ~/.claude/odeo-docs
for doc in "$REPO_DIR"/docs/*.md; do
  [[ -f "$doc" ]] && place "$doc" ~/.claude/odeo-docs/"$(basename "$doc")"
done
mkdir -p ~/.claude/odeo-docs/checklists
for doc in "$REPO_DIR"/docs/checklists/*.md; do
  [[ -f "$doc" ]] && place "$doc" ~/.claude/odeo-docs/checklists/"$(basename "$doc")"
done

# 3. Scaffolder + guard scripts: EVERY program in bin/, not just *.sh. The glob used
#    to be *.sh, which silently skipped bin/token-report.py while this comment claimed
#    "all of bin/", so a user following the docs got "command not found".
#    Selection is by SHEBANG, not by the exec bit: a checkout that lost its exec bits
#    (the Windows case .gitattributes already guards against) would make an exec-bit
#    test install NOTHING and still exit 0, which is the same silent-skip defect this
#    loop exists to kill, widened from one file to all of them.
#    TWO guards, because a selection rule can be wrong in two directions and each needs
#    its own backstop: copying ZERO programs can never be a silent success, and SKIPPING
#    any file in bin/ can never be silent either. The second is what makes the promise
#    above ("every program in bin/") enforceable rather than aspirational: a new file
#    that does not look like a program stops the install instead of quietly not shipping.
echo "  → bin scripts → ~/bin/"
# BEGIN bin-install   (tests/install-bin.test.sh extracts exactly this block and runs it;
#                      keep both markers, the test fails LOUD if either one moves)
installed=0
skipped=""
for script in "$REPO_DIR"/bin/*; do
  [[ -f "$script" ]] || continue
  if ! head -c 2 "$script" 2>/dev/null | grep -q '#!'; then
    skipped="$skipped $(basename "$script")"
    continue
  fi
  place "$script" ~/bin/"$(basename "$script")"
  chmod +x ~/bin/"$(basename "$script")" 2>/dev/null || true
  installed=$((installed+1))
done
(( installed > 0 )) || { echo "install: FAILED, no programs found in $REPO_DIR/bin" >&2; exit 1; }
[[ -z "$skipped" ]] || {
  echo "install: FAILED, these files in bin/ carry no shebang and were not installed:$skipped" >&2
  echo "         Add a shebang, or move them out of bin/ if they are not programs." >&2
  exit 1
}
# END bin-install

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
  cp "$REPO_DIR/global/CLAUDE.md" ~/.claude/odeo-baseline.md
  echo "    ! ~/.claude/CLAUDE.md already exists, left untouched."
  echo "      Baseline saved to ~/.claude/odeo-baseline.md, merge what you want."
else
  cp "$REPO_DIR/global/CLAUDE.md" ~/.claude/CLAUDE.md
fi

# 4a. Global output-language default (one-time). Written to the same
#     ~/.claude/CLAUDE.md line that bin/resolve-language.sh reads for the GLOBAL
#     precedence level. Asked EXACTLY ONCE: the writer is idempotent, so a re-run
#     (or a later project setup) never re-prompts, and a skip records English.
#     Machine surfaces stay English regardless of the code stored.
echo "  → global output language (one-time)"
if [[ -L ~/.claude/CLAUDE.md ]]; then
  echo "    ! ~/.claude/CLAUDE.md is a symlink (into the repo); leaving it untouched."
  echo "      Set your language per-project at setup, or edit your own global file."
elif [[ -f ~/.claude/CLAUDE.md ]] && grep -qE '^output_language:' ~/.claude/CLAUDE.md; then
  echo "    already set, leaving it unchanged."
elif [[ -n "$INSTALL_LANG" ]]; then
  "$REPO_DIR/bin/set-global-language.sh" "$INSTALL_LANG" || { echo "    ! invalid --lang '$INSTALL_LANG' (en|de|hr|fr)"; exit 1; }
elif [[ -t 0 ]]; then
  echo ""
  echo "    Language for the docs Odeo generates for you (PRDs, stories, plans, reviews)."
  echo "    Code, comments, filenames, and commit messages always stay English."
  read -r -p "    Language? [E]nglish (default) / [d]e German / [h]r Croatian / [f]r French: " _glang || _glang=""
  case "$_glang" in
    [Dd]*) _code=de ;;
    [Hh]*) _code=hr ;;
    [Ff]*) _code=fr ;;
    *)     _code=en ;;
  esac
  "$REPO_DIR/bin/set-global-language.sh" "$_code" || { echo "    ! could not set language '$_code'"; exit 1; }
else
  # Non-interactive install (CI, piped): default English, never hang on a prompt.
  "$REPO_DIR/bin/set-global-language.sh" en
fi

# 4b. Community knowledge base (shared, read-only secondary source)
#     Pulled into ~/.claude/community-knowledge so Claude can consult it alongside
#     each project's local knowledge/. Opt-in by nature: contribute with
#     /contribute-lesson. Graceful if the repo is not reachable yet.
COMMUNITY_KNOWLEDGE_REPO="${COMMUNITY_KNOWLEDGE_REPO:-https://github.com/ivansolic/Odeo-knowledge.git}"
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

✅ Odeo installed (commands, agents, skills, and the PM skills).

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
