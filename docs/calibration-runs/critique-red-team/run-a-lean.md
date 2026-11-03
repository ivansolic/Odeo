<!-- run: after USR-030, sample-a, request "critique this PRD" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Reminders are what moves days-to-paid from 34 to 20 (and the comparison across opted-in accounts will show it) | High | High | Low |
| 2 | Late payment is what drives customers to cancel, so faster payment lowers churn | High | Medium | Low |
| 3 | At least 40 percent of accounts switch reminders on within 60 days, although the switch is off by default | High | High | Low |
| 4 | Three fixed emails (3 days before, on the day, 7 days after) are acceptable to the customers' clients and to the customers | Medium | Medium | Medium |
| 5 | Reminders reach the inbox and "need no extra work", because invoices already go out from the same sending domain | Medium | Medium | Low |

Top pick this week: claim 1, with claim 3 next to it (same pilot data answers both).

### Kill tests

**1. Reminders cause the faster payment.**
Strongest case: many invoices are paid late only because nobody chased them. A prompt on the due date costs the payer nothing and removes the "I forgot" delay, so a large drop in the median is plausible.
- Fails if: in a comparison of invoices that got reminders against similar invoices (same account, same size band) that did not, the median days-to-paid differs by less than 5 days. Also fails if the 34 days is mostly driven by clients with 30 or 60 day payment terms, where a reminder 7 days after the due date comes later than the usual payment.
- Evidence this week: one query splitting the last 6 months of invoices by days between due date and payment, and by payment terms. It shows how many invoices are paid more than 7 days after the due date, which is the only group the three emails can reach.
- Kill criterion: fewer than 30 percent of invoices are paid later than 7 days after the due date. Then a median of 20 is out of reach by reminders alone; change the target or the mechanism.
- Cheapest test: the query, plus a pilot with a holdout. Half of the invoices in each pilot account get no reminders. The PRD's metric (accounts with reminders on) compares accounts that chose reminders, who are probably the ones already chasing, with their own past, so it cannot separate cause from selection. Fix the metric to include a holdout, and report a mean or a share paid within 20 days next to the median, since a median alone moves with a small group.

**2. Late payment drives churn.**
Strongest case: cash-flow stress is real for 1 to 10 person businesses, and our tool is where the pain shows up, so cancellations after a late month are credible.
- Fails if: among accounts that cancelled in the last 12 months, the share with a median days-to-paid above 34 in their last 3 months is not clearly higher (less than 1.3 times) than among accounts that stayed.
- Evidence this week: that one comparison from billing and invoice data, plus the cancellation reasons field or exit survey, if one exists. The PRD states the reason as fact and cites neither.
- Kill criterion: accounts that cancel pay no later than accounts that stay. Then the churn argument is gone and the feature has to stand on days-to-paid alone, which is a weaker business case.
- Cheapest test: the comparison, 1 day of analysis. Also note the guardrail ("no rise in cancellation") cannot detect a benefit or a harm within 90 days at this account volume unless you state the minimum number of accounts needed.

**3. 40 percent switch reminders on.**
Strongest case: the pain is daily and obvious, the explanation is short, and the switch is one click inside a flow customers already use.
- Fails if: fewer than 25 percent of pilot accounts switch it on within 14 days of seeing the offer.
- Evidence this week: how many accounts opened a comparable settings switch in the last launch (any past opt-in feature), and the click-through of an in-app banner for a fake-door "Turn on reminders" in week 1.
- Kill criterion: under 10 percent opt in within 14 days in the fake-door test. Then default behaviour or the offer has to change, because the effect on the whole base will be too small to move any account-wide figure.
- Cheapest test: fake-door banner on 2,000 accounts for 10 days, no scheduling code.

**4. The fixed schedule is acceptable.**
Strongest case: three touches, neutral wording, nothing aggressive, and the customer opted in. Most clients will see a normal courtesy.
- Fails if: in the pilot, more than 5 percent of reminded clients reply with a complaint, or more than 10 percent of pilot customers switch reminders off again within 30 days.
- Evidence this week: 6 calls with customers, one question: "Would you send this email to your best client 3 days before the due date?" The first reminder goes out before anything is late, which is the one most likely to feel pushy.
- Kill criterion: 3 or more of 6 customers say they would not send the pre-due-date email. Drop it and keep the other two.
- Cheapest test: show the three email drafts to 6 customers; no code.

