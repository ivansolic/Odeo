<!-- run: after USR-031, sample-a, request "critique this PRD" -->
## Red team
Ranking rule: a claim ranks highest when being wrong would change the decision, it is plausibly wrong because the PRD cites no evidence, and one cheap check this week would settle it.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Late payment is the top reason customers leave, so faster payment reduces churn | High | Medium | Low |
| 2 | Reminders alone move median days-to-paid from 34 to 20, and the metric measured on opted-in accounts proves it | High | High | Medium |
| 3 | At least 40 percent of accounts switch reminders on within 60 days, although the switch is off by default | High | High | Low |
| 4 | Email deliverability is fine and needs no extra work because the invoice sending domain is reused | High | Medium | Low |
| 5 | The customers' clients will not find the reminders pushy and will not complain | Medium | Medium | Medium |

Top pick this week: claim 1

Tie note: claims 1, 3 and 4 are all cheap to test. Claim 1 wins because every other claim only matters if paying faster actually keeps customers. If claim 1 is false, the whole PRD solves a problem that is not the churn problem.

Dropped as cosmetic and not listed: the dashboard accent colour for the settings page.

### Kill tests

**Claim 1: Late payment is the top reason customers leave, and faster payment reduces churn**
- Strongest case: Cash flow is the lifeblood of a business with 1 to 10 staff. If our tool is where they feel the pain of unpaid invoices, then blaming the tool is natural, and exit surveys or cancellation notes plausibly say so. The PRD states it as a fact in the Problem and again as the logic behind the guardrail.
- Fails if: in the last 12 months of cancellations, fewer than 1 in 4 cancelled accounts gave late payment or unpaid invoices as their reason, or if cancelled accounts did not have a longer median days-to-paid than retained accounts.
- Evidence this week: the cancellation reason field or exit survey for the last 12 months, plus median days-to-paid split by cancelled versus retained accounts. The PRD cites neither.
- Kill criterion (a proposal, not a benchmark): if under 25 percent of cancellations name late payment and the cancelled and retained groups differ by fewer than 5 days in median days-to-paid, stop treating churn as the goal. Keep the feature only as a convenience feature, drop the churn guardrail as its success claim, and rewrite the Problem section.
- Cheapest test: one query on existing cancellation data and one on invoice timing, an afternoon of work, no new build.

**Claim 2: Reminders alone move days-to-paid from 34 to 20, measured on accounts with reminders on**
- Strongest case: Many late payments are simply forgotten invoices, and a prompt on the due date and a week after is exactly what a polite human would send. Three touches per invoice is a standard pattern, and halving the delay is not absurd for the forgetful share of clients.
- Fails if: the invoices paid late are mostly late because of client cash problems or disputes, not forgetfulness, so reminders shift only the forgetful minority. Also fails as a measurement if the accounts that opt in already pay faster than average, because the metric then reads as a win with no cause.
- Evidence this week: the 34 day median split into the share of invoices paid within 7 days of due date versus the long tail, and median days-to-paid of the accounts most likely to opt in versus all accounts. The PRD also never says where the 34 days comes from (which accounts, which period).
- Kill criterion (a proposal): if 34 days is a median in which more than half of the late invoices are more than 30 days past due, or if the early adopter group is already below 25 days before launch, then the 20 day target is not reachable by reminders. Change the metric to a comparison of opted-in versus a held-back group of similar accounts, and lower the target to what the forgetful share can explain.
- Cheapest test: a histogram of days-to-paid from existing invoice data, plus the pilot in week 5 run with a held-back control group instead of all 10 pilot accounts switched on.

**Claim 3: At least 40 percent of accounts switch reminders on within 60 days, with the switch off by default**
- Strongest case: The pain is real and the explanation is short, so owners who chase invoices by hand will see value immediately. Off by default is the respectful choice, and a clear one-line explanation of what is sent can convert well.
- Fails if: comparable opt-in switches in our product (any feature that is off by default) reach fewer than 40 percent of accounts within 60 days, or if fewer than 40 percent of accounts even visit the settings page in that time.
- Evidence this week: adoption of our existing off-by-default settings, and the share of accounts that open the settings page in a 60 day window. The PRD cites no number behind the 40 percent.
- Kill criterion (a proposal): if our comparable switches reach under 20 percent in 60 days, reminders cannot move a portfolio-wide metric. Either turn them on by default for new accounts, with an easy off, or announce them in the invoice-sending flow itself, and say so in the PRD instead of leaving 40 percent as an unexplained hope.
- Cheapest test: pull adoption of the three most similar existing settings from product analytics.

