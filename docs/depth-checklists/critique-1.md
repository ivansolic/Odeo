---
skill: critique
source_skill: pm-execution/skills/strategy-red-team
source_commit: 07b34f6
---

# Depth checklist: critique, adopted from the red-team source skill

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|
| Step 1: extract every claim the plan asserts (user, market, constraint, mechanism, timeline) | step | present | Pass 1 step 1: "List what the plan takes for granted: who the user is, how the market behaves, what limits the team, why the mechanism works, how long it takes." | default |
| Step 1: keep only load-bearing claims, drop cosmetic ones | decision rule | present | Pass 1 step 1: "Keep only the claims the plan stands on: if the claim is false, the decision changes. Drop cosmetic ones (style, naming, wording) and do not list them at all." | default |
| Step 2: state the strongest version of each claim, then attack that version | step | present | Pass 1 step 2: "write the strongest case for it, then attack that case, never a weaker version." | default |
| Step 3: write each failure mode as "Fails if" with a concrete, falsifiable condition | step | present | Pass 1 step 3: "Write each failure as "Fails if ..." with a concrete, checkable condition", with a good and a bad example | default |
| Step 4: rank by impact if wrong, likelihood wrong and cheapness to test | decision rule | present | Pass 1 step 4: "Rank the claims on three measures, each high / medium / low and each shown per claim: impact if wrong, likelihood it is wrong, cost to test." | default |
| Step 4: the top of the ranking is what to test this week; surface the ranking first | decision rule | present | Pass 1 step 4: "Top = high impact, plausibly wrong, cheap to test: that is what to test this week." Output: `### Claims ranked` is the first section under `## Red team` | default |
| Step 5: default to "the risk is real" unless the plan cites evidence against it | decision rule | present | Pass 1 step 5: "Treat a claim as at risk unless the plan cites evidence for it." | default |
| Step 5: say plainly when a claim is well reasoned; never invent a weakness | decision rule | present | Pass 1 step 5: "Do not invent doubt. ... When a claim is well supported, say so and move it to What holds up." | default |
| Step 6: per surviving claim, Fails if | template section | present | Pass 1 step 6 and Output `### Kill tests`: "Fails if" | default |
| Step 6: per surviving claim, evidence to get this week | template section | present | Pass 1 step 6: "Evidence this week (which number, report or customer call would settle it)" | default |
| Step 6: per surviving claim, kill criterion | template section | present | Pass 1 step 6: "the Kill criterion is the decision: the result on this week's evidence at which you stop or change the plan, and what changes." | default |
| Step 6: per surviving claim, cheapest test | template section | present | Pass 1 step 6: "Cheapest test" | default |
| Step 7: optional second model, only when the user asks | step | present | Output, last default line: "More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section." and On request: "A second model's opinion: `/odeo:second-opinion-pm`." | on request |
| Step 8: output title line naming the plan in one line | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which claim to test first, since the user just named the plan when asking |  |
| Step 8: Top Kill-Assumptions, ranked, 3 to 5 at most | template section | present | Output `### Claims ranked` table and "Rules: at most 5 claims" | default |
| Step 8: Claim field per kill-assumption | template section | present | Output `### Claims ranked`: column "Claim" | default |
| Step 8: What's Well-Reasoned section | template section | present | Output `### What holds up` | default |
| Step 8: What I Couldn't Assess section | template section | present | Output `### What I could not judge` | default |
| Context: a red-team is not a pre-mortem (attacks live assumptions now) | decision rule | present | Intro: "Two passes: a red-team that attacks the logic, and a pre-mortem that imagines failure and works backward" | default |
| Context: five real kill-assumptions beat twenty generic risks | decision rule | present | Pass 1: "Rules: at most 5 claims; specific to this plan, no generic risks." | default |
| Note: no strawmanning | decision rule | present | Pass 1 step 2: "never a weaker version"; Quality rules: "Attack the strongest version, not a strawman." | default |
| Note: no generic risk lists, every item specific to this plan | decision rule | present | Pass 1: "specific to this plan, no generic risks." | default |
| Note: no fabrication, if it is sound say so | decision rule | present | Pass 1 step 5: "Do not invent doubt." | default |
| Note: rank ruthlessly, the cheapest high-impact test is the point | decision rule | present | Pass 1 step 4 ranking rule; Quality rules: "The top-ranked claim is the one to test this week (step 4); name it in the Top pick line." | default |
| Note: end with what to do, not only what to fear | decision rule | present | Output `### Kill tests` (a test, evidence and threshold per claim) and "Route the follow-ups so they survive the session" | default |
| Further reading: three links to the author's articles | template section | excluded | a person credit or author link |  |

Primary method source: the red-team pass was checked against the Key Assumptions Check in
"A Tradecraft Primer: Structured Analytic Techniques for Improving Intelligence Analysis"
(US Government, March 2009, steps 1 to 4: keep only the assumptions that must be true for
the line to stand, and ask under what conditions each might not hold), and against the
assumptions check, assumptions review and devil's advocacy in the UK "Red Teaming
Handbook", 3rd edition (DCDC, June 2021: per assumption, the confidence in it and the
impact if it is invalid, rated supported, caveated or unsupported). Neither source covers
cost to test as a ranking measure or stating the strongest case before the attack; those
two come from the source skill alone. Read 2026-11-03 from
https://www.cia.gov/resources/csi/static/955180a45afe3f5013772c313b16face/Tradecraft-Primer-apr09.pdf
and
https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1027158/20210625-Red_Teaming_Handbook.pdf
