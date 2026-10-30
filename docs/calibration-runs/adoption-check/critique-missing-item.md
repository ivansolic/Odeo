---
skill: critique
source_skill: pm-execution/skills/pre-mortem
source_commit: 07b34f6
---

# Depth checklist: critique, adopted from the pre-mortem source skill

| item | kind | status | where in the Odeo skill, or the exclusion reason | shown |
|---|---|---|---|---|
| Gather the PRD: read it thoroughly (product, market, assumptions, timeline) | step | excluded | already covered by an existing Odeo rule or step: "After a `/odeo:prd` or `/odeo:strategy` draft, before committing to build." (When to use) and "Attack the strongest version, not a strawman." (Quality rules) |  |
| Gather the PRD: web search for competitive landscape or market conditions when relevant | step | excluded | adding length without changing any decision the user makes; leaves unchanged the decision whether to run `/odeo:research` for market facts |  |
| Think step by step: imagine the launch, then imagine it fails | step | present | Pass 2, Pre-mortem: "It's 6 months later and this shipped and failed. What happened?" | default |
| Think step by step: the launch is in 14 days | decision rule | excluded | already covered by an existing Odeo rule or step: "It's 6 months later and this shipped and failed." (Pass 2); the horizon is the user's, not fixed |  |
| Think step by step: prompts what we missed or did not execute well | step | present | Pass 2, Pre-mortem: "What happened?" with the ranked failure modes | default |
| Think step by step: prompts what we were overconfident about | step | present | Pass 1, Red-team: "The assumptions: which single assumption, if wrong, collapses the whole thing?" | default |
| Categorize risks as Tigers (real problems, evidence-based, require action) | decision rule | excluded | already covered by an existing Odeo rule or step: "List the **top 3 failure modes** ranked by likelihood" (Pass 2); the ranking makes the real risks the listed ones |  |
| Categorize risks as Paper Tigers (overblown concerns, documented to align stakeholders) | decision rule | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which three failure modes to test first |  |
| Categorize risks as Elephants (unspoken worries nobody validates, to investigate) | decision rule | excluded | already covered by an existing Odeo rule or step: "Name the **one assumption** that would sink it; that's where to focus." (Quality rules) |  |
| Classify Tigers by urgency: Launch-Blocking (must be solved before launch), with examples | decision rule | excluded | adding length without changing any decision the user makes; leaves unchanged the decision whether to revise the PRD before building |  |
| Classify Tigers by urgency: Fast-Follow (within 30 days after launch), with examples | decision rule | excluded | a number asked for without a source: the 30-day window has no evidence behind it |  |
| Classify Tigers by urgency: Track (monitor after launch), with examples | decision rule | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which follow-ups go into `.claude/tasks/todo.md` |  |
| Action plans for every Launch-Blocking Tiger: describe the risk clearly | step | present | Pass 2, Pre-mortem: each failure mode listed with what happened | default |
| Action plans: suggest a concrete mitigation | step | present | Pass 2, Pre-mortem: "the cheapest way to test it now" | default |
| Action plans: identify the best owner (function or person) | step | excluded | a person credit or author link: a template field for a named person; the template would carry a person's name |  |
| Action plans: set a decision or completion date | step | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which follow-ups are written to `.claude/tasks/todo.md` ("as a checkable item, with a one-line why") |  |
| Output template: heading "Pre-Mortem Analysis: [Product Name]" | template section | excluded | already covered by an existing Odeo rule or step: "Findings + ranked failure modes + leading signals, in chat." (Output) |  |
| Output template: section Tigers (Real Risks), each with category and mitigation plan | template section | present | Pass 2, Pre-mortem: top 3 failure modes with a leading signal and the cheapest test | default |
| Output template: section Paper Tigers (Overblown Concerns), each with why it is not a true risk | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which three failure modes to test first |  |
| Output template: section Elephants (Unspoken Worries), each with an investigation approach | template section | excluded | already covered by an existing Odeo rule or step: "Name the **one assumption** that would sink it; that's where to focus." (Quality rules) |  |
| Output template: section Action Plans for Launch-Blocking Tigers | template section | excluded | adding length without changing any decision the user makes; leaves unchanged the decision whether to revise the PRD before building |  |
| Action plan table column: Risk | table column | present | Pass 2, Pre-mortem: the failure mode named | default |
| Action plan table column: Mitigation | table column | present | Pass 2, Pre-mortem: "the cheapest way to test it now" | default |
| Action plan table column: Owner | table column | excluded | a person credit or author link: the column holds a person's name |  |
| Action plan table column: Due Date | table column | excluded | adding length without changing any decision the user makes; leaves unchanged the decision which follow-ups are written to `.claude/tasks/todo.md` |  |
| Save the output as PreMortem-[product-name]-[date].md | step | excluded | already covered by an existing Odeo rule or step: "goes into `.claude/tasks/todo.md` as a checkable item, with a one-line why" (Output); the findings are revised into the PRD |  |
| Note: be honest and constructive, improve launch readiness, do not assign blame | decision rule | excluded | already covered by an existing Odeo rule or step: "Be genuinely adversarial; a soft critique is useless." (Quality rules) |  |
| Note: involve cross-functional perspectives (engineering, design, go-to-market) | decision rule | excluded | adding length without changing any decision the user makes; leaves unchanged the decision who reads the critique |  |
| Note: revisit the pre-mortem 2-3 weeks before launch | decision rule | excluded | already covered by an existing Odeo rule or step: "Re-run if the revisions are large." (When to use) |  |
| Further reading: two external articles by the source author | step | excluded | a person credit or author link: the links point to the author's own publication |  |

Method source checked against: the classic pre-mortem technique, as named in the skill ("the classic pre-mortem technique").
