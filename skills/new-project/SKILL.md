---
description: Create a new Claude-ready project folder with Odeo's structure (CLAUDE.md, docs/, tasks/, knowledge/, design/ for UI projects), a git repo on main and the git guards installed. Explicit command; run it once per new project, then open the folder and run /setup-project. Example: "/new-project my-app".
disable-model-invocation: true
---

# New project (scaffold a project from the plugin)

Creates a new project folder from the templates that ship inside the Odeo plugin, by
running the plugin's `init-project.sh`. Nothing needs to be cloned or installed first:
the plugin's `bin/` is on the PATH of Claude's shell.

## When to use (and when not)
- Starting a NEW product or repo that should follow the Odeo workflow.
- Not for an existing codebase: open that folder and run `/setup-project`, which has an
  existing-project mode that maps the code instead of scaffolding over it.

## Process
1. **Name.** Take it from the argument, or ask once. The script accepts only letters,
   digits, `.`, `_` and `-`, starting with a letter or digit, and refuses anything else
   (paths, spaces), so pass the user's text as typed and relay its error if it refuses.
2. **Where.** The project is created INSIDE the current directory. Say the full path it
   will get (`$(pwd)/<name>`) and ask whether that is right; if not, ask for the parent
   folder and `cd` there first. Never create it inside another git repository without
   saying so: check `git rev-parse --show-toplevel 2>/dev/null` and mention the repo if
   one is found.
3. **UI or not.** Ask: "Will this project have a user interface?" Yes means `--ui`
   (adds the design layer), no means `--no-ui`.
4. **Language.** Use the global default: `resolve-language.sh "$(pwd)"` prints it. Do not
   ask again; the user changes it later with `/language`.
5. **Run** (non-interactive, so every choice is a flag):
   `init-project.sh <name> --ui|--no-ui --language <code>`
   Exit 0 means created. Exit 1 prints the reason (name refused, folder exists,
   templates missing); relay it as it is and stop.
6. **Hand over.** Say what was created and the next two steps: open the folder in Claude
   (terminal: `cd <name> && claude`; desktop app: open the folder as the project), then
   run `/setup-project` there to set the stack and commands.
7. **Remote, only if asked.** Creating a GitHub repository sends the project outward, so
   offer it and run `gh repo create <name> --private --source=<name> --remote=origin`
   only after an explicit yes (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 1, human
   floor). Never push `main`.

## Worked example
"/new-project invoice-tracker"
- The name is a valid slug. Current directory `/Users/ana/code`, not inside a repo:
  "I'll create `/Users/ana/code/invoice-tracker`, OK?" Yes.
- "Will this project have a user interface?" Yes, so `--ui`.
- `resolve-language.sh /Users/ana/code` prints `de`.
- Runs `init-project.sh invoice-tracker --ui --language de`, exit 0.
- "Created `/Users/ana/code/invoice-tracker` with git on `main` and the guards installed
  (no direct push to main, secret scan on commit). Next: open it (`cd invoice-tracker &&
  claude`) and run `/setup-project`. Want a private GitHub repo for it as well?"

## Output
A new folder `<name>/` with `CLAUDE.md`, `docs/`, `.claude/tasks/`, `knowledge/`,
`design/` (UI projects only), `.claude/settings.json`, an initial commit on `main`, and
the pre-push and pre-commit guards. No remote unless the user said yes in step 7.

## Rules
- The scaffolding is the deterministic `init-project.sh`; never recreate its files by
  hand, because the guards and the ledger ignore rules come from it.
- Outward actions (a GitHub repo, a push) follow `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`
  Guardrails 1: offered, never assumed.
