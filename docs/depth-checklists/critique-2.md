---
skill: critique
source_skill: pm-execution/commands/red-team-prd
source_commit: 07b34f6
---

# Depth checklist: critique, adopted from the red-team source command

The source command wraps the red-team source skill (checklist `critique-1.md`). Its rows
repeat that skill only where the command states the item itself.

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|
| Invocation examples: a pasted PRD, a one-line bet, "the current doc" | worked example | excluded | already covered by an existing Odeo rule or step: the skill's trigger "critique, red-team, poke holes in, stress-test, or pre-mortem a PRD, strategy, or product direction" (description) starts it from a pasted PRD, a strategy or a bare direction |  |
| Step 1: accept the plan in any form (PRD, roadmap, strategy memo, one-line bet, uploaded doc, the doc in context) | step | excluded | already covered by an existing Odeo rule or step: the skill's trigger "critique, red-team, poke holes in, stress-test, or pre-mortem a PRD, strategy, or product direction" (description) takes a PRD, a strategy or a bare direction as input |  |
| Step 2: apply the red-team skill: keep only load-bearing claims | step | present | Pass 1 step 1: "Keep only the claims the plan stands on: if the claim is false, the decision changes." | default |
| Step 2: steelman each claim, then attack the steelman | step | present | Pass 1 step 2: "write the strongest case for it, then attack that case, never a weaker version." | default |
| Step 2: write each failure mode as "Fails if" | step | present | Pass 1 step 3: "Write each failure as "Fails if ..."" | default |
| Step 2: rank by impact, likelihood wrong and cheapness to test | decision rule | present | Pass 1 step 4: "impact if wrong, likelihood it is wrong, cost to test" | default |
| Step 2: default to "the risk is real", say what is well reasoned, never fabricate | decision rule | present | Pass 1 step 5: "Treat a claim as at risk unless the plan cites evidence for it. When a claim is well supported, say so and move it to What holds up." | default |
| Step 3: output title line with the plan in one line | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which claim to test first, since the user just named the plan when asking |  |
| Step 3: Top Kill-Assumptions, ranked, 3 to 5 at most | template section | present | Output `### Claims ranked` and "Rules: at most 5 claims" | default |
| Step 3: per claim, Claim / Fails if / Evidence this week / Kill criterion / Cheapest test | template section | present | Output `### Claims ranked` ("Claim" column) and `### Kill tests` ("Fails if / Evidence this week / Kill criterion / Cheapest test") | default |
| Step 3: What's Well-Reasoned section | template section | present | Output `### What holds up` | default |
| Step 3: What I Couldn't Assess section | template section | present | Output `### What I could not judge` | default |
| Step 4: offer to turn the top kill-assumption into an experiment this week | step | present | Output, last default line: "More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section." and On request: "Turn the top claim into an experiment: `/odeo:experiments`." | on request |
| Step 4: offer to run a pre-mortem to complement it | step | present | Output, last default line: "More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section." and On request: "Run the pre-mortem alone" (and Pass 2 runs it by default) | on request |
| Step 4: offer to rewrite the riskiest section of the plan | step | present | Output, last default line: "More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section." and On request: "rewrite the riskiest section of the plan" | on request |
| Note: lead with the ranking | decision rule | present | Output: `### Claims ranked` is the first section under `## Red team` | default |
| Note: five real kill-assumptions beat twenty generic risks, cut ruthlessly | decision rule | present | Pass 1: "Rules: at most 5 claims; specific to this plan, no generic risks." | default |
| Note: distinct from the pre-mortem | decision rule | present | Intro: "Two passes: a red-team that attacks the logic, and a pre-mortem that imagines failure and works backward" | default |
| Note: if the plan is strong, say so and name the one thing still worth checking | decision rule | present | Pass 1 step 5: "When a claim is well supported, say so"; Quality rules: "The top-ranked claim is the one to test this week (step 4); name it in the Top pick line." | default |
| Note: ask the user before adding a second model | decision rule | present | Output, On request: "print them only when the user asks, under `## Next steps`" | on request |

Primary method source: as in `critique-1.md` (Key Assumptions Check, "A Tradecraft
Primer", March 2009; assumptions check, assumptions review and devil's advocacy, UK "Red
Teaming Handbook", 3rd edition, June 2021), read 2026-11-03.
