# Task: Phase 2, first-party PM set (own the PM layer)

## ACTIVE DISCUSSION: loops + evals + guardrails (design, not yet built)
Order: #1 evals DONE-design, #2 improve DONE-design, #3 signal loop <- HERE, #4 build-first/taste-at-speed, #5 trigger pattern, then GUARDRAILS.
No attribution to individuals for loop/eval/build-first ideas (generic). Keep METHOD names in existing PM skills (RICE/INVEST/JTBD); person names optional.

Design decided so far (to BUILD after discussion):
- EVAL FRAMEWORK: rubric (criteria+threshold, lives with each skill = data, not agent) + scorers by domain: deterministic (tests/lint), code-reviewer (code), design-reviewer (UI), NEW `pm-reviewer` (PM docs), human (final gate). Reviewers = evaluators (upgrade them to write score+record; no twin agents). 3 scorer types combine (deterministic + LLM-judge + human). Eval records = small files in `docs/evals/<id>.md`, git = history/baseline, read last+baseline. Community eval contribution from the start (opt-in, sanitized, curated, same infra as /contribute-lesson). Compounding WITH curation + human sample-check, not blind.
- #2 IMPROVE-THE-ARTIFACT: new skill `/improve` (chosen over extending /knowledge-refresh). Loop: agent finds signal -> proposes change to skill/rubric/knowledge/prompt -> runs eval (old vs new) -> present -> HUMAN approves keep/revert -> commit (versioned). Agents propose+measure; human approves (changing the system = floor). Two scopes: local (this project) + shipped skills/rubrics (via curation/PR, not silent auto-update). Code improves indirectly via lessons/knowledge (repeat low score -> lesson -> developer avoids next time).
- TRIGGERING (all loops): "nudge + human-run" DEFAULT (system reminds at natural moment, you run it); real cron = opt-in later for advanced. Timing per loop's natural moment: maintenance/signal -> session start (quiet, conditional); learn/retro -> after /merge or when you say end. Intervals: knowledge-refresh ~2-4wk, improve on repeated eval drop (~3-5), signal ~weekly, learn/retro per story.
- BACKGROUND OPTION: nudge may offer "run maintenance/signal in background while you work" (opt-in, not silent auto-start). Read-only analysis runs parallel safely; APPLYING a change waits for gate + runs in own worktree. Apply changes at a calm moment (after /merge / next session start), not mid-coding.
- NAMING: /improve (or /refine). pm-reviewer (consistent with code-reviewer/design-reviewer).

## PARKED , GUARDRAILS (build AFTER PM loops #3,#4,#5)
Make an explicit Guardrails layer: consolidate scattered rules into `## Guardrails` in AGENTS.md, tagged [enforced] (deterministic: privacy-scan, gitignore, worktree isolation, worktree-parallel-check) vs [instructed] (model-followed: bg=read+propose-not-write, own files/port/db/env, apply waits for gate, plan-first, never-weaken-tests). Strengthen enforced where cheap. Irreversible/dangerous (merge/ship/send-out/secrets/delete) must be enforced mechanism. Each skill references relevant guardrails, doesn't repeat.

## PARKED (long) , end-to-end dogfood test; marketplace listing.

---


Goal/outcome: the system owns its full discovery->spec flow with our own skills,
built from PUBLIC frameworks in our own words (credited by name), so there is no
hard dependency on pm-skills. Human-in-command positioning throughout.

