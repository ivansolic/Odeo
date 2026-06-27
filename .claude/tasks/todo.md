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

## Review
(to fill in after)
