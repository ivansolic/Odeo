# System map

The single source of truth for what exists in this system: every command, agent,
and loop, organized by lifecycle phase. `/odeo:guide` and `/odeo:start` consult this map;
the authoring standard requires updating it whenever a command is added or renamed.

## The lifecycle (the order things happen)
```
1 SETUP -> 2 DISCOVER -> 3 STRATEGY -> 4 PLAN -> 5 SPEC -> 6 BUILD -> 7 MEASURE -> 8 LAUNCH
                                  (9 KNOWLEDGE loops run throughout; 10 ORCHESTRATORS chain phases)

New product:          /odeo:discover -> strategy skills -> /odeo:plan -> /odeo:spec per epic -> /odeo:build -> /odeo:merge -> /odeo:outcome -> /odeo:go-to-market
Incremental feature:  /odeo:spec -> /odeo:build -> /odeo:merge -> /odeo:outcome
Trivial fix:          just build it (branch, fix, review, /odeo:merge)
Build-to-learn:       /odeo:prototype -> findings -> promote at the right phase (by scope)
```

## 1. Setup & onboarding
| Command | What it does |
|---|---|
| `/odeo:new-project` | Create a new project folder from the plugin's templates (CLAUDE.md, docs, tasks, knowledge, design for UI), git on main, guards installed. Then open it and run /odeo:setup-project. |
| `/odeo:setup-project` | Configure a project: new (interview/preset) or existing (maps the codebase); sets dev-rigor style and preferences. Once per project. |
| `/odeo:setup-design` | Design system setup: tokens as the styling source of truth (UI projects). |
| `/odeo:start` | You-are-here: reads project state, tells you the next step + pending loop reminders. |
| `/odeo:focus` | Fence this session's edits to one directory (`/odeo:focus <dir>`); a PreToolUse hook refuses edits elsewhere until `/odeo:focus off`. A focus aid under the permanent DO-NOT-TOUCH boundaries. |
| `/odeo:language` | Show or change the language generated documents are written in: `/odeo:language` reports the current language and where it is set, `/odeo:language de` sets this project, `/odeo:language de --global` sets your default for all projects (en, de, hr, fr). |

## 2. Discovery & research
| Command | What it does |
|---|---|
| `/odeo:brainstorm` | Diverge on a problem/idea: 7-10 distinct options before converging. |
| `/odeo:personas` | Jobs-to-be-Done personas: the job, current alternative, pains, gains. |
| `/odeo:interview-synthesis` | Raw interviews/feedback into themed opportunities (not a feature wishlist). |
| `/odeo:competitor-analysis` | The landscape + your wedge, including the status quo as a competitor. |
| `/odeo:market-segments` | Segments, beachhead, ICP, sober TAM/SAM/SOM. |
| `/odeo:opportunity-solution-tree` | Outcome -> opportunities -> solutions -> experiments (visual discovery). |
| `/odeo:customer-journey-map` | Stages, touchpoints, emotions, pains for one persona + scenario. |
| `/odeo:experiments` | Riskiest assumptions + the cheapest test for each (pass/fail defined upfront). |
| `/odeo:prototype` | Build-to-learn: N disposable working variants, compare live, keep the winner's learnings. |

## 3. Strategy & viability
| Command | What it does |
|---|---|
| `/odeo:vision` | The 2-5 year north star narrative. |
| `/odeo:strategy` | Focused bets + explicit non-goals, insight-driven. |
| `/odeo:value-proposition` | Jobs/pains/gains mapped to your pain-relievers and gain-creators. |
| `/odeo:okrs` | Set outcome-based OKRs; re-run over existing OKRs = check-in (actuals vs targets). |
| `/odeo:business-model` | Lean/Business Model Canvas, the viability one-pager. |
| `/odeo:pricing` | Value metric, model, tiers, willingness-to-pay. |

## 4. Planning (portfolio: WHICH epics, in what order)
| Command | What it does |
|---|---|
| `/odeo:prioritize` | RICE-ranked epics/opportunities with visible inputs. |
| `/odeo:roadmap` | Outcome-based now/next/later horizons (no fake dates). |
| `/odeo:stakeholder-map` | Power/interest grid + communication plan. |

## 5. Specification (feature level: define ONE thing)
| Command | What it does |
|---|---|
| `/odeo:prd` | Problem-first PRD with measurable outcome; security pre-mortem when sensitive. |
| `/odeo:critique` | Red-team + pre-mortem on a PRD/direction before committing. |
| `/odeo:stories` | INVEST stories with binary acceptance criteria, ordered by dependency. |

