# Beginner's Guide, for non-engineers learning this workflow

This explains the **ideas and the "why"** behind the daily workflow, in plain
language. For the exact commands in order, see `WORKFLOW.md`, this guide is the
*mental model* that makes those commands make sense.

Read it once, slowly. Keep `WORKFLOW.md` open beside it when you actually work.

---

## 1. The big mental model: you wear two hats

This is a **PM → Dev workflow**, run by one person: you. You switch between two
hats, and the whole process is just *knowing which hat you're wearing*.

- 🎩 **PM hat**, decide *what* to build and *why*. Discovery, the PRD, stories,
  acceptance criteria. (This is your home turf already.)
- 🛠️ **Dev hat**, *build and ship* it. Planning, code, tests, review, merge.
  You don't type code, **Claude is your developer**; you direct and approve.

`/odeo:build` is the literal moment you **switch hats**: PM work is done, time to
build. Everything before it is PM; everything after is Dev.

And remember the relationship with Claude:

> Claude is a very capable junior developer. Fast and knowledgeable, but
> over-confident, it will say "done" when it isn't. Your job is the senior's
> job: *"Show me it works."* You don't read every line; you watch the **shape**
> and catch what feels off.

---

## 2. What you already know transfers (don't be intimidated)

The hard part of building software is deciding **what** to build and **what
"done" means**, and that's PM work you already do:

| You already know (PM) | It becomes (in this workflow) |
|---|---|
| Defining the problem & who it's for | The PRD |
| Success metrics | The PRD's outcome criteria |
| Breaking work into pieces | User stories |
| "How do we know it's done?" | Acceptance criteria → the test plan |
| Prioritizing | The order you build stories in |

The **new** part, branches, commits, tests, the actual code, is mostly handled
*by Claude*. You're learning to *direct* that, not to do it by hand. You're not
starting from zero; you're adding a delivery half to skills you already have.

---

## 3. The PM → Dev pipeline (one picture)

```
        🎩 PM HAT                    switch         🛠️ DEV HAT
  (decide what & why)                 hats        (build & ship)
                                        │
 brainstorm → PRD → critique →  ──/odeo:build───→  plan → build → verify
 (optional) user stories                          → review → /odeo:merge
        │                                                        │
   saved in docs/                                          lives on GitHub
```

You move left to right. You never build before the PM side is clear enough.

---

## 4. The very first thing: configure the project

When a project is freshly created, its `CLAUDE.md` (the file that tells Claude
about your project) is full of blanks. **Your first move inside a new project:**

```
/odeo:setup-project
```

Claude interviews you, what's your stack, how do you run tests, any house rules, 
and fills `CLAUDE.md` in for you. (Or you can pick a ready-made preset.) You only
do this **once per project.** After it, Claude knows what it's working with, and
everything else (like the testing habit) reads from that file.

**Working in your own language.** You don't have to work in English. Claude can
write your PRDs, stories, plans, and reviews in German, Croatian, or French, while
the code, the commit messages, and the filenames always stay English. Set it once:

```
/odeo:language de          (German, for this project)
/odeo:language de --global (German, for every project)
/odeo:language             (just show the current setting)
```

Only the *prose* Claude writes for you changes; anything a machine reads stays
English, so nothing leaks into your code. There's also a gentle check that warns
if a document drifts from your setting, it only warns, it never blocks you.

> One honest note: this guide, and all the docs that explain how the system works,
> stay in English on purpose. They describe the mechanics, and the mechanics stay
> English. Your *own* documents follow the language you set.

---

## 5. The vocabulary (the words that scare beginners)

| Word | What it actually is | Everyday analogy |
|---|---|---|
| **Terminal** | The window where you type commands | Talking to your computer in text |
| **Repository (repo)** | A folder that tracks every change | A project folder with infinite undo + full history |
| **Git** | The tool that does that tracking | A time machine for your files |
| **GitHub** | A website that stores your repo online | Google Drive, but for code + history |
| **Branch** | A separate copy where you work safely | A draft you can throw away without touching the real thing |
| **Commit** | A saved checkpoint with a label | "Save game", a snapshot you can return to |
| **Push** | Uploading your commits to GitHub | Syncing your draft to the cloud |
| **Pull Request (PR)** | A proposal to merge your branch into main | "Here's my finished draft, review before it goes live" |
| **Merge** | Folding your branch into the main version | Accepting the draft into the real document |

Don't memorize these. They stick after a week of use.

---

## 6. Commands vs. skills (two kinds of "Claude shortcuts")

You'll see two kinds of capabilities. The difference is simple, **who decides to
use it:**