**5. Deliverability is fine.**
Strongest case: the same domain already delivers invoices, so authentication (SPF, DKIM) is set and the reputation is good.
- Fails if: the spam-complaint rate on reminder emails is above 0.1 percent, or inbox placement of reminders is below 95 percent in a seed test. Invoices are expected by the payer; chasers are the kind of mail people mark as spam, and complaints on the shared domain would hurt invoice delivery too, which is the core product.
- Evidence this week: current bounce and complaint rates for invoice mail, and a seed test of a reminder-style message across the 5 largest mailbox providers.
- Kill criterion: any complaint rate above 0.3 percent in the pilot. Move reminders to a separate sending subdomain before rollout.
- Cheapest test: seed test plus a separate subdomain decision made now, before week 5.

### What holds up
- **The baseline.** The PRD states a concrete current figure (34 days median, from our own invoices). I take it as given, with one thing to confirm: the period it covers and whether it includes invoices with long payment terms.
- **The boundaries.** Off by default, no late fees, no custom wording, no card subscriptions. These keep the MVP small and reduce harm from wrong sends; I find no hole in them.
- **Stopping on payment, as a goal.** Stopping reminders once the invoice is paid is the right requirement. How the tool learns about a payment made outside it is not in the PRD; that is a pre-mortem item below, not a claim I rank.

### What I could not judge
- Whether a median of 20 days is a realistic target. The PRD names no benchmark from similar tools and no pilot result, and nothing in it lets me say if 20 is bold or modest. `/odeo:research` can give outside numbers.
- Whether 6 weeks and 2 engineers fit. I have no view of the codebase, in particular how paid-state detection would work for payments made by bank transfer.

## Pre-mortem

"It is 6 months later, this shipped and failed. What happened?"

1. **Too few switched it on, and those who did were already good at chasing.** The account-wide median barely moved. Likelihood: highest, because the switch is off by default and the metric only counts accounts that turned it on.
   - Leading signal: fewer than 15 percent of accounts opted in by day 14, and opted-in accounts already had a median below 34 days.
   - Cheapest test now: the fake-door banner from claim 3, and the history of opted-in accounts versus the rest.
2. **Reminders went to clients who had already paid.** The client paid by bank transfer, the customer had not marked the invoice paid yet, and a "7 days overdue" email arrived. The customer is embarrassed in front of their own client and switches reminders off, or leaves.
   - Leading signal: in the pilot log, reminders sent within 3 days before a payment was recorded or marked, and support tickets saying "reminded after paying".
   - Cheapest test now: replay the last 60 days of invoices against the planned schedule and count how many reminders would have gone out after a payment that was recorded later than the send time.
3. **The pilot could not prove anything, and rollout went ahead anyway.** The internal test with 10 accounts runs in week 5, one week before the staged rollout, but the average invoice takes 34 days to be paid, so no pilot invoice completes its cycle before the decision.
   - Leading signal: at the end of week 5, fewer than 10 invoices per pilot account have a full reminder cycle behind them.
   - Cheapest test now: start the pilot in week 3 on the part that already works (scheduler plus log), and define in advance what number in week 5 stops the rollout.

## Security pre-mortem

The feature touches PII (names and email addresses of the customers' clients, invoice amounts) and sends mail from our domain to third parties who never signed up with us.

"It is 6 months later and we had a leak or abuse through this. What was the hole?"

1. **Reminders as a spam and phishing channel.** Someone opens a trial account, creates invoices for a long list of foreign addresses, and our domain sends three emails to each. Design must include: a cap on reminders per account and per day, a check on new accounts before reminders can be switched on, a visible "this is not for me" link in every email, a suppression list that blocks further sends to an address that used it, and a complaint rate alarm per account.
2. **Wrong recipient or exposed invoice.** The reminder goes to a stale or mistyped client address, or the link to the invoice in the email can be guessed or reused. Design must include: the recipient taken only from the invoice record at send time, links with unguessable, expiring tokens, minimal invoice detail in the email body, and no personal data of the client in log lines (log IDs only).
3. **Cross-account leak.** The scheduling job and the weekly summary read invoices across accounts; one query without an account filter puts another account's invoices into a log or a summary. Design must include: every query in the job scoped to one account, a test that a job run for account A can never return a row of account B, and a defined retention period for the reminder log, with client data deleted or anonymised when the customer deletes the invoice or the account.
