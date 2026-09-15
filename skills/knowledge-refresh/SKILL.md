---
description: Audit and refresh the knowledge/ base against the current codebase. Detects stale, misleading, or redundant entries and Keeps / Updates / Consolidates / Replaces / Deletes them, keeping documented solutions current and trustworthy. Run periodically.
disable-model-invocation: true
---

Keep `knowledge/` accurate as the code evolves. A stale knowledge base is worse
than none, so this audits every entry against the real codebase.

## Modes
- **Interactive**, ask on ambiguous cases (Update vs Replace vs Delete), confirm before writing.
- **Headless**, do the unambiguous actions, flag ambiguous ones as stale with reasoning, produce a report.
Ask which mode, default interactive.

## For each entry, check 5 drift dimensions vs current code
1. **References**, file paths, classes, modules: moved or renamed?
2. **Solution**, does the recommended fix still match how the code works now?
3. **Code examples**, do snippets reflect the current codebase?
4. **Related docs**, are cross-referenced entries still present and consistent?
5. **Vocabulary**, do domain terms still match the code?

## Classify into one outcome
| Outcome | When |
|---|---|
| **Keep** | Still accurate and useful |
| **Update** | Solution valid, references drifted, fix paths/links in place |
| **Consolidate** | Overlapping entries, both correct, merge into one canonical, delete redundant |
| **Replace** | Guidance now misleading, write a successor from current code evidence |
| **Delete** | Obsolete |

## Auto-delete only if ALL THREE hold
- The referenced implementation is gone, AND
- The problem domain the entry addresses no longer exists, AND
- No substantive inbound citations (only decorative links, if any).
If any condition fails, classify as Update / Replace / Consolidate / mark stale instead. (Git history preserves deletions.)

## Also
- Flag entries with `reuse_count: 0` that are old: candidates for review (maybe not useful).
- Resolve cross-entry conflicts (one says "use X", another "avoid X") via Update or Consolidate.

## Output
A markdown **report**: every entry, its classification, the evidence, and the action taken (or recommended if a write failed). Then commit the approved changes (respect the ask-before-push rule).

## Safety rules
- Never delete unless all three conditions hold.
- Ambiguous cases: ask (interactive) or mark stale for human review (headless); never guess a delete.
