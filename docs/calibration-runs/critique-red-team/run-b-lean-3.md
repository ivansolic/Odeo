<!-- run: after USR-030 review round 2, sample-b, request "critique this PRD" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Invited members install the app and sign up from a link, instead of telling the first person to keep using chat | High | High | Low |
| 2 | Households move their whole list into the app and stay, instead of going back to notes and chat | High | Medium | Medium |
| 3 | Households find the app on their own: 5,000 weekly active households in 6 months needs no stated acquisition plan | High | High | Medium |
| 4 | Live sync, offline mode with later sync, and notifications fit in weeks 4 to 8 with 3 engineers | High | Medium | Low |

Top pick this week: claim 1.

### Kill tests
**1. Invited members install the app from a link.**
Strongest case: the inviter is a partner or flatmate with a real reason to ask, the link
opens a short sign-up, and the shared list is useful from the first item. The invitee has
just watched the inviter use it at home, so asking costs one tap.
- Fails if: fewer than 6 in 10 invited members install and add or tick off one item within
  7 days of receiving the link.
- Evidence this week: invite 8 to 10 of the 12 interviewed households with a stand-in
  (a shared list in an existing app, or a clickable prototype) and count who installs
  and acts.
- Kill criterion (proposal): fewer than 4 of 10 invitees act within 7 days. Then stop the
  install-first plan and test a version where invitees can open and edit the list in a
  browser without installing, which today is out of scope ("Web or tablet versions").
- Cheapest test: the stand-in invites above, no build. The PRD only assumes link invites
  are accepted "without a lengthy sign-up"; it gives no number for acceptance.

**2. Households keep one list in the app and do not drift back to chat.**
Strongest case: 9 of 12 interviewed households bought a duplicate in the past month, so the
pain is frequent, and a list that shows who ticked what removes the exact failure they
describe. Chat has no tick-off state.
- Fails if: fewer than 5 in 10 trial households still use the list for their weekly shop
  in week 3 of a trial.
- Evidence this week: a 2-week trial with 6 of the interviewed households on a stand-in
  shared list, check at day 14 whether the chat or notes list is still being used for
  groceries.
- Kill criterion (proposal): 3 or more of 6 households are still keeping a parallel chat
  list at day 14. Then do not build the MVP as scoped; first find what chat does better
  (speed of adding, one-handed use) and change the add flow.
- Cheapest test: the trial above. The PRD cites interviews for the problem but none for
  the switch; the 8-week retention target of 35 percent has no stated basis.

**3. Households find the app without an acquisition plan.**
Strongest case: shared grocery pain is universal, every installed household brings in
2 to 5 people through invites, and each invite is a free ad. A loop like that could
carry the number alone.
- Fails if: the plan needs more than about 1 new household per existing household per
  6 months to reach 5,000, and the invite flow gives fewer than 0.5.
- Evidence this week: the PRD names no channel, no budget and no per-household invite
  rate. Work backward from 5,000: how many sign-ups per week that needs, and what
  share could come from invites at the rate measured in claim 1's test.
- Kill criterion (proposal): the backward calculation needs more than 3 times the weekly
  sign-ups that invites alone could give. Then either add a paid or partner channel
  to the plan with a budget, or lower the target and say why.
- Cheapest test: a one-page calculation this week, then a landing page with a waitlist
  for 14 days to measure sign-up intent per visitor.
- Also note: the metric counts a household active when 2 members add or tick off an
  item in a week, so one person adding and a partner ticking once is enough. It can be
  met by light use and says little about whether duplicates went down.

**4. The 10-week timeline fits sync, offline and notifications.**
Strongest case: sync services and offline libraries exist, the list is a simple data
shape (items with a name and a state), and the team holds weeks 4 to 6 for it with no
other work running.
- Fails if: a 5-day spike cannot show two phones editing the same item offline and
  merging correctly after reconnect.
- Evidence this week: a 5-day engineering spike on the offline merge case (same item
  edited or ticked on two phones with no signal), reported by the engineers.
- Kill criterion (proposal): the spike does not merge cleanly in 5 days. Then move
  offline use out of the MVP and ship live sync only, and say so before the beta.
- Cheapest test: the spike. The PRD hedges the signal question in its assumptions
  ("or an offline mode that syncs later is enough") but then puts both live sync and
  offline in the same 3 weeks.

### What holds up
**The problem happens.** The PRD cites 12 interviews and 9 households that bought a
duplicate in the past month. That is enough to treat the problem as real for the
people interviewed, so it is not ranked as a risk. Whether it is painful enough to
change habits is claim 2. The out-of-scope list (multiple lists, cost splitting, web
versions) is also clear and keeps the MVP small.

### What I could not judge
Whether 5,000 weekly active households or a 35 percent retention rate is a reasonable
target. The PRD gives no benchmark, market size or comparable app, and I cannot check one
from the document. Get it from `/odeo:research`, and treat both numbers as unverified
until then. I also could not tell how the app knows "a list you are about to shop from"
for the push notification: the PRD gives no trigger, so I could not rank it.

## Pre-mortem
"It's 6 months later and this shipped and failed. What happened?"

1. **Invitees never installed, so lists stayed single-user.** Most likely. Leading signal:
   in the closed beta, fewer than half of the invited members act within a week. Test now:
   claim 1's stand-in invites.
2. **People tried it for two weeks and went back to chat.** Leading signal: week-2 to
   week-4 drop in households where both members were active. Test now: the 2-week trial in
   claim 2, plus asking dropped households what they use instead.
3. **The beta passed with 30 hand-picked households and the launch had no way to grow.**
   Leading signal: sign-ups flat after release week, almost all from invites inside
   existing households. Test now: the backward calculation and waitlist in claim 3.

## Security pre-mortem
This feature holds accounts, household membership, who bought what and when (a pattern of
daily life), and invite links that grant access. It needs this.

"It's 6 months later and we had a leak through this. What was the hole?"

1. **A guessable or forwarded invite link lets a stranger join a household** and read its
   list and activity notes. Design must include: long random single-purpose links, an
   expiry, a way for the household owner to revoke a link and remove a member, and a
   visible notice to current members when someone joins.
2. **A member who left (a flatmate who moved out, a partner after a break-up) still sees
   the list and gets notifications.** Design must include: removal that ends access and
   push registration at once, and a check on every request that the person is a current
   member of this household, not only that they are logged in.
3. **Activity notes and device tokens are stored and logged with personal data.** Design
   must include: no names or item contents in logs, a way to export and delete an
   account and its notes, a retention period for activity history, and encryption in
   transit and for stored data.

More on request: a second model's view, an experiment for the top claim, a rewrite of
the riskiest section.
