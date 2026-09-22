#!/usr/bin/env bash
#
# init-project.sh, initialize a new Claude-ready project.
#
# Scaffolds only the PROJECT-SPECIFIC parts (CLAUDE.md, docs/, tasks/, knowledge/,
# design/). The commands, agents, and skills come from the installed
# Odeo plugin (or `install.sh`), so they are available in every
# project automatically, no per-project copies to drift.
#
# Usage:
#   init-project.sh <project-name> [--no-ui]
#
# Requires project templates in ~/.claude-templates/ (see INSTALL.md).

set -euo pipefail

TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$HOME/.claude-templates}"
HAS_UI=""          # empty = ask; true/false = set explicitly by a flag
PROJECT_NAME=""
LANGUAGE=""        # empty = ask interactively or use the en default

# The while/case/shift form is required to consume the value token of a
# two-token flag like --language <code>. A for-arg loop cannot do that because
# it has no mechanism to advance past the value to the next argument.
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-ui|--no-design) HAS_UI=false; shift ;;
    --ui)       HAS_UI=true; shift ;;
    --language) [ "$#" -ge 2 ] || { echo "--language needs a value (en|de|hr|fr)" >&2; exit 1; }
                LANGUAGE="$2"; shift 2 ;;
    -*)         echo "Unknown option: $1" >&2; exit 1 ;;
    *)          [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$1"; shift ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: init-project.sh <project-name> [--no-ui]"
  echo ""
  echo "Example: init-project.sh my-startup"
  echo "         init-project.sh my-api --no-ui   (backend-only: skip the design layer)"
  exit 1
fi

if [[ -e "$PROJECT_NAME" ]]; then
  echo "Error: '$PROJECT_NAME' already exists in this directory."
  exit 1
fi

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR"
  echo "Run the system install first (see INSTALL.md)."
  exit 1
fi

# Project-specific templates only. Commands/agents/skills ship via the plugin.
REQUIRED_TEMPLATES=(
  "CLAUDE.md"
  "tasks/todo.md"
  "tasks/lessons.md"
  "docs/ADR-TEMPLATE.md"
  "design/tokens.json"
  "design/README.md"
  "knowledge/README.md"
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

# Resolve whether this project has a UI (controls the design layer)
if [[ -z "$HAS_UI" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "Will this project have a UI? [Y/n] " _ans || _ans=""
    case "$_ans" in [Nn]*) HAS_UI=false ;; *) HAS_UI=true ;; esac
  else
    HAS_UI=true   # non-interactive default: include the design layer
  fi
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

echo "  → installing git guards (no direct push to main; secret scan on commit)"
if command -v install-git-guards.sh >/dev/null 2>&1; then
  install-git-guards.sh >/dev/null
elif [[ -x "$HOME/bin/install-git-guards.sh" ]]; then
  "$HOME/bin/install-git-guards.sh" >/dev/null
else
  echo "    ! install-git-guards.sh not found, hooks skipped (run it later)"
fi

echo "  → creating folder structure"
mkdir -p .claude/tasks
mkdir -p docs/prds docs/stories docs/decisions docs/research docs/templates docs/evals docs/plans
mkdir -p knowledge

echo "  → copying project templates"
cp "$TEMPLATES_DIR/CLAUDE.md" CLAUDE.md
cp "$TEMPLATES_DIR/tasks/todo.md" .claude/tasks/todo.md
cp "$TEMPLATES_DIR/tasks/lessons.md" .claude/tasks/lessons.md
cp "$TEMPLATES_DIR/docs/ADR-TEMPLATE.md" docs/templates/ADR-TEMPLATE.md
cp "$TEMPLATES_DIR/knowledge/README.md" knowledge/README.md

# Curated permission allowlist: read-only git, test/lint/typecheck/build, and
# editor reveals run without a prompt; everything else still asks. Cuts prompt
# fatigue without touching the security posture (no bypass, no broad grants).
if [[ -f "$TEMPLATES_DIR/claude-settings.json" ]]; then
  echo "  → seeding .claude/settings.json (safe-command allowlist)"
  cp "$TEMPLATES_DIR/claude-settings.json" .claude/settings.json
fi

# Design layer (only for UI projects). The design-reviewer agent and /setup-design
# come from the plugin; here we only seed the project's token source of truth.
if $HAS_UI; then
  mkdir -p design
  cp "$TEMPLATES_DIR/design/tokens.json" design/tokens.json
  cp "$TEMPLATES_DIR/design/README.md" design/README.md
fi

# Persist the chosen output language as the canonical single line.
# Machine surfaces stay English; this only tells generators which language
# to write user-facing prose in (resolved by bin/resolve-language.sh).
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
.claude/focus-zone

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
echo "Structure (project-specific files; commands/agents/skills come from the plugin):"
echo "  $PROJECT_NAME/"
echo "  ├── CLAUDE.md            (project config: stack, commands, conventions, Security & Data)"
echo "  ├── .claude/tasks/       (todo.md, lessons.md)"
echo "  ├── knowledge/           (reusable solved problems)"
if $HAS_UI; then echo "  ├── design/              (tokens.json, design system source of truth)"; fi
echo "  └── docs/                (prds, stories, decisions, research, templates)"
echo ""
echo "Available everywhere from the Odeo plugin:"
echo "  build:    /build /merge /ci /commit-push /optimize /worktree-parallel-check"
echo "  PM:       /brainstorm /prd /critique /stories /prioritize /roadmap ... (full set:"
echo "            discovery, strategy, planning, metrics, launch, see the system map)"
echo "  learning: /learn /retro /outcome /knowledge-refresh /product-signal /improve"
echo "  navigate: /start (where am I + what's next)  ·  or just ask \"how do I...\" (/guide)"
echo "  agents:   architect, builder, codebase-analyst + reviewers (code, pm, skill,"
echo "            architecture$( $HAS_UI && echo ', design' )) + debugger"
echo "  auto:     test-driven-development$( $HAS_UI && echo ', ux-design, ux-writing' )"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  gh repo create $PROJECT_NAME --private --source=. --remote=origin --push"
echo "  git remote set-head origin -a    (one-time; lets tools resolve origin/HEAD,"
echo "                                    e.g. the built-in /security-review needs it)"
echo "  claude"
echo ""
echo "Then, first thing inside Claude, configure the project for your stack:"
echo "  > /setup-project   (stack, commands, conventions → fills CLAUDE.md)"
if $HAS_UI; then
  echo "After the PM phase, before building UI, set up the design system:"
  echo "  > /setup-design    (ingest your tokens or generate from PRD/personas → tokens.json)"
fi
echo ""
