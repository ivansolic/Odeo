---
id: PRD-002
title: Odeo as a PM plugin that ends with a delivery-ready package
status: draft
date: 2026-10-25
---

# PRD-002: Odeo as a PM plugin that ends with a delivery-ready package

## 1. Problem
Odeo is two products in one plugin: a product-management workflow (discovery, strategy,
PRD, critique, stories, outcome, go-to-market) and a software-delivery workflow (build,
merge, review loops, git gates). The delivery half carries most of the complexity, while
building is, by assumption (section 3), already well served by dedicated development
tools, and it blurs who Odeo is
for.

Who hurts:
- **The maintainer**, who spends most of the effort on the delivery half. Measured on
  2026-10-22/23 in this repository: 41 of the last 100 commits were review records of
  delivery work; 72 code-reviewer runs in 30 days, about 1.5M tokens each (13 runs of one
  session, about 20M tokens); 7 of the 10 agents (75% of agent text) and 16 of the 67
  skills (33% of skill text) serve delivery; phases 1 and 2 of the October slimming were
  spent almost entirely on delivery machinery (merge-gate, review loop, bin wrappers).
- **Founders, entrepreneurs and PMs** looking for rigorous product work, who meet a
  plugin described as "PM-to-Dev workflow" and a guide full of git branches, worktrees
  and merge gates. Assumption, not yet validated with users: this framing narrows the
  audience to people who also want Odeo's way of building.

Why now: public adoption is still near zero (repository `ivansolic/Odeo`, read
2026-10-23: 1 star, 0 forks, 25 unique cloners in 14 days), so the cut costs almost no
user migration.

## 2. Outcome & success metrics
Outcome: a founder, entrepreneur or PM takes a fuzzy idea through Odeo to a package that
is ready for delivery: whoever builds it, a developer or any build tool, can start without
asking anything the package already decides.

Success metrics (targets):
- **Delivery-ready (primary):** in 3 of 3 pilot handoffs, the builder's first questions
  are only about things the package leaves open, never about something it already
  decides, and the builder's own summary of the work names the same problem, outcome and
  in-scope items as the package and adds no scope the package does not contain. Measured
  by reading each pilot transcript or conversation against the package. The pilots use at
  least two different build setups (for example one developer and one build tool), and at
  least one of the three ideas comes from a person who is not the maintainer.
- **Focus:** the shipped plugin contains no build, merge or code-review skill or agent
  (0 of each), and its README and ROADMAP name founders, entrepreneurs and PMs as the
  audience and the delivery-ready package as the end point.
- **Maintenance load (secondary):** over the 30 days after the cut, review-record commits
  are under 15% of all commits (41% before), measured with `git log`.
- **No lost value:** every PM skill that exists today still exists and still passes its
  quality gate after the cut (pm-reviewer and skill-reviewer records unchanged or better).

## 3. Context
- Assumption, not measured: building is well served elsewhere, by dedicated development
  tools and plugins that plan, implement, test and review code, and they all start from
  the same thing, a clear specification. That is what Odeo should hand them. Odeo does not
  choose or name a build tool for the user.
- The real alternative for the user is a general assistant asked to "write me a PRD".
  Odeo's answer is rigor (reviewed documents, traced requirements, a pre-mortem), which
  also costs time; the cut keeps that rigor and removes the build machinery around it.
- Odeo's own data on what is used (session transcripts since 2026-09-23, all projects on
  the maintainer's machine): `/odeo:merge` 19 runs, `/odeo:learn` 4, `/odeo:stories`,
  `/odeo:guide` and `/odeo:research` 1 to 2 each; the build agents (architect, builder)
  were never dispatched. Most of that use is developing Odeo itself, so it says little
  about what outside users would use.
- Odeo's differentiator on the PM side is rigor, not prompts: rubrics, pm-reviewer, a
  research skill that cites sources and checks quotes, critique with a pre-mortem, and
  stories that state what and why, never how.
- Constraint: Odeo's own scripts (privacy scan, publish guard, lint, gates) still need a
  test suite and code review to maintain. That is repository tooling, not a feature
  users install.

## 4. Hypotheses & assumptions
- **H1 (riskiest): a package of PRD, stories and a short brief is enough to start
  building.** Risk: builders still have to come back with questions the PM thought were
  settled, because the package leaves out what a builder needs (priorities, edge cases,
  constraints). Wrong if: in a pilot a builder asks something the package should have
  answered, or misstates the scope.