**Claim 4: Email deliverability is fine because the invoice sending domain is reused**
- Strongest case: The domain already has a sending history and reputation, so reminders to the same clients start warm. Transactional mail about money someone owes tends to be opened.
- Fails if: reminders raise spam complaint or bounce rates enough to hurt the same domain's invoice emails. Reusing the domain is the risk, not the safeguard: a complaint wave on reminders lands on the invoice mail that customers depend on.
- Evidence this week: current bounce and complaint rates on the sending domain, whether sender authentication (SPF, DKIM, DMARC) is set up, and the provider's complaint threshold at which sending is throttled.
- Kill criterion (a proposal): if complaint rate today is already above 0.1 percent, or authentication is not in place, do not send reminders from the shared domain. Move them to a separate sending stream or subdomain before the pilot, which changes the timeline.
- Cheapest test: read the deliverability dashboard and the DNS records, under an hour.

**Claim 5: The customers' clients will not find reminders pushy and will not complain**
- Strongest case: A neutral template sent 3 days before, on, and 7 days after the due date is mild, and clients of small businesses expect payment prompts. A reminder before the due date is a courtesy.
- Fails if: more than 1 in 50 recipients in the pilot replies with a complaint, marks the mail as spam, or the pilot customers report that a client was upset. A client who already paid by a route we cannot see (bank transfer not yet matched) is the most likely trigger.
- Evidence this week: support tickets or comments from customers who today send manual reminders about client reactions, and how many of today's payments are bank transfers that we only learn about late.
- Kill criterion (a proposal): if even 2 of the 10 pilot accounts report an upset client in week 5, pause the staged rollout and fix wording, the schedule or the paid detection first.
- Cheapest test: five short calls with customers who chase invoices by hand today, plus the week 5 pilot with a feedback line.

### What holds up
- The Out of scope list is clean and consistent with an MVP: custom schedules, SMS, fees and subscription reminders are all excluded, so the scope does not hide a second product.
- Stopping reminders automatically when an invoice is marked paid is a sound requirement and is in Scope as a rule, not a hope. (The risk that remains is detection, handled in the pre-mortem.)
- The invoice log showing what was sent and when is a good, cheap support tool and needs no kill test.
- The 34 day figure is stated as a measured number and gives a baseline. Its source is missing (claim 2), but it is not an invented market fact.

### What I could not judge
- Whether 6 weeks with 2 engineers is realistic: the PRD gives no estimate basis and I have no view of the team or the existing scheduling code.
- Whether the weekly summary is needed for the first release or is scope creep: I found no evidence for or against it in the PRD.
- Whether one fixed schedule (3 days before, due date, 7 days after) is right for all clients and payment terms. Nothing in the PRD supports or contradicts it, and it is not in the top 5 because it can be revised after launch.
- Legal obligations for sending mail in our customers' name to their clients in the markets we serve. I did not check this and it should go to legal.

## Pre-mortem

> It is 6 months later. Reminders shipped and failed. Imagine how.

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | A client who already paid receives a reminder because the payment was not yet matched (bank transfers, partial payments), and the customer is embarrassed in front of their own client | High | High | Define what counts as paid, add a delay rule for unmatched payments, add a one-click "mark as paid" shortcut in the log, and test with real timing data | engineering | before the week 5 pilot |
| 2 | Spam complaints or bounces from reminders damage the sending domain, and invoice emails themselves start landing in spam | Medium | High | Confirm sender authentication, add an unsubscribe or "I already paid" link, set a complaint-rate stop that pauses sending automatically, consider a separate sending stream | engineering | before the week 5 pilot |
| 3 | The metric reads as a success or failure for the wrong reason: only opted-in accounts are measured, so selection bias hides the real effect and the churn guardrail is too slow to detect harm | High | Medium | Add a held-back comparison group in the pilot and a measurement plan that compares like with like, and say how long the cancellation guardrail needs to be readable | product | before beta |

