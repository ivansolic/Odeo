---
id: PRD-003
title: PM skills with the method depth of the leading open collection and Odeo's rigor
status: draft
date: 2026-10-29
---

# PRD-003: PM skills with the method depth of the leading open collection and Odeo's rigor

## 1. Problem
After PRD-002, Odeo is a PM plugin and nothing else, so the quality of its PM skills is
the whole product. Measured against a widely used free alternative (the only one compared
here), those skills are rigorous but thin.

The comparison (read in full on 2026-10-29, repository `phuryn/pm-skills` at commit
`07b34f6`, MIT licence; 27,501 stars and 2,846 forks read the same day through the GitHub
API):
- **Method depth.** Its 69 skills and 42 commands hold 71,851 words; Odeo's 47 skills hold
  22,386 (word counts of the skill and command files on both sides). Most Odeo PM skills
  give steps and quality rules but no output shape: `critique` asks for "findings + ranked
  failure modes" with no structure, while the alternative's red-team returns, per
  assumption, the condition that breaks it, a kill criterion and the cheapest test.
- **Missing jobs.** Odeo has no skill to prepare a user interview (only to synthesise one
  afterwards), none to triage a batch of feature requests into decisions, and nothing that
  turns acceptance criteria into test scenarios, the thing PRD-002's riskiest assumption
  (H1, builders asking about edge cases) depends on.
- **Rigor that stops at three rubrics.** `pm-reviewer`'s scope names 17 kinds of document
  (`agents/pm-reviewer.md`, Scope); rubrics exist for PRDs, stories and research
  documents, the last of which is not one of the 17 named kinds. For the 15 named kinds
  without one (personas to signal memos) it falls back to the skill's own quality rules
  and flags the missing rubric. Odeo's differentiator (PRD-002, Context) is therefore real
  for PRDs, stories and research documents, and thin for the rest.
- **Odeo's own standard is unmet.** `docs/skill-authoring-standard.md` (item 4) requires a
  worked example with real values; 21 of the 47 skills have no section headed Example
  (heading check, 2026-10-29).
- **No record of what changed.** Odeo has no changelog and no version tags (repository
  read 2026-10-29); a user cannot see what a new version changes in the skills they rely
  on, and this PRD ships in three releases.

