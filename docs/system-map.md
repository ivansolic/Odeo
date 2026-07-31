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
| `/focus` | Fence this session's edits to one directory (`/focus <dir>`); a PreToolUse hook refuses edits elsewhere until `/focus off`. A focus aid under the permanent DO-NOT-TOUCH boundaries. |
| `/language` | Show or change the language generated documents are written in: `/language` reports the current language and where it is set, `/language de` sets this project, `/language de --global` sets your default for all projects (en, de, hr, fr). |

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
| `/deploy` | Ship a merged change to the platform in CLAUDE.md: re-check green, rollback ready, deploy, live smoke test, record it. PRODUCTION is your explicit go; staging may be offered. Makes "shipped" true before /outcome. |
| `/sync-docs` | Reconcile what the code does against what the docs claim (README/docs/CLAUDE.md), then sync or name the gap, your approval. Offered by /merge when a diff touched documented behavior. |
| `/research` | Cited market/web research: every claim 2+ independent sources or labeled unverified; TAM/SAM/SOM as ranges with methods. Saves docs/research/RES-NNN. Offered by /discover and /prd; standalone anytime. |
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
| `/improve` | on repeated eval drops | Improve a skill/rubric/knowledge entry with evidence (A/B test, keep or revert). Also has a calibrate mode: measure a reviewer against planted-defect scenarios (docs/checklists/review-calibration.md) without changing it. |
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
| `agent-reviewer` | Agent definitions (`agents/*.md`) vs the agent rubric: frontmatter, tool least-privilege, role boundary, policy/effort conformance. |
| `codebase-analyst` | Maps an existing codebase (read-only). |
Plus deterministic scorers (tests, `privacy-scan.sh`, and the gates below) and the human as the final gate.

## Deterministic gates (in `bin/`, run directly; exit 0 = clean, exit 1 = violation, exit 2 = usage error)
| Script | What it does |
|---|---|
| `coverage-check.sh` | PRD requirement coverage: every R<n> in a PRD must be claimed by a story `covers:` field. Standalone, invoked by `/build`. |
| `spec-gate.sh` | Spec entry gate: artifact must be committed, covered by a passing eval record newer than the last commit, and reviewed on the strong tier. Invoked by `/build`. |
| `merge-gate.sh` | Merge entry gate: not on main, clean working tree, a review record exists for the branch, boundary check passes. Invoked by `/merge`. |
| `language-guard.sh` | No-leak gate for machine surfaces: checks that frontmatter field names and enum values, filenames, directory names, branch names, and commit type/scope are ASCII and allowlist-conforming, so enabling a non-English output language cannot corrupt project mechanics. Standalone, explicitly invoked; exit 0/1/2. |
| `publish-guard.sh` | Publish leak gate. Refuses internal artifacts (denylist `docs/internal-paths.txt`) and, with `--require-allowlist`, any path not on the KEEP-PUBLIC allowlist `docs/public-paths.txt` (fail-closed: an unclassified committed path blocks the publish until a human classifies it). Privacy is advisory (exit 3, human reviews); denylist/allowlist are hard (exit 1). Reads paths NUL-delimited. Also runs inside the pre-push hook as the public-remote backstop. |

## Utility scripts (in `bin/`, run directly)
| Script | What it does |
|---|---|
| `token-report.py` | Per-agent token (and optional cost) breakdown of a session transcript, so build economics are measured, not guessed. Prices passed as args, never hardcoded. |
| `publish-snapshot.sh` | The only sanctioned publish path: materializes tracked HEAD (`git archive`, no history), strips the denylist, verifies with `publish-guard --require-allowlist` (fail-closed), and emits a clean snapshot dir. The pre-push hook (contract A) refuses every other push to the public remote (`CLAUDE_PUBLIC_REMOTE`, default `origin`) unless `CLAUDE_PUBLISH_SNAPSHOT=1`, which only this script sets after the human confirms any advisory privacy findings. |

## Second opinion (paid cross-model review, human-invoked only)
An external vendor model reviews one artifact; OUR matching reviewer compares the
two reads (overlap / only-ours / only-vendor + recommendation). It informs; it
never gates. Data leaves the machine and costs money, so a human starts every send.

| Command | Target -> our reviewer | What it does |
|---|---|---|
| `/second-opinion-code` | code -> `code-reviewer` | Independent read of a code diff. |
| `/second-opinion-pm` | pm -> `pm-reviewer` | Independent read of a PM document (PRD, stories, strategy, roadmap, research, discovery). |
| `/second-opinion-plan` | plan -> `architecture-reviewer` | Independent read of an implementation plan (the orchestrator writes the comparison, since architecture-reviewer writes no record). |
| `/second-opinion-design` | design -> `design-reviewer` | Independent read of UI (look + code), via a multimodal vendor. |

All four share `bin/second-opinion.sh` and `docs/second-opinion-protocol.md`; the
vendor is always an argument, never a command name (lint C10).

## Key decision points (the /guide decision trees)
- Idea fuzzy vs concrete: fuzzy -> `/discover`; concrete enough to touch -> `/prototype`.
- One feature vs many epics: one -> `/spec` directly; many/new product -> `/plan` first (product-level foundation before features).
- Build mode (always asked, never inferred): clear + independent -> **for me** (agents); fuzzy / want to steer -> **with me** (live). "Mode A/B" work as aliases.
- Parallel or not: independent stories only; check with `/worktree-parallel-check`.
- Dev rigor: new project -> TDD-lite; existing codebase with few tests -> Test-after (set in `/setup-project`).
- Share a prototype: quick + no account -> tunnel (machine stays on); days + stakeholders -> preview deploy.
