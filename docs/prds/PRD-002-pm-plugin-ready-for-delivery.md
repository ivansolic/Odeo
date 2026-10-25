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
building is already well served by dedicated development tools, and it blurs who Odeo is
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
- Building is well served elsewhere: dedicated development tools and plugins plan,
  implement, test and review code. They all start from the same thing, a clear
  specification, and that is what Odeo should hand them. Odeo does not choose or name a
  build tool for the user.
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
In (the thin slice):
1. **Delivery-ready package:** one Odeo step that, after the stories pass their review,
   assembles a package any builder can start from (the PRD, the stories with their
   acceptance criteria, and a short brief of what is decided and what is open), checks
   it is complete, and tells the user it is ready for delivery. Plain Markdown in the
   project, readable by a person or any tool. No build tool is named or assumed.
2. **Cut:** 16 skills (build, merge, deploy, ci, commit-push, optimize,
   worktree-parallel-check, focus, sync-docs, test-driven-development, ux-design,
   setup-design, query, and the three code/design/plan second-opinion skills) leave the
   plugin, with 7 agents (architect, builder, code-reviewer, design-reviewer,
   architecture-reviewer, codebase-analyst, debugger) and the build-only scripts
   (merge-gate, spec-gate, boundary-check, coverage-check, focus-check). They go to a
   tagged archive branch in this repository and are not maintained (decided 2026-10-23).
   `prototype`, `ux-writing` and `second-opinion-pm` stay (decided 2026-10-23).
3. **Repositioning:** plugin description, README, ROADMAP, guide and system map say who
   Odeo is for and that it ends with a delivery-ready package.
4. **Instructions:** AGENTS.md keeps the rules a PM workflow and Odeo's own maintenance
   need; build rules leave with the build half.
5. **Pilot:** 3 handoffs on real ideas, across at least two build setups, transcripts or
   notes kept as evidence.
6. **One release:** the prepared, unpublished 0.5.0 (review-loop and merge-gate changes)
   is not published on its own; its PM-relevant parts ship with the cut release
   (decided 2026-10-23).

Out (non-goals):
- Building, recommending or integrating any build tool.
- Changing what the PM skills produce (rubrics and document shapes stay), beyond what the
  package needs.
- A Codex or other host port.
- Migration tooling for outside users of the build half (none known).

## 6. Requirements & acceptance criteria
- **R1 Delivery-ready package.** After stories pass review, the user gets one package and
  is told it is ready for delivery. AC: the package states the problem, the outcome and
  its metric, the scope with non-goals, the stories with their acceptance criteria, and a
  list of what is decided and what is still open; a builder in the pilot starts from it
  without the user copying or re-explaining anything; it names no build tool.
- **R2 Clean cut.** The shipped plugin contains none of the skills, agents and scripts in
  scope item 2. AC: the plugin's file list after install has none of them, and no
  remaining skill, guide line or system-map row points to one.
- **R3 Nothing PM is lost.** AC: every remaining PM skill passes its quality gate after
  the cut, and `/odeo:guide` routes every PM question it routed before.
- **R4 Protection stays where it protects users.** Odeo keeps installing the secret-scan
  pre-commit hook in projects it creates, because PM documents (interviews, figures) can
  hold secrets too; the pre-push guard goes with the build half (decided 2026-10-23). AC:
  a new project's pre-commit refuses a planted secret; the privacy scan still runs before
  anything leaves the machine (`/odeo:contribute-lesson`, shared prototypes); the release
  notes and `/odeo:new-project` name the push guard as no longer installed.
- **R5 Clear positioning.** AC: the plugin description, README opening and ROADMAP name
  founders, entrepreneurs and PMs, and describe the end point as a package ready for
  delivery to any builder, with no build tool named.
- **R6 Odeo can still maintain itself.** The maintainer's own merge gate and code-reviewer
  move to a repository-only folder that the publish step strips, so they keep working on
  this repository and never reach users. AC: the repository's tests, lint, publish guard,
  merge gate and code review for its scripts keep working, and the published tree
  contains none of them.
- **R7 The package is scanned.** AC: before the package is handed over, the privacy scan
  runs on it, and a planted e-mail address or key produces a warning the user must answer.
- **R8 Removed scripts are named.** AC: when an existing project's git hook points to a
  script the release no longer ships, the session-start check names that hook and the
  one command that refreshes it.

## 7. Risks & dependencies
- **Value:** the PM half alone is not compelling; founders want one tool that also
  builds. Detect: H2 signals; mitigation is a package good enough to start any build.
- **Usability:** a package that is complete for one builder is thin for another (a human
  developer wants different detail than a build tool). Detect: H3, the second build setup
  in the pilot.
- **Feasibility:** low; this is mostly removal, plus one step.
- **Security pre-mortem** (the cut removes protections users had). "It is six months
  later and a user leaked a secret through a project Odeo set up. What was the hole?"
  - Odeo stopped installing its pre-commit secret scan into new projects, and nothing
    told the user. **Requirement (R4):** the secret-scan pre-commit hook stays; the
    dropped pre-push guard is named in the release notes and in `/odeo:new-project`.
  - The package carried private data (customer names, figures from interviews) to a
    builder or into a repository that is later pushed publicly. **Requirement (R7):** the
    privacy scan runs on the package before it is handed over.
  - Old git hooks in existing projects point at scripts the new release no longer ships
    and silently stop scanning. **Requirement (R8):** the session-start check that already
    names outdated guards also names guards whose scripts were removed.

## 8. Open questions
1. **What the brief holds beyond the PRD and stories:** priorities, constraints, known
   edge cases, a glossary? The pilot shows what builders actually ask for.
2. **Audience of the first release:** the maintainer's own work, or a public launch with
   positioning and a short demo?

Decided 2026-10-23 by the maintainer (were open questions in v1): the build half goes to
an archive branch; `prototype`, `ux-writing` and `second-opinion-pm` stay, `query` goes;
the secret-scan pre-commit hook stays; the prepared 0.5.0 ships only as part of the cut.
Decided 2026-10-25: Odeo names no build tool; the package is ready for any builder.
