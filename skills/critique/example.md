# Worked example: Red team part

Fictional plan: "Add a paid tier at 12 EUR per seat per month to a team retrospective
tool. Target: 4% of active teams convert within 60 days of launch." All numbers below
are illustrative (hypothesis), not facts.

Dropped, not listed: "the tier is called Plus". It is a naming choice, and changing it
would not change the decision. This line exists only to teach the rule.

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
treated as at risk.

### What I could not judge
Whether 12 EUR is the right price. The plan names no competitor prices and no
willingness-to-pay data, and nothing in it lets me rank price against the other claims.
Get it from `/odeo:research` before setting the number.
