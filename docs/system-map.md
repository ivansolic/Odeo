# System map

The single source of truth for what exists in this system: every command, agent,
and loop, organized by lifecycle phase. `/guide` and `/start` consult this map;
the authoring standard requires updating it whenever a command is added or renamed.

## The lifecycle (the order things happen)
```
1 SETUP -> 2 DISCOVER -> 3 STRATEGY -> 4 PLAN -> 5 SPEC -> 6 BUILD -> 7 MEASURE -> 8 LAUNCH
                                  (9 KNOWLEDGE loops run throughout; 10 ORCHESTRATORS chain phases)

New product:          /discover -> strategy skills -> /plan -> /spec per epic -> /build -> /merge -> /outcome -> /go-to-market
Incremental feature:  /spec -> /build -> /merge -> /outcome
Trivial fix:          just build it (branch, fix, review, /merge)
Build-to-learn:       /prototype -> findings -> promote at the right phase (by scope)
```

## 1. Setup & onboarding
| Command | What it does |
|---|---|
| `/setup-project` | Configure a project: new (interview/preset) or existing (maps the codebase); sets dev-rigor style and preferences. Once per project. |
| `/setup-design` | Design system setup: tokens as the styling source of truth (UI projects). |
| `/start` | You-are-here: reads project state, tells you the next step + pending loop reminders. |

## 2. Discovery & research
| Command | What it does |
|---|---|
| `/brainstorm` | Diverge on a problem/idea: 7-10 distinct options before converging. |
| `/personas` | Jobs-to-be-Done personas: the job, current alternative, pains, gains. |
| `/interview-synthesis` | Raw interviews/feedback into themed opportunities (not a feature wishlist). |
| `/competitor-analysis` | The landscape + your wedge, including the status quo as a competitor. |
| `/market-segments` | Segments, beachhead, ICP, sober TAM/SAM/SOM. |
| `/opportunity-solution-tree` | Outcome -> opportunities -> solutions -> experiments (visual discovery). |
| `/customer-journey-map` | Stages, touchpoints, emotions, pains for one persona + scenario. |
| `/experiments` | Riskiest assumptions + the cheapest test for each (pass/fail defined upfront). |
| `/prototype` | Build-to-learn: N disposable working variants, compare live, keep the winner's learnings. |

## 3. Strategy & viability
| Command | What it does |
|---|---|
| `/vision` | The 2-5 year north star narrative. |
| `/strategy` | Focused bets + explicit non-goals, insight-driven. |
| `/value-proposition` | Jobs/pains/gains mapped to your pain-relievers and gain-creators. |
| `/okrs` | Set outcome-based OKRs; re-run over existing OKRs = check-in (actuals vs targets). |
| `/business-model` | Lean/Business Model Canvas, the viability one-pager. |
| `/pricing` | Value metric, model, tiers, willingness-to-pay. |

## 4. Planning (portfolio: WHICH epics, in what order)
| Command | What it does |
|---|---|
| `/prioritize` | RICE-ranked epics/opportunities with visible inputs. |
| `/roadmap` | Outcome-based now/next/later horizons (no fake dates). |
| `/stakeholder-map` | Power/interest grid + communication plan. |

## 5. Specification (feature level: define ONE thing)
| Command | What it does |
|---|---|
| `/prd` | Problem-first PRD with measurable outcome; security pre-mortem when sensitive. |
| `/critique` | Red-team + pre-mortem on a PRD/direction before committing. |
| `/stories` | INVEST stories with binary acceptance criteria, ordered by dependency. |

## 6. Build & integrate
| Command | What it does |
|---|---|
| `/build` | The build entry. **with me** (Mode A): you + Claude, live in your editor. **for me** (Mode B): architect plans -> architecture-reviewer checks -> you approve -> builders execute in worktrees -> reviewers -> your gate. |
| `/merge` | Rebase onto main, tests, merge PR, cleanup. Serialized; always your approval. |
| `/ci` | Generate `.github/workflows/checks.yml` from the project's own Commands, so every PR runs typecheck/lint/tests/build. Verify only, never deploy. Offered by /setup-project and /merge. |
| `/commit-push` | Conventional commit + secret scan + push safety checks. |
| `/optimize` | Grounded performance loop: measure -> one change -> re-measure -> keep only if faster. |
| `/worktree-parallel-check` | Read-only: what's safe to build next / in parallel, warns on overlap. |

