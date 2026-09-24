# Odeo

**One person, the whole product team.**

Odeo covers the **entire product development lifecycle**, the work that normally takes three people: the **PM** who decides what to build and why, the **designer** who decides how it looks and behaves, and the **engineer** who builds, tests, secures and ships it. You stay the one who decides. Claude does the execution in all three.

`discovery → PRD → critique → stories → design → build → test → security → ship → measure → learn`

Built for PMs and builders. No engineering background assumed.

---

## Five commands carry the whole lifecycle

You do not memorize sixty commands. Five orchestrators chain the right ones in the right order, and each one **stops at a gate and waits for you** before the next phase begins.

| | Phase | What it chains | You decide |
|---|---|---|---|
| **`/odeo:discover`** | PM, fuzzy idea | brainstorm → personas → journey map → opportunity tree → experiments | which opportunity is worth pursuing |
| **`/odeo:plan`** | PM, portfolio | prioritize → roadmap | what gets built, and in what order |
| **`/odeo:spec`** | PM, one feature | PRD → critique → stories | whether the spec is right before anyone builds |
| **`/odeo:build`** | Design + engineering | plan → build → test → review → merge | the plan, and every merge |
| **`/odeo:go-to-market`** | Launch | positioning → marketing → GTM plan → release notes | the story you take to market |

Each is also runnable on its own. Skip straight to `/odeo:spec` for an incremental feature, or just build for a trivial fix. **Nothing chains past a gate on its own**, which is the subject of the next section.

After shipping, `/odeo:outcome` compares the real result against what the PRD said it would achieve, and `/odeo:learn` banks what you solved so the next story starts smarter.

## It stops asking. It never stops checking.

**Odeo is a graph of loops with you at the gates.** Each node is its own small cycle, plan, execute, verify; the graph is what connects them; and one rule decides which transitions need a human:

> **A gate runs automatically when its decision is derivable from an anchor. It stays yours when it is a judgment about value, or when it cannot be undone.**

Evidence moves the work forward. You command the direction. That is what human-in-command means here, concretely rather than as a slogan: **you are not asked about everything, you are asked about the things only you can answer.**

So `spec-gate` and `merge-gate` never ask: a story cannot enter the build without a fresh passing review, and a branch cannot merge unless **every** review record approves. Approving a plan, merging, and publishing are judgments or are irreversible, so they are always yours.

**The anchors are what keep the checking honest.** Tests that actually ran, scans that actually blocked, review records that name the commit they cover. Guardrails are tagged `[E]` where a mechanism holds them and `[I]` where the model does: an `[E]` is backed by a script with an exit code rather than by the model's goodwill, and an `[I]` is layered with verifiers and your gate on top.

**And the graph is not decoration, it is three things you can verify yourself.** The `architect` has no write tool, so it structurally cannot produce code. The `builder` works in its own git worktree and the reviewer never sees its context, so a review is independent instead of the same agent grading its own homework. Several stories build in parallel, isolated, then rejoin at one gate.

---

## Who it's for

PMs and builders who want to ship real software with Claude Code and don't want to figure out the workflow, testing, and security discipline from scratch. No engineering background assumed, the included `BEGINNERS-GUIDE.md` explains every concept in plain language.

## Install

Odeo is a Claude Code plugin. Nothing to clone, nothing to copy into your home folder.

**Claude Code (terminal) and the Claude desktop app (Code tab):**

```
/plugin marketplace add ivansolic/Odeo
/plugin install odeo@odeo
```

When the plugin is enabled, Claude Code asks once which language Odeo writes your
documents in (English, Deutsch, Hrvatski, Français). Code, filenames and commits always
stay English. Change it any time in `/config` or with `/odeo:language`.

Every Odeo command carries the `odeo:` prefix, because Claude Code namespaces plugin
commands: type `/odeo:build`, `/odeo:prd`, `/odeo:merge`. Type `/odeo:` to see them all.

Then start a project:
- **New project:** `/odeo:new-project my-app`, then open that folder and run `/odeo:setup-project`.
- **Existing codebase:** open it and run `/odeo:setup-project` (it maps the code instead of
  scaffolding over it).

Requires Claude Code 2.1.271 or later. The guards are bash scripts, so on Windows run Claude
Code inside WSL or Git Bash; that path is **not yet verified** end to end.

**Other agents** (Codex CLI and app, Antigravity, claude.ai): not yet. Each needs its own
plugin manifest and a verified port of the hooks, and none ships until it is tested.

