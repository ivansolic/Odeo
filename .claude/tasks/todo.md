# Task: Phase 2, first-party PM set (own the PM layer)

## BUILD PROGRESS
- [x] BATCH 1 , eval framework (2026-07-07): eval-framework.md + skill-authoring-standard.md (+skill rubric) + prd/stories rubrics + NEW pm-reviewer & skill-reviewer + code/design-reviewer upgraded (review=eval, records) + contribute-lesson extended (rubrics/eval learnings) + install (system docs -> ~/.claude/claude-cofounder-docs/) + scaffold docs/evals/. All checks green.
- [x] BATCH 2 , agent core (2026-07-07): plan-format.md+rubric, architect (read-only), developer->builder (contract+receiving-review), codebase-analyst, /build architect->gate->builders pipeline, /setup-project existing-mode + dev-rigor picker, repo-wide reference update, scaffold docs/plans. All checks green.
- [x] BATCH 3 , new skills (2026-07-07): system-map.md + /guide (auto-invoked advisor) + /start + /improve (A/B keep/revert) + /product-signal (weekly compare) + /prototype (worktree+port+server per variant, findings, promote gate) + OKR check-in mode + roadmap-drift offers in /outcome & /product-signal. All checks green.
- [x] BATCH 4 , guardrails (2026-07-07): AGENTS.md ## Guardrails (6 groups, E/I, counters on 4 critical rules) + enforced mechanisms (secret-scan, boundary-check, merge-gate, install-git-guards w/ pre-push+pre-commit hooks) wired into /commit-push, /merge, /build, init-project. 28 test assertions green; live block verified. Live pressure-testing of counters -> dogfood.
- [x] BATCH 5 , alignment + docs (2026-07-07): 56-skill alignment pass (recorded), Use-when fixes on 3 auto-skills, examples added to merge/retro/sync-community, Anthropic checklists recorded (1 accepted gap), WORKFLOW nested-loops + trigger table + background docs, README context-advantage + new bullets, BEGINNERS never-lost. ALL 5 BATCHES COMPLETE.

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

## GUARDRAILS , FINAL DESIGN (user confirmed 2026-07-07):
One `## Guardrails` section in AGENTS.md = single source of truth; skills/agents REFERENCE rules (no copies). Tags: [E] enforced by mechanism, [E-part] partially enforced, [I] instructed (+bulletproofed where critical). PRINCIPLE: [E] for anything reducible to artifact-existence, file-path check, or script exit code; [I] for judgment calls, layered with bulletproofing + verifiers + human gate.

