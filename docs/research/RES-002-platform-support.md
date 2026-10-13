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
Antigravity CLI binary `agy` 1.1.5, Claude Code's changelog at commit `bf2323b`, Odeo at
commit `4f0084e`), for OpenAI Codex (the CLI, and Codex in the ChatGPT desktop app), Google
Antigravity, claude.ai chat and Claude Cowork:

1. Is there a plugin format, and can it install from GitHub?
2. Are SKILL.md skills supported?
3. Are subagents supported, and can a plugin ship them?
4. Are lifecycle hooks that inject context at session start supported, and do they run
   without a user prompt?
5. Can a plugin ship executables (Odeo's top-level `bin/`)?
6. How do plugin updates reach users?
7. What would Odeo lose there, and which platform should be ported first?

The decision it serves: which platform the next porting spike targets (Phase 2 in the task
ledger). Scope: desktop and CLI products only, no region or segment limit (all targets are
global products). For Codex, the source code evidence is the CLI's; the ChatGPT desktop app
is covered only where a finding says so.

Key terms in this report:
- **Ported**: Odeo installs on the target as a plugin and its three load-bearing layers work
  there: the PM skills, the build and review pipeline (dispatched agents with their own
  tools), and the baseline context that hooks inject at session start.
- **Least rework**: the fewest of those three layers that must be rebuilt in another format.
- **Baseline**: the content of Odeo's `global/CLAUDE.md`, delivered by Odeo's SessionStart
  and SubagentStart hooks.
- **Finding**: one fact, with one confidence word. **Verified** means two notes from
  independent sources each quote that same fact; anything less is one source or unverified.

## Answer

Cowork is probably the target with the least rework, but only after release B: it is
documented to load the same plugin folder's skills, agents and hooks (one source each, F20,
F21, F22), yet it refuses a plugin with a top-level `bin/` folder (one source, F25), which Odeo
keeps until release B deletes it (one source, F40); this ranking is an inference that also
rests on the open question of which hook events fire in Cowork. Codex comes next: it installs
from GitHub and reads the `.claude-plugin` marketplace (verified, F1, F2) and has session-start
events whose output becomes context (verified, F5, F6), but a user must trust each hook before
it runs and again after every change (verified, F8, F9), Odeo's agents would likely have to
become skills (one source, inference, F11), and whether Odeo's hooks run there unmodified is
unverified. Antigravity installs from GitHub (verified, F30) and injects context at session
start (verified, F31) but needs its own manifest (one source, F33); claude.ai chat ignores
agents (one source, F21) and its docs conflict on hooks (C1), so it can carry the PM skills at
most; plugin updates were found documented only for Antigravity (one source, F37) and were not
re-checked for the others.

## Findings

One fact per finding, each with its confidence word and notes. Data date for every finding:
2026-10-13 unless one is given.

### Codex (CLI unless stated)

- **F1** Codex adds a plugin marketplace from a GitHub repository (`codex plugin marketplace
  add owner/repo`). **Verified** (notes 1, 2).
- **F2** Codex reads a marketplace at `.claude-plugin/marketplace.json`. **Verified** (notes
  1, 3).
- **F3** Codex discovers a plugin manifest at `.claude-plugin/plugin.json`. **One source**
  (note 3).
- **F4** Plugins work in Codex in the ChatGPT desktop app. **One source** (note 4).
- **F5** Codex has `SessionStart` and `SubagentStart` hook events. **Verified** (notes 5, 6).
- **F6** Output of a Codex `SessionStart` hook is added to the model's context. **Verified**
  (notes 5, 6).
- **F7** Codex limits each hook's model-visible output to about 2,500 tokens by default.
  **Verified** (notes 5, 6).
- **F7b** A Codex hook handler can change that limit with `additionalContextLimit`.
  **Verified** (notes 5, 6).
- **F8** Codex runs a non-managed hook, plugin hooks included, only after the user trusts it.
  **Verified** (notes 5, 7).
