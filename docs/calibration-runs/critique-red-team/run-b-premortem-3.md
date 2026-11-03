<!-- run: after USR-031 review round 4, sample-b, request "critique this PRD" -->
## Red team
Ranking rule: the claim to test first is the one that is costly if wrong, plausibly wrong, and cheap to test, so high impact, medium or high likelihood of being wrong, and low cost to test rank highest.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members will install the app and join through a link instead of asking the first person to keep using chat | High | High | Low |
| 2 | Households will keep one list in the app instead of going back to notes and chat | High | Medium | Medium |
| 3 | 5,000 weekly active households within 6 months is reachable | High | High | Medium |
| 4 | Live sync, offline mode, notifications and a beta fit in 10 weeks with 3 engineers | Medium | Medium | Low |
| 5 | The problem is real: people buy duplicates because they shop from separate lists | High | Low | Low |

Top pick this week: claim 1

### Kill tests

**Claim 1: invited members install the app and join**
- Strongest case: a link is the lowest-friction invite there is, everyone already has a phone, and the second member sees the benefit right away because the list is already filled.
- Fails if: fewer than 5 in 10 invited second members install and join within 2 days of getting the link (threshold is a proposal).
- Evidence this week: send a link to a clickable prototype to the second member in 10 of the 12 interviewed households and count who gets as far as joining. The PRD cites no evidence on this step, and the whole metric needs 2 members per household.
- Kill criterion: fewer than 3 in 10 join within 2 days (proposal): stop and change the plan so the invited person can join without installing first. That means web access, which is currently out of scope.
- Cheapest test: the prototype link above, sent by message. Half a day.

**Claim 2: households keep one list in the app**
- Strongest case: the duplicate purchases happen because lists are separate; one list that updates live removes the cause, and 9 of 12 interviewees felt the pain.
- Fails if: fewer than 4 in 10 pilot households stop using chat or notes for groceries after 2 weeks of a shared list (proposal).
- Evidence this week: the PRD never says why a shared note in an app people already have is not enough, and it cites no check of that alternative. Ask the 12 interviewees whether they have tried a shared notes list, and what happened.
- Kill criterion: if 5 or more of the 12 already run a shared note successfully (proposal), stop and rework the pitch around what a shared note cannot do, such as who ticked what or the in-shop notification.
- Cheapest test: 10 households use a shared note for 2 weeks, with a check-in at day 14. No build needed.

**Claim 3: 5,000 weekly active households in 6 months**
- Strongest case: every household invites others, so growth carries itself, and sharing a list is a natural word-of-mouth moment.
- Fails if: the plan names no channel with an estimated cost per active household that adds up to 5,000 within the budget.
- Evidence this week: the PRD has a target but no acquisition channel, no budget and no baseline. Ask the business owner for the channel and the budget behind the number.
- Kill criterion: no channel and budget named by the end of this week: treat 5,000 as a wish, not a target, and set one scaled to the channel before building.
- Cheapest test: a 30-minute conversation with whoever owns growth. A market claim about conversion rates is unverified here; check with `/odeo:research` if one is added.

**Claim 4: the timeline holds**
- Strongest case: the scope is small, accounts come first, and the one risky part, sync, has 3 weeks.
- Fails if: an engineering spike puts live sync plus offline conflict handling above 3 weeks (proposal).
- Evidence this week: no estimate is cited in the PRD. A 2-day spike on two phones editing the same list offline settles it.
- Kill criterion: spike says more than 4 weeks (proposal): drop offline mode from the first release or move the beta, and say which.
- Cheapest test: the spike above.

### What holds up
- Claim 5, the problem: the PRD cites 12 interviews with 9 duplicate purchases in the past month. That is a small sample and says nothing about how much it hurts, but it is real evidence for the problem, so it gets no kill test.
- The outcome metric is defined by what members do (2 members adding or ticking items in one week), not by sign-ups. That is harder to game than downloads.
- Scope is clearly bounded: costs, recipes, prices and multiple lists are out of scope.

