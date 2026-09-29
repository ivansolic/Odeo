---
artifact: docs-desktop-install-note
type: code
branch: docs/desktop-install-note
reviewed_commit: b599230
date: 2026-09-29
scorer: code-reviewer
model: claude-opus-5-5[1m] (Opus 5.5, 1M context)
model_tier: strong
effort: high
record_version: 2
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
verdict: APPROVE
previous_total: 11/12
---

## Scope reviewed

Round 2. This round reviewed the delta `git diff a77bf8a..b599230`: one README hunk,
README.md:60-64. Round 1 reviewed the whole branch (`main..a77bf8a`, README.md only)
against the raw official docs, fetched with curl and grepped:
- code.claude.com/docs/en/desktop.md, lines 407-409 and 431-439
- code.claude.com/docs/en/discover-plugins.md, lines 90-108 (Desktop app tab), 149, 185
- code.claude.com/docs/en/plugins-reference.md, line 579 (`bin/` row)
- claude.com/docs/plugins/org-sync.md, lines 107-111

Deterministic: `bin/docs-claims-check.sh` exit 0 at b599230. `bin/skills-lint.sh` exit 0 at
a77bf8a. The delta does not touch skills, so skills-lint was not re-run.

## Round-2 verification
- The round-1 Important (README.md:61-63, the unqualified claim that plugins are shared) is
  closed. The text now says to pick "your user account" as the scope. The Desktop app tab
  step "Choose a scope" uses the same label: "your user account, this project, or
  local-only". The README now limits sharing to "At user scope the terminal and the desktop
  app's local sessions share it". This matches discover-plugins.md:149: the terminal and the
  desktop app's local sessions read the same settings files, so "a plugin you install at
  user scope in any of them is available in the other two".
- The parenthetical "a project or local-only scope stays in that one folder" matches the
  scope definitions at discover-plugins.md:141-143. Project scope goes in that repository's
  `.claude/settings.json`, and local scope in its `.claude/settings.local.json`, so both
  apply only to that repository.
- The step order stays followable: marketplace in a terminal, then + → Plugins →
  Add plugin → odeo, then the scope.
- The human-verified fact (odeo loads in the desktop Code tab) is kept and not contradicted.

## Findings
None open.

## Checked and consistent with the docs (carried from round 1, text unchanged)
- Customize syncs through claude.ai, and Cowork reads from it: desktop.md:407.
- claude.ai and Cowork do not install a plugin with a top-level `bin/`:
  plugins-reference.md:579, org-sync.md:109.
- Odeo's guards are in bin/: hooks/hooks.json:72 and :83.
- The docs do not show the label "Add marketplace" under Customize → Plugins (they name
  only "Customize > Plugins", org-sync.md:9). I cannot verify it from the docs, and it is
  not a finding.

## History
- v1 (a77bf8a): REQUEST CHANGES, 11/12. One Important: the claim that the terminal and
  the desktop app share plugins left out the user-scope and local-session conditions, and
  the steps left out the scope choice.
- v2 (b599230): APPROVE, 12/12. The fix uses the suggested wording and matches the docs.

## Regression
Better than v1: correctness went from 1 to 2, total from 11/12 to 12/12.