- **F9** Codex records trust against the hook's hash, so a changed hook needs trust again.
  **Verified** (notes 5, 7).
- **F10** Codex PreToolUse can match file edits as `apply_patch`, `Edit` or `Write`. **One
  source** (note 5).
- **F11** OpenAI's guide for porting Claude Code plugins says to move agent procedures into
  skills; that Codex plugins cannot ship agents is an **inference** from it. **One source**
  (note 8).
- **F12** Codex custom agents are standalone TOML files under `~/.codex/agents/` or
  `.codex/agents/`. **One source** (note 8).
- **F13** OpenAI's porting guide says to call bundled executables by package-relative path.
  **One source** (note 8).
- **F14** Codex's plugin installer skips a symlinked executable under `bin/`. **One source**
  (note 9).
- **F15** Codex's skill list uses at most 2% of the context window, or 8,000 characters when
  the window is unknown. **One source** (note 10).
- **F16** Codex reads AGENTS.md files up to 32 KiB combined by default. **One source** (note
  11).

### Cowork and claude.ai chat

- **F20** Cowork and chat load `skills/<name>/SKILL.md`. **One source** (note 12).
- **F21** Cowork loads `agents/*.md`; chat ignores them. **One source** (note 12).
- **F22** Cowork loads a plugin's `hooks/hooks.json`. **One source** (note 12).
- **F23** Hooks from organization plugins run in Cowork. **Verified** (notes 12, 13).
- **F24** Cowork and chat add plugins from **Customize > Plugins**, including a marketplace in
  a GitHub repository. **One source** (note 12).