Who hurts (assumption, inferred from comparing the documents, not yet observed in users):
founders, entrepreneurs and PMs (PRD-002's audience) who get less method guidance from
Odeo than from a free collection they can install in a minute; and, observed, the
maintainer, whose claim of rigor does not yet hold across the skill set.

What the alternative lacks, and Odeo keeps: it has no rule against invented numbers (it
asks for customer acquisition cost, lifetime value, revenue projections and market size
from model memory), no sourcing of competitor facts, no scored review, no gates, and at
least one wrong formula (its A/B sample size leaves out statistical power). Depth without
these is not what Odeo adds.

Why now: PRD-002 makes PM content the entire offer, and the cut frees the maintenance
effort that went into the delivery half.

## 2. Outcome & success metrics
Outcome: a founder or PM who uses an Odeo PM skill gets a document whose structure, method
and evidence are at least as complete as the alternative's, and still meets Odeo's rigor:
every number sourced or labelled a hypothesis, and every document type in `pm-reviewer`'s
scope scored by a rubric.

Success metrics (targets):
- **Same depth as the source (primary, decided 2026-10-29 as what matters most):** for
  every Odeo skill that adopts from a source skill, a side-by-side checklist lists every
  step, output-template section, table column, decision rule and worked example of the
  source skill and shows each one present in Odeo's skill or excluded with a named reason
  from a closed list (a factual error, a number asked for without a source, a person
  credit or author link, wording that would be copied, a non-goal of this document, in
  which case the exclusion quotes that non-goal, already covered by an existing Odeo rule
  or step, which the exclusion quotes, or adding length without changing any decision the
  user makes, in which case the exclusion names the decision it leaves unchanged). Each
  adopted skill keeps a lean default and offers
  the deeper parts on request, so present does not mean always printed.
  Target: 100% of items present or excluded with a listed reason, for every adopted skill,
  in every release.
- **Pilot gate, then better than the alternative and than before (release 1):** first the
  pilot: only `prd` and `critique` are deepened (R1, R5), and for 3 sample ideas, one of
  them from a person who is not the maintainer, the PRD and critique are produced three
  ways: by Odeo before, by Odeo after, and by the alternative's own PRD, pre-mortem and
  red-team skills. A reader who is not the maintainer and is not told which document came
  from where prefers Odeo after in at least 3 of 3 ideas over both others, with the reason
  written down per idea. Only if the pilot passes does the rest of the work proceed (decided
  2026-10-29); if it fails, the reasons go back into this document before anything else is
  built. At the end of release 1 the same comparison runs again on the PRD, critique and
  stories (the alternative's stories skill as the third arm), and for one of the ideas the
  discovery documents release 1 changes are compared before and after in the same way. If
  that comparison fails, release 1 does not ship: each skill whose document lost is revised
  or returned to its before state, the reasons go into this document, and the comparison
  runs again.
- **Each later release improves what it changes:** for releases 2 and 3, for one sample
  idea, the documents that release changes are preferred after over before in the same
  kind of comparison, and each new rubric passes its calibration (R21).
- **Rigor everywhere:** every document type in `pm-reviewer`'s scope has its own rubric
  after release 3 (20 of 20: the 17 named today plus the 3 R21 adds; from 2 of 17), so
  the reviewer never reports a missing rubric. Research documents keep their own rubric.
- **Standard met:** every skill in the plugin at release time has a worked example with
  real values (from 26 of 47 by heading check), checked by the `skill-reviewer`
  worked-example criterion at 2.
- **No lost rigor (guardrail):** after each release, no skill asks for a number without a
  source or a hypothesis label, no skill names a person or a third-party plugin (lint C8),
  the lint and all test suites are green, and no `skill-reviewer` score is lower than
  before.
- **Leading signal, not a target (decided 2026-10-29):** stars and unique cloners of the
  public repository Odeo is installed from (not the development repository), read from the
  GitHub API. The API returns clones for the last 14 days only (GitHub REST documentation,
  traffic endpoints, read 2026-10-30), so cloners are read for the 14 days before release 1
  and the 14 days ending 30 days after it, and stars on both days. Flat
  numbers do not fail this document; they are the signal that the gap users feel may be
  awareness rather than depth (section 8, question 2).

## 3. Context
- Source of the comparison: three independent reads of the alternative, by area
  (discovery, research and analytics; strategy, go-to-market and marketing; execution,
  delivery and repository rules), plus a direct read of its PRD, stories, pre-mortem and
  red-team skills, all on 2026-10-29. Every adopted item below names the gap it closes.
- How content is adopted (decided 2026-10-29): structure as it is (templates, tables,
  steps, method names), the prose rewritten in Odeo's own words and passed through Odeo's
  guardrails. No text is copied, so the MIT licence puts no notice obligation on Odeo, and
  lint C8 (no person credits, no third-party plugin names) stays as it is. Ideas and
  methods are not covered by copyright; wording is.
- Scope of adoption (decided 2026-10-29): the full adopt list from the comparison plus the
  optional frameworks (Ansoff, Porter, PESTLE, SWOT, sentiment and NPS, job stories and
  WWA) as modes inside existing skills, not as new skills.
- Already done on this branch (commit `e9288b6`): every skill starts when the user asks for
  it in words or says yes to an offer. This is PRD-002 R15, done here first; the two
  branches reconcile when this one is rebased onto `main`.
- Constraint: PRD-002 is in its stories phase in a parallel branch. This PRD changes skill
  bodies, rubrics and adds skills; it does not touch what PRD-002 owns (the package, the
  setup, the session baseline, the README and CONTRIBUTING rewrite). PRD-002 merges two
  setup skills into one, so skill counts here are stated "at release time", not as a
  fixed number.

## 4. Hypotheses & assumptions
- **H1 (riskiest): more method makes documents better, not just longer.** The alternative's
  PRD is deliberately one to two pages; adding templates and sections to every Odeo skill
  can bloat the output and slow the user. Tested first, and cheaply, by the pilot gate on
  `prd` and `critique`. Wrong if: in the pilot or the release 1 comparison Odeo after loses
  any idea to either other arm, or any "after" document of the comparison (PRD and critique
  in the pilot; PRD, critique and stories at the end of release 1) runs more than 50% longer
  than "before" for the same idea without a higher `pm-reviewer` score (for the critique,
  which has no rubric, without the reader preferring it). Length is measured on the lean
  default output, without depth requested.
- **H2: rewriting in Odeo's words keeps the substance.** Wrong if: a reviewer comparing an
  adopted section with its source finds a step, criterion or table column lost that the
  requirement names.
- **H3: rubrics written from templates measure quality, not form.** A rubric that rewards
  filled-in sections teaches the model to fill sections. Wrong if: in calibration a
  deliberately hollow document (every section present, no evidence) passes a new rubric.
- **A1: the alternative's methods are sound where adopted.** Each adopted method is checked
  against its primary source before it goes in; its known errors (the sample-size formula,
  unsourced claims such as capturing "60-70% of a segment in 3-18 months") are not adopted.

## 5. Scope
In, in three releases (decided 2026-10-29), each one shippable on its own and each
shipping the rubrics listed for it below (18 in all, R21); documents that are not in
`pm-reviewer`'s scope, such as a critique, an interview script, a meeting summary or an
A/B test reading, get no rubric and are held to their skill's quality rules and, where
the skill adopts from a source skill, the depth checklist (R24):
1. **Release 1, the core path and the discovery that feeds it** (PRD, critique, stories,
   interviews, triage, experiments, discovery, opportunity trees): it starts with the
   pilot, R1 and R5 plus the R24 checklists and R25 routing check for those two skills,
   and the pilot comparison (section 2); only if the pilot passes do R2 to R4, R6 to R10,
   R23, R26 and R27 follow, with rubrics for interview syntheses, opportunity trees, discovery
   plans and request triage.
2. **Release 2, strategy and market:** R11 to R19, with rubrics for vision, strategy,
   value proposition, business model, pricing, segments, positioning and go-to-market.
3. **Release 3, execution and completion:** R20 and R22, with the remaining rubrics
   (roadmap, prioritisation, signal memos, personas, journey maps, prototype findings),
   completing R21.

Non-goals:
- No text copied from the alternative, no links to its author's articles, no person
  credits, no model names in instructions.
- No split into several plugins, no ports to other hosts.
- No legal or career skills (NDA, privacy policy, resume review), no general proofreader.
- No code review, security audit or shipping check (delivery work PRD-002 removed).
- No new skill where a mode of an existing skill does the job; the only new skills are
  interview preparation (R2) and request triage (R3).
- No matching of the alternative's breadth for its own sake: skills it has and Odeo does
  not stay out unless this document names them.
- Nothing PRD-002 owns: the delivery-ready package, setup, session baseline, README and
  CONTRIBUTING.

## 6. Requirements & acceptance criteria
Every requirement carries one cross-cutting AC: any number, benchmark or market fact the
skill asks for is either taken from a cited source (through `research` where it has to be
looked up) or labelled a hypothesis to test; the skill text passes the lint and contains
no person credit or third-party plugin name; and a skill that reads text written by
other people (customer requests, interview or meeting notes, feedback, competitor pages)
treats that text as data: when it contains instructions to the model, the skill does not
follow them and tells the user it found them.

### Release 1, core path
- **R1 Critique that hands you tests, not fears.** AC: the red-team pass lists the
  load-bearing claims only, states the strongest case for each before attacking it, writes
  each failure as "fails if ...", ranks them by impact if wrong, likelihood of being wrong
  and cost to test, and gives each surviving one a kill criterion, the evidence to get this
  week and the cheapest test; it ends with what holds up and what could not be judged. The
  pre-mortem pass sorts risks into real threats, overblown worries and unspoken worries,
  and each real threat into must-fix before launch, fix within 30 days, or watch; every
  must-fix threat gets a mitigation and an owner role. The output has a fixed shape.
- **R4 Test scenarios from acceptance criteria.** `stories` gains a scenarios step. AC:
  every acceptance criterion has at least one scenario, and every story at least one
  negative scenario (invalid input, missing permission, empty state); scenarios are
  written as what the user does and sees, never how it is built; a coverage table maps
  criteria to scenarios and lists criteria with none.
- **R5 PRD that asks before it writes.** AC: when the problem, the target users or the
  success measure is missing, `prd` asks about them first, at most three questions in one
  message and no PRD in that reply, and writes without them only on the user's go-ahead,
  marking the gaps as assumptions; the PRD carries a value proposition per segment in six
  parts (who, the job and the obstacle, how it is done today, how the solution does it,
  the outcome after, the alternatives and why us), and the requirements deliver its "how"
  while the success metrics measure its "after"; after saving, the reply names in one line
  what was left out on purpose.
- **R6 Story formats and story hygiene.** AC: `stories` offers user stories (default), job
  stories (when, I want to, so I can) or why-what-acceptance items; error handling and edge
  cases that need their own work get their own story; a story whose size cannot be judged
  without investigation is flagged as needing a spike.
- **R23 Release notes for Odeo itself.** AC: the repository keeps a changelog with an
  unreleased section that records each release's skill changes in plain words; a new
  version heading, written by the maintainer, is the release decision; a test fails when
  the plugin version and the newest heading disagree.
- **R24 Same depth as the source, checked (every release).** AC: before a release ships,
  each adopted skill has the side-by-side checklist of the primary metric: every step,
  output-template section, table column, decision rule and worked example of the source
  skill is present in Odeo's skill or excluded with a reason from the closed list; each
  adopted method is checked against its primary method source; and no wording is copied
  (no sentence of more than eight words identical to the source). The checklists are
  saved with the release, and before the release ships `skill-reviewer` checks each one
  against the source skill at the read commit: every item accounted for, every exclusion
  reason from the closed list, every "adds length" exclusion naming the user decision it
  leaves unchanged; a checklist it rejects blocks the release. The check also confirms that no
  adopted template has a field for a person's name or contact detail.
- **R25 Skills still route correctly when started by asking (every release).** AC: before
  each release, for each skill a request in plain words that should start it does, and its
  two nearest neighbours (for example `prd` and `stories`, `critique` and `experiments`,
  and the two new skills against `interview-synthesis` and `product-signal`) are not
  confused, checked on a written list of sample requests that grows with each release.
  The same list also runs with the alternative collection installed next to Odeo (decided
  2026-10-29); the result is written down per request, and an Odeo skill that loses a
  request it should win gets a sharper description before the release ships. The
  alternative is installed, here and for the pilot's third arm, only at the commit that was
  read (`07b34f6`, or a newer commit read in full first), in a separate profile with no
  private repositories, credentials or connected services, and removed afterwards. (Read
  2026-10-29: at `07b34f6` it ships markdown only, no hooks, scripts or server
  configuration.)
- **R26 Meeting summary as a mode (decided 2026-10-29).** `interview-synthesis` gains a
  meeting mode. AC: from meeting notes it separates what was discussed from what was
  decided, lists each decision with its date and who decided it by role, lists action
  items with an owner role and flags any action without an owner, and lists open
  questions; participants appear by role, never by name or contact detail.
- **R27 Planted-instruction check (every release, from the first skill that reads text by
  others).** AC: before each release, every skill that reads text written by other people
  (R2, R3, R10, R17, R18, R26 and `product-signal`) is run on one sample input that
  contains a planted instruction to the model; the skill does not follow it and tells the
  user it found it; the result is written down per skill next to R25's list, and a skill
  that follows the instruction blocks the release.

### Release 1, discovery
- **R2 Interview preparation.** A new skill prepares a user interview. AC: it produces a
  timed script (opening, past behaviour, problem depth, current alternatives, wrap-up)
  whose questions ask about past behaviour, never about hypothetical futures or opinions
  of the idea; each question states why it is asked; it includes follow-up probes, a
  note-taking template that records participants by role or code, never by name or
  contact detail, and the warning signs of a misleading interview; it hands over to
  `interview-synthesis`.
- **R3 Feature request triage.** A new skill takes a batch of requests (pasted or a file)
  and returns decisions. AC: it groups requests into themes by the underlying need, not the
  requested feature; it shows each theme's volume and the segments asking; it places each
  theme in one of four buckets, act now, plan next, collect more signal, decline, with a
  reason, and gives the reason for every decline; it flags requests that contradict each
  other; it never counts a request as evidence of a need without the need being stated;
  its saved output carries no names, email addresses or other contact details from the
  input, only themes, counts, segments and quotes stripped of identifying details.
- **R7 Experiments with sharper hypotheses.** AC: every hypothesis is written as "at least
  X% of Y will do Z"; evidence where the participant commits something (money, time, data)
  counts above stated interest; for a new product the assumptions cover eight risk areas
  (value, usability, feasibility, viability, ethics, go-to-market, strategy, team) with a
  probing question each; a test on a live product states how users are protected if it
  goes wrong.
- **R8 Discovery that ends in a plan.** AC: `discover` ends in one discovery plan with an
  assumptions table, an experiments table, a week-by-week timeline and a decision rule per
  experiment (if it passes, then ...; if it fails, then ...).
- **R9 Opportunity trees that pick a target.** AC: `opportunity-solution-tree` scores
  opportunities by importance and current satisfaction to choose the target, phrases
  opportunities in the customer's words ("I struggle to ..."), and asks for at least three
  solutions per chosen opportunity.
- **R10 Interview synthesis with a shape.** AC: `interview-synthesis` uses a fixed
  template per interview, a table of assumptions confirmed or contradicted, flags
  contradictions within one interview, synthesises across interviews, and refers to
  participants by role or code, never by name or contact detail.

### Release 2, strategy and market
- **R11 Strategy that survives a coherence check.** AC: `strategy` covers cost position,
  capabilities (build or partner), what competitors cannot or will not copy, and a
  trade-off table (we choose, over, because); it checks the parts reinforce each other; it
  offers optional modes for growth direction (Ansoff), macro factors (PESTLE, factors
  sourced through `research`) and strengths and weaknesses (SWOT).
- **R12 Vision drafted wide.** AC: `vision` drafts three to five variants before choosing
  one, with the reason for the choice.
- **R13 Business model with a viability check.** AC: `business-model` says when to use
  which canvas (lean, business model, startup), and checks lifetime value against
  acquisition cost only from real data, saying "no data" otherwise.
- **R14 Pricing grounded in tests.** AC: `pricing` diverges over three to five monetisation
  models before choosing, includes a willingness-to-pay method (price sensitivity
  questions), a competitor price benchmark through `research` with sources, a migration
  plan for existing customers, and a pricing experiment.
- **R15 Value proposition with before and after.** AC: `value-proposition` states how the
  job is done today and what changes after, and produces statements ready for marketing,
  sales and onboarding.
- **R16 Metrics with a North Star that holds up.** AC: `metrics` classifies the product's
  business game (attention, transaction, productivity), validates the North Star against
  explicit criteria in a pass or fail table, breaks it into three to five input metrics
  with an owner role each, pairs every gameable metric with a counter-metric, marks
  leading and lagging, and sets thresholds and a review cadence.
- **R17 Segments, ideal customer and beachhead with scoring.** AC: `market-segments` scores
  candidate beachheads on pain, willingness to pay, winnable share and referral potential,
  derives the ideal customer from existing customer data when there is any (best retained,
  fastest to value), lists disqualification criteria, and offers a segment-from-user-data
  mode; when it reads customer data it works on aggregates and traits, and its saved
  output names no individual customer or person and carries no contact details.
- **R18 Competition with a decision.** AC: `competitor-analysis` separates table stakes
  from differentiators, recommends per gap whether to double down, close it or ignore it,
  and offers an industry forces section (Porter); `battlecard` adds the questions a rival
  coaches prospects to ask, win and loss patterns, and a last-updated date with a refresh
  reminder; every competitor fact is cited.
- **R19 Go-to-market with motions and messages.** AC: `gtm-plan` chooses among the
  go-to-market motions (inbound, outbound, paid, community, partners, account-based,
  product-led) against price and sales cycle, names no vendor tools, writes a message per
  stakeholder, and lays out pre-launch, launch week and post-launch in a table;
  `positioning` and `marketing` produce a message matrix (audience, message, proof, call to
  action).

### Release 3, execution and completion
- **R20 Execution skills deepened.** AC: `okrs` offers two to three alternative objectives
  before converging, explains OKR versus KPI versus North Star in one paragraph, pairs each
  gameable key result with a counter-metric and names the goal it serves; `roadmap` can
  convert an existing feature roadmap into outcomes ("enable segment to outcome so that
  impact"), asks "so what?" until the value is reached, gives each item a success metric,
  asks who the roadmap is for, and flags features that serve no outcome; `prioritize` can
  rank problems by importance and satisfaction before features; `release-notes` adds a
  deprecations bucket and tone by audience; `stakeholder-map` adds the often-missed
  stakeholders, a conflicts section and an optional decision-rights table; `growth-loops`
  adds the collaboration loop; `product-signal` segments satisfaction scores and labels
  model-judged sentiment as approximate; `ab-test` adds an outcome decision table, the
  novelty and primacy check, "underpowered means extend, not no effect", and an impact
  range from the confidence interval, and any sample-size formula it gives includes power;
  `cohorts` adds a no-data-yet path and the founding-user and seasonality caveats.
- **R21 A rubric for every document type (across releases 1 to 3).** AC: `pm-reviewer`'s
  scope gains the three document types this PRD makes central (discovery plans, request
  triage results, segment and ideal customer documents); each of these 3 and each of the
  15 types in its scope without a rubric today gets one, 18 in all, shipped in the release
  section 5 lists it under, scored 0 to 2 per criterion, rewarding
  evidence and decisions over filled sections; each new rubric is calibrated on one strong
  and one deliberately hollow document, and the hollow one fails.
- **R22 A worked example in every skill.** AC: every skill in the plugin at release time
  without one gains a worked example with real values; `skill-reviewer` scores the
  worked-example criterion at 2 for every skill.

## 7. Risks & dependencies
- **Bloat (H1).** Every requirement adds content. Mitigation: each skill keeps a lean
  default and offers depth on request, as the alternative's PRD does; the length check in
  H1 is the signal.
- **Form over substance in rubrics (H3).** Mitigation: the hollow-document calibration in
  R21 blocks a rubric that rewards filled sections.
- **Wording drift towards the source (licence).** Mitigation: R24's identical-sentence
  check; adopting from a read of the source, writing from the requirement.
- **Merge conflict with PRD-002.** Both branches touch skill files; the invocation change
  (`e9288b6`) duplicates PRD-002 R15. Mitigation: this branch rebases onto `main` after
  PRD-002 merges and before release 1 is built; skill bodies here, frontmatter there.
- **Inherited errors (A1).** Mitigation: every adopted method checked against its primary
  source; the known errors are listed in A1 and excluded.
- **Mis-routing.** With every skill now started by asking, neighbouring skills can steal
  each other's requests, worse with two new skills in release 1. Mitigation: R25's sample
  request check before every release, starting in release 1.
- **Popular for breadth, not depth.** The alternative's appeal may come from its 69
  skills, not their depth, in which case deeper Odeo skills do not close the gap users
  feel. Mitigation: the third arm of the release 1 comparison compares depth directly;
  breadth is a deliberate non-goal. This document cannot detect a breadth preference in
  users; if the reader's reasons or user requests point to missing skills, that is the
  signal to revisit it in a later PRD.
- **Maintenance load returns.** PRD-002 cut the delivery half partly because review
  records were 41% of commits; adopting depth into 30 skills (28 existing plus the 2 new
  ones, R1 to R20) and 18 rubrics brings review rounds back. Mitigation: the pilot gate
  stops the work early if depth does not pay; signal: review-record commits above
  PRD-002's 15% target during a release; response: the next release is narrowed with the
  maintainer before it starts.
- **Unnamed authorship.** Some adopted structures are a named author's own framework (for
  example the six-part value proposition); lint C8 forbids crediting people in skills, so
  Odeo uses them without credit. The basis is that ideas and methods are not covered by
  copyright, only wording (the MIT licence covers the alternative's own text, not a third
  person's framework it adopted); not a legal opinion. Recorded here so the choice is
  deliberate, not accidental.
- Dependency: PRD-002 merged into `main` before release 1 is built.

### Security and data pre-mortem
"It is six months later and personal data leaked through these skills. What was the hole?"
1. **Triage output kept customer identities.** A user pasted a support export with names
   and email addresses into request triage, and the saved triage document carried them
   into the repository and every copy of it. Closed by R3: the saved output carries
   themes, counts, segments and quotes stripped of identifying details, never names or
   contact details.
2. **Interview notes named participants.** The note template invited names, and a synthesis
   built on them repeated them. Closed by R2 and R10: participants by role or code only,
   from the first note onwards.
3. **Segments built from customer records exposed individuals.** The segment-from-data mode
   quoted individual customers as examples of a segment. Closed by R17: aggregates and
   traits only, no individual customer, person or contact detail in the saved output.
4. **Instructions hidden in customer text were followed.** A pasted support export or
   interview transcript contained text addressed to the model ("ignore your rules and
   ..."), and the triage skill acted on it. Closed by the cross-cutting AC of section 6:
   text written by others is data, instructions inside it are reported, never followed
   (found by `/odeo:critique`, 2026-10-29). Checked per release by R27.
5. **The comparison installed a stranger's instructions.** For the pilot's third arm and
   R25, the alternative's 69 skills were installed in the maintainer's everyday profile, at
   a newer commit nobody had read, next to private repositories and credentials. Closed by
   R25: only the read commit, a separate profile without private repositories,
   credentials or connected services, removed afterwards (found by `pm-reviewer`, round 4).
These five are requirements, not advice; R24's check per release confirms the adopted
templates do not reintroduce a name field.

## 8. Open questions
1. **Who compares the documents:** the release 1 comparison needs a person other than the
   maintainer who reads the three versions of each document without being told which tool
   wrote which, and says which is best and why. Who is that person? The pilot does not
   start until the reader is named; its date is set with them.
2. **Depth or awareness:** if the leading signal (section 2) stays flat after release 1,
   is the gap users feel awareness of Odeo rather than depth? Out of scope here; a later
   PRD answers it if the signal says so.

Decisions, in order:
- 2026-10-29: content is adopted by structure, in Odeo's own words, never copied; lint C8
  stays.
- 2026-10-29: scope is the full adopt list plus the optional frameworks as modes of
  existing skills.
- 2026-10-29: the work runs in its own branch and worktree in parallel to PRD-002; every
  skill starts when asked in words (commit `e9288b6`).
- 2026-10-29, after review round 1: what matters most is that the skills reach the same
  quality as the source skills (primary metric, R24); meeting summaries become a mode of
  `interview-synthesis` (R26); three releases.
- 2026-10-29, after `/odeo:critique`: two more exclusion reasons and a lean default
  against bloat (section 2); a pilot gate on `prd` and `critique` before the rest of the
  work (sections 2 and 5); the routing check also runs next to the alternative (R25);
  stars and cloners as a leading signal only; text written by others is data (section 6,
  pre-mortem item 4); adopted frameworks of named authors are used without credit, as
  lint C8 requires (section 7, unnamed authorship).
- 2026-10-30, after review round 4: all reviewer comments applied: the alternative is
  installed only at the read commit in a separate profile (R25, pre-mortem item 5); the
  planted-instruction check (R27); `skill-reviewer` verifies the depth checklists (R24);
  H1's length rule covers the critique and the lean default; a fail path for the end of
  release 1; the leading signal reads the public repository within the API's 14-day window.