Agents here: `architect` (plans, read-only), `builder` (executes the approved plan, own worktree), `debugger` (root-cause investigation). Auto-skills: `test-driven-development`, `ux-design`, `ux-writing`.

## 7. Metrics & analytics
| Command | What it does |
|---|---|
| `/metrics` | North Star + supporting + guardrail metrics, with sources. |
| `/ab-test` | Plan or read an A/B test honestly (sample size, significance, ship/stop). |
| `/cohorts` | Retention curves by cohort; does the tail flatten? |
| `/query` | Plain language to SQL, read-only by default. |

## 8. Launch & growth
| Command | What it does |
|---|---|
| `/positioning` | The context that makes your value obvious (alternatives, category, best-fit). |
| `/marketing` | Channels + campaigns for one segment, tested cheap before scaling. |
| `/gtm-plan` | The focused go-to-market plan artifact. |
| `/release-notes` | Benefit-first user-facing notes. |
| `/growth-loops` | Self-reinforcing growth cycles for the PRODUCT (a strategy doc, not a system loop). |
| `/battlecard` | Honest competitive battlecard per rival. |
| `/product-name` | Name brainstorming with ownability checks before you fall in love. |

## 9. Knowledge & learning (the system gets smarter)
| Command | Recurring | What it does |
|---|---|---|
| `/learn` | per story | Capture a verified, non-trivial, reusable solution into `knowledge/` (draft shown first). |
| `/retro` | per session | End-of-session lessons, routed to lessons.md / CLAUDE.md with your approval. |
| `/outcome` | per shipped feature (~1 week after) | Did it actually solve the problem? Real data only; feeds /learn and suggests next steps. |
| `/knowledge-refresh` | every 2-4 weeks | Audit and prune the knowledge base against current code. |
| `/product-signal` | weekly | Gather user feedback -> themes -> compare vs last memo -> signal memo. |
| `/improve` | on repeated eval drops | Improve a skill/rubric/knowledge entry with evidence (A/B test, keep or revert). |
| `/contribute-lesson` | opt-in | Share a sanitized lesson/rubric/eval learning with the community (privacy-scanned, your approval). |
| `/sync-community` | often | Pull the latest shared community knowledge (read-only). |

Recurring loops are reminded via nudges (max one, easy to decline); you always run them. No silent scheduling exists.

## 10. Orchestrators (chain the phases, a gate between every step)
| Command | Chains |
|---|---|
| `/discover` | brainstorm -> personas -> journey-map -> opportunity-tree -> experiments |
| `/plan` | prioritize -> roadmap |
| `/spec` | prd -> critique -> stories |
| `/go-to-market` | positioning -> marketing -> gtm-plan -> release-notes |

## Reviewers (cross-cutting; each also invokable standalone as a consultant)
| Agent | Domain |
|---|---|
| `code-reviewer` | Code: bugs, security, performance; scores + eval record. |
| `design-reviewer` | UI: heuristics, states, a11y, tokens, microcopy; scores + record. |
| `architecture-reviewer` | Architecture decisions, module boundaries (read-only advice). |
| `pm-reviewer` | PM documents vs rubrics; eval records; blind scoring in A/B tests. |
| `skill-reviewer` | Skill files vs the authoring standard. |
| `codebase-analyst` | Maps an existing codebase (read-only). |
Plus deterministic scorers (tests, `privacy-scan.sh`) and the human as the final gate.

## Key decision points (the /guide decision trees)
- Idea fuzzy vs concrete: fuzzy -> `/discover`; concrete enough to touch -> `/prototype`.
- One feature vs many epics: one -> `/spec` directly; many/new product -> `/plan` first (product-level foundation before features).
- Build mode (always asked, never inferred): clear + independent -> **for me** (agents); fuzzy / want to steer -> **with me** (live). "Mode A/B" work as aliases.
- Parallel or not: independent stories only; check with `/worktree-parallel-check`.
- Dev rigor: new project -> TDD-lite; existing codebase with few tests -> Test-after (set in `/setup-project`).
- Share a prototype: quick + no account -> tunnel (machine stays on); days + stakeholders -> preview deploy.