**Coming from the old `install.sh` setup?** Its copies in your home folder would load
every skill twice. After installing the plugin, ask Claude to run
`odeo-migrate-legacy.sh` (a dry run that lists what would move), then
`odeo-migrate-legacy.sh --apply`. It moves the copies aside into
`~/.claude/odeo-legacy-<date>/` and deletes nothing. Odeo also reminds you once per
session while they are still there.

## Updating

Third-party marketplaces do not auto-update by default. Turn it on once:
`/plugin` → **Marketplaces** → **odeo** → **Enable auto-update**. Claude Code then checks
after each start and tells you to run `/reload-plugins` when a new version arrived.

Or update by hand:

```
/plugin marketplace update odeo
/plugin update odeo@odeo
```

What updates: every skill, agent, guard script, and the global baseline (it is delivered
by the plugin at session start, not copied into your files). What never changes on an
update: your own `~/.claude/CLAUDE.md`, your projects, and your language setting.

**For maintainers:** users receive a new version only when `version` in
`.claude-plugin/plugin.json` goes up, so bump it with every release, then publish through
`bin/publish-snapshot.sh` (the only sanctioned path to the public repo).

**Working on Odeo itself:** clone the repo and run `claude --plugin-dir .` inside it. The
plugin loads straight from your clone, so edits apply on the next session or
`/reload-plugins`, with no version bump.

## The workflow at a glance

```
        🎩 PM HAT                    switch            🛠️ DEV HAT
  (decide what & why)                 hats           (build & ship)
                                        │
 brainstorm → PRD → critique →  ──/odeo:build───→  plan → build → verify
 (optional) user stories                          → code-review
        │                                          → /security-review (sensitive)
   saved in docs/                                  → /odeo:merge → ship → /odeo:retro
                                                            │
                                          /odeo:outcome (post-ship) → /odeo:learn (capture)
                                                            │
                                                       lives on GitHub
```

You run each step; nothing fires blindly. The two automatic guardrails: a TDD skill writes tests first for backend logic, and a security baseline applies to all code. `/odeo:build` runs human-first or runs a plan-first agent pipeline (the architect plans, you approve, builders execute, one per story in isolated worktrees); you approve at every gate.

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
├── .claude-plugin/
│   ├── plugin.json           ← plugin manifest (version, language dialog)
│   └── marketplace.json      ← makes this repo its own marketplace
├── hooks/
│   ├── hooks.json            ← session start (baseline, language), /odeo:focus fence, end-of-turn sweep
│   └── odeo-context.sh       ← delivers the global baseline to the session and to subagents
├── skills/                   ← slash commands (you type /name); each is a SKILL.md
│   ├── build/                ← /odeo:build stories: human-first, or architect->builder agents (you approve)
│   ├── merge/                ← /odeo:merge rebase onto main, test, merge PR, cleanup
│   ├── learn/                ← /odeo:learn capture a verified solved problem (shows draft first)
│   ├── knowledge-refresh/    ← /odeo:knowledge-refresh audit/refresh the knowledge base
│   ├── outcome/              ← /odeo:outcome post-ship outcome check
│   ├── contribute-lesson/    ← /odeo:contribute-lesson opt-in share to community knowledge
│   ├── commit-push/          ← /odeo:commit-push with secret-scan + safety checks
│   ├── retro/                ← /odeo:retro end-of-session learning capture
│   ├── setup-project/        ← /odeo:setup-project onboarding interview
│   ├── setup-design/         ← /odeo:setup-design design-system/tokens setup (UI)
│   ├── start/                ← /odeo:start you-are-here + next step + due loop reminders
│   ├── guide/                ← auto-activates when you ask "how do I..." (routes goals)
│   ├── prototype/            ← /odeo:prototype build-to-learn (N variants, live compare)
│   ├── improve/              ← /odeo:improve evidence-gated system improvement (A/B, keep/revert)
│   ├── product-signal/       ← /odeo:product-signal weekly user-feedback memo + trend
│   ├── language/             ← /odeo:language set the prose language (code stays English)
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
│   └── agent-reviewer.md     ← scores agent definitions against the agent rubric (docs/agent-rubric.md)
├── bin/                      ← 26 executables: deterministic guards + scaffolding
│   ├── init-project.sh       ← scaffolds the project-specific parts of a new project
│   ├── community-sync.sh     ← clones or refreshes the community knowledge mirror
│   ├── odeo-migrate-legacy.sh ← moves an old install.sh install aside (never deletes)
│   ├── install-git-guards.sh ← installs pre-push + pre-commit hooks into a repo
│   ├── token-report.py       ← session token usage (the one non-bash tool here)
│   │                           gates (exit codes, no judgment; each one blocks something):
│   ├── merge-gate.sh         ← /odeo:merge preconditions (branch, clean tree, EVERY review approves)
│   ├── spec-gate.sh          ← /odeo:build entry gate (a story/PRD needs a fresh passing review)
│   ├── secret-scan.sh        ← staged-secrets gate (blocks the commit)
│   ├── privacy-scan.sh       ← deterministic privacy guard (blocks leaks before sharing)
│   ├── boundary-check.sh     ← DO-NOT-TOUCH path gate (blocks protected-path changes)
│   ├── skills-lint.sh        ← the system's own consistency gate (skills, agents, AGENTS.md,
│   │                           the global baseline, and the system map)
│   ├── coverage-check.sh     ← PRD-requirement coverage check
│   ├── docs-claims-check.sh  ← re-derives the docs' countable claims from the tree
│   ├── focus-check.sh        ← /odeo:focus session edit fence
│   │                           output language (see /odeo:language):
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
│   ├── ledger-backup.sh      ← backs up todo.md + lessons.md, which git deliberately ignores
│   └── session-end-check.sh  ← advisory end-of-session sweep (incl. a stale ledger backup)
├── project-templates/        ← project-specific scaffolding only (not the tools)
│   ├── CLAUDE.md             ← per-project config incl. a Security & Data section
│   ├── knowledge/            ← README for the project knowledge base
│   ├── design/               ← tokens.json (DTCG) + README (UI projects)
│   ├── tasks/                ← working files: todo.md, lessons.md
│   ├── docs/                 ← document templates: ADR-TEMPLATE.md
│   └── presets/              ← example filled stacks (e.g. angular-nest-mysql.md)
├── global/
│   └── CLAUDE.md             ← user-global baseline, delivered at session start by the plugin
├── tests/
│   └── *.test.sh             ← 38 suites, 1261 assertions. 26 of the 26 programs have their
│                               own suite; the remaining suites are cross-cutting rather than
│                               per-program. The number counts the `ok` lines one full run
│                               reports, so it moves with the machine: a skipped case takes its
│                               assertions with it (running as root, a shell that refuses what
│                               a case needs), and a machine that
│                               runs a case this one skips counts MORE. The suites name what they
│                               skipped rather than pass quietly, and the claims check reports the
│                               count as UNVERIFIED there instead of calling it drift
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

