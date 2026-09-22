# WORKFLOW.md, Daily Operating Manual

How you work with Claude from idea to shipped feature.
Keep this open until the rhythm becomes muscle memory (~2-3 weeks).

> New to coding, or a concept here doesn't make sense? Read
> **`BEGINNERS-GUIDE.md`** first, it explains the ideas behind these commands
> (the two hats, the two modes, what a branch is, who triggers what) in plain
> language. This file is the *what to type*; that file is the *why*.

The workflow (the phases, the discipline, the rhythm) is yours and stays fixed.
The PM thinking inside Phase 1 runs on our **first-party PM skills** (`/brainstorm`,
`/prd`, `/critique`, `/stories`, ...).

---

## Returning to Work (day 2 and beyond)

Your setup is installed once and stays, global `CLAUDE.md`, the skills and agents
(including the PM skills), templates, and `init-project.sh` are all permanent. You
do NOT reinstall any of that to start working again. You just open a project.

### Start a brand-new project
```bash
cd ~/Desktop                 # or wherever you keep projects
init-project.sh my-project   # scaffolds the full structure
cd my-project
gh repo create my-project --private --source=. --remote=origin --push
claude
```
Then, **first thing inside Claude**, configure the project for your stack:
```
/setup-project
```
Claude interviews you (stack, commands, conventions) and fills in `CLAUDE.md`, 
or you start from a preset in `~/.claude-templates/presets/`. Once per project.
Then begin Phase 1 (brainstorm → PRD → critique → stories) below.

### Come back to an existing project
```bash
cd ~/Desktop/my-project
claude --continue     # resumes your last session in this folder
# or: claude --resume   (pick from a list of past sessions)
# or: claude            (fresh session)
```
`.claude/tasks/todo.md` carries the active task state across sessions, so even a
fresh `claude` picks up where you left off.

### You do NOT need to redo
- ❌ Copy CLAUDE.md / templates
- ❌ Re-run `install.sh` (the skills/agents stay installed)
- ❌ Touch `~/.bash_profile`

### If commands seem missing in a session
```
# our skills/agents live in ~/.claude/skills and ~/.claude/agents; re-run install.sh if missing.
/reload-plugins           # if a plugin's commands stop responding
```

For first-time machine setup (or troubleshooting an install), see `INSTALL.md`.

---

## The Big Picture

```
IDEA (fresh or imported)
 │
 ▼
┌─────────────────────────────────────────────┐
│ PHASE 1: PM (discovery & specification)     │
│ /brainstorm → /prd → /critique → /stories   │
│ (first-party PM skills)                     │
└──────────────────┬──────────────────────────┘
                   ▼
               /build
                   │
                   ▼
┌─────────────────────────────────────────────┐
│ PHASE 2: DEVELOPMENT (one story at a time)  │
│ /build → plan → implement → verify → review │
│   with me (live)      ·  for me (agents)    │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ PHASE 3: CLOSE (per story)                  │
│ /merge (rebase, test, PR) → /outcome → /learn │
└─────────────────────────────────────────────┘
```

**You drive every step manually.** Claude does NOT move to the next step on its
own, you decide when an output is good enough and when you advance. Each
`/skill` and each subagent is invoked explicitly by you. The only place Claude
loops on its own is implementation (Phase 2.2), and even that starts when you
say go.

One Claude session carries through all phases. VS Code sits beside the terminal
as your editor, it's a window, not a destination.

---

## IMPORTING EXTERNAL CONTENT (before Phase 1)

Already have a PRD, research, feature requests, or notes from elsewhere?
Don't start from zero, bring it in and continue from where you are.

### An external PRD or document

**Option A, paste it directly:**
> "Here is my existing PRD: [paste text]. Evaluate it and tell me what's missing."

**Option B, the file is already local:**
> "Read docs/prds/PRD-001-name.md and evaluate it."

**Option C, Notion / Google Docs / any tool:**
Copy the content → paste into Claude. There's no direct integration, copy/paste
is enough.

After importing, continue normally, usually jump to step **1.3 (critique)** or
**1.4 (user stories)**, skipping the steps you already did outside.

### External feature requests or user feedback

```
/interview-synthesis
```
Paste the list, Claude extracts opportunities and themes; then `/prioritize` to triage.

### External interview notes or research

```
/interview-synthesis
```
Paste the notes; Claude turns them into structured insights and opportunities.

---

## PHASE 1: PM, From Idea to Stories