## 6. Build & integrate
| Command | What it does |
|---|---|
| `/odeo:build` | The build entry. **with me** (Mode A): you + Claude, live in your editor. **for me** (Mode B): architect plans -> architecture-reviewer checks -> you approve -> builders execute in worktrees -> reviewers -> your gate. |
| `/odeo:merge` | Rebase onto main, tests, merge PR, cleanup. Serialized; always your approval. |
| `/odeo:deploy` | Ship a merged change to the platform in CLAUDE.md: re-check green, rollback ready, deploy, live smoke test, record it. PRODUCTION is your explicit go; staging may be offered. Makes "shipped" true before /odeo:outcome. |
| `/odeo:sync-docs` | Reconcile what the code does against what the docs claim (README/docs/CLAUDE.md), then sync or name the gap, your approval. Offered by /odeo:merge when a diff touched documented behavior. |
| `/odeo:research` | Cited market/web research: every claim 2+ independent sources or labeled unverified; TAM/SAM/SOM as ranges with methods. Saves docs/research/RES-NNN. Offered by /odeo:discover and /odeo:prd; standalone anytime. |
| `/odeo:ci` | Generate `.github/workflows/checks.yml` from the project's own Commands, so every PR runs typecheck/lint/tests/build. Verify only, never deploy. Offered by /odeo:setup-project and /odeo:merge. |
| `/odeo:commit-push` | Conventional commit + secret scan + push safety checks. |
| `/odeo:optimize` | Grounded performance loop: measure -> one change -> re-measure -> keep only if faster. |
| `/odeo:worktree-parallel-check` | Read-only: what's safe to build next / in parallel, warns on overlap. |

Agents here: `architect` (plans, read-only), `builder` (executes the approved plan, own worktree), `debugger` (root-cause investigation). Auto-skills: `test-driven-development`, `ux-design`, `ux-writing`.

## 7. Metrics & analytics
| Command | What it does |
|---|---|
| `/odeo:metrics` | North Star + supporting + guardrail metrics, with sources. |
| `/odeo:ab-test` | Plan or read an A/B test honestly (sample size, significance, ship/stop). |
| `/odeo:cohorts` | Retention curves by cohort; does the tail flatten? |
| `/odeo:query` | Plain language to SQL, read-only by default. |

## 8. Launch & growth
| Command | What it does |
|---|---|
| `/odeo:positioning` | The context that makes your value obvious (alternatives, category, best-fit). |
| `/odeo:marketing` | Channels + campaigns for one segment, tested cheap before scaling. |
| `/odeo:gtm-plan` | The focused go-to-market plan artifact. |
| `/odeo:release-notes` | Benefit-first user-facing notes. |
| `/odeo:growth-loops` | Self-reinforcing growth cycles for the PRODUCT (a strategy doc, not a system loop). |
| `/odeo:battlecard` | Honest competitive battlecard per rival. |
| `/odeo:product-name` | Name brainstorming with ownability checks before you fall in love. |

## 9. Knowledge & learning (the system gets smarter)
| Command | Recurring | What it does |
|---|---|---|
| `/odeo:learn` | per story | Capture a verified, non-trivial, reusable solution into `knowledge/` (draft shown first). |
| `/odeo:retro` | per session | End-of-session lessons, routed to lessons.md / CLAUDE.md with your approval. Then runs `ledger-backup.sh`, which copies the gitignored ledger (`todo.md`, `lessons.md`) to the recorded `ledger_backup:` target outside the repo and reports the result by exit code. |
| `/odeo:outcome` | per shipped feature (~1 week after) | Did it actually solve the problem? Real data only; feeds /odeo:learn and suggests next steps. |
| `/odeo:knowledge-refresh` | every 2-4 weeks | Audit and prune the knowledge base against current code. |
| `/odeo:product-signal` | weekly | Gather user feedback -> themes -> compare vs last memo -> signal memo. |
| `/odeo:improve` | on repeated eval drops | Improve a skill/rubric/knowledge entry with evidence (A/B test, keep or revert). Also has a calibrate mode: measure a reviewer against planted-defect scenarios (docs/checklists/review-calibration.md) without changing it. |
| `/odeo:contribute-lesson` | opt-in | Share a sanitized lesson/rubric/eval learning with the community (privacy-scanned, your approval). |
| `/odeo:sync-community` | often | Pull the latest shared community knowledge (read-only). |

Recurring loops are reminded via nudges (max one, easy to decline); you always run them. No silent scheduling exists.

## 10. Orchestrators (chain the phases, a gate between every step)
| Command | Chains |
|---|---|
| `/odeo:discover` | brainstorm -> personas -> journey-map -> opportunity-tree -> experiments |
| `/odeo:plan` | prioritize -> roadmap |
| `/odeo:spec` | prd -> critique -> stories |
| `/odeo:go-to-market` | positioning -> marketing -> gtm-plan -> release-notes |

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
| `coverage-check.sh` | PRD requirement coverage: every R<n> in a PRD must be claimed by a story `covers:` field. Standalone, invoked by `/odeo:build`. |
| `spec-gate.sh` | Spec entry gate: artifact must be committed, covered by a passing eval record newer than the last commit, and reviewed on the strong tier. Invoked by `/odeo:build`. |
| `merge-gate.sh` | Merge entry gate: not on main, clean working tree, a review record exists for the branch, boundary check passes. Invoked by `/odeo:merge`. |
| `language-guard.sh` | No-leak gate for machine surfaces: checks that frontmatter field names and enum values, filenames, directory names, branch names, and commit type/scope are ASCII and allowlist-conforming, so enabling a non-English output language cannot corrupt project mechanics. Standalone, explicitly invoked; exit 0/1/2. |
| `publish-guard.sh` | Publish leak gate. Refuses internal artifacts (denylist `docs/internal-paths.txt`) and, with `--require-allowlist`, any path not on the KEEP-PUBLIC allowlist `docs/public-paths.txt` (fail-closed: an unclassified committed path blocks the publish until a human classifies it). Privacy is advisory (exit 3, human reviews); denylist/allowlist are hard (exit 1). Reads paths NUL-delimited. Also runs inside the pre-push hook as the public-remote backstop. |

