<!-- run: after USR-030, sample-a, request "critique this PRD, go deeper and tell me what I could do next" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Late payment is what drives customers away, so faster payment lowers churn | High | Medium | Low |
| 2 | The switched-on accounts will show the feature's effect (and 40 percent will switch on within 60 days) | High | High | Low |
| 3 | Reminder emails reach the inbox and cause no deliverability work | High | Medium | Low |
| 4 | Clients will not find the reminders pushy, and none arrive after the client has paid | High | Medium | Low |
| 5 | One fixed schedule (3 days before due, due date, 7 days after) moves the median from 34 to 20 days | High | High | Low |

Top pick this week: claim 1. If it is false, even a perfect feature does not move the number the business case rests on.

### Kill tests
The thresholds below are my proposals (hypothesis), not facts about your product. Change them, but set them before you look at the data.

**1. Faster payment lowers churn.**
Strongest case: a business with 1 to 10 staff lives on cash flow, so a client who pays 3 weeks late is a real strain, and an owner under that strain cancels tools first.
- Fails if: accounts that cancelled in the last 6 months did not have a clearly higher share of overdue invoices in their last 90 days than comparable accounts that stayed, or fewer than 1 in 4 cancellation reasons mention late-paying clients. The PRD states "top reason customers leave" without citing where that comes from, so I treat it as unsupported. Late payment may be a symptom of a business that is already failing, which no reminder fixes.
- Evidence this week: the cancellation-reason export, plus one query comparing the overdue share in the last 90 days for cancelled versus retained accounts of the same size.
- Kill criterion: the overdue share differs by less than 10 percent relative between the two groups. Then drop churn as the justification and re-justify the feature on another outcome, or deprioritise it.
- Cheapest test: the query and reading 10 cancellation reasons. No build.

**2. Switched-on accounts show the effect.**
Strongest case: reminders are an opt-in feature, so measuring only accounts that use it is the honest population, and 90 days across many accounts is a large sample.
- Fails if: there is no comparison group. The outcome metric covers only accounts with reminders on, and owners who switch that on are the ones who already chase invoices. A fall from 34 to 20 days then partly reflects who opted in, not what the reminders did. It also fails if fewer than 20 percent of pilot owners switch it on within 14 days of seeing the switch, because the 40 percent assumption has no cited basis.
- Evidence this week: the median days-to-paid of the 10 pilot accounts over their last 90 days (are they already near the 34, or faster?), and the switch-on rate when the switch is shown to the pilot.
- Kill criterion: no comparison group in the rollout design (a ship-blocker for the measurement, not for the feature), or a pilot switch-on rate under 20 percent: then rethink the off-by-default choice before building more.
- Cheapest test: use the week 6 staged rollout as a random staggered start, so accounts not yet switched on form the comparison. Costs a rollout rule, not code.

**3. Emails reach the inbox.**
Strongest case: invoices already go from this domain and arrive, so authentication and reputation are in place.
- Fails if: reminders are a different kind of message. They are overdue-payment messages sent to third parties, and up to three extra emails per unpaid invoice go out from the same domain. If clients mark them as spam, the damage lands on the invoices as well, so the risk is not only that reminders fail but that invoices stop arriving.
- Evidence this week: the current bounce and spam-complaint rates for invoice emails from your email provider, and a seed-inbox test of one sample reminder at 3 large mailbox providers.
- Kill criterion: the pilot complaint rate is above the limit you agree with your email provider (a figure around 0.1 percent is often quoted, from memory and unverified, so confirm it), or more than 1 of 10 seed inboxes put the sample in spam. Then add a separate sending stream or sender setup before launch.
- Cheapest test: the seed-inbox send and the provider dashboard. No new code.

**4. Clients are not annoyed, and no reminder arrives after payment.**
Strongest case: the template is neutral, there are only three emails, the feature is off by default, and reminders stop when the invoice is paid.
- Fails if: the stop rule depends on the invoice being marked paid or a payment arriving through the tool. Small businesses are often paid by bank transfer and mark the invoice by hand, days later. A client who has already paid and still gets a reminder is the case that generates complaints to your customers. The reminder 3 days before the due date also goes to clients who were going to pay anyway.
- Evidence this week: the share of paid invoices that are marked paid by hand versus matched automatically, and the typical delay between the real payment and the mark.
- Kill criterion: more than 20 percent of paid invoices are marked by hand with a median delay over 2 days. Then the stop rule fails too often to ship as written: add an owner confirmation step or better payment matching first.
- Cheapest test: one query on how invoices become "paid", plus asking the 10 pilot owners whether any client has complained.