- **F25** Cowork and chat refuse a plugin with a top-level `bin/` directory. **One source**
  (note 14; three pages of one vendor's docs).
- **C1** Chat and hooks, a **conflict**: the platform table says chat ignores
  `hooks/hooks.json` (note 12); the desktop changelog of 2026-09-10 says hooks from
  organization plugins now "also run in Chat" (note 13).

### Antigravity

- **F30** Antigravity installs plugins from a GitHub repository. **Verified** (notes 15, 16).
- **F31** Antigravity has a `SessionStart` hook that can inject steps into the conversation
  before the first model call. **Verified** (notes 17, 18).
- **F32** Antigravity has a `Stop` hook. **Verified** (notes 17, 18).
- **F32b** Antigravity has tools named `run_command` and `view_file`. **Verified** (notes 17,
  18).
- **F32c** Antigravity PreToolUse matches tool names such as `run_command`. **One source**
  (note 17).
- **F33** An Antigravity plugin needs its own `plugin.json`, whose schema allows only `name`
  and `description`. **One source** (note 15).
- **F34** Antigravity plugins can contain `skills/<name>/SKILL.md`. **One source** (note 15).
- **F35** Antigravity plugins can ship subagents in `agents/`. **One source** (notes 15, 19,
  both Google docs).
- **F36** Antigravity rules: 24,000 bytes per file and a 20,000-token budget shared by all
  active rules. **One source** (note 20).
- **F37** Plugins installed in Antigravity 2.0 are updated automatically. **One source** (note
  15).

### Claude Code (Odeo's current platform)

- **F38** Claude Code puts a plugin's `bin/` on the Bash tool's PATH. **Verified** (notes 21,
  22).
- **F39** Claude Code caps each hook's `additionalContext` at 10,000 characters. **One
  source** (note 23).
- **F39b** Claude Code loads skills, agents and hooks from a plugin. **One source** (note 12).

### Odeo itself

- **F40** At `4f0084e` Odeo's `bin/` still holds 26 forwarding wrappers, and release B, the
  next planned release, deletes them. **One source** (note 24, this repo).
- **F41** Odeo 0.3.0 (2026-09-29) moved its programs to `scripts/`. **One source** (note 24).
- **F42** Odeo's baseline is 20,395 characters at `4f0084e`, delivered as 4 SessionStart
  parts. **One source** (note 24, measured).

### Capability table

**Y** supported, **P** partial or reworked, **N** not supported, **?** no finding. Each cell
names its finding; the confidence word is on the finding.

| Capability Odeo uses | Claude Code | Codex | Antigravity | Cowork | claude.ai chat |
|---|---|---|---|---|---|
| Plugin from GitHub | ? | Y (F1, F2) | Y (F30) | Y (F24) | Y (F24) |
| Reads `.claude-plugin/` manifest | ? | Y (F2, F3) | N, own manifest (F33) | ? | ? |
| Top-level `bin/` | Y, on PATH (F38) | P, package-relative (F13, F14) | ? | N, refused (F25) | N, refused (F25) |
| SKILL.md skills | Y (F39b) | Y, list capped (F15) | Y (F34) | Y (F20) | Y (F20) |
| Subagents from a plugin | Y (F39b) | N, inferred (F11); TOML agents (F12) | Y (F35) | Y (F21) | N (F21) |
| Session-start context | Y, 10,000 chars (F39) | Y, ~2,500 tokens (F5, F6, F7) | Y (F31) | ? | C1 |
| Hooks run without a prompt | ? | N, trust first (F8, F9) | ? | ? | ? |
| Updates | ? | ? | Y, in 2.0 (F37) | ? | ? |

### Notes

1. OpenAI docs, developers.openai.com/plugins/build/plugins.md: line 541, "a legacy-compatible
   marketplace at `$REPO_ROOT/.claude-plugin/marketplace.json`"; lines 184 to 190, "Use
   `codex plugin marketplace add` to add and track a marketplace source" with the example
   `codex plugin marketplace add owner/repo`.
2. Codex source, github.com/openai/codex at `90f00bd`, `codex-rs/cli/src/marketplace_cmd.rs`
   lines 62 to 66: `bin_name = "codex plugin marketplace add"`; "Marketplace source: a local
   path, owner/repo[@ref], HTTPS Git URL, or SSH Git URL."
3. Codex source at `90f00bd`: `codex-rs/core-plugins/src/marketplace.rs` lines 20 to 25,
   `MARKETPLACE_MANIFEST_RELATIVE_PATHS` includes `".claude-plugin/marketplace.json"`;
   `codex-rs/exec-server-protocol/src/protocol.rs` lines 51 to 55,
   `DISCOVERABLE_PLUGIN_MANIFEST_PATHS` includes `".claude-plugin/plugin.json"`.
4. OpenAI docs, developers.openai.com/codex/plugins.md (redirects to
   learn.chatgpt.com/docs/plugins.md), lines 12 to 13: "Plugins work in Chat and Work across
   ChatGPT on the web, desktop, and mobile, and in Codex in the ChatGPT desktop app."
5. OpenAI docs, developers.openai.com/codex/hooks.md (redirects to
   learn.chatgpt.com/docs/hooks.md): line 27, "When a session or subagent starts |
   `SessionStart`, `SubagentStart`"; line 676, "That `additionalContext` text is added as
   extra developer context"; lines 529 to 530, "By default, Codex limits each model-visible
   hook-output message to roughly 2,500 tokens"; line 555, "Omit `additionalContextLimit` to
   use the default `2500`-token threshold"; lines 64 to 66, "Before a non-managed hook can
   run, Codex requires you to review and trust the exact hook definition. Codex records trust
   against the hook's current hash, so new or changed hooks are marked for review and skipped
   until trusted"; lines 406 to 408, "Codex skips plugin-bundled hooks until you review and
   trust the current hook definition"; line 433, "For `apply_patch`, `matcher` values can
   also use `Edit` or `Write`".
6. Codex source at `90f00bd`: `codex-rs/protocol/src/protocol.rs` lines 1694 and 1697,
   `SessionStart` and `SubagentStart`; `codex-rs/hooks/src/events/session_start.rs` line 94,
   `additional_contexts_for_model: Vec<AdditionalContext>`; `codex-rs/hooks/src/output_spill.rs` line 12,
   `DEFAULT_HOOK_OUTPUT_TOKEN_LIMIT: usize = 2_500`; `codex-rs/core/tests/suite/hooks.rs`
   line 2092, test `session_start_hooks_apply_additional_context_limits_individually`.
7. Codex source at `90f00bd`, `codex-rs/hooks/src/engine/discovery.rs`: lines 715 to 721, a
   handler is pushed only `if enabled && (source.bypass_hook_trust || matches!(trust_status,
   HookTrustStatus::Managed | HookTrustStatus::Trusted))`; lines 807 to 810,
   `Some(trusted_hash) if trusted_hash == current_hash => HookTrustStatus::Trusted`,
   `Some(_) => HookTrustStatus::Modified`, `None => HookTrustStatus::Untrusted`.
8. OpenAI docs, one source across two pages:
   developers.openai.com/plugins/guides/submit-claude-plugin.md line 33, "move reusable agent
   procedures into skills", and line 37 (`bin/` row), "Call bundled executables with
   package-relative paths"; developers.openai.com/codex/subagents.md (redirects to
   learn.chatgpt.com/docs/agent-configuration/subagents.md) lines 340 to 342, "add standalone
   TOML files under `~/.codex/agents/` for personal agents or `.codex/agents/` for
   project-scoped agents".
