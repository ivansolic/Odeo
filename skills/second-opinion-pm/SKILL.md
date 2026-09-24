---
description: Get a paid, independent SECOND OPINION on a PM document (PRD, user stories, strategy, roadmap, research, or a discovery artifact) from an external vendor model, then have OUR pm-reviewer compare the two reads. Explicit command (data leaves the machine and costs money); run it on a big bet, a sink-it assumption a critique surfaced, multi-epic scope, or a hard-to-reverse decision. Example: "second opinion on PRD-007".
disable-model-invocation: true
---

# Second opinion (PM document)

Get an INDEPENDENT cross-model review of a PM document from an external vendor
CLI, then have OUR `pm-reviewer` compare the vendor's findings against ours. The
vendor INFORMS; our reviewer keeps the verdict. The shared mechanism and rules
live in `${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md` (read it; not restated here).

## When to use (and when not)
- Use on a BIG BET: a critique flagged a sink-it assumption; the scope spans many
  epics; or the decision is hard to reverse. A costly PM mistake is worth a paid
  second read.
- Covers everything `pm-reviewer` judges: PRD, stories, strategy, roadmap,
  research, GTM, and discovery artifacts (personas, opportunity trees, experiments).
- Human-invoked only. Data leaves the machine and it costs money; it never
  self-runs, and a skill offers it once at those triggers, never after a decline.
- Not for: routine or low-stakes docs (our own review is enough); anything you
  have not consented to send. The pre-send scan blocks secrets/PII regardless.

## Process
1. **Consent + scope** (per the protocol): confirm the human wants to send THIS
   document. Optionally offer a this-session scope grant, never persisted.
2. **Prepare the payload**: the document file itself, the smallest artifact that
   answers the question (one PRD, one strategy brief).
3. **Resolve the vendor and announce the model as a QUESTION**: the vendor is an
   argument (default from the protocol's matrix); state the model and let the
   human confirm, pick another, or stop.
4. **Run the wrapper**: `second-opinion.sh pm <payload-file> [--vendor NAME]
   [--model ID]` (on PATH through the Odeo plugin). It runs `privacy-scan.sh` before sending
   and stops on exit 1; a missing vendor CLI is exit 3 (it never simulates).
5. **OUR pm-reviewer authors the comparison**: hand it the vendor's structured
   findings; it writes the second-opinion record (overlap / only-ours /
   only-vendor + recommendation) and NEVER changes its own verdict.
6. **Present and discuss**: show the comparison; decisions stay with the human.
7. **Offer the absorption loop**: if a vendor-unique finding class recurs, offer
   `/improve` to fold it into OUR pm-reviewer as a permanent check.

## Worked example
"Second opinion on PRD-007, this is our whole Q3 bet."
- Payload: `docs/prds/PRD-007-*.md`.
- "Send PRD-007 to the vendor on its strongest available model? ok / pick / stop."
  The human says ok.
- `second-opinion.sh pm docs/prds/PRD-007-password-reset.md`
- The pre-send scan passes; the vendor returns findings; `pm-reviewer` records:
  overlap = the outcome metric has no target; only-vendor = the riskiest
  assumption (adoption) has no experiment; only-ours = a scope nit. Recommendation:
  add the experiment before build. Our PRD verdict is unchanged, in its own record.

## Output
- A raw transcript in `docs/second-opinion-logs/` (gitignored) plus a provenance
  stamp (vendor, model, duration, sha256).
- A record `docs/evals/second-opinion-pm-<id>.md` (format in the eval framework):
  structured findings + the comparison; no gate `verdict:`, and it uses
  `related_branch:` (not `branch:`) so no gate ever picks it up.

## Rules
- Everything consequential is referenced from `${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md`
  and the guardrails, not restated: consent, the pre-send scan, never-simulate,
  provenance, authority (informs, never rules), model picker, cost bounds.
- The vendor is an argument, never part of this skill's name or a command.
