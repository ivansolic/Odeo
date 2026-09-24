---
description: Get a paid, independent SECOND OPINION on UI (the look and the UI code) from an external MULTIMODAL vendor model, then have OUR design-reviewer compare the two reads. Explicit command (data leaves the machine and costs money); run it on a high-stakes or contested UI, or when a design review scored low. Example: "second opinion on the checkout screen".
disable-model-invocation: true
---

# Second opinion (design)

Get an INDEPENDENT cross-model review of UI from an external MULTIMODAL vendor
CLI, then have OUR `design-reviewer` compare the vendor's findings against ours.
The vendor INFORMS; our reviewer keeps the verdict. The shared mechanism and
rules live in `${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md` (read it; not restated here).

## When to use (and when not)
- Use on a high-stakes or contested UI: a flagship screen, a flow users abandon,
  or a `design-reviewer` score that came in low and you want an outside read.
- Needs a MULTIMODAL vendor (it must read the rendered look, not just the code),
  so the default vendor for this target differs from the code target, per the
  protocol matrix.
- Covers what `design-reviewer` judges: usability, states, accessibility, token
  adherence, microcopy, from the UI code and the rendered look together.
- Human-invoked only. Data leaves the machine and it costs money; it never
  self-runs, offered once at the triggers, never after a decline.
- Not for: backend/logic (that is `second-opinion-code`); anything unconsented.
  The pre-send scan blocks secrets/PII regardless.

## Process
1. **Consent + scope** (per the protocol): confirm the human wants to send THIS
   UI. Optionally offer a this-session scope grant, never persisted.
2. **Prepare the payload**: the UI code plus a rendered view (a screenshot or an
   exported render) so the multimodal vendor can judge the look, not just markup.
   Seed/fake data only, never real user data in a shared screen.
3. **Resolve the vendor and announce the model as a QUESTION**: the vendor is an
   argument (multimodal default from the protocol's matrix); state the model and
   let the human confirm, pick another, or stop.
4. **Run the wrapper**: `second-opinion.sh design <payload-file> [--vendor NAME]
   [--model ID]` (on PATH through the Odeo plugin). It runs `privacy-scan.sh` before sending
   and stops on exit 1; a missing vendor CLI is exit 3 (it never simulates).
5. **OUR design-reviewer authors the comparison**: hand it the vendor's structured
   findings; it writes the second-opinion record (overlap / only-ours /
   only-vendor + recommendation) and NEVER changes its own verdict.
6. **Present and discuss**: show the comparison; the builder verifies before fixing.
7. **Offer the absorption loop**: if a vendor-unique finding class recurs, offer
   `/odeo:improve` to fold it into OUR design-reviewer as a permanent check.

## Worked example
"Second opinion on the checkout screen, conversion is dropping there."
- Payload: the screen's component code plus a screenshot of the rendered state.
- "Send the checkout screen to the vendor on its strongest multimodal model? ok /
  pick / stop." The human says ok.
- `second-opinion.sh design /tmp/checkout-bundle.md`
- The pre-send scan passes; the vendor returns findings; `design-reviewer` records:
  overlap = the primary button lacks a visible focus ring; only-vendor = the error
  state has no recovery affordance; only-ours = a spacing-scale slip. Recommendation:
  fix focus + error recovery. Our UI verdict is unchanged, in its own record.

## Output
- A raw transcript in `docs/second-opinion-logs/` (gitignored) plus a provenance
  stamp (vendor, model, duration, sha256).
- A record `docs/evals/second-opinion-design-<id>.md` (format in the eval
  framework): structured findings + the comparison; no gate `verdict:`, and it
  uses `related_branch:` (not `branch:`) so no gate ever picks it up.

## Rules
- Everything consequential is referenced from `${CLAUDE_PLUGIN_ROOT}/docs/second-opinion-protocol.md`
  and the guardrails, not restated: consent, the pre-send scan (fake data only in
  a shared screen), never-simulate, provenance, authority (informs, never rules),
  model picker, cost bounds.
- The vendor is an argument, never part of this skill's name or a command.
