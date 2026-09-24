---
description: Create a new Claude-ready project folder with Odeo's structure (CLAUDE.md, docs/, tasks/, knowledge/, design/ for UI projects), a git repo on main and the git guards installed. Explicit command; run it once per new project, then open the folder and run /odeo:setup-project. Example: "/odeo:new-project my-app".
disable-model-invocation: true
---

# New project (scaffold a project from the plugin)

Creates a new project folder from the templates that ship inside the Odeo plugin, by
running the plugin's `init-project.sh`. Nothing needs to be cloned or installed first:
the plugin's `bin/` is on the PATH of Claude's shell.

## When to use (and when not)
- Starting a NEW product or repo that should follow the Odeo workflow.
- Not for an existing codebase: open that folder and run `/odeo:setup-project`, which has an
  existing-project mode that maps the code instead of scaffolding over it.

## Process
1. **Name.** Take it from the argument, or ask once. Before anything reaches a shell,
   check it yourself: it must match `^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$` (a letter or
   digit first, then letters, digits, `.`, `_`, `-`). If it does not, say why and ask
   again; never quote or escape your way around it. `init-project.sh` enforces the same
   rule, but only after the shell has parsed the command, so it cannot protect the
   command you write.
2. **Where.** The project goes inside a parent folder, by default the current one. Say
   the full path it will get and ask whether that is right. A parent folder the user
   names is refused if it contains a `'`; otherwise it is used single-quoted. If the
   parent is inside a git repository (`git -C '<parent>' rev-parse --show-toplevel`
   succeeds), say so before going on. If `<parent>/<name>` already exists
   (`test -e '<parent>/<name>'`), say so and ask for another name; never run the script
   over an existing folder.
3. **UI or not.** Ask: "Will this project have a user interface?" Yes means `--ui`
   (adds the design layer), no means `--no-ui`.
4. **Language.** `resolve-language.sh '<parent>'` prints the language to pass: the
   parent folder's own `CLAUDE.md` setting if it has one, otherwise the global default.
   Do not ask again; the user changes it later with `/odeo:language`.
5. **Run in ONE call**, so the folder created is the folder confirmed:
   `cd -- '<parent>' && pwd -P && init-project.sh '<name>' --ui|--no-ui --language <code>`
   The first output line is the real parent path; report `<that path>/<name>`, never
   the path you assumed.
6. **Read the result.**
   - Exit 0: created. Relay two warnings if the output has them: `looks
     machine-generated` (the git email every commit will carry) and `hooks skipped` (the
     guards are NOT installed; do not claim they are).
   - Any other exit: relay the output as it is and stop. If the output says `already
     exists`, that folder is the user's own and was not touched. Otherwise, if `<name>/`
     now exists, it is an incomplete scaffold: say so, and do not delete it yourself.
   - The script prints its own "Next steps", including `gh repo create ... --push`. Do
     not run them; step 7 is the only way to a remote.
7. **Hand over.** Say what was created and the next two steps: open the folder in Claude
   (terminal: `cd <name> && claude`; desktop app: open the folder as the project), then
   run `/odeo:setup-project` there to set the stack and commands.
8. **Remote, only if asked.** Creating a GitHub repository sends the project outward, so
   offer it and run `gh repo create '<name>' --private --source='<path>' --remote=origin`
   only after an explicit yes (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 1, human
   floor). Never push `main`.

## Worked example
"/odeo:new-project invoice-tracker"
- `invoice-tracker` matches the name rule. The current folder is `/Users/ana/code`, not
  inside a repository: "I'll create `/Users/ana/code/invoice-tracker`, OK?" Yes.
- "Will this project have a user interface?" Yes, so `--ui`.
- `resolve-language.sh '/Users/ana/code'` prints `de`.
- Runs `cd -- '/Users/ana/code' && pwd -P && init-project.sh 'invoice-tracker' --ui
  --language de`. First line `/Users/ana/code`, exit 0, no `hooks skipped` line.
- "Created `/Users/ana/code/invoice-tracker` with git on `main` and the guards installed
  (no direct push to main, secret scan on commit). Next: open it (`cd invoice-tracker &&
  claude`) and run `/odeo:setup-project`. Want a private GitHub repo for it as well?"
- Had the user typed `/odeo:new-project my app`: "`my app` has a space; project names use
  letters, digits, `.`, `_` or `-`. How about `my-app`?"

## Output
A new folder `<name>/` with `CLAUDE.md`, `docs/`, `.claude/tasks/`, `knowledge/`,
`design/` (UI projects only), `.gitignore`, `.claude/settings.json` (when the template
ships one), two commits on `main` (initial and scaffold), and the pre-push and
pre-commit guards unless the output said `hooks skipped`. No remote unless the user
said yes in step 8.

## Rules
- The scaffolding is the deterministic `init-project.sh`; never recreate its files by
  hand, because the guards and the ledger ignore rules come from it.
- Outward actions (a GitHub repo, a push) follow `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`
  Guardrails 1: offered, never assumed.
