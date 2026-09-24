---
description: Use when a project needs configuring: a new project before any building, CLAUDE.md still full of placeholders, or the user asks to set up or reconfigure the project, its stack, commands, or conventions.
---

Goal: turn the placeholder `CLAUDE.md` into a real, project-specific config by
**interviewing the user**, never guess the stack. One question group at a time,
wait for answers, confirm before writing.

## 0. Does the idea exist yet? (before any stack question)
Setup answers HOW we build; it cannot precede knowing WHAT we build. If the user
hasn't stated a direction yet (or says "we still need to brainstorm"), say so
plainly and route first:
> "Stack and conventions follow from what we're building. Want to shape the idea
>  first (`/odeo:brainstorm`, or `/odeo:prototype` to feel a concrete feature), and come
>  back to setup once there's a direction? Or if you already know, tell me in a
>  sentence and we'll set up now."
Never march a user without a direction through stack questions.

## 1. Check current state, and pick the path: NEW or EXISTING project
Read `CLAUDE.md`. If the Stack/Commands/Conventions sections are already filled
(no `[...]` placeholders), tell the user it looks configured and ask whether they
want to reconfigure or stop.

Then look at the repo: is there already a real codebase here (source files beyond
the scaffold)? Ask plainly:
> "Is this a **new project** (we start from zero) or an **existing codebase**
>  (I should learn how it's already built)?"

**EXISTING path (onboarding an established codebase):**
1. **Dispatch the `codebase-analyst` agent** (read-only, own context) to map the
   repo: stack, architecture, modules, conventions, test state, risky areas, and
   proposed DO-NOT-TOUCH boundaries.
2. Save its map as `docs/codebase-map.md`.
3. **Confirm the boundaries with the user** (plain language): "these interfaces/
   folders look like they shouldn't be touched, correct? anything to add?" The
   confirmed list is binding for the architect and builder.
4. Fill CLAUDE.md **from the map** (their real stack, their conventions), then
   continue the interview below ONLY for what the map couldn't tell (Security &
   Data facts, house rules, preferences). Never impose our conventions over
   theirs; the codebase's existing style wins.
5. Dev-rigor default (step H below) comes from the test state: few or no tests
   -> suggest `Test-after`.

**NEW path:** continue with step 2 (preset or interview) as usual.