| | **Command** (e.g. `/odeo:setup-project`, `/odeo:build`, `/odeo:retro`) | **Skill** (e.g. the TDD skill, ux-design) |
|---|---|---|
| Who starts it | **You**, by typing the `/name` | **Claude**, automatically, when the work matches |
| Trigger | Explicit: you choose the moment | Contextual: Claude reads the skill's description and engages when it fits |
| Good for | Deliberate actions you run at a specific point | Background expertise that should "just apply" |
| Example | You type `/odeo:build` when ready to build | You build a backend rule → the TDD skill kicks in on its own |

Think of it as: **commands are buttons you press; skills are reflexes Claude has.**
(Plugin-bundled skills are a special case: skills that ship inside a plugin are
invoked by a namespaced name like `/plugin-name:command`, so they behave like
commands in practice.)

This is why the end-of-session retro is a **command** (`/odeo:retro`) and not a skill:
Claude can't detect that you're wrapping up, so *you* press the button.

---

## 7. The single most important concept: the two modes

Claude works in **two modes**, switched with **`Shift+Tab`**.

### 🟡 Plan mode, "THINK, don't touch"
Claude can read and talk, but **cannot change anything** (no editing, no git, no
creating files). Use it to design and agree on a plan **before** code is written.
The bottom of the screen shows when it's on.

### 🟢 Normal mode, "DO it"
Claude can edit files, run commands, create branches, commit, actually act.

**Why this matters (the question every beginner hits):** some commands need to
*do* things, so they must run in **normal mode**. The clearest case is
`/odeo:build`, it creates a branch and writes a file; plan mode (read-only)
would block it.

> **The golden order:** set the stage first (normal mode), *then* think (plan
> mode), *then* build (normal mode).
>
> `/odeo:build` (DO) → `Shift+Tab` twice to plan mode (THINK) → Claude drafts the plan →
> you **approve** (approving **automatically exits** plan mode) → it BUILDS.

You don't manually switch back: approving the plan exits plan mode for you. And in
Mode A, `/odeo:build` **tells you on screen** to press `Shift+Tab` and **waits**, it won't
write code before you approve, so you can't forget.

If you remember one thing: **set the stage in normal mode, plan in plan mode,
build in normal mode.**

