<!-- run: before USR-030, skill at commit 657f363, sample-a, no depth requested -->
# Critique: PRD "Auto-reminders for unpaid invoices"

Output language: en (as instructed). Two passes plus a security pre-mortem, because the feature sends email to third parties and stores their contact data.

## Pass 1, Red-team

### The problem
- The problem is plausible but the evidence is thin. "Late payment is the top reason customers leave us" is stated as fact with no source: no churn-interview count, no exit-survey share, no cohort comparison. It is the claim the whole PRD stands on.
- The 34-day median is a single number. It does not say how much of it is "customer forgot" (what reminders fix) versus "client cannot or will not pay yet" (what reminders do not fix) versus "payment terms are 30 days" (which is not lateness at all). If most invoices carry net-30 terms, a median of 34 is only 4 days late, and a target of 20 means clients pay before the due date, which three reminders starting 3 days before due will barely influence.
- "Most do not" write follow-ups is also unevidenced. If customers already chase by phone or WhatsApp, the email reminder adds little.

### The assumptions: the one that sinks it
**Assumption 3: "Reducing days-to-paid reduces churn."** It is listed as an assumption but the whole business case rests on it. Two things break it:
1. The PRD never shows that customers who get paid faster stay. Late payment may be a symptom (customers in cash trouble leave because they are failing), not a cause. Faster payment from their clients would then change nothing.
2. The outcome metric is days-to-paid, not retention. The team can hit 20 days and still lose the customers it was meant to save, and the guardrail only checks that churn does not rise, not that it falls. Success on the stated metric does not prove the bet.

If this one is wrong, the feature works as designed and the business gets nothing.

Other assumptions that are weaker than they look:
- **Deliverability is declared "fine and needs no extra work".** This is the most dangerous sentence in the PRD. The sending domain is shared with invoices. Reminders are the email type most likely to be marked as spam by clients who dispute or dislike them. A few complaints on the reminder stream can damage the domain reputation and push the invoices themselves into spam, which makes days-to-paid worse and could cut off the core product. "Already used for invoices" is an argument for the risk, not against it. No SPF/DKIM/DMARC check, no separate sending stream, no bounce or complaint handling, no monitoring is planned.
- **"Clients will not find them pushy and will not complain to our customers."** This is a hope, not an assumption anyone tested. A neutral template sent in the customer's name to the customer's own client is exactly where relationship damage happens, and the customer, not us, bears it. A reminder sent to a client who already paid by bank transfer will be the worst case.
- **40 percent adoption in 60 days with an off-by-default switch.** Off-by-default is the safe choice, but nothing in the plan makes customers discover the switch. No prompt, no onboarding, no in-product nudge is in scope.
- **One fixed schedule is fine for everyone.** Customers with net-14, net-30 and net-60 terms, or invoices issued on the due date, all get the same three dates. For invoices sent less than 3 days before due, the first reminder is in the past. The PRD does not say what happens.

### The outcome and the metric
- **Selection bias.** The metric is measured "across all accounts that have reminders switched on". Customers who opt in are the ones who care about late payment. Comparing them to the 34-day figure from all accounts will overstate the effect. There is no control group, no before and after for the same accounts, no holdout.
- **Gameable and noisy.** A median over 90 days after launch is dominated by invoices sent before launch and by invoices still unpaid (right-censoring): unpaid invoices are not in a days-to-paid median until they are paid, so the metric improves artificially if the slowest ones simply have not closed yet. Customers can also game it by marking invoices paid manually.
- **The guardrail is too weak.** "No rise in monthly cancellation rate" has no baseline, no window, and with a small account base, normal noise will swamp it. It also does not cover the second harm: client complaints and deliverability.
- 20 days is a 41 percent cut. Where does that number come from? No source is given, and no smaller target is stated as the "good enough".

