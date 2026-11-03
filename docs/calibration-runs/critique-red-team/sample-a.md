# PRD: Auto-reminders for unpaid invoices

## Problem
Small businesses that use our invoicing tool send invoices and then chase payment by hand.
Late payment is the top reason customers leave us, so every day an invoice stays unpaid
puts the account at risk. Today a customer must remember to write a follow-up email for
each overdue invoice, and most do not. The median invoice is paid 34 days after it is sent.

## Target users
- Owners of businesses with 1 to 10 staff who send 10 to 80 invoices per month.
- The person who does the bookkeeping, often the owner, usually part time.
- Their clients, who receive the reminders and decide whether to pay.

## Outcome metric
Reduce median days-to-paid from 34 to 20 within 90 days of launch, measured across all
accounts that have reminders switched on. Guardrail: no rise in the monthly cancellation rate.

## Assumptions
- Customers will switch reminders on when we offer them, at least 40 percent within 60 days.
- The clients who receive reminders will not find them pushy, and will not complain to our customers.
- Reducing days-to-paid reduces churn, because late payment is what drives customers away.
- Reminder emails reach the inbox. Our sending domain is already used for invoices, so
  email deliverability is fine and needs no extra work.
- Customers are happy with one fixed schedule: 3 days before the due date, on the due date,
  and 7 days after.

## Scope (MVP)
- One on/off switch per account, off by default, with a short explanation of what is sent.
- Three fixed reminder emails per invoice on the schedule above, using a neutral template.
- Reminders stop automatically when the invoice is marked paid or a payment arrives.
- A log on each invoice showing which reminders were sent and when.
- The reminder settings page uses the existing blue accent colour of the dashboard.
- A weekly summary of reminders sent and invoices paid after a reminder.

## Out of scope
- Custom schedules, custom wording and per-client overrides.
- SMS or in-app notifications.
- Late fees, interest and debt collection.
- Reminders for recurring subscriptions billed by card.

## Timeline
6 weeks, 2 engineers.
- Weeks 1 to 2: scheduling job, paid-state detection, reminder log.
- Weeks 3 to 4: email template, settings switch, weekly summary.
- Week 5: internal test with 10 pilot accounts.
- Week 6: staged rollout to all accounts.
