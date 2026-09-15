# Odeo

**The workflow system that turns one person into a product team.**

The whole product lifecycle, with you directing Claude: idea → discovery → PRD → design → build → test → secure → ship → measure → learn. **Built for PMs and builders.**

---

## What is this?

Odeo is an opinionated workflow system for [Claude Code](https://claude.com/claude-code). It covers the **whole product lifecycle**, from first idea and discovery, through PRD, design, build, test, and security, to ship, and then measuring the outcome and feeding what you learn back in. You direct Claude as your developer instead of writing code by hand. It bundles the global instructions, project scaffolding, PM workflow, a test-driven-development habit, a security baseline, and an end-to-end daily process into one install.

You bring the *what* and *why* (the product thinking). The system makes Claude deliver the *how* (the code), with guardrails so the result is actually solid.

**Why a human stays in command:** you hold the context advantage, you understand your users, market, and constraints in ways no model does. The approval gates aren't a brake on the system; they're where its best information enters. One person, the force of a whole product team, and you stay in command.

## Who it's for

PMs and builders who want to ship real software with Claude Code and don't want to figure out the workflow, testing, and security discipline from scratch. No engineering background assumed, the included `BEGINNERS-GUIDE.md` explains every concept in plain language.

**Runs on:** macOS and Linux (developed and tested there). Windows is expected to work
under WSL or Git Bash but is not yet verified; the toolchain is bash, so PowerShell cannot
run it. See INSTALL.md.

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

You run each step; nothing fires blindly. The two automatic guardrails: a TDD skill writes tests first for backend logic, and a security baseline applies to all code. `/build` runs human-first or runs a plan-first agent pipeline (the architect plans, you approve, builders execute, one per story in isolated worktrees); you approve at every gate.

## Repo structure

This repo **is** the Claude Code plugin. Agents, skills, and the manifest live at
the root; the discipline lives in `AGENTS.md`.

```
Odeo/
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
│   ├── build/                ← /build stories: human-first, or architect->builder agents (you approve)
│   ├── merge/                ← /merge rebase onto main, test, merge PR, cleanup
│   ├── learn/                ← /learn capture a verified solved problem (shows draft first)
│   ├── knowledge-refresh/    ← /knowledge-refresh audit/refresh the knowledge base
│   ├── outcome/              ← /outcome post-ship outcome check
│   ├── contribute-lesson/    ← /contribute-lesson opt-in share to community knowledge
│   ├── commit-push/          ← /commit-push with secret-scan + safety checks
│   ├── retro/                ← /retro end-of-session learning capture
│   ├── setup-project/        ← /setup-project onboarding interview
│   ├── setup-design/         ← /setup-design design-system/tokens setup (UI)
│   ├── start/                ← /start you-are-here + next step + due loop reminders
│   ├── guide/                ← auto-activates when you ask "how do I..." (routes goals)
│   ├── prototype/            ← /prototype build-to-learn (N variants, live compare)
│   ├── improve/              ← /improve evidence-gated system improvement (A/B, keep/revert)
│   ├── product-signal/       ← /product-signal weekly user-feedback memo + trend
│   ├── language/             ← /language set the prose language (code stays English)
│   ├── test-driven-development/ ← auto-applies to logic (RED-GREEN-REFACTOR)
│   ├── ux-design/            ← auto-applies to UI (heuristics, states, a11y)
│   ├── ux-writing/           ← auto-applies to UI copy (microcopy, errors)
│   └── ...                   ← + the full PM set (discovery, strategy, planning,
│                                metrics, launch), catalog: docs/system-map.md
├── agents/                   ← subagents (separate-context executors)
│   ├── architect.md          ← plans a story as a contract (read-only, plan-only)
│   ├── builder.md            ← executes the approved plan in its own worktree
│   ├── codebase-analyst.md   ← maps an existing codebase (read-only)
│   ├── debugger.md           ← root-cause investigation, minimal fix + regression test
│   ├── code-reviewer.md      ← code, functions, security
│   ├── architecture-reviewer.md ← architecture, and the plan reviewer
│   ├── design-reviewer.md    ← UI: heuristics, states, a11y, tokens
│   ├── pm-reviewer.md        ← scores PM documents against rubrics
│   ├── skill-reviewer.md     ← scores skills against the authoring standard
│   ├── agent-reviewer.md     ← scores agent definitions against the agent rubric
│   └── agent-rubric.md       ← the rubric agent-reviewer scores against
├── bin/                      ← 22 executables: deterministic guards + scaffolding
│   ├── init-project.sh       ← scaffolds the project-specific parts of a new project
│   ├── install-git-guards.sh ← installs pre-push + pre-commit hooks into a repo
│   ├── token-report.py       ← session token usage (the one non-bash tool here)
│   │                           gates (exit codes, no judgment; each one blocks something):
│   ├── merge-gate.sh         ← /merge preconditions (branch, clean tree, EVERY review approves)
│   ├── spec-gate.sh          ← /build entry gate (a story/PRD needs a fresh passing review)
│   ├── secret-scan.sh        ← staged-secrets gate (blocks the commit)
│   ├── privacy-scan.sh       ← deterministic privacy guard (blocks leaks before sharing)
│   ├── boundary-check.sh     ← DO-NOT-TOUCH path gate (blocks protected-path changes)
│   ├── skills-lint.sh        ← the system's own consistency gate (skills, agents, AGENTS.md,
│   │                           the global baseline, and the system map)
│   ├── coverage-check.sh     ← PRD-requirement coverage check
│   ├── focus-check.sh        ← /focus session edit fence
│   │                           output language (see /language):
│   ├── resolve-language.sh   ← resolves the effective language (project > global > en)
│   ├── language-guard.sh     ← keeps machine-read surfaces English (enforced)
│   ├── language-status.sh    ← reports the effective language and where it came from
│   ├── set-global-language.sh, set-project-language.sh  ← the writers
│   ├── prose-language-check.sh ← advisory warning on a prose-language mismatch
│   │                           publishing (the only sanctioned path out):
│   ├── publish-snapshot.sh   ← builds a clean public snapshot (content, never history)
│   ├── publish-guard.sh      ← fail-closed: nothing internal or unclassified ships
│   ├── share-tunnel.sh       ← time-boxed public tunnel for a preview
│   ├── second-opinion.sh     ← the sanctioned path for a paid cross-model review
│   └── session-end-check.sh  ← advisory end-of-session sweep
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
│   └── *.test.sh             ← 27 suites, 827 assertions. 21 of the 22 programs have their
│                               own suite (session-end-check.sh has none yet); the remaining
│                               suites are cross-cutting rather than per-program
└── docs/
    ├── system-map.md         ← the catalog: every command/agent/loop by phase
    ├── eval-framework.md     ← rubrics, scorers, eval records, regression
    ├── plan-format.md        ← the architect's plan contract format + rubric
    ├── skill-authoring-standard.md ← how skills are written (+ skill rubric)
    ├── invariants.md         ← the invariants the lint enforces
    ├── privacy-guard.md      ← design of the privacy guard
    ├── second-opinion-protocol.md ← when and how a paid cross-model review runs
    ├── internal-paths.txt    ← denylist: what never leaves the machine
    ├── public-paths.txt      ← allowlist: what may be published (fail-closed)
    ├── checklists/           ← recorded audit results (alignment, Anthropic practices)
    └── examples/             ← worked examples of the artifacts this system produces

# Commands, agents, and skills are provided by the installed plugin (or install.sh),
# so they are available in EVERY project automatically, no per-project copies.
# Security review uses Claude Code's built-in /security-review, driven by our baseline.
```

## What's inside

- **Agent-first, plugin-native**, the repo is a Claude Code plugin: skills orchestrate, agents execute. The operating baseline lives in `AGENTS.md` (read before `CLAUDE.md`); the tools (commands, agents, skills) install once and are available in every project.
- **Security, built in**, a comprehensive, OWASP-aligned **Security Baseline** (in `AGENTS.md` and `global/CLAUDE.md`) applied to all code; a per-project **Security & Data** section (PII inventory, auth model, GDPR); a security pre-mortem at the PRD stage; the discipline is also embedded in the skill/agent bodies so it holds for plugin-only installs; and Claude Code's **built-in `/security-review`** for sensitive changes.
- **Project scaffolding** (`init-project.sh`), one command creates the project-specific parts (config, docs structure, task files, knowledge base, design tokens). The commands/agents/skills come from the installed plugin, so there are no per-project copies to drift.
- **`/setup-project`**, interviews you about your stack, commands, and data, then fills the project config. Run once per project.
- **Output language** (`/language`), choose the language the system writes human-facing prose in, English by default, plus German, Croatian, and French, as a global default with a per-project override. Code and every machine-read surface stay English: filenames, branch names, and commit type/scope by a deterministic guardrail, commit subjects and code identifiers by instruction and review. An advisory check warns when a document's prose drifts from the setting. Built for people who think in their own language but ship in English.
- **First-party PM skills**, a full set built from public, named frameworks, spanning the lifecycle: **discovery** (`/brainstorm`, `/personas`, `/interview-synthesis`, `/competitor-analysis`, `/market-segments`, `/opportunity-solution-tree`, `/customer-journey-map`, `/experiments`), **strategy & viability** (`/vision`, `/strategy`, `/value-proposition`, `/okrs`, `/business-model`, `/pricing`), **planning** (`/prioritize`, `/roadmap`, `/stakeholder-map`), **spec** (`/prd`, `/critique`, `/stories`), **metrics & analytics** (`/metrics`, `/ab-test`, `/cohorts`, `/query`), and **launch & growth** (`/positioning`, `/marketing`, `/gtm-plan`, `/release-notes`, `/growth-loops`, `/battlecard`, `/product-name`). Four **orchestrators** chain them with human gates: **`/discover` -> `/plan` -> `/spec` -> `/go-to-market`**.
- **TDD skill**, auto-applies test-first to backend logic, stays out of the way on UI.
- **Design layer**, two auto-applying skills, `ux-design` (usability heuristics, UX laws, UI states, accessibility) and `ux-writing` (microcopy: button/link labels, error and empty-state copy, voice and tone); **design tokens** (`design/tokens.json`, DTCG) as the styling source of truth, set up by `/setup-design`; a `design-reviewer` subagent that reviews layout, states, a11y, tokens, and microcopy. Optional per project (`init-project.sh --no-ui` skips it).
- **Hybrid agentic build** (`/build`), one entry, two modes, always your choice. **With me**: branch, seed todo, open your editor, plan and build together, file by file, live. **For me**: the `architect` (read-only) plans each story as a written contract, an `architecture-reviewer` independently checks the plan, **you approve it**, then a `builder` per story executes it exactly in its own git worktree (single or parallel), reviewers score the result, and you gate again. A builder never runs without an approved plan, and **`/merge`** runs only when you say so, integrating each approved branch with a clean linear history (rebase onto main, tests, merge, cleanup).
- **Compounding knowledge** (`/learn`, `/knowledge-refresh`, `knowledge/`), verified solved problems become a reusable, maintained knowledge base that Claude consults before non-trivial work, so the system gets smarter per story. `/learn` shows the draft before writing.
- **Community knowledge** (`/contribute-lesson`), opt-in, share a sanitized, generalized lesson with the shared knowledge base so the whole system gets smarter; on update you get back the curated knowledge of all contributors. Approval-gated, nothing leaves your machine without your OK.
- **Privacy guard** (`bin/privacy-scan.sh`), a deterministic scan (emails, secrets/tokens, local paths, IPs, and your own deny-list terms) that runs as a hard gate before anything is shared via `/contribute-lesson`. The safety net under the model's sanitization and your approval, so private data can't leak by accident, including other users' data once this is a product. Your private terms live in a local `~/.claude/privacy-denylist.txt`, never in a repo.
- **Post-ship outcome loop** (`/outcome`), about a week after shipping, compares the real outcome against the PRD's intended outcome and verdicts keep/iterate/kill. Never on fabricated data.
- **Never lost** (`/start` + `/guide`), `/start` reads your project and says where you are, what's next, and which recurring loops are due; and whenever you ask "how do I do X here?", the `/guide` advisor auto-activates and routes your goal to the right commands, prerequisites first. It only recommends what actually exists.
- **Grounded in established practice**, the skills implement named, public frameworks rather than improvised process: stories use **INVEST** and the **3 C's**; personas center on **Jobs-to-be-Done**; discovery follows **continuous-discovery** and **diverge-then-converge** ideation; critique combines a **red-team** pass with the classic **pre-mortem**; experiments follow **lean validation** across the **four product risks** (value, usability, feasibility, viability); accessibility gates on **WCAG AA**; engineering discipline uses **TDD** and **Conventional Commits**. You can hand any artifact to a seasoned PM or engineer and they'll recognize the method.
- **Build-to-learn** (`/prototype`), spin up 2-3 disposable working variants (each in its own worktree, own port, running server), compare them live, kill the weak ones, and promote the winner's learnings into the real, fully-rigorous build. Prototypes never ship raw.
- **Evals built in**, every artifact type has a rubric and a scorer: reviewers score code, UI, PM documents, and skills (review = eval, records in `docs/evals/`), regressions are visible, and `/improve` changes the system itself only when an A/B test proves the new version better, you keep or revert.
- **Guardrails, enforced where it matters**, one `## Guardrails` section in `AGENTS.md` tags every hard rule as mechanism-enforced or instructed: no direct pushes to main (git hook), no secrets in commits (scan blocks the commit), no merges without a review record (gate script), protected paths can't be touched (boundary check), nothing private leaves the machine unscanned.
- **Weekly listening** (`/product-signal`), your users' feedback becomes a themed memo compared against last week: what's new, what's growing, what faded, feeding `/prioritize` and `/roadmap` with reality.
- **The docs, by job**, `INSTALL.md` (setup, bare machine to ready), `BEGINNERS-GUIDE.md` (the concepts, in plain language), `WORKFLOW.md` (daily use, what to type), `AGENTS.md` (the operating baseline every agent reads), `ROADMAP.md` (direction), and `CONTRIBUTING.md` for contributing back (code and beyond).

## Your data: what's private, what's shared
- **Your memory and project knowledge stay yours.** Your Claude Code memory (your preferences) and each project's `knowledge/` live on your machine; nothing is uploaded.
- **Install flows one way, to you.** Installing gives you the skills, agents, and baseline. It never sends your code or data anywhere.
- **Community knowledge is opt-in, one lesson at a time.** `/contribute-lesson` is the *only* outward path: it sanitizes and generalizes a single lesson, runs a deterministic privacy scan (a hard gate), shows you exactly what would leave, and opens a PR only after you approve. A maintainer curates it; once merged, it reaches everyone on their next update (`/sync-community`). **You give one lesson; you get back the community's curated knowledge.**

## Quick start

> Assumes a working dev machine (Node 22+, `git`, `gh`, Claude Code, VS Code; `pnpm` only if your project is JS/TS).
> **New to this, or a fresh machine?** Follow `INSTALL.md` instead, it installs everything from zero with checks.

```bash
# 1. Clone and install the system
git clone https://github.com/ivansolic/Odeo.git
cd Odeo
./install.sh                 # asks your doc language once (change it any time with /language); --link for live updates on `git pull`
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

# The commands (/build, /merge, ...), agents (architect, builder, code-reviewer, ...), and
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

## Credits

- The **first-party PM skills** are built from public, named frameworks: continuous discovery, Jobs-to-be-Done, the Value Proposition Canvas, OKRs, INVEST, the 3 C's, RICE, AARRR, HEART, red-team + pre-mortem, positioning. We wrote every skill ourselves from these public methods; we did not copy any other implementation.
- **`/security-review`** is a built-in command of Claude Code (Anthropic).

## Contributing

Contributions are welcome, and not just code. Better docs, a clearer beginner explanation, a new preset, a workflow improvement, or a generalizable lesson via `/contribute-lesson` all count. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT, see [`LICENSE`](LICENSE). Use it, fork it, make it yours.
