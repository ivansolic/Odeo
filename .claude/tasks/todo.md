# Task: Phase 2, first-party PM set (own the PM layer)

## ACTIVE DISCUSSION: loops + evals + guardrails (design, not yet built)
Order: #1 evals DONE, #2 improve DONE, #3 signal DONE, #4 prototype DONE, #5 trigger pattern DONE, then TDD-vs-normal-dev option <- NEXT, then CATEGORIZATION, then GUARDRAILS.

#5 TRIGGER (decided): default everywhere = nudge + human-run (system reminds at natural moment, you run). Cron = opt-in later. Trigger per loop's natural moment (table below). Nudge rules: max ONE, short, plain, easy to decline, restrained (only when interval passed / signal built up). DOC TODO: the trigger table must be documented VISUALLY (nice table: loop | natural moment | interval) , knowledge-refresh(session start,quiet | 2-4wk), /improve(repeated eval drop | ~3-5), /product-signal(first session after interval | weekly), /learn+/retro(after /merge or you say end | per story), /outcome(you, ~1wk after ship | per feature). BACKGROUND OPTION: always surface as an option for read-only loops ("run in background while you work?") + document HOW it's done (own worktree, read-only analysis parallel-safe, applying change waits for gate). Honest limit: nudge depends on you opening a session; cron covers "weeks away".
No attribution to individuals for loop/eval/build-first ideas (generic). Keep METHOD names in existing PM skills (RICE/INVEST/JTBD); person names optional.

#3 PRODUCT-SIGNAL (decided): new skill `/product-signal` (name chosen over /signal, clearer). Recurring product-feedback loop: gather (tickets/calls/analytics, read-only) -> cluster into themes (needs not features) -> COMPARE vs last memo immediately (new/stronger/faded) -> draft signal memo -> human gate -> save `docs/signals/<date>.md` (git=history/baseline). Feeds /prioritize,/roadmap,/prd,/outcome. ~weekly, nudge+human, background-able (read-only). A la carte; complements /interview-synthesis (recurring+memory layer). Never fabricate data.

#4 PROTOTYPE / taste-at-speed (decided): new skill `/prototype` (orchestrates, dispatches agents). Alternative DISCOVERY method (build-to-learn). Fidelity choice lo-fi(frontend)/hi-fi(full app). N variants, each own worktree + own port + running server + live URL for side-by-side eval (pairwise) -> kill most (mindset not quota). Sharing: default cloudflared quick tunnel (NO account, temp, machine-on) for both lo/hi; durable/multi-stakeholder/days -> preview deploy (Vercel/Netlify frontend, Railway/Render full-stack, needs free account). NEVER real/PII data in shared prototype (seed/fake) -> guardrail. No project? offer to init one (don't force); if declined, scratch worktree + state consequence (promote needs project later). Findings -> `docs/prototypes/<idea>/findings.md` (durable), skills READ it (nothing auto-uploads): /plan reads epics+effort, /prd reads detail. Findings capture: user flow, screens+states, tasks, test-feedback, decisions+why, worked/failed, tech/data-model sketch, edge-cases + security&data notes, kill-rationale, assumptions validated/invalidated, scope-gaps, dependencies, complexity signal, open risks, metrics, provenance.
  PROMOTE (after validation) rejoins normal flow AT PHASE BY SCOPE (not auto /plan): solo/small -> /spec -> build; real product -> (strategy/business-model, scaled) -> PRODUCT-LEVEL foundation (architecture /setup-project + ADR + architecture-reviewer + high-level critique/pre-mortem incl. product-level security) -> /plan (epics) -> /spec per epic -> build.
  TWO critiques / two architecture levels: PRODUCT-level (once, before features: foundation+security+"does it hold") and FEATURE-level (/critique inside /spec). Prototype proves DESIRABILITY only; product-level covers VIABILITY+FEASIBILITY/foundation it skipped. Even a good prototype still gets a LIGHTER targeted /critique (build/security risks), not full re-litigation.
  Promote paths: harden-in-place (clean prototype: refactor+tests+review) OR throwaway-rebuild (dirty prototype: build from findings). Code quality ALWAYS via Staza A. Prototype never ships raw.