PM here is driven by our **first-party PM skills** (built from public frameworks,
credited by name). You keep the `docs/` folder as the home for the output, save
PRDs and stories into `docs/prds/PRD-NNN-<slug>.md` and
`docs/stories/USR-NNN-<slug>.md` so the rest of the workflow lines up.

### 1.1 Brainstorm

Start Claude in your project, plan mode ON (`Shift+Tab` twice).

```
/brainstorm
```

It diverges into many distinct options before converging, problem-first. Push
back, combine options, iterate until the idea has shape. (For discovery support:
`/personas`, `/interview-synthesis`, `/competitor-analysis`, `/market-segments`;
for direction: `/vision`, `/strategy`.)

### 1.2 Write the PRD

When the idea has shape:

```
/prd
```

Walk through, in this order:
1. **The problem**, who hurts, how much, why now
2. **The outcome**, measurable success criteria
3. **Hypotheses**, what you're assuming and how you'd know you're wrong

⚠️ Don't fill in solutions before the problem is solid. If you catch yourself
jumping to features, that's the signal to slow down.

Save the result into `docs/prds/PRD-NNN-<slug>.md` (next free number, lowercase
hyphenated slug) so the folder convention stays intact.

### 1.3 Critique it

```
/critique
```

Two passes in one skill: a **red-team** that attacks the assumptions, logic, and
scope, then a **pre-mortem**, "it's 6 months later and this failed, why?", giving
the top 3 failure modes ranked by likelihood, each with the leading signal you'd
see early.

**Security pre-mortem (required for sensitive features).** If the feature
touches authentication, personal data (PII), payments, file uploads, or anything
users would consider private, extend the pre-mortem with a security lens:

> "It's 6 months later and we had a breach or data leak through this feature.
> What was the hole? Where does this data live, who can reach it, and what's the
> worst path in? List the top 3 attack/leak scenarios and what the design must
> include to close them."

Capture the answers in the PRD (they become requirements and acceptance
criteria, not afterthoughts). This is where architecture-level security is
decided, code review later can't fix a design that stores or exposes the wrong
thing.

Revise the PRD based on the findings. Re-run if the changes were large.

### 1.4 Break into user stories

```
/stories
```

> "Order them by dependency, what must be built first. Save them into
> docs/stories/ as USR-NNN-<slug>.md."

Review what comes out. Good stories are:
- **Small**, one story = 0.5 to 2 days of work. Bigger → split it.
- **Independent** where possible, minimal blocking between stories
- **Testable**, acceptance criteria you can verify objectively

#### What a good story looks like

```markdown
## Story
As a registered user
I want to reset my password via email
So that I can regain access without contacting support

## Acceptance Criteria
- [ ] "Forgot password" link on login page sends reset email within 30s
- [ ] Reset link expires after 1 hour
- [ ] Used reset link cannot be reused
- [ ] Password must meet strength requirements (shown inline)
- [ ] User is logged in automatically after successful reset
```

Notice: every criterion is **observable and binary**, it either works or it
doesn't. "User-friendly flow" is NOT an acceptance criterion. "Error message
appears within the form, not as an alert" IS.

