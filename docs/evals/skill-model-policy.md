---
artifact: skill-model-policy
type: skill
artifact_kind: skill
covers: build setup-project start
branch: main
date: 2026-07-18
scorer: skill-reviewer
model: claude-fable-5[1m]
model_tier: strong
scores:
  build:         { trigger: 2, structure: 2, example: 1, precision: 2, safety: 2, total: 9 }
  setup-project: { trigger: 2, structure: 2, example: 2, precision: 1, safety: 2, total: 9 }
  start:         { trigger: 2, structure: 2, example: 1, precision: 2, safety: 2, total: 9 }
verdict: PASS
---

# Skill review: model-policy change (commit 7979e9d; build, setup-project, start)

Threshold per skill: total >= 8/10 AND no criterion at 0. All three pass, no
zeros. Tier note: the harness reports `claude-fable-5[1m]`; the AGENTS.md tier
map carries no fable entry, so `strong` is the conservative honest
classification (it is not fast-tier; whether it is "strongest" on this
subscription is unverifiable from inside the session).

## Evidence per deciding score

- **build, example 1**: the worked example (USR-012 block) does NOT show the
  new mandatory step. The process says "Model plan, asked before any work" and
  "In for-me mode, write the answer into the plan file as `model_plan:`", but
  the example jumps from "> for me" straight to `worktree-parallel-check`, no
  model-plan question, and the plan line shows no `model_plan:` even though
  plan-format.md and the builder's contract require it. Imitating the example
  verbatim skips a guardrail-mandated question. All other criteria 2: explicit
  command with example invocation in the description; lean structure; exact
  names (`model_plan:`, `/model`); question phrasing is right ("Continue with
  these, or change...?", "question, not a block, the choice is the user's").
- **setup-project, precision 1**: H2 says "Code execution always rides the
  newest fast-strong tier", "fast-strong" exists nowhere in the AGENTS.md tier
  map (fast | strong | strongest; execution = sonnet class = strong). An agent
  told to resolve "the newest fast-strong tier" live has no defined referent,
  and "fast" risks being misread as the haiku class. Everything else exact
  (`session_model_preference: strongest | strong-default`, "never a model
  name (names age; the preference must not)"). Trigger 2: "Use when a project
  needs configuring:" + triggers only (fixed since the prior record). Example
  2 per the established convention for interview skills: verbatim ask-scripts
  with concrete option labels; H2's "(name + price as resolved now)"
  placeholders are forced by the no-baked-names invariant, by design.
- **start, example 1** (unchanged from prior record): output shape is an
  `<angle-bracket>` template; the new preference-mismatch line is itself a
  quoted script ("session runs on <current>, your preference means <resolved
  now>, /model to switch"), imitable but no worked run with real values.
  Trigger 2 (fixed since prior record: "Use when the user asks 'where are
  we'..."). Precision 2 with one clarity note: "Also note when a NEW top model
  exists" names no detection mechanism; it is only derivable as the
  preference=strongest case of the mismatch check (no stored name to compare
  against, correctly, since storage is semantic).

## Invariant checks (the five asked)

1. **No baked names/prices**: CLEAN in all three skills, AGENTS.md,
   builder.md, plan-format.md, and the four reviewer agents. Only tier words
   and resolve-live instructions ("Resolve LIVE what the harness is actually
   running", "ask the harness/session what tiers and prices exist right now").
   Flagged for human judgment, prose names that remain elsewhere:
   `docs/invariants.md:19` C11 rationale column ("the 'Sonnet 4.6' stale-name
   incident while Sonnet 5 was already out") and the same lore in a
   `bin/skills-lint.sh:92` comment; both are incident history, not
   instructions, but they are prose names in files. `docs/checklists/
   dogfood-results.md` ("Model: Opus 4.8") is a dated record, names allowed.
2. **Question, not FYI**: build phrases it as a question and even the
   below-strong warning is "(question, not a block, the choice is the
   user's)"; setup-project H2 is a question; matches guardrail 3 [I] ("put to
   the user as a QUESTION before work starts"). start's one-liner is an FYI,
   acceptable: /start is read-only status, starts no work, and "/model to
   switch" leaves the act to the user.
3. **Semantic storage**: setup-project records
   `session_model_preference: strongest | strong-default`, "never a model
   name"; AGENTS.md says the same. Consistent.
4. **No contradictions on defaults**: AGENTS.md (judgment = session model,
   execution = sonnet tier resolved to newest), build ("session model for
   judgment; the builder's tier alias for execution"), builder.md (`model:
   sonnet`, "the human flips your `model:` to `inherit`, never you"),
   plan-format.md (`model_plan:` block, builder requires it), start (mismatch
   reminder mirrors H2's "/start reminds..."). One vocabulary defect:
   setup-project's "fast-strong tier" (scored under precision). One doc-drift:
   AGENTS.md says names are "recorded after (`model:` + `model_tier:` in eval
   records). Files speak in tiers; versions never appear in them", yet
   plan-format.md's `model_plan:` intentionally records resolved names in plan
   files ("builder: <tier -> model>"). Plans are per-run records like evals,
   but a strict reader of AGENTS.md would conclude plans must speak tiers
   only. The sentence should name `model_plan:` alongside eval records.
5. **Lettering after H2**: coherent. A-J intact, H2 sits between H and I, the
   EXISTING-path cross-reference "step H below" still resolves, numbered
   top-level steps 0-5 untouched. (The prior record's lettering complaint is
   fixed.)

## Map duty

No new command added (existing /build, /setup-project, /start; H2 is an
interview step). `docs/system-map.md` unaffected. Satisfied / N-A.

## Record contract (the four reviewers)

pm-reviewer, skill-reviewer, design-reviewer, code-reviewer all carry the
`model:` + `model_tier: fast | strong | strongest` declaration and the
fast-tier-refusal note. Consistent with merge-gate/spec-gate tests
(`model_tier:` fixtures present).

## Top fixes

1. build worked example: insert the model-plan question and answer between the
   mode choice and the pipeline, and add `model_plan:` to the plan line, e.g.
   after "> for me" add: `"Model plan: thinking/reviews on <session model>,
   building on <builder tier>. Continue?" > yes` and change the architect line
   to `docs/plans/2026-07-14-usr-012-timer.md (approved: no, model_plan: set)`.
2. setup-project H2: replace "the newest fast-strong tier" with the tier map's
   word, e.g. "the newest strong execution tier (the builder's pinned tier,
   see AGENTS.md Model policy)".
3. AGENTS.md Model policy, third bullet: extend "recorded after" to
   "(`model:` + `model_tier:` in eval records; `model_plan:` in approved
   plans)" so plan-format.md stops contradicting the letter of the policy.
4. start: tie the new-top-model note to its mechanism: "when the preference is
   `strongest` and the live top tier differs from the session model, phrase
   the mismatch line as: your 'strongest' now points to <name>". As written,
   "note when a NEW top model exists" has no source of truth.
5. Human call: decide whether incident-history prose names
   (docs/invariants.md C11 rationale, bin/skills-lint.sh comment) are exempt
   from the no-names rule; if yes, say so once in the invariants header.

## Vs previous version

Prior coverage: `docs/evals/skill-dogfood-fix-batch.md` (2026-07-13).
- build: 9 -> 9. The prior "no end-to-end worked run" fix WAS implemented
  (USR-012 block exists), but the example now lags the new model-plan step, so
  example stays 1 for a new reason. No regression, no gain.
- setup-project: 9 -> 9. Trigger 1 -> 2 (description now starts "Use when...")
  and the lettering fix landed; precision 2 -> 1 (new "fast-strong tier"
  wording). Net flat.
- start: 8 -> 9. Trigger 1 -> 2 (description rewritten to triggers only).
  Improvement.

## History

- 2026-07-18, v1 of this record: first review of the model-policy change
  across build/setup-project/start. PASS (9/9/9). Behavioral note: whether
  sessions actually ASK the model question before work (rather than
  announcing) is runtime behavior; recommend /improve subagent testing on
  /build's model-plan step, form looks fine.