### Scope
- The MVP is not minimal. The log and the weekly summary are not needed to test the bet. The weekly summary is a reporting feature, and "the settings page uses the existing blue accent colour" is not a scope item at all, it is a style note that belongs to implementation. They signal a wishlist and eat part of the 6 weeks.
- What the smallest test of the bet looks like: the on/off switch, the three emails, stop on paid. That could ship in 3 to 4 weeks and leave time to learn.
- The riskiest part is under-scoped: "Reminders stop automatically when the invoice is marked paid or a payment arrives". Payments that arrive outside the tool (bank transfer, cash, a credit note, a partial payment) are not detected. Partial payments, disputed invoices, cancelled invoices and invoices re-issued with corrections are not mentioned. Sending a dunning email for an invoice the client already paid is the failure customers will remember.
- Which email address is used, who it appears to be from, whether the customer can preview or pause a single reminder, and what the client can reply to are all missing. A client reply to a no-reply address would be a bad experience.

### The alternative
- Why will customers not keep doing what they do today? The PRD only says they "do not remember". Alternatives that already exist: accountants and bookkeepers who chase, bank-integrated tools that mark paid automatically, a direct payment link on the invoice (which attacks the real friction: the client has to find out how to pay). A "pay now" link is not in scope or out of scope. Reminders without an easy way to pay may just annoy.
- The cheapest alternative is a pre-written reminder email template the customer can send with one click. It would test whether customers want to chase at all, without building a scheduler.

### Timeline
- 6 weeks, 2 engineers, with the pilot in week 5 and a full rollout in week 6. That is one week of learning from 10 accounts. Ten accounts at 10 to 80 invoices a month, with a 34-day median, will not produce a single full payment cycle in a week, so the pilot cannot validate the metric. It can only catch crashes. Rolling out to all accounts the week after means a staged rollout with no real evidence.
- No buffer, no explicit work for deliverability, abuse protection, or legal review. The estimate looks like it was made from the feature list, not the risks.

## Pass 2, Pre-mortem

> "It's 6 months later, this shipped and failed. What happened?"

Ranked by likelihood.

### 1. Reminders hurt deliverability and the invoices themselves start landing in spam (likely)
Reminders to unhappy clients attract spam complaints on the shared sending domain. Reputation drops. Invoices, the core product, are delayed or lost. Days-to-paid gets worse, not better, and customers churn for a reason the feature caused.
- **Leading signal:** complaint rate and bounce rate on the reminder stream; inbox-placement for invoice emails at seed addresses; customers writing "my client never got the invoice".
- **Cheapest test now:** send reminders from a separate subdomain or stream with its own reputation, and run an inbox-placement test on the template before week 5. Define a complaint-rate threshold that auto-pauses the feature.

### 2. Wrong or unwelcome reminders damage the customer's relationship with their client, and the customer switches it off or leaves (likely)
Reminders go out for invoices already paid outside the tool, disputed, partially paid, or cancelled. A client is embarrassed or angry and tells our customer. Customers turn the switch off, so adoption falls under 40 percent, or they blame us.
- **Leading signal:** share of accounts that switch on and then off within 30 days; support tickets mentioning "reminder sent but already paid"; manual "mark paid" actions made within a day after a reminder.
- **Cheapest test now:** in the pilot, give each customer a preview and a one-click "pause for this invoice", and count how often it is used. Replay the pilot customers' last 90 days of invoices against the stop rules offline and count how many reminders would have been wrong.

### 3. It works on the surface but does not move the business (plausible)
Days-to-paid improves a little among customers who opted in, but they were the careful ones. Churn does not change, because the assumption that late payment drives churn was wrong or because late payers were never the customers about to leave. The team declares success on the metric and learns nothing about retention.
- **Leading signal:** retention of opted-in versus comparable non-opted-in accounts at 90 days; whether churned accounts had slower days-to-paid before they left, measured on past data.
- **Cheapest test now:** before building anything, take the last 12 months of churned accounts and compare their days-to-paid history with retained ones. If there is no difference, stop. Then randomise the offer (holdout group) at rollout so the effect can be separated from self-selection.

