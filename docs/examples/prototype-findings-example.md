# Prototype findings — Expense splitter for friends

_Date: 2026-07-15_
_Fidelity: lo-fi (frontend only, vanilla HTML/CSS/JS, fake data, no persistence)_
_Variants: 2 (parallel, each in its own git worktree + port)_

## Framing question
> When adding a shared expense, which entry flow feels more effortless — a
> structured quick-add form (A) or a single natural-language line (B)?

## Verdict: **Variant A (quick-add form) wins.**

---

## The two variants

| | A — Quick-add form (`:3001`) | B — One-line natural input (`:3002`) |
|---|---|---|
| Entry | Discrete fields: amount, payer (select), description, split-with (chips), equal split | One text box, e.g. `dinner 42 me, split with Ana i Marko` |
| Feedback | Live per-person breakdown as you type | Parses text and reads back its interpretation before commit |
| Model | Explicit — every option is visible | Implicit — behavior hidden behind phrasing/keywords |

## Why A won (decision + rationale)
- **Recognition over recall.** Every control is on screen. Nothing to remember.
- **Intuitive with zero learning.** Tester (PM, n=1) got it immediately.
- **Confidence.** You see exactly what's captured because you set each field.

## Why B lost (kill rationale — recorded so it isn't re-litigated)
- **Hidden command language.** B only reaches its full behavior through typed
  keywords like `split all` and `split with`. These are **commands you must
  learn and write** — not discoverable, not intuitive. The power is invisible
  until you already know the magic words.
- **Recall burden.** Direct quote from the test: natural language is hard
  because the command triggers (e.g. `split all`) "need to be written and it is
  not intuitive as variant A."
- **Ambiguity anxiety.** Even with a read-back, guessing payer/participants from
  free text creates a "did it understand me?" tax that the form simply doesn't have.

## What worked / what didn't
- **Worked (both):** shared shell + identical seed data isolated the variable to
  the entry flow — the comparison was clean. Live breakdown/read-back gave
  instant feedback in both.
- **Worked (A):** split-with chips + equal split read as effortless and obvious.
- **Didn't (B):** the parser is intentionally naive; feeling where it gets shaky
  was the point, and it confirmed the concept's core weakness rather than a bug.

## User flow (winner, A)
1. Enter amount → 2. pick who paid → 3. (optional) description → 4. toggle who
splits → 5. see live equal-split breakdown → 6. Add expense → item appears in Recent.

## Screens + states observed
- Form: **empty/disabled** (CTA off until amount>0 AND ≥1 person), **valid/preview**,
  **submitted** (feed flash + reset).
- Feed: **seeded** and **populated**; empty state built but not exercised (always seeded).

## Tasks / stories implied (for the real build)
- Add an expense (amount, payer, participants, equal split).
- See a running list of recent expenses with per-person share.
- (Implied, not prototyped) balances/"who owes whom", edit/delete, unequal splits.

## Tech approach + data-model sketch
- Expense: `{ desc: string, amount: number, payer: PersonId, people: PersonId[] }`
  — equal split derived as `amount / people.length`.
- Person: seeded list `[Me, Ana, Marko, Lena]`; no real identity/auth in prototype.
- Split method: **equal only** in both prototypes.

## Edge cases found (mostly via B, still relevant to A)
- Missing amount / no participants → must block submit (both handled).
- Payer should always be included in the split (B forced this decision explicitly).
- Decimal handling: `,` vs `.`; amount rounding for non-divisible splits (e.g.
  €10 / 3) — **remainder/penny-allocation is unspecified and must be decided.**
- Multiple numbers or names in one line (only relevant if any NL input survives).

## Security & data notes (feeds the PRD pre-mortem)
- **PII:** friends' names (and later emails/identities) are personal data. Real
  build must classify, minimize, and support export/delete (GDPR).
- **Auth:** not touched in prototype; a real multi-user splitter needs
  per-user auth and object-level authorization (you may only see/edit groups
  and expenses you belong to — IDOR risk).
- **Input validation:** amount and participant IDs validated server-side; never
  trust client. Money as integer minor units, not float, in the real build.

## Assumptions validated / invalidated
- ✅ Validated: a visible structured form feels effortless for this task.
- ❌ Invalidated: natural-language entry is *not* a shortcut here — its command
  syntax adds cognitive load instead of removing it.
- ➕ Open: a hybrid (form primary, optional smart-paste) was **not** tested.

## What the prototype did NOT cover
- Persistence, real users, auth, groups, balances/settle-up, unequal/percentage
  splits, currencies other than €, editing/deleting, mobile-native gestures,
  accessibility audit, empty-state UX.

## Dependencies discovered
- None required for the winner — a plain form. Real build needs the usual
  stack decisions (framework, storage, auth), currently unset in CLAUDE.md.

## Complexity signal for the real build
- **Low–moderate.** Winner is a standard form + list. Complexity lives in the
  *domain* (balances, settle-up, unequal splits, multi-user auth), not the entry UI.

## Open risks
1. Penny-rounding on non-divisible splits — decide allocation rule early.
2. Money-as-float in prototype — must switch to integer minor units.
3. Multi-user authz (IDOR) is the real security surface, entirely un-prototyped.

## Metrics
- Informal, n=1 (PM self-test). No timing captured; decision was qualitative and clear.

---

## Prototype artifacts
- Variant A: worktree `../proto-dogfood-expense-a` (branch `prototype/expense-a`), served `:3001`
- Variant B: worktree `../proto-dogfood-expense-b` (branch `prototype/expense-b`), served `:3002`
- Both disposable. Findings above are the durable handoff.
