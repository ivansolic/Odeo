#!/usr/bin/env bash
#
# init-project.sh, Initialize a new Claude-ready project from your templates
#
# Usage:
#   init-project.sh <project-name>
#
# Requires templates in ~/.claude-templates/ (see INSTALL.md, Step 7)

set -euo pipefail

TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$HOME/.claude-templates}"
HAS_UI=""          # empty = ask; true/false = set explicitly by a flag
PROJECT_NAME=""
for arg in "$@"; do
  case "$arg" in
    --no-ui|--no-design) HAS_UI=false ;;
    --ui) HAS_UI=true ;;
    -*) echo "Unknown option: $arg"; exit 1 ;;
    *) [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$arg" ;;
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
  echo "See INSTALL.md Step 7 for first-time setup."
  exit 1
fi

REQUIRED_TEMPLATES=(
  "CLAUDE.md"
  "tasks/todo.md"
  "tasks/lessons.md"
  "agents/code-reviewer.md"
  "agents/architecture-reviewer.md"
  "agents/design-reviewer.md"
  "commands/commit-push.md"
  "commands/dev-handoff.md"
  "commands/setup-project.md"
  "commands/setup-design.md"
  "commands/retro.md"
  "commands/sprint.md"
  "commands/compound.md"
  "commands/compound-refresh.md"
  "commands/pulse.md"
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

# Resolve whether this project has a UI (controls the design layer)
if [[ -z "$HAS_UI" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "Will this project have a UI? [Y/n] " _ans
    case "$_ans" in [Nn]*) HAS_UI=false ;; *) HAS_UI=true ;; esac
  else
    HAS_UI=true   # non-interactive default: include the design layer
  fi
fi

echo "Creating project: $PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "  → initializing git"
git init -q
git commit --allow-empty -m "chore: initial commit" -q
git branch -M main

echo "  → creating folder structure"
mkdir -p .claude/tasks .claude/agents .claude/commands
mkdir -p docs/prds docs/stories docs/decisions docs/research docs/templates
mkdir -p knowledge

echo "  → copying templates"
cp "$TEMPLATES_DIR/CLAUDE.md" CLAUDE.md
cp "$TEMPLATES_DIR/tasks/todo.md" .claude/tasks/todo.md
cp "$TEMPLATES_DIR/tasks/lessons.md" .claude/tasks/lessons.md
cp "$TEMPLATES_DIR/agents/code-reviewer.md" .claude/agents/code-reviewer.md
cp "$TEMPLATES_DIR/agents/architecture-reviewer.md" .claude/agents/architecture-reviewer.md
cp "$TEMPLATES_DIR/commands/commit-push.md" .claude/commands/commit-push.md
cp "$TEMPLATES_DIR/commands/dev-handoff.md" .claude/commands/dev-handoff.md
cp "$TEMPLATES_DIR/commands/setup-project.md" .claude/commands/setup-project.md
cp "$TEMPLATES_DIR/commands/retro.md" .claude/commands/retro.md
cp "$TEMPLATES_DIR/commands/sprint.md" .claude/commands/sprint.md
cp "$TEMPLATES_DIR/commands/compound.md" .claude/commands/compound.md
cp "$TEMPLATES_DIR/commands/compound-refresh.md" .claude/commands/compound-refresh.md
cp "$TEMPLATES_DIR/commands/pulse.md" .claude/commands/pulse.md
cp "$TEMPLATES_DIR/docs/ADR-TEMPLATE.md" docs/templates/ADR-TEMPLATE.md
cp "$TEMPLATES_DIR/knowledge/README.md" knowledge/README.md

# Design layer (only for UI projects)
if $HAS_UI; then
  mkdir -p design
  cp "$TEMPLATES_DIR/agents/design-reviewer.md" .claude/agents/design-reviewer.md
  cp "$TEMPLATES_DIR/commands/setup-design.md" .claude/commands/setup-design.md
  cp "$TEMPLATES_DIR/design/tokens.json" design/tokens.json
  cp "$TEMPLATES_DIR/design/README.md" design/README.md
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
echo "Structure:"
echo "  $PROJECT_NAME/"
echo "  ├── CLAUDE.md"
echo "  ├── .claude/"
if $HAS_UI; then
  echo "  │   ├── agents/     (code-reviewer, architecture-reviewer, design-reviewer)"
  echo "  │   ├── commands/   (setup-project, setup-design, sprint, compound, compound-refresh, pulse, commit-push, dev-handoff, retro)"
else
  echo "  │   ├── agents/     (code-reviewer, architecture-reviewer)"
  echo "  │   ├── commands/   (setup-project, sprint, compound, compound-refresh, pulse, commit-push, dev-handoff, retro)"
fi
echo "  │   └── tasks/      (todo.md, lessons.md)"
echo "  ├── knowledge/      (compound: reusable solved problems)"
if $HAS_UI; then echo "  ├── design/         (tokens.json, design system source of truth)"; fi
echo "  └── docs/           (prds, stories, decisions, research, templates)"
echo ""
echo "PM work (PRDs, critique, stories) is driven by the pm-skills plugins:"
echo "  /pm-product-discovery:brainstorm-ideas-new   → explore the idea"
echo "  /pm-execution:create-prd                      → write the PRD"
echo "  /pm-execution:strategy-red-team + :pre-mortem → critique it"
echo "  /pm-execution:user-stories                    → break into stories"
echo "  (save outputs into docs/prds and docs/stories)"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  gh repo create $PROJECT_NAME --private --source=. --remote=origin --push"
echo "  claude"
echo ""
echo "Then, first thing inside Claude, configure the project for your stack:"
echo "  > /setup-project   (stack, commands, conventions → fills CLAUDE.md)"
if $HAS_UI; then
  echo "After the PM phase, before building UI, set up the design system:"
  echo "  > /setup-design    (ingest your tokens or generate from PRD/personas → tokens.json)"
fi
echo ""
echo "Build stories with agents:  /sprint   (single or parallel, you approve at the gate)"
echo "Capture reusable solutions: /compound    ·    Post-ship outcome check: /pulse"
echo ""