**For UI stories**, fold the design expectations into the same acceptance
criteria, the **user flow**, the **screens** touched, and **which states** apply
(loading / empty / error / no-results, plus focus/disabled where relevant). Keep
them behavioral and token-independent ("shows an empty state with an invite
action"), not visual ("uses blue"), the look comes from tokens at build time.
These ride in the normal AC list; you don't tag them as "design" vs "functional."

### 1.5 Commit the PM work

```
/commit-push
```

PM artifacts are code. They get committed like code (the command will put you
on a `docs/` branch if you're on main).

---

### The full PM set (by lifecycle phase)

**Discovery & research:** `/brainstorm` · `/personas` (JTBD) · `/interview-synthesis` · `/competitor-analysis` · `/market-segments` · `/opportunity-solution-tree` (Torres) · `/customer-journey-map` · `/experiments` (assumption tests, Ries + Cagan's 4 risks)
**Strategy & viability:** `/vision` · `/strategy` (Cagan) · `/value-proposition` · `/okrs` · `/business-model` (Lean/Business Model Canvas) · `/pricing` (value-based)
**Planning (portfolio):** `/prioritize` (RICE) · `/roadmap` (now/next/later) · `/stakeholder-map`
**Spec (feature):** `/prd` · `/critique` (red-team + pre-mortem) · `/stories` (INVEST + 3 C's)
**Metrics & analytics:** `/metrics` (North Star) · `/ab-test` · `/cohorts` · `/query` (NL->SQL)
**Launch & growth:** `/positioning` (Dunford) · `/marketing` · `/gtm-plan` · `/release-notes` · `/growth-loops` · `/battlecard` · `/product-name`

**Orchestrators (chain the above, with a human gate between each step):**
`/discover` (front funnel) -> `/plan` (prioritize -> roadmap) -> `/spec` (prd -> critique -> stories) -> `/go-to-market` (positioning -> marketing -> gtm-plan -> release-notes).

Browse everything with `/`. All first-party (built from named public frameworks).

### The order, at a glance
The lifecycle runs top-down by altitude: understand, decide, define, build, measure, launch.
```
NEW PRODUCT (full):
  /discover  ->  strategy (/vision /strategy /market-segments /business-model /pricing)
            ->  /plan (/prioritize -> /roadmap)
            ->  per epic in roadmap order: /spec (/prd -> /critique -> /stories)
            ->  /build -> /merge -> /outcome   (loop to /plan for the next epic)
            ->  /go-to-market when an epic is ready for users
INCREMENTAL FEATURE: skip to /spec -> /build -> /outcome
TRIVIAL FIX:         just /build
```
**Worked example (new product: freelancer billable-time tracker):** `/discover` finds the
opportunity (invoicing is a chore) -> `/plan` ranks epics and roadmaps them (NOW capture
time, NEXT invoicing) -> `/spec` the MVP "capture time" (`/prd` -> `/critique` -> `/stories`
ordered by dependency: data model -> timer -> tagging) -> `/build` each -> `/outcome` ->
loop to `/plan` for invoicing -> `/go-to-market` at launch.

**Two altitudes of prioritization (don't confuse them):** `/prioritize` + `/roadmap` rank
*which epics* (value, portfolio level); `/stories` orders *which stories within an epic* (by
dependency, not value). Every step is human-gated; merge-to-main, ship, and send-out always
need your approval.

---

## When to Use Stories vs. Skip to todo.md

User stories are an **optional spec layer**, not a default. Decide with one
question:

> **"Is this more than ~1-2 days of work, OR does it split into independent
> pieces?"**
> Yes → use stories. No → skip them.

**Key point: `todo.md` is used in BOTH cases.** It's the execution layer and it
never goes away, it always holds the implementation plan for whatever you're
building right now. A story is just an optional spec *above* todo.md, never a
replacement for it.

- **With stories:** PRD → stories → `/build` (per story) seeds the plan
  into `todo.md` → build
- **Without stories:** PRD → plan mode drafts the plan straight into `todo.md`
  → build

### The three tracks

| Scenario | Path |
|---|---|
| **New product / concept from scratch** (greenfield) | Brainstorm → (strategy/vision) → **PRD scoped to a thin MVP slice** → critique → **stories, ordered by dependency** → build story-by-story |
| **Incremental feature** on an existing product | PRD (light) → **todo.md** → build (skip stories) |
| **Trivial fix** | **todo.md** only, fast lane (skip PRD + stories) |

### Greenfield: why stories matter most here

Building from scratch is the scenario where stories help **most**, not least, a
new product is one vision that splits into many independent pieces (data model,
auth, core flow, settings, polish…). Stories keep that sprawling build into
small, separately reviewable steps.

The trap to avoid: writing one massive PRD for the *entire* product, then
generating 40 stories at once. Instead, scope the PRD to a **thin vertical slice
(the MVP)** and let stories sequence that slice:

```
/brainstorm                → shape the concept
/vision (optional)         → the north star
/prd                       → PRD for the MVP slice ONLY
/critique                  → red-team + pre-mortem, pull it apart
/stories                   → decompose the slice, order by dependency
   USR-001 data model  →  USR-002 auth  →  USR-003 core flow  → ...
/build (per story) → review → /merge → next story
```

Each merged PR is one visible step toward the MVP.

### Fast lane (trivial changes)

For a typo, a copy tweak, a one-line fix, skip the PRD and stories entirely:

```
git checkout -b fix/<short-description>
# make the change → "Invoke code-reviewer" (still worth it) → /commit-push
/merge   # rebase onto main, test, open + merge PR, cleanup
```

The one rule that always holds, in every track: **never batch multiple stories
into one branch.** One story = one branch = one PR.

---

## PHASE TRANSITION

### Set up the design system (once, before building UI)

If this project has UI and you haven't done it yet, run, **after** the PM phase
(so it's informed by the PRD/personas/strategy), **before** building UI:

```
/setup-design
```

It ingests your existing tokens (or a Figma export), or proposes a starter from
your product context, then wires token compilation to your stack. One-time per
project. (Skip for API-only/backend projects.) Tokens become the styling source
of truth; the `ux-design` skill applies them when you build.

### /build

When stories are ready and you're switching to building, `/build` is the single
entry. It has two modes; you pick at the start:

- **With me (Mode A).** You and Claude build one story together, step by step,
  with you reviewing at each stage. This folds in the old PM→Dev handoff: it
  verifies the spec, creates the branch, seeds `todo.md`, and opens the editor
  before you plan and build. Best while you're learning the rhythm.
- **For me (Mode B).** A fixed, always-gated pipeline: the `architect` (read-only)
  plans your stories as a written contract (`docs/plans/`), **you approve the
  plan**, then a `builder` per story executes it exactly, each in its own isolated
  git worktree (TDD per your dev-rigor setting, verify, review), and presents the
  result for your approval. A builder never runs without an approved plan, that
  gate is structural. Optionally open the worktree(s) in your editor to watch.
  Best once you trust the flow.

  **One story at a time is the default.** Parallel (several agents at once) is
  opt-in and only offered when the stories you picked are *independent* (Claude
  runs an overlap check first). To trigger it, either name multiple stories when
  you invoke (`/build USR-001 USR-002 in parallel`) or just say "parallel" when
  Claude asks. If you say "go", you get them one at a time. Keep parallel to 2 to 4
  so your review stays the bottleneck, not a rubber stamp.

```
/build
```

> ⚠️ **Run `/build` in normal mode, not plan mode.** It creates branches and
> writes `todo.md`, actions that plan mode (read-only) would block. In Mode A,
> enter plan mode (`Shift+Tab` twice) only *after* it sets up, for step 2.1.
> Order: **build setup (do) → plan mode (think) → exit plan mode (build).**

In Mode A it will:
1. Ask which spec you're implementing
2. Verify the spec is actually ready (problem, outcome, scope all filled)
3. Write a handoff summary into `.claude/tasks/todo.md` (so context survives
   even if you start a fresh session later)
4. Create the feature branch from up-to-date main
5. Open VS Code (as editor, your Claude session stays in this terminal)

Then continue with 2.1 below. In Mode B the agents run that pipeline for you and
you jump to reviewing their results (2.3 onward) before `/merge`.

---

## Parallel work (the agent fleet)

The principle: **one focused, isolated context per task beats one session juggling
everything** (less clutter in the agent's head means better work, "context minimalism").
A widely shared productivity tip: **spin up 3 to 5 git worktrees at once, each running its
own session in parallel.** A **git worktree** is one repo checked out into several separate
folders, each on its own branch, so agents never trample each other's files.

You can run a fleet two ways (both give the same win, focused + isolated agents):

```
Way 1, ONE session, background agents (Mode B parallel, easiest):
  [tab: claude]   (architect planned, you approved the plans)
      ├─ dispatches → builder A → own worktree (background)   (builder has isolation: worktree)
      ├─ dispatches → builder B → own worktree (background)
      └─ you watch + approve results in one place (the agent view, see below)

Way 2, MANY sessions, one per task (hands-on; the classic "several tabs" setup):
  [tab 1: claude --worktree feature-auth]      → you drive auth
  [tab 2: claude --worktree feature-billing]   → you drive billing
  (each gets its own isolated checkout under .claude/worktrees/<name>/)
```

Built-in Claude Code tools (use these, don't rebuild them; all work in any terminal, no desktop app needed):
- **`claude agents`** opens the **agent view**: a full-screen terminal dashboard of your background sessions (which are running / need input / done / their PR status). Enter to attach, Space to peek, type to dispatch a new one. Your main fleet control.
- **`claude --bg "task"`** starts a background agent from the shell; **`claude --worktree <name>`** opens an interactive session in its own isolated worktree; **`claude attach|logs|stop <id>`** manages a background session.
- Our `builder` agent has `isolation: worktree`, so dispatched agents are isolated automatically. To check what's safe to parallelize, run **`worktree-parallel-check`** first.

**When with-me vs for-me:** clear + independent work -> for me (agents, faster, parallel); fuzzy / needs your steering -> with me (build together). The mode is asked on every /build, never assumed. The isolation benefit ("no context-mixing = better output") holds for both; Mode A just lets you steer live.

**When to parallelize, and the gotchas:**
- Only **independent** tasks (different files/modules). `worktree-parallel-check` / the `/build` overlap check warns first; coupled work stays sequential, or you get merge conflicts.
- Each worktree needs its **own `node_modules` and `.env`** (not shared); don't run two dev servers on the **same port**.
- Integrate **serially**: `/merge` rebases each branch onto an up-to-date main, one at a time, so conflicts surface cleanly.
- Keep each agent's context **lean** (let it pull from `knowledge/` on demand; context minimalism).
- The human floor holds: every branch still merges only with your approval.

---

## PHASE 2: DEVELOPMENT, One Story at a Time

### The iron rule
**One story = one branch = one PR.** Never batch multiple stories into one
branch. Small changes are reviewable; big ones hide bugs.

### 2.1 Start the story

Plan mode ON (`Shift+Tab` twice), then:

> "Implement story docs/stories/USR-003-password-reset.md.
> Read it fully, then draft the implementation plan in todo.md."

Claude reads the story, drafts a step-by-step plan with checkable items.
**You review the plan before any code is written.** Ask questions. Change steps.
Only approve when you understand what's about to happen.

### 2.2 Implementation

Switch out of plan mode (Shift+Tab) and let Claude work.

With `CLAUDE_CODE_AUTO_VERIFY=1` set, Claude automatically loops:
generate → lint → typecheck → test → self-correct → repeat until green.

**TDD-lite (automatic):** for logic with clear rules, backend, API, services,
validation, calculations, bug fixes, the `test-driven-development` skill engages
on its own: it turns each acceptance criterion into a failing test *before* the
implementation, then drives it green (RED → GREEN → REFACTOR). You don't invoke
it. For UI/component layout, visual exploration, prototypes, and trivial fixes it
stays out of the way (tests come after, if at all). If you ever want to force it
on or off for a given piece, just say so.

Your job during this: read what Claude is doing. You don't need to understand
every line, but watch for:
- Files being touched that the plan didn't mention → ask why
- The same error appearing twice → say "Stop. Re-enter plan mode and
  reinvestigate the root cause."
- Claude saying "done" without showing verification → ask "Prove it works."

### 2.3 Verify against acceptance criteria

When Claude says the story is implemented:

> "Walk through every acceptance criterion in the story one by one.
> For each: demonstrate it passes, or mark it as failing."

This is the moment the story format pays off, the criteria ARE the test plan.
Anything failing → back to implementation.

### 2.4 Code review

> "Invoke the code-reviewer subagent on these changes."

The reviewer returns a verdict (APPROVE / APPROVE WITH COMMENTS / REQUEST
CHANGES) with findings sorted Critical → Important → Nitpicks.

**Rule: fix all Critical and Important findings. Nitpicks are your call.**
Skipping the review or ignoring Criticals = removing your own safety net.

**For UI changes, also run the design review:**

> "Invoke the design-reviewer subagent on these changes."

`code-reviewer` covers logic/security; `design-reviewer` covers UI only, 
usability heuristics, all states (loading/empty/error + hover/focus/disabled),
accessibility, design-token adherence (no hardcoded styles), and **microcopy**
(button/link labels, error and empty-state copy, the `ux-writing` standards). Same
Critical → Important → Nitpicks rule. Skip it for backend-only changes.

### 2.4b Security review (for sensitive changes)

If the change touches **auth, user input handling, file uploads, payments, or
data access**, run the built-in security review before committing:

```
/security-review
```

This is a dedicated vulnerability hunt over the pending changes, deeper on
security than code-reviewer's general sweep (injection, authz gaps, secrets
exposure, unsafe handling). Treat its findings like code-review Criticals: fix
before commit.

Also, if this story **added or updated dependencies**: run `pnpm audit` (or your
package manager's equivalent) and resolve criticals/highs before shipping.

For ordinary changes (UI layout, copy, internal refactors with no input/data
surface), skipping this step is fine, code-reviewer still covers the basics.

### 2.5 Commit and push

```
/commit-push
```

The command checks you're on a branch, scans for secrets, runs lint+typecheck,
proposes a conventional commit message, and pushes.

### 2.6 Architecture decisions along the way

If during implementation you hit a structural question ("should this be a
separate module?", "REST or WebSocket here?"):

> "Invoke the architecture-reviewer subagent on this question: [describe]"

If the decision is significant, capture it:

> "Create an ADR for this decision using docs/templates/ADR-TEMPLATE.md"

Future-you (and future teammates) will thank you for the WHY being written down.

---

## PHASE 3: CLOSE, Per Story

### Definition of Done (every story)

`/stories` gives each story its own acceptance criteria, but not a DoD checklist,
this is yours, the same gate for every story before it's "done":

- [ ] Code merged to main via PR
- [ ] Tests added (unit + e2e where relevant)
- [ ] Documentation updated (if user-facing or API change)
- [ ] No new linter or typecheck errors
- [ ] Acceptance criteria all met
- [ ] Reviewed by the `code-reviewer` subagent (or a human reviewer)
- [ ] `/security-review` passed, required if the change touches auth, input,
      uploads, payments, or data access
- [ ] No new `pnpm audit` criticals/highs, required if dependencies changed
- [ ] No PII or secrets in logs, commits, or error messages introduced by this story

### 3.1 Integrate with /merge

When the story is reviewed and you approve it, run:

```
/merge
```

It does the git mechanics for you, on a clean linear history:
1. Fetches the latest `origin/main`, and checks by ancestry that it really is your
   upstream. When neither side is an ancestor of the other and the project publishes
   through a separate step, that remote is a publication, not an upstream: it integrates
   into your local `main` instead and tells you so, rather than rebasing onto it
2. Rebases your branch on top of it (resolving conflicts by intent + tests, asking
   you if genuinely ambiguous; it never weakens a test to resolve)
3. Runs tests + typecheck, must be green
4. Updates the branch with `--force-with-lease` if it was already pushed
5. Opens and squash-merges the PR
6. Cleans up: back to main, pulls, deletes the branch local + remote

Even solo, read your own PR diff once before approving the merge. You'll catch
things. With multiple stories in flight, `/merge` integrates them one at a time so
conflicts surface and resolve cleanly.

### 3.2 Close the loop in the project

> "Mark story USR-003 as Done. Add the Review section to todo.md:
> what shipped, what was harder than expected, any follow-ups."

### 3.3 Capture reusable knowledge (if you solved something worth keeping)

If the story involved solving a non-trivial, verified problem that is likely to
recur, capture it so the system reuses it next time:

```
/learn
```

It quality-gates (verified + non-trivial + reusable), shows you the drafted entry,
and writes it to `knowledge/` only after you approve. Periodically, run
`/knowledge-refresh` to audit that base against the current code and prune dead
weight.

If a lesson is **universal** (not specific to this project), Claude may offer
`/contribute-lesson`, an opt-in way to share a sanitized, generalized version with
the community knowledge base. You see exactly what would be shared and approve
before anything leaves your machine; in return, future updates bring back the
curated knowledge of all contributors.

### 3.4 Lessons (only if corrections happened)

If you corrected Claude during the story:

> "Update lessons.md with what went wrong. If the rule applies beyond this
> task, propose an update to CLAUDE.md too."

Review the proposed rule before it's written. This is how Claude gets
measurably better on YOUR project over time.

### 3.5 End-of-session retro (a 2-minute habit)

Before you close a working session, run:

```
/retro
```

It looks back over the session, proposes the lessons worth keeping, and routes
each (with your approval), project-specific → `.claude/tasks/lessons.md`; a rule
that applies to all your work → a proposed global CLAUDE.md update.

Then it backs up the build ledger, which is the part git deliberately cannot do.
`.claude/tasks/todo.md` and `lessons.md` are gitignored so they never reach a
published snapshot, which also means no commit carries them: lose the machine and
you lose the task state and every correction the project has learned. `/retro`
runs `ledger-backup.sh`, which copies both files to the target recorded as a
`ledger_backup:` line in `CLAUDE.local.md` (read first, the right place for a
private target) or `CLAUDE.md`, either a git remote and branch or a directory,
and in both cases **outside this repository**. If no target is recorded it says
once what is at stake and offers to add the line, then drops it for the session.
Every failure has its own exit code and the "last backup" stamp is written only
after a verified success, so a backup that silently stopped working reports as
behind instead of passing as done.

> ⚠️ `/retro` is something **you invoke** when wrapping up, Claude can't detect
> that you're ending a session, so nothing fires it automatically.

This turns the learning files from "filled only on correction" into "reviewed
every session." Over weeks, `lessons.md` and your CLAUDE.md files quietly become
a record of how *you* like to work, and Claude stops repeating the same misses.

### Then: next story. Back to 2.1.

---

## POST-SHIP: Did it actually work? (about a week later)

Shipping is not the finish line, the question the PRD asked was whether this
*solves the problem*. About a week after a feature is live (enough time for real
data), run:

```
/outcome
```

It reads the PRD's intended outcome and success criteria, gathers **real** signals
only (analytics you provide or a connector, error logs, your own observations),
compares actual vs intended, and gives a verdict: **keep / iterate / kill /
need-more-data**.

> ⚠️ It never fabricates data. If the feature isn't shipped, or there's no real
> data yet, the honest output is "need-more-data, here's what to instrument," not
> invented numbers. Fake outcomes would poison `knowledge/`.

With your approval, the result feeds `/learn` (what worked or failed in
production) and promotes or demotes related `knowledge/` entries, so the knowledge
base is judged by real outcomes, not just whether code matched. This closes the
loop: idea → ship → measure → learn → better next story.

---

## The loops, at every timescale

One picture explains how the whole system improves itself. Loops are nested by
how fast they turn, and every one has a verifier and a stop:

```
MINUTES   the agent's inner loop     build -> test -> fix, to the success-signal
          (builder; verifier = tests/criteria; stop = all green or ~3 tries)
HOURS     your steering loop         plan gate -> review -> approve/redirect
          (you direct and taste; you don't QA line by line)
DAYS      the users' loop            /outcome + /product-signal -> back into /plan
          (real signals decide what's next; never fabricated)
WEEKS     the system learns          /learn, /knowledge-refresh, /improve
          (knowledge compounds; skills/rubrics only change with evidence)
```

Why a human stays in the loop: you hold the **context advantage**, you understand
your users, market, and constraints in ways no model does. The gates aren't a
brake on the system; they're where its best information enters.

### 🔁 Recurring loops, when each runs (nudge reminds you; YOU run them)

| Loop | Natural moment | Interval |
|---|---|---|
| `/knowledge-refresh` | session start (quiet, only if due) | every 2-4 weeks |
| `/improve` | when evals show repeated drops | after ~3-5 same-criterion drops |
| `/product-signal` | first session after the interval | ~weekly |
| `/learn` + `/retro` | after `/merge`, or when you say you're wrapping up | per story / session |
| `/outcome` | you decide, ~a week after shipping | per shipped feature |

Rules: at most ONE nudge, short, easy to decline; nothing ever runs on a silent
schedule (no scheduler exists, that's a guardrail).

**Background option:** read-only loops (`/product-signal`, analysis parts of
`/improve` and `/knowledge-refresh`) can run in the background while you work,
they read and think in their own isolated worktree and STOP at "here's my
proposal, approve?". Applying any change waits for your gate, at a calm moment
(after `/merge` or at the next session start), never mid-build.

---

## Working With Claude, Rules of Thumb

### Trust but verify
Claude is a very talented junior who always sounds confident. Your job is the
senior's job: "How do you know it works?" / "Did you actually run it?"

### Signals Claude made a mistake
1. Says "done" without running anything → demand proof
2. Uses a function you can't find defined anywhere → likely hallucinated
3. Code works but does MORE than you asked → scope creep, ask why
4. Same fix attempted twice with small variations → it's guessing; force re-plan
5. You read the code and feel confused → not your fault; ask Claude to explain
   (it often finds its own bug while explaining)

### When things go sideways
- **STOP early.** The global CLAUDE.md tells Claude to re-plan when stuck,
  but you can force it: "Stop. Enter plan mode. Reinvestigate from scratch."
- **Don't let it push through.** Three failed attempts at the same problem
  means the approach is wrong, not the execution.

### Session management
- One session per day per project is normal
- If context gets long and Claude gets "forgetful": `/compact` (compresses
  history) or start fresh, `todo.md` carries the active task state across
  sessions, that's exactly why it exists
- Resume a previous session anytime: `claude --continue` (last session) or
  `claude --resume` (pick from list)
- Works identically in native terminal and VS Code terminal, they have the
  same rights; permissions belong to your user account, not the terminal window

### Skill & subagent invocation (your current level)
Invoke explicitly, every time:
- PM thinking (Phase 1) → our PM skills (`/brainstorm`, `/prd`, `/critique`,
  `/stories`, `/prioritize`, ...)
- `code-reviewer` subagent → before every commit
- `architecture-reviewer` subagent → any decision touching multiple modules

After ~2 months, when you can tell when reviews get skipped, you can start
trusting auto-invocation.

---

## Quick Reference Card

| I want to... | I do... |
|---|---|
| Start a new project | `init-project.sh <name>` → `gh repo create ...` → `claude` |
| See where you are + what's next | `/start` (you-are-here + due loop reminders) |
| Ask "how do I do X here?" | just ask, `/guide` auto-activates (routes goal -> commands) |
| Try an idea by building it | `/prototype` (N disposable variants, live compare, keep the learnings) |
| Improve a skill/rubric with evidence | `/improve` (A/B test, you keep or revert) |
| Weekly listen to your users | `/product-signal` (themes + trend vs last week) |
| Configure a new project (stack, commands) | `/setup-project` (once per project, first thing) |
| Change the language of generated documents | `/language` (shows it) · `/language de` (this project) · `/language de --global` (all projects). Moves PROSE only; code, commits and filenames stay English, the prose check is advisory and never blocks |
| Import an existing PRD | Paste it, or "Read docs/prds/... and evaluate it" |
| Triage external requests | `/interview-synthesis` then `/prioritize` |
| Run the whole discovery cycle | `/discover` (brainstorm -> personas -> journey -> OST -> experiments) |
| Explore an idea | `/brainstorm` |
| De-risk before building | `/experiments` (assumption tests) |
| Plan the portfolio | `/plan` (`/prioritize` -> `/roadmap`) |
| Spec one feature | `/spec` (`/prd` -> `/critique` -> `/stories`) |
| Check what's safe to build next / in parallel | `worktree-parallel-check` (read-only; recommends + warns on overlap) |
| Watch the agent fleet (no desktop app) | `claude agents` (terminal dashboard) |
| Write a PRD | `/prd` |
| Challenge a PRD | `/critique` (red-team + pre-mortem) |
| Create stories | `/stories` |
| Prioritize epics / roadmap | `/prioritize` (RICE) · `/roadmap` (now/next/later) |
| Take it to market (launch) | `/go-to-market` (positioning -> marketing -> gtm-plan -> release-notes) |
| Price it / model the business | `/pricing` · `/business-model` |
| Analyze a test / retention | `/ab-test` · `/cohorts` · `/query` |
| Speed up something slow | `/optimize` (measure -> change -> re-measure; never guess) |
| Set up the design system | `/setup-design` (once, after PM, before building UI) |
| Switch to building / build a story | `/build` (with me: live together, or for me: agents on your approved plan; you approve at the gate) |
| Check it's really done | "Walk through every acceptance criterion" |
| Review code | "Invoke code-reviewer on these changes" |
| Review UI | "Invoke design-reviewer on these changes" (states, a11y, tokens, heuristics) |
| Security-check a sensitive change | `/security-review` (auth, input, uploads, payments, data access) |
| Audit dependencies | `pnpm audit` after adding/updating packages |
| Commit + push | `/commit-push` |
| Integrate an approved branch | `/merge` (rebase onto main, test, merge PR, cleanup) |
| Ship it to the platform | `/deploy` (re-checks green, deploys, verifies; after `/merge`) |
| Get PRs tested automatically | `/ci` (sets up GitHub Actions, ~2 minutes) |
| Market/web research with sources | `/research` (market size, competitors, pricing, verifying a claim) |
| Docs drifted from the code | `/sync-docs` (reconciles README/docs/CLAUDE.md against what actually ships) |
| Want an independent check from another vendor's model | `/second-opinion-code` · `/second-opinion-plan` · `/second-opinion-pm` · `/second-opinion-design`. **Paid**, opt-in, never automatic: an external model reviews, then OUR reviewer weighs its findings. See `docs/second-opinion-protocol.md` |
| Record a decision | "Create an ADR for this decision" |
| Teach Claude a lesson | "Update lessons.md so you don't repeat this" |
| Wrap up a session / capture learnings | `/retro` |
| Capture a reusable solved problem | `/learn` (verified + non-trivial only; shows draft first) |
| Keep the knowledge base current | `/knowledge-refresh` |
| Share a lesson with the community | `/contribute-lesson` (opt-in, sanitized, approval-gated) |
| Pull the latest community knowledge | `/sync-community` (vs `/plugin update` for the tooling) |
| Check a shipped feature's outcome | `/outcome` (about a week after shipping, real data only) |
| Resume yesterday's session | `claude --continue` |
| Claude is stuck/looping | "Stop. Enter plan mode. Reinvestigate from scratch." |
