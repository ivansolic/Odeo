# INSTALL.md, Complete Mac Setup, Step by Step

Follow these steps **in order**. Total time: ~30-40 minutes if starting from zero.
Each step ends with a ✓ CHECK, verify it before moving on.

**Platforms: macOS and Linux are what this is developed and tested on.** The toolchain is
bash and the gates are bash scripts, so PowerShell and `cmd` cannot run it. On Windows it is
**expected to work under WSL or Git Bash but has not been verified end to end there**; WSL
is the better bet, because `./install.sh --link` needs permission to create symlinks, which
WSL has by default and native Windows does not without developer mode. Steps 0 to 4 below
use Mac commands; on Linux and WSL substitute your package manager for Homebrew and the
rest is identical.

**If the scripts fail with `set: pipefail: invalid option name` or `syntax error near
unexpected token`, your checkout has CRLF line endings** (git's `core.autocrlf` does this on
Windows). Diagnose with `bash tests/line-endings.test.sh`, which names the affected files.
To fix, commit or stash your work first, then:

```bash
git rm --cached -r . && git reset --hard    # discards uncommitted changes
```

or just clone again. Note that `git add --renormalize .` does **not** help here: the
committed content is already LF, so there is nothing to renormalize; only your checkout is
CRLF, which is why the index looks clean while the files on disk do not run.

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

## Step 6, Clone Odeo and install it

Everything below, the global instructions, project templates, stack presets, the
TDD skill, the `init-project.sh` scaffolder, your PATH, and the auto-verify env
var, is installed by one script.

```bash
mkdir -p ~/code && cd ~/code
git clone https://github.com/ivansolic/Odeo.git
cd Odeo
./install.sh
```

`install.sh` puts everything where Claude Code reads it:
- `~/.claude/CLAUDE.md`, global baseline instructions + the Security Baseline + your chosen output-language default
- `~/.claude/skills/`, all skills, available in every project: the workflow commands (`/build`, `/merge`, `/learn`, ...) and the auto-applying skills (TDD, ux-design)
- `~/.claude/agents/`, the subagents (`architect`, `builder`, `code-reviewer`, ...), available everywhere
- `~/.claude-templates/`, project-specific scaffolding templates + `presets/`
- `~/bin/`, the scaffold + guard scripts (init-project, privacy-scan, secret-scan, boundary-check, merge-gate, install-git-guards)
- your shell profile, adds `~/bin` to PATH and sets `CLAUDE_CODE_AUTO_VERIFY=1`

> This is the GitHub install path. The same repo is also a Claude Code plugin
> (`.claude-plugin/plugin.json`); a marketplace listing comes later. Either way the
> operating baseline lives in `AGENTS.md` (read before `CLAUDE.md`).

It will NOT overwrite an existing `~/.claude/CLAUDE.md` (it saves the baseline to
`~/.claude/odeo-baseline.md` instead, so your personal global is safe).

> **Tip:** `./install.sh --link` symlinks instead of copying, so a later
> `git pull` updates your installed system live, handy if you'll improve it.

> **Language:** on first install Odeo asks once which language to write your
> documents in (PRDs, stories, plans, reviews), English (default), German,
> Croatian, or French; code, filenames, and commit messages always stay English.
> Press Enter to keep English. It is asked only once (re-running never re-prompts).
> For a scripted or non-interactive install, pass `--lang <code>` (`en`|`de`|`hr`|`fr`)
> or set `ODEO_INSTALL_LANG`; a non-interactive install defaults to English without prompting.

Then reload your shell so the PATH and env var take effect:
```bash
source ~/.bash_profile     # or ~/.zshrc if you use zsh
```