### Fix within 30 days
| # | Risk | Likelihood | Impact | Response | Owner role |
|---|------|------------|--------|----------|------------|
| 1 | Customers want their own wording and switch reminders off after the first complaint from a client | Medium | Medium | Review the off-switch rate in the first month and prioritize custom wording if it is high | product |
| 2 | Support is not ready for "why did my client get this email" tickets | Medium | Medium | Give support a short explainer, the invoice log and a way to see what was sent | support |
| 3 | The weekly summary email adds noise or a second unsubscribe path that nobody maintains | Low | Low | Check opens of the summary after the first month, drop or fold it into the dashboard if unread | product |

### Watch
- Opt-in below the 40 percent assumption: trigger is adoption under 15 percent of accounts after 30 days, which would move claim 3 from watch to a plan change.
- Cancellation rate: trigger is a rise of more than one percentage point in monthly cancellations among accounts that switched reminders on, compared with those that did not.
- Reminder fatigue: trigger is the share of accounts that switch reminders off after previously switching them on exceeding 10 percent in a month.

### Overblown worries
- "One fixed schedule will not fit everyone." Overblown for the MVP because the PRD already puts custom schedules out of scope on purpose and an early version can learn from the data. It becomes real if over 10 percent of accounts switch the feature off within a month and give timing as the reason.
- "6 weeks is too tight." Overblown only in the sense that the build is small (a job, a template, a switch, a log); I cannot judge it fully (see What I could not judge). It becomes real if the paid-state detection in weeks 1 to 2 slips, because the pilot depends on it.

### Unspoken worries
- Our customers' clients receive mail that says it is from our customer but is written by us, and nobody has asked whether customers are comfortable with that. How to check: ask five pilot candidates to read the template before the pilot. How to raise it: put it on the agenda of the next product review as "who is the sender in the eyes of the client".
- The Problem section blames churn on late payment, but cancellations may be driven by price, a competitor or missing features, and nobody is checking it. How to check: the cancellation data query in claim 1. How to raise it: share the result with whoever owns churn reporting before the PRD is approved.
- Reminders could reduce days-to-paid while damaging customers' relationships with their clients, which our metric cannot see. How to check: ask pilot customers in week 5 whether any client reacted. How to raise it: add a question about client reaction to the pilot exit interview.

Launch call: phase, because three risks are must-fix before the week 5 pilot (wrongly sent reminders, sender reputation, an unreadable metric), and the PRD's two load-bearing claims (churn link and opt-in rate) are untested. Go to the pilot only after the cheap checks above, and roll out beyond the pilot only when the complaint rate and wrongly sent rate stay under the stop rules.

## Security pre-mortem
The feature handles personal data of people who are not our users: names and email addresses of our customers' clients, plus what they owe and when. It also sends mail on behalf of our customers.

Top 3 leak or attack scenarios:
1. **Reminders go to the wrong person or leak invoice details.** A bug in recipient lookup or template filling sends one client's amount and invoice number to another. The design must include a fixed recipient taken only from the invoice record, no free-text insertion into the template, and a test with two accounts that have the same client name.
2. **The reminder mail is abused as a phishing relay.** Anyone with access to a customer account could change the client email on an invoice and get us to send a mail from our trusted domain to any address. The design must include a rate limit per account per day, an alert when a client email is changed and a reminder follows within 24 hours, and the limit on three mails per invoice enforced on the server.
3. **Reminder links or the log expose data to the wrong user.** The "I already paid" link and the per-invoice log could be guessable, or visible across accounts. The design must include unguessable, expiring tokens, an object-level check that the log belongs to the viewing account, and no personal data of clients in application logs.

Also required: a record of who receives mail on whose behalf, a way to delete a client's data on request, and a stated retention period for the log.

More on request: a second model's view, an experiment for the top claim, a rewrite of the riskiest section, test scenarios for the riskiest areas, a launch checklist.
