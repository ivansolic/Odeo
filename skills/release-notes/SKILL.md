---
description: Write user-facing release notes / changelog entries that lead with benefits and are scannable, not a raw commit dump. Use when shipping something users should notice. Turns shipped work into a clear "what's new and why you care."
disable-model-invocation: true
---

# Release notes

Release notes are marketing and support in one: they tell users **what changed and why
it helps them**, in their language. Not a git log.

## When to use
- Shipping a feature, improvement, or notable fix that users should know about.

## Process
1. **Group by user impact**, not by component. Common buckets: New, Improved, Fixed.
2. **Lead each item with the benefit:** "Reset your password in seconds" before (or
   instead of) "added password-reset endpoint." Plain language, no jargon.
3. **Be specific and honest:** what it does, any limits, and how to use it if non-obvious.
   Don't oversell; don't bury breaking changes.
4. **Call out breaking changes / actions required** prominently and separately.
5. **Match the channel:** a one-line changelog entry, an in-app note, or a longer post,
   keep depth appropriate. Link to docs for detail.
6. **No internal noise:** skip refactors/chores users don't feel, unless they explain a
   visible change.

## Output
Release notes in the project's changelog / release format. Pairs with `/gtm-plan` for a real launch.

## Quality rules
- Benefit first, in the user's words; the mechanism is secondary.
- Breaking changes and required actions are never buried.
- Honest about limitations; no overselling. Skip internal-only churn.