- **H2:** founders, entrepreneurs and PMs value a PM-only Odeo. Wrong if: within 60 days
  of the release nobody outside the maintainer opens an issue, stars or installs it (the
  repository has traffic numbers), or the first outside feedback asks for the build half.
- **H3:** the package works across build setups, not only one. Wrong if: it works with
  one build setup in the pilot and fails the primary metric with the other.
- **H4:** no outside user depends on `/odeo:build` or `/odeo:merge` today. Wrong if: an
  issue or message reports one; the near-zero adoption above makes this likely to hold.

## 5. Scope
In, the thin slice (each item is referred to by its name elsewhere in this document):
1. **Delivery-ready package:** one Odeo step that, after the stories pass their review,
   assembles a package any builder can start from (the PRD, the stories with their
   acceptance criteria, and a short brief of what is decided and what is open), checks
   it is complete, and tells the user it is ready for delivery. Plain Markdown in the
   project, readable by a person or any tool. No build tool is named or assumed.
2. **Core path:** the front door for founders is a short path, PRD, critique, stories,
   package; `/odeo:guide`, the README and `/odeo:start` lead with it. The other PM skills
   stay as extras reached when needed (decided 2026-10-25). The user moves along it, and
   reaches any other skill, by asking in their own words ("write the stories") or by
   saying yes to an offered next step; typing a command is possible but never required
   (R15, decided 2026-10-25).
3. **Cut:** 20 skills (build, merge, deploy, ci, commit-push, optimize,
   worktree-parallel-check, focus, sync-docs, test-driven-development, ux-design,
   setup-design, query, the three code/design/plan second-opinion skills, and the four
   knowledge skills learn, knowledge-refresh, contribute-lesson and sync-community), 7
   agents (architect, builder, code-reviewer, design-reviewer, architecture-reviewer,
   codebase-analyst, debugger) and 4 scripts (merge-gate, boundary-check, focus-check,
   community-sync) leave the plugin, together with the session-start reminder to refresh
   the community knowledge, and the pre-push guard Odeo installed in users' projects is
   no longer installed (R4). The knowledge skills were built for solved technical
   problems (verified by passing tests, checked against the code); the shared community
   base holds no lessons, only five empty technical categories, and is the one way
   someone else's text reaches a session unreviewed (local copy read 2026-10-25; decided
   2026-10-25). A copy goes to a tagged
   archive branch and is not maintained (decided 2026-10-23). What stays: `prototype`,
   `ux-writing` and `second-opinion-pm` (decided 2026-10-23); `spec-gate` and
   `coverage-check`, which the package needs (decided 2026-10-25); the scripts remaining
   skills use (R11). The maintainer's own merge gate, code-reviewer and pre-push guard
   for this repository are kept and maintained as repository-only tooling (R6).
4. **No model policy:** agents run on the session's model; review records lose
   `model_tier` and `model_waiver`; `spec-gate` stops checking a tier; the model-policy
   section of AGENTS.md, the lint rule on model names and every model remark in the
   remaining skills (for example `setup`, `start`) go. Nothing in the plugin says
   which model to use (decided 2026-10-25).
5. **Instructions:** AGENTS.md keeps the rules a PM workflow and Odeo's own maintenance
   need; build rules and the model policy leave. The baseline Odeo adds to every session
   keeps only PM rules: communication, PM practice, honesty and privacy; git discipline,
   code style, testing, code security and the cut agents leave it (R17, decided
   2026-10-25).
6. **Repositioning:** plugin description, README, ROADMAP, guide and system map say who
   Odeo is for and that it ends with a delivery-ready package.
7. **Pilot:** 3 handoffs on real ideas, across at least two build setups; the transcript
   of each Odeo session is kept, and a transcript or notes of each build, as evidence.
8. **One release:** the prepared, unpublished 0.5.0 (review-loop and merge-gate changes)
   is not published on its own; its PM-relevant parts ship with this release (decided
   2026-10-23).
9. **One setup:** `new-project` and `setup-project` become one `setup` skill that
   prepares a place for product documents, new or inside an existing folder; the stack
   interview, the stack presets and the design layer leave it; it asks what the product
   is, whether to teach product terms as it goes, and the product's security and data
   facts (R16, decided 2026-10-25).

Side change in the same release, outside the thin slice (it does not test the outcome;
the maintainer asked for it, decided 2026-10-25):
- **Prototype sharing in two modes:** a *quick share* from the user's machine that can
  last as long as a review needs and be extended without a new link (R13), and a
  *lasting share* that is published once and keeps the same link after the machine is
  off and after the prototype is updated, the way a shared document link works (R14).
  Odeo publishes the lasting share to a place the user already has (the sharing built
  into the tool they work in, or a static hosting account they choose), only where every
  R14 check holds, and does not bundle or name one.

