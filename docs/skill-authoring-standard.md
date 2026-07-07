# Skill authoring standard

The rules every skill in this system must follow, ours and new contributions
alike. `skill-reviewer` scores skills against the rubric at the bottom. Informed by
Anthropic's official skill-authoring guidance (docs.claude.com) and hard-won
practice; written in our own words.

## Naming and description
- **Name:** short, lowercase-hyphen, action or artifact the user wants
  (`build`, `prd`, `product-signal`). No `-loop` suffixes, recurring behavior is
  marked in docs, not in names. English only.
- **Description, auto-invoked skills** (no `disable-model-invocation`): start with
  **"Use when..."** and describe ONLY the triggering conditions, symptoms, and
  keywords a session would contain. Never summarize the workflow in the
  description (the agent then skips reading the body). Include the words people
  actually use ("slow", "flaky", "how do I...").
- **Description, explicit commands** (`disable-model-invocation: true`): say what
  the user gets and when to run it, in plain language, with an example invocation
  if the shape is non-obvious.
- Third person, consistent terminology (one name per concept, everywhere).

## Body structure
The proven shape (adapt, don't pad):
1. One-line essence (what this does, plainly)
2. When to use (and when NOT to)
3. Process (numbered, concrete)
4. A worked example with real values (never abstract placeholders)
5. Output (what is produced, where it is saved)
6. Quality/safety rules (reference guardrails, don't restate them)

## Size and structure limits
- **The context window is a shared resource.** Keep SKILL.md lean: under 500
  lines, ideally far less. Frequently auto-loaded skills should be tightest.
- **Progressive disclosure:** heavy reference goes into supporting files in the
  skill folder (`rubric.md`, `reference.md`), max ONE level deep, agents fail to
  follow deeper chains.
- One excellent, complete example beats several mediocre ones.
- Diagrams/flowcharts only for genuine decision points, never for linear steps.

## Content rules
- Plain language first; technical terms as short labeled asides (system-wide rule).
- **No placeholders:** "TBD", "add validation here" and vague steps are failures.
  Exact paths, names, commands.
- No time-sensitive facts (versions, dates, "currently") that rot.
- Pre-written scripts over agent-generated code for critical operations
  (the `privacy-scan.sh` principle).
- Explanation template where teaching is needed: WHAT, EXAMPLE, WHY, WHERE IT
  LIVES, CONCLUSION + limits.
- Never weaken or restate a guardrail; reference it.

## Documentation duties
- If the skill adds a command, update `docs/system-map.md` (the catalog `/guide`
  and `/start` consult). A skill that isn't on the map doesn't exist.
- Recurring skills get the recurring mark in docs (not in the name).

## Testing duties (before a skill ships or changes)
- **Content skills:** produce an artifact with it; score the artifact with the
  domain rubric (must pass threshold).
- **Behavior/discipline skills:** subagent test (baseline without vs variant
  with), see `docs/eval-framework.md`. Full rigor (5+ reps) for
  discipline-critical skills.
- Edits to an existing skill go through `/improve` (evidence, keep or revert).

## Skill rubric (used by skill-reviewer, 0-2 per criterion)
```
1. Trigger clarity     0 vague description / 1 states purpose / 2 correct format for its
                       type ("Use when..." + triggers for auto; plain what-you-get for explicit)
2. Structure           0 wall of text / 1 partial / 2 follows the body structure, lean,
                       progressive disclosure respected (<500 lines, refs one level deep)
3. Worked example      0 none or abstract / 1 present but thin / 2 concrete, real values,
                       runnable or directly imitable
4. Precision           0 placeholders or vagueness / 1 mostly exact / 2 exact paths, names,
                       commands throughout; no TBDs
5. Safety integration  0 contradicts or restates guardrails / 1 silent / 2 references the
                       relevant guardrails and honesty rules where they apply
Threshold: total >= 8/10 AND no criterion at 0.
```