## 2. Preset shortcut, only when one actually fits
Check `ls ${CLAUDE_PLUGIN_ROOT}/project-templates/presets/` QUIETLY. Mention a preset ONLY if it
matches the stack the user has described or implied (e.g. they said "Angular and
NestJS" and `angular-nest-mysql` exists):
> "There's a ready-made preset for that stack, want me to start from it and
>  tweak, instead of the questions?"
If nothing matches (or the user hasn't named a stack yet), say nothing about
presets, advertising an irrelevant preset only confuses, and go straight to the
interview (step 3).

If they take a preset:
- Copy it over `CLAUDE.md`: `cp ${CLAUDE_PLUGIN_ROOT}/project-templates/presets/<name>.md CLAUDE.md`
- Jump to step 5 (confirm + per-project details).

## 3. Interview, ask in small groups, wait for each answer

Ask these groups one at a time. Keep questions plain; a non-engineer should be
able to answer. Offer examples. Accept "I don't know / none" gracefully.

**A. What is this project?**
- One or two sentences: what it is, who it's for, the outcome it produces.

**B. Frontend** (or "none / API-only"):
- Framework + version? Language? State/data approach? UI library? Test tool?

**C. Backend** (or "none / frontend-only"):
- Framework? Language + runtime? Database? ORM/data access? Validation? Auth? API style?

**D. Tooling:**
- Package manager? Monorepo tool (or none)? Deployment target?

**E. Architecture**, the user chooses. Present the options with neutral
trade-offs and let them decide. Do **not** steer toward any option. Only if the
user explicitly asks for your recommendation, give it, with your reasoning.

> "How should the software be structured? Each has trade-offs:
>
> - **Monolith**, one app, one codebase, one deploy. Fewest moving parts; one
>   thing to build, run, and deploy. Everything scales together as a unit.
> - **Modular monolith**, one deploy, with clear internal module boundaries.
>   More upfront structure; a future split is easier if you ever need it.
> - **Microservices**, multiple independently deployed services. Independent
>   scaling and parallel teams, at the cost of operational complexity (networking,
>   multiple deploys, cross-service debugging).
> - **Serverless (functions + managed services)**, no servers to run; pay per
>   use, fast to ship small pieces. Cold starts, vendor lock-in, and harder local
>   dev / long-running flows.
>
> Which one do you want? (Happy to give my recommendation and why, if you'd like.)"

Record the user's choice in the `## Architecture` section of CLAUDE.md. Do not
add a recommendation there unless the user asked for one.

**F. Commands** (critical, the TDD skill and auto-verify loop use these):
- How do you start the app (dev)? Run tests? Run backend tests separately? Lint?
  Typecheck? Build? Any DB commands (migrate/generate/studio)?
- If the user doesn't know, infer sensible defaults from the stack and the
  package manifest (e.g. read `package.json` scripts) and confirm them.
- **Record test commands in their NON-INTERACTIVE form** (`vitest run`, never
  bare `vitest`; `--watch=false` where needed): a watch-mode command hangs any
  automated run forever, and agents will run these commands constantly.

**G. Conventions / house rules:**
- Any patterns they always want? Anything they never want (the "Don't" list)?
- If they have none yet, say you'll fill in sensible defaults for the stack and
  they can refine later.

**H. How strictly should we test? (dev-rigor style, per project)**
All three styles ALWAYS end with tests + review + the security baseline; the only
difference is WHEN tests are written. Ask with plain explanations, and propose the
context-aware default:
> "How should we handle tests while building?
>  - **TDD**, the test is written BEFORE the code, for everything (highest
>    discipline; slower on visual UI work).
>  - **TDD-lite**, test-first for logic (backend, APIs, calculations, bug
>    fixes), tests-after for UI (the balanced default for new projects).
>  - **Test-after**, code first, tests right after, everywhere (fastest start;
>    the sensible default on an existing codebase that has few or no tests).
>  Whichever you pick, nothing merges without tests and review, this only sets
>  the ORDER."
Default: **new project -> TDD-lite; existing codebase with few/no tests ->
Test-after.** Record the choice in CLAUDE.md's Conventions section as
`dev_rigor: tdd | tdd-lite | test-after` with a one-line meaning. The architect
and builder read it.

**H2. Where should the thinking run? (model preference, semantic)**
Resolve the CURRENT model lineup live (ask the harness/session what tiers and
prices exist right now, never recite from this file), then ask:
> "On which model should the thinking run, planning, discovery, reviews?
>  (Code execution rides the builder's pinned execution tier, see AGENTS.md
>  Model policy; this choice is for judgment.)
>  - **strongest**, the top tier that exists (name + price as resolved now)
>  - **strong-default**, the strongest standard-price tier (name it now)
>  This is a DEFAULT, not a lock: /model overrides it any moment, and one
>  sentence changes it permanently."
Record semantically in CLAUDE.md Conventions: `session_model_preference:
strongest | strong-default`, never a model name (names age; the preference
must not). /odeo:start reminds when the session and the preference disagree.

**I. How should I talk to you? (plain language preference)**
> "I always explain things in plain language. Do you also want me to teach you the
>  technical terms as we go, the plain explanation first, then the technical name in
>  a short aside (e.g. 'fixed how it fetches data (technical: removed an N+1 query)')?
>  - **Teach me as I go:** I add the technical term so you learn it.
>  - **Just keep it plain:** I skip the technical aside."
Record this as `teach_me_as_i_go: yes|no` in the CLAUDE.md Conventions section
(default **yes**, most solo builders are learning something; professionals turn
it off with one answer). When yes, it also turns on teaching comments in built
code: comments explain intent and connections, and are updated with the code
they describe.

**I2. Output language for generated docs**
> "Which language should I WRITE your documents in, PRDs, user stories,
>  plans, review write-ups? Code, comments, filenames, and commit messages
>  always stay English. English (default), German, Croatian, or French?"
Record it in the CLAUDE.md Conventions section as the single canonical line
`output_language: <code>` where <code> is one of en|de|hr|fr (default en if
skipped). Same line `bin/init-project.sh` writes at scaffold time;
re-running setup updates it. Do not add a change-anytime command here.

**J. Security & Data** (do not skip, fills the Security & Data section):
First tell the user:

> "A security baseline already applies to all code automatically (input
> validation, safe queries, authorization on every endpoint, no personal data in
> logs, secrets hygiene, dependency audits), you don't need to ask for it.
> I just need the facts specific to this project:"

Then ask, in plain language:
1. **What personal data will this handle?** (names, emails, addresses, IPs,
   photos…, or none). Anything sensitive, payments, health, documents?
2. **Who are the users and where?** (If EU users → note that GDPR applies and
   data export/deletion must be designed in, not bolted on.)
3. **Will users log in?** If yes: email+password, Google/OAuth login, or company
   SSO? Are there different roles (e.g. user vs admin)?
4. **Any known compliance requirements** from their industry or clients?
   (If they don't know: record "GDPR if EU users; none other known".)
5. **Anything especially worth protecting** in this product? (the "crown
   jewels", e.g. customer lists, pricing, documents)

From the answers, fill the **Sensitive data inventory**, **Users & compliance**,
and **Authentication & access** subsections. Where the user is unsure, write a
secure default and mark it `# TODO: confirm` (e.g. retention: "until account
deletion # TODO: confirm"). Never write "no security needed", if the project
truly handles no personal data, record that explicitly and keep the checkpoints.

## 4. Fill in CLAUDE.md
Replace every `[...]` placeholder in the Stack, Architecture, Commands, Project
Structure, Conventions, Security & Data, and Don't sections with the answers. For anything the user left
open, put a sensible stack-appropriate default and mark it `# TODO: confirm`.

Leave the Git Workflow and Product Documentation sections as they are (they're
stack-agnostic). Update `_Last updated:_` to today's date.

## 5. Confirm and finalize
- Show the user the filled CLAUDE.md (or a summary of each section).
- Ask for corrections; apply them.
- Remind them: "You can rerun `/odeo:setup-project` anytime, or just edit CLAUDE.md
  directly. The TDD skill will use the Commands you set here."
- If the repo has a GitHub remote (or as soon as it gets one), offer CI once:
  "want every pull request tested automatically? `/odeo:ci` generates the workflow
  from the Commands you just set, about two minutes." (Setup can wait; the
  offer should not be pushy, /odeo:merge re-offers when it matters.)

## Safety Rules
- Never invent a stack, ask, or read the project's manifest and confirm.
- Never overwrite a CLAUDE.md that's already filled without explicit confirmation.
- Keep the placeholders' section structure intact; only replace the `[...]` parts.