Out (non-goals):
- Building, recommending or integrating any build tool.
- Changing what the PM skills produce: their rubrics and document shapes stay. The only
  edits to remaining PM skills are the ones the items above require: removing model
  remarks (No model policy), removing pointers to cut items (R2), leading with the core
  path and letting the user start each skill by asking (Core path, R15), the one
  `setup` skill that no longer installs the pre-push guard and says so (One setup, R4,
  R16), and the prototype sharing change (the side change). The review-record format
  loses its two model fields (No model policy) and nothing else.
- A Codex or other host port.
- Migration tooling for outside users of the build half (none known).
- A public launch campaign or demo; whether and how to launch is decided after the
  pilot (open question 2).

## 6. Requirements & acceptance criteria
- **R1 Delivery-ready package.** After stories pass review, the user gets one package and
  is told it is ready for delivery. AC: the package states the problem, the outcome and
  its metric, the scope with non-goals, the stories with their acceptance criteria, and a
  list of what is decided and what is still open; it is assembled only when `spec-gate`
  confirms the PRD and stories carry a fresh passing review and `coverage-check` confirms
  every PRD requirement has a story; a builder in the pilot starts from it without the
  user copying or re-explaining anything; it names no build tool.
- **R2 Clean cut.** The shipped plugin contains none of the skills, agents and scripts the
  Cut item removes. AC: the plugin's file list after install has none of them, and no
  remaining skill, guide line or system-map row points to one.
- **R3 Nothing PM is lost.** AC: every remaining PM skill passes its quality gate after
  the release, and `/odeo:guide` routes every PM question it routed before.
- **R4 Protection stays where it protects users.** Odeo keeps installing the secret-scan
  pre-commit hook in the places for product documents it sets up, because PM documents
  (interviews, figures) can hold secrets too; the pre-push guard it installed in users'
  projects is no longer installed (decided 2026-10-23). AC: a place `setup` prepares
  refuses a planted secret on commit; the privacy scan still runs before anything leaves
  the machine (shared prototypes, the package under R7); the release notes and `setup`
  name the push guard as no longer installed.
- **R5 Clear positioning.** AC: the plugin description, README opening and ROADMAP name
  founders, entrepreneurs and PMs, and describe the end point as a package ready for
  delivery to any builder, with no build tool named.
- **R6 Odeo can still maintain itself.** The maintainer's own merge gate, code-reviewer
  and pre-push guard for this repository move to a repository-only folder that the
  publish step strips. AC: on this repository the tests, lint, publish guard, merge gate,
  pre-push guard and code review for its scripts keep working, and the published tree
  contains none of them.
- **R7 The package is scanned.** AC: before the package is handed over, the privacy scan
  runs on it, and a planted e-mail address or key produces a warning the user must answer.
- **R8 Removed scripts are named.** AC: when an existing project's git hook points to a
  script the release no longer ships, the session-start check names that hook and the
  one command that refreshes it.
- **R9 No interviewee data in the package.** AC: the package refers to raw interview
  notes by path and never copies them; its summarized findings carry no person's name; a
  pilot package built from an interview synthesis with planted names contains none.
- **R10 The archive stays private.** AC: the archive branch exists only on the private
  remote, and this repository's pre-push guard (kept under R6) refuses a push of it to
  the public remote.
- **R11 Scripts that remaining skills use stay.** AC: `share-tunnel.sh` (used by
  `prototype`) and `second-opinion.sh` (used by `second-opinion-pm`) ship in the plugin,
  and every remaining skill's script references resolve after install.
- **R12 No model policy.** AC: no shipped agent, skill, rubric, record format, gate or
  instruction file mentions a model tier, a waiver or which model to use; `spec-gate`
  accepts a passing record without `model_tier`.
