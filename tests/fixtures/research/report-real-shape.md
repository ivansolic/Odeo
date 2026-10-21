---
id: RES-901
title: Fixture in the shape of a real report
mode: deep-dive
depth: quick
date: 2026-10-20
---

# RES-901: Does the Widget CLI load plugin hooks at session start?

## Question

As of 2026-10-20 (Widget CLI source at commit `fe12ab3`): does a Widget CLI plugin get a
session-start hook, and does the user approve it first? Key terms: **session start** means
the first model request of a new session.

## Answer

A plugin can add context at session start (verified, F1); the user approves a plugin once at
install (one source, F2); the docs and the changelog disagree on the default timeout (C1).

## Findings

### Hooks

- **F1** A Widget CLI plugin can register a `SessionStart` hook that adds context. **Verified**
  (notes 1, 3)
  <!-- terms: SessionStart; context -->
- **F2** The user approves a plugin once, at install. **One source** (note 2)

### Limits

- **F3** A hook's output is cut at 4,000 characters by default. **Verified** (notes 2, 3)
  <!-- terms: 4,000|4_000 -->
- **C1** The default hook timeout is a **conflict**: 30 seconds (note 1) against 60 seconds
  (note 4).

| Capability | Widget CLI |
|---|---|
| Session-start context | Y (F1) |
| Output cap | 4,000 chars (F3) |

### Notes

1. Widget docs, docs.widget.dev/hooks.md: line 12, "A plugin can register a `SessionStart`
   hook; its output is added as context for the model"; line 40, "Hooks time out after 30
   seconds".
2. Widget docs, docs.widget.dev/plugins.md: line 8, "You approve a plugin once, when you
   install it"; line 30, "Hook output is truncated at 4,000 characters".
3. Widget source, github.com/widget/cli at `fe12ab3`, `src/hooks/session.rs` lines 10 to 14:
   `HookEvent::SessionStart` and "push the hook output into the model context"; line 3,
   `const MAX_OUTPUT: usize = 4_000;`.
4. Widget changelog, github.com/widget/cli `CHANGELOG.md` at `fe12ab3`, section 2.3.0:
   "Raised the default hook timeout to 60 seconds".

## Numbers

None besides F3.

## Unverified

- F2: one source (docs only).
- C1: 30 seconds (note 1) against 60 seconds (note 4).

## Implications for us

- Port the baseline as a session-start hook (F1, verified); keep each part under 4,000
  characters (F3, verified).

## Sources (accessed 2026-10-20)

- docs.widget.dev/hooks.md, /plugins.md; github.com/widget/cli at `fe12ab3`.
