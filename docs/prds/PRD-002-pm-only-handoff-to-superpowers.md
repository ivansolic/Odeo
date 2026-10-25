---
id: PRD-002
title: Odeo as a PM plugin that hands the build to Superpowers
status: draft
date: 2026-10-23
---

# PRD-002: Odeo as a PM plugin that hands the build to Superpowers

## 1. Problem
Odeo is two products in one plugin: a product-management workflow (discovery, strategy,
PRD, critique, stories, outcome, go-to-market) and a software-delivery workflow (build,
merge, review loops, git gates). The delivery half carries most of the complexity while
other plugins already do it well, and it blurs who Odeo is for.

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
user migration. And a maintained, widely used build workflow exists to hand over to:
Superpowers (obra/superpowers, MIT, read at commit `2ce8aa1`, 2026-10-21), whose
`brainstorming` skill explicitly accepts "a spec, a plan, a handoff" as its starting
point and whose `writing-plans` skill starts "when you have a spec or requirements".

## 2. Outcome & success metrics
Outcome: a founder, entrepreneur or PM takes a fuzzy idea through Odeo to a reviewed PRD
and stories, and hands them to Superpowers without re-explaining what was decided.

Success metrics (targets):
- **Clean handoff (primary):** in 3 of 3 pilot handoffs, Superpowers' `brainstorming`
  echoes the request correctly and its one opening question is about something the PRD
  and stories leave open, never about something they already decide. "Echoes correctly"
  means its summary names the same problem, outcome and in-scope items as the handed-over
  documents and adds no scope they do not contain. Measured by reading the transcript of
  each pilot against the documents. The maintainer runs the pilots, and at least one of the
  three ideas comes from a person who is not the maintainer.
- **Focus:** the shipped plugin contains no build, merge or code-review skill or agent
  (0 of each), and its README and ROADMAP name founders, entrepreneurs and PMs as the
  audience.
- **Maintenance load (secondary):** over the 30 days after the cut, review-record commits
  are under 15% of all commits (41% before), measured with `git log`.
- **No lost value:** every PM skill that exists today still exists and still passes its
  quality gate after the cut (pm-reviewer and skill-reviewer records unchanged or better).

## 3. Context
- The real alternative for the build half is Superpowers: brainstorming, writing-plans,
  executing-plans, subagent-driven development, test-driven development, code review,
  git worktrees, finishing a branch. Its specs live in `docs/superpowers/specs/`, its
  plans in `docs/superpowers/plans/`, and a plan carries the path of the spec it
  implements (read from `skills/brainstorming/SKILL.md` and `skills/writing-plans/SKILL.md`
  at `2ce8aa1`).
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
- **H1 (riskiest): the handoff can be clean without new machinery.** Risk: Superpowers'
  brainstorming re-asks or second-guesses what the PRD settled, and the user ends up
  re-deciding scope. Wrong if: in a pilot its opening question is answered by the
  handed-over documents, or its echo misstates the scope.
- **H2:** founders, entrepreneurs and PMs value a PM-only Odeo. Wrong if: within 60 days
  of the release nobody outside the maintainer opens an issue, stars or installs it (the
  repository has traffic numbers), or the first outside feedback asks for the build half.
- **H3:** Superpowers stays maintained and keeps accepting a spec as input. Wrong if: its
  brainstorming or writing-plans skill stops reading a handed-over spec; we would see it
  when the pilot handoff is re-run before each Odeo release.
- **H4:** no outside user depends on `/odeo:build` or `/odeo:merge` today. Wrong if: an
  issue or message reports one; the near-zero adoption above makes this likely to hold.

## 5. Scope
In (the thin slice):
1. **Handoff step:** one Odeo skill that, after stories pass their review, writes a
   handoff document Superpowers can start from, and tells the user the one command to run
   next. One document, one command.
