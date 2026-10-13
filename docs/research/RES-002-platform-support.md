---
id: RES-002
title: Platform support for Odeo beyond Claude Code
mode: deep-dive
depth: thorough
date: 2026-09-29
revised: 2026-10-13
sources: official vendor docs read raw and grepped; second source = vendor source code, shipped binary or changelog
---

# RES-002: Where can Odeo run besides Claude Code?

## Question

As of 2026-10-13 (sources re-read that day; Codex source at commit `90f00bd`, the local
Antigravity CLI binary `agy` 1.1.5, Odeo at commit `4f0084e`), for OpenAI Codex (CLI and the
ChatGPT desktop app), Google Antigravity, claude.ai chat and Claude Cowork:

1. Is there a plugin format, and can it install from GitHub?
2. Are SKILL.md skills supported?
3. Are subagents with their own tool lists supported?
4. Are lifecycle hooks that inject context at session start supported, and do they run
   without a user prompt?
5. Can a plugin ship executables (Odeo's top-level `bin/`)?
6. How do plugin updates reach users?
7. What would Odeo lose there, and which platform should be ported first?

The decision it serves: which platform the next porting spike targets (Phase 2 in the task
ledger). Scope: desktop and CLI products only, no region or segment limit (all targets are
global products).

Key terms in this report:
- **Ported**: Odeo installs on the target as a plugin and its three load-bearing layers work
  there: the PM skills, the build and review pipeline (dispatched agents with their own
  tools), and the baseline context that hooks inject at session start.
- **Least rework**: the fewest of those three layers that must be rebuilt in another format.
- **Baseline**: the content of Odeo's `global/CLAUDE.md`, delivered by Odeo's SessionStart
  and SubagentStart hooks.

## Answer

Cowork is likely the target with the least rework, but only after release B: it reads the
same plugin folder, loads skills and agents (one source, F9b, F9c) and hooks (verified, F9d),
yet refuses any plugin with a top-level `bin/` folder (one source, F10), which Odeo ships
until release B deletes it (one source, F21). Codex comes next: it reads Odeo's plugin files
and runs the two session-start hooks Odeo uses (verified, F1, F2), but users must trust its
hooks before they run and again after every hook change (verified, F4), and Odeo's agents
would likely have to become skills (one source, an inference, F6); Antigravity is closer than
v3 said, since it now injects context at session start (verified, F12) and takes plugin agents
(one source, F16b), but it needs its own manifest (one source, F14). claude.ai chat ignores
agents (one source, F9c) and its docs conflict on hooks (F11), so it can carry the PM skills at
most, and how updates reach users is documented only for Antigravity (one source, F17), so it
is open for Codex, Cowork and chat.

## Findings

Every claim carries its note numbers and its confidence word: **verified** (two independent
sources), **one source**, or **unverified** (no source this report can name). The data date
of every claim is 2026-10-13 unless one is given. Claims are grouped by sub-question.

### 1. Plugin format and install

- **F1** Codex reads Odeo's existing manifests: it discovers `.claude-plugin/plugin.json` and
  accepts a marketplace at `.claude-plugin/marketplace.json`. **Verified** (notes 1, 2).
- **F13** Antigravity installs plugins from a GitHub repository URL. **Verified** (notes 14, 15).
- **F14** Antigravity needs its own `plugin.json` at the plugin root, whose schema allows only
  `name` and `description` and forbids other fields. **One source** (note 14).
- **F9a** Cowork and claude.ai chat add plugins from **Customize > Plugins**, including a
  marketplace in a GitHub repository. **One source** (note 9).

### 2. SKILL.md skills

- **F7** Codex supports skills; its skill list uses at most 2% of the context window, or
  8,000 characters when the window is unknown. **One source** (note 6).
- **F9b** claude.ai chat and Cowork load `skills/<name>/SKILL.md`. **One source** (note 9).
- **F16** Antigravity plugins can contain `skills/<name>/SKILL.md`. **One source** (note 14).

### 3. Subagents with own tool lists

- **F6** OpenAI's guide for porting Claude Code plugins tells authors to "move reusable agent
  procedures into skills"; that Codex plugins cannot ship agents is an **inference** from this
  advice. **One source** (note 5).
- **F6b** Codex custom agents are standalone TOML files under `~/.codex/agents/` or
  `.codex/agents/`. **One source** (note 5).
- **F9c** Cowork loads `agents/*.md`; claude.ai chat ignores them. **One source** (note 9).
- **F16b** Antigravity plugins can ship subagents as `plugins/<plugin_name>/agents/`.
  **One source** (note 16). Which frontmatter fields (tools, model) it honours: **unverified**.

### 4. Session-start hooks and trust

- **F2** Codex has `SessionStart` and `SubagentStart` hooks that add context. **Verified**
  (notes 3, 4).
- **F3** Codex caps each hook's model-visible output at about 2,500 tokens by default; a
  handler can raise it with `additionalContextLimit`. **Verified** (notes 3, 4).
- **F4** Codex skips plugin hooks until the user reviews and trusts them, and records trust
  against the hook's hash, so a new or changed hook needs review again. **Verified** (notes
  3, 4).
