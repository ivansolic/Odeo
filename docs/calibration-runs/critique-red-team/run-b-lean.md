<!-- run: after USR-030, sample-b, request "critique this PRD" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members will install the app and join through a link, instead of telling the first person to keep using chat | High | High | Low |
| 2 | Households will move their one list into the app and keep it there, rather than drifting back to notes and chat | High | High | Medium |
| 3 | 5,000 weekly active households within 6 months will be reached, with no stated way of reaching them | High | High | Medium |
| 4 | The MVP, with live sync, offline sync, activity notes and "about to shop" notifications, fits 10 weeks and 3 engineers, including beta and store release | Medium | High | Low |

Top pick this week: claim 1. The outcome metric counts a household only when at least 2 members are active, so every household that fails to bring in a second person counts as zero.

### Kill tests
**1. Invited members install the app and join.**
Strongest case: the person who sets up the household is motivated by the duplicate purchases, and a link in the group chat they already use is the lowest-friction invite possible. The invitee only has to tap once.
- Fails if: fewer than 6 in 10 invited second members install the app and make their first edit within 7 days of the invite.
- Evidence this week: take 10 of the 12 interviewed households and ask the person who would set it up to send a link to a test build (or a clickable prototype) to the other member. Count who installs and adds one item.
- Kill criterion: under 50 percent of invited members complete first use within 7 days in the beta. Then the invite flow, not the list, is the product, and the plan changes (for example a web-based join for invitees, which is currently out of scope).
- Cheapest test: the 10-household prototype test above; no backend needed.

**2. Households move the list into the app and stay.**
Strongest case: 9 of 12 interviewees had bought a duplicate item in the past month, so the pain is frequent, and a shared live list removes it directly.
- Fails if: fewer than half of the households that adopt the app still add items every week in week 4, because the habit they already have (chat, notes) costs nothing and works well enough.
- Evidence this week: ask the 9 households with duplicates how they would have prevented it with what they already own (a shared note, a chat message), and whether any already tried a shared list app and stopped. The PRD names no existing shared-list apps and no reason people dropped them.
- Kill criterion: fewer than 35 percent of beta households active in week 8 (the PRD's own secondary target, used here as the stop line); or 3 or more of 9 interviewees say a shared note already solves it.
- Cheapest test: the follow-up calls, plus a 2-week test where 5 households use a shared note and report duplicates, as the baseline the app must beat.

**3. 5,000 weekly active households in 6 months.**
Strongest case: household products spread by invite, so each household can bring a second one (flatmates, relatives) without paid acquisition.
- Fails if: each active household brings in fewer than 0.3 new households within 8 weeks, so organic growth alone cannot reach 5,000 and the plan has no paid channel or budget.
- Evidence this week: the PRD has no acquisition channel, no budget and no invite-to-new-household rate. Write down the channel and the budget, and compare with a cost per active household from any comparable app.
- Kill criterion: the beta shows a growth factor under 0.3 and no channel in the plan can be funded to the 5,000 target; then change the target or fund the channel before building.
- Cheapest test: ask the 30 beta households how many other households they told about it in 4 weeks; no code.

**4. The MVP fits 10 weeks.**
Strongest case: one list, one role and no web version is a narrow scope, and 3 engineers plus a designer is a reasonable team for it.
- Fails if: the offline mode with conflict handling (two people edit the same item while offline) is not working by the end of week 6, or if the store review and the 30-household beta cannot fit in weeks 9 to 10 together.
- Evidence this week: ask the engineers for a spike estimate of offline sync with conflict resolution, and check the current store review time for a new app.
- Kill criterion: the spike says offline sync alone needs more than 3 weeks; then cut offline mode or the "about to shop" notification, which the PRD does not define (it does not say how the app knows the user is about to shop).
- Cheapest test: a 2-day spike on offline sync and a written definition of the notification trigger.

### What holds up
**The problem exists.** The PRD cites 12 interviews with flatmates and couples, 9 of whom bought a duplicate item in the past month. That is stated evidence, so it is not treated as at risk. Limit: it is a small sample and shows the pain happens, not that people will change habits to fix it (that is claim 2).

**Signal in the shop.** The assumption is hedged in the plan itself: offline use with later sync is in scope, so the plan does not depend on good signal. The remaining risk is the cost of building offline mode, which is in claim 4.

### What I could not judge
Whether the market already has a free product that does this well. The PRD names no competitor, so I cannot rank "why not use an existing app" against the other claims. Get it from `/odeo:research` before the next version.

## Pre-mortem
It is 6 months later, the app shipped and failed. What happened, ranked by likelihood:

1. **Only the person who set up the household ever used it.** The second member never installed it, so no household counted as active and the metric stayed near zero.
   - Leading signal: in the beta, fewer than half of invites lead to a first edit within a week.
   - Cheapest test now: the 10-household prototype test in claim 1.
2. **Households tried it for two weeks and went back to chat.** Adding items to the app took more steps than typing a message, and nothing made the app better than the habit.
   - Leading signal: items added per household fall by more than half between week 1 and week 4 of the beta.
   - Cheapest test now: 5 households on a shared note for 2 weeks as the baseline.
3. **The launch slipped and the growth never came.** Offline sync took twice the estimate, beta and store release were squeezed, and with no acquisition plan the launch reached few households.
   - Leading signal: offline sync is not demoable at the end of week 5, or no named channel has an owner by week 3.
   - Cheapest test now: the 2-day offline spike and a one-page acquisition plan.

## Security pre-mortem
This feature handles accounts, member names, who bought what and when, push notification addresses, and invite links, so it counts as sensitive. It is 6 months later and we had a leak through this. What was the hole?

1. **A leaked or guessable invite link let a stranger join a household.** The link in a group chat gets forwarded, or the token is short, and the stranger sees the lists and the names of all members.
   - Design must include: long random single-purpose tokens, an expiry, a way to revoke the link, owner approval of new members or a member limit, and rate limiting on the join endpoint.
2. **A removed flatmate kept access.** The MVP scope has no way to remove a member or leave a household, so after a move-out the former member still sees the list and the activity notes (who is home, when they shop).
   - Design must include: remove member and leave household in the MVP, with access and push notifications cut at once, and a server-side check on every request that the user is currently a member of that specific household (object-level access, not only "logged in").
3. **Activity notes and notification data exposed personal habits.** The activity notes and push notifications record who did what and when. Logs, notification payloads or analytics could carry names and item names, and an account or household could not be exported or fully deleted.
   - Design must include: no names or item text in logs or push payloads beyond what the user must see, a retention period for activity notes, account deletion and data export, and encryption in transit and at rest.

On request: a second model's opinion (`/odeo:second-opinion-pm`), turn claim 1 into an experiment (`/odeo:experiments`), or rewrite the riskiest section of the PRD.
