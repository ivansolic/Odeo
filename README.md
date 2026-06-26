# Claude Cofounder

**The workflow system that turns one person into a product team.**

The whole product lifecycle, with you directing Claude: idea → discovery → PRD → design → build → test → secure → ship → measure → learn. **Built for PMs and builders.**

---

## What is this?

Claude Cofounder is an opinionated workflow system for [Claude Code](https://claude.com/claude-code). It covers the **whole product lifecycle**, from first idea and discovery, through PRD, design, build, test, and security, to ship, and then measuring the outcome and feeding what you learn back in. You direct Claude as your developer instead of writing code by hand. It bundles the global instructions, project scaffolding, PM workflow, a test-driven-development habit, a security baseline, and an end-to-end daily process into one install.

You bring the *what* and *why* (the product thinking). The system makes Claude deliver the *how* (the code), with guardrails so the result is actually solid.

## Who it's for

PMs and builders who want to ship real software with Claude Code and don't want to figure out the workflow, testing, and security discipline from scratch. No engineering background assumed, the included `BEGINNERS-GUIDE.md` explains every concept in plain language.

## The workflow at a glance

```
        🎩 PM HAT                    switch            🛠️ DEV HAT
  (decide what & why)                 hats           (build & ship)
                                        │
 brainstorm → PRD → critique →  ─────/build─────→  plan → build → verify
 (optional) user stories                          → code-review
        │                                          → /security-review (sensitive)
   saved in docs/                                  → /merge → ship → /retro
                                                            │
                                          /outcome (post-ship) → /learn (capture)
                                                            │
                                                       lives on GitHub
```

You run each step; nothing fires blindly. The two automatic guardrails: a TDD skill writes tests first for backend logic, and a security baseline applies to all code. `/build` runs human-first or dispatches `developer` agents (one per story, in isolated worktrees); you approve at every gate.

## Repo structure

```
claude-cofounder/
├── README.md                 ← you are here
├── INSTALL.md                ← full first-time setup (bare machine → ready)
├── BEGINNERS-GUIDE.md        ← the concepts, in plain language
├── WORKFLOW.md               ← the daily operating manual
├── install.sh                ← installs the system onto your machine
├── global/
│   └── CLAUDE.md             ← baseline instructions + the SECURITY BASELINE (OWASP/GDPR-aware)
├── project-templates/        ← scaffolded into every new project (organized by type)
│   ├── CLAUDE.md             ← per-project config incl. a Security & Data section
│   ├── commands/             ← slash commands (you type /name)
│   │   ├── setup-project.md  ← /setup-project onboarding interview
│   │   ├── setup-design.md   ← /setup-design design-system/tokens setup (UI projects)
│   │   ├── build.md          ← /build stories: human-first or developer agents (you approve)
│   │   ├── merge.md          ← /merge rebase onto main, test, merge PR, cleanup
│   │   ├── commit-push.md    ← /commit-push with secret-scan + safety checks
│   │   ├── learn.md          ← /learn capture a verified solved problem (shows draft first)
│   │   ├── knowledge-refresh.md ← /knowledge-refresh audit/refresh the knowledge base
│   │   ├── outcome.md        ← /outcome post-ship outcome check
│   │   ├── contribute-lesson.md ← /contribute-lesson opt-in share to community knowledge
│   │   └── retro.md          ← /retro end-of-session learning capture
│   ├── agents/               ← subagents (separate-context)
│   │   ├── developer.md              ← builds one story end-to-end in its own worktree
│   │   ├── code-reviewer.md          ← code, functions, security
│   │   ├── debugger.md
│   │   ├── architecture-reviewer.md
│   │   └── design-reviewer.md        ← UI: heuristics, states, a11y, tokens (UI projects)
│   ├── knowledge/            ← reusable solved problems (consulted before non-trivial work)
│   ├── design/               ← tokens.json (DTCG) + README, design-system source of truth (UI projects)
│   ├── tasks/                ← working files: todo.md, lessons.md
│   ├── docs/                 ← document templates: ADR-TEMPLATE.md
│   └── presets/              ← example filled stacks (e.g. angular-nest-mysql.md)
├── skills/
│   ├── test-driven-development/   ← user-level skill (auto-applies to logic)
│   └── ux-design/                 ← user-level skill (auto-applies to UI: heuristics, states, a11y)
├── bin/
│   ├── init-project.sh       ← scaffolds a new Claude-ready project
│   └── privacy-scan.sh       ← deterministic privacy guard (blocks leaks before sharing)
├── tests/
│   └── privacy-scan.test.sh  ← tests for the privacy guard
└── docs/
    └── privacy-guard.md      ← design of the privacy guard

# Security review is handled by Claude Code's built-in /security-review command
# (ships with Claude Code, not a file in this repo), driven by our Security Baseline.
```

## What's inside

- **Global instructions**, communication, git discipline, TDD, and workflow orchestration that shape every session.
- **Security, built in**, a comprehensive, OWASP-aligned **Security Baseline** (ours, in `global/CLAUDE.md`) applied to all code; a per-project **Security & Data** section (PII inventory, auth model, GDPR); a security pre-mortem at the PRD stage; and Claude Code's **built-in `/security-review`** command for sensitive changes. The baseline loads every session, so it informs both `/security-review` and code review automatically.
- **Project scaffolding** (`init-project.sh`), one command creates a Claude-ready project: docs structure, task files, review subagents, and workflow commands.
- **`/setup-project`**, interviews you about your stack, commands, and data, then fills the project config. Run once per project.
- **PM workflow via [pm-skills](https://github.com/phuryn/pm-skills)**, brainstorm, PRDs, critique, user stories (a separate plugin you install once; see Quick start).
- **TDD skill**, auto-applies test-first to backend logic, stays out of the way on UI.
- **Design layer**, a `ux-design` skill (usability heuristics, UX laws, UI states, accessibility) that auto-applies to UI; **design tokens** (`design/tokens.json`, DTCG) as the styling source of truth, set up by `/setup-design` and compiled to your stack; a `design-reviewer` subagent for UI review. Optional per project (`init-project.sh --no-ui` skips it).
- **Hybrid agentic build** (`/build`), one entry, two modes. Human-first: branch, seed todo, open editor, plan and build with you step by step. Agents: dispatch a `developer` per story, each end-to-end (plan, TDD build, verify, review) in its own git worktree, single or parallel, with the oversight you pick. Either way you hold the gates. **`/merge`** then integrates an approved branch with a clean linear history (rebase onto main, tests, merge, cleanup).
- **Compounding knowledge** (`/learn`, `/knowledge-refresh`, `knowledge/`), verified solved problems become a reusable, maintained knowledge base that Claude consults before non-trivial work, so the system gets smarter per story. `/learn` shows the draft before writing.
- **Community knowledge** (`/contribute-lesson`), opt-in, share a sanitized, generalized lesson with the shared knowledge base so the whole system gets smarter; on update you get back the curated knowledge of all contributors. Approval-gated, nothing leaves your machine without your OK.
- **Privacy guard** (`bin/privacy-scan.sh`), a deterministic scan (emails, secrets/tokens, local paths, IPs, and your own deny-list terms) that runs as a hard gate before anything is shared via `/contribute-lesson`. The safety net under the model's sanitization and your approval, so private data can't leak by accident, including other users' data once this is a product. Your private terms live in a local `~/.claude/privacy-denylist.txt`, never in a repo.
- **Post-ship outcome loop** (`/outcome`), about a week after shipping, compares the real outcome against the PRD's intended outcome and verdicts keep/iterate/kill. Never on fabricated data.
- **Three docs**, `INSTALL.md` (setup), `BEGINNERS-GUIDE.md` (concepts), `WORKFLOW.md` (daily use). Plus `CONTRIBUTING.md` for contributing back (code and beyond).

## Quick start

> Assumes a working dev machine (Node 22+, `git`, `gh`, Claude Code, VS Code; `pnpm` only if your project is JS/TS).
> **New to this, or a fresh machine?** Follow `INSTALL.md` instead, it installs everything from zero with checks.

```bash
# 1. Clone and install the system
git clone https://github.com/ivansolic/claude-cofounder.git
cd claude-cofounder
./install.sh                 # add --link for live updates on `git pull`
source ~/.bash_profile       # or ~/.zshrc

# 2. Scaffold and open a project
init-project.sh my-app
cd my-app
gh repo create my-app --private --source=. --remote=origin --push
claude
```

Then, **inside Claude**, install the PM skills once (a separate maintained plugin, you fetch it, you don't bundle it):

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

Finally, configure the project for your stack:

```
/setup-project
```

That's it, start with `/pm-product-discovery:brainstorm-ideas-new` or paste an existing idea/PRD. See `WORKFLOW.md` for the full daily flow.

## What a project looks like

After `init-project.sh my-app`:

```
my-app/
├── CLAUDE.md                 ← project config (stack, commands, conventions, Security & Data)
├── .gitignore
├── .claude/
│   ├── agents/               ← developer, code-reviewer, debugger, architecture-reviewer
│   ├── commands/             ← setup-project, build, merge, learn, knowledge-refresh,
│   │                           outcome, contribute-lesson, commit-push, retro
│   │                           (+ Claude Code's built-in /security-review for sensitive changes)
│   └── tasks/                ← todo.md (active task), lessons.md (corrections)
└── docs/
    ├── prds/                 ← Product Requirements Documents
    ├── stories/              ← user stories
    ├── decisions/            ← Architecture Decision Records
    ├── research/             ← user research notes
    └── templates/            ← ADR template

# The Security Baseline (from your global CLAUDE.md) applies to all code here automatically.
```

PRDs and user stories are generated by the pm-skills plugins and saved as `PRD-NNN-<slug>.md` / `USR-NNN-<slug>.md`.

## Read more

- **`INSTALL.md`**, complete setup from a bare machine, step by step.
- **`BEGINNERS-GUIDE.md`**, the mental model (two hats, two modes, who triggers what) for non-engineers.
- **`WORKFLOW.md`**, the daily operating manual: every command, in order.

## Requirements

- [Claude Code](https://claude.com/claude-code), includes the built-in `/security-review` command this workflow uses
- Node.js 22+, `git`, [`gh`](https://cli.github.com/), required (Claude Code itself runs on Node)
- `pnpm`, **only for JS/TS projects**. Other stacks (Python, Go, …): install that language's tooling instead; you set the real commands via `/setup-project`.
- VS Code (optional but recommended)
- The [pm-skills](https://github.com/phuryn/pm-skills) plugin marketplace (installed once, see Quick start)

## Credits

- **PM workflow** is powered by [**pm-skills**](https://github.com/phuryn/pm-skills) by phuryn, a separate plugin, installed as a dependency (not bundled here).
- **`/security-review`** is a built-in command of Claude Code (Anthropic).

## Contributing

Contributions are welcome, and not just code. Better docs, a clearer beginner explanation, a new preset, a workflow improvement, or a generalizable lesson via `/contribute-lesson` all count. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT, see [`LICENSE`](LICENSE). Use it, fork it, make it yours.