9. Codex source at `90f00bd`, `codex-rs/core-plugins/src/store_tests.rs` lines 531 to 552,
   test `agent_plugin_install_skips_symlinked_executable`, asserting
   `!result.installed_path.join("bin/tool").exists()`.
10. OpenAI docs, developers.openai.com/codex/skills.md (redirects to
    learn.chatgpt.com/docs/build-skills.md) lines 38 to 39: "this list uses at most 2% of the
    model's context window, or 8,000 characters when the context window is unknown".
11. OpenAI docs, developers.openai.com/codex/guides/agents-md.md (redirects to
    learn.chatgpt.com/docs/agent-configuration/agents-md.md) line 15:
    "`project_doc_max_bytes` (32 KiB by default)".
12. Anthropic docs, claude.com/docs/plugins/platform-support.md, component table (columns
    Chat, Cowork, Claude Code): "Skills (`skills/<name>/SKILL.md`) | Loads | Loads | Loads";
    "Agents (`agents/*.md`) | Ignored | Loads | Loads"; "Hooks (`hooks/hooks.json`) | Ignored
    | Loads | Loads"; install table, row "Where you add plugins": "[**Customize > Plugins**](https://claude.ai/customize/plugins)
    in claude.ai or the desktop app"; row "Hosts for a marketplace you add yourself": "GitHub
    and GitHub Enterprise repositories".
13. Claude desktop changelog, claude.com/docs/cowork/changelog.md, entry v1.52386.0
    (2026-09-10), line 580: "Changed hooks from organization plugins to also run in Chat,
    matching Cowork and Code."
14. Anthropic docs, one source across three pages: claude.com/docs/plugins/platform-support.md,
    "Executables in a top-level `bin/` directory | Can't be installed | Can't be installed |
    Loads"; claude.com/docs/plugins/build.md line 544, "stops claude.ai and Cowork from installing the
    plugin at all" (after "**A top-level `bin/` directory**"); claude.com/docs/plugins/org-sync.md
    line 109, "The error message starts with `Plugin contains a top-level bin/ directory`".
15. Google docs, antigravity.google/docs/plugins: "A plugin is a directory containing a
    required manifest file ( plugin.json )"; schema `"required" : [ "name" ],
    "additionalProperties" : false` with only `name` and `description`; tree shows
    `skills/<skill-name>/SKILL.md` and `agents/<agent-name>.md`; "Install from a GitHub repository link"; "Plugins installed in Antigravity 2.0 are
    automatically updated"; under "CLI filesystem location": "the CLI stages plugin assets in your global
    configuration directory: ~/.gemini/antigravity-cli/plugins/<plugin_name>/"; the `agy plugin list --json` example on the same page shows `"path" :
    "/home/user/.gemini/config/plugins/gcalendar"`.
16. Antigravity changelog, antigravity.google/docs/changelog, Antigravity CLI section: "Added
    support for installing plugins directly from GitHub subpaths (with branch resolution)";
    "Fixed plugin installation path mismatch: updated the plugin subcommand to install
    downloaded plugins directly to the shared configuration directory ( ~/.gemini/config/ )
    rather than the private application data folder". The page text does not let this report
    attribute either line to a release (two parsing methods gave different versions), so no
    version is claimed.
17. Google docs, antigravity.google/docs/hooks: "SessionStart array Handlers that run once
    when a new conversation session starts, before the first model invocation"; output field
    "injectSteps array of objects Optional. List of steps to inject into the conversation
    trajectory at the start of the session"; "Stop Fires when execution terminates"; matcher
    example "Match exactly run_command"; tool list "view_file : View the contents of a file".
18. Antigravity CLI binary `agy` 1.1.5 (local, file date 2026-07-21), `strings` output:
    `.exa.hooks_pb.SessionStartHookArgs`,
    `hooks_go_proto.(*SessionStartHookResult).GetInjectSteps`, `StopHookArgs`, `run_command`
    (65 hits), `view_file` (49 hits).
19. Google docs, antigravity.google/docs/subagents, locations table: "Plugins
    plugins/<plugin_name>/agents/ Bundled Plugin Package".
20. Google docs, antigravity.google/docs/rules: "24 KB ( 24,000 bytes) per-file limit" and
    "20,000-token aggregate rules budget".
21. Anthropic docs, code.claude.com/docs/en/plugins-reference.md line 626: "Executables |
    `bin/` | Files here are on the Bash tool's `PATH` while the plugin is enabled, so Claude
    runs them as bare commands."
22. Claude Code changelog, github.com/anthropics/claude-code `CHANGELOG.md` at `bf2323b`
    (2026-10-13), section 2.1.91: "Plugins can now ship executables under `bin/` and invoke
    them as bare commands from the Bash tool".
23. Anthropic docs, code.claude.com/docs/en/hooks.md line 996: "A hook's `additionalContext`, `systemMessage`,
    and `initialUserMessage` strings, and its plain stdout, are capped at 10,000 characters".
24. This repo, run 2026-10-13: `git show -s 0abbffb` "chore(release): 0.3.0" (2026-09-29);
    `git show -s c56da53` "chore(release): 0.3.4" (2026-10-02); `.claude-plugin/plugin.json`
    "version": "0.3.4"; at `4f0084e`: `ls bin | wc -l` = 26, `ls scripts | wc -l` = 26,
    `ls skills | wc -l` = 67, `grep -l disable-model-invocation skills/*/SKILL.md | wc -l` =
    53, `wc -m global/CLAUDE.md` = 20395; `hooks/hooks.json` registers `odeo-context.sh
    baseline 1` to `4` on SessionStart; `.claude/tasks/todo.md` lines 143 and 222 plan
    release B to "delete bin/".

## Numbers

All measured on 2026-10-13 at `4f0084e` (note 24).
- Odeo's baseline: 20,395 characters, about 5.1k tokens by the heuristic of characters
  divided by four (an estimate, not a tokenizer count). Against Codex's default of about
  2,500 tokens per hook (F7) that means at least 3 parts, or one part with a raised
  `additionalContextLimit` (F7b). Against Claude Code's 10,000 characters per hook (F39) Odeo
  uses 4 parts today. Antigravity rules: one 24,000-byte file would hold it, but it would
  share the 20,000-token budget with every other active rule (F36).
- Odeo ships 67 skills; 53 carry `disable-model-invocation`. Whether Codex's skill-list cap
  (F15) would shorten their descriptions depends on the context window: not measured.
- `bin/` and `scripts/` each hold 26 files.

## Unverified

One source:
- Codex: F3 `.claude-plugin/plugin.json` discovery (code only); F4 plugins in the ChatGPT
  desktop app; F10 PreToolUse edit matcher; F11 agents to skills; F12 TOML agents; F13
  package-relative executables; F14 symlinked executables skipped; F15 skill-list cap; F16
  AGENTS.md size.
- Cowork and chat: F20 skills; F21 agents; F22 Cowork hooks for plugins in general (F23
  verifies organization plugins only); F24 install path; F25 `bin/` refused (Anthropic docs
  only; no dated refused install was observed).
- Antigravity: F32c PreToolUse matching; F33 manifest; F34 skills; F35 plugin agents; F36
  rules limits; F37 automatic updates.
- Claude Code: F39 hook cap; F39b skills, agents and hooks load.
- Odeo: F40, F41, F42, this repo only.

Unverified, no source this report can name:
- Codex: whether Odeo's hooks run there unmodified; whether `bin/` is put on PATH; how plugin
  updates reach users; skill namespace format; order of concurrently started SessionStart
  parts; whether the ChatGPT desktop app shares the CLI's hook and trust behaviour.
- Cowork: which hook events fire and inject context; whether the user confirms plugin hooks
  first; whether agent frontmatter (`tools`, `model`, `effort`, `isolation`) is honoured;
  whether it reads `.claude-plugin/`; how updates reach users.
- Antigravity: whether `bin/` is supported; which agent frontmatter fields it honours;
  whether hooks run without a prompt; whether `agy plugin import ... claude` (seen in the
  binary as `ClaudeCodeImporter`, 5 hits) converts Odeo, not run.
- claude.ai chat: whether it reads `.claude-plugin/`; how updates reach users; whether an
  upload rejects skill frontmatter outside the Agent Skills spec.
- Claude Code cells marked **?** were not researched (Odeo's current platform).
- Open questions from v3, not re-researched: language dialog (userConfig) support; AGENTS.md
  or CLAUDE.md reading outside Codex; git guards in the user's repo.

Conflicts, with both values:
- C1 chat hooks: "Ignored" (note 12) against "hooks from organization plugins ... also run in
  Chat" (note 13).
- Antigravity CLI plugin location: `~/.gemini/antigravity-cli/plugins/<plugin_name>/` (note
  15, "CLI filesystem location") against `/home/user/.gemini/config/plugins/gcalendar` (note
  15, the `agy plugin list --json` example) and `~/.gemini/config/` (note 16, changelog fix).

Inferences:
- F11: Codex plugins cannot ship agents (from porting advice).
- The ranking in the Answer and Implications (Cowork, then Codex, then Antigravity): it
  weighs one-source findings (F20 to F22, F25, F33, F35) and the open question of which hook
  events fire in Cowork.

## Implications for us

- **Do release B before any Cowork work, then test Cowork first.** Reason: Cowork is
  documented to load skills, agents and hooks (F20, F21, F22, one source each), so it may
  need the least rework (an inference), but it refuses Odeo while `bin/` exists (F25, one
  source; F40, one source). The Cowork install test after release B is also what turns those
  one-source findings into verified ones or refutes them.
- **Keep Codex as the second target and plan for the trust step.** Reason: Codex installs
  from GitHub, reads our marketplace and has session-start context (F1, F2, F5, F6,
  verified), but every release that changes a hook asks users to trust it again (F8, F9,
  verified), and the agent pipeline likely has to become skills (F11, one source, an
  inference). The spike settles whether Odeo's hooks run unmodified (unverified).
- **Re-rank Antigravity after the Cowork test; claude.ai chat stays PM skills at most.**
  Reason: Antigravity injects context at session start (F31, verified) and takes plugin
  agents (F35, one source), but needs its own manifest (F33, one source) and its own tool
  names in guards (F32c, one source). Chat ignores agents (F21, one source), which removes
  the build pipeline whatever C1 resolves to.

## Sources (accessed 2026-10-13)

Every page below was fetched raw on 2026-10-13 and grepped; the notes quote what each claim
uses. Redirects are recorded as observed that day.

OpenAI:
- developers.openai.com/plugins/build/plugins.md (no redirect), note 1
- developers.openai.com/plugins/guides/submit-claude-plugin.md (no redirect), note 8
- developers.openai.com/codex/plugins.md, redirects to learn.chatgpt.com/docs/plugins.md,
  note 4
- developers.openai.com/codex/hooks.md, redirects to learn.chatgpt.com/docs/hooks.md, note 5
- developers.openai.com/codex/subagents.md, redirects to
  learn.chatgpt.com/docs/agent-configuration/subagents.md, note 8
- developers.openai.com/codex/skills.md, redirects to learn.chatgpt.com/docs/build-skills.md,
  note 10
- developers.openai.com/codex/guides/agents-md.md, redirects to
  learn.chatgpt.com/docs/agent-configuration/agents-md.md, note 11
- github.com/openai/codex at `90f00bd` (2026-10-13), shallow clone, notes 2, 3, 6, 7, 9
- read, no finding uses it: /codex/config-reference.md (redirects to
  learn.chatgpt.com/docs/config-file/config-reference.md), /codex/import.md (redirects to
  learn.chatgpt.com/docs/import.md); /codex/changelog.md returned 404.

Google:
- antigravity.google/docs/plugins (note 15), /changelog (note 16; page text through
  Antigravity 2.0 v2.23.0 of 2026-10-12 and CLI v1.3.1 of 2026-10-07), /hooks (note 17),
  /subagents (note 19), /rules (note 20)
- the local `agy` 1.1.5 binary, `strings` only, not run (note 18)
- read, no finding uses it: /skills, /cli/features, /marketplace, /sidecars,
  /cli/gcli-migration

Anthropic:
- claude.com/docs/plugins/platform-support.md (notes 12, 14), /build.md and /org-sync.md
  (note 14)
- claude.com/docs/cowork/changelog.md, entries through v2.31226.1 of 2026-10-09 (note 13)
- code.claude.com/docs/en/plugins-reference.md (note 21), /hooks.md (note 23)
- github.com/anthropics/claude-code `CHANGELOG.md` at `bf2323b` (note 22)
- read, no finding uses it: claude.com/docs/plugins/overview.md, /org-rollout.md, /admin.md,
  /cowork/guide/plugins.md, /cowork/overview.md; code.claude.com/docs/en/plugins.md,
  /skills.md, /discover-plugins.md, /desktop.md

This repo: commands and files named in note 24.

Not covered: no install was run on any target; no Codex binary was available locally, and
the ChatGPT desktop app was not inspected; the Antigravity changelog's release attribution
could not be parsed reliably; the google-gemini/gemini-cli docs page listed in v3 was not
recovered, and no finding rests on it; no non-English docs.

## Revision 2026-10-13 (v5)

Round 5 scored v4 at 10/16: several findings joined two facts with one source each under one
"verified". v5 states one fact per finding, and calls a finding verified only when two notes
from independent sources quote that fact; the Answer, table and Implications cite findings
only. New sources: Codex GitHub install (docs and CLI code), Codex trust gating in code,
Claude Code `bin/` on PATH (docs and changelog).

## Revision 2026-10-13 (v4)

Re-scored v3 against the final research rubric at 6/16: most cells cited no source and two
one-source claims were stated as fact. v4 re-fetched every source raw, quoted each claim in a
note and labelled it. Two findings changed the answer: Antigravity's docs now describe a
SessionStart hook that injects context (v3 found none in the docs), and Anthropic's platform
table says Cowork loads agents and hooks.

## Revision 2026-10-02

Round 2 (12/14) found two Answer claims stated as fact that rested on **?** cells. Round 1
(9/14): about nine cells cited a source count without naming the sources.
