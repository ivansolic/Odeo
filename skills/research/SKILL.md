---
description: Use when the user wants market or web research with sources, asks about market size, TAM/SAM/SOM, competitor landscape, what competitors charge, a pricing or trend scan, or verifying a claim ("is it true that..."), or when a PRD/strategy rests on unverified assumptions.
---

# Research (evidence, not vibes)

Turns a question into a CITED report the rest of the system can lean on. The
contract: **every claim is verified (two independent sources) or says plainly that it
is not (`one source` or `unverified`).** These terms, and note, traced and
independent, are defined once, in the Definitions of `${CLAUDE_PLUGIN_ROOT}/skills/research/rubric.md`; this skill
uses them and never rewords them. No number is ever invented; a range with a shown
method beats a confident single figure.

## Modes (pick from the question, confirm in one line)
- **market-size**: TAM/SAM/SOM as RANGES, triangulated from 2+ methods
  (top-down report data + bottom-up unit math), method shown for each.
- **competitors**: who plays, positioning, pricing, strengths/gaps, a
  feature-table only where sources support it. Feeds `/odeo:competitor-analysis`.
- **pricing**: what the market charges, models (per-seat, usage, freemium),
  where the price walls sit.
- **deep-dive**: any question ("do recipe sites block server-side scraping?"),
  answered with sources.

## Process
1. **Sharpen the question** (one exchange max): scope, region, segment, date
   sensitivity, the decision it serves, its sub-questions, and what its key terms
   mean in this report. A vague question produces a vague report; say so and sharpen.
2. **Ask the depth**: quick scan (~10 min, top sources only) or thorough
   (fan-out, cross-checks). Recommend from the stakes: a PRD bet deserves
   thorough; a curiosity deserves quick.
3. **Fan out searches**, several phrasings and angles per sub-question (market
   term + synonyms, competitor names once discovered, "X pricing", "X market
   size <year>", regional variants). Fetch the promising sources, don't answer
   from search snippets alone.
4. **Triangulate every claim**: aim for two independent sources per claim (the rubric's
   Independent sources and Verified definitions say what counts). Conflicting numbers
   are reported AS a conflict with both values, never silently averaged.
4b. **Cite as you write**: put a claim's sources in a numbered note under Findings (the
   rubric's Note definition). Every claim cites its note(s) and carries its confidence
   word where it appears: verified, one source, or unverified (the rubric's Confidence
   words). A claim with no note you can name is unverified, however sure you feel;
   never restate a source from memory.
5. **Write the report** to `docs/research/RES-NNN-<slug>.md` (NNN = next number
   after the highest existing `RES-` file there):
   ```
   ## Question (scope, sub-questions, the decision it serves, key terms;
      mode and depth may sit in the frontmatter)
   ## Answer (3 sentences, plain language; each factual clause cites its note
      or says "unverified")
   ## Findings (each claim: its note numbers + its confidence word, with the
      data's date; the numbered notes with quotes follow the claims)
   ## Numbers (ranges + the method that produced each)
   ## Unverified (every claim that is not verified, and every conflict with both values)
   ## Implications for us (what this changes in PRD/priorities, 3 bullets max,
      each with its reason and the notes it rests on)
   ## Sources (grouped by publisher, links, access date, versions; one line on
      what the search did not cover: regions, paywalls, languages, blocked pages)
   ```
5b. **Score it**: commit the report on a branch (on `main`, ask the human to create one
   first: Git discipline in `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`), then dispatch `pm-reviewer` against
   `${CLAUDE_PLUGIN_ROOT}/skills/research/rubric.md`, handing it `git rev-parse --short HEAD` and
   `output_language` (Guardrails 1 and 7 in `${CLAUDE_PLUGIN_ROOT}/AGENTS.md`).
   Below the threshold, fix the report and re-dispatch the same reviewer: the review
   loop of Guardrails 3, with its stop condition.
6. **Show it to the human**: open the report in their editor (`code -r <file>`,
   fallback `cursor -r`; neither installed, give the path). Mention
   Cmd+Shift+V once for the formatted view.
7. **Route it**: offer the natural next step, cite it in the PRD's Context
   (`/odeo:prd` picks RES-NNN up), hand competitor rows to `/odeo:competitor-analysis`,
   or feed sizing into `/odeo:prioritize`. Follow-ups the user wants later go into
   `.claude/tasks/todo.md`.

## Where it sits in the process
Discovery. `/odeo:discover` offers it as an optional evidence step; `/odeo:prd` offers it
when the Context section rests on assumptions ("shall I back this with
/odeo:research?"). Fully standalone too, any question, any time, no phase required.

## Worked example
Adapted from a real report (RES-002, "Where can Odeo run besides Claude Code?",
deep-dive, thorough). The note and its quote are verbatim from it; the confidence word
and the Unverified line show how this skill writes the same claim, which RES-002 itself
did not do:
> Answer clause: "users must approve plugin hooks before they run, apparently again
> whenever a hook changes (one source, note 2)."
> Note 2: developers.openai.com/codex/hooks, quote: "Codex skips plugin-bundled hooks
> until you review and trust the current hook definition".
> Unverified section: "the hook trust step rests on one source; whether it repeats on
> every hook change is an inference from 'the current hook definition'."
The clause says its confidence word, the note gives the page and the quote, and the
inference is labeled as one. The same report also shows the failure this skill now
prevents: the sources behind most of its table cells were not kept, so those cells
could not be traced to anything.

## Honest limits (say them, never paper over)
- **No web access / blocked network** (corporate proxies, sandboxes): say so
  immediately and stop, a report from memory is not research. Offer what
  memory legitimately can do: name the QUESTIONS to answer and the likely
  source types, labeled "not verified, research pending".
- Search coverage is imperfect (regional/paywalled sources may be missing);
  the Sources list IS the coverage claim, nothing beyond it.
- Data ages: every number carries its data year, not just the access date.

## Rules for yourself
- Verified, or labeled `one source` or `unverified`: no exceptions, no silent averaging.
- No sentence states something as fact without citing a note; its confidence word is
  said where the claim appears, not only in the Unverified section.
- Never fabricate a number, a source, or a quote (honesty guardrail; a
  fabricated citation is worse than no report).
- Ranges with methods over point estimates; conflicts reported as conflicts.
- Plain language in the Answer; the evidence lives in Findings.
- **Write the body in the project's output language; mechanics stay English.** Before
  writing, resolve it with `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-language.sh" <project-dir>` (the project's
  `output_language` setting) and write the document BODY in that language. The whole
  frontmatter block, the filename slug and every machine-read field stay English, and
  the fixed section headings and field labels of this document's shape stay English
  while the prose under them is localized. See `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` Guardrails 7 for the rule
  and the fallback chain; do not restate it here, and never widen the code set, name a
  language the resolver does not support, or offer to translate an existing document.
