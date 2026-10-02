---
id: RES-002
title: Platform support for Odeo beyond Claude Code
mode: deep-dive
depth: thorough
date: 2026-09-29
revised: 2026-10-02
sources: official vendor docs only, read raw and grepped; second source = vendor source code, binary or changelog
---

# RES-002: Where can Odeo run besides Claude Code?

## Question

For OpenAI Codex (CLI and the ChatGPT desktop app), Google Antigravity, claude.ai chat and
Claude Cowork: is there a plugin format, are SKILL.md skills, subagents with their own tools,
and lifecycle hooks that inject context supported, can a plugin ship executables on PATH, how
do updates reach users, and what would Odeo lose. Which platform should be ported first?

## Answer

Odeo can most likely run in Codex with the least rework: Codex reads Odeo's existing plugin
files (note 1) and was reported to have the two session-start hooks Odeo relies on (not yet
verified), but Odeo's review and build agents would likely have to be rebuilt as skills
(note 3, one source), and users must approve plugin hooks before they run, apparently again
whenever a hook changes (note 2). Cowork and claude.ai chat refuse any plugin with a top-level
`bin/` folder (note 4), so they cannot be tried until release B, the next minor release, which
deletes the old `bin/` wrappers; what else works in Cowork is largely unverified, and claude.ai
chat was reported to ignore hooks and agents (not verified), so it could carry at most the
planning (PM) skills. Antigravity's hook list has no session-start event (note 5, one source),
so Odeo's baseline would have to be rewritten as rules there.

## Findings

Legend: **Y** supported · **P** partial or reworked · **N** not supported · **?** unverified.
A **verified** cell cites a note below that quotes TWO independent sources (vendor docs plus
vendor source code, a binary or a changelog). A cell citing a note with only one source says
"one source"; it is evidence, not verification. A cell marked
**?** was reported by the 2026-09-29 research, but the agent reports that held its sources
were not kept (revision 2026-10-02), so its source cannot be named here: the reported value
is shown after "reported:", and it must be re-checked before anything relies on it. The
Claude Code column is Odeo's own platform, exercised by its test suite.

| Capability Odeo uses | Claude Code (today) | Codex CLI / ChatGPT app | Antigravity | Cowork | claude.ai chat |
|---|---|---|---|---|---|
| Plugin manifest + install from GitHub | Y | **Y, reads `.claude-plugin/*` directly** (note 1) | ? reported: own `plugin.json` (name + description only); GitHub URL install works, per changelog + binary | ? reported: Customize, Add marketplace | ? reported: same path as Cowork |
| Top-level `bin/` in the plugin | Y, on PATH | ? reported: allowed, not on PATH, symlinks skipped | ? inferred: not on PATH, because no doc mentions it (no positive source) | **N, plugin refused** (note 4) | **N, plugin refused** (note 4) |
| SKILL.md skills | Y | ? reported: yes, as `plugin:skill`, list capped at 8,000 chars or 2% of context | ? reported: yes, open standard | ? reported: yes | ? reported: yes; upload may reject non-standard frontmatter |
| Subagents with own tool lists | Y | ? inferred: not from a plugin (note 3, one source, porting advice); ? reported: standalone TOML agents, no tool list, sandbox only | ? reported: `agents/*.md`, own tool names | ? reported: yes; frontmatter fields unknown | ? reported: ignored |
| Session-start context injection | Y, 10k/hook, split into parts | ? reported: SessionStart + SubagentStart exist; **~2,500 tokens/hook default** (note 2) | **N, no SessionStart event** (note 5, one source); rules instead, 24 KB per file, 20k-token budget (note 5, one source) | ? reported: hooks load; which events fire unknown | ? reported: hooks ignored |
| Edit guard (PreToolUse) | Y | ? reported: partial, sees the `apply_patch` text, not a file path | P, the PreToolUse event exists (note 5, one source); ? reported: own tool names, can gate but not inject | ? | ? reported: no |
| Stop hook | Y | ? reported: partial, JSON only | P, the Stop event exists (note 5, one source); ? reported: `decision: continue` | ? | ? reported: no |
| Plugin hooks run without a prompt | Y | **N, skipped until the user trusts them** (note 2) | ? reported: yes | ? reported: no, user confirms first (one source only) | n/a |
| userConfig dialog (language) | Y | ? reported: no | ? reported: no (schema forbids) | ? reported: no | ? reported: no |
| Reads AGENTS.md / CLAUDE.md | CLAUDE.md | ? reported: AGENTS.md, 32 KiB limit | ? reported: AGENTS.md / GEMINI.md, not CLAUDE.md | ? reported: as Claude Code | n/a |
| Updates | version bump | ? reported: version bump; Git marketplaces auto-upgrade at start (source code only) | ? reported: marketplace auto-update; GitHub installs need reinstall | ? reported: automatic, "Check for updates" | ? reported: as Cowork |
| Git guards in the user's repo | Y | ? inferred: yes, it runs as a local CLI | ? inferred: yes, it runs as a local CLI | ? (runs in a VM) | ? inferred: no, no local repo |