GROUP 1 HUMAN FLOOR: merge/push to main [E-part: pre-push hook blocks direct push + recommend GitHub branch protection; approval itself procedural] · ship/deploy [I] · data leaving machine [E privacy-scan + I approval] · system changes via /improve [I keep/revert gate].
GROUP 2 PRIVACY: privacy-scan before anything leaves [E] · personal layer never public [E gitignore] · NO real/PII data in shared prototype [E: share/deploy step MUST run privacy-scan over prototype seed/env/data, exit 1 = share blocked] · secrets in commits [E: secret-scan hard gate in /commit-push + pre-commit hook; logs stay I].
GROUP 3 QUALITY NEVER-SKIP: product foundation [I + E-part: artifact-existence checks (CLAUDE.md filled, ADR exists) at /build; quality unjudgeable by script] · dev rigor [I + E-part: /merge gate script-checks tests green + review/eval record exists, else REFUSED] · never-weaken-test [I, bulletproof #1, later optional detector "test modified & now passes -> warn"] · strategy asked+noted [I + existence check of brief] · plan-first [Mode B = E via pipeline: builder REQUIRES approved plan doc in docs/plans/ as input, no plan = no dispatch; Mode A = I].
GROUP 4 LOOPS: verifier + stop (done-signal + max ~3 tries -> stop & report) [I] · nudge max-one/restrained/easy-decline [I] · no silent cron [E BY DESIGN: no scheduler exists in the system; cron only if user explicitly sets it up].
GROUP 5 AGENTS & ISOLATION: architect read-only [E tools] · reviewers + codebase-analyst read-only [E tools] · dispatched/bg agents own worktree [E isolation:worktree] · bg ANALYSIS agents read-only tools, proposal returned as message, apply via main session gate [E] · builder executes approved plan as contract, no redesign, plan breaks -> STOP & ask [I bulletproof] · story-architect never redecides product architecture (escalate = ADR) [I] · DO-NOT-TOUCH [E: mechanical path check , diff builder's changed files vs codebase-map do-not-touch list before present//merge, touch = BLOCKED] · own port/db/env per worktree [I reminder].
GROUP 6 HONESTY: never fabricate data [I bulletproof] · never "done" with failing signal [I] · admit limits/heuristics [I] · never invent commands/capabilities (/guide) [I].
META: a rule not written down does not exist.
ENFORCED-GATE UX: gates physically stop with a PLAIN message saying what's missing + how to fix (e.g. /merge refused: "tests red" / "no review record"; /build: "no approved plan, run architect?"; commit blocked: secret shown).
BULLETPROOFING PASS (build-time, for critical [I]: never-weaken-tests, builder-contract, PII-in-prototype, never-fabricate): fresh subagent in temptation scenario -> record exact rationalizations -> write counters INTO the rule -> retest until no loopholes. Output: hardened rule text + documented excuse table.
BUILD ORDER for guardrails: 1) AGENTS.md ## Guardrails section 2) skills/agents reference pass 3) mechanisms: pre-push hook, secret-scan gate in commit-push, share-step privacy-scan, /merge script-gate, do-not-touch path check, plan-artifact requirement in /build pipeline 4) bulletproofing pass 5) cheap [I]->[E] upgrades review.

## (old parked note, superseded by final design above)
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
5. ANTHROPIC OFFICIAL skill-authoring guidance (public docs; obra vendored a copy , we DON'T copy, we fold principles into our authoring standard, our words + pointer to official docs): context window = public good (conciseness is duty); progressive disclosure (SKILL.md <500 lines, reference files max ONE level deep); third-person descriptions; test across target models; PRE-WRITTEN scripts over agent-generated code for critical ops (we already do: privacy-scan.sh); no time-sensitive info; consistent terminology; evals BEFORE extensive docs.
6. CONSULT AT BUILD TIME (official Anthropic, concepts in our words): "Building Effective Agents" essay (orchestrator-workers, evaluator-optimizer , validates our orchestrators + eval loops) + "Claude Code Best Practices" blog (CLAUDE.md, explore->plan->code->commit, TDD, subagents).
STATUS writing-skills: NOT built yet. Will exist in TWO forms: (a) embedded , subagent-testing in /improve, bulletproofing in guardrails, authoring standard for our own skill writing; (b) contributor guide later (community phase).
7. AUTHORING STANDARD = MANDATORY artifact at build time: `docs/skill-authoring-standard.md` (our rules incl. Anthropic-official principles). USED: checklist for every new skill; TRACKED: skill rubric in eval framework (pm-reviewer can score a skill against it) + /improve references it + ONE-TIME alignment pass over the existing 51 skills. Also MANDATORY at build time: systematic checklist pass through "Building Effective Agents" + "Claude Code Best Practices" (have/missing/not-needed + why).
8. DOCUMENTATION/EXPLANATION TEMPLATE (user rule, canonical): 1) WHAT (one plain sentence) 2) EXAMPLE (concrete walkthrough with real values, never abstract) 3) WHY (design decisions explained, analogies where they help) 4) WHERE IT LIVES / use cases (when yes, when no) 5) CONCLUSION + reasoning/limits (honest about what it doesn't cover). The subagent-testing explanation goes into docs AS the canonical sample of this template. Applies to all docs + all explanations.
9. RIGOR ALLOCATION (decided rationale, document it): 5+ reps reserved for critical skills = RISK-BASED TESTING (cost 10+ agent runs per change; content-skill errors are cheap+caught by later layers rubric/critique/human gate; guardrail failures are expensive+dangerous; marginal benefit diminishes). NOT a ban , user can request full rigor on any skill anytime.
10. META-RULE "EVERYTHING IN WRITING" (user, hard rule -> AGENTS.md): a rule/process that isn't written into a durable artifact DOES NOT EXIST. No tribal knowledge. Mapping at build: authoring standard -> docs/skill-authoring-standard.md; Anthropic checklist pass -> docs/checklists/anthropic-practices-pass.md (RESULT written: have/missing/not-needed + why); doc template -> authoring standard + AGENTS.md; rigor allocation -> AGENTS.md/guardrails; guardrails -> AGENTS.md ## Guardrails; trigger table/nested loops/arch-builder -> WORKFLOW+AGENTS. Until build, todo.md is the design ledger (all decisions live there).
11a. ROLE SPLIT in skill improvement (decided, precise): skill-reviewer = STATIC form check of the skill FILE against authoring standard (does NOT test behavior, does NOT call other reviewers). /improve = EXPERIMENT ORCHESTRATOR (runs subagent A/B tests, decides rep count 5+ only for critical, calls the right domain reviewer). Domain reviewer (pm-/code-/design-) = BLIND scoring of the OUTPUTS the test subagents produce (domain chosen by what the skill produces). Flow: improve proposes -> skill-reviewer form gate -> subagent A/B -> domain reviewer scores outputs -> improve compares -> human keep/revert -> commit. Analogy for docs: proofreader (skill-reviewer) / subject grader (domain reviewer) / study lead (improve).
11. SKILL-REVIEWER (decided, user's call , don't mix domains): NEW agent `skill-reviewer` scores SKILLS against the authoring standard + skill rubric (structure, "Use when..." description, token efficiency, example quality, no placeholders). pm-reviewer stays PURELY PM/product documents (spec: PRD/stories/AC; discovery: personas/journey/OST/interview/findings; strategy briefs incl. light one-pagers; planning: roadmap/prioritization; launch: gtm-plan/positioning/signal memos; used for gates, regression, /improve on PM docs, blind scoring in subagent tests). Reviewer map final: code-reviewer=code, design-reviewer=UI, architecture-reviewer=architecture, pm-reviewer=PM docs, skill-reviewer=skills (+later community-contributed skills before curation), deterministic scripts, human final gate. All reviewers invokable standalone (consultant mode). DOCUMENT the reviewer map + each scope.

## CATEGORIZATION (DECIDED, user confirmed all):
- 10 lifecycle categories (doc/mental map; GitHub repo layout stays TECHNICAL skills/+agents/ flat , plugin format; README/WORKFLOW carry the categorized map): 1 Setup & Onboarding (setup-project, setup-design; codebase-analyst*) · 2 Discovery & Research (brainstorm, personas, interview-synthesis, competitor-analysis, market-segments, opportunity-solution-tree, customer-journey-map, experiments, prototype*) · 3 Strategy & Viability (vision, strategy, value-proposition, okrs, business-model, pricing) · 4 Planning/portfolio (prioritize, roadmap, stakeholder-map) · 5 Specification (prd, critique, stories) · 6 Build & Integrate (build, merge, commit-push, optimize, worktree-parallel-check; agents architect*, builder*(=developer), debugger; auto: TDD, ux-design, ux-writing) · 7 Metrics & Analytics (metrics, ab-test, cohorts, query) · 8 Launch & Growth (positioning, marketing, gtm-plan, release-notes, growth-loops, battlecard, product-name) · 9 Knowledge & Learning (learn🔁, retro🔁, outcome🔁, knowledge-refresh🔁, product-signal*🔁, improve*🔁, contribute-lesson, sync-community) · 10 Orchestrators (discover -> plan -> spec -> go-to-market). Reviewers cross-cutting (code/design/architecture/pm*/skill*) + deterministic + human gate.
- LOOP NAMING = (b+c): NO -loop suffix in command names (verified practice: obra/EveryInc/3rd-party-PM-plugin/gstack/builtins , zero "loop" names; loop lives in concepts/docs) + 🔁 mark + a "Recurring loops" cross-section block in docs. growth-loops stays (domain term for the product-growth skill, unrelated to our system loops , document the distinction).
- NEW: /start (read-only orientation: reads project state -> you-are-here on lifecycle map + next step + consolidated 🔁 nudges; empty-project variant suggests entry points). Category: Setup.
- PM loops: covered (product-signal weekly, outcome per-ship, experiments per-bet, improve on eval-drops, learn/retro, macro signal->plan->spec->build->outcome). Two small additions, NOT new skills: ROADMAP-DRIFT NUDGE (after /outcome or /product-signal with picture-changing findings -> offer to revisit /roadmap) + OKR CHECK-IN MODE (re-running /okrs over existing OKRs = compare actuals vs KRs, status). NO PM executor agent (PM work = conversation with the user, their context advantage; research via built-in subagents; pm-reviewer evaluates; revisit only if dogfood shows a concrete need , then a narrow read-only research agent, never a "PM writer").

## NEW , /guide (ANYTIME ADVISOR, decided design, user requested):
- Goal-driven navigator: user states a goal in plain words -> /guide knows the WHOLE system (catalog + lifecycle map + our decision trees: discover-vs-prototype, Mode A-vs-B, TDD styles, tunnel-vs-deploy, etc.) + reads project state -> returns the ROUTE: commands in order, options with tradeoffs, missing prerequisites, example invocation. Read-only; offers "want me to start it?" (runs only on user's yes).
- KEY MECHANISM: NOT disable-model-invocation , auto-invoked skill with "Use when the user asks how to proceed / which command / what are my options / what's needed..." description -> activates BY ITSELF whenever the user asks "how do I...", no need to remember the command. First auto-invoked navigation skill.
- Consults docs/system-map.md (single source of truth catalog; authoring standard REQUIRES updating it when a skill is added). Honest-limits rule: if the system doesn't cover it -> say so + closest alternative/manual path; NEVER invent commands. Respects teach-me setting. /start = WHERE AM I (state) vs /guide = I WANT X, HOW (goal); guide uses state for the route FROM here TO goal; documented as a pair.

## PARKED (long) , end-to-end dogfood test; marketplace listing.

---


Goal/outcome: the system owns its full discovery->spec flow with our own skills,
built from PUBLIC frameworks in our own words (credited by name), so there is no
hard dependency on 3rd-party-PM-plugin. Human-in-command positioning throughout.

Integrity rule: build from public frameworks (Cagan, Torres, ProductCompass-style
PRD, 3 C's / Jeffries, INVEST / Wake, RICE / Intercom) in OUR words; credit each by
name; never copy/reword 3rd-party-PM-plugin text.

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
- 3rd-party-PM-plugin handling: TBD (see decisions) , default to ours; keep 3rd-party-PM-plugin optional + credited, or remove.

## Decisions (confirmed)
- Scope: FULL set now (build in batches, depth over shallow stubs).
- 3rd-party-PM-plugin: default to OURS; keep 3rd-party-PM-plugin optional + credited (no big-bang removal).
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
- [ ] WORKFLOW.md Phase 1 + global CLAUDE.md PM section point at our skills (3rd-party-PM-plugin optional/credited)
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
README, INSTALL, install.sh, project-CLAUDE + preset all default to OUR skills; 3rd-party-PM-plugin
kept as a credited optional alternative (its install step is now optional). install.sh
ships them user-level; scaffold + privacy tests green. Did NOT copy 3rd-party-PM-plugin text.
Deferred (very end): marketplace listing; the end-to-end dogfood test.

## DOGFOOD FIX BATCH (2026-07-13, approved A / pending sign-off B)

### Batch A — approved by Ivan
- [x] A1 merge-gate.sh: parse ONLY frontmatter `verdict:` (+ TDD tests) — F2
- [x] A2 reviewer agents: single clean frontmatter verdict, history in body — F2
- [x] A3 /merge: CI-exists check + warm /learn nudge; /start: /retro nudge; rewrite both nudges positively (no "skip if you like") — F3, F6 + tester note
- [x] A4 secret-scan.sh: credential-assignment rule skips test paths, key formats stay global (+ tests) — F5
- [x] A5 init-project.sh: git identity sanity check (machine/work email warning) — F7
- [x] A6 architect plan template: mandatory design-token wiring task for new UI packages — F8
- [x] A7 3rd-party-PM-plugin: port best bits into our skills (multi-lens ideation, product-focused), sharpen our `description:` triggers, INSTALL.md says uninstall 3rd-party-PM-plugin — F1
- [x] A8 origin/HEAD auto-fix: `git remote set-head origin -a` baked into every first-push point (init next-steps, /merge, /build) so built-in /security-review works — F4 upgraded from doc-note to real fix

### Batch B — from tester notes (sign-off pending)
- [x] B1 VS Code integration (MUST): always `code -r` (reuse window, no dock dupes); PM docs auto-open after creation; Mode A live reveal standard; Mode B offers opening the worktree; document native gutter/diff coloring
- [x] B2 learning comments rule for builder + subagents (decided: teach_me-linked, default ON; comments = intent + connections, updated with the code)
- [x] B3 merge human-floor: /merge NEVER self-triggers; /build ends with an offer, not an action; guardrail + rationalization counter in AGENTS.md
- [x] B4 test-command hygiene: non-watch runners (vitest run), timeouts; /setup-project fills non-interactive commands; builder rule
- [x] B5 for-me mode: architecture-reviewer reviews EVERY architect plan before the human gate (decided: every story)
- [x] B6 mode ALWAYS asked, never inferred (/build wording + guardrail)
- [x] B7 Mode A: optional "want the architect agent to draft the plan?" offer
- [x] B8 entry flow: /start + /setup-project ask "do you have the idea yet?" → route brainstorm/prototype-first; remove preset-ad line; mode names decided: 'with me' / 'for me' (A/B aliases kept)
- [x] B9 /critique writes follow-ups into todo/backlog so long projects resume cleanly
- [x] B10 /setup-design: own-design-system/Figma source added; invokability decided: setup+navigation+discovery model-invocable, build/merge/commit-push human-only
- [x] B11 stories skill: words over symbols ("at least one"), audience-adaptive AC technicality, standalone/no-repo mode
- [x] B12 docs: "grounded in established frameworks" section (INVEST, 3C's, JTBD, diverge-converge...); cleaner chat output, VS Code preview tip
- [x] B13 project template ships .claude/settings.json permission allowlist (tests/lint/typecheck/git-read) to cut prompt fatigue
- [x] B14 model-robustness pass: critical rules rewritten imperative with rationalization counters (merge floor, verdict ownership, mode ask, false-green); measurable target set: zero human-floor violations + zero false greens on Opus, verified by the next dogfood. Full-catalog wording pass stays on the watch list
- [x] AFTER-1: CI, built as the /ci skill (generates checks.yml from the project's Commands section; offered once by /setup-project and /merge; skill-reviewer PASS 8/10, both fixes applied)
- [ ] AFTER-2: /prototype dogfood test (Ivan drives it, not yet run)

## INNOVATION BATCH (2026-07-16, from the cross-test synthesis)
- [x] #1 skills-lint + docs/invariants.md: 9 mechanical invariants (each born from a real dogfood bug), 16 tests, repo passes its own lint; first run caught 4 real violations; person credits stripped from 14 skills (C8 enforces)
- [x] #2 share-tunnel.sh (TTL, self-closing, .shares registry) + session-end-check.sh (Stop hook) + /start share reminders + guardrail entries; 11 tests
- [x] #5 /research skill: 2+ sources or 'unverified', ranges with methods, RES-NNN reports; offered by /prd and /discover; skill-reviewer PASS 8/10, fixes applied
- [ ] #3 living design gallery + Figma token bridge (A-G elaboration in chat + results docs), PARKED by Ivan until after launch
- [ ] #4 /improve "calibrate" mode, MOVED TO PRE-LAUNCH by Ivan 2026-07-17 (metrics before launch); metric map approved: fire-rate (descriptions), separation (rubrics), catch-rate on seeded bugs + 5-rep variance (reviewers), verified-real rate (vendor prompts), attempts-to-green + stop-and-ask counts (plans/builder, already in records), unverified-ratio + claim-survival (research), route-correct rate (guide/start), knowledge reuse-rate, nudge acceptance-rate; NOT metricized: taste/aesthetics/tone/strategy wisdom (human judgment, Goodhart guard: metrics are sensors for /improve, verdicts stay with reviewers + human)

## LAUNCH POLISH BATCH (approved 2026-07-17, build AFTER the naming decision)
- [ ] README narrative rewrite (gstack-style storytelling: hook -> philosophy -> the loop -> catalog by phase -> honest limits); our lifecycle gets its branded name here
- [ ] Prefix decision folded into branding (marketplace namespace resolves it once); no mass rename before that
- [x] second-opinion SHIPPED on main (beab56b Phase1-5, a20ce40 -pm/-plan/-design):
      FOUR focused skills (code/pm/plan/design) + docs/second-opinion-protocol.md +
      bin/second-opinion.sh + lint C10 (16-test wrapper suite). NAME TBD at brand.
      Original design (evolved from ONE skill to four, one per reviewer jurisdiction),
      target as argument: code | plan | pm | design, each cross-diffed against
      the matching OUR reviewer (code/architecture/pm/design); design target
      needs a multimodal vendor CLI (gemini), code/plan/doc work with codex.
      Design decided 2026-07-17:
      * wrapper script (bin/) is the ONLY sanctioned path: runs the vendor CLI non-interactively, captures the RAW transcript to a file, stamps provenance (CLI version, actual model id parsed from output, duration, output hash); record references the raw log; missing CLI = exit 3, skill stops (never simulates)
      * strongest vendor model requested EXPLICITLY (--model flag/config), the model that actually answered is printed + recorded in frontmatter (vendor_model:); if the account lacks the top model, say so, record what ran
      * consent: per-invocation default; optional per-session/per-branch scope grant (never persisted, never global); secret-scan over the diff before EVERY send regardless; delta shown on repeat sends
      * authority: merge-gate reads only OUR code-reviewer's verdict; second opinion informs, never rules
      * absorb-the-strength loop: recurring unique-to-vendor findings become checks in OUR code-reviewer (via /improve)
- [x] /focus session edit boundary SHIPPED on main (671c91d): PreToolUse hook
      focus-check.sh (deny-only, fail-open, path-escape safe), 11-test suite, [E]
      guardrail. (Was "/freeze".)
- [x] /sync-docs docs-drift reconciler SHIPPED on main (671c91d): gather->compare->
      draft->gate; offered by /merge on documented-behavior diffs. (Was "/document-release".)
- [ ] Park notes: taste-memory/design-shotgun ideas live with the design gallery batch; transparent opt-in telemetry with the marketplace phase
      * gstack /codex implementation notes (read 2026-07-17, source studied):
        `codex review "<prompt>" -c 'model_reasoning_effort="high"'` for the gate;
        `codex exec "<prompt>" -C <root> -s read-only --json` for adversarial/consult
        (read-only sandbox flag!); model NOT hardcoded (default frontier, -m override);
        diff embedded in the prompt (newer codex rejects prompt+--base together);
        plan content pasted verbatim (never "read this file", wastes tool calls);
        filesystem-boundary line in every prompt (never read ~/.claude, agents/);
        timeouts 330s/600s with exit-124 handling; auth probe before running;
        session resume via saved session-id for consult mode; findings logged as
        JSON for the cross-model overlap table (Both/Only-X/Only-Claude + agreement %).
        Ours adds on top: consent gate w/ scoped grants, secret-scan pre-send,
        provenance wrapper (raw transcript + hash), vendor_model: in the record.
      * MUST (Ivan 2026-07-17, "vrijednost ogromna"): ONE skill over a shared
        bin/second-opinion.sh (mechanism in script, thin prose); NO new agents;
        vendor matrix defaults per target (code/plan/doc->codex, design->gemini,
        re-verify capabilities at build time) + --vendor override + both-option;
        STRUCTURED findings mandatory from v1 (target, finding class, file:line,
        who found it), they feed the absorption loop: /improve mines recurring
        vendor-unique finding classes into permanent checks in OUR reviewers,
        every paid second opinion permanently upgrades the first.
      * Comparison flow (Ivan): OUR matching reviewer (not the main session,
        not a new agent) receives the vendor findings and authors the
        comparison in the second-opinion record (overlap / only-ours /
        only-vendor + recommendation); vendor findings NEVER touch our
        verdict; the main session presents it and discusses next steps with
        the user; builder verifies-before-fixing as with any review.
      * Invocation: human-invoked only (data leaves + costs money); offered
        max once at natural moments, never after a decline. Offer TRIGGERS
        approved by Ivan 2026-07-17 (named list lives in the skill, the offer
        always states its reason): risky review = touches auth/payments/
        uploads/data-access paths, or security dim < 2, or a contested
        finding, or 2+ REQUEST-CHANGES cycles; big bet = critique flagged a
        severe sink-it assumption, multi-epic scope, or a hard-to-reverse
        decision. Vendor ASKED by name when >1 installed (recommendation from
        the matrix); strongest model always, named and recorded.
      * FINAL SHAPE, CLOSED by Ivan 2026-07-18: FOUR focused full-standard
        skills, in this order and naming: second-opinion-pm (everything
        pm-reviewer judges, incl. discovery: personas, OST, experiments,
        interviews, PRD, stories, strategy, roadmap, research, GTM),
        second-opinion-plan (-> architecture-reviewer), second-opinion-design
        (multimodal, look + UI code -> design-reviewer), second-opinion-code
        (diff -> code-reviewer). Target rule: a target = its reviewer's
        jurisdiction (new PM doc types need no new skill). Each skill is FULL
        per the authoring standard (Use when, process, vendor instructions
        that grow, worked example, limits), only the shared mechanism is
        referenced, never restated: ONE docs/second-opinion-protocol.md +
        ONE bin/second-opinion.sh. Working names final at branding.
        (superseded draft below:) FOUR thin per-target skills
        (second-opinion-code/-plan/-doc/-design) + ONE shared protocol doc
        (consent, provenance, record format, vendor matrix, referenced never
        restated) + ONE bin/second-opinion.sh; lint C10: all four reference
        the protocol, line cap each, no vendor names in file/command names
        (names mandatory IN records: vendor_model:, and spoken at send time)
      * Maximize gstack adoption (Ivan): adversarial think-like-an-attacker
        framing, diff-in-prompt, filesystem boundary line, read-only sandbox
        flag, timeouts, severity markers, three modes
      * ALWAYS strongest models for review-class actions (both vendors and
        ours), stated and recorded, cheaper only by explicit override
      * Adversarial mode is READ-ONLY: the vendor reasons about how the code
        fails (file:line), never edits, never executes attacks; when a finding
        needs proof, OUR builder writes the failing test in OUR worktree
      * Model picker (Ivan 2026-07-19): default = vendor's strongest AVAILABLE
        on the user's actual subscription, resolved live and ANNOUNCED as a
        question (user can stop/override in one line, e.g. "koristi Terru");
        full picker only ON DEMAND: fetch the vendor's CURRENT model list with
        their own one-line descriptions and tier/variant structure (e.g.
        Sol/Ultra, Terra, Luna) at call time, never baked into files; record
        what actually ran (vendor_model:). Symmetric on every host (on Codex,
        picking Claude's model works the same way).
      * Token/cost bounds: reviews are bounded jobs (one artifact, one diff),
        review loop capped at 3 cycles, expensive classes (both-vendors,
        repeats) declare budget upfront; user can downgrade tier anytime by
        explicit override; org/spend limits are the hard external wall, state
        lives in files so work resumes cleanly after a reset.
      * Vendor is an ARGUMENT, never a skill name: no codex-*/gemini-* skill
        family; per-vendor CLI differences live inside the wrapper script.

## POST-LAUNCH BACKLOG (recorded 2026-07-17)
- [ ] PORTABILITY (approved 2026-07-17): the system installable on other hosts
      (Codex, Cursor, ...), requires translating skill/agent formats per host;
      design consequence already locked: second-opinion is host-symmetric
      (vendor = runtime detection, never a command name).

## MOVED TO PRE-LAUNCH by Ivan 2026-07-17 (part of the launch polish batch):
- [x] /deploy SHIPPED on main (27ce3cd): re-check green -> rollback-ready-first ->
      deploy to the CLAUDE.md platform -> live smoke test -> record to
      docs/deploys/history.md -> offer /outcome. PRODUCTION human floor (explicit
      go), staging may proceed. skill-reviewer 10/10. NAME TBD at brand.
      Original design note: human says ship, the skill does the
      craft, re-check, deploy to the project's platform (from CLAUDE.md), live
      smoke test, ready rollback. NEVER auto-CD to production (human floor);
      optional auto-deploy to STAGING only. Closes the gap before /outcome
      (outcome assumes something shipped). CI=yes CD-decision=human stays the line.

## MODEL POLICY PACKAGE (built 2026-07-18, approved by Ivan)
- [x] Tier-based model policy shipped: builder pinned to sonnet tier (inherit =
      human-flipped max-quality override); judgment inherits the session;
      semantic preference (strongest|strong-default) in setup-project; model
      plan asked as a QUESTION before work (written as model_plan: in for-me
      plans, builder contract requires it); /start preference + new-top-model
      reminders; reviewers record model: + model_tier:; tier map lives once in
      AGENTS.md (fast=haiku/flash/mini classes)
- [x] Guardrails: [E] lint C11 (no version-pinned model names/ids anywhere in
      instruction files, prose included, Anthropic-family alternation extended
      per host at port time; builder tier pinned), [E] gate tier floor
      (allowlist fast|strong|strongest, fast needs model_waiver: human, deny
      by default), [I] question-not-FYI announcement, no silent switches,
      record-model honesty
- [x] Review loop ran: code-reviewer 7/12 REQUEST CHANGES (Critical: blocklist
      floor) -> fixes+8 tests -> 11/12 APPROVE WITH COMMENTS -> final fixes
      (template line, casing test); skill-reviewer PASS 9/9/9, 4 fixes applied.
      Suites: lint 23, merge-gate 22, spec-gate 26.
- Born from the live incident: a stale versioned name was quoted in
  conversation while its successor had already shipped; the system now cannot
  repeat it in files, and resolves names live everywhere else.

## EFFICIENCY + QUALITY UPGRADES (approved 2026-07-18, from a study of an external agent-skills framework)
Naming locked this session: /freeze -> /focus, /document-release -> /sync-docs
(final naming pass still at branding). /prototype PM-artifact bridge shipped
this session (10/10). Then this track:
- [x] Phase 1 (729d0ef) , token-report (measure first): NEW bin/token-report.py (python3
      stdlib; per-agent token breakdown from a session .jsonl; prices never
      hardcoded, optional --input-price/--output-price add a $ column) + NEW
      tests/token-report.test.sh + system-map line. code-reviewer on the script.
- [x] Phase 2 (fae8a5a) , plan-format C+D: complete-code-as-economy (exact code in the
      task, builder transcribes) + task right-sizing (smallest unit worth a
      fresh reviewer's gate). GUARDRAIL (Ivan): complete code does NOT waive
      test-first, builder writes failing test (RED) then transcribes (GREEN);
      one sentence, no new logic/code.
- [x] Phase 3 (fae8a5a) , review budget B: code-reviewer + design-reviewer get a diff-first
      scope (don't crawl unless naming a concrete risk; don't re-run the suite to
      confirm the builder's report). Removes redundant work only; diff scrutiny
      unchanged.
- [x] Phase 4 (fae8a5a) , Scrutiny-tag A (per-story, reframed): per-task `Scrutiny:` tag
      (mechanical|standard|judgment) is a reviewer ATTENTION signal only (where to
      look hardest), NOT a model selector. Renamed from `Tier:` off the arch
      review to avoid colliding with model_tier. Reviews ALWAYS run on the
      strongest via session preference (Ivan's call 2026-07-18); NO review_tier
      field, NO model-scaling. Per-task dispatch DEFERRED pending token-report.
      arch-reviewer loop: round 1 PROCEED-WITH-MODS (4 concerns) -> fixes ->
      round 2 PROCEED (all closed, constraints hold).
- [x] Phase 5 (90583ab) , red-flag pattern: optional calm two-column table device in
      skill-authoring-standard.md (reference guardrail, don't restate; only where
      a shortcut is observed). Exemplar in the standard; no skill retrofits yet.
- [x] Phase 6 (90583ab) , judgment-eval scaffolding: docs/checklists/review-calibration.md
      format + 1-2 seed planted-defect scenarios; live calibration folds into
      polish #3 (/improve calibrate mode).
- Do NOT: multi-harness (parked), their caps/pressure tone, cheap controller /
  cheap reviewer (they empirically failed the N=5 quality gates).