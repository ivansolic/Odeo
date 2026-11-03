---
skill: critique
source_skill: pm-execution/skills/pre-mortem
source_commit: 07b34f6
---

# Depth checklist: critique, adopted from the pre-mortem source skill

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|
| Step 1: read the PRD or plan thoroughly (product, market, assumptions, timeline) | step | present | Pass 1 step 1: "List what the plan takes for granted: who the user is, how the market behaves, what limits the team, why the mechanism works, how long it takes." Pass 2 runs on the same reading | default |
| Step 1: research the competitive landscape or market conditions when relevant | step | present | Pass 2 step 1: "A risk that rests on a market fact gets it checked with `/odeo:research` or marked unverified." | default |
| Step 2: imagine the product launches in 14 days | decision rule | excluded | already covered by an existing Odeo rule or step: Pass 2: "It's 6 months later and this shipped and failed. What happened?" Odeo critiques a PRD before building, so its framing looks back from after launch instead of counting down to it |  |
| Step 2: imagine it fails (no adoption, missed revenue, reputation hit) and ask what went wrong | step | present | Pass 2 step 1: "Imagine it shipped and failed, then look for causes in five areas: technical, users, business, operations, dependencies." | default |
| Step 2: ask what we missed or did not execute well | step | present | Pass 2 step 1: "Push past the obvious: the most dangerous risks are the ones nobody raises." | default |
| Step 2: ask what we were overconfident about | step | present | Pass 1 step 1 and step 5: the claims the plan takes for granted, each treated "as at risk unless the plan cites evidence for it" | default |
| Step 3: classify each failure as exactly one of three types | decision rule | present | Pass 2 step 2: "Put every risk in exactly one group." | default |
| Step 3: Tigers, real problems based on evidence, experience or clear logic, that require action | decision rule | present | Pass 2 step 2: "Real threat: there is evidence or clear logic for it." Action follows in step 3, every real threat gets a timing bucket | default |
| Step 3: Paper Tigers, overblown concerns not worth significant investment, documented to align stakeholders | decision rule | present | Pass 2 step 2: "Overblown worry: say why it is overblown and what would turn it into a real threat." Output `### Overblown worries` | default |
| Step 3: Elephants, unspoken concerns nobody validates, to investigate before launch | decision rule | present | Pass 2 step 2: "Unspoken worry: nobody is checking it, so say how to check it before launch and how to raise it with the team." | default |
| Step 4: Launch-Blocking, must be solved before launch | decision rule | present | Pass 2 step 3: "must fix before launch"; Output `### Must fix before launch` | default |
| Step 4: Fast-Follow, must be solved within 30 days after launch | decision rule | present | Pass 2 step 3: "fix within 30 days"; Output `### Fix within 30 days` | default |
| Step 4: Track, monitor after launch and solve if it becomes an issue | decision rule | present | Pass 2 step 3: "or watch. ... A watched threat names its trigger, the early signal that would move it up." | default |
| Step 4: an example for each urgency class | worked example | present | `skills/critique/example.md`, Pre-mortem part: one must-fix row, one 30-day row and one watched risk with its trigger | default |
| Step 5: for every launch-blocking risk, describe it clearly | template section | present | Output `### Must fix before launch`, column "Risk" | default |
| Step 5: a concrete mitigation action | template section | present | Pass 2 step 4: "a mitigation specific enough to assign"; column "Mitigation" | default |
| Step 5: the best owner (function or person) | template section | present | Pass 2 step 4: "an owner written as a role (product, engineering, support, legal), never a person's name"; column "Owner role". The person half is dropped because no adopted template has a field for a person's name (R24, R1) | default |
| Step 5: a decision or completion date | template section | present | Pass 2 step 4: ""by when" as a point in the plan (for example "before beta"), never an invented calendar date"; column "By when" | default |
| Step 6: output title naming the product | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which threats to fix before launch, since the user just named the plan when asking |  |
| Step 6: Tigers section, each with its category and mitigation plan | template section | present | Output `### Must fix before launch`, `### Fix within 30 days` and `### Watch` | default |
| Step 6: Paper Tigers section, each with why it is not a true risk | template section | present | Output `### Overblown worries` "(per worry: why it is overblown, what would make it real)" | default |
| Step 6: Elephants section, each with an investigation approach | template section | present | Output `### Unspoken worries` "(per worry: how to check it, how to raise it)" | default |
| Step 6: action plans for launch-blocking Tigers (risk, mitigation, owner, due date) | template section | present | Output `### Must fix before launch` table: "Risk / Mitigation / Owner role / By when" | default |
| Step 7: save the output as a dated markdown file | step | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which threats to fix, since the critique answers in chat and its follow-ups are routed to the task list ("Route the follow-ups so they survive the session") |  |
| Note: honest and constructive, improve readiness, not assign blame | decision rule | present | Pass 2 step 6: "No blame; the goal is readiness." | default |
| Note: default to Tiger when unsure | decision rule | present | Pass 2 step 2: "When unsure, call it a real threat." | default |
| Note: involve cross-functional perspectives (engineering, design, go-to-market) | decision rule | present | Pass 2 step 1: "look for causes in five areas: technical, users, business, operations, dependencies" | default |
| Note: revisit the pre-mortem 2 to 3 weeks before launch | decision rule | present | Pass 2 step 6: "Always end with the `Before launch:` line: re-run the pre-mortem on the must-fix items." Output: "Before launch: re-run the pre-mortem on must-fix <numbers>" The interval of 2 to 3 weeks is not carried over: it is a number given without a source | default |
| Further reading: two links to the author's articles | template section | excluded | a person credit or author link |  |

Primary method source: the pre-mortem pass was checked against "The Pre-Mortem Method",
written by the method's originator (Psychology Today, January 2021): the plan is
announced as a fiasco, each member writes the reasons it failed, the reasons are
collected into one list, the members assess each problem for likelihood, impact and ease
of prevention, and then name actions to address the items. The original 2007 Harvard
Business Review article is paywalled and was not read. The three-way sort into real,
overblown and unspoken worries and the three timing buckets are not in that source; they
come from the source skill alone. Read 2026-11-03 from
https://www.psychologytoday.com/ie/blog/seeing-what-others-dont/202101/the-pre-mortem-method
