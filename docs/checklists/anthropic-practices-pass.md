# Anthropic guidance checklist pass, results (2026-07-07)

Systematic pass through Anthropic's public guidance relevant to this system, with
the have / missing / not-needed verdict per item and why. Sources: the official
skill-authoring best practices (docs.claude.com), the "Building Effective Agents"
engineering essay, and the "Claude Code Best Practices" engineering post. Written
in our own words; this records OUR compliance, it does not reproduce their text.

## Skill-authoring best practices
| Guidance | Verdict | Where / why |
|---|---|---|
| Conciseness, context window is a shared resource | HAVE | Standard sets size limits; largest skill 171 lines |
| Progressive disclosure (lean SKILL.md + reference files, one level deep) | HAVE | rubric.md beside SKILL.md; standard enforces one level |
| Descriptions optimized for discovery ("Use when...", triggers) | HAVE | All 4 auto-skills compliant (fixed in alignment pass) |
| Third-person, consistent terminology | HAVE | Standard rule; spot-checked |
| Pre-written scripts over agent-generated code for critical ops | HAVE | privacy-scan, secret-scan, boundary-check, merge-gate, install-git-guards |
| No time-sensitive info in skills | HAVE | Standard rule |
| Build evals before extensive docs | HAVE | Eval framework + rubrics shipped before the doc overhaul |
| Test across target models | MISSING (accepted) | Single-model usage today; revisit when the plugin ships to varied users |
| Iterative refinement with agents (one agent writes, another tests) | HAVE (designed) | /improve subagent A/B method; live pressure-runs land with dogfood |

## Building Effective Agents (patterns)
| Pattern | Verdict | Where |
|---|---|---|
| Workflows vs agents: prefer simple, composable steps | HAVE | Skills orchestrate; agents execute; orchestrators are thin chains with gates |
| Orchestrator-workers | HAVE | /build Mode B: architect plans, builders execute in parallel worktrees |
| Evaluator-optimizer loop | HAVE | reviewers + success-signal loop + /improve keep/revert |
| Routing | HAVE | /guide routes goals to the right command; domain reviewers by artifact type |
| Guardrails and human oversight for consequential actions | HAVE | AGENTS.md Guardrails, enforced mechanisms, human floor |
| Keep agent context minimal, pull on demand | HAVE | codebase-map, knowledge pulled on demand; isolated agent contexts |

## Claude Code Best Practices
| Practice | Verdict | Where |
|---|---|---|
| CLAUDE.md as tuned, living project config | HAVE | project CLAUDE.md + /setup-project (new and existing modes) |
| Explore -> plan -> code -> commit | HAVE | architect (explore+plan) -> gate -> builder (code+commit per task) |
| TDD with Claude | HAVE | dev-rigor styles; TDD/TDD-lite defaults |
| Use subagents for verification/independent work | HAVE | reviewer agents, builder isolation, blind scoring |
| Git worktrees for parallel sessions | HAVE | isolation: worktree, worktree-parallel-check, fleet docs |
| Course-correct early, iterate on plans | HAVE | plan gate, stop-and-ask contract discipline |
| Headless/automation | NOT NEEDED (by design) | No silent scheduling is a deliberate guardrail; cron stays opt-in |

## Summary
No blocking gaps. One accepted gap (multi-model testing) recorded with its
revisit condition. This document is updated whenever a new relevant guidance item
appears or a verdict changes.