- **R13 Longer shares that keep their link (side change).** Today extending a share means
  starting a new tunnel, and a new tunnel always gets a new address ("The hostname changes
  each time you create a Quick Tunnel", Cloudflare Quick Tunnels docs, read 2026-10-25).
  AC: when sharing, the user chooses how long the share stays open, up to 8 hours in
  total; an open share can be extended up to that total by moving its end time while the
  same tunnel keeps running, so the link stays the same; every share announces its end
  time, closes on its own, and stays listed by `/odeo:start` while open.
- **R14 Lasting shares (side change).** Today `prototype` already offers a preview
  deploy for sharing over days: it needs an account with a hosting service, is recorded
  in the project's share list, recommends password protection where the service offers
  it, and is deleted by hand. R14 builds on that step rather than adding a second one. A
  lasting share does not close on its own, so its protection is access and consent
  rather than time. AC: Odeo publishes only to a place where every check below holds,
  and says so when the user's chosen place cannot meet one; the user approves each
  publication before anything leaves the machine; the privacy scan runs on the prototype
  first and a planted e-mail address or key blocks the publication until the user answers;
  the share is private to the user until they share it, and nobody without the link (and
  the password, where the place offers one) can reach it; after the user's machine is off
  and after an update, the same link shows the current prototype; `/odeo:start` lists
  every lasting share; one command withdraws a share, and the link stops working; the
  prototype uses seed data only.
- **R15 Start a skill by asking (Core path).** Today 37 of the 47 skills that remain
  after the cut start only when the user types their command; asking in words ("write the
  stories for this PRD") gets a request to type it instead. AC: every remaining skill
  starts when the user asks for it in words or says yes to an offer of it, and in the
  pilot transcripts no skill starts without one of the two; each step that sends
  something off the machine or makes it public (a quick or lasting prototype share, a
  remote repository `setup` offers to create) still asks for the user's explicit yes
  before it happens, whoever started the skill; integrating into this repository's main
  branch stays the maintainer's own command (R6).
- **R16 One setup.** Today `new-project` scaffolds a code project (git with the push and
  commit guards, a design layer for interfaces, a knowledge folder) and hands over to
  `setup-project`, which interviews the user about the stack, the build and test commands
  and conventions, offers a stack preset, and maps an existing codebase with an agent the
  cut removes. AC: one `setup` skill prepares a place for product documents, either a new
  folder or inside an existing one; it creates the document folders, sets the output
  language, and starts version history where none exists, because the spec gate reads
  review freshness from it, and its first commit holds only the files `setup` created,
  never files that were already in the folder; it installs the secret scan on commit
  (R4); it asks three things: what the product is (who it is for and the outcome it
  produces), whether to teach product terms as it goes (the plain explanation first, then
  the term in a short aside, such as ICP, North Star or RICE; default yes, one answer
  turns it off), and the product's security and data facts (which personal data it
  handles, who its users are and where, whether they log in), which feed every PRD's
  security pre-mortem; it asks nothing about a stack, build or test commands and offers
  no stack preset, design layer or knowledge folder; in an existing folder it overwrites
  no file the user has, and in an existing project instruction file it adds the language
  line and replaces nothing; creating a remote repository and pushing to it stays an
  offer that runs only after the privacy scan and the user's explicit yes (R15).
- **R17 A PM baseline in every session.** Today, once Odeo is installed, every session in
  every project receives a 232-line baseline (unless the user's own global instructions
  already carry its security section) whose sections are mostly about building software:
  git discipline, code style, testing, a security baseline for code, the community
  knowledge base, and when to call the code and architecture reviewers. AC: the baseline
  Odeo adds to every session contains the communication, PM practice, honesty and privacy
  rules (secrets and personal data stay out of documents, nothing leaves the machine
  without approval), and every section of it belongs to one of these four groups, so
  nothing about git branches, code style, tests, code security, plan formats, bug fixing,
  the task ledger, community knowledge or an agent the cut removes remains; every rule a
  remaining skill relies on is in that skill or in AGENTS.md; the communication rules
  point to `setup` for the product-terms preference (R16), which teaches product terms
  rather than technical ones; in the pilot this is checked on a machine whose own global
  instructions do not already carry the baseline.

## 7. Risks & dependencies
- **Value:** the PM half alone is not compelling; founders want one tool that also
  builds. Detect: H2 signals within 60 days; mitigation is a package good enough to
  start any build.
- **Usability:** a package that is complete for one builder is thin for another (a human
  developer wants different detail than a build tool). Detect: H3, the second build setup
  in the pilot.
- **Feasibility:** low for the cut, which is mostly removal; medium for the new work,
  the package step, quick shares that keep their link (R13), lasting shares (R14) and a
  new trigger description for every remaining skill (R15), one `setup` from two skills
  (R16) and a shorter session baseline (R17).
- **Weight (from the critique):** the rigor that sets Odeo apart is also slow; a founder
  who meets several review rounds on a first PRD stops before the package. Detect: in the
  three pilot sessions, any that produce one document and never reach the package.
  Mitigation in scope: the Core path.
- **Reach (from the critique):** nobody outside the maintainer finds it, since launch is
  out of this slice. Detect: the same 60-day window as H2, repository traffic and
  installs.
- **Security pre-mortem** (the cut removes protections users had). "It is six months
  later and a user leaked a secret through a project Odeo set up. What was the hole?"
  - Odeo stopped installing its pre-commit secret scan into new projects, and nothing
    told the user. **Requirement (R4):** the secret-scan pre-commit hook stays; the
    dropped pre-push guard is named in the release notes and in `setup`.
  - The package carried private data to a builder or into a repository that is later
    pushed publicly. **Requirement (R7):** the privacy scan runs on the package before
    it is handed over.
  - Old git hooks in existing projects point at scripts the new release no longer ships
    and silently stop scanning. **Requirement (R8):** the session-start check that already
    names outdated guards also names guards whose scripts were removed.
  - Interviewee names and quotes from an interview synthesis travelled in the package; the
    privacy scan matches patterns and does not recognize personal names.
    **Requirement (R9):** the package refers to raw notes and its findings carry no names.
  - The archive branch, which holds internal paths, was pushed to the public remote.
    **Requirement (R10):** private only, refused by this repository's own pre-push guard.
  - A shared prototype's tunnel broke because its script was cut with the build half.
    **Requirement (R11):** scripts that remaining skills use stay.
  - A longer share was forgotten and a prototype stayed public for hours. **Requirement
    (R13):** at most 8 hours in total, an announced end time, automatic close, and a
    listing in `/odeo:start` while open; prototypes keep using seed data only.
  - A lasting share, which never closes on its own, stayed reachable for months after the
    review, with real customer data pasted into the prototype. **Requirement (R14):**
    approval before each publication, the privacy scan first, private until shared, seed
    data only, listed in `/odeo:start`, and one command to withdraw it.
  - The assistant started a prototype share or pushed a new repository on its own
    reading of the conversation, because skills no longer wait for a typed command.
    **Requirement (R15):** a skill starts only on the user's request or yes, and every
    step that sends something off the machine still asks for an explicit yes first.
  - `setup` started version history in a founder's existing folder and its first commit
    took in interview recordings and a customer spreadsheet that were already there;
    the folder was later pushed. The secret scan finds keys, not personal data.
    **Requirement (R16):** the first commit holds only the files `setup` created, and
    a push it offers runs the privacy scan first.
  - Slimming the session baseline also dropped the rule that keeps secrets and personal
    data out of documents, and a founder pasted customer records into a PRD.
    **Requirement (R17):** the baseline keeps the privacy rules; only the rules about
    building software leave.

## 8. Open questions
1. **What the brief holds beyond the PRD and stories:** priorities, constraints, known
   edge cases, a glossary? The pilot shows what builders actually ask for.
2. **Audience of the first release:** the maintainer's own work, or a public launch with
   positioning and a short demo?
3. **Product knowledge across projects:** do founders want Odeo to remember verified
   insights (research findings, decisions, market facts, each with its source) from one
   project to the next? If the pilot shows it, a PM version of the cut `learn` skill is
   specified then; until then `retro` captures lessons per project.

Decisions, in order:
- 2026-10-23: the build half goes to an archive branch; `prototype`, `ux-writing` and
  `second-opinion-pm` stay, `query` goes; the secret-scan pre-commit hook stays and the
  pre-push guard in users' projects goes; the prepared 0.5.0 ships only as part of this
  release.
- 2026-10-25: Odeo names no build tool; the package is ready for any builder.
- 2026-10-25, after `/odeo:critique`: `spec-gate` and `coverage-check` stay; the Core path;
  R9 to R11 from the security pre-mortem; no model policy at all; longer prototype shares
  as a side change.
- 2026-10-25, round 5: prototype sharing in two modes, quick and lasting, the lasting one
  keeping its link like a shared document (R14).
- 2026-10-25, round 6: every remaining skill can be started by asking in words or by a
  yes to an offer, not only by a typed command; steps that send anything off the machine
  keep their own approval (R15).
- 2026-10-25, round 7: `new-project` and `setup-project` become one `setup` for product
  documents (R16); the session baseline keeps only PM rules (R17); the four knowledge
  skills go to the archive with the build half, and product knowledge across projects
  becomes open question 3; the tools for improving and reviewing skills and agents stay
  in the plugin.
- 2026-10-25, round 8: `setup` asks what the product is, whether to teach product terms
  (default yes) and the product's security and data facts; its first commit holds only
  its own files and an offered push runs the privacy scan first.
