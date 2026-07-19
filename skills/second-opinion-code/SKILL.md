---
description: Get a paid, independent SECOND OPINION on a code diff from an external vendor model, then have OUR code-reviewer compare the two reads. Explicit command (data leaves the machine and costs money); run it when a diff is risky, auth/payments/uploads/data-access, a security concern, a contested finding, or repeated REQUEST-CHANGES, and you want a cross-model check. Example: "second opinion on this branch's diff".
disable-model-invocation: true
---

# Second opinion (code)

Get an INDEPENDENT cross-model review of a code diff from an external vendor CLI,
then have OUR `code-reviewer` compare the vendor's findings against ours. The
vendor INFORMS; our reviewer keeps the verdict. The shared mechanism and rules
live in `docs/second-opinion-protocol.md` (read it; not restated here).

## When to use (and when not)
- Use when a diff earns a paid, independent read: it touches auth, payments,
  uploads, or data-access; a review scored security below 2; a finding is
  contested; or the review loop hit 2+ REQUEST-CHANGES cycles.
- Human-invoked only. Data leaves the machine and it costs money, so it never
  self-runs; a skill may offer it once at those triggers, never after a decline.
- Not for: routine low-risk diffs (our own review is enough); anything you have
  not consented to send. Secrets/PII are blocked by the pre-send scan regardless.
- Plan, doc, and design targets use their own second-opinion skill, not this one.

## Process
1. **Consent + scope** (per the protocol): confirm the human wants to send THIS
   diff. Optionally offer a this-branch/this-session scope grant, never persisted.
2. **Prepare the payload**: write the exact diff to a file, the smallest artifact
   that answers the question (for a branch, `git diff main... > <file>`).
3. **Resolve the vendor and announce the model as a QUESTION**: the vendor is an
   argument (default from the protocol's matrix); state the model it will run on
   and let the human confirm, pick another, or stop.
4. **Run the wrapper**: `second-opinion.sh code <payload-file> [--vendor NAME]
   [--model ID] [--mode review|adversarial]` (in `~/bin` or `bin/`). It runs
   `privacy-scan.sh` before sending and stops on exit 1; a missing vendor CLI is
   exit 3 (it never simulates). Use `--mode adversarial` for security-shaped reads.
5. **OUR code-reviewer authors the comparison**: hand it the vendor's structured
   findings; it writes the second-opinion record (overlap / only-ours /
   only-vendor + recommendation) and NEVER changes its own verdict.
6. **Present and discuss**: show the comparison; the builder verifies a finding
   before fixing it, as with any review.
7. **Offer the absorption loop**: if a vendor-unique finding class recurs, offer
   `/improve` to fold it into OUR code-reviewer as a permanent check.

## Worked example
"Give me a second opinion on this auth change."
- `git diff main... > /tmp/auth.diff` (the change touches login, a risky path).
- "Send /tmp/auth.diff to the vendor on its strongest available model? ok / pick
  another / stop." The human says ok.
- `second-opinion.sh code /tmp/auth.diff --mode adversarial`
- The pre-send scan passes; the vendor returns findings; `code-reviewer` records:
  overlap = a missing rate-limit; only-vendor = a session-fixation risk we missed;
  only-ours = a naming nit. Recommendation: fix the session-fixation (verify
  first). The merge verdict is unchanged and lives in its own review record.

## Output
- A raw transcript in `docs/second-opinion-logs/` (gitignored) plus a provenance
  stamp (vendor, model, duration, sha256).
- A record `docs/evals/second-opinion-code-<id>.md` (format in the eval
  framework): structured findings + the comparison; no gate `verdict:`, and it
  uses `related_branch:` (not `branch:`) so the merge-gate never picks it up.

## Rules
- Everything consequential is referenced from `docs/second-opinion-protocol.md`
  and the guardrails, not restated: consent, the pre-send scan, never-simulate,
  provenance, authority (informs, never rules), model picker, cost bounds.
- The vendor is an argument, never part of this skill's name or a command.