Notes, verbatim anchors (the only sources this document can still name):
1. Codex manifests: "a legacy-compatible marketplace at `$REPO_ROOT/.claude-plugin/marketplace.json`"
   (developers.openai.com/plugins/build/plugins) and source `DISCOVERABLE_PLUGIN_MANIFEST_PATHS`
   including `.claude-plugin/plugin.json` (github.com/openai/codex, commit c248f6d).
2. Codex hooks: "Codex skips plugin-bundled hooks until you review and trust the current hook
   definition"; "By default, Codex limits each model-visible hook-output message to roughly
   2,500 tokens" (developers.openai.com/codex/hooks) and `DEFAULT_HOOK_OUTPUT_TOKEN_LIMIT = 2_500`
   (same repo and commit).
3. Codex agents, ONE source: "Convert reusable behavior to skills… move reusable agent
   procedures into skills" (developers.openai.com/plugins/guides/submit-claude-plugin, OpenAI's
   official guide for porting Claude Code plugins). It is advice, so "plugins cannot ship
   agents" is an inference from it, not a quote; the TOML details are not covered by it.
4. `bin/` refused on claude.ai and Cowork: "A top-level `bin/` directory stops claude.ai and
   Cowork from installing the plugin at all" (claude.com/docs/plugins/build) and the
   plugins-reference `bin/` row; fix documented as `scripts/` + `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`
   (claude.com/docs/plugins/org-sync).
5. Antigravity, ONE source per claim. Hooks: events PreToolUse, PostToolUse, PreInvocation, PostInvocation, Stop;
   SessionStart 0 hits, PreToolUse 9 (antigravity.google/docs/hooks); rules limits "24 KB
   (24,000 bytes) per-file limit" and "20,000-token aggregate rules budget"
   (antigravity.google/docs/rules).

## Numbers

Measured in this repo on 2026-09-29 unless a commit is named.
- Odeo's baseline: ~19k characters (measured), about 4.75k tokens (heuristic: characters
  divided by four, not a tokenizer count), delivered in 3 parts. Against Codex's ~2,500 tokens
  per hook (note 2) that means at least 2 parts; a setting to raise the limit was reported as
  `additionalContextLimit` (? unverified, no source kept). Antigravity rules: fits one 24 KB
  file but shares the 20k-token budget with all rules (note 5).
- Odeo ships 67 skills (re-counted at a278bd0). The reported 8,000-character Codex skill-list
  cap (?) would shorten descriptions and drop some skills from implicit matching.
- On 2026-09-29, `bin/` held the 26 programs, called by bare name; `resolve-language` appeared in
  8 files, `privacy-scan` in 6. Since 0.3.0 (published 2026-09-29) the programs live in
  `scripts/` and are called by path; `bin/` holds only 26 forwarding wrappers for old installs,
  and release B removes them.

## Unverified

Every **?** cell in the table, plus:
- Cowork: whether SessionStart and SubagentStart fire and inject context; whether PreToolUse
  and Stop hooks run; whether agent frontmatter (`tools`, `model`, `effort`, `isolation`) is
  honoured; whether git hooks can be installed into the user's repos from the Cowork VM; the
  "user confirms plugin hooks first" claim rests on one source.