# Commands, agents, and skills are provided by the installed plugin, so they are
# available in EVERY project automatically, no per-project copies.
# Security review uses Claude Code's built-in /security-review, driven by our baseline.
```

## What's inside

### Decide what to build
| | What it gives you |
|---|---|
| `/odeo:discover`, `/odeo:brainstorm`, `/odeo:personas`, `/odeo:experiments` | a de-risked direction instead of a hunch, built on named public frameworks (Jobs-to-be-Done, continuous discovery, the four product risks) |
| `/odeo:prd`, `/odeo:critique`, `/odeo:stories` | a spec that survived a red-team and a pre-mortem, split into INVEST stories |
| `/odeo:prioritize`, `/odeo:roadmap` | RICE ordering and a now/next/later roadmap |
| `/odeo:product-signal` | a weekly themed memo of what users actually said, compared to last week |

### Build it
| | What it gives you |
|---|---|
| `/odeo:build` | two modes, always your choice: build live with Claude, or approve a written plan and let agents execute it in isolated worktrees |
| `/odeo:prototype` | 2-3 disposable variants running side by side, so you learn before you commit |
| `ux-design`, `ux-writing`, `/odeo:setup-design` | usability heuristics, every UI state, WCAG AA, and design tokens as the source of truth. Auto-applies to UI, stays out of the way elsewhere |
| `test-driven-development` | tests written before the logic they check. Auto-applies to backend rules, skips UI exploration |
| `/odeo:new-project`, `/odeo:setup-project` | the project scaffold, then an interview that fills in your stack, commands and data model. Once per project |

### Keep it honest
| | What it gives you |
|---|---|
| Security Baseline | OWASP-aligned rules applied to all code, a security pre-mortem at PRD stage, and `/security-review` for sensitive changes |
| Evals | every artifact type has a rubric and a scorer. Reviews ARE the eval record, so regressions are visible |
| Guardrails | `[E]` enforced by a mechanism, `[I]` by instruction. No direct push to main, no secrets in commits, no merge without an approving record |
| `privacy-scan`, `publish-guard` | deterministic gates. Nothing private leaves the machine unscanned, nothing internal reaches the public repo |
| `/odeo:language` | choose the language Odeo writes prose in (English, German, Croatian, French). Code and machine-read surfaces stay English |

### Get smarter each time
| | What it gives you |
|---|---|
| `/odeo:learn`, `knowledge/` | a verified solved problem becomes a reusable entry Claude reads before the next non-trivial task |
| `/odeo:outcome` | a week after shipping, the real result against what the PRD promised. Never on fabricated data |
| `/odeo:retro`, `lessons.md` | corrections become rules, so the same mistake does not return |
| `/odeo:start`, `/odeo:guide` | where you are, what is next, and which command gets you there. Only ever recommends what exists |

Every skill implements a named, public method rather than improvised process: INVEST and the 3 C's for stories, Jobs-to-be-Done for personas, continuous discovery, red-team plus pre-mortem for critique, lean validation across the four product risks, WCAG AA for accessibility, TDD and Conventional Commits for engineering. Hand any artifact to a seasoned PM or engineer and they will recognize the method.

## Your data: what's private, what's shared
- **Your memory and project knowledge stay yours.** Your Claude Code memory (your preferences) and each project's `knowledge/` live on your machine; nothing is uploaded.
- **Install flows one way, to you.** Installing gives you the skills, agents, and baseline. It never sends your code or data anywhere.
- **Community knowledge is opt-in, one lesson at a time.** `/odeo:contribute-lesson` is the *only* outward path: it sanitizes and generalizes a single lesson, runs a deterministic privacy scan (a hard gate), shows you exactly what would leave, and opens a PR only after you approve. A maintainer curates it; once merged, it reaches everyone on their next update (`/odeo:sync-community`). **You give one lesson; you get back the community's curated knowledge.**

## Quick start

> Assumes Claude Code, `git` and [`gh`](https://cli.github.com/) are installed.
> **New to this, or a fresh machine?** Follow `INSTALL.md`, it sets everything up from zero with checks.

Inside Claude Code:

```
/plugin marketplace add ivansolic/Odeo
/plugin install odeo@odeo
/odeo:new-project my-app
```

Open `my-app` in Claude, then configure it for your stack:

```
/odeo:setup-project
```

That's it, start with `/odeo:brainstorm` (our first-party PM skill) or paste an existing idea/PRD. See `WORKFLOW.md` for the full daily flow.

## What a project looks like

After `/odeo:new-project my-app`:

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

# The commands (/odeo:build, /odeo:merge, ...), agents (architect, builder, code-reviewer, ...), and
# auto-skills (TDD, ux-design) come from the installed plugin, available here without
# per-project copies. The Security Baseline applies to all code automatically.
```

