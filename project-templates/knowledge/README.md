# Knowledge (compound)

Reusable solved problems for this project. The compounding idea: the first time
you solve something hard it costs research; every next time it is a quick lookup
here. **Consulted before non-trivial work; captured with `/compound`; maintained
with `/compound-refresh`.**

Starts empty on purpose. Only **verified, non-trivial, reusable** solutions go in
(quality gate in `/compound`), so the base stays trustworthy.

## Layout
```
knowledge/
└── [category]/        e.g. auth/, payments/, data/, ui/
    └── [slug].md      one solved problem per file
```

## Entry format
YAML frontmatter for search, then a body by track.

```yaml
---
module: [area of the codebase]
tags: [searchable, keywords]
problem_type: [bug | pattern | decision]
provenance: [story/PR/incident it came from]
reuse_count: 0
created: [YYYY-MM-DD]
---
```

- **Bug track:** Problem · Symptoms · What didn't work · Solution (minimal before/after) · Why it works · Prevention.
- **Knowledge track:** Context · Guidance · Why it matters · When to apply · Examples.

## How it is used
- **Read (automatic):** before non-trivial work, Claude searches `knowledge/` and reuses a documented solution (rule lives in `CLAUDE.md`).
- **Write (you):** `/compound` after a verified non-trivial solution.
- **Maintain:** `/compound-refresh` audits entries against the current code and Keeps / Updates / Consolidates / Replaces / Deletes them.
- **Outcome-judged:** `/pulse` can promote or demote entries based on how a shipped solution actually performed in production.

`reuse_count` and `provenance` make reuse measurable and entries auditable.