**5. The fixed schedule gets to 20 days.**
Strongest case: the due date is when most people act, and a nudge 3 days before, on, and 7 days after covers the whole window.
- Fails if: the target is counted from the send date but the schedule is counted from the due date, and the PRD gives no payment terms. With 30-day terms the median invoice is paid about 4 days late, so reaching 20 means paying 10 days before the due date, which no reminder in this schedule asks for. With 14-day terms the last reminder lands on day 21 and the worst payers get silence after that.
- Evidence this week: one query on the distribution of payment terms and on when invoices are paid relative to the due date (early, on time, 1 to 7 days late, more than 7 days late).
- Kill criterion: reaching 20 days would require more than a third of invoices to be paid before the first reminder is sent. Then the target and the schedule contradict each other: change the target (for example, measure the late invoices only) or the schedule.
- Cheapest test: the query. No build.

### What holds up
**The baseline.** The PRD gives a concrete starting number, a median of 34 days from send to payment, and a guardrail (no rise in monthly cancellation) that can be measured. I could not see the source of the 34, so confirm it is current, but it is stated and checkable rather than assumed.

**The MVP is tight.** The out-of-scope list fences off custom schedules, SMS, late fees and card subscriptions, and off by default respects clients. The weekly summary is not needed to measure the outcome and is the one cuttable item, but cutting it would not change the decision, so I do not rank it.

### What I could not judge
- Whether 6 weeks and 2 engineers is enough. The PRD gives no estimate basis, and paid-state detection (see claim 4) may be the hard part. An engineer who knows the payment code can say in an hour.
- Whether reminders beat what customers can already do, for example accounting tools or integrations that chase invoices. The PRD names no alternatives or competitor offers. Get that from `/odeo:research` before you commit.
- Who the email appears to come from (the customer or your product), which changes both deliverability and legal exposure.

## Pre-mortem
"It's 6 months later and this shipped and failed. What happened?" Ranked by likelihood:

1. **Most of it ran on the wrong accounts and nothing moved overall.** Few accounts switched it on, those who did were already prompt payers, and churn looks the same as before.
   - Leading signal: pilot switch-on rate under 20 percent in week 5, or no gap in churn between switched-on and other accounts after 60 days.
   - Cheapest test now: show the switch to the 10 pilot owners early and read their pre-launch days-to-paid (claim 2).
2. **Reminders went to clients who had already paid.** Owners marked paid late, clients complained, owners switched the feature off, and a few cancelled, breaching your own guardrail.
   - Leading signal: support tickets saying "reminder after I paid", and owners turning the switch off within 14 days.
   - Cheapest test now: the query on how invoices become paid and the delay (claim 4).
3. **The sending domain took a reputation hit.** Complaints on reminders pushed invoice emails into spam, so clients saw invoices later and days-to-paid got worse.
   - Leading signal: bounce and complaint rates and invoice open rates dropping in the first 2 weeks of staged rollout.
   - Cheapest test now: the seed-inbox send and the provider dashboard (claim 3).

## Security pre-mortem
This feature sends client names, email addresses, invoice amounts and payment status to third parties, so it is sensitive. "It's 6 months later and we had a leak through this. What was the hole?"

1. **A reminder went to the wrong person or carried another account's invoice.** A stale address, a template merge bug, or a scheduling job that does not check which account owns the invoice. The design must take the recipient only from the invoice's own client record at send time, check account ownership in the job, and have a test with two accounts proving no cross-over.
2. **A link or attachment in the reminder is open to anyone.** The PRD does not say whether reminders link to the invoice. If they do, a guessable or never-expiring link exposes the invoice to anyone who gets the email forwarded. The design must use unguessable, expiring links, or no link and only the invoice number and amount in the body.
3. **The log, summary and sending outlive their purpose.** The reminder log and weekly summary store and send client email addresses with no retention rule, and the job could keep emailing clients after an account is closed or a client is deleted. Clients are third parties who never signed up with you. The design must state what is stored and for how long, delete the log with the account, stop sending on account closure, and give clients a way to say they do not want these emails.

Capture these as requirements in the PRD before the build starts.

## Next

What you could do next, only if you want more depth: a second model's opinion with `/odeo:second-opinion-pm`, turn claim 1 into an experiment with `/odeo:experiments`, run the pre-mortem alone, or have me rewrite the riskiest section of the PRD (the outcome metric and schedule, claims 2 and 5). If you want to act on these later and not now, say which tests and I will propose them as checkable items for `.claude/tasks/todo.md`, written only after you confirm.
