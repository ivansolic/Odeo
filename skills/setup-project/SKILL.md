---
description: First-run onboarding. Interviews the user about their stack, commands, and conventions, then fills in the project CLAUDE.md. Offers to start from a preset. Use once per new project, before any building.
disable-model-invocation: true
---

Goal: turn the placeholder `CLAUDE.md` into a real, project-specific config by
**interviewing the user**, never guess the stack. One question group at a time,
wait for answers, confirm before writing.

## 1. Check current state
Read `CLAUDE.md`. If the Stack/Commands/Conventions sections are already filled
(no `[...]` placeholders), tell the user it looks configured and ask whether they
want to reconfigure or stop.

## 2. Offer a preset shortcut
List the available presets first: `ls ~/.claude-templates/presets/`. Then ask:

> "Do you want to start from a preset, or answer a few questions?
>  Presets available: [list what you found in ~/.claude-templates/presets/].
>  - **Preset:** I'll copy it into CLAUDE.md, then we tweak names/details.
>  - **Interview:** I'll ask you about your stack and fill it in from scratch."

If they pick a preset:
- Copy the chosen preset over `CLAUDE.md`:
  `cp ~/.claude-templates/presets/<name>.md CLAUDE.md`
- Jump to step 5 (confirm + per-project details).

If they pick interview, continue to step 3.

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

**D2. Architecture**, the user chooses. Present the options with neutral
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

**E. Commands** (critical, the TDD skill and auto-verify loop use these):
- How do you start the app (dev)? Run tests? Run backend tests separately? Lint?
  Typecheck? Build? Any DB commands (migrate/generate/studio)?
- If the user doesn't know, infer sensible defaults from the stack and the
  package manifest (e.g. read `package.json` scripts) and confirm them.

**F. Conventions / house rules:**
- Any patterns they always want? Anything they never want (the "Don't" list)?
- If they have none yet, say you'll fill in sensible defaults for the stack and
  they can refine later.

**G. Security & Data** (do not skip, fills the Security & Data section):
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
- Remind them: "You can rerun `/setup-project` anytime, or just edit CLAUDE.md
  directly. The TDD skill will use the Commands you set here."

## Safety Rules
- Never invent a stack, ask, or read the project's manifest and confirm.
- Never overwrite a CLAUDE.md that's already filled without explicit confirmation.
- Keep the placeholders' section structure intact; only replace the `[...]` parts.
