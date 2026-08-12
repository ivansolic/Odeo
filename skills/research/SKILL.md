---
description: Use when the user wants market or web research with sources, asks about market size, TAM/SAM/SOM, competitor landscape, what competitors charge, a pricing or trend scan, or verifying a claim ("is it true that..."), or when a PRD/strategy rests on unverified assumptions.
---

# Research (evidence, not vibes)

Turns a question into a CITED report the rest of the system can lean on. The
contract: **every claim carries 2+ independent sources, or it carries the label
`unverified`.** No number is ever invented; a range with a shown method beats a
confident single figure.

## Modes (pick from the question, confirm in one line)
- **market-size**: TAM/SAM/SOM as RANGES, triangulated from 2+ methods
  (top-down report data + bottom-up unit math), method shown for each.
- **competitors**: who plays, positioning, pricing, strengths/gaps, a
  feature-table only where sources support it. Feeds `/competitor-analysis`.
- **pricing**: what the market charges, models (per-seat, usage, freemium),
  where the price walls sit.
- **deep-dive**: any question ("do recipe sites block server-side scraping?"),
  answered with sources.

## Process
1. **Sharpen the question** (one exchange max): scope, region, segment, date
   sensitivity. A vague question produces a vague report; say so and sharpen.
2. **Ask the depth**: quick scan (~10 min, top sources only) or thorough
   (fan-out, cross-checks). Recommend from the stakes: a PRD bet deserves
   thorough; a curiosity deserves quick.
3. **Fan out searches**, several phrasings and angles per sub-question (market
   term + synonyms, competitor names once discovered, "X pricing", "X market
   size <year>", regional variants). Fetch the promising sources, don't answer
   from search snippets alone.
4. **Triangulate every claim**: 2+ INDEPENDENT sources (two articles citing the
   same press release = one source). Conflicting numbers are reported AS a
   conflict with both values, never silently averaged.
5. **Write the report** to `docs/research/RES-NNN-<slug>.md` (NNN = next number
   after the highest existing `RES-` file there):
   ```
   ## Question · ## Answer (3 sentences, plain language)
   ## Findings (each claim: source A + source B, with the data's date)
   ## Numbers (ranges + the method that produced each)
   ## Unverified (single-source or contested, labeled honestly)
   ## Implications for us (what this changes in PRD/priorities, 3 bullets max)
   ## Sources (links, access date)
   ```
6. **Show it to the human**: open the report in their editor (`code -r <file>`,
   fallback `cursor -r`; neither installed, give the path). Mention
   Cmd+Shift+V once for the formatted view.
7. **Route it**: offer the natural next step, cite it in the PRD's Context
   (`/prd` picks RES-NNN up), hand competitor rows to `/competitor-analysis`,
   or feed sizing into `/prioritize`. Follow-ups the user wants later go into
   `.claude/tasks/todo.md`.

## Where it sits in the process
Discovery. `/discover` offers it as an optional evidence step; `/prd` offers it
when the Context section rests on assumptions ("shall I back this with
/research?"). Fully standalone too, any question, any time, no phase required.

## Worked example
> User: "how big is the meal-prep app market in the EU?"
> -> mode: market-size, thorough. Searches: "meal planning app market size
>    europe", "recipe app revenue EU", competitor annual reports, app-store
>    category data. Triangulates a top-down analyst range against bottom-up
>    (EU households x adoption x ARPU), both methods shown.
> -> RES-003-eu-meal-prep-market.md: "€180-420M SAM (two methods, 2025 data);
>    the wide range comes from disagreement between analyst reports (labeled);
>    bottom-up favors the low end. Unverified: retention benchmarks (one
>    source)." Opened in the editor; offered: "cite RES-003 in PRD-001's
>    Context?"

## Honest limits (say them, never paper over)
- **No web access / blocked network** (corporate proxies, sandboxes): say so
  immediately and stop, a report from memory is not research. Offer what
  memory legitimately can do: name the QUESTIONS to answer and the likely
  source types, labeled "not verified, research pending".
- Search coverage is imperfect (regional/paywalled sources may be missing);
  the Sources list IS the coverage claim, nothing beyond it.
- Data ages: every number carries its data year, not just the access date.

## Rules for yourself
- Two independent sources or `unverified`, no exceptions, no silent averaging.
- Never fabricate a number, a source, or a quote (honesty guardrail; a
  fabricated citation is worse than no report).
- Ranges with methods over point estimates; conflicts reported as conflicts.
- Plain language in the Answer; the evidence lives in Findings.
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `resolve-language.sh <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