## HARD RULES (go to guardrails):
- PRODUCT-LEVEL FOUNDATION (architecture, data model, security posture, "does the whole thing hold") = NEVER skipped, solo or team. No fast mode that skips it.
- DEVELOPMENT RIGOR (TDD where rules apply, review, security baseline, tests) = NEVER skipped. No fast mode without it.
- STRATEGY (#1) = questions ALWAYS asked + a short durable note ALWAYS written; only DOCUMENT DEPTH scales to ambition (full docs vs one structured one-pager). Light != sloppy: same named sections, clarity, evidence-vs-assumption tagged, decision+date. Never "in head, nothing written".
- Decision: chose (A) foundation+dev mandatory, strategy scales depth only. Rejected (B) light mode that skips product decisions (introduces gaps/debt, no benefit).
- General UX pattern (adopt everywhere): OFFER the option; if declined, STATE the consequence plainly.

Design decided so far (to BUILD after discussion):
- EVAL FRAMEWORK: rubric (criteria+threshold, lives with each skill = data, not agent) + scorers by domain: deterministic (tests/lint), code-reviewer (code), design-reviewer (UI), NEW `pm-reviewer` (PM docs), human (final gate). Reviewers = evaluators (upgrade them to write score+record; no twin agents). 3 scorer types combine (deterministic + LLM-judge + human). Eval records = small files in `docs/evals/<id>.md`, git = history/baseline, read last+baseline. Community eval contribution from the start (opt-in, sanitized, curated, same infra as /contribute-lesson). Compounding WITH curation + human sample-check, not blind.
- #2 IMPROVE-THE-ARTIFACT: new skill `/improve` (chosen over extending /knowledge-refresh). Loop: agent finds signal -> proposes change to skill/rubric/knowledge/prompt -> runs eval (old vs new) -> present -> HUMAN approves keep/revert -> commit (versioned). Agents propose+measure; human approves (changing the system = floor). Two scopes: local (this project) + shipped skills/rubrics (via curation/PR, not silent auto-update). Code improves indirectly via lessons/knowledge (repeat low score -> lesson -> developer avoids next time).
- TRIGGERING (all loops): "nudge + human-run" DEFAULT (system reminds at natural moment, you run it); real cron = opt-in later for advanced. Timing per loop's natural moment: maintenance/signal -> session start (quiet, conditional); learn/retro -> after /merge or when you say end. Intervals: knowledge-refresh ~2-4wk, improve on repeated eval drop (~3-5), signal ~weekly, learn/retro per story.
- BACKGROUND OPTION: nudge may offer "run maintenance/signal in background while you work" (opt-in, not silent auto-start). Read-only analysis runs parallel safely; APPLYING a change waits for gate + runs in own worktree. Apply changes at a calm moment (after /merge / next session start), not mid-coding.
- NAMING: /improve (or /refine). pm-reviewer (consistent with code-reviewer/design-reviewer).

## DOC-TODO , NESTED LOOPS FRAMING (from The Batch 359 / Ng, write in OUR words, no attribution):
- Document our loops as NESTED TIMESCALES (one picture explains all): MINUTES = agent inner loop (builder success-signal: build->test->fix) | HOURS = your steering loop (plan gate, review, taste; you direct, you don't QA) | DAYS = users' loop (/outcome, /product-signal, /experiments -> back into /plan) | WEEKS = system learns (/improve, /knowledge-refresh, compounding). Goes in WORKFLOW + BEGINNERS next to Big Picture.
- POSITIONING language: human "context advantage" , you understand users+constraints the model lacks; that's WHY human-in-command is a permanent advantage, not a temporary brake. Use in README/positioning, our words.
- Validation note: Ng's 3 loops map 1:1 to what we built (independent confirmation; we also have the weeks layer he doesn't name).

## PARKED , GUARDRAILS (build AFTER PM loops + categorization + TDD-option)
Make an explicit Guardrails layer: consolidate scattered rules into `## Guardrails` in AGENTS.md, tagged [enforced] (deterministic: privacy-scan, gitignore, worktree isolation, worktree-parallel-check) vs [instructed] (model-followed: bg=read+propose-not-write, own files/port/db/env, apply waits for gate, plan-first, never-weaken-tests). Strengthen enforced where cheap. Irreversible/dangerous (merge/ship/send-out/secrets/delete) must be enforced mechanism. Each skill references relevant guardrails, doesn't repeat.
Add to guardrails (from #4 discussion): product-level foundation never skipped; dev rigor never skipped; strategy always-asked+short-note (depth scales); never real/PII data in a shared prototype; sharing/deploy = outward = human-gated.
Add to guardrails (from architect/builder discussion): architect is STRUCTURALLY read-only (tools frontmatter = enforced, not instructed); builder implements the approved plan as a CONTRACT (no redesign; plan doesn't hold -> STOP and ask, never improvise) [instructed]; story-architect NEVER redecides product-level architecture (change = escalate to human, ADR) [instructed]; DO-NOT-TOUCH boundaries from codebase-map are binding for architect+builder [instructed]; background/maintenance agents = read+propose only, own worktree, apply waits for human gate [instructed + worktree enforced].

## DEV-RIGOR STYLE (decided): per-project setting in /setup-project, 3 styles (all keep tests+review+security ALWAYS; only test TIMING varies, no gap):
- `TDD` (test-first everywhere) , highest rigor.
- `TDD-lite` (test-first for logic, test-after for UI) , balanced.
- `Test-after` (code first, tests after, everywhere) , fastest, still always tested+reviewed. (formal term: test-last)
- DEFAULT = CONTEXT-AWARE: greenfield(new) -> TDD-lite; brownfield(existing, few/no tests) -> Test-after. User can change. Lives in CLAUDE.md; read by /build + developer. NOT for architecture/epics/strategy. English names + plain explanation in the picker.

## BROWNFIELD / EXISTING-CODEBASE SUPPORT (decided):
- /setup-project gets an "Existing project" mode (user-facing plain; greenfield/brownfield = technical terms only).
- It DISPATCHES a NEW read-only agent `codebase-analyst` (isolated context = better result than setup reading in main context, avoids context bloat on big repos). Analyst returns a STRUCTURED map (stack, architecture, modules, conventions, test state, where-things-live, risky areas).
- /setup-project writes CLAUDE.md + `docs/codebase-map.md` (durable) from the map; developer agents READ the map later (compounding, context minimalism).
- developer on existing code: read relevant part/map first -> baseline (run existing tests if any; else confirm it builds/runs) -> follow THEIR conventions -> add tests for NEW/changed code (test-after) -> NEVER force-retrofit tests on all legacy. review+security still apply.
- A la carte: can dispatch developer for one task without onboarding, but onboarding (codebase-map) makes it much better.
NEW AGENT to build: `codebase-analyst` (read-only). NEW skill mode: /setup-project existing.

## ARCHITECT/BUILDER (decided: ALWAYS-SPLIT in Mode B, TWO SEPARATE AGENT FILES):
- Mode B pipeline (always, no path choice): /build -> `architect` (plans ALL chosen stories) -> HUMAN GATE (approve plan) -> `builder`(s), one per story in own worktree, build per the approved plan AS A CONTRACT -> reviewers -> human gate -> /merge. Spectrum idea REJECTED in favor of one consistent pipeline (simpler, anti-drift everywhere, matches subagent-driven practice; cost = +1 dispatch per story, negligible).
- TWO SEPARATE .md AGENTS (not one agent with two modes), decisive reason: tools are per-agent-file frontmatter. architect.md = tools Read/Grep/Glob -> STRUCTURALLY read-only (enforced brake, cannot write even if it wanted). builder.md = full tools + isolation: worktree. One file can't have two tool sets. Also: clean focused contexts (minimalism) + each independently invokable a la carte (@agent-architect plan-only; @agent-builder build-from-my-plan; /build orchestrates both).
- MIGRATION: agents/developer.md -> agents/builder.md (keeps EVERYTHING: isolation: worktree, success-signal loop, green baseline, reads AGENTS/CLAUDE+lessons+knowledge+community, dev-rigor applies, never-weaken-tests, stop-and-ask; only "makes its own plan" moves out , plan becomes its INPUT/contract; if plan doesn't hold -> STOP and ask, no improvising). agents/architect.md = NEW (read-only; plan-only: approach, interfaces, boundaries, risks; clarification-first; on brownfield INHERITS stack + respects codebase-map DO-NOT-TOUCH; escalates to human if a story would require changing product-level architecture , that's an ADR decision).
- TWO ARCHITECTURE LEVELS (document clearly): PRODUCT-level (once, foundation: /setup-project + ADR + architecture-reviewer + high-level critique , monolith-vs-services, data model, stack, security posture) vs STORY-level (architect agent, per story batch inside /build, plans WITHIN the inherited foundation, never redecides it).
- PLAN MODE vs ARCHITECT (document): Mode A = you+Claude plan live, Shift+Tab plan mode is YOUR manual read-only brake (no architect agent there; you are the architect-approver). Mode B = architect agent replaces interactive planning; its brake is built-in (read-only tools). /build remains just the DOOR; inside it architect runs FIRST, before any code.
- Mode A unchanged. Trivial fixes still skip /build (fast lane). Parallel fleet unchanged (builders are the parallel worktree agents).
- DOC TODO: document all of this thoroughly (two agents, always-split pipeline, two architecture levels, plan-mode-vs-architect mapping, invocation a la carte).

## PLAN-FORMAT STANDARD (decided, generic principles in OUR words , this IS the architect's contract):
- Architect's plan MUST contain: HEADER (goal, architecture, stack, constraints verbatim from spec) -> FILE MAP before tasks (files created/modified + responsibilities = design boundaries upfront) -> TASKS = smallest independently testable units, TDD rhythm (test->fail->implement->pass->commit), each step ~2-5min with EXACT paths, function signatures, commands, expected outputs.
- NO PLACEHOLDERS rule: "TBD"/"add validation"-style vagueness = plan failure. Explicit consumed/produced interfaces between tasks (builder sees dependencies).
- Saved to docs/plans/<date>-<feature>.md. QUALITY TEST: a context-free builder (or unfamiliar dev) can execute it alone , that's the bar. Add a PLAN RUBRIC to the eval framework (pm-reviewer or code-reviewer scores plan quality).
- Applies DRY/YAGNI; frequent commits (each task ends in commit).

## RECEIVING-REVIEW DISCIPLINE (decided, fold into builder + /build):
- Builder must VERIFY each reviewer finding before acting (reviewers can be wrong): confirmed -> fix (Critical/Important mandatory); not confirmed -> push back WITH EVIDENCE, never blind compliance, never blind dismissal. Human arbitrates disputes at the gate.

## SKILL-CRAFT TAKEAWAYS (from analyzing obra writing-skills , concepts in OUR words, never copy text):
1. SUBAGENT-TESTING METHOD for /improve (fills the "how do we eval a skill change" gap): fresh subagent per scenario, control WITHOUT the guidance vs variant WITH it, compare behavior; pressure-scenarios for discipline skills; document exact failure/rationalization patterns at baseline. Full rigor (5+ reps) reserved for discipline-critical skills (guardrails/TDD/merge/privacy) + /improve keep-revert decisions; content PM skills use output rubrics instead (cheaper, already designed).
2. BULLETPROOFING for GUARDRAILS step: agents under pressure RATIONALIZE around rules ("spirit vs letter") -> instructed guardrails must be pressure-tested, loopholes explicitly closed, rationalization counters written. Feed into guardrails build.
3. SKILL-AUTHORING STANDARD for ourselves (and later contributors): auto-invoked skills' descriptions start "Use when..." + trigger conditions ONLY (no workflow summary , agents skip reading otherwise), keyword/symptom coverage; one excellent example > many mediocre; token efficiency; flowcharts only for decisions; SKILL.md lean + heavy reference in supporting files. Matters MOST for auto-invoked skills (ux-design, ux-writing, TDD); explicit commands less critical but same standard.
4. PARKED , contributor-facing writing-skills guide (CONTRIBUTING/community phase) gets this content, our words.

## PARKED , CATEGORIZATION (NEXT): categorize all skills/loops; decide `-loop` suffix vs a "Loops" category (recurring: /product-signal, /improve, /knowledge-refresh). Autofill mitigates length.
Reference note (obra/superpowers subagent-driven-development = essentially our /build Mode B; confirms rigorous path; not a prototype model).

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