Integrity rule: build from public frameworks (Cagan, Torres, ProductCompass-style
PRD, 3 C's / Jeffries, INVEST / Wake, RICE / Intercom) in OUR words; credit each by
name; never copy/reword pm-skills text.

## Proposed scope, core-first in batches
Batch 1 (the spine WORKFLOW Phase 1 already uses):
- [ ] brainstorm , divergent discovery; Torres opportunity framing; problem-before-solution
- [ ] prd , problem-first, measurable outcomes, ProductCompass-style sections
- [ ] critique , strategy red-team + pre-mortem (incl. security pre-mortem for sensitive features)
- [ ] stories , INVEST + 3 C's + testable acceptance criteria (UI states folded in)
- [ ] prioritize , RICE
Batch 2 (supporting, common): personas, metrics/north-star, vision/strategy (Cagan)
Batch 3 (later, optional): GTM, release-notes, market/competitor, OKRs, sprint-plan

## Format
- Each = skills/<name>/SKILL.md in the plugin, explicit (disable-model-invocation: true).
- Our own prose; each cites its public framework by name in the body.
- Plain names now (/brainstorm /prd /critique /stories /prioritize); auto-namespaced
  as claude-cofounder:* when plugin-installed.
- Outputs save to docs/prds/PRD-NNN, docs/stories/USR-NNN (unchanged convention).

## Integration
- Update WORKFLOW.md Phase 1 + global CLAUDE.md PM section to use our skills.
- pm-skills handling: TBD (see decisions) , default to ours; keep pm-skills optional + credited, or remove.

## Decisions (confirmed)
- Scope: FULL set now (build in batches, depth over shallow stubs).
- pm-skills: default to OURS; keep pm-skills optional + credited (no big-bang removal).
- Format: skills/<name>/SKILL.md, disable-model-invocation: true, each cites its public framework by name.

## Full catalog (build order)
Batch A , Discovery & research:
- [ ] brainstorm (divergent; Torres opportunity framing; problem-before-solution)
- [ ] personas (Jobs-to-be-Done, Christensen)
- [ ] interview-synthesis (continuous discovery, Torres)
- [ ] competitor-analysis
- [ ] market-segments (segmentation, TAM/SAM/SOM, ICP)
Batch B , Strategy:
- [ ] vision (Cagan)
- [ ] strategy (insight-driven; Cagan)
- [ ] value-proposition (Value Proposition Canvas, Osterwalder)
- [ ] okrs (Doerr)
Batch C , Specification:
- [ ] prd (problem-first; ProductCompass-style sections)
- [ ] critique (strategy red-team + pre-mortem incl. security)
- [ ] stories (INVEST/Wake + 3 C's/Jeffries + acceptance criteria)
- [ ] prioritize (RICE; note MoSCoW, value/effort)
Batch D , Metrics & GTM:
- [ ] metrics (North Star + AARRR/HEART)
- [ ] gtm (go-to-market plan)
- [ ] positioning (April Dunford framework)
- [ ] release-notes

## Integration (after skills built)
- [ ] WORKFLOW.md Phase 1 + global CLAUDE.md PM section point at our skills (pm-skills optional/credited)
- [ ] install.sh / scaffold unaffected (skills ship with plugin); re-run install; scaffold test
- [ ] dash-check; commit per batch (no push)

## Review (parallel work + worktree-parallel-check + build guidance)
- worktree-parallel-check (new, read-only): reads dependency order + active git worktrees,
  recommends the next safe story, warns on overlap, states its heuristic limit (/merge backstop)
  + runtime reminders. Standalone + called by /build. Does NOT touch PM skills (a la carte).
- /build: guided mode-pick (clear/fuzzy -> A/B + why); explicit plan-gate (Mode A prompts
  Shift+Tab, drafts plan, waits, no code before approval; approving auto-exits plan mode);
  conditional worktree setup in Mode A; B1 overlap check scans other worktrees too.
- developer agent: isolation: worktree (from earlier).
- Docs: WORKFLOW parallel section uses verified commands (claude agents terminal fleet dashboard,
  no desktop; claude --bg / --worktree / attach/logs/stop), when A vs B, quick-ref rows.
  BEGINNERS: 'three plans' clarified (a plan / plan mode / /plan / todo.md), golden order fixed.
- 52 skills installed; scaffold + privacy tests green; nothing pushed.
- Deferred (user's call, after this): PM-setup-loop discussion (how /stories, /prioritize,
  /roadmap chain / whether a PM orchestration loop). Plus the long-parked: dogfood test, marketplace listing.

## Review (loops + plain-language, calibrated to leaders)
Researched how leaders do autonomy (Cherny/Wu loop engineering + verifiers; Steinberger
"a loop that can't stop is just expensive"; Claire Vo's oversight warnings; consensus
"orchestration > autonomy", DORA: more autonomy without guardrails = more bugs). We were
already aligned on the orchestration/verifier/human-floor side; iterated lightly:
- Plain-language-to-user rule system-wide (ux-writing applied to all system output + replies),
  plain first + optional labeled technical aside; "teach me as I go" preference in /setup-project
  (default off). Ivan's personal pref = ON (saved to memory).
- AGENTS.md principle: every loop has a verifier + explicit stop (done-signal + max iterations).
- Option 1: developer + /build define an explicit success-signal and loop to it with a bounded
  stop + pass/fail checklist (default = acceptance criteria + tests; quality targets opt-in).
- Option 4: /outcome auto-drafts a /learn entry (approval-gated), proposes knowledge promote/
  demote, suggests next step (e.g. /optimize); nothing auto-runs across a gate.
- Option 2: /optimize, grounded performance loop (measure -> change -> re-measure -> keep if better).
51 skills installed; scaffold + privacy tests green; nothing pushed.

## Review (expansion, full set)
Expanded to the full PM catalog (34 skills + 4 orchestrators). Added: Batch E
(opportunity-solution-tree, roadmap, customer-journey-map, pricing, business-model,
experiments, stakeholder-map), analytics (ab-test, cohorts, query), marketing/growth
(marketing, product-name, growth-loops, battlecard), /sync-community, and orchestrators
/discover, /plan, /spec, /go-to-market. Renamed /gtm -> /gtm-plan (freed /go-to-market).
Each skill cites a named public framework + a worked example. Two-altitude prioritization
(epics via /prioritize+/roadmap; stories via dependency in /stories) and the autonomy
floor (merge/ship/send-out always human-gated) wired in. Docs integrated: README ("your
data: private vs shared" + full catalog + orchestrators), WORKFLOW (full PM set by phase,
order-at-a-glance + freelancer worked example, quick-ref rows), AGENTS (lifecycle order,
two-altitude, autonomy floor, knowledge family). 49 skills installed; scaffold + privacy
tests green; nothing pushed.

## Review (original core)
Shipped the full first-party PM set (17 skills) built from public frameworks, each
credited by name (Torres, JTBD/Christensen, Cagan, Osterwalder, Doerr/Grove, Wake,
Jeffries, RICE/Intercom, McClure, Google HEART, Dunford):
- Discovery: brainstorm, personas, interview-synthesis, competitor-analysis, market-segments
- Strategy: vision, strategy, value-proposition, okrs
- Spec: prd, critique, stories, prioritize
- Metrics/GTM: metrics, positioning, gtm, release-notes
All plugin skills (disable-model-invocation). Integration: global CLAUDE.md, WORKFLOW,
README, INSTALL, install.sh, project-CLAUDE + preset all default to OUR skills; pm-skills
kept as a credited optional alternative (its install step is now optional). install.sh
ships them user-level; scaffold + privacy tests green. Did NOT copy pm-skills text.
Deferred (very end): marketplace listing; the end-to-end dogfood test.
