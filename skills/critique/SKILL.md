---
description: Use when the user asks to critique, red-team, poke holes in, stress-test, or pre-mortem a PRD, strategy, or product direction before committing to build it.
---

# Critique (red-team + pre-mortem)

Find the holes while they're cheap. Two passes: a **red-team** that attacks the logic,
and a **pre-mortem** that imagines failure and works backward (the classic
pre-mortem technique).

## When to use
- After a `/odeo:prd` or `/odeo:strategy` draft, before committing to build.
- Re-run if the revisions are large.
- Not for code, a single story or a second model's read (that is `/odeo:second-opinion-pm`).

## Pass 1, Red-team (attack it)
1. **List what the plan takes for granted:** who the user is, how the market behaves,
   what limits the team, why the mechanism works, how long it takes. Keep only the
   claims the plan stands on: if the claim is false, the decision changes. Drop cosmetic
   ones (style, naming, wording) and do not list them at all. Look for claims in five places: the problem
   (real, urgent, whose evidence?), the assumptions, the outcome or metric (measurable,
   gameable?), the scope (is the MVP minimal?), the alternative (why not keep doing what
   they do today?).
2. **Strongest case first.** For each kept claim, write the strongest case for it, then
   attack that case, never a weaker version.
3. **Write each failure as "Fails if ..."** with a concrete, checkable condition. Good:
   "Fails if fewer than 1 in 10 interviewed admins has paid for a similar tool in the
   last year." Bad: "Fails if users don't care."
4. **Rank the claims** on three measures, each high / medium / low and each shown per
   claim: impact if wrong, likelihood it is wrong, cost to test. Top = high impact,
   plausibly wrong, cheap to test: that is what to test this week. Say this ranking rule
   in one sentence in the output.
5. **Do not invent doubt.** Treat a claim as at risk unless the plan cites evidence for
   it. When a claim is well supported, say so and move it to What holds up.
   That claim stays in the ranked table but gets no kill test.
6. **For each claim still standing as a risk:** Strongest case, Fails if, Evidence this
   week (which number, report or customer call would settle it), Kill criterion, Cheapest
   test. Fails if says when the claim is false; the Kill criterion is the decision: the
   result on this week's evidence at which you stop or change the plan, and what changes.

Rules: at most 5 claims; specific to this plan, no generic risks.

## Pass 2, Pre-mortem (assume failure)
> "It's 6 months later and this shipped and failed. What happened?"
1. **Imagine it shipped and failed, then look for causes in five areas:** technical,
   users, business, operations, dependencies. Push past the obvious: the most dangerous
   risks are the ones nobody raises. A risk that rests on a market fact gets it checked
   with `/odeo:research` or marked unverified.
2. **Put every risk in exactly one group.** Real threat: there is evidence or clear logic
   for it. Overblown worry: say why it is overblown and what would turn it into a real
   threat. Unspoken worry: nobody is checking it, so say how to check it before launch and
   how to raise it with the team. When unsure, call it a real threat.
3. **Put every real threat in exactly one timing bucket:** must fix before launch, fix
   within 30 days, or watch. A 30-day threat gets a likelihood, an impact, a mitigation
   and an owner role. A watched threat names its trigger, the early signal that would move
   it up.
4. **Give every must-fix threat** a likelihood and an impact (high, medium or low), a
   mitigation specific enough to assign, an owner written as a role (product, engineering,
   support, legal), never a person's name, and "by when" as a point in the plan (for
   example "before beta"), never an invented calendar date.
5. **Make the launch call:** go, phase or delay, with the reason. Many must-fix threats
   mean phase or delay.
6. **No blame; the goal is readiness.** Always end with the `Before launch:` line: re-run
   the pre-mortem on the must-fix items. When the user acts on the critique, that re-run
   becomes a follow-up (see Output).

Rule: at most 3 real threats in total across the three timing buckets, at most 3
overblown worries and at most 3 unspoken worries.

## Security pre-mortem (required for sensitive features)
If it touches auth, PII, payments, uploads, or anything private:
> "It's 6 months later and we had a breach/leak through this. What was the hole? Where
> does the data live, who can reach it, what's the worst path in?"
List the top 3 attack/leak scenarios and what the design must include to close them.

**Both passes:** a threshold or trigger you propose is labelled as a proposal, and a market
fact or benchmark is cited or marked unverified (`${CLAUDE_PLUGIN_ROOT}/AGENTS.md`
Guardrails 6). A worked example of both passes with real values: `example.md`.

## Output
In chat, always this shape, in this order; an empty section says "None." The headings are
structural labels and stay English (Guardrails 7):

```
## Red team
Ranking rule: <one sentence>
### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
Top pick this week: claim <N>
### Kill tests
(per claim: Strongest case / Fails if / Evidence this week / Kill criterion / Cheapest test)
### What holds up
### What I could not judge
## Pre-mortem
### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
### Fix within 30 days
| # | Risk | Likelihood | Impact | Mitigation | Owner role |
### Watch
(per risk: the trigger that would move it up)
### Overblown worries
(per worry: why it is overblown, what would make it real)
### Unspoken worries
(per worry: how to check it, how to raise it)
Launch call: go | phase | delay, <reason>
Before launch: re-run the pre-mortem on must-fix <numbers>   (none open: re-run if the plan changes)
## Security pre-mortem   (only when the feature is sensitive)
More on request: a second model's view, an experiment for the top claim, a rewrite of
the riskiest section, test scenarios for the riskiest areas, a launch checklist.
## Next steps            (only when the user asked for depth or next steps)
```

**On request.** The `More on request` line above offers the deeper parts; print them
only when the user asks, under `## Next steps`:
- A second model's opinion: `/odeo:second-opinion-pm`.
- Turn the top claim into an experiment: `/odeo:experiments`.
- Run the pre-mortem alone, or rewrite the riskiest section of the plan.
- Test scenarios for the riskiest areas.
- A launch checklist: must-fix items closed, an owner for each 30-day item, triggers
  being watched, a way to roll back, support told what is coming.

Revise the PRD; capture security findings as requirements.

**Route the follow-ups so they survive the session.** Any finding the user wants
to act on but not now (a test to run, a gate to satisfy, an assumption to check)
goes into `.claude/tasks/todo.md` as a checkable item, with a one-line why.
Long projects resume through `/odeo:start`, and /odeo:start can only surface what is
written down. If the PRD was revised, open the revised file in the editor
(`code -r <file>`, fallback `cursor -r`, else just give the path).

## Quality rules
- Be genuinely adversarial; a soft critique is useless. Attack the strongest version, not a strawman.
- The top-ranked claim is the **one to test this week** (step 4); name it in the Top pick line.
- Every watched threat gets a **trigger** you could detect early.
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-language.sh" <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