2. **Cut:** 16 skills (build, merge, deploy, ci, commit-push, optimize,
   worktree-parallel-check, focus, sync-docs, test-driven-development, ux-design,
   setup-design, query, and the three code/design/plan second-opinion skills) leave the
   plugin, with 7 agents (architect, builder, code-reviewer, design-reviewer,
   architecture-reviewer, codebase-analyst, debugger) and the build-only scripts
   (merge-gate, spec-gate, boundary-check, coverage-check, focus-check). They go to a
   tagged archive branch in this repository and are not maintained (decided 2026-10-23).
   `prototype`, `ux-writing` and `second-opinion-pm` stay (decided 2026-10-23).
3. **Repositioning:** plugin description, README, ROADMAP, guide and system map say who
   Odeo is for and where the build continues.
4. **Instructions:** AGENTS.md keeps the rules a PM workflow and Odeo's own maintenance
   need; build rules leave with the build half.
5. **Pilot:** 3 handoffs to Superpowers on real ideas, transcripts kept as evidence.
6. **One release:** the prepared, unpublished 0.5.0 (review-loop and merge-gate changes)
   is not published on its own; its PM-relevant parts ship with the cut release
   (decided 2026-10-23).

Out (non-goals):
- Building or maintaining a replacement build plugin.
- Changing what the PM skills produce (rubrics and document shapes stay).
- A Codex or other host port.
- Migration tooling for outside users of the build half (none known).
- Changes to Superpowers itself.

## 6. Requirements & acceptance criteria
- **R1 Handoff.** After stories pass review, the user gets one handoff document and one
  next command. AC: a pilot user starts Superpowers from it without copying anything by
  hand, and the document states the problem, the outcome and its metric, the scope with
  non-goals, and the stories with their acceptance criteria.
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
  founders, entrepreneurs and PMs, and name Superpowers as the place the build continues.
- **R6 Odeo can still maintain itself.** The maintainer's own merge gate and code-reviewer
  move to a repository-only folder that the publish step strips, so they keep working on
  this repository and never reach users. AC: the repository's tests, lint, publish guard,
  merge gate and code review for its scripts keep working, and the published tree
  contains none of them.
- **R7 The handoff document is scanned.** AC: before the handoff document is written into
  a code repository, the privacy scan runs on it, and a planted e-mail address or key in
  the document produces a warning the user must answer.
- **R8 Removed scripts are named.** AC: when an existing project's git hook points to a
  script the release no longer ships, the session-start check names that hook and the
  one command that refreshes it.

## 7. Risks & dependencies
- **Value:** the PM half alone is not compelling; founders want one tool that also
  builds. Detect: H2 signals; mitigation is the handoff itself.
- **Viability:** dependence on a third-party plugin's behavior. Detect: re-run one pilot
  handoff before each release (H3).
- **Usability:** two plugins and a handoff are harder than one flow. Detect: pilot
  transcripts; the user needs more than one command to continue.
- **Feasibility:** low; this is mostly removal, plus one skill.
- **Security pre-mortem** (the cut removes protections users had). "It is six months
  later and a user leaked a secret through a project Odeo set up. What was the hole?"
  - Odeo stopped installing its pre-commit secret scan into new projects, and nothing
    told the user. **Requirement (R4):** the secret-scan pre-commit hook stays; the
    dropped pre-push guard is named in the release notes and in `/odeo:new-project`.
  - A handoff document carried private data (customer names, figures from interviews)
    into a repository that is later pushed publicly. **Requirement (R7):** the handoff
    step runs the existing privacy scan on the handoff document and warns before writing
    it into a code repository.
  - Old git hooks in existing projects point at scripts the new release no longer ships
    and silently stop scanning. **Requirement (R8):** the session-start check that already
    names outdated guards also names guards whose scripts were removed.

## 8. Open questions
1. **Handoff target:** Superpowers' `brainstorming` (re-reads and confirms the spec) or
   straight to `writing-plans` (treats it as final)? The pilot tries both and keeps the
   one that meets the clean-handoff metric.
2. **Audience of the first release:** the maintainer's own work, or a public launch with
   positioning and a short demo?

Decided 2026-10-23 by the maintainer (were open questions in v1): the build half goes to
an archive branch; `prototype`, `ux-writing` and `second-opinion-pm` stay, `query` goes;
the secret-scan pre-commit hook stays; the prepared 0.5.0 ships only as part of the cut.