- **F5** Codex matches PreToolUse on `apply_patch`, which can also be matched as `Edit` or
  `Write`. **One source** (note 3).
- **F9d** Cowork loads `hooks/hooks.json`. **Verified** (notes 9, 11). Which events fire in
  Cowork, and whether the user confirms plugin hooks first: **unverified**.
- **F11** claude.ai chat and hooks: **conflict**. The platform table says chat ignores
  `hooks/hooks.json` (note 9); the desktop changelog of 2026-09-10 says "hooks from
  organization plugins" now "also run in Chat" (note 11). Both may hold (organization plugins
  only); this report cannot settle it.
- **F12** Antigravity has a `SessionStart` hook that fires before the first model call and
  can inject steps into the conversation. **Verified** (notes 12, 13).
- **F12b** Antigravity has `PreToolUse` and `Stop` hooks; PreToolUse matches Antigravity's own
  tool names such as `run_command` and `view_file`, not Claude Code's. **Verified** (notes 12,
  13).
- **F12c** Antigravity rules: 24,000 bytes per file and a 20,000-token budget shared by all
  active rules. **One source** (note 17).
- **F19** Claude Code caps each hook's `additionalContext` at 10,000 characters. **One
  source** (note 18).

### 5. Executables (`bin/`)

- **F10** claude.ai chat and Cowork refuse a plugin with a top-level `bin/` directory.
  **One source** (note 10; three pages of one vendor's docs).
- **F8** Codex: OpenAI's porting guide says to "Call bundled executables with
  package-relative paths" (note 5, one source); Codex's installer skips a symlinked
  executable under `bin/` (note 7, one source, a test in the source). Whether `bin/` is put on
  PATH: **unverified**.
- **Antigravity** `bin/`: no source found that mentions it. **Unverified**.

### 6. Updates

- **F17** Antigravity: plugins installed in Antigravity 2.0 "are automatically updated".
  **One source** (note 14).
- Codex, Cowork and claude.ai chat: no update mechanism re-checked in this revision.
  **Unverified**.

### 7. Odeo itself

- **F21** Odeo 0.3.0 (commit `0abbffb`, 2026-09-29) moved its programs to `scripts/`; at
  `4f0084e` (version 0.3.4, released 2026-10-02 as `c56da53`) `bin/` still holds 26
  forwarding wrappers, and release B, the next planned release, deletes them. **One
  source** (note 19: this repo's history, files and task ledger).
- **F22** Odeo's baseline is 20,395 characters at `4f0084e`, delivered as 4 SessionStart
  parts. **One source** (note 19, measured in this repo).

### Capability table

**Y** supported, **P** partial or reworked, **N** not supported, **?** unverified. Each cell
names its finding; the confidence word is on the finding above.

| Capability Odeo uses | Claude Code (today) | Codex CLI / ChatGPT app | Antigravity | Cowork | claude.ai chat |
|---|---|---|---|---|---|
| Plugin manifest, GitHub install | Y | Y, reads `.claude-plugin/*` (F1) | P, own `plugin.json` (F14); GitHub install (F13) | Y (F9a) | Y (F9a) |
| Top-level `bin/` | Y, on PATH | P, package-relative paths (F8) | ? | N, refused (F10) | N, refused (F10) |
| SKILL.md skills | Y | Y, list capped (F7) | Y (F16) | Y (F9b) | Y (F9b) |
| Subagents | Y | P, not from a plugin (F6, inferred); TOML agents (F6b) | Y, plugin `agents/` (F16b) | Y (F9c) | N, ignored (F9c) |
| Session-start context | Y, 10,000 chars per hook (F19) | Y, ~2,500 tokens per hook (F2, F3) | Y, `injectSteps` (F12) | ? which events fire (F9d) | conflict (F11) |
| Edit guard (PreToolUse) | Y | P, `apply_patch` matcher (F5) | P, own tool names (F12b) | ? | conflict (F11) |
| Hooks run without a prompt | Y | N, trust first, again on change (F4) | ? | ? | n/a |
| Updates | version bump | ? | Y, automatic in 2.0 (F17) | ? | ? |

Rows from v3 that this revision did not re-check (language dialog, AGENTS.md or CLAUDE.md
reading, git guards in the user's repo) are dropped from the table and listed as open
questions under Unverified. One of them has a source now: Codex reads AGENTS.md up to 32 KiB
by default (note 8, one source).

### Notes

1. OpenAI docs, developers.openai.com/plugins/build/plugins.md, line 541: "a
   legacy-compatible marketplace at `$REPO_ROOT/.claude-plugin/marketplace.json`".
2. Codex source, github.com/openai/codex at `90f00bd` (2026-10-13),
   `codex-rs/exec-server-protocol/src/protocol.rs` lines 51 to 55:
   `DISCOVERABLE_PLUGIN_MANIFEST_PATHS` = `.codex-plugin/plugin.json`,
   `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`.
3. OpenAI docs, developers.openai.com/codex/hooks.md (redirects to
   learn.chatgpt.com/docs/hooks.md). Line 27: "When a session or subagent starts |
   `SessionStart`, `SubagentStart`". Lines 529 to 530: "By default, Codex limits each
   model-visible hook-output message to roughly 2,500 tokens". Line 555: "Omit
   `additionalContextLimit` to use the default `2500`-token threshold". Lines 64 to 66:
   "Codex records trust against the hook's current hash, so new or changed hooks are marked
   for review and skipped until trusted". Lines 406 to 408: "Codex skips plugin-bundled hooks
   until you review and trust the current hook definition". Line 433: "For `apply_patch`,
   `matcher` values can also use `Edit` or `Write`".
4. Codex source at `90f00bd`: `codex-rs/protocol/src/protocol.rs` lines 1694 and 1697
   (`SessionStart`, `SubagentStart`); `codex-rs/hooks/src/events/session_start.rs` lines 56
   and 59; `codex-rs/hooks/src/output_spill.rs` line 12:
   `DEFAULT_HOOK_OUTPUT_TOKEN_LIMIT: usize = 2_500`; `codex-rs/core/tests/suite/hooks.rs`
   line 2092: `session_start_hooks_apply_additional_context_limits_individually`;
   `codex-rs/hooks/src/engine/discovery.rs` lines 666 to 681: `current_hash = hook_hash(...)`
   passed to `hook_trust_status(..., &current_hash, trusted_hash)`.
5. OpenAI docs, developers.openai.com/plugins/guides/submit-claude-plugin.md, line 33:
   "Convert reusable behavior to skills. Turn each Markdown command into a skill, move
   reusable agent procedures into skills"; line 37 (`bin/` row): "Call bundled executables
   with package-relative paths". developers.openai.com/codex/subagents.md (redirects to
   learn.chatgpt.com/docs/agent-configuration/subagents.md), lines 340 to 342: "add
   standalone TOML files under `~/.codex/agents/` for personal agents or `.codex/agents/` for
   project-scoped agents". Both pages are OpenAI docs: one source.
6. OpenAI docs, developers.openai.com/codex/skills.md (redirects to
   learn.chatgpt.com/docs/build-skills.md), lines 38 to 39: "this list uses at most 2% of the
   model's context window, or 8,000 characters when the context window is unknown".
7. Codex source at `90f00bd`, `codex-rs/core-plugins/src/store_tests.rs` lines 531 to 552,
   test `agent_plugin_install_skips_symlinked_executable`: asserts
   `!result.installed_path.join("bin/tool").exists()` for a symlinked `bin/tool`.
8. OpenAI docs, developers.openai.com/codex/guides/agents-md.md (redirects to
   learn.chatgpt.com/docs/agent-configuration/agents-md.md), line 15: "`project_doc_max_bytes`
   (32 KiB by default)".
9. Anthropic docs, claude.com/docs/plugins/platform-support.md, component table (columns
   Chat, Cowork, Claude Code): "Skills (`skills/<name>/SKILL.md`) | Loads | Loads | Loads";
   "Agents (`agents/*.md`) | Ignored | Loads | Loads"; "Hooks (`hooks/hooks.json`) | Ignored |
   Loads | Loads"; install table: "Where you add plugins | **Customize > Plugins**"; "Hosts
   for a marketplace you add yourself | GitHub and GitHub Enterprise repositories".
10. Anthropic docs, the same vendor's docs counted as one source:
    claude.com/docs/plugins/platform-support.md: "Executables in a top-level `bin/` directory
    | Can't be installed | Can't be installed | Loads"; claude.com/docs/plugins/build.md line
    544: "A top-level `bin/` directory stops claude.ai and Cowork from installing the plugin
    at all"; claude.com/docs/plugins/org-sync.md line 109: "The error message starts with
    `Plugin contains a top-level bin/ directory`".
11. Claude desktop changelog, claude.com/docs/cowork/changelog.md, entry v1.52386.0
    (2026-09-10), line 580: "Changed hooks from organization plugins to also run in Chat,
    matching Cowork and Code."
12. Google docs, antigravity.google/docs/hooks: "SessionStart array Handlers that run once
    when a new conversation session starts, before the first model invocation"; output field
    "injectSteps array of objects Optional. List of steps to inject into the conversation
    trajectory at the start of the session"; events table lists SessionStart, PreToolUse,
    PostToolUse, PreInvocation, PostInvocation, Stop; matcher example "Match exactly
    run_command"; tool list includes "view_file".
13. Antigravity CLI binary `agy` 1.1.5 (local, file date 2026-07-21), `strings` output:
    `.exa.hooks_pb.SessionStartHookArgs`,
    `hooks_go_proto.(*SessionStartHookResult).GetInjectSteps`, `StopHookArgs`, `run_command`
    (65 hits), `view_file` (49 hits).
14. Google docs, antigravity.google/docs/plugins: "A plugin is a directory containing a
    required manifest file ( plugin.json )"; schema `"required" : [ "name" ],
    "additionalProperties" : false` with only `name` and `description`; tree shows
    `skills/<skill-name>/SKILL.md` and `agents/<agent-name>.md`; "agy plugin install
    https://github.com/ < owner > / < repo >"; "Plugins installed in Antigravity 2.0 are
    automatically updated"; "CLI filesystem location ... ~/.gemini/antigravity-cli/plugins/
    <plugin_name>/"; the `agy plugin list --json` example on the same page shows `"path" :
    "/home/user/.gemini/config/plugins/gcalendar"`.
15. Antigravity changelog, antigravity.google/docs/changelog, Antigravity CLI section:
    "Added support for installing plugins directly from GitHub subpaths (with branch
    resolution)"; "Fixed plugin installation path mismatch: updated the plugin subcommand to
    install downloaded plugins directly to the shared configuration directory (
    ~/.gemini/config/ ) rather than the private application data folder". The page text does
    not let this report attribute either line to a release reliably (two parsing methods gave
    different versions), so no version is claimed.
16. Google docs, antigravity.google/docs/subagents, locations table: "Plugins
    plugins/<plugin_name>/agents/ Bundled Plugin Package". Same vendor as note 14.
17. Google docs, antigravity.google/docs/rules: "24 KB ( 24,000 bytes) per-file limit" and
    "20,000-token aggregate rules budget".
18. Anthropic docs, code.claude.com/docs/en/hooks.md line 996: "A hook's `additionalContext`
    ... are capped at 10,000 characters".
19. This repo: `git show 0abbffb` "chore(release): 0.3.0" (2026-09-29); `git show c56da53`
    "chore(release): 0.3.4" (2026-10-02); `.claude-plugin/plugin.json` "version": "0.3.4";
    `ls bin` 26 files and `ls scripts` 26 files at `4f0084e`; release B planned in
    `.claude/tasks/todo.md` lines 143 and 222 ("delete bin/"); `wc -m global/CLAUDE.md` =
    20395 at `4f0084e`; `hooks/hooks.json` registers `odeo-context.sh baseline 1` to `4` on
    SessionStart.

## Numbers

All measured on 2026-10-13 unless a date is given.
- Odeo's baseline: 20,395 characters at `4f0084e` (`wc -m global/CLAUDE.md`, note 19), about
  5.1k tokens by the heuristic of characters divided by four (an estimate, not a tokenizer
  count). Against Codex's default of about 2,500 tokens per hook (F3) that means at least 3
  parts, or one part with a raised `additionalContextLimit` (F3). Against Claude Code's
  10,000 characters per hook (F19) Odeo uses 4 parts today. Antigravity rules: one 24,000-byte
  file would hold it, but it would share the 20,000-token budget with every other active rule
  (F12c).
- Odeo ships 67 skills at `4f0084e` (`ls skills`); 53 of them carry
  `disable-model-invocation` (`grep -l`). Whether the Codex skill-list cap (F7) would shorten
  their descriptions depends on the context window: unverified, not measured.
- `bin/` and `scripts/` each hold 26 files at `4f0084e` (note 19).

## Unverified

Not verified (one source):
- F6 and F6b Codex agents; the "plugins cannot ship agents" reading is an **inference** from
  porting advice.
- F5 Codex PreToolUse matcher; F7 Codex skill-list cap; F8 Codex `bin/` handling (two
  separate one-source facts; "not on PATH" is unverified); Codex reads AGENTS.md up to
  32 KiB (note 8).
- F9a, F9b, F9c Cowork and claude.ai install path, skills and agents (Anthropic docs only).
- F10 `bin/` refused on claude.ai and Cowork: three pages of one vendor's docs. A dated
  install attempt that is refused would be a second kind of evidence.
- F12c Antigravity rules limits; F14 Antigravity manifest; F16, F16b Antigravity skills and
  plugin agents; F17 Antigravity automatic updates.
- F19 Claude Code 10,000-character hook cap.
- F21, F22 Odeo's own release facts and baseline size: this repo only (its history, files
  and task ledger), measured, not a second independent source.

Unverified (no source this report can name):
- Cowork: which hook events fire and inject context; whether the user confirms plugin hooks
  first; whether agent frontmatter (`tools`, `model`, `effort`, `isolation`) is honoured;
  whether git hooks can be installed into the user's repos from Cowork.
- Antigravity: whether `bin/` is supported or put on PATH; which agent frontmatter fields it
  honours; whether `agy plugin import ... claude` (seen in the binary as `ClaudeCodeImporter`,
  5 hits, note 13) converts Odeo, not run.
- Codex: whether `bin/` is on PATH; how plugin updates reach users; the skill namespace
  format; the order of concurrently started SessionStart parts; whether an unmodified Odeo
  repo installs as-is.
- Updates for Codex, Cowork and claude.ai chat.
- Dropped v3 rows, now open questions: language dialog (userConfig) support on each target;
  AGENTS.md or CLAUDE.md reading on Antigravity, Cowork and chat; git guards in the user's
  repo on each target.
- Claude.ai upload rejecting skill frontmatter outside the Agent Skills spec (relevant to the
  53 skills with `disable-model-invocation`).

Conflicts, with both values:
- F11 claude.ai chat hooks: "Ignored" (note 9, platform table) against "hooks from
  organization plugins ... also run in Chat" (note 11, changelog 2026-09-10).
- Antigravity CLI plugin location: `~/.gemini/antigravity-cli/plugins/<plugin_name>/` (note
  14, "CLI filesystem location") against `~/.gemini/config/plugins/...` (note 14, the
  `agy plugin list --json` example on the same page) and `~/.gemini/config/` (note 15,
  changelog fix).

Inferences:
- F6 "Codex plugins cannot ship agents" (from porting advice).
- The capability table's **P** for Codex subagents rests on that inference.

## Implications for us

- **Do release B before any Cowork work, then test Cowork first.** Reason: Cowork loads the
  same skills, agents and hooks (F9b, F9c, F9d; F9c is one source), so it may need the least
  rework, but it refuses Odeo while `bin/` exists (F10, one source; F21, one source). The Cowork install
  test after release B is also what turns F10 and F9c into verified claims or refutes them.
- **Keep Codex as the second target, and plan for the hook trust step.** Reason: Codex reads
  our manifests and runs our session-start hooks (F1, F2, verified), but every release that
  changes a hook asks users to trust it again (F4, verified), and the agent pipeline likely
  has to become skills (F6, one source, an inference). The spike should settle the
  unverified Codex items above before a PRD.
- **Re-rank Antigravity against Codex after the Cowork test; claude.ai chat stays PM skills
  at most.** Reason: Antigravity now injects context at session start (F12, verified) and
  takes plugin agents (F16b, one source), but needs its own manifest (F14, one source) and
  its own tool names in guards (F12b). Chat ignores agents (F9c, one source), which removes
  the build pipeline, whatever the hook conflict (F11) resolves to.

## Sources (accessed 2026-10-13)

Every page below was fetched raw on 2026-10-13 and grepped; the notes quote what each claim
uses. Redirects are recorded as observed that day.

OpenAI:
- developers.openai.com/plugins/build/plugins.md (no redirect)
- developers.openai.com/plugins/guides/submit-claude-plugin.md (no redirect)
- developers.openai.com/codex/hooks.md, redirects to learn.chatgpt.com/docs/hooks.md
- developers.openai.com/codex/skills.md, redirects to learn.chatgpt.com/docs/build-skills.md
- developers.openai.com/codex/subagents.md, redirects to
  learn.chatgpt.com/docs/agent-configuration/subagents.md
- developers.openai.com/codex/guides/agents-md.md, redirects to
  learn.chatgpt.com/docs/agent-configuration/agents-md.md
- read, no claim uses it: /codex/plugins.md (to learn.chatgpt.com/docs/plugins.md),
  /codex/config-reference.md (to learn.chatgpt.com/docs/config-file/config-reference.md),
  /codex/import.md (to learn.chatgpt.com/docs/import.md); /codex/changelog.md returned 404.
- github.com/openai/codex at `90f00bd` (2026-10-13), shallow clone, files named in notes 2, 4
  and 7.

Google:
- antigravity.google/docs/hooks, /plugins, /subagents, /rules, /changelog (page text through
  Antigravity 2.0 v2.23.0 of 2026-10-12 and CLI v1.3.1 of 2026-10-07)
- read, no claim uses it: /skills (only for F16's SKILL.md format), /cli/features,
  /marketplace, /sidecars, /cli/gcli-migration
- the local `agy` 1.1.5 binary, `strings` only, not run.

Anthropic:
- claude.com/docs/plugins/platform-support.md, /build.md, /org-sync.md
- claude.com/docs/cowork/changelog.md (entries through v2.31226.1 of 2026-10-09)
- code.claude.com/docs/en/hooks.md
- read, no claim uses it: claude.com/docs/plugins/overview.md, /org-rollout.md, /admin.md,
  /cowork/guide/plugins.md, /cowork/overview.md; code.claude.com/docs/en/plugins-reference.md,
  /plugins.md, /skills.md, /discover-plugins.md, /desktop.md;
  raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md (no `bin/` refusal entry).

This repo: commits and files named in note 19.

Not covered: no install was run on any target; no Codex binary was available locally; the
Antigravity changelog's release attribution could not be parsed reliably; the
google-gemini/gemini-cli docs page listed in v3 was not recovered, and no claim in this
revision rests on it; no non-English docs.

## Revision 2026-10-13

Re-scored against the final research rubric (`skills/research/rubric.md`) at 6/16 FAIL:
traceability and unverified labelling scored 0 because most cells cited no source and two
one-source claims were stated as fact. This revision re-fetched every source raw, quoted each
claim in a note, labelled each claim, and dropped or opened what it could not re-source.
Two findings changed the answer: Antigravity now documents a SessionStart hook that injects
context (it had none on 2026-09-29), and Anthropic's platform table says Cowork loads agents
and hooks. Codex hook trust repeating on every change is now quoted, no longer inferred.

## Revision 2026-10-02

Round 2 (12/14) found two Answer claims stated as fact that rested on **?** cells, and the
legend called one quoted source "verified". Round 1 (9/14): about nine cells cited a source
count without naming the sources, which lived in agent reports that were not kept.
