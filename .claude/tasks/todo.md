# Task: Phase 2, first-party PM set (own the PM layer)

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
