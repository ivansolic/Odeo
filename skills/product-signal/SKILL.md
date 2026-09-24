---
description: Weekly product-signal memo, gathers your users' feedback (tickets, calls, analytics, reviews), clusters it into themes, and compares against LAST week's memo (what's new, stronger, faded). Run about weekly; a nudge reminds you. Read-only gathering; never fabricates data. About the product you're building, not this system.
disable-model-invocation: true
---

# Product signal (the weekly listening loop)

Turns scattered user feedback into one structured memo, and, crucially, compares
it to last time, so you see TRENDS (new pains, growing themes, faded complaints)
instead of reacting to the loudest recent voice.

## When this runs
- ~Weekly; the first session after a week has passed, a nudge offers it (you run
  it). It can run in the background while you work, gathering is read-only.

## Process
1. **Gather from REAL sources only, and pull only what the memo needs.** From
   exports/pastes you provide, or a connected tool (MCP connector) if configured.
   Be specific; do not let a connector wander the whole dataset: pull the items
   in THIS window (since the last memo's date, else the last ~7 days), capped
   (say the ~100 most recent per source), and only the fields the memo uses, the
   text, the date, the source, and any severity/frequency signal, not full
   records or unrelated tables. Sources: support tickets, call notes, reviews,
   product analytics. A source is missing or empty? Note it and continue with
   what exists. **Never invent or estimate feedback.**
2. **Cluster into themes**: recurring pains, requests, confusions, praise. Frame
   as NEEDS ("users can't find X"), not features ("add a button").
   Count frequency; quote 1-2 verbatim examples per theme.
3. **Compare vs the previous memo** (`docs/signals/`, newest file): what is NEW,
   what got STRONGER, what FADED, what disappeared. First run has no baseline,
   say so and skip the comparison, from run two onward this is the payoff.
4. **Draft the signal memo**: themes + evidence + frequency + trend + a short
   "what this suggests" (feeds `/odeo:prioritize`, `/odeo:roadmap`, `/odeo:prd`, `/odeo:outcome`).
5. **Your gate**: you review (is this real? actionable?), then save to
   `docs/signals/<YYYY-MM-DD>.md`, it becomes next week's baseline.
6. **Roadmap-drift check**: if a finding changes the priority picture ("the top
   pain isn't on the roadmap"), offer: "this changes priorities, want to revisit
   /odeo:roadmap (or /odeo:plan)?" Offer only; you decide.

## Memo shape
```
docs/signals/2026-07-14.md
## Themes (by strength)
1. <theme>, 14 mentions (up from 6)  TREND: growing
   "quote" · "quote"    -> suggests: <one line>
2. ...
## New this week / Faded since last week
## Sources used (and which were missing)
```

## Rules for yourself
- Real data only; missing sources are named, never filled in.
- Needs, not feature requests; a request is a clue to the need underneath.
- Comparison is the point: always read the previous memo when one exists.
- Offer roadmap revisit on picture-changing findings; never rewrite plans yourself.
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `resolve-language.sh <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
