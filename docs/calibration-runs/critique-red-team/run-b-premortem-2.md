<!-- run: after USR-031 final wording, sample-b, request "critique this PRD" -->
## Red team
Ranking rule: the top claim is the one with high impact if wrong, a plausible chance of being wrong, and a low cost to test, so it is the one to test this week.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members install the app and join via the link, instead of asking the first person to keep using chat | High | High | Low |
| 2 | Households keep one list in the app and stop using notes and chat | High | Medium | Medium |
| 3 | 5,000 weekly active households in 6 months is reachable (and "2 members active in the same week" measures real value) | High | Medium | Low |
| 4 | Nobody already solves this well enough (why not keep using chat or a free shared-list feature in a notes or reminders app) | High | Medium | Low |
| 5 | Live sync, offline mode, notifications and beta fit in 10 weeks with 3 engineers and 1 designer | Medium | High | Medium |

Top pick this week: claim 1

### Kill tests
**Claim 1: invited members join**
- Strongest case: the invite is one tap on a link, the inviter has a reason to push (their partner or flatmate is the one who forgets items), and the 9 of 12 duplicate-purchase finding shows the pain is shared by both people, so the second person also gains.
- Fails if fewer than 4 in 10 invited second members open the link, install and add or tick one item within 7 days. (Proposed threshold, not from the PRD.)
- Evidence this week: invite-to-first-action rate from a hand-run test. Give 15 households (use the interviewees, 9 of whom had the duplicate problem) a prototype or a stand-in shared list with an invite link, and count second members who act within 7 days.
- Kill criterion: below 2 in 10 acting second members (proposed), stop building the MVP as an install-first app and test an invite flow that works without an install (for example a web view of the list) before any engineering starts; between 2 and 4 in 10, keep the plan but make the join step the first thing built and tested.
- Cheapest test: the 15-household invite test above, run with a clickable prototype and a manually synced list. No engineering needed.

**Claim 2: households keep one list in the app**
- Strongest case: once both people see ticks appear live in the shop, the app beats a chat thread, because chat has no "done" state and the list shows who bought what.
- Fails if fewer than half of the test households from claim 1 still use the list for their main weekly shop in week 3.
- Evidence this week: a 3-week diary check on the same 15 households (proposed), reading whether the shop list lives in the app or in chat.
- Kill criterion: below 4 in 15 households (proposed) still using it in week 3, stop and rework the habit loop (reminders, a reason to prefer the app over chat) before building more scope; the notification feature moves up or is redesigned.
- Cheapest test: extend the claim 1 test by two weeks; no extra recruiting.

**Claim 3: 5,000 weekly active households in 6 months**
- Strongest case: a household is a viral unit (every invite adds a user), the problem is universal for shared kitchens, and the definition requires two members, which filters out empty sign-ups.
- Fails if the plan cannot name an acquisition channel and a cost per household that reaches 5,000, or if the measured definition can be met without shared use. The PRD names no channel, no sign-up forecast and no baseline, and the target has no source.
- Evidence this week: a back-of-envelope funnel (sign-ups needed, given the 35 percent 8-week retention target and the claim 1 join rate) and the channel that supplies them. Check whether one person using two devices or adding and ticking items alone with a second dummy member could count as active.
- Kill criterion: if the funnel needs more than the team can plausibly acquire in 6 months (proposed: more than 3x the sign-ups the channel can show in a pilot), lower the target or change the launch market before committing the date.
- Cheapest test: a one-page funnel calculation plus a read of how "active" is computed.

**Claim 4: the alternatives are not good enough**
- Strongest case: chat and phone notes have no done state and no live view, and the interviews show 9 of 12 still bought duplicates despite them.
- Fails if more than 3 in 10 interviewees already share a list in an existing app and still report duplicates for a reason this MVP does not fix. Whether established shared-list apps are free and widely used is a market fact: unverified here, check with `/odeo:research`.
- Evidence this week: re-ask the 12 interviewees which tool they use today and why a shared list in it did or did not work; list 3 competing shared-list products and their free features.
- Kill criterion: if most interviewees already use a shared list that works for them, stop and change the proposition to what those tools lack, or do not build.
- Cheapest test: 12 short follow-up messages plus a 1-hour competitor scan.