**✓ CHECK 1:** `cat ~/.claude/CLAUDE.md | head -3` (or the baseline file) shows the global instructions.
**✓ CHECK 2:** `ls ~/.claude-templates/` shows the project-specific templates: `tasks/`, `docs/`, `design/`, `knowledge/`, `presets/`, and `CLAUDE.md`.
**✓ CHECK 3:** `init-project.sh` (no arguments) prints the usage message.
**✓ CHECK 4:** `echo $CLAUDE_CODE_AUTO_VERIFY` prints `1`.
**✓ CHECK 5:** `ls ~/.claude/skills/` shows the skills (including `prd`, `stories`, `brainstorm`, `test-driven-development`, ...); `ls ~/.claude/agents/` shows `architect`, `builder`, `code-reviewer`, ...

_The PM skills, the workflow commands, the agents, and the TDD skill are all
installed by `install.sh` and available in every project. The TDD and ux-design
skills auto-apply; the rest you invoke._

---

## Step 7, One PM system at a time

The PM phase runs on our **first-party PM skills** (installed in Step 6). If a
third-party PM plugin is ALSO installed, plain-language requests ("let's
brainstorm", "critique this PRD") can route to either skill set, and you end up
with a mixed system whose gates and conventions don't fully apply, our own
end-to-end test hit exactly this.

For the single-system experience: inside a Claude session type `/plugin`, open
the Installed list, and uninstall any other PM packages. (If you deliberately
prefer another plugin for the PM phase, its namespaced commands keep working,
just know the routing caveat above. Save outputs into the same `docs/`
convention either way.)

---

## Step 7b, Environment notes (read once, saves an afternoon)

- **Repos created locally** (the normal `init-project.sh` flow) don't have
  `origin/HEAD` until you run `git remote set-head origin -a` once after
  creating the remote, the init output reminds you. The built-in
  `/security-review` needs it.
- **Test commands must be non-interactive**: `vitest run`, never bare `vitest`
  (watch mode never exits, and agents run your test command constantly).
  `/setup-project` records them correctly if you let it.
- **Registry/network limits**: corporate networks and sandboxes sometimes block
  package fetches (pnpm/npm). If installs hang, that's the environment, not the
  system; try again on an open network before debugging further.
- **Org spend limits**: agent-heavy steps (for-me builds, reviews) stop when the
  organization's Claude budget is exhausted; work resumes cleanly after a reset,
  state lives in files, not the session.

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

1. Type `/`, you should see `setup-project`, `build`, `merge`, `commit-push` (workflow) and `prd`, `brainstorm`, `stories`, `critique` (PM skills)
2. Ask: *"What does my global CLAUDE.md say about git discipline?"*, Claude should quote your rules (proves global file loads)
3. Run `/setup-project`, Claude should interview you about your stack (or offer a preset) and fill in CLAUDE.md (proves onboarding works). On a fresh scaffold, CLAUDE.md starts with `[...]` placeholders until you do this.
4. Ask: *"List the subagents available in this project"*, should mention `architect`, `builder`, `code-reviewer`, and `architecture-reviewer` (PM critique is the `/critique` skill)
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
│   └── Odeo/                  ← the cloned repo (source you can `git pull` to update)
├── .claude/
│   ├── CLAUDE.md              ← global instructions (auto-loads everywhere)
│   ├── skills/                ← all skills: /build /merge /learn ... + TDD, ux-design (Step 6)
│   ├── agents/                ← subagents: architect, builder, code-reviewer, ... (Step 6)
│   ├── community-knowledge/   ← shared knowledge base (if reachable)
│   └── plugins/               ← any plugins you add install here
├── .claude-templates/         ← project-specific scaffolding for init-project.sh
│                                 (CLAUDE.md, tasks/, docs/, design/, knowledge/, presets/)
├── .bash_profile              ← contains PATH + CLAUDE_CODE_AUTO_VERIFY
└── bin/
    ├── init-project.sh        ← scaffolds the project-specific parts of a project
    ├── privacy-scan.sh        ← deterministic privacy guard
    └── + secret-scan, boundary-check, merge-gate, install-git-guards (enforced gates)
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
    └── templates/             ← ADR template (PRD/story format comes from /prd, /stories)
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
