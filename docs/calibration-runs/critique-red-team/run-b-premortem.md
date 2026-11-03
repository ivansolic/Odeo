<!-- run: after USR-031, sample-b, request "critique this PRD" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members will install the app and accept a link invite, instead of telling the first person to keep using chat | High | High | Low |
| 2 | Households will move to one list in the app and stay there, instead of returning to notes and chat | High | High | Medium |
| 3 | 5,000 weekly active households within 6 months is reachable (and 35 percent still active after 8 weeks) | High | High | Medium |
| 4 | Live sync plus offline sync plus push notifications fit in 10 weeks with 3 engineers | Medium | Medium | Low |
| 5 | The duplicate-buying problem is real | High | Low | Low |

Top pick this week: claim 1.

### Kill tests
**1. Invited members install the app and accept the invite.**
Strongest case: the invitee is a partner or flatmate who is told to join by someone they
live with, the link is one tap, and the pain (buying milk twice) is felt by both people.
- Fails if: fewer than 6 in 10 people invited by a household creator install the app and
  join within 7 days, or fewer than 2 in 3 of those who open the link finish joining.
- Evidence this week: ask 10 of the 12 interviewed flatmates and couples one question,
  "If your housemate sent you a link to install a shared list app, would you, and what
  do you do today when they ask you to install something?" Then send 10 real people a
  link to a clickable mock-up that stops at a "join" screen and count who gets through.
- Kill criterion (proposal): fewer than 6 of the 10 get through the mock-up join screen.
  Then the plan changes: the invitee must be able to use the list without installing
  (a web view from the link), which the PRD currently puts out of scope.
- Cheapest test: the 10 calls first, the link mock-up second, no code.

**2. Households move to one list and stay there.**
Strongest case: 9 of 12 interviewees already feel the cost of split lists, and a shared
list removes the question "did you already buy it?", which chat never answers.
- Fails if: fewer than half of interviewees who tried a shared list for 2 weeks (any
  existing shared-list tool) were still using it in week 3.
- Evidence this week: ask the 9 who bought duplicates which shared tool (a shared notes
  app, a shared list in a reminders app, a dedicated list app) they tried, and why they
  stopped. The PRD names no existing alternative, so this is the missing evidence.
- Kill criterion (proposal): 6 or more of the 9 tried a shared tool and dropped it for a
  reason this MVP does not fix. Then stop, and decide what the app does that those
  tools do not before building.
- Cheapest test: the 9 calls, then a 2 week concierge pilot with 5 households using a
  shared list in a tool they already have, to measure whether 2 members stay active.

**3. 5,000 weekly active households in 6 months.**
Strongest case: household products spread inside a home by invite, so each creator brings
1 to 4 more users, and the target is small next to the number of shared flats and families.
- Fails if: the plan cannot name a channel that brings in 1,000 new households per month
  at the cost per household the team can pay, or the chance a new household reaches
  "2 members active in one week" is below 30 percent.
- Evidence this week: write the funnel on one page (visits, installs, household created,
  second member joined, both active), fill each step with a benchmark or mark it unverified
  (I have none from the plan), and compare it to the budget. The 35 percent 8-week
  retention target also has no baseline in the plan.
- Kill criterion (proposal): the funnel needs more than 3 times the households the closed
  beta of 30 can show at the second-member step. Then cut the 6-month target or fund a
  channel before build starts.
- Cheapest test: the funnel page this week; the 30-household beta measures the second-member
  step, but only after the build is done, so it cannot be the first test.

**4. The scope fits in 10 weeks.**
Strongest case: the sequence is sensible (accounts first, sync mid, notifications last),
and push is the last item, so it can be dropped without breaking the rest.
- Fails if: a 3 day spike shows that two phones editing the same list offline, then
  reconnecting, loses or duplicates items in more than 1 in 20 trials.
- Evidence this week: a 3 day engineering spike on offline edit and merge, the riskiest
  piece because weeks 4 to 6 carry list, live sync and offline together.
- Kill criterion (proposal): the spike needs more than 2 weeks to reach 1 in 20 or better.
  Then drop offline from the MVP and ship live sync only, or delay the date.
- Cheapest test: the spike. The weeks 9 to 10 beta also has no slack: a defect found
  there pushes the store release.