### What I could not judge
- Engineering effort for sync and offline: needs an engineer's estimate.
- Acquisition cost and conversion: no data in the PRD, and I have no verified source for them.
- App store review time and push permission rates: not checked, so any number I would give is unverified.

## Pre-mortem
It's 6 months later and the app shipped and failed. This is what happened, without blame.

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | The second member never joins, so the household is never active and the metric never counts it. The invite needs an install and an account, while the PRD says "without a lengthy sign-up" and weeks 1 to 3 build accounts first. | High | High | Run the invite test from claim 1, set a join target from it, and design the join step so it asks for a name only. | Product | Before the account work is signed off (week 3) |
| 2 | Offline edits collide: two people tick or add the same item in the shop with no signal, and the list shows a duplicate or loses a tick. That breaks the one promise of the product. | Medium | High | Write down the conflict rule (for example, a tick always wins, an add merges by item name), then test with two phones in airplane mode. | Engineering | Before beta |

### Fix within 30 days
None. Everything else that is real either blocks launch or is a watch item.

### Watch
- **Retention falls after the first month.** Households start well because of the invite, then drift back to chat. Trigger (proposal): in the beta, fewer than 1 in 3 of the 30 households is still active in week 4, which is below the 35 percent 8-week target before the 8 weeks have even passed.

### Overblown worries
- **Poor phone signal inside supermarkets.** Overblown because offline mode is already in scope and syncs on return. It becomes real if the beta shows more than 1 in 10 shop trips ending with a lost or duplicate item (proposal), which is the same signal as must-fix 2.
- **Scope creep toward multiple lists or cost splitting.** Overblown because both are explicitly out of scope and no source in the PRD pushes for them. It becomes real if 3 or more beta households ask for the same extra feature unprompted (proposal).

### Unspoken worries
- **Moving out or leaving a household.** Nobody covers what happens when a flatmate leaves: they still see the list and who bought what, and the creator may be the only person who can remove anyone. Check: walk through the move-out case with the designer using the current scope and see what is missing. Raise: bring it to the next planning meeting as a missing scenario, not as a criticism of the scope.
- **The store release has no buffer.** The beta and the store release share weeks 9 and 10. Nobody has checked how long a store review takes or what happens if the first review is rejected (not verified here; check with `/odeo:research`). Raise: ask engineering to add a buffer week or move the beta start earlier.
- **The metric can be met without replacing chat.** A couple that each tick one item per week counts as active, even if they still plan shopping in chat. Check: compare, in the beta, the count of active households against the count that add 3 or more items in a week. Raise: ask the analytics owner whether to add a second activity level before the 5,000 target is fixed.

Launch call: phase. Release first to the 30-household beta only, because both must-fix risks decide whether a household ever becomes active, and the PRD has no evidence on either. Open wider only after must-fix 1 and 2 pass their tests.
Before launch: re-run the pre-mortem on must-fix 1, 2

## Security pre-mortem
This feature touches accounts, names, who-bought-what history and invite links, so it is sensitive. It's 6 months later and we had a leak. The three most likely holes:

1. **A forwarded or guessed invite link.** Anyone holding the link joins the household and sees the list and activity. The design must include: long random link tokens, an expiry, a way to revoke a link, a visible member list so the household notices a stranger, and rate limits on joining.
2. **A former member who never lost access.** Nothing in scope lets anyone leave or be removed, so an ex-flatmate keeps seeing the household for as long as their session lives. The design must include leave and remove-member actions that end that person's access and sync immediately.
3. **One household reading another's list.** A list identifier that is guessable, or a server that checks only "is logged in", would let a user read other households' lists and activity notes. Push notifications could also show list items on a lock screen. The design must include a server-side check that the user belongs to this household on every list and sync request, notification text that can be hidden, and a way for a user to export and delete their data.

More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section, test scenarios for the riskiest areas, a launch checklist.
