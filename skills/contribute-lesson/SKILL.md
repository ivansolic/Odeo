---
description: Opt-in. Share a local knowledge/ lesson, an improved rubric, or an eval learning with the community knowledge base so the whole system gets smarter. Sanitizes and generalizes it, shows you exactly what would be shared, and only opens a PR after your approval. Never sends anything automatically.
disable-model-invocation: true
---

Turn a local lesson into a community contribution, safely. You give, and in return
the curated knowledge of all contributors comes back to you on update. **Opt-in and
approval-gated: nothing leaves your machine without your explicit OK.**

## When this runs
- You invoke `/odeo:contribute-lesson`, OR
- After `/odeo:learn` or `/odeo:retro`, if a lesson looks universal, Claude offers it (you choose), OR
- After `/odeo:improve` keeps a rubric or skill change that would help everyone, Claude offers it.
Only for **generalizable** content (universal patterns), never project-specific.

## What can be contributed (three kinds, same pipeline)
1. **A lesson** from `knowledge/` (a solved, reusable problem).
2. **An improved rubric** (e.g. a sharper PRD criterion that /odeo:improve proved better), shared so everyone's quality bar rises.
3. **An eval learning** (a scoring insight, e.g. "PRDs keep failing on X, here is the counter"), generalized.

## The offer (when Claude suggests it)
> 💡 This lesson could help others using this system.
>
> Contributing it adds it to the shared knowledge base:
> • The system YOU use gets smarter, on each update you get back the curated
>   knowledge of ALL contributors, not just your own.
> • The more people contribute, the faster everyone builds and the fewer repeated mistakes.
>
> Privacy guaranteed:
> • Only a sanitized, generalized version is shared, no code, secrets, names, or
>   anything private from your project.
> • You will see EXACTLY what would be shared, and nothing goes without your approval.
>
> Contribute this lesson? (I will show you the sanitized version first.)

## Steps
1. Pick the contribution: a lesson from `knowledge/`, a kept rubric change, or an eval learning (ask which if several).
2. **Sanitize + generalize:**
   - Remove: real secrets/keys, PII, the project's proprietary code, internal file/class names, business logic specific to them.
   - Keep: the technical pattern, problem to solution, the reasoning, and a **generic** illustrative code example (not their proprietary code).
   - Result: a universal, reusable lesson with a generic example. Concrete, not vague.
3. **Run the deterministic privacy scan (hard gate, do not skip):**
   - Write the sanitized draft to a temp file and run `privacy-scan.sh <file>`
     (on PATH through the Odeo plugin's `bin/`).
   - **Exit 0:** clean, continue.
   - **Exit 1 (BLOCK):** it found emails, secrets/tokens, local paths, IPs, or the
     user's deny-list terms. Show the findings. For each, either **redact it** or
     have the user **explicitly confirm it is a generic example, not real data**
     (per-item override). Then re-run the scan. Do not continue while it blocks
     unless the user has overridden each specific finding.
   - This is a safety net under your sanitization, not a replacement for it.
4. **Show the user the exact sanitized, scanned version** for review.
5. **Only after approval**, open a PR to the community knowledge repo:
   `gh repo fork ... ` then PR to `ivansolic/Odeo-knowledge` (or the configured community repo).
6. Confirm what was submitted and that nothing else left the machine.

## Safety rules (non-negotiable)
- **Opt-in only. Never auto-send.** Always the user's explicit approval before the PR.
- **Run `privacy-scan.sh` and clear/override every finding before the PR.** The scan is a hard gate, not advisory.
- **Never share private specifics** (secrets, PII, proprietary code, internal names). Share the pattern, not the project.
- Show the exact sanitized content before submitting.
- Only generalizable lessons; project-specific ones stay local.
