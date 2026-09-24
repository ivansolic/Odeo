---
description: Reconcile what the shipped code actually does against what the docs claim (README, docs/, CLAUDE.md, release notes), then sync the docs or name the gap, always with your approval. Explicit command; run it after a change altered behavior the docs describe, or before a release or pitch when the docs must be trustworthy. Offered by /odeo:merge when a merged diff touched documented behavior. Example: "/odeo:sync-docs" after shipping a change to the export format.
disable-model-invocation: true
---

# Sync docs (docs-drift reconciler)

Compare what the code now DOES against what the docs SAY, then either sync the doc
to reality or name the gap for you to decide. It never edits docs without your
approval and never claims behavior it did not verify in the code.

## When to use (and when not)
- After a change altered behavior the docs describe (a flag, an endpoint, a
  default, a supported format), or before a release or pitch when the docs must
  be trustworthy.
- Offered by `/odeo:merge` when the merged diff touched documented behavior; otherwise
  human-invoked. Never after a decline.
- Not for: pure internal refactors that changed no described behavior; or writing
  NEW docs from scratch (that is authoring, not reconciliation).

## Process
1. **Scope the change**: the diff to reconcile (a branch's `git diff main...`, a
   merge, or a named area). Name what behavior changed.
2. **List the docs that describe that behavior**: README.md, `docs/` (guides, and
   PRDs/stories where user-facing), CLAUDE.md (commands, conventions), and any
   release-facing notes. Read what each currently CLAIMS.
3. **Compare, claim by claim**: for each doc statement about the changed area,
   does the code still do that? Mark each MATCHES / STALE (doc wrong) / MISSING
   (new behavior undocumented) / ASPIRATIONAL (doc describes intent the code does
   not yet meet). Verify every claim against the code, never guess.
4. **Draft the fix per gap**: STALE gives the corrected sentence; MISSING gives
   the line to add; ASPIRATIONAL you NAME (do not quietly rewrite a doc to match
   half-built code, that is a decision for the human, not a sync).
5. **Your gate**: show the drafted doc edits as a diff plus the named gaps; apply
   only what you approve. Nothing is written silently.
6. **Offer `/odeo:release-notes`** when user-facing behavior changed and a release is near.

## Worked example
"/odeo:sync-docs" after a change that added Excel export alongside CSV.
- Scope: the export module diff.
- Docs: README "Exports" section claims "export to CSV".
- Compare: README is STALE (the code now exports CSV and Excel); the CLI
  `--format` help is MISSING the `xlsx` value.
- Draft: README -> "export to CSV or Excel (.xlsx)"; help text -> add `xlsx`.
- Your gate: you approve the README edit and defer the help text; only the README
  edit is applied. The deferred item is listed so it is not lost.

## Output
- Approved doc edits applied in place (a normal reviewable diff), plus a short
  list of any gaps you chose to leave (named, not lost).

## Rules
- Verify every claim against the actual code; never document behavior you did not
  confirm. Never edit a doc without your approval (draft-first, per the guardrails).
- Reconcile, do not invent: an ASPIRATIONAL doc is a decision to surface, not a
  thing to silently rewrite to match incomplete code.
