<!-- run: after USR-030 fix of the on-request wording, sample-b, request "critique this PRD" -->
## Red team

Ranking rule: the top claim is the one with high impact if wrong, a plausible chance of being wrong, and a cheap test, so that is what to test this week.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members will install the app and join through a link, instead of telling the first person to keep using chat | High | High | Low |
| 2 | Households will move their one list into the app and stop using notes and chat | High | Medium | Low |
| 3 | 5,000 weekly active households in 6 months and 35 percent still active after 8 weeks are reachable | High | High | Medium |
| 4 | The MVP is minimal and fits 10 weeks with 3 engineers (live sync, offline sync and push notifications included) | Medium | High | Low |

### Kill tests

**1. Invited members will install and join**
- Strongest case: the inviter feels the pain (9 of 12 interviewees bought a duplicate), a link is one tap, and a flatmate who is nagged about duplicates has a reason to join.
- Fails if: fewer than 6 in 10 people who receive an invite link install the app and join within 7 days.
- Evidence this week: a clickable prototype or a simple shared-list stand-in sent as a link by 10 of the interviewed people to their actual flatmates or partner. Count who joins and how long it takes.
- Kill criterion: below 40 percent of invitees joining within 7 days, stop and rethink the model (for example a web view for invitees, which the PRD currently excludes) before building.
- Cheapest test: the 10-person invite run above, using a no-code shared list. Zero engineering.

**2. Households will switch from chat and notes**
- Strongest case: a shared list removes the cause of the duplicates, and the list is where the shopping happens, so it replaces chat for this purpose.
- Fails if: fewer than half of the interviewed households, given a shared list, still use it as the only list after 3 weeks.
- Evidence this week: ask the 12 interviewees what they tried before (shared notes apps, shared reminders lists) and why they stopped. The interviews show a problem, not willingness to switch.
- Kill criterion: if 8 or more of 12 already tried a shared list and went back to chat, the product has to answer why this time is different before any build.
- Cheapest test: follow-up calls with the 12 interviewees and a 3-week shared-list pilot with 5 of them.

**3. The metric targets are reachable**
- Strongest case: the household definition (2 members active in the same week) is stricter than plain downloads, so a number reached on it means real use.
- Fails if: the plan cannot name an acquisition channel that yields about 5,000 active households (roughly 15,000 to 20,000 installs at typical activation and invite drop-off) within 6 months, or if a single person with two accounts can satisfy the "2 members" rule.
- Evidence this week: the expected install source and cost per install, and a benchmark for 8-week retention in comparable utility apps. The PRD gives neither, and the 5,000 and 35 percent targets carry no cited basis.
- Kill criterion: if the cheapest credible channel cannot deliver the installs within the budget, or the beta (30 households) shows 4-week household activity under 20 percent, change the target or the plan.
- Cheapest test: write down the funnel math (installs, invite acceptance, household activation) and compare it with the budget. Then check whether two test accounts held by one person count as an active household.

**4. The MVP is minimal and fits 10 weeks**
- Strongest case: the scope already excludes multiple lists, costs, web and price tracking, and the remaining items are each standard.
- Fails if: the team's estimate for live sync plus offline sync with conflict handling (two people edit or tick the same item offline) exceeds 3 weeks, or if "a list you are about to shop from" cannot be defined without location tracking.
- Evidence this week: an engineering estimate of weeks 4 to 6 by the engineers who will build it, and a one-line definition of when the push notification fires.
- Kill criterion: if the estimate for sync and offline is over 4 weeks, cut offline mode or push notifications from the MVP, whichever the test in claim 1 and 2 shows matters less.
- Cheapest test: a half-day estimate session with the 3 engineers, with the offline conflict cases written out.

### What holds up
- The problem exists: 9 of 12 interviewed flatmates and couples bought a duplicate item in the past month. This is evidence from the plan itself. It is a small sample and only shows the pain, not urgency or willingness to switch (that is claim 2).
- The scope boundaries are clear and the out-of-scope list is credible: multiple lists, cost splitting, store integration and web are all things that would blow the 10 weeks.
- The target user is specific (2 to 5 people sharing one kitchen) and the metric definition requires more than one member, which fits the product's purpose.

### What I could not judge
- The acquisition budget and channels: the PRD names none.
- Whether the team has built offline sync before, which drives claim 4.
- The legal basis and privacy handling for member activity data (see the security pre-mortem), which needs someone who owns that for the company.
- Retention benchmarks for this category: I have none I can cite, so the 35 percent target is neither confirmed nor refuted.

## Pre-mortem
It is 6 months later and this shipped and failed. What happened?

1. **Invitees never joined, so households stayed at one user (most likely).** The first person installed, the others kept using chat, and no household reached 2 active members. Leading signal: in the 30-household beta, less than half of invited members join in the first week. Cheapest test now: the 10-person invite run in claim 1.
2. **People tried it for two weeks and went back to chat.** The list was no worse than chat but not better, and switching had a cost. Leading signal: the share of beta households with activity in week 3 compared with week 1, and the first item added by a second member. Cheapest test now: the 3-week pilot with 5 of the interviewees.
3. **The launch slipped or shipped with a weak sync.** Offline conflicts produced lost or duplicated items, which is exactly the problem the product promises to solve. Leading signal: by the end of week 6 the sync passes less than the agreed set of conflict cases. Cheapest test now: write the offline conflict cases and estimate them with the engineers.

## Security pre-mortem
This feature handles accounts, who lives with whom, shopping habits and push notifications, so this section applies. It is 6 months later and we had a leak through this. What was the hole?

1. **An invite link that stays valid and can be forwarded.** Someone outside the household joins and sees the list and who added what. Where the data lives: the household list and activity notes. Who can reach it: anyone holding the link. Design must include: invite links that expire, can be revoked, and ideally need approval by the household creator, with the link not guessable.
2. **Former members keep access.** A flatmate moves out or a couple splits, and nothing in the MVP lets anyone leave or be removed. They keep seeing the list and the "who added and who ticked off" notes, which show when people are home and shopping. Design must include: leave household and remove member in the MVP, with access ending at once and a clear rule for what happens to their entries.
3. **Notification and activity data leaks outside the household.** Push notifications show item names on lock screens, and the notification logic ("a list you are about to shop from") may need location data that is collected and stored without a clear need. Design must include: collecting no location at all in the MVP or a stated minimum, no personal data in logs, per-household authorization on every list request (so one household's id cannot be used to read another's), and a data export and delete path for members from the start.
