---
description: Opt-in. Share a local knowledge/ lesson with the community knowledge base so the whole system gets smarter. Sanitizes and generalizes it, shows you exactly what would be shared, and only opens a PR after your approval. Never sends anything automatically.
---

Turn a local lesson into a community contribution, safely. You give, and in return
the curated knowledge of all contributors comes back to you on update. **Opt-in and
approval-gated: nothing leaves your machine without your explicit OK.**

## When this runs
- You invoke `/contribute-lesson`, OR
- After `/learn` or `/retro`, if a lesson looks universal, Claude offers it (you choose).
Only for **generalizable** lessons (universal patterns), never project-specific ones.

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
1. Pick the lesson from `knowledge/` (ask which if several).
2. **Sanitize + generalize:**
   - Remove: real secrets/keys, PII, the project's proprietary code, internal file/class names, business logic specific to them.
   - Keep: the technical pattern, problem to solution, the reasoning, and a **generic** illustrative code example (not their proprietary code).
   - Result: a universal, reusable lesson with a generic example. Concrete, not vague.
3. **Show the user the exact sanitized version** for review.
4. **Only after approval**, open a PR to the community knowledge repo:
   `gh repo fork ... ` then PR to `ivansolic/claude-cofounder-knowledge` (or the configured community repo).
5. Confirm what was submitted and that nothing else left the machine.

## Safety rules (non-negotiable)
- **Opt-in only. Never auto-send.** Always the user's explicit approval before the PR.
- **Never share private specifics** (secrets, PII, proprietary code, internal names). Share the pattern, not the project.
- Show the exact sanitized content before submitting.
- Only generalizable lessons; project-specific ones stay local.
