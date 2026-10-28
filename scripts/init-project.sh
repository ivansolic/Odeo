#!/usr/bin/env bash
#
# init-project.sh, initialize a new Claude-ready project.
#
# Scaffolds only the PROJECT-SPECIFIC parts (CLAUDE.md, docs/, tasks/). The skills and
# agents come from the installed Odeo plugin, so they are available in every project automatically,
# no per-project copies to drift.
#
# Usage:
#   init-project.sh <project-name> [--language <code>]
#
# --ui and --no-ui are still accepted and do nothing (callers written before the design
# layer left the plugin pass them).
#
# Templates come from the plugin's own project-templates/, next to this script's scripts/
# (the layout Claude Code copies into the plugin cache). CLAUDE_TEMPLATES_DIR overrides.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$SCRIPT_DIR/../project-templates}"
PROJECT_NAME=""
LANGUAGE=""        # empty = ask interactively or use the en default

# The while/case/shift form is required to consume the value token of a
# two-token flag like --language <code>. A for-arg loop cannot do that because
# it has no mechanism to advance past the value to the next argument.
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-ui|--no-design|--ui) shift ;;   # accepted, no effect: the design layer left the plugin
    --language) [ "$#" -ge 2 ] || { echo "--language needs a value (en|de|hr|fr)" >&2; exit 1; }
                LANGUAGE="$2"; shift 2 ;;
    -*)         echo "Unknown option: $1" >&2; exit 1 ;;
    *)          [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$1"; shift ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: init-project.sh <project-name> [--language <code>]"
  echo ""
  echo "Example: init-project.sh my-startup"
  exit 1
fi

# The name becomes a directory here and a repo name later, and /odeo:new-project passes user
# text straight in, so it is allowlisted: a letter or digit first, then letters, digits,
# dot, underscore, hyphen. That rules out paths (/, ..), hidden dirs, spaces and shell text.
if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$ ]]; then
  echo "Error: invalid project name '$PROJECT_NAME'."
  echo "Use letters, digits, '.', '_' or '-', starting with a letter or digit (e.g. my-app)."
  exit 1
fi

if [[ -e "$PROJECT_NAME" ]]; then
  echo "Error: '$PROJECT_NAME' already exists in this directory."
  exit 1
fi

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR"
  echo "Reinstall the Odeo plugin (see README, Installation)."
  exit 1
fi

# Project-specific templates only. Commands/agents/skills ship via the plugin.
REQUIRED_TEMPLATES=(
  "CLAUDE.md"
  "tasks/todo.md"
  "tasks/lessons.md"
  "docs/ADR-TEMPLATE.md"
)

MISSING=()
for template in "${REQUIRED_TEMPLATES[@]}"; do
  if [[ ! -f "$TEMPLATES_DIR/$template" ]]; then
    MISSING+=("$template")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Error: Missing templates in $TEMPLATES_DIR:"
  for t in "${MISSING[@]}"; do
    echo "  - $t"
  done
  exit 1
fi

# Validate any explicitly provided language code before touching the filesystem.
# An invalid explicit flag is a programmer error; fail fast before any mkdir.
if [[ -n "$LANGUAGE" ]]; then
  case "$LANGUAGE" in
    en|de|hr|fr) ;;
    *) echo "Unknown language: $LANGUAGE (allowed: en de hr fr)" >&2; exit 1 ;;
  esac
fi

# Resolve the output language. A flag value was already validated above.
# In interactive mode, ask once with a short menu (Enter skips to English).
# In non-interactive mode, the safe default is English.
if [[ -z "$LANGUAGE" ]]; then
  if [[ -t 0 ]]; then
    echo ""
    echo "  Output language for generated docs (PRDs, stories, plans, reviews)."
    echo "  Code and mechanics always stay English."
    read -r -p "  Language? [E]nglish (default) / [d]e German / [h]r Croatian / [f]r French: " _lang_ans || _lang_ans=""
    case "$_lang_ans" in
      [Dd]*) LANGUAGE=de ;;
      [Hh]*) LANGUAGE=hr ;;
      [Ff]*) LANGUAGE=fr ;;
      *)     LANGUAGE=en ;;   # Enter/skip/English -> en
    esac
  else
    LANGUAGE=en   # non-interactive default
  fi
fi

echo "Creating project: $PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "  → initializing git"
git init -q

# Identity sanity check: machine-generated emails (user@Host.something.ip/.local)
# silently brand every commit, and on a work machine they can embed the employer.
_git_email="$(git config user.email 2>/dev/null || true)"
if [[ -z "$_git_email" ]] || [[ "$_git_email" =~ @.*\.(local|lan|ip)$ ]]; then
  echo ""
  echo "  ⚠ git user.email is '${_git_email:-unset}', which looks machine-generated."
  echo "    Every commit in this project would carry it (including pushes to GitHub)."
  if [[ -t 0 ]]; then
    read -r -p "    Enter the email to use for this project (or press Enter to keep as is): " _ans_email || _ans_email=""
    if [[ -n "$_ans_email" ]]; then
      git config user.email "$_ans_email"
      echo "    → set for this project. (Set it globally with: git config --global user.email $_ans_email)"
    fi
  else
    echo "    Fix it with: git config --global user.email you@example.com"
  fi
  echo ""
