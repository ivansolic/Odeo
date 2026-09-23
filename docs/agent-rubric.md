# Agent authoring rubric

Scored by `agent-reviewer` (0-2 per criterion) over an agent definition file.
Used as a quality gate and for regression checks (better than the previous
version?). Record goes to `docs/evals/agent-<name>.md`.

```
1. Trigger/description   0 vague; can't tell when this agent is dispatched
   clarity               1 states what it does
                         2 states what it does AND when it's dispatched AND its
                           scope boundary (what it is NOT for)

2. Tool least-privilege  0 tools far exceed the role (e.g. Write/Edit on a
                           read-only reviewer/analyst)
                         1 mostly right, one questionable grant
                         2 tools are exactly what the role needs, nothing more;
                           read-only roles carry no mutating tools

3. Role boundary         0 does several jobs, or redecides what it should inherit
                         1 mostly one job, fuzzy edges
                         2 one clear job; escalates instead of overreaching
                           (e.g. story-level planning never redecides product
                           architecture)

4. Policy conformance    0 violates AGENTS.md (version-pinned model name, wrong
                           builder model, missing required frontmatter)
                         1 conforms but a field is loose or undeclared
                         2 fully conforms: tiers not versions (C11), effort
                           declared from the allowed set, builder model
                           sonnet/inherit, isolation set where needed

5. Instruction quality   0 vague or contradictory instructions
                         1 clear but thin
                         2 a precise contract: process, output shape, honesty/
                           guardrail integration, "rules for yourself"

Threshold: total >= 8/10 AND no criterion at 0.
```

Notes for the scorer:
- Quote the frontmatter line or instruction sentence behind every score.
- Least-privilege (criterion 2) is the highest-signal check: an over-broad
  `tools:` grant is a security-relevant finding, not a style nit.
- Score the definition, not the role's usefulness; whether the system NEEDS this
  agent is an architecture question, not this rubric's.