### What holds up
**5. The problem is real.** The PRD cites 12 interviews, 9 of whom bought a duplicate in
the past month. That is evidence of the pain, not of the switch to a new app (claim 2),
so this claim stays in the ranked table and gets no kill test.

### What I could not judge
Whether 12 interviewees are representative: the PRD does not say how they were chosen,
and I cannot tell if they were friends of the team. I also cannot judge the market size
or competitor position: the PRD names no competitor and no market data. Get it from
`/odeo:research` before setting the 5,000 target.

## Pre-mortem

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | The second member never joins: the install plus account step loses the invitee, so most households have one active member and do not count as active | High | High | Let the invitee join from the link with the shortest possible step, and show the creator who has not joined and a one-tap reminder | Product | Before beta |
| 2 | Offline edits conflict on return to signal: items are lost, duplicated or ticked twice, and the shared list stops being trusted | Medium | High | Define a merge rule (a tick wins over an edit, deletes are kept for a short time), test it with two phones in airplane mode | Engineering | Before beta |
| 3 | An invite link is forwarded or leaked and a stranger joins a household and sees the list and who is home shopping | Medium | High | Links expire, a member approves new joins or the link is single use, and any member can remove someone | Engineering | Before beta |

### Fix within 30 days
| # | Risk | Response | Owner role |
|---|------|----------|------------|
| 4 | Push notifications annoy people ("someone added milk" at work) and they switch them off or delete the app | Add a per-household and per-person control, and cap pushes per day | Product |
| 5 | A person leaves the household (breakup, moving out) and still sees the list, or their activity notes stay visible | Add "leave household" and "remove member", and define what the notes show afterwards | Product |

### Watch
- Households with one member only. Trigger: during the beta, more than 40 percent (proposal)
  of households have no second member after 7 days.
- Sync delay in real shops. Trigger: more than 1 in 10 updates take longer than 10 seconds
  to reach the second phone in the beta logs.
- Beta too short to read retention. Trigger: the 8-week target cannot be measured from a
  beta that lasts under 2 weeks, so the first retention number arrives after store release.

### Overblown worries
- "Supermarket signal is too weak for live sync." Overblown: the PRD already includes
  offline use with later sync, so a weak signal slows updates and does not break the list.
  It becomes real if the merge rule in must-fix item 2 fails in testing.
- "Cost splitting is missing." Overblown for the MVP: it is out of scope on purpose, and
  the interviews cite duplicates and forgotten items, not money. It becomes real if
  beta users ask for it unprompted in more than a quarter of feedback.

### Unspoken worries
- Nobody owns the data for people in a household: names, who bought what, and when a person
  is in a shop. That is personal data about people who live together, and it must be
  deletable and exportable. Check: ask legal one question, "what must we offer a person who
  leaves a household or deletes their account?" Raise it at the next planning meeting
  as a launch blocker candidate.
- The team has no named owner of the invite and join experience, even though both the
  main metric and claim 1 depend on it. Check: ask who in the team owns the funnel from
  link to second member. Raise it as a question, not a criticism, at the next sync.
- The success metric counts a household as active when 2 members add or tick off an item,
  which can be met by one person pressing buttons on two phones in a test. Check: look at
  whether the 2 members have different devices in the beta data. Raise it when the
  metric definition is agreed.

Launch call: phase, release to the 30 beta households first and hold the store release,
because the second-member join (must-fix item 1) and the offline merge (item 2) decide whether
the product works at all and neither has been tested yet.

## Security pre-mortem
It is 6 months later and we had a leak through this. The data is household membership,
shopping habits, who added and ticked each item, device push tokens and account details.
Anyone who can join a household can read all of it.
1. **The invite link is the key.** Scenario: the link is shared in a group chat or
   guessed, and a stranger joins. The design must include long random unguessable links,
   expiry, single use or member approval, and a way to see and remove members.
2. **Another household's list is reachable.** Scenario: the server checks only that a
   person is logged in, not that they belong to that household, so changing an ID in a request
   shows another household's list. The design must check household membership on
   the server for every read and write on a list.
3. **A former member keeps access and data.** Scenario: a person leaves or is removed and
   still receives pushes, sync updates or sees notes about themselves. The design must
   revoke access and tokens when someone leaves, and support export and deletion of
   personal data (GDPR).

More on request: a second model's view, an experiment for the top claim, a rewrite of
the riskiest section, test scenarios for the riskiest areas, a launch checklist.
