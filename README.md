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
 brainstorm → PRD → critique →  ──/dev-handoff──→  plan → build → verify
 (optional) user stories                          → code-review
        │                                          → /security-review (sensitive)
   saved in docs/                                  → /commit-push → ship → /retro
                                                            │
                                                       lives on GitHub
```

You run each step; nothing fires blindly. The two automatic guardrails: a TDD skill writes tests first for backend logic, and a security baseline applies to all code.

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
│   │   ├── sprint.md         ← /sprint build stories with agents (single or parallel, you approve)
│   │   ├── dev-handoff.md    ← /dev-handoff PM→Dev transition
│   │   ├── commit-push.md    ← /commit-push with secret-scan + safety checks
│   │   ├── compound.md       ← /compound capture a verified solved problem
│   │   ├── compound-refresh.md ← /compound-refresh audit/refresh the knowledge base
│   │   ├── pulse.md          ← /pulse post-ship outcome check
│   │   └── retro.md          ← /retro end-of-session learning capture
│   ├── agents/               ← subagents (separate-context reviewers)
│   │   ├── code-reviewer.md          ← code, functions, security
│   │   ├── architecture-reviewer.md
│   │   └── design-reviewer.md        ← UI: heuristics, states, a11y, tokens (UI projects)
│   ├── knowledge/            ← compound: reusable solved problems (consulted before non-trivial work)
│   ├── design/               ← tokens.json (DTCG) + README, design-system source of truth (UI projects)
│   ├── tasks/                ← working files: todo.md, lessons.md
│   ├── docs/                 ← document templates: ADR-TEMPLATE.md
│   └── presets/              ← example filled stacks (e.g. angular-nest-mysql.md)
├── skills/
│   ├── test-driven-development/   ← user-level skill (auto-applies to logic)
│   └── ux-design/                 ← user-level skill (auto-applies to UI: heuristics, states, a11y)
└── bin/
    └── init-project.sh       ← scaffolds a new Claude-ready project

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
- **Hybrid agentic build** (`/sprint`), you pick single or parallel agents and how much oversight; each agent takes a story end-to-end (plan, TDD build, verify, review) in its own worktree and presents for your approval before merge. Agents do the work, you hold the gates.
- **Compounding knowledge** (`/compound`, `/compound-refresh`, `knowledge/`), verified solved problems become a reusable, maintained knowledge base that Claude consults before non-trivial work, so the system gets smarter per story.
- **Post-ship outcome loop** (`/pulse`), about a week after shipping, compares the real outcome against the PRD's intended outcome and verdicts keep/iterate/kill. Never on fabricated data.
- **Three docs**, `INSTALL.md` (setup), `BEGINNERS-GUIDE.md` (concepts), `WORKFLOW.md` (daily use).

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
│   ├── agents/               ← code-reviewer, architecture-reviewer
│   ├── commands/             ← setup-project, dev-handoff, commit-push, retro
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
- The **test-driven-development** skill is adapted from the TDD skill in [**obra/superpowers**](https://github.com/obra/superpowers) by Jesse Vincent.
- The **compounding knowledge** design (`/compound`, `/compound-refresh`) is adapted from the compound-engineering plugin by [**EveryInc**](https://github.com/EveryInc/compound-engineering-plugin) (MIT).
- **`/security-review`** is a built-in command of Claude Code (Anthropic).

## License

MIT, see [`LICENSE`](LICENSE). Use it, fork it, make it yours.
