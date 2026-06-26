# INSTALL.md, Complete Mac Setup, Step by Step

Follow these steps **in order**. Total time: ~30-40 minutes if starting from zero.
Each step ends with a ✓ CHECK, verify it before moving on.

---

## Step 0, Open Terminal

Press `Cmd + Space`, type `Terminal`, hit Enter.
All commands below are typed there.

---

## Step 1, Install Homebrew (Mac package manager)

Check if you already have it:
```bash
brew --version
```

If you see a version number → skip to Step 2.
If you see "command not found":
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow the on-screen instructions (it may ask for your Mac password and tell you to run 1-2 extra commands at the end, do them).

**✓ CHECK:** `brew --version` shows a version number.

---

## Step 2, Install Node.js, Git, GitHub CLI (and pnpm if JS/TS)

`node`, `git`, `gh` are always required, Claude Code itself runs on Node.
`pnpm` is only needed for JS/TS projects; skip it otherwise and install your
language's tooling instead (you set the real commands later via `/setup-project`).

```bash
brew install node git gh      # always
brew install pnpm             # only if your project is JS/TS
```

**✓ CHECK:** the always-required three show versions:
```bash
node --version    # should be v22+
git --version
gh --version
```

---

## Step 3, Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Then log in:
```bash
claude
```
First launch will walk you through authentication with your Anthropic account.

**✓ CHECK:** `claude --version` shows a version. Type `claude` in any folder and it starts.

---

## Step 4, Install VS Code + `code` command

1. Download from https://code.visualstudio.com and drag to Applications
2. Open VS Code
3. Press `Cmd + Shift + P`, type `shell command`, select:
   **Shell Command: Install 'code' command in PATH**

**✓ CHECK:** open a NEW terminal window, type `code --version`, shows a version.

---

## Step 5, GitHub account + authentication

1. Create account at https://github.com if you don't have one
2. Authenticate the CLI:
```bash
gh auth login
```
Choose: GitHub.com → HTTPS → Yes (authenticate Git) → Login with a web browser.
Follow the browser flow.

**✓ CHECK:** `gh auth status` shows "Logged in to github.com".

---

## Step 6, Clone Claude Cofounder and install it

Everything below, the global instructions, project templates, stack presets, the
TDD skill, the `init-project.sh` scaffolder, your PATH, and the auto-verify env
var, is installed by one script.

```bash
mkdir -p ~/code && cd ~/code
git clone https://github.com/ivansolic/claude-cofounder.git
cd claude-cofounder
./install.sh
```

`install.sh` puts everything where Claude Code reads it:
- `~/.claude/CLAUDE.md`, global baseline instructions + the Security Baseline
- `~/.claude/skills/`, all skills, available in every project: the workflow commands (`/build`, `/merge`, `/learn`, ...) and the auto-applying skills (TDD, ux-design)
- `~/.claude/agents/`, the subagents (`developer`, `code-reviewer`, ...), available everywhere
- `~/.claude-templates/`, project-specific scaffolding templates + `presets/`
- `~/bin/init-project.sh` and `~/bin/privacy-scan.sh`
- your shell profile, adds `~/bin` to PATH and sets `CLAUDE_CODE_AUTO_VERIFY=1`

> This is the GitHub install path. The same repo is also a Claude Code plugin
> (`.claude-plugin/plugin.json`); a marketplace listing comes later. Either way the
> operating baseline lives in `AGENTS.md` (read before `CLAUDE.md`).

It will NOT overwrite an existing `~/.claude/CLAUDE.md` (it saves the baseline to
`~/.claude/claude-cofounder-baseline.md` instead, so your personal global is safe).

> **Tip:** `./install.sh --link` symlinks instead of copying, so a later
> `git pull` updates your installed system live, handy if you'll improve it.

Then reload your shell so the PATH and env var take effect:
```bash
source ~/.bash_profile     # or ~/.zshrc if you use zsh
```

**✓ CHECK 1:** `cat ~/.claude/CLAUDE.md | head -3` (or the baseline file) shows the global instructions.
**✓ CHECK 2:** `ls ~/.claude-templates/` shows the template folders: `agents/`, `commands/`, `tasks/`, `docs/`, `presets/`, and `CLAUDE.md`.
**✓ CHECK 3:** `init-project.sh` (no arguments) prints the usage message.
**✓ CHECK 4:** `echo $CLAUDE_CODE_AUTO_VERIFY` prints `1`.
**✓ CHECK 5:** `cat ~/.claude/skills/test-driven-development/SKILL.md | head -2` shows the skill's frontmatter.

_PM work, commands, critique, and the PRD/story format, is owned by the
pm-skills plugins (Step 7), not custom files. The TDD skill auto-applies to
backend logic and stays out of the way for UI/prototype work; you never invoke it._

---

## Step 7, PM plugins (pm-skills), the source of all PM commands

