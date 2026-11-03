<!-- run: after USR-031 review round 4, sample-a, request "critique this PRD" -->
## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | The fixed schedule (3 days before due, on the due date, 7 days after) can pull the median from 34 days to 20 | High | High | Low |
| 2 | Late payment is what drives customers away, so faster payment cuts churn | High | Medium | Low |
| 3 | At least 40 percent of accounts switch reminders on within 60 days, although the switch is off by default | High | Medium | Medium |
| 4 | The clients who receive the reminders will not find them pushy and will not complain to our customers | High | Medium | Medium |
| 5 | The current median is 34 days from send to paid | Medium | Low | Low |

Top pick this week: claim 1.

### Kill tests
**1. The schedule can reach a 20-day median.**
Strongest case: reminders are standard practice, a message on the due date is the
nudge that most late payers need, and cutting 14 days off a median is a modest ask if
many invoices sit unpaid only because nobody remembered them.
- Fails if: for more than half of invoices, the first reminder (3 days before the due
  date) falls after day 20 of the invoice's life, because the payment terms are longer
  than 23 days. The plan names no payment terms, so this can be true without anyone
  having noticed. If it is, most invoices are paid before any reminder fires and the
  median cannot reach 20 through reminders.
- Evidence this week: one query on the gap between send date and due date for invoices
  sent in the last 90 days, plus the share of invoices paid before the due date.
- Kill criterion (proposal): the median payment term is longer than 23 days. Then stop
  using median days-to-paid as the success number and measure share of invoices paid
  within 7 days of the due date, or change the schedule to start earlier.
- Cheapest test: the query. Nothing needs to be built.

**2. Late payment drives churn.**
Strongest case: for a business with 1 to 10 staff, cash flow is survival, so a tool
that does not help them get paid is the first thing blamed, and cancellation reasons
may say so. The plan states it as the top reason.
- Fails if: fewer than 1 in 5 customers who cancelled in the last 12 months give late
  payment as the reason, or customers in the slowest-paid quartile of invoices cancel
  at about the same rate as the fastest-paid quartile. The plan gives no number for
  "top reason", so it is treated as unsupported.
- Evidence this week: cancellation-reason data for the last 12 months, and monthly
  cancellation rate split by each account's median days-to-paid.
- Kill criterion (proposal): either Fails if condition holds. Then remove the retention
  claim from the business case and sell this as a convenience feature, with the
  cancellation guardrail kept as a safety check only.
- Cheapest test: two queries.

**3. 40 percent switch it on.**
Strongest case: the switch comes with a plain explanation, the benefit is immediate
and the tool already holds the data, so there is little to configure.
- Fails if: the most similar existing off-by-default setting was switched on by fewer
  than 20 percent of accounts within 60 days of release.
- Evidence this week: adoption of that existing setting, and 8 short calls with
  owners: "Would you switch this on today? What would stop you?"
- Kill criterion (proposal): comparable adoption is under 20 percent. Then either
  switch it on by default for new accounts with a clear notice, or cut the 40 percent
  target and the 20-day target with it, because both depend on who is opted in.
- Cheapest test: the adoption query; the calls only if it is borderline.

**4. Clients will not push back.**
Strongest case: three polite emails are less than most clients already get from
suppliers, the template is neutral and reminders stop when paid.
- Fails if: in the 8 owner calls, 3 or more say they would not want an automatic email
  going to their key clients, or support tickets from the last 6 months show clients
  of customers reacting badly to chasing mail.
- Evidence this week: the same 8 calls with one added question, "Which clients would
  you not email automatically?", and a search of support tickets for client complaints.
- Kill criterion (proposal): 3 or more of 8 name clients they would exclude. Then the
  per-client exclusion currently listed out of scope moves into the MVP.
- Cheapest test: add the question to the claim 3 calls. The 10-account pilot in
  week 5 is too late to find this out.

### What holds up
**5. The 34-day median.** The plan states it as a measured figure and builds nothing
on a disputed reading of it, so it is not treated as at risk. It stays in the ranked
table above but gets no kill test. The measurement period is not named, which is a
detail to confirm, not a doubt.

