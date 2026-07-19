---
artifact: skill-prototype
type: skill
branch: main
artifact_version: 2
date: 2026-07-19
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
previous_total: 9/10
---

## Findings

- **Trigger clarity (2):** Explicit command (`disable-model-invocation: true`),
  so the correct format is plain what-you-get-and-when, and the description
  delivers both: "spin up N disposable working prototypes in parallel ...
  compare them live, kill the weak ones, and capture the winner's learnings as
  findings that feed the real build. Use when an idea is concrete enough to
  touch but you don't know which shape is right." No example invocation needed;
  the shape is a bare `/prototype`.
- **Structure (2):** Follows the body shape at 107 lines: one-line essence
  ("build 2-3 cheap working variants, FEEL them, keep the best, throw the
  rest"), Preconditions, 8 numbered process steps, output path in step 7
  (`docs/prototypes/<idea>/findings.md`, committed on
  `chore/prototype-findings`), findings checklist, "Rules for yourself".
  Progressive disclosure respected: the full findings example lives one level
  away at `docs/examples/prototype-findings-example.md` (verified present).
- **Worked example (2):** Concrete throughout and completed by the reference
  file: inline framing example ("which invoicing flow feels effortless?"),
  the derivation example with a real shape ("PRD-002 says the problem is X
  for persona Y, proposed framing: ... confirm or correct"), runnable commands
  (`open http://localhost:3001`, `code --add <a> <b>`,
  `share-tunnel.sh <port> [minutes]`), and the referenced example file is a
  real, imitable findings document.
- **Precision (2):** Now exact throughout, both round-1 gaps closed.
  (a) Step 1 names the canonical location: "If PM artifacts already exist
  (docs/prds/, or docs/research/ holding discovery packets and RES-NNN
  research reports)", which matches the canonical home in
  skills/discover/SKILL.md line 22 ("A discovery packet in `docs/research/`");
  the derive-vs-ask trigger check no longer leaves the agent guessing where to
  look. (b) The step-1 recording mandate now survives into the durable-handoff
  contract: the findings checklist carries "source document tested (PRD/RES id,
  or \"none, no PM artifacts existed\")", so a later promote can find what it
  updates. Remaining exact anchors unchanged (branch name, `~/bin` with repo
  fallback `bin/privacy-scan.sh`, `docs/prototypes/.shares`, `?v=<timestamp>`).
- **Safety integration (2):** References guardrails without weakening or
  restating: sharing is "outward = gated" with "your explicit OK + privacy
  scan, fake data only"; `privacy-scan.sh` run before exposure with an honest
  fallback ("only if truly absent, do a manual equivalent scan and show the
  results"); public-repo consequence surfaced ("say so plainly and get an
  explicit go"); exposure lifecycle owned (TTL floor, `.shares` record,
  teardown confirmation); and the rigor exception is explicitly fenced
  ("applies ONLY inside this skill; promotion re-enters full discipline").

## Cross-checks

- **Map duty:** satisfied, `/prototype` present in docs/system-map.md; no new
  command added by this change.
- **One-level-deep rule:** satisfied; the only supporting reference
  (`docs/examples/prototype-findings-example.md`) is one hop and exists.
- **Scripts referenced exist:** `bin/privacy-scan.sh` and `bin/share-tunnel.sh`
  verified present in prior round; unchanged.
- **Integrity check:** voice and terminology match this repo's house style; no
  verbatim-copied external text detected.

## Top fixes

None. All five criteria at 2; no fixes required for form.

- Behavioral note, not a form defect: whether agents actually DERIVE the framing
  question instead of re-asking when a PRD/RES exists is runtime behavior;
  verify via /improve subagent testing if not already done.

## History

- 2026-07-19, v2 (this record): re-review, round 2. Both round-1 precision
  gaps were fixed and verified in the working tree, so precision goes 1 -> 2 and
  total 9/10 -> 10/10 (verdict stays PASS).
  Fix 1: step 1 now names the exact artifact location "(docs/prds/, or
  docs/research/ holding discovery packets and RES-NNN research reports)"
  replacing the vague "(docs/prds/, a discovery packet, research reports)";
  `docs/research/` matches the canonical home in skills/discover/SKILL.md line 22.
  Fix 2: the findings checklist now carries "source document tested (PRD/RES id,
  or \"none, no PM artifacts existed\")", so the step-1 recording mandate is
  carried into the durable handoff a promote depends on. No other content
  changed; the other four criteria remain at 2.
- 2026-07-18, v1: first persisted eval record. Total 9/10, PASS, precision 1/2.
  Two precision gaps found in the then-new step-1 PM-artifact bridge: (a) an
  unnamed docs/research/ path, (b) a missing checklist field for the tested
  document. Both flagged as one-line edits; both now addressed in v2.