### Three things called "plan", don't mix them up
- **a plan** = the *list of steps* ("1. data model, 2. timer, ..."). Claude writes it; you approve it before code.
- **plan mode** = the `Shift+Tab` *safety switch* that stops Claude from touching files while you review that list. (Optional lock; in Mode B the background agent doesn't use it, it just shows its plan and waits.)
- **`/odeo:plan`** = a *PM skill* (a different thing): it prioritizes and roadmaps which features to build, way upstream, before any code.
- (And **`todo.md`** = the saved checklist that carries your task across sessions; `/odeo:build` writes it for you.)

---

## 8. VS Code, your window into the code (and where to keep working)

When you run `/odeo:build`, it **opens VS Code automatically**. VS Code is just
the **editor where you can *see* the code**, your Claude session stays in the
terminal regardless. The moment it opens, you choose where to work:

- **Option A, stay in your terminal.** Glance at VS Code to read the files
  Claude changes; keep chatting in the terminal you already have.
- **Option B, continue inside VS Code's terminal.** Your session is saved *per
  project*, not locked to a window. In VS Code, open the built-in terminal
  (**View → Terminal**, or `` Ctrl+` ``) and run `claude --continue`, it resumes
  exactly where you left off, now with chat and code in one window.

> ⚠️ Don't run the *same* session in two terminals at once, one at a time.

**No VS Code installed?** No problem, `/odeo:build` notices, skips opening it,
and tells you. The branch and checklist are still created; you work terminal-only.

---

## 9. Starting from something you already have

You rarely start from a blank page, usually you've got an idea or a document
already. You don't have to begin at brainstorm. **Bring what you have into
Claude and jump in at the right step:**

- **A rough idea** → start at brainstorm.
- **Notes / a rough doc** → paste it, ask Claude to turn it into a PRD.
- **A finished PRD** → paste or save it, skip to critique or straight to stories.

How to get a document in:
1. **Paste it** into the chat.
2. **Save it as a file** in the project, then say *"read this file."*
3. **From Notion, Google Docs, or similar tools**, connect them via **MCP** so
   Claude reads your document directly (this needs the tool's MCP connector set
   up once). Copy/paste always works as the simple fallback.

---

## 10. Who triggers what, who writes what, where it's saved

The rule never changes:

> **You *trigger* (type the command). Claude *writes* (produces the content).
> You *approve* (keep it or change it).** Nothing writes itself.

Full chain for a **bigger feature or a project built from scratch**:

| # | Step (hat) | **You trigger** | **Claude writes** | **Saved where** |
|---|---|---|---|---|
| 0 | 🛠️ Configure project | `/odeo:setup-project` | your filled CLAUDE.md | `CLAUDE.md` |
| 1 | 🎩 Brainstorm | `/odeo:brainstorm` | options to choose from | (in chat) |
| 2 | 🎩 PRD | `/odeo:prd` | the PRD document | `docs/prds/PRD-NNN-<slug>.md` |
| 3 | 🎩 Critique | `/odeo:critique` (red team + pre-mortem) | weak spots & risks | (in chat) |
| 4 | 🎩 Stories **+ acceptance criteria** | `/odeo:stories` | each story **with its acceptance criteria** | `docs/stories/USR-NNN-<slug>.md` |
| 5 | 🎩 Pick a story | *(you decide)* |, |, |
| 6 | switch hats + build | `/odeo:build` | branch + checklist, then plan & build | `.claude/tasks/todo.md` |
| 7 | 🛠️ Plan | plan mode → "implement USR-NNN" | the step-by-step plan | `todo.md` |
| 8 | 🛠️ Verify | "walk through each acceptance criterion" | proof each criterion passes | (in chat) |
| 9 | 🛠️ Review | "invoke code-reviewer" | findings to fix | (in chat) |
| 10 | 🛠️ Ship | `/odeo:commit-push`, then `/odeo:merge` | commit + PR merged, cleaned up | GitHub |
| 11 | 🎩 Retro | `/odeo:retro` | lessons routed to the right file, then the gitignored ledger backed up outside the repo | `lessons.md` / CLAUDE.md, plus your backup target |
| 12 | 🎩 Capture / measure | `/odeo:learn` now, `/odeo:outcome` ~a week later | knowledge entry, real outcome verdict | `knowledge/` |

**Key points beginners miss:**

- **Acceptance criteria aren't separate**, they live *inside* each user story.
  When you run `/odeo:stories` (step 4), Claude writes the story
  *and* its acceptance criteria. You review and adjust them.
- **The same criteria come back at the Verify step** (step 8 in this table) as
  your test checklist. Write them well once, use them twice, first as the spec,
  then to prove it's done.
- **Small work skips steps 4-5**, stories are only worth it for bigger features.
  See "When to use stories vs. skip to todo.md" in `WORKFLOW.md`.

---

## 11. The two checklists, and why there are two

- **`todo.md`**, *the HOW, for right now.* Claude's working checklist for the
  task you're building this moment. Changes constantly; survives if you close and
  reopen Claude tomorrow. **Always used.**
- **A user story**, *the WHAT and WHY, permanently.* A small saved spec (with
  acceptance criteria). **Optional**, only for bigger work.

A story *feeds into* `todo.md`: the story is the spec, `todo.md` is the build plan.

---

## 12. "Tests" and "TDD" in plain language

A **test** is a tiny piece of code that checks "does this behave the way I said?"
, e.g. "a password reset link should stop working after 1 hour."

**TDD (Test-Driven Development)** means writing that check **before** the real
code, watching it fail (proving the check is real), then writing code until it
passes. Backwards-sounding, but it stops a whole class of bugs.

In your setup this is a **skill** that applies **automatically for logic**
(backend, rules, calculations) and **skips visual/UI tinkering**. You do nothing, 
Claude engages it when it fits (that's what makes it a skill, not a command). You
can always say "use TDD here" or "skip TDD." The acceptance criteria from step 4
are exactly what those tests are built from.

---

## 13. Security, built in by default

You don't need to be a security expert: a **security baseline applies to all code
automatically** (it lives in your global CLAUDE.md). Claude validates input,
uses safe database queries, keeps personal data out of logs, handles passwords
and secrets properly, without you asking. Your part is small and structured:

- **When setting up a project** (`/odeo:setup-project`), you'll be asked a few plain
  questions: what personal data will this handle? where are your users? will
  people log in? That fills the project's "Security & Data" section.
- **When a feature touches sensitive ground** (login, personal data, payments,
  file uploads), two extra moments exist:
  - at the PRD stage, the critique includes a **security pre-mortem** ("if we
    had a data leak through this, what was the hole?"), so security is designed
    in, not patched on;
  - before committing, you run **`/security-review`**, a dedicated
    vulnerability hunt over the changes, on top of the normal code review.
- **EU users → GDPR**: the system defaults to "user data must be exportable and
  deletable" from day one, because retrofitting that later is painful.

Rule of thumb: if a story involves things users would consider private, expect
the security steps; if it's a button color, they stay out of your way.

---

## 14. How the system gets smarter (so mistakes don't repeat)

Three places hold "lessons," from narrow to broad:

- **`.claude/tasks/lessons.md`**, a running log of corrections *for this project*.
- **Project `CLAUDE.md` → Corrections**, the durable rules for this project.
- **Global `CLAUDE.md`**, rules that apply to *all* your work, everywhere.

A lesson "graduates" upward as it proves it matters everywhere. Capturing them is
the job of **`/odeo:retro`**, run it at the end of a session (it's a command, so *you*
press it; Claude can't tell when you're done). It proposes what you learned and
routes each lesson, with your approval, to the right file. Over weeks this quietly
becomes a record of how *you* like to work, and Claude stops repeating misses.

`/odeo:retro` also **backs those files up outside the repository**. `lessons.md` and
`todo.md` are gitignored, so they never ship in a published snapshot and no commit
carries them either: without a backup they exist only on this machine. At the end
of the retro Claude runs `ledger-backup.sh`, which copies both to the target you
record once as a `ledger_backup:` line in `CLAUDE.local.md` (gitignored, so a
private target never becomes public) or in `CLAUDE.md`, either a git remote and
branch or a folder. If you haven't set one, Claude tells you once and offers to
add the line.

*(Knowledge for other domains, marketing, etc., should live in its own folder
with its own CLAUDE.md, never mixed into the coding setup.)*

---

## 15. When things feel wrong (trust your gut)

You don't need to know code to spot trouble:

| Signal | What to say |
|---|---|
| Claude says "done" but ran nothing | "Prove it works. Show me." |
| It changed files you didn't expect | "Why did you touch that? It wasn't in the plan." |
| The same error twice | "Stop. Enter plan mode and reinvestigate from scratch." |
| You feel confused reading something | "Explain this to me simply." (It often finds its own bug while explaining.) |
| It built more than you asked | "That's more than I asked for, why?" |

**Golden rule when stuck:** don't let Claude push through a failing approach three
times. Stop it, send it back to plan mode, make it rethink.

---

## 16. Your very first feature, slow-motion walkthrough

1. Open the terminal, go to your project, type `claude`.
2. 🛠️ Run `/odeo:setup-project` (first time in this project only) → answer the stack
   questions or pick a preset.
3. 🎩 Plan mode ON (`Shift+Tab` twice). Describe your idea, let Claude give
   options, pick one.
4. 🎩 Run `/odeo:prd`. Answer its questions about the problem.
5. 🎩 Run `/odeo:critique` to poke holes. Fix the PRD.
6. 🎩 (Bigger feature only) `/odeo:stories` → Claude writes stories
   and acceptance criteria. Review them.
7. **switch hats.** Plan mode OFF. Run `/odeo:build`, it makes your branch and
   checklist, and opens VS Code (Section 8, choose where to work). (This is Mode A,
   human-first. Once you trust the flow, Mode B has an architect plan each story,
   you approve the plan, and builder agents execute it and present the result.)
8. 🛠️ Plan mode ON. Ask Claude to plan the build. Read it. Approve it.
9. 🛠️ Plan mode OFF. Let Claude build (it writes tests + code).
10. 🛠️ "Walk through every acceptance criterion." Then "invoke code-reviewer."
    If the change touches login, personal data, payments, or uploads: also run
    `/security-review` (Section 13).
11. 🛠️ Run `/odeo:commit-push`, then `/odeo:merge` (rebase onto main, test, merge PR, clean up).
12. 🎩 Before you stop: run `/odeo:retro`, capture what you learned, and let it back up
    `todo.md` + `lessons.md` outside the repo (git ignores them, so nothing else
    carries them). If you solved something reusable, `/odeo:learn` it.
13. You shipped something. 🎉 About a week later, run `/odeo:outcome` to see if it
    actually solved the problem. Next piece: back to step 7.

---

## 17. Never lost: two helpers that always know the way

- **`/odeo:start`**, type it any time: it reads your project and answers "where am I,
  what's next?" with one concrete next command, plus any due reminders (like
  "you haven't captured lessons this week").
- **Just ask**, you don't need to memorize commands. Ask in plain words ("how do
  I get these stories into Jira?", "what now?") and the built-in guide activates
  by itself: it tells you the route, what's missing first, and offers to start.
  It never runs anything without your yes.

Rule of thumb: lost = `/odeo:start`; have a goal = just ask.

---

## 18. Where to go next

- **`WORKFLOW.md`**, the exact commands, in order, for daily use. Your main map.
- **`INSTALL.md`**, only for first-time setup or fixing a broken install.
- This guide, re-read whenever a concept stops making sense.

It becomes muscle memory in about 2-3 weeks. Until then, keeping all three files
open is completely normal. You've got this.
