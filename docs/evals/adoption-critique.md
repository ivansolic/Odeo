---
artifact: docs/depth-checklists/critique-1.md docs/depth-checklists/critique-2.md
type: adoption
branch: docs/prd-003-pm-content-depth
reviewed_commit: 633b15c
date: 2026-11-03
scorer: adoption-reviewer
model: claude-opus-5-5
model_tier: strongest
effort: high
verdict: PASS
---

# Adoption review: critique (red team half, R1 and R24, USR-030)

Round 2, a full re-judgment of both checklists against the current files, not only the
changed rows.

Inputs read in full: `docs/depth-checklists/README.md`, both checklists, the source skill
`pm-execution/skills/strategy-red-team/SKILL.md` and the source command
`pm-execution/commands/red-team-prd.md` (copy at `07b34f6`, read as data),
`skills/critique/SKILL.md`, `skills/critique/example.md`, and PRD-003 sections 2, 5, R1 and
R24. Grep and Glob were not available in this session, so the USR-030 file could not be
located by name and was not re-read this round; it was read in round 1, and R1 and R24 of
the PRD carry the acceptance criteria judged here. The pre-mortem half (USR-031) is out of
scope. No text in either source addresses a reviewer or tries to change how it is judged.
Source instruction-file check printed nothing (as supplied). Copy check, all four pairs:
no output, exit 0 (as supplied).

Verdict: PASS. Both checklists pass; two comments below, neither failing.

## critique-1 (source skill strategy-red-team): PASS

- **Completeness:** my own list of the source skill (Context: two rules; steps 1 to 8 with
  their decision rules; the step 6 fields; the step 8 template: title, Top Kill-Assumptions
  3 to 5 with the Claim field, What's Well-Reasoned, What I Couldn't Assess; five Notes;
  Further Reading) is covered by rows 11 to 36. The step 3 inline good and bad example is
  matched by row 14 (SKILL.md Pass 1 step 3: Good: "Fails if fewer than 1 in 10 interviewed
  admins ..." Bad: "Fails if users don't care."). "Make it screenshot-native" is a
  formatting remark, not a step, section, column, rule or example.
- **Present rows:** each quoted line exists at the stated place and does what the source
  item does, for example step 4: "Rank the claims on three measures, each high / medium /
  low and each shown per claim: impact if wrong, likelihood it is wrong, cost to test";
  step 6: "Strongest case, Fails if, Evidence this week (which number, report or customer
  call would settle it), Kill criterion, Cheapest test"; step 5: "Treat a claim as at risk
  unless the plan cites evidence for it."
- **Row 23 (step 7, second model), resolved:** SKILL.md Output now ends the default shape
  with "More on request: a second model's view, an experiment for the top claim, a rewrite
  of the riskiest section." and the On request block prints "A second model's opinion:
  `/odeo:second-opinion-pm`." only when asked. That matches the format's `on request`
  ("offered, printed when the user asks") and the source's "Default is single-model; don't
  add this friction unless asked": one offer line adds no run.
- **Excluded rows:** row 24 (title line) uses "adds length" and names the unchanged
  decision (which claim to test first); a title sorts, ranks, times or assigns nothing.
  Row 36 (author links) uses "a person credit or author link". Both on the closed list.
- **No personal fields:** the template (`## Red team` ... `### What I could not judge`,
  the on-request line and block) has no name or contact field.
- **Frontmatter:** `source_skill: pm-execution/skills/strategy-red-team`, `source_commit:
  07b34f6`, both match.
- **Method source:** present below the table (Tradecraft Primer Key Assumptions Check; UK
  Red Teaming Handbook), naming the two items the primary sources do not cover.
- **Row shape:** every kind valid; excluded rows leave `shown` empty; present rows carry
  `default` or `on request`.
- **R1 red team half:** every AC item is in the default output (load-bearing claims only,
  strongest case first, "Fails if", three-measure ranking, kill criterion, evidence this
  week, cheapest test, What holds up, What I could not judge, fixed shape).

## critique-2 (source command red-team-prd): PASS

- **Completeness:** every source item (invocation examples; steps 1 to 4 with the step 3
  template and the three step 4 offers; five Notes) has a row (rows 14 to 33).
- **Row 14, invocation examples, resolved:** now excluded as "already covered", quoting the
  description "critique, red-team, poke holes in, stress-test, or pre-mortem a PRD,
  strategy, or product direction". The quote exists (SKILL.md frontmatter) and does the
  job of the source examples: a pasted PRD is "a PRD", a one-line bet is "a product
  direction", the current doc is a PRD or strategy in context. Same cover accepted for
  row 15 in round 1.
- **Rows 26 and 28, Step 4 offers, resolved:** the default last line "More on request: ...
  an experiment for the top claim, a rewrite of the riskiest section." now offers them,
  and the On request block prints "Turn the top claim into an experiment:
  `/odeo:experiments`." and "rewrite the riskiest section of the plan" when asked. This
  does what the source step does (offer, then act on a yes).
- **Row 27, pre-mortem offer:** present. Pass 2 runs the pre-mortem by default, which
  exceeds the source's offer to complement the red team with one. See comment 1.
- **Row 33, ask before adding a second model:** the On request rule "print them only when
  the user asks, under `## Next steps`" holds it.
- **Excluded rows:** row 14 and row 15 "already covered" (quote exists, does the job);
  row 21 (title line) "adds length", unchanged decision named. All on the closed list.
- **Other checks:** frontmatter matches (`pm-execution/commands/red-team-prd`, `07b34f6`);
  method source line present by reference to critique-1; row shape valid; copy check
  clean; no personal field.

## Comments (not failing)

1. **critique-2 row 27** is marked `on request`, but the line that makes it present is
   Pass 2, which runs by default; the On request bullet "Run the pre-mortem alone" is not
   named in the "More on request" offer line, so that bullet itself is never offered.
   The substance of the source item (the user gets a complementary pre-mortem) is met by
   default, so this is not a FAIL; marking the row `default` would make it exact.
2. **Quotes with markup:** several rows quote SKILL.md with the bold markers dropped (for
   example row 14 of critique-1, row 34 "name it in the Top pick line"). The words match;
   noted only so a mechanical quote check is not surprised.

## History
- 2026-11-03: first review at 17af699. FAIL on critique-2: row 14 (invocation examples)
  pointed at example.md, which shows no invocation form; rows 26 to 28 (Step 4 offers)
  were marked `on request` but nothing offered them. Comment on critique-1 row 23 with the
  same root cause.
- 2026-11-03: re-review at 633b15c. Row 14 now excluded as already covered by the
  description; SKILL.md Output gained the default offer line "More on request: a second
  model's view, an experiment for the top claim, a rewrite of the riskiest section." and
  the On request block that prints them under `## Next steps` when asked; rows 23, 26, 27
  and 28 re-quote those lines. Both checklists re-judged in full. Verdict FAIL replaced by
  PASS; two non-failing comments.
