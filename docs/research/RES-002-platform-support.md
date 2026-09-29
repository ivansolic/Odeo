---
id: RES-002
title: Platform support for Odeo beyond Claude Code
mode: deep-dive
depth: thorough
date: 2026-09-29
sources: official vendor docs only, read raw and grepped; second source = vendor source code, binary or changelog
---

# RES-002: Where can Odeo run besides Claude Code?

## Question

For OpenAI Codex (CLI and the ChatGPT desktop app), Google Antigravity, claude.ai chat and
Claude Cowork: is there a plugin format, are SKILL.md skills, subagents with their own tools,
and lifecycle hooks that inject context supported, can a plugin ship executables on PATH, how
do updates reach users, and what would Odeo lose. Which platform should be ported first?

## Answer

Codex is the closest target: it reads Odeo's existing `.claude-plugin/` manifests, loads its
skills and hooks, and injects SessionStart and SubagentStart context, but it cannot ship
Odeo's subagents from a plugin and hides plugin hooks until the user trusts them. Cowork runs
nearly all of Odeo once `bin/` is renamed; Antigravity has no session-start hook, so the
baseline would have to become rules. None of the four puts a plugin's `bin/` on PATH, so
moving `bin/` to `scripts/` and calling scripts by path is a prerequisite shared by every port.

## Findings

Legend: **Y** supported · **P** partial or reworked · **N** not supported · **?** unverified.
Sources per cell are in the notes below the table; "2" = two independent official sources.

| Capability Odeo uses | Claude Code (today) | Codex CLI / ChatGPT app | Antigravity | Cowork | claude.ai chat |
|---|---|---|---|---|---|
| Plugin manifest + install from GitHub | Y | **Y, reads `.claude-plugin/*` directly** (2) | Y, own `plugin.json` (name + description only); GitHub URL install works (2: changelog + binary) | Y, Customize → Add marketplace (2) | Y, same path as Cowork (2) |
| Top-level `bin/` in the plugin | Y, on PATH | P, allowed, **not on PATH**, symlinks skipped (2) | P, not on PATH (absence confirmed) | **N, plugin refused** (4) | **N, plugin refused** (4) |
| SKILL.md skills | Y | Y, `plugin:skill`, list capped at 8,000 chars / 2% of context (2) | Y, open standard (2) | Y (2) | Y (2); upload may reject non-standard frontmatter (?) |
| Subagents with own tool lists | Y | **N from a plugin**; standalone TOML, no tool list, sandbox only (2) | Y, `agents/*.md`, own tool names (2) | Y (3); frontmatter fields honoured (?) | N, ignored (3) |
| Session-start context injection | Y, 10k/hook, split into parts | **Y**, SessionStart + SubagentStart, ~2,500 tokens/hook default, raisable (2) | **N**, no SessionStart; use `rules/` (24 KB/file, 20k-token budget) or PreInvocation (2) | Hooks load (3); specific events (?) | N, hooks ignored (3) |
| Edit guard (PreToolUse) | Y | P, sees the `apply_patch` text, not a file path (2) | P, own tool names, can gate not inject (2) | ? | N |
| Stop hook | Y | P, JSON only (2) | P, `decision: continue` (2) | ? | N |
| Plugin hooks run without a prompt | Y | **N, skipped until the user trusts them** in `/hooks` (2) | Y (2) | N, user confirms first (1) | n/a |
| userConfig dialog (language) | Y | N (2) | N (schema forbids) (2) | N (2) | N (2) |
| Reads AGENTS.md / CLAUDE.md | CLAUDE.md | AGENTS.md, 32 KiB (2) | AGENTS.md / GEMINI.md, not CLAUDE.md (2) | as Claude Code (?) | n/a |
| Updates | version bump | version bump; Git marketplaces auto-upgrade at start (1) | marketplace auto-update; GitHub installs need reinstall (2) | automatic, "Check for updates" (2) | as Cowork |
| Git guards in the user's repo | Y | Y (local CLI) | Y (local CLI) | ? (VM) | N |

Notes, verbatim anchors (full quotes and URLs are in the three agent reports behind this file):
- Codex manifests: "a legacy-compatible marketplace at `$REPO_ROOT/.claude-plugin/marketplace.json`"
  (developers.openai.com/plugins/build/plugins) and source `DISCOVERABLE_PLUGIN_MANIFEST_PATHS`
  including `.claude-plugin/plugin.json` (github.com/openai/codex, commit c248f6d).
