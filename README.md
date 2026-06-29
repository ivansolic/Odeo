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

This repo **is** the Claude Code plugin. Agents, skills, and the manifest live at
the root; the discipline lives in `AGENTS.md`.

```
claude-cofounder/
├── README.md                 ← you are here
├── INSTALL.md                ← full first-time setup (bare machine → ready)
├── BEGINNERS-GUIDE.md        ← the concepts, in plain language
├── WORKFLOW.md               ← the daily operating manual
├── AGENTS.md                 ← the operating baseline (security, TDD, git, agent-first); read before CLAUDE.md
├── CLAUDE.md                 ← shim: @AGENTS.md + "developing this repo" notes
├── install.sh                ← installs the system (GitHub path; lays the global baseline)
├── .claude-plugin/
│   └── plugin.json           ← marketplace manifest
├── skills/                   ← slash commands (you type /name); each is a SKILL.md
│   ├── build/                ← /build stories: human-first or developer agents (you approve)
│   ├── merge/                ← /merge rebase onto main, test, merge PR, cleanup
│   ├── learn/                ← /learn capture a verified solved problem (shows draft first)
│   ├── knowledge-refresh/    ← /knowledge-refresh audit/refresh the knowledge base
│   ├── outcome/              ← /outcome post-ship outcome check
│   ├── contribute-lesson/    ← /contribute-lesson opt-in share to community knowledge
│   ├── commit-push/          ← /commit-push with secret-scan + safety checks
│   ├── retro/                ← /retro end-of-session learning capture
│   ├── setup-project/        ← /setup-project onboarding interview
│   ├── setup-design/         ← /setup-design design-system/tokens setup (UI)
│   ├── test-driven-development/ ← auto-applies to logic (RED-GREEN-REFACTOR)
│   ├── ux-design/            ← auto-applies to UI (heuristics, states, a11y)
│   └── ux-writing/           ← auto-applies to UI copy (microcopy, errors, NN/g)
├── agents/                   ← subagents (separate-context executors)
│   ├── developer.md          ← builds one story end-to-end in its own worktree
│   ├── code-reviewer.md      ← code, functions, security
│   ├── debugger.md
│   ├── architecture-reviewer.md
│   └── design-reviewer.md    ← UI: heuristics, states, a11y, tokens
├── bin/
│   ├── init-project.sh       ← scaffolds the project-specific parts of a new project
│   └── privacy-scan.sh       ← deterministic privacy guard (blocks leaks before sharing)
├── project-templates/        ← project-specific scaffolding only (not the tools)
│   ├── CLAUDE.md             ← per-project config incl. a Security & Data section
│   ├── knowledge/            ← README for the project knowledge base
│   ├── design/               ← tokens.json (DTCG) + README (UI projects)
│   ├── tasks/                ← working files: todo.md, lessons.md
│   ├── docs/                 ← document templates: ADR-TEMPLATE.md
│   └── presets/              ← example filled stacks (e.g. angular-nest-mysql.md)
├── global/
│   └── CLAUDE.md             ← user-global baseline laid into ~/.claude by install.sh
├── tests/
│   └── privacy-scan.test.sh  ← tests for the privacy guard
└── docs/
    └── privacy-guard.md      ← design of the privacy guard

# Commands, agents, and skills are provided by the installed plugin (or install.sh),
# so they are available in EVERY project automatically, no per-project copies.
# Security review uses Claude Code's built-in /security-review, driven by our baseline.
```

## What's inside

