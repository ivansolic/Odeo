---
artifact: docs/plan-format.md
covers: docs/plan-format.md docs/skill-authoring-standard.md skills/build/SKILL.md
type: standard
branch: chore/adr-001-contracts-not-code
commit: 93536c7
artifact_version: 4
date: 2026-08-04
scorer: skill-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 10/10
---

Scope: form review of the three covered files, judged as an AUTHORING STANDARD (a
format agents must produce plus a rubric a gate scores), not as a `SKILL.md`.
`agents/architecture-reviewer.md`, `AGENTS.md` and `bin/language-status.sh` were read
as EVIDENCE only; `agents/` definitions belong to `agent-reviewer` and code belongs to
`code-reviewer`.

Round 4 is a NARROW re-verification: only `skills/build/SKILL.md` moved since v3, and
only its pipeline diagram. `docs/plan-format.md` and
`docs/skill-authoring-standard.md` were confirmed untouched since the passes that
cleared them and are NOT re-reviewed here.

Subject provenance at this record's HEAD `93536c7`:

| Subject | Last touched | Cleared in |
|---|---|---|
| `docs/plan-format.md` | `0ba0109` | v3 (10/10, every finding closed) |
| `docs/skill-authoring-standard.md` | `f8f8da6` | v2 (F11, F12 closed) |
| `skills/build/SKILL.md` | `f4e295a` | v4, this round |

The per-file last-touched commits are as reported by the coordinator from `git log`
per path; this session had no shell, so all CONTENT claims below are anchored to
lines read directly at HEAD, and no claim rests on the diff.

## Artifact: docs/plan-format.md + 2 coordinated files  (format spec, not invoked)

## Scores
- trigger clarity 2 (unchanged): `docs/plan-format.md:5-8` "**What \"exactly\" binds**
  (this list is canonical; other files cite it rather than restating it): signatures,
  paths, behavior rules, INVARIANTS, named mechanisms, test cases, verify commands,
  and boundaries. NOT the implementation shape". The canonical declaration is now
  load-bearing across the set (see round 4 below), which is what it was written for.
- structure 2 (unchanged): one `Consumes / Produces:` field at
  `docs/plan-format.md:92-94` before `Verify:`; declaration before use (`:42`, `:48`
  ahead of `:69`, `:75`); every section carries an escape (`:44`, `:50-51`, `:100`,
  `:110-113`) backed by `:120-124`. `docs/plan-format.md` 201 lines,
  `skills/build/SKILL.md` 239 lines, both well under 500, no supporting files, so the
  size and one-level rules are not at risk.