### What I could not judge
- Whether a 20-day median is a realistic target. The plan cites no benchmark for how
  much automatic reminders move payment time, and I have none I can cite. Treat any
  figure as unverified until `/odeo:research` has checked it.
- Whether one fixed schedule suits every customer. The plan assumes it and offers no
  evidence either way, and nothing here lets me rank it against the claims above.
  Part of claim 1 depends on it.

## Pre-mortem

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | Reminders hurt the sending domain that also delivers invoices: client spam reports on reminders push invoices themselves into spam folders, and customers stop getting paid at all | Medium | High | Send reminders from a separate sending stream or subdomain, check authentication records, set a spam-complaint threshold (proposal: 0.1 percent) that pauses sending automatically | Engineering | Before the internal pilot |
| 2 | A client who has already paid receives a reminder, because a bank transfer or cash payment was never marked paid in the tool | High | High | Test paid-state detection against the pilot accounts' real payment methods; add a one-click "stop reminders" on each invoice and a "this invoice may already be paid" line in the email | Product | Before the internal pilot |

### Fix within 30 days
None.

### Watch
- Cancellations rise among accounts with reminders on. Trigger: the monthly cancellation
  rate of reminder accounts exceeds that of other accounts by more than 10 percent
  relative (proposal) for two months in a row.

### Overblown worries
- "Six weeks is too short for a scheduling job, paid-state detection and a log."
  Overblown: the scope is small, fixed and has no customization. It becomes real if
  paid-state detection turns out to need a new payment-source integration that is not
  in weeks 1 to 2.
- "Customers will cancel because we email their clients for them." Overblown: the
  switch is off by default and the owner opts in knowingly. It becomes real if the
  plan moves to on by default, which claim 3 may push it toward.

### Unspoken worries
- Nobody owns the question of rules for automatic emails to third parties.
  The customers' clients never agreed to hear from us, and personal data in the EU
  carries obligations. I have not checked local rules, so this is unverified. Check:
  ask legal one question, "may we send payment reminders on a customer's behalf to
  their clients, and what must the email contain?" Raise it in the next planning
  meeting as a launch blocker candidate.
- The success number has no control. It is measured only across accounts that switch
  reminders on, and those are probably the ones that already chase payment, so a
  before and after comparison will mix the feature's effect with who chose it. Check:
  agree the comparison with analytics before launch, for example the same accounts'
  last 90 days before switching on. Raise it when the metric definition is reviewed.
- Nobody has looked at where a client's reply goes. A client who answers a reminder
  ("already paid, see attached") may write to an address nobody reads. Check: send a
  test reminder to an outside address and reply to it. Raise it with engineering at
  the next sync.

Launch call: phase, run the 10-account pilot first and do not start the 90-day
clock until claim 1 has been checked, because two must-fix items and an untested
top claim would otherwise turn a full rollout into a guess.
Before launch: re-run the pre-mortem on must-fix 1, 2

## Security pre-mortem
The feature emails third parties and handles invoice data and email addresses, so this
section is required.
1. **Our domain used to send abuse.** Anyone who opens an account can create invoices
   to any address and have reminders sent from our trusted domain. Design must include:
   per-account daily send limits, a hold on new accounts until the first invoices are
   reviewed, escaping of every customer-entered field in the template, and a way to
   report abuse.
2. **Invoice details reach the wrong person.** Reminder emails carry company names and
   amounts, and any link in them could be guessed or forwarded. Design must include:
   links that expire and cannot be guessed, no amounts in subject lines, and delivery
   only to the address stored for that invoice's client.
3. **Another account's data in a log or summary.** The reminder log and the weekly
   summary are new places where one customer's data can land in another's view.
   Design must include: account checked on every request, the scheduling job and the
   weekly summary scoped to one account at a time, and logs that record invoice IDs
   and events, not client names or email addresses.

More on request: a second model's view, an experiment for the top claim, a rewrite of
the riskiest section, test scenarios for the riskiest areas, a launch checklist.