- Codex hooks: "Codex skips plugin-bundled hooks until you review and trust the current hook
  definition"; "By default, Codex limits each model-visible hook-output message to roughly
  2,500 tokens" (developers.openai.com/codex/hooks) and `DEFAULT_HOOK_OUTPUT_TOKEN_LIMIT = 2_500`.
- Codex agents: "Convert reusable behavior to skills… move reusable agent procedures into
  skills" (developers.openai.com/plugins/guides/submit-claude-plugin, OpenAI's official guide
  for porting Claude Code plugins).
- `bin/` refused on claude.ai and Cowork: "A top-level `bin/` directory stops claude.ai and
  Cowork from installing the plugin at all" (claude.com/docs/plugins/build) and the
  plugins-reference `bin/` row; fix documented as `scripts/` + `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`
  (claude.com/docs/plugins/org-sync).
- Antigravity hooks: events PreToolUse, PostToolUse, PreInvocation, PostInvocation, Stop;
  SessionStart 0 hits, PreToolUse 9 (antigravity.google/docs/hooks); rules limits "24 KB
  (24,000 bytes) per-file limit" and "20,000-token aggregate rules budget"
  (antigravity.google/docs/rules).

## Numbers

- Odeo's baseline: ~19k characters, about 4.75k tokens (measured locally, 3 parts today).
  Codex default 2,500 tokens per hook: needs 2 parts or `additionalContextLimit`. Antigravity
  rules: fits one 24 KB file but shares a 20k-token budget with all rules.
- Odeo ships 67 skills. Codex lists skills in at most 8,000 characters (or 2% of context), so
  descriptions will be shortened and some skills dropped from implicit matching.
- `bin/` holds 26 programs, called by bare name from skills, agents and hooks; `resolve-language`
  alone appears in 8 files, `privacy-scan` in 6.

## Unverified

- Cowork: whether SessionStart and SubagentStart fire and inject context, whether agent
  frontmatter (`tools`, `model`, `effort`, `isolation`) is honoured, and whether git hooks can
  be installed into the user's repos from the Cowork VM.
- claude.ai: whether a plugin upload rejects skill frontmatter outside the Agent Skills spec
  (`disable-model-invocation` is in 53 of 67 skills). Documented for skill uploads only.
- Codex: order of concurrently launched SessionStart parts; whether an unmodified Odeo repo
  installs as-is through `codex plugin marketplace add ivansolic/Odeo`; the `$odeo:skill`
  mention syntax (source test only); auto-upgrade at startup (source only).
- Antigravity: `agy plugin import … claude` exists in the shipped binary (help text and
  `ClaudeCodeImporter`) but is undocumented; not run. Where CLI installs land (docs and
  changelog disagree). Skill namespace format (one changelog line).

## Implications for us

- **Shared first step for every port: move `bin/` to `scripts/` and call scripts by path.**
  It is required for Cowork and claude.ai and needed anyway for Codex and Antigravity. Claude
  Code loses only bare-name calls.
- **Port Codex first**, then Cowork. Codex already reads our manifests and has the two hooks
  the baseline needs; the real work is the subagent pipeline (no plugin-shipped agents, no tool
  lists) and the hook trust step users must take once. Cowork is nearly free after step one.
- **Antigravity is a larger rework** (baseline as rules, own tool names, own manifest), and
  **claude.ai chat can only carry the PM skills**; decide whether either is worth it after the
  Codex port. Test the undocumented `agy plugin import` first: it could shorten Antigravity.

## Sources (accessed 2026-09-29)

OpenAI: developers.openai.com/codex/plugins, /plugins/build/plugins, /codex/skills,
/codex/hooks, /codex/subagents, /codex/guides/agents-md, /codex/config-reference,
/plugins/guides/submit-claude-plugin, /codex/import (several redirect to learn.chatgpt.com);
github.com/openai/codex at c248f6d; Codex CLI 0.158.0 (released 2026-09-28).
Google: antigravity.google/docs/plugins, /cli/features, /changelog, /marketplace, /skills,
/subagents, /hooks, /sidecars, /rules, /cli/gcli-migration; google-gemini/gemini-cli docs;
the local `agy` 1.1.5 binary (help text and strings only).
Anthropic: claude.com/docs/plugins/platform-support, /overview, /build, /org-sync,
/org-rollout, /admin, /cowork/guide/plugins, /cowork/overview, /cowork/changelog,
/skills/overview, /skills/how-to; code.claude.com/docs/en/plugins-reference,
/plugins/components, /plugins/loading, /skills, /discover-plugins, /desktop;
support.claude.com/en/articles/12111783.