All Phase 1 PM work (brainstorm, PRD, critique, user stories) is powered by the
**pm-skills** marketplace. These plugins replace any custom PM command or
subagent, there is no `/new-prd` or `product-critic` in this setup.

### Where plugins live
Plugins install into `~/.claude/plugins/`. They do NOT touch your
`~/.claude/CLAUDE.md`, your global instructions and the plugins are separate
layers that work together.

### How to install
Plugin commands run **inside a Claude session**, not from the shell. Start
`claude`, then add the marketplace and install the packs:

```
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
```

`pm-execution` and `pm-product-discovery` are the two you'll use most, they
cover PRDs, user stories, critique (red-team, pre-mortem), brainstorming, and
feature triage. The rest are situational (see the bonus table in WORKFLOW.md).

### Good habits
1. **Read before you lean on it.** Open `~/.claude/plugins/<name>/` and skim the
   SKILL.md files. You're installing instructions that shape Claude's behavior, 
   know what they say. This is also how you learn to write your own.
2. **Save outputs into your `docs/` structure.** The skills generate content;
   you keep the folder convention, drop PRDs into `docs/prds/PRD-NNN-<slug>.md`
   and stories into `docs/stories/USR-NNN-<slug>.md`.

**✓ CHECK:** inside a Claude session, type `/pm-` and the pm-skills commands
(`pm-execution:create-prd`, `pm-execution:user-stories`, …) appear in the list.

---

## Step 8, Final verification (5-minute test run)

Test the whole chain with a throwaway project:

```bash
cd ~/Desktop
init-project.sh test-setup
cd test-setup
```

You should see the success message with the folder tree.

Connect to GitHub:
```bash
gh repo create test-setup --private --source=. --remote=origin --push
```

Start Claude:
```bash
claude
```

Inside Claude, verify each piece:

1. Type `/`, you should see `setup-project`, `commit-push`, and `dev-handoff` (your workflow commands)
2. Type `/pm-`, you should see the pm-skills commands (`pm-execution:create-prd`, `pm-execution:user-stories`, …)
3. Ask: *"What does my global CLAUDE.md say about git discipline?"*, Claude should quote your rules (proves global file loads)
4. Run `/setup-project`, Claude should interview you about your stack (or offer a preset) and fill in CLAUDE.md (proves onboarding works). On a fresh scaffold, CLAUDE.md starts with `[...]` placeholders until you do this.
5. Ask: *"List the subagents available in this project"*, should mention code-reviewer and architecture-reviewer (PM critique now lives in pm-skills, not a subagent)
6. Press `Shift+Tab` twice, bottom of screen should show plan mode is on

If all 6 pass: **your setup is complete.**

Clean up the test:
```bash
cd ~/Desktop
rm -rf test-setup
gh repo delete test-setup --yes
```

---

## Where everything lives, final map

```
~ (your home folder)
├── code/
│   └── claude-cofounder/      ← the cloned repo (source you can `git pull` to update)
├── .claude/
│   ├── CLAUDE.md              ← global instructions (auto-loads everywhere)
│   ├── skills/                ← all skills: /build /merge /learn ... + TDD, ux-design (Step 6)
│   ├── agents/                ← subagents: developer, code-reviewer, ... (Step 6)
│   ├── community-knowledge/   ← shared knowledge base (if reachable)
│   └── plugins/               ← pm-skills plugins install here (Step 7)
├── .claude-templates/         ← project-specific scaffolding for init-project.sh
│                                 (CLAUDE.md, tasks/, docs/, design/, knowledge/, presets/)
├── .bash_profile              ← contains PATH + CLAUDE_CODE_AUTO_VERIFY
└── bin/
    ├── init-project.sh        ← scaffolds the project-specific parts of a project
    └── privacy-scan.sh        ← deterministic privacy guard
```

Everything under `~/.claude*` and `~/bin` is installed by `install.sh` from the
cloned repo, re-run it (or use `--link`) after a `git pull` to update.

Per project (created by init-project.sh, project-specific files only; the
commands/agents/skills come from the install above and work in every project):
```
my-project/
├── CLAUDE.md                  ← project config (stack, conventions, Security & Data)
├── .gitignore
├── .claude/
│   └── tasks/                 ← todo.md (active task), lessons.md (corrections)
├── knowledge/                 ← reusable solved problems for this project
├── design/                    ← tokens.json + README (UI projects only)
└── docs/
    ├── prds/                  ← Product Requirements Documents
    ├── stories/               ← user stories
    ├── decisions/             ← Architecture Decision Records
    ├── research/              ← user research notes
    └── templates/             ← ADR template (PRD/story format comes from pm-skills)
```

---

## When you're ready to start the real project

```bash
cd ~/projects        # or wherever you keep projects
init-project.sh my-real-project
cd my-real-project
gh repo create my-real-project --private --source=. --remote=origin --push
claude
```

Then open WORKFLOW.md and follow the daily operating manual. If you're new to
coding, read BEGINNERS-GUIDE.md first, it explains the concepts behind the
workflow in plain language.
