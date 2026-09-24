---
description: Get a paid, independent SECOND OPINION on an implementation plan from an external vendor model, then weigh it against OUR architecture-reviewer. Explicit command (data leaves the machine and costs money); run it on a risky or hard-to-reverse plan, a large epic, or a contested architectural call. Example: "second opinion on the sync-engine plan".
disable-model-invocation: true
---

# Second opinion (plan)

Get an INDEPENDENT cross-model review of an implementation plan from an external
vendor CLI, then weigh it against OUR `architecture-reviewer`. The vendor INFORMS;
our review still governs. The shared mechanism and rules live in
`${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md` (read it; not restated here).

## When to use (and when not)
- Use on a risky plan: a hard-to-reverse architectural choice, a large epic, or a
  contested call where a second architectural read is worth paying for.
- Covers what `architecture-reviewer` weighs: module boundaries, data flow,
  failure modes, and 2-year maintainability of the PLAN (not the finished code,
  that is `second-opinion-code`).
- Human-invoked only. Data leaves the machine and it costs money; it never
  self-runs, offered once at the triggers, never after a decline.
- Not for: routine plans (our own architecture review is enough); anything
  unconsented. The pre-send scan blocks secrets/PII regardless.

## Process
1. **Consent + scope** (per the protocol): confirm the human wants to send THIS
   plan. Optionally offer a this-branch scope grant, never persisted.
2. **Prepare the payload**: the plan file, plus the inherited architecture context
   it depends on (paste it in, do not make the vendor guess).
3. **Resolve the vendor and announce the model as a QUESTION**: the vendor is an
   argument (default from the protocol's matrix); state the model and let the
   human confirm, pick another, or stop.
4. **Run the wrapper**: `second-opinion.sh plan <payload-file> [--vendor NAME]
   [--model ID]` (on PATH through the Odeo plugin). It runs `privacy-scan.sh` before sending
   and stops on exit 1; a missing vendor CLI is exit 3 (it never simulates).
5. **Compare, THE WRINKLE for plans:** `architecture-reviewer` returns advice and
   writes NO record (its verdict lives in the plan's `arch_review:` line, written
   by the orchestrator). So dispatch `architecture-reviewer` on the plan, then
   YOU (the orchestrating session) author the second-opinion comparison record
   from the vendor findings + the architecture-reviewer's advice: overlap /
   only-ours / only-vendor + recommendation. The vendor never touches the plan's
   `arch_review:` verdict.
6. **Present and discuss**: show the comparison; a real gap sends the plan back to
   the `architect` for a revision, per the normal plan-review loop.
7. **Offer the absorption loop**: if a vendor-unique finding class recurs, offer
   `/improve` to fold it into OUR architecture-reviewer as a permanent check.

## Worked example
"Second opinion on the sync-engine plan, we cannot re-do this later."
- Payload: `docs/plans/2026-07-19-sync-engine.md` + the inherited architecture note.
- "Send the sync-engine plan to the vendor on its strongest available model? ok /
  pick / stop." The human says ok.
- `second-opinion.sh plan docs/plans/2026-07-19-sync-engine.md`
- The pre-send scan passes; the vendor returns findings; architecture-reviewer
  advises; the orchestrator records: overlap = the retry path can double-write;
  only-vendor = no backpressure when the queue fills; only-ours = a naming drift.
  Recommendation: add backpressure to the plan. The plan's `arch_review:` verdict
  is unchanged; a confirmed gap goes back to the architect.

## Output
- A raw transcript in `docs/second-opinion-logs/` (gitignored) plus a provenance
  stamp (vendor, model, duration, sha256).
- A record `docs/evals/second-opinion-plan-<id>.md` written by the ORCHESTRATOR
  (since architecture-reviewer writes none): structured findings + the comparison;
  no gate `verdict:`, and it uses `related_branch:` (not `branch:`).

## Rules
- Everything consequential is referenced from `${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md`
  and the guardrails, not restated: consent, the pre-send scan, never-simulate,
  provenance, authority (informs, never rules), model picker, cost bounds.
- The vendor is an argument, never part of this skill's name or a command.