## Utility scripts (in `bin/`, run directly)
| Script | What it does |
|---|---|
| `token-report.py` | Per-agent token (and optional cost) breakdown of a session transcript, so build economics are measured, not guessed. Prices passed as args, never hardcoded. |
| `ledger-backup.sh` | Backs up `.claude/tasks/todo.md` + `lessons.md`. They are gitignored so the ledger never reaches a published snapshot, which means nothing else carries them. Target is one `ledger_backup:` line in `CLAUDE.local.md` (read first, the right place for a private target) or `CLAUDE.md`: a git remote+branch, or a directory. Every failure has its own exit code (2 refused, 3 nothing was promised, 4 the target could not be used, 5 push refused, 6 nothing to back up), and the local stamp is written ONLY after a verified success, so `--check` still reports "behind" for a backup that silently stopped working. Three refusals carry the design: no target may sit inside **any** git repository (asked of the resolved landing directory on the `dir` arm and of a local remote's parent on the `git` arm, after three rounds of narrower guards each traded one failure shape for another); a local remote may not BE this repository, asked by git COMMON DIR, which is what refuses a linked worktree however the URL is spelled; and a git target may not be the project's publish remote (by name and by normalised URL). LOCATION is decided by repository MARKERS ON DISK, never by git's message: git says "not a git repository" both when there is none and when it cannot follow one, and reading that sentence put the ledger in a live work tree at exit 0. IDENTITY is the one question git itself is asked, because a shared object store is not visible on disk. Both read the URL through ONE shared conversion, after two conversions disagreed and pushed the ledger to the publish remote spelled as a `file://` URL; a relative remote URL is refused outright, since the directory this program would check is not the directory git writes to. The whole git environment is dropped at startup, both the variables that NAME a repository (`GIT_DIR`, `GIT_INDEX_FILE` and family) and the `GIT_CONFIG_*` ones that REWRITE it (a measured `insteadOf` redirection sent the ledger to an injected remote at exit 0), so a run from a hook answers about the project it was given and cannot corrupt the caller's index. Run by `/odeo:retro`; `--check` is what `session-end-check.sh` reads. |
| `publish-snapshot.sh` | The only sanctioned publish path: materializes tracked HEAD (`git archive`, no history), strips the denylist, verifies with `publish-guard --require-allowlist` (fail-closed), and emits a clean snapshot dir. The pre-push hook (contract A) refuses every other push to the public remote (`CLAUDE_PUBLIC_REMOTE`, default `origin`) unless `CLAUDE_PUBLISH_SNAPSHOT=1`, which only this script sets after the human confirms any advisory privacy findings. |

## Second opinion (paid cross-model review, human-invoked only)
An external vendor model reviews one artifact; OUR matching reviewer compares the
two reads (overlap / only-ours / only-vendor + recommendation). It informs; it
never gates. Data leaves the machine and costs money, so a human starts every send.

| Command | Target -> our reviewer | What it does |
|---|---|---|
| `/odeo:second-opinion-code` | code -> `code-reviewer` | Independent read of a code diff. |
| `/odeo:second-opinion-pm` | pm -> `pm-reviewer` | Independent read of a PM document (PRD, stories, strategy, roadmap, research, discovery). |
| `/odeo:second-opinion-plan` | plan -> `architecture-reviewer` | Independent read of an implementation plan (the orchestrator writes the comparison, since architecture-reviewer writes no record). |
| `/odeo:second-opinion-design` | design -> `design-reviewer` | Independent read of UI (look + code), via a multimodal vendor. |

All four share `bin/second-opinion.sh` and `docs/second-opinion-protocol.md`; the
vendor is always an argument, never a command name (lint C10).

## Key decision points (the /odeo:guide decision trees)
- Idea fuzzy vs concrete: fuzzy -> `/odeo:discover`; concrete enough to touch -> `/odeo:prototype`.
- One feature vs many epics: one -> `/odeo:spec` directly; many/new product -> `/odeo:plan` first (product-level foundation before features).
- Build mode (always asked, never inferred): clear + independent -> **for me** (agents); fuzzy / want to steer -> **with me** (live). "Mode A/B" work as aliases.
- Parallel or not: independent stories only; check with `/odeo:worktree-parallel-check`.
- Dev rigor: new project -> TDD-lite; existing codebase with few tests -> Test-after (set in `/odeo:setup-project`).
- Share a prototype: quick + no account -> tunnel (machine stays on); days + stakeholders -> preview deploy.
