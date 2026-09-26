---
module: Claude Code plugin hooks (hooks/hooks.json, hooks/odeo-context.sh)
tags: [claude-code, hooks, sessionstart, subagentstart, additionalcontext, limit, 10000, plugin]
problem_type: pattern
provenance: plugin install 0.2.0 (baseline delivery), verified end to end in a real session
reuse_count: 0
created: 2026-09-26
---

# A hook's context is capped at 10,000 characters: split, don't trim

## Context
Delivering a baseline (an 18.6k-char CLAUDE.md) through a SessionStart hook. The official
hooks docs (code.claude.com/docs/en/hooks.md, read raw) say additionalContext and plain
stdout are "capped at 10,000 characters"; over it, Claude gets a file path plus a 2,000-char
preview and is NOT asked to read the rest. The cap is measured PER HOOK, and when several
hooks answer the same event "Claude receives all of the values".

## Guidance
- Register one hook command per part (`baseline 1`, `baseline 2`, ...) and split at section
  boundaries; a section over budget splits at line boundaries. Budget ~9,200 content chars
  so header + margin stays under 9,500.
- Register a spare part slot, and test that hooks.json registers every part the file needs.
- Test the OUTCOME: parts rejoin byte-exact to the source, and no part exceeds the budget.
- The same parts go to SubagentStart: subagents do not see the main session's context.
- Parts arrive in parallel, so out of order; label each "part N of M".

## Why it matters
Trimming silently loses rules; one oversized hook silently becomes a 2k preview.

## When to apply
Any hook that injects more than a few thousand characters.