## Security pre-mortem

This feature touches personal data (client names and email addresses, invoice amounts and due dates, payment status) and sends email in a customer's name to people who never agreed to our terms. It is sensitive.

> "It's 6 months later and we had a breach or leak through this. What was the hole?"

**Where the data lives and who can reach it:** client contact data and invoice details sit in the invoice database, are copied into the reminder log, the email provider, the sending queue, and the weekly summary. Reachable by the customer's staff, by us, and by the email provider.

### Top 3 attack and leak scenarios

1. **Our system as a spam and phishing relay.** A malicious or compromised account creates invoices to arbitrary addresses (with attacker-chosen client name and notes) and switches reminders on. We send three emails per invoice, from our trusted domain, to strangers. Worse, a phishing link in an invoice description is then delivered on our reputation.
   - **Design must include:** per-account and per-recipient send caps; new-account and new-recipient throttling; no free text from the customer in the reminder (the neutral fixed template is correct, keep it that way); links only to our own invoice page; abuse monitoring; automatic pause on complaint spikes; a way for a client to block all further reminders from us (see 3).
2. **Reminders disclose invoice data to the wrong person, or leak across accounts.** A mistyped or stale client address, a shared mailbox, a forwarded email, or an invoice link that is guessable all expose amounts and business relationships. A scheduling job that reads invoices across accounts without strict account scoping could send one customer's reminder with another's data (an object-level access failure, the classic IDOR shape in a batch job). Reminder log and weekly summary could also be shown to the wrong users.
   - **Design must include:** the scheduler resolves recipients and content strictly from the invoice's own account and has a test that proves it cannot cross accounts; unguessable, expiring, single-invoice links with no login-free access to other invoices; minimal data in the email body (invoice number and amount, not line items or notes); log and summary access limited to authorised roles of that account; recipient address validation and bounce handling so repeatedly failing addresses are suppressed.
3. **Privacy and consent gaps turn into a legal and trust breach.** The client is a data subject who receives automated emails with no relationship to us. Without an unsubscribe or objection route, a retention limit for the reminder log and recipient data, and a way to export and delete a client's data on request, we are exposed under GDPR and anti-spam rules in the countries our customers operate in. Email addresses and content could end up in application logs and in the email provider with no retention policy. Customers could be sending reminders to people who are not their client.
   - **Design must include:** a clear role statement (customer is the controller, we are the processor) and a data processing agreement covered in the terms; an unsubscribe or "stop reminders for this invoice" link in every email that is honoured immediately and stored as a suppression list; defined retention for the log and client contact data; deletion and export that cover the reminder log, queue and provider; no recipient addresses or invoice contents in application logs, only IDs and events; TLS enforced for sending; the email provider reviewed and covered by a processing agreement.

These findings should be captured as requirements in the PRD, not left as notes. Note that none of them appear in scope today, and the 6-week plan has no time for them.

## What to do next

1. **Focus on the one assumption:** test "late payment drives churn" on existing data before any build. It costs a query, and it decides whether the project should exist.
2. **Fix the metric:** add a holdout or before and after comparison, handle unpaid invoices in the median, and give the guardrail a baseline and a complaint-rate and deliverability companion guardrail.
3. **Move deliverability and stop-rule correctness from "no work" to explicit scope,** and cut the weekly summary and the colour note from the MVP.
4. **Add the security requirements above** as acceptance items, including unsubscribe, rate caps, account scoping tests and retention.
5. **Re-plan the pilot:** start it earlier, make it long enough to see payments close, and make the full rollout depend on its result.

Verdict on the current draft: not ready to build. The problem is probably real, but the case rests on an unchecked churn link, the metric cannot prove it, and the largest risks (deliverability, wrong reminders, abuse and privacy) are either dismissed or absent.