**Claim 5: 10 weeks is enough**
- Strongest case: the scope is cut hard (one list, no costs, no web), and sync is a solved problem on managed backends.
- Fails if offline sync with conflict handling (two people edit or delete the same item offline) cannot be built, tested and shown in the 3 weeks given to list, live sync and offline together, or if there is no slack after the beta.
- Evidence this week: an engineering estimate of offline sync conflict rules and one sync spike.
- Kill criterion: if engineering estimates offline sync alone at more than 2 of the 3 weeks (proposed), move offline mode out of the MVP or move the beta date.
- Cheapest test: a 2-day sync spike and a written estimate.

### What holds up
- The problem itself is evidenced: 9 of 12 interviewees bought a duplicate in the past month. The sample is small and shows pain, not willingness to switch, which is why claims 2 and 4 stay open.
- Poor phone signal in supermarkets is already handled by the plan: it names an offline mode and puts it in scope, so this claim moves here and gets no kill test (its build cost is covered by claim 5).
- Scope is mostly minimal: multiple lists, cost splitting and web are explicitly out.

### What I could not judge
- Whether 5,000 households is large or small for the market: the PRD gives no market size and I have no verified source for it.
- Whether the engineers can build sync in the time: I can only flag the risk, not size it.
- Which competing apps exist today and how good they are: unverified without `/odeo:research`.

## Pre-mortem
> It is 6 months later, this shipped, and it failed.

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | Second members do not join, so households never count as active and the main metric stays near zero | High | High | Run the invite test (claim 1), and make the join step work with one tap and no sign-up form; decide on an install-free path if it fails | product | before the build starts (before week 1) |
| 2 | Offline edits collide (the same item edited, ticked or deleted by two people offline), producing lost or duplicated items, which is the exact pain the product promises to remove | Medium | High | Define conflict rules in writing (for example "tick wins over delete"), test with two phones in airplane mode | engineering | before beta |
| 3 | Invite links work as open doors: anyone with a forwarded link joins the household and sees names, items and who shops when | Medium | High | Expiring and revocable links, owner approval or a member limit, a way to remove a member | engineering | before beta |

### Fix within 30 days
| # | Risk | Likelihood | Impact | Response | Owner role |
|---|------|------------|--------|----------|------------|
| 1 | The "about to shop from" notification has no defined trigger, so it fires too often or never and people switch notifications off | Medium | Medium | Define the trigger (for example, a member taps "I am shopping now"), then measure opt-outs | product |
| 2 | The household owner leaves or deletes the account and the household breaks | Medium | Medium | Transfer ownership, keep the list for remaining members | engineering |

### Watch
- Retention below the 8-week target: trigger is week-4 active households below half of week-1 active households in the beta, which moves it to must fix.
- Store review delay for the release: trigger is no approval answer 5 working days after submission, which moves the release date risk up.

### Overblown worries
- "Phone signal in supermarkets will break live sync": overblown because the plan already includes offline mode with sync. It becomes real if the offline conflict rules (must fix 2) are not built or tested.
- "Costs of staples need splitting, so households will leave without it": overblown for the MVP because the problem evidence is about duplicates and forgotten items, not money. It becomes real if the flatmate interviews show cost splitting as the reason for sharing a list.

### Unspoken worries
- The 5,000 target has no stated source and no channel. How to check: write the funnel (claim 3) before the date is committed. How to raise it: ask the sponsor plainly "what makes 5,000 the number" in the next review.
- The 10 weeks leave no slack: the beta of 30 households is in the last 2 weeks, so any finding from it lands after the plan ends. How to check: ask engineering which week is the first with a working two-phone demo. How to raise it: propose a first two-person test in week 4, not week 9.

Launch call: phase, release to the 30 beta households first because the join rate (claim 1) and offline conflicts (must fix 2) are unproven; widen only when the invite test and the two-phone offline test pass.

## Security pre-mortem
The feature handles accounts, household membership and a record of who bought what and when, which is personal data.
1. **Link forwarding or guessing.** Hole: a forwarded or guessed invite link lets a stranger into a household. Design must include: long random single-purpose tokens, expiry, revocation, owner approval and a member limit.
2. **Activity notes expose behaviour.** Hole: "who added and who ticked" shows presence and habits, and a removed member or ex-flatmate still sees it. Design must include: access removed at once when a member leaves, and the household list never readable without current membership checked on the server for every list request.
3. **Data stays after leaving or deleting.** Hole: names and activity stay after an account is deleted, which fails basic GDPR duties. Design must include: export and deletion of a member's data, anonymizing their name in the history, and no personal data in logs.

More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section, test scenarios for the riskiest areas, a launch checklist.