- Antigravity: "`bin/` not on PATH" is an inference from absence in the docs, not a confirmed
  fact. `agy plugin import … claude` exists in the shipped binary (help text and
  `ClaudeCodeImporter`) but is undocumented; not run. Where CLI installs land: the docs and the
  changelog were found to disagree, but the two values were not kept, so this is open. Skill
  namespace format: one changelog line.
- claude.ai: whether a plugin upload rejects skill frontmatter outside the Agent Skills spec
  (`disable-model-invocation` is in 53 of 67 skills); documented for skill uploads only.
- Codex: order of concurrently launched SessionStart parts; whether an unmodified Odeo repo
  installs as-is through `codex plugin marketplace add ivansolic/Odeo`; the `$odeo:skill`
  mention syntax (source test only); auto-upgrade at startup (source only).
- Git guard cells for Codex, Antigravity and claude.ai are inferences from how each product
  runs (local CLI or not), not documented facts.

## Implications for us

- **Done: move `bin/` to `scripts/` and call scripts by path.** Shipped in 0.3.0 (2026-09-29).
  Cowork and claude.ai still refuse Odeo until release B deletes the `bin/` wrappers, so the
  Cowork install test belongs to release B.
- **Port Codex first, then Cowork.** Codex is the only target where the parts Odeo depends on
  most are verified: it reads our manifests (note 1) and its hook output limit and trust step
  are documented (note 2). Cowork cannot be tried before release B, and most of what it would
  run is unverified. The real Codex work is likely the subagent pipeline (no plugin-shipped
  agents, inferred from note 3) and the hook trust step for users, which note 2 ties to "the
  current hook definition", so it probably repeats whenever a release changes the hooks.
  Re-check every **?** Codex cell in the spike before the PRD.
- **Antigravity is a larger rework** (baseline as rules, note 5, one source, plus reported own tool names
  and own manifest), and **claude.ai chat can carry the PM skills at most**; decide whether
  either is worth it after the Codex port. Test the undocumented `agy plugin import` first: it
  could shorten Antigravity.

## Sources (accessed 2026-09-29)

These pages were read for the original research. Only the notes above keep quotes from them;
which page supported which **?** cell was not kept. Where a page redirected, which ones did was
not kept either.
OpenAI: developers.openai.com/codex/plugins, /plugins/build/plugins, /codex/skills,
/codex/hooks, /codex/subagents, /codex/guides/agents-md, /codex/config-reference,
/plugins/guides/submit-claude-plugin, /codex/import (several redirect to learn.chatgpt.com);
github.com/openai/codex at c248f6d; Codex CLI 0.158.0 (released 2026-09-28).
Google: antigravity.google/docs/plugins, /cli/features, /changelog, /marketplace, /skills,
/subagents, /hooks, /sidecars, /rules, /cli/gcli-migration; google-gemini/gemini-cli docs (path
not kept); the local `agy` 1.1.5 binary (help text and strings only).
Anthropic: claude.com/docs/plugins/platform-support, /overview, /build, /org-sync,
/org-rollout, /admin, /cowork/guide/plugins, /cowork/overview, /cowork/changelog,
/skills/overview, /skills/how-to; code.claude.com/docs/en/plugins-reference,
/plugins/components, /plugins/loading, /skills, /discover-plugins, /desktop;
support.claude.com/en/articles/12111783.

## Revision 2026-10-02

Round 2 (12/14) found the same pattern once more: two Answer claims stated as fact rested on
**?** cells, and the legend called one quoted source "verified". Now: verified means two
independent sources, notes 3 and 5 are labelled one source, the Codex agents cell is an
inference, the Answer and Implications cite or hedge every factual clause, the hook trust
step is no longer called one-time, and release B is explained.

Round 1:

The pm-reviewer scored version 1 at 9/14 (docs/evals/RES-002.md): about nine cells cited a
source count without naming the sources, which lived in three agent reports that were not kept.
Rather than restate them from memory, those cells are now marked **?** with the reported value
shown. Also corrected: "Cowork runs nearly all of Odeo" and "nearly free" (unsupported by the
table), the `bin/` status after 0.3.0, the reason for Codex first, the token figure labelled as
a heuristic, and claude.ai chat added to the Answer.