fi

git commit --allow-empty -m "chore: initial commit" -q
git branch -M main

echo "  → installing git guards (secret scan on commit)"
# Only the installer shipped next to this script, never one from PATH, where the user's
# environment can hold a script of the same name.
if [[ -x "$SCRIPT_DIR/install-git-guards.sh" ]]; then
  "$SCRIPT_DIR/install-git-guards.sh" >/dev/null
else
  echo "    ! install-git-guards.sh not found, hooks skipped (run it later)"
fi

echo "  → creating folder structure"
mkdir -p .claude/tasks
mkdir -p docs/prds docs/stories docs/decisions docs/research docs/templates docs/evals docs/plans

echo "  → copying project templates"
cp "$TEMPLATES_DIR/CLAUDE.md" CLAUDE.md
cp "$TEMPLATES_DIR/tasks/todo.md" .claude/tasks/todo.md
cp "$TEMPLATES_DIR/tasks/lessons.md" .claude/tasks/lessons.md
cp "$TEMPLATES_DIR/docs/ADR-TEMPLATE.md" docs/templates/ADR-TEMPLATE.md

# Curated permission allowlist: read-only git, test/lint/typecheck/build, and
# editor reveals run without a prompt; everything else still asks. Cuts prompt
# fatigue without touching the security posture (no bypass, no broad grants).
if [[ -f "$TEMPLATES_DIR/claude-settings.json" ]]; then
  echo "  → seeding .claude/settings.json (safe-command allowlist)"
  cp "$TEMPLATES_DIR/claude-settings.json" .claude/settings.json
fi

# Persist the chosen output language as the canonical single line.
# Machine surfaces stay English; this only tells generators which language
# to write user-facing prose in (resolved by scripts/resolve-language.sh).
# Both branches use mktemp + mv for consistency (arch-review IMPORTANT-2);
# under init-project.sh's `set -e`, a failed awk/sed aborts before mv, so no
# half-written CLAUDE.md.new is ever left in the scaffold for `git add -A`.
if grep -qE '^output_language:' CLAUDE.md; then
  tmp_claude="$(mktemp)"
  sed -E "s/^output_language:.*/output_language: ${LANGUAGE}/" CLAUDE.md > "$tmp_claude"
  mv "$tmp_claude" CLAUDE.md
elif grep -qE '^## Conventions' CLAUDE.md; then
  tmp_claude="$(mktemp)"
  awk -v line="output_language: ${LANGUAGE}" '
    { print }
    /^## Conventions/ && !done { print ""; print line; done=1 }
  ' CLAUDE.md > "$tmp_claude"
  mv "$tmp_claude" CLAUDE.md
else
  printf '\noutput_language: %s\n' "${LANGUAGE}" >> CLAUDE.md
fi

echo "  → writing .gitignore"
cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
.pnpm-store/

# Environment (NEVER commit)
.env
.env.local
.env.*.local

# Build artifacts
dist/
build/
.angular/
tmp/

# Coverage
coverage/
.nyc_output/

# IDE
.vscode/*
!.vscode/extensions.json
.idea/

# Claude local-only files
CLAUDE.local.md
.claude/local/

# The build ledger. Deliberately NOT committed: todo.md carries session state and lessons.md
# every correction this project has learned, and both would otherwise ride along into any
# published snapshot. Git therefore does not back them up either, which is what
# `ledger-backup.sh` and the `ledger_backup:` line in CLAUDE.md exist for.
.claude/tasks/todo.md
.claude/tasks/lessons.md

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
pnpm-debug.log*
GITIGNORE

git add -A
git commit -m "chore: scaffold Claude-ready project structure" -q

echo ""
echo "✅ Project '$PROJECT_NAME' initialized."
echo ""
echo "Structure (project-specific files; skills and agents come from the plugin):"
echo "  $PROJECT_NAME/"
echo "  ├── CLAUDE.md            (project config: stack, commands, conventions, Security & Data)"
echo "  ├── .claude/tasks/       (todo.md, lessons.md)"
echo "  └── docs/                (prds, stories, decisions, research, templates)"
echo ""
echo "Available everywhere from the Odeo plugin:"
echo "  PM:       /odeo:brainstorm /odeo:prd /odeo:critique /odeo:stories /odeo:prioritize /odeo:roadmap ... (full set:"
echo "            discovery, strategy, planning, metrics, launch, see the system map)"
echo "  learning: /odeo:retro /odeo:outcome /odeo:product-signal /odeo:improve"
echo "  navigate: /odeo:start (where am I + what's next)  ·  or just ask \"how do I...\" (/odeo:guide)"
echo "  writing:  ux-writing (applies automatically to interface text)"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  gh repo create $PROJECT_NAME --private --source=. --remote=origin --push"
echo "  git remote set-head origin -a    (one-time; lets tools resolve origin/HEAD,"
echo "                                    e.g. the built-in /security-review needs it)"
echo "  claude"
echo ""
echo "Then, first thing inside Claude, configure the project:"
echo "  > /odeo:setup-project   (fills CLAUDE.md for your project)"
echo ""
