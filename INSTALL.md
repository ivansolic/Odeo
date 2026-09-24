# INSTALL.md, Complete Mac Setup, Step by Step

Follow these steps **in order**. Total time: ~30-40 minutes if starting from zero.
Each step ends with a ✓ CHECK, verify it before moving on.

**Platforms: macOS and Linux are what this is developed and tested on.** Steps 0 to 4 below
use Mac commands; on Linux and WSL substitute your package manager for Homebrew and the
rest is identical. **On Windows, start at [Step 6w](#step-6w-windows)
instead.**

**Working from a clone of Odeo (contributors) and the scripts fail with `set: pipefail:
invalid option name` or `syntax error near unexpected token`? Your checkout has CRLF line
endings** (git's `core.autocrlf` does this on
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

## Step 6, Install the Odeo plugin

Start Claude Code (`claude` in the terminal, or the Code tab of the desktop app) and run:

```
/plugin marketplace add ivansolic/Odeo
/plugin install odeo@odeo
```

That is the whole install. Nothing is cloned and nothing is copied into your home folder:
the skills, agents, guard scripts and templates live inside the plugin, and the global
baseline (including the Security Baseline) is delivered to every session and every
subagent by the plugin itself. If your own `~/.claude/CLAUDE.md` already carries the
Security Baseline heading, yours is used and nothing is duplicated.

> **Language:** when the plugin is enabled, Claude Code asks once which language Odeo
> writes your documents in (PRDs, stories, plans, reviews): English (default), German,
> Croatian, or French. Code, filenames and commit messages always stay English. Change it
> later in `/config` (the Odeo row) or with `/language`.

> **Updates:** third-party marketplaces do not auto-update by default. Turn it on once:
> `/plugin` → **Marketplaces** → **odeo** → **Enable auto-update**. Or update by hand with
> `/plugin marketplace update odeo` and `/plugin update odeo@odeo`.

> **Coming from the old `install.sh` setup?** Ask Claude to run `odeo-migrate-legacy.sh`
> (a dry run), then `odeo-migrate-legacy.sh --apply`. It moves the old copies aside into
> `~/.claude/odeo-legacy-<date>/`, deletes nothing, and never touches your own
> `~/.claude/CLAUDE.md`. Projects you created before the plugin keep their secret scan:
> `~/bin/secret-scan.sh` becomes a small shim that runs the plugin's copy (and blocks if the
> plugin is gone, rather than letting commits through unchecked).

**✓ CHECK 1:** `/plugin` → **Installed** lists `odeo`.
**✓ CHECK 2:** type `/` and you see `new-project`, `setup-project`, `build`, `merge`, `prd`, `brainstorm`.
**✓ CHECK 3:** ask *"Which subagents do you have?"*, the answer includes `architect`, `builder`, `code-reviewer`.
**✓ CHECK 4:** ask *"What does the Security Baseline say about SQL queries?"*, Claude answers "parameterized queries only" (proves the baseline arrived).

_The TDD and ux-design skills auto-apply; the rest you invoke._

---

## Step 6w, Windows

**Status: NOT verified end to end on a Windows machine.** If it fails there, the failure is
worth reporting rather than working around.

Odeo's guarantees are bash scripts with exit codes: the merge gate, the secret scan, the
publish guard, the git hooks. Reimplementing them in PowerShell would mean two
implementations of every guard, and two implementations drift. So the rule is one
sentence: **run Claude Code inside WSL (recommended) or Git Bash**, then install the plugin
as in Step 6. A session started from PowerShell would give you the workflow without the
guards, and the guards are the half that makes any of this trustworthy.

### If scripts fail with `set: pipefail: invalid option name`

Your checkout has CRLF line endings, which git's `core.autocrlf` does on Windows, and a CRLF
bash script does not run at all. This only concerns a clone you work on (see "Working on
Odeo itself" in the README); the plugin install itself is not a checkout. The remedy is at
the top of this file, under Platforms; `bash tests/line-endings.test.sh` names any affected
file.

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

- **Repos created locally** (the normal `/new-project` flow) don't have
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

Test the whole chain with a throwaway project. Inside Claude, from your Desktop folder:

```
/new-project test-setup
```

Claude confirms the path, asks whether the project has a UI, creates the folder with git
on `main` and the guards installed, and offers a GitHub repo (say no for this test).
Open `test-setup` in Claude, then verify each piece:

1. Type `/`, you should see `setup-project`, `build`, `merge`, `commit-push` (workflow) and `prd`, `brainstorm`, `stories`, `critique` (PM skills)
2. Ask: *"What does the global baseline say about git discipline?"*, Claude should quote the rules (proves the plugin delivered the baseline)
3. Run `/setup-project`, Claude should interview you about your stack (or offer a preset) and fill in CLAUDE.md (proves onboarding works). On a fresh scaffold, CLAUDE.md starts with `[...]` placeholders until you do this.
4. Ask: *"List the subagents available in this project"*, should mention `architect`, `builder`, `code-reviewer`, and `architecture-reviewer` (PM critique is the `/critique` skill)
5. Press `Shift+Tab` twice, bottom of screen should show plan mode is on

If all 5 pass: **your setup is complete.** Clean up by deleting the `test-setup` folder.

---

## Where everything lives, final map

```
~ (your home folder)
├── .claude/
│   ├── CLAUDE.md              ← YOUR global instructions (optional; Odeo never writes it,
│   │                            except the one `output_language:` line of your choice)
│   ├── plugins/cache/odeo/    ← the installed plugin: skills, agents, hooks, guard scripts,
│   │                            templates, one folder per version (managed by Claude Code)
│   ├── plugins/data/          ← what the plugin remembers between updates (e.g. the last
│   │                            applied language)
│   └── community-knowledge/   ← shared knowledge base, after your first /sync-community
└── (nothing else: no ~/bin, no ~/.claude-templates, no shell-profile edits)
```

Everything Odeo ships updates with the plugin. Per project (created by `/new-project`,
project-specific files only; the commands, agents and skills come from the plugin and
work in every project):
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

In Claude, from the folder where you keep projects:

```
/new-project my-real-project
```

Say yes when it offers a private GitHub repo, open `my-real-project` in Claude, and run
`/setup-project`.

Then open WORKFLOW.md and follow the daily operating manual. If you're new to
coding, read BEGINNERS-GUIDE.md first, it explains the concepts behind the
workflow in plain language.
