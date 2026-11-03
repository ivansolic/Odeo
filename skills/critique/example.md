# Worked example: Red team and pre-mortem

Fictional plan: "Add a paid tier at 12 EUR per seat per month to a team retrospective
tool. Target: 4% of active teams convert within 60 days of launch." All numbers below
are illustrative (hypothesis), not facts.

Note for the reader, not part of the output: the plan also says "the tier is called
Plus". That is a naming choice, so the critique below leaves it out without mentioning it.

## Red team

Ranking rule: test first what is high impact, plausibly wrong and cheap to test.

### Claims ranked
| # | Claim | Impact if wrong | Likelihood wrong | Cost to test |
|---|-------|-----------------|------------------|--------------|
| 1 | Team admins can approve a spend of 12 EUR per seat without a procurement step | High | High | Low |
| 2 | Teams will pay for history and export, the features behind the paywall | High | Medium | Medium |
| 3 | Active teams stay active long enough to be asked for money within 60 days | Medium | Low | Low |

Top pick this week: claim 1.

### Kill tests
**1. Admins can approve the spend alone.**
Strongest case: teams of 5 to 15 people cost 60 to 180 EUR per month, below most
card-approval limits, and the admin already owns the tool choice.
- Fails if: more than half of admins say a purchase over 50 EUR per month needs someone
  else's sign-off.
- Evidence this week: 8 short calls with admins of active teams, one question: "Who signs
  off on this amount?"
- Kill criterion (proposal): 5 or more of the 8 admins name a second approver. Then
  stop the per-seat plan and price per team on an invoice instead.
- Cheapest test: the 8 calls first; if they pass, a fake-door upgrade button for 10
  days, no billing code.

**2. Teams pay for history and export.**
Strongest case: the 20 percent of teams that reopen old retros show a real need, and
export is the one thing they cannot get elsewhere.
- Fails if: fewer than 1 in 10 active teams opened a retro older than 30 days in the
  last 60 days.
- Evidence this week: one query on retro-open events by retro age, last 60 days.
- Kill criterion (proposal): the query confirms the Fails if. Then move history out of
  the paid tier and gate export alone, keeping the price.
- Cheapest test: the query, plus asking 5 admins which gated feature they would miss.

### What holds up
**3. Teams stay active.** The plan cites 12-week retention for the last three monthly
cohorts, and all are above 60 percent. The plan states its evidence, so this is not
treated as at risk. It stays in the ranked table above but gets no kill test.

### What I could not judge
Whether 12 EUR is the right price. The plan names no competitor prices and no
willingness-to-pay data, and nothing in it lets me rank price against the other claims.
Get it from `/odeo:research` before setting the number.

## Pre-mortem

### Must fix before launch
| # | Risk | Likelihood | Impact | Mitigation | Owner role | By when |
|---|------|------------|--------|------------|------------|---------|
| 1 | Admins cannot buy: the upgrade needs a second approver and the tool has no invoice option | High | High | Add pay-by-invoice for team plans and a "send this quote to your approver" link | Product | Before beta |

### Fix within 30 days
| # | Risk | Likelihood | Impact | Mitigation | Owner role |
|---|------|------------|--------|----------|------------|
| 2 | Support cannot tell a failed payment from a lapsed plan, so paying teams lose history | Medium | Medium | Write one support macro and show payment status on the team page | Support |

### Watch
- Free-tier teams drop sharply after the paywall appears. Trigger: weekly active teams
  fall more than 10 percent (proposal) below the 4-week average before launch.

### Overblown worries
- "Teams will leave for a free competitor." Overblown: the plan's retention figures show
  teams stay for the shared retro history, not the price alone. It becomes real if
  churn among the first 100 upgraded teams passes the free-tier churn.

### Unspoken worries
- Nobody owns the tax and invoice rules for teams outside the home country. Check: ask
  legal one question, "which countries need local invoice details at 12 EUR?" Raise it
  in the next planning meeting as a launch blocker candidate.

Launch call: phase, release to 10 percent of teams first, because the must-fix approval
gap would hide real demand behind a purchase process we have not built.
Before launch: re-run the pre-mortem on must-fix 1.

## Security pre-mortem
The plan adds payments and invoices, so this section is required.
1. **Invoice links that anyone can open.** Invoices carry the company name, address and
   amount. Design must include: invoice pages behind login, or links that expire and
   cannot be guessed.
2. **A former admin keeps billing access.** Design must include: billing rights end when
   the admin role is removed, checked on every billing request.
3. **Card data in our logs.** Design must include: card details handled only by the
   payment provider's hosted form, never stored or logged by us.

More on request: a second model's view, an experiment for the top claim, a rewrite of
the riskiest section, test scenarios for the riskiest areas, a launch checklist.