- worked example 2 (unchanged): `docs/plan-format.md:92-94` cites "local `C1
  (language status line)`" and `:52` declares "### C1: language status line", so the
  document's own reference resolves inside the document; the chain is one thread
  (`:71-73`, `:52-67`, `:92-94`, `:156-163`) and the values are verified real
  (`bin/language-status.sh:13-21`, `:53`, `:62`, `:66-72`).
  `skills/build/SKILL.md:202-221` still carries a concrete end-to-end run, untouched.
- precision 2 (unchanged, and slightly stronger): the four v2 gaps stay closed
  (`docs/plan-format.md:149-150`, `:182-185`, `:39-40`, `:92-94`). Round 4 removed a
  DRIFTED enumeration rather than adding a vagueness: the old inline list in the
  pipeline diagram ("signatures, behavior, invariants, tests, verify, boundaries")
  was not the canonical list, it dropped `paths` and `named mechanisms`, so a
  glance-reader was being taught a shorter contract than the one that binds.
- safety integration 2 (unchanged, and better held): `docs/plan-format.md:57-60`
  cites `AGENTS.md` Guardrails 1 as governing, `:173-175` assigns the graph walk to
  `architecture-reviewer` with the human reading at the gate, and
  `skills/build/SKILL.md:98-100` now REFERENCES the canonical binding list instead of
  carrying a fourth copy of it, which is the standard's own rule ("Never weaken or
  restate a guardrail; reference it", plus one name per concept everywhere). The
  file's own gates are untouched: spec gate `:12-16`, plan gate `:169-170`,
  `boundary-check.sh` `:183-185`, merge floor `:190-198`, safety rules `:230-238`.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## Ceiling
Max reachable 10/10, and it is reached. No criterion is structurally capped for this
artifact set.

## Round 4: the one stale subject, `skills/build/SKILL.md` at f4e295a

**What changed.** `:98-100` now reads "-> builder per story (own worktree, holds the
plan's contract exactly: the canonical binding list in docs/plan-format.md; the
implementation within it is the builder's)". Previously the same line re-listed the
binding items.

**(a) Does the citation improve or worsen this file? It improves it, and I would NOT
inline the list again.** The coordinator's concern is legitimate in principle (a
pipeline diagram is read at a glance, and a pointer costs a file hop), so here is the
reasoning rather than a rule-quote:
1. The inlined version was WRONG, not merely redundant. It read "signatures,
   behavior, invariants, tests, verify, boundaries" while the canonical list
   (`docs/plan-format.md:5-8`) is "signatures, paths, behavior rules, INVARIANTS,
   named mechanisms, test cases, verify commands, and boundaries". `paths` and
   `named mechanisms` were missing. For a surface read at a glance, an incomplete
   list is worse than a pointer: it teaches a smaller contract quickly, and
   `named mechanisms` is exactly the item a builder rationalizes away.
2. The glance value of this diagram is the ORDER and the three gates
   (`:95-104`), which is fully intact and unchanged. The enumeration was never what
   the diagram was scanned for.
3. The reader who needs the enumeration is the builder, and it reaches that actor
   through `agents/builder.md` and through the plan document itself, not through this
   diagram. The orchestrating session reading `/build` needs "the contract binds
   exactly, the implementation does not", which the line still says in full.
4. One name per concept across the system is a standard rule, and a four-way drift
   was the observed failure, not a hypothetical one.
   If the diagram feels heavy at three lines, the cheap fix is wording, not a second
   copy: "-> builder per story (own worktree, holds the plan's contract exactly, per
   the canonical list in docs/plan-format.md; the implementation is the builder's)".
   Cosmetic, my call would be to leave it as is.

**Honest self-correction.** My v1 pass called `skills/build/SKILL.md:98-100` a match
to `docs/plan-format.md:5-8` ("the smallest change, and it is clean"). That was a
match of REGISTER, not of items: I compared the two sentences for meaning and did not
diff the enumerations term by term, so I did not catch the drift that the parallel
`agent-reviewer` pass found. The finding is theirs, it is correct, and the lesson for
this reviewer is that any restated list must be diffed item by item against its
source before being called a match.

**(b) Nothing else in the file conflicts with the canonical-list pattern.** Checked
every place the file speaks about the contract:
- `:173-175` "executes its plan as a contract: success-signal, green baseline, tasks
  in order (dev-rigor style from CLAUDE.md), loop to the signal, stop-and-ask on any
  plan conflict" enumerates the builder's EXECUTION obligations, a different concept
  from what the plan BINDS. It is not a competing copy and needs no citation.
- `:30-31` ("builds to that plan's contract in its own worktree") and `:169-170`
  ("both are the builder's contract preconditions") carry no list.
- `:186-187` "contract adherence (any deviations from the plan)" carries no list.
- The file now cites `docs/plan-format.md` three times, `:60`, `:99`, `:153`, with one
  consistent name for the artifact and ZERO copies of the canonical list.
- Consequence stated plainly, not as a finding: a reader of `skills/build/SKILL.md`
  alone no longer learns the binding items anywhere in the file. That is the intended
  cost of a single-source list, and it is the correct trade here for the four reasons
  above.

**(c) The score does not move.** 10/10 holds, all five criteria at 2. The change is
neutral-to-positive on precision and safety integration and touches nothing else.
No new finding, and none of v3's cosmetic residues is affected.

## Cosmetic residue (carried from v3, still not blocking)
- **R1 `docs/plan-format.md:45-46` and `:107`, two illustrative values off the
  unified example thread** (the install `--overwrite` flag; a German-PRD success row
  proven by `tests/localized-prose.test.sh`, a file not in the example plan's File
  map). Both are real values and neither is cross-referenced, so nothing dangles.
- **R2 `docs/plan-format.md:185-186`, a wrap artifact** splitting "one dangling" /
  "reference" inside the rubric fence. One-line rewrap, no semantic effect.
- **R3 `docs/plan-format.md:153-154`, condition 3 does not say the reason may ride on
  the label line**, although the worked example does exactly that. Both placements
  satisfy the rule, so no gate consequence.
- **R4 (outside this artifact) `docs/evals/agent-architecture-reviewer.md:103` cites
  `docs/plan-format.md:169-176` for criterion 3**, now at `:182-194`. Line drift in
  another reviewer's record, refreshable only by that reviewer, not a merge blocker.
- **R5 (new, cosmetic) `skills/build/SKILL.md:98-100`**, the parenthetical now spans
  three lines inside the ASCII pipeline. Wording could shorten it if the diagram
  should stay lighter; do NOT re-inline the list.

## Prior findings
All closed; see the closure table in v3 (`git show` the previous version of this
record) for the line checked on each of F1-F15. Nothing reopened at `93536c7`: the two
files those findings live in are untouched since they were cleared.

## House style
No em or en dashes and no non-Latin characters in the three covered files. English
throughout. No versions, dates or "currently" introduced. No internal path or story
id in a publish-allowlisted file. `skills/build/SKILL.md` still bakes in no model
names, speaking in tier plus effort (`:37-56`), which the model-policy rule requires.

## Map duty
No command surface added or altered in round 4 (one wording inside an existing
diagram), so no `docs/system-map.md` delta is required. `/build` is already on the map
and its description is unchanged (`skills/build/SKILL.md:2`). Not a finding.

## Round-by-round
- Round 1 (2026-08-04, Opus 5 (1M), strongest, `aee5ab1`): 6/10 CHANGES-REQUIRED.
  Four blocking (F1-F4), five Medium, three Low.
- Round 2 (2026-08-04, Opus 5 (1M), strongest, `f8f8da6`): 7/10 CHANGES-REQUIRED.
  Structure 1 to 2; F13-F15 raised.
- Round 3 (2026-08-04, Opus 5 (1M), strongest, `0ba0109`): 10/10 PASS. Every finding
  closed at a named line; four cosmetic residues recorded.
- Round 4 (2026-08-04, Opus 5 (1M), strongest, `93536c7`): 10/10 PASS held.
  Narrow re-verification of `skills/build/SKILL.md` only; the canonical-list citation
  is an improvement (it replaced a drifted copy), nothing else in that file competes
  with the pattern, one cosmetic residue added (R5).

## Vs previous version
10/10 to 10/10, no criterion moved, no finding reopened. The only subject that changed
(`skills/build/SKILL.md:98-100`) got better on two criteria without reaching the level
boundary: precision (a drifted six-item list replaced by a pointer to the canonical
eight-item list) and safety integration (reference instead of restatement, one name
per concept). The record's `commit:` field moves `0ba0109` to `93536c7` so it no
longer claims a commit its subjects have moved past, and the subject-provenance table
now states per-file last-touched commits so a future reader can see WHICH subject a
given round actually verified.

## History
- v1 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, `aee5ab1`): 6/10
  CHANGES-REQUIRED, record created, F1-F4 blocking.
- v2 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, `f8f8da6`): 7/10
  CHANGES-REQUIRED; F1, F3, F5, F7, F9-F12 closed, F13-F15 raised, structure 1 to 2.
- v3 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, `0ba0109`): 10/10 PASS;
  F2, F4, F6, F8, F13, F14 closed and F15 closed on its operative part; worked
  example, precision and safety integration 1 to 2; verdict CHANGES-REQUIRED to PASS.
- v4 (2026-08-04, `claude-opus-5[1m]`, strongest, effort high, `93536c7`): 10/10 PASS
  held. Changed: regenerated because `skills/build/SKILL.md` moved to `f4e295a` after
  v3, so the record's `commit:` was stale for one of its three subjects. Added the
  round-4 verification of the canonical-list citation (kept, with the drift evidence
  that makes inlining the wrong fix), a self-correction of v1's item-blind "match"
  claim, a subject-provenance table, and R5. No score change, no finding reopened.

Note: this remains a FORM review, verified by reading the files at HEAD (no shell in
this session). What is left is BEHAVIORAL and is NOT covered by this PASS: whether the
architect declares each interface once and references it, and whether
`architecture-reviewer` catches a dangling reference, a `Consumed by:` set mismatch
and a missing `illustrative-not-contract:` label in a real plan. That is an `/improve`
subagent test. Standing calibration note for it: criterion 3 leaves a `Consumed by:`
set mismatch and a Success-signal row-count mismatch to the catch-all level 1, so
neither can force a 0 on its own; that is deliberate calibration, and
`docs/plan-format.md:182-194` is the line to revisit if the runtime test shows those
slipping through.