- **Agent-first, plugin-native**, the repo is a Claude Code plugin: skills orchestrate, agents execute. The operating baseline lives in `AGENTS.md` (read before `CLAUDE.md`); the tools (commands, agents, skills) install once and are available in every project.
- **Security, built in**, a comprehensive, OWASP-aligned **Security Baseline** (in `AGENTS.md` and `global/CLAUDE.md`) applied to all code; a per-project **Security & Data** section (PII inventory, auth model, GDPR); a security pre-mortem at the PRD stage; the discipline is also embedded in the skill/agent bodies so it holds for plugin-only installs; and Claude Code's **built-in `/security-review`** for sensitive changes.
- **Project scaffolding** (`init-project.sh`), one command creates the project-specific parts (config, docs structure, task files, knowledge base, design tokens). The commands/agents/skills come from the installed plugin, so there are no per-project copies to drift.
- **`/setup-project`**, interviews you about your stack, commands, and data, then fills the project config. Run once per project.
- **First-party PM skills**, a full set built from public frameworks (credited by name), spanning the lifecycle: **discovery** (`/brainstorm`, `/personas`, `/interview-synthesis`, `/competitor-analysis`, `/market-segments`, `/opportunity-solution-tree`, `/customer-journey-map`, `/experiments`), **strategy & viability** (`/vision`, `/strategy`, `/value-proposition`, `/okrs`, `/business-model`, `/pricing`), **planning** (`/prioritize`, `/roadmap`, `/stakeholder-map`), **spec** (`/prd`, `/critique`, `/stories`), **metrics & analytics** (`/metrics`, `/ab-test`, `/cohorts`, `/query`), and **launch & growth** (`/positioning`, `/marketing`, `/gtm-plan`, `/release-notes`, `/growth-loops`, `/battlecard`, `/product-name`). Four **orchestrators** chain them with human gates: **`/discover` -> `/plan` -> `/spec` -> `/go-to-market`**. The [pm-skills](https://github.com/phuryn/pm-skills) plugin is an optional alternative.
- **TDD skill**, auto-applies test-first to backend logic, stays out of the way on UI.
- **Design layer**, two auto-applying skills, `ux-design` (usability heuristics, UX laws, UI states, accessibility) and `ux-writing` (microcopy: button/link labels, error and empty-state copy, voice and tone, NN/g-based); **design tokens** (`design/tokens.json`, DTCG) as the styling source of truth, set up by `/setup-design`; a `design-reviewer` subagent that reviews layout, states, a11y, tokens, and microcopy. Optional per project (`init-project.sh --no-ui` skips it).
- **Hybrid agentic build** (`/build`), one entry, two modes. Human-first: branch, seed todo, open editor, plan and build with you step by step. Agents: dispatch a `developer` per story, each end-to-end (plan, TDD build, verify, review) in its own git worktree, single or parallel, with the oversight you pick. Either way you hold the gates. **`/merge`** then integrates an approved branch with a clean linear history (rebase onto main, tests, merge, cleanup).
- **Compounding knowledge** (`/learn`, `/knowledge-refresh`, `knowledge/`), verified solved problems become a reusable, maintained knowledge base that Claude consults before non-trivial work, so the system gets smarter per story. `/learn` shows the draft before writing.
- **Community knowledge** (`/contribute-lesson`), opt-in, share a sanitized, generalized lesson with the shared knowledge base so the whole system gets smarter; on update you get back the curated knowledge of all contributors. Approval-gated, nothing leaves your machine without your OK.
- **Privacy guard** (`bin/privacy-scan.sh`), a deterministic scan (emails, secrets/tokens, local paths, IPs, and your own deny-list terms) that runs as a hard gate before anything is shared via `/contribute-lesson`. The safety net under the model's sanitization and your approval, so private data can't leak by accident, including other users' data once this is a product. Your private terms live in a local `~/.claude/privacy-denylist.txt`, never in a repo.
- **Post-ship outcome loop** (`/outcome`), about a week after shipping, compares the real outcome against the PRD's intended outcome and verdicts keep/iterate/kill. Never on fabricated data.
- **Three docs**, `INSTALL.md` (setup), `BEGINNERS-GUIDE.md` (concepts), `WORKFLOW.md` (daily use). Plus `CONTRIBUTING.md` for contributing back (code and beyond).

## Your data: what's private, what's shared
- **Your memory and project knowledge stay yours.** Your Claude Code memory (your preferences) and each project's `knowledge/` live on your machine; nothing is uploaded.
- **Install flows one way, to you.** Installing gives you the skills, agents, and baseline. It never sends your code or data anywhere.
- **Community knowledge is opt-in, one lesson at a time.** `/contribute-lesson` is the *only* outward path: it sanitizes and generalizes a single lesson, runs a deterministic privacy scan (a hard gate), shows you exactly what would leave, and opens a PR only after you approve. A maintainer curates it; once merged, it reaches everyone on their next update (`/sync-community`). **You give one lesson; you get back the community's curated knowledge.**

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

Then, **inside Claude**, configure the project for your stack:

```
/setup-project
```

That's it, start with `/brainstorm` (our first-party PM skill) or paste an existing idea/PRD. See `WORKFLOW.md` for the full daily flow.

> **Optional:** prefer the [pm-skills](https://github.com/phuryn/pm-skills) plugin for the PM phase? Install it once inside Claude (`/plugin marketplace add phuryn/pm-skills`, then `/plugin install pm-execution@pm-skills` and the other `pm-*` packages, then `/reload-plugins`). Our first-party PM skills are the default; pm-skills is an alternative, not required.

## What a project looks like

After `init-project.sh my-app`:

```
my-app/
├── CLAUDE.md                 ← project config (stack, commands, conventions, Security & Data)
├── .gitignore
├── .claude/
│   └── tasks/                ← todo.md (active task), lessons.md (corrections)
├── knowledge/                ← reusable solved problems for this project
├── design/                   ← tokens.json + README (UI projects only)
└── docs/
    ├── prds/                 ← Product Requirements Documents
    ├── stories/              ← user stories
    ├── decisions/            ← Architecture Decision Records
    ├── research/             ← user research notes
    └── templates/            ← ADR template

# The commands (/build, /merge, ...), agents (developer, code-reviewer, ...), and
# auto-skills (TDD, ux-design) come from the installed plugin, available here without
# per-project copies. The Security Baseline applies to all code automatically.
```

PRDs and user stories are generated by the PM skills (`/prd`, `/stories`) and saved as `PRD-NNN-<slug>.md` / `USR-NNN-<slug>.md`.

## Read more

- **`INSTALL.md`**, complete setup from a bare machine, step by step.
- **`BEGINNERS-GUIDE.md`**, the mental model (two hats, two modes, who triggers what) for non-engineers.
- **`WORKFLOW.md`**, the daily operating manual: every command, in order.

## Requirements

- [Claude Code](https://claude.com/claude-code), includes the built-in `/security-review` command this workflow uses
- Node.js 22+, `git`, [`gh`](https://cli.github.com/), required (Claude Code itself runs on Node)
- `pnpm`, **only for JS/TS projects**. Other stacks (Python, Go, …): install that language's tooling instead; you set the real commands via `/setup-project`.
- VS Code (optional but recommended)
- Optional: the [pm-skills](https://github.com/phuryn/pm-skills) plugin, if you prefer it over the built-in PM skills

## Credits

- The **first-party PM skills** are built from public, named frameworks, credited in each skill: Teresa Torres (continuous discovery), Jobs-to-be-Done (Christensen), Marty Cagan (vision/strategy), Osterwalder (Value Proposition Canvas), Doerr/Grove (OKRs), Wake (INVEST), Jeffries (3 C's), RICE (Intercom), McClure (AARRR), Google (HEART), April Dunford (positioning). We wrote our own skills from these public methods; we did not copy any other implementation.
- [**pm-skills**](https://github.com/phuryn/pm-skills) by phuryn is supported as an optional alternative for the PM phase (a separate plugin, not bundled).
- **`/security-review`** is a built-in command of Claude Code (Anthropic).

## Contributing

Contributions are welcome, and not just code. Better docs, a clearer beginner explanation, a new preset, a workflow improvement, or a generalizable lesson via `/contribute-lesson` all count. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT, see [`LICENSE`](LICENSE). Use it, fork it, make it yours.