PRDs and user stories are generated by the PM skills (`/odeo:prd`, `/odeo:stories`) and saved as `PRD-NNN-<slug>.md` / `USR-NNN-<slug>.md`.

## Read more

- **`INSTALL.md`**, complete setup from a bare machine, step by step.
- **`BEGINNERS-GUIDE.md`**, the mental model (two hats, two modes, who triggers what) for non-engineers.
- **`WORKFLOW.md`**, the daily operating manual: every command, in order.

## Requirements

- [Claude Code](https://claude.com/claude-code) 2.1.271 or later, includes the built-in `/security-review` command this workflow uses
- Node.js 22+, `git`, [`gh`](https://cli.github.com/), required (Claude Code itself runs on Node)
- `pnpm`, **only for JS/TS projects**. Other stacks (Python, Go, …): install that language's tooling instead; you set the real commands via `/odeo:setup-project`.
- VS Code (optional but recommended)

## Credits

- The **first-party PM skills** are built from public, named frameworks: continuous discovery, Jobs-to-be-Done, the Value Proposition Canvas, OKRs, INVEST, the 3 C's, RICE, AARRR, HEART, red-team + pre-mortem, positioning. We wrote every skill ourselves from these public methods; we did not copy any other implementation.
- **`/security-review`** is a built-in command of Claude Code (Anthropic).

## Contributing

Contributions are welcome, and not just code. Better docs, a clearer beginner explanation, a new preset, a workflow improvement, or a generalizable lesson via `/odeo:contribute-lesson` all count. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT, see [`LICENSE`](LICENSE). Use it, fork it, make it yours.
