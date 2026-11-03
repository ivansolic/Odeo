---
skill: critique
source_skill: pm-execution/commands/pre-mortem
source_commit: 07b34f6
---

# Depth checklist: critique, adopted from the pre-mortem source command

The source command wraps the pre-mortem source skill (checklist `critique-3.md`). Its rows
repeat that skill only where the command states the item itself.

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|
| Invocation examples: a pasted PRD or plan, a one-line launch description | worked example | excluded | already covered by an existing Odeo rule or step: the skill's trigger "critique, red-team, poke holes in, stress-test, or pre-mortem a PRD, strategy, or product direction" (description) starts it from a pasted PRD, a strategy or a bare direction |  |
| Step 1: accept the plan in any format; more detail gives a sharper analysis | step | excluded | already covered by an existing Odeo rule or step: the same trigger (description), which names a PRD, a strategy or a product direction as input |  |
| Step 2: imagine it launched and failed | step | present | Pass 2: "It's 6 months later and this shipped and failed. What happened?" and step 1 | default |
| Step 2: generate risks across technical, user, business, operational and dependency categories | step | present | Pass 2 step 1: "look for causes in five areas: technical, users, business, operations, dependencies." | default |
| Step 3: Tigers, assess severity as launch-blocking, fast-follow or track | decision rule | present | Pass 2 step 3: "Put every real threat in exactly one timing bucket: must fix before launch, fix within 30 days, or watch." | default |
| Step 3: launch-blocking Tigers need immediate mitigation | decision rule | present | Pass 2 step 4: every must-fix threat gets "a mitigation specific enough to assign" | default |
| Step 3: fast-follow Tigers are planned for the first sprint after launch | decision rule | present | Pass 2 step 3: "fix within 30 days"; Pass 2 step 3: "A 30-day threat gets a likelihood, an impact, a mitigation and an owner role." | default |
| Step 3: track Tigers are monitored but do not delay launch | decision rule | present | Pass 2 step 3: "watch. A watched threat names its trigger"; only must-fix threats feed the launch call (step 5) | default |
| Step 3: Paper Tigers, explain why the concern is manageable | decision rule | present | Pass 2 step 2: "Overblown worry: say why it is overblown" | default |
| Step 3: Paper Tigers, note what would need to change to make it a real Tiger | decision rule | present | Pass 2 step 2: "and what would turn it into a real threat." | default |
| Step 3: Elephants, surface political, organisational or uncomfortable risks | decision rule | present | Pass 2 step 2: "Unspoken worry: nobody is checking it" and step 1: "the most dangerous risks are the ones nobody raises." | default |
| Step 3: Elephants, frame constructively with conversation starters | decision rule | present | Pass 2 step 2: "how to raise it with the team"; Output `### Unspoken worries` "(per worry: how to check it, how to raise it)" | default |
| Step 4: report header with date and status (draft or reviewed) | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which threats to fix before launch, since the critique answers in chat at the time it is asked |  |
| Step 4: risk summary with counts per group and per urgency | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which threats to fix before launch, since each group is its own section and holds at most 3 items ("Rule: at most 3 real threats in total across the three timing buckets, at most 3 overblown worries and at most 3 unspoken worries.") |  |
| Step 4: Launch-Blocking table (risk, likelihood, impact, mitigation, owner, deadline) | table column | present | Output `### Must fix before launch`: "\| # \| Risk \| Likelihood \| Impact \| Mitigation \| Owner role \| By when \|" | default |
| Step 4: Fast-Follow table (risk, likelihood, impact, planned response, owner) | table column | present | Output `### Fix within 30 days`: "\| # \| Risk \| Likelihood \| Impact \| Mitigation \| Owner role \|" (the planned response is the Mitigation column) | default |
| Step 4: Track Tigers with trigger conditions | template section | present | Output `### Watch` "(per risk: the trigger that would move it up)" | default |
| Step 4: Paper Tigers section with reasoning | template section | present | Output `### Overblown worries` | default |
| Step 4: Elephants in the Room section | template section | present | Output `### Unspoken worries` | default |
| Step 4: Go/No-Go checklist (launch-blocking mitigated, fast-follow assigned, monitoring for track, rollback plan, support briefed) | template section | present | Output, On request: "A launch checklist: must-fix items closed, an owner for each 30-day item, triggers being watched, a way to roll back, support told what is coming."; the go or no-go itself is the default `Launch call: go \| phase \| delay, <reason>` | on request |
| Step 4: save as markdown | step | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which threats to fix, since the critique answers in chat and its follow-ups are routed to the task list ("Route the follow-ups so they survive the session") |  |
| Step 5: offer to update the PRD with the mitigations | step | present | Output: "Revise the PRD; capture security findings as requirements." | default |
| Step 5: offer test scenarios for the riskiest areas | step | present | Output last default line "More on request: ... test scenarios for the riskiest areas, a launch checklist." and On request: "Test scenarios for the riskiest areas." | on request |
| Step 5: offer a launch checklist from the findings | step | present | Output last default line "More on request: ... a launch checklist." and On request: "A launch checklist: ..." | on request |
| Note: the best pre-mortem happens when the plan is about 80% done | decision rule | present | When to use: "After a `/odeo:prd` or `/odeo:strategy` draft, before committing to build." (a draft that exists, before the build starts) | default |
| Note: push past the obvious risks | decision rule | present | Pass 2 step 1: "Push past the obvious: the most dangerous risks are the ones nobody raises." | default |
| Note: Elephants are the highest-value output | decision rule | present | Pass 2 step 1: "the most dangerous risks are the ones nobody raises", and the unspoken worries have their own section with a check before launch | default |
| Note: each Tiger's mitigation is specific and assignable, not "be careful" | decision rule | present | Pass 2 step 4: "a mitigation specific enough to assign" | default |
| Note: too many launch-blocking Tigers means delay or phase the launch | decision rule | present | Pass 2 step 5: "Make the launch call: go, phase or delay, with the reason. Many must-fix threats mean phase or delay." | default |

Primary method source: as in `critique-3.md` ("The Pre-Mortem Method", Psychology Today,
January 2021, by the method's originator), read 2026-11-03. The categories, timing
buckets and go/no-go items come from the source command alone.
