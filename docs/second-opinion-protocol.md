# Second-opinion protocol

The ONE shared contract every `second-opinion-*` skill references (and never
restates). A second opinion is a PAID cross-model review: an external vendor CLI
reviews one artifact, and OUR matching reviewer authors the comparison. It is a
consult, not a gate.

## Authority (the line that never moves)
The vendor's findings INFORM; they never rule. OUR matching reviewer keeps its
verdict, and the `merge-gate` reads only OUR reviewer's record. A second opinion
can change what a human decides; it cannot change a gate.

## The mechanism: `bin/second-opinion.sh`
The ONLY sanctioned path to a vendor (on PATH through the Odeo plugin). It runs the vendor
CLI non-interactively and READ-ONLY over one payload file, and it:
- refuses to send until `privacy-scan.sh` passes over the payload (fail-closed);
- never simulates: a missing or broken vendor CLI stops the run (exit 3);
- captures the raw transcript to `docs/second-opinion-logs/` (gitignored) and
  stamps provenance (vendor, CLI version, actual model, duration, sha256, time);
- exit codes: 0 ok, 1 privacy-scan blocked, 2 usage/setup, 3 vendor missing or
  unauthenticated or failed, 124 timed out.
Skills call the script; they do not re-implement any of it.

## Consent (before anything leaves the machine)
- **Human-invoked only.** Data leaves the machine and it costs money, so a human
  starts every send. Consent is per-invocation by default.
- An optional scope grant (this session, or this branch) may be offered, never
  persisted, never global.
- `privacy-scan.sh` runs before EVERY send regardless of any grant (the script
  enforces this). On a repeat send of the same artifact, show the human the delta
  since the last send.

## Model picker
- Default: the vendor's strongest model AVAILABLE on the user's subscription,
  resolved live and ANNOUNCED as a question ("send to <vendor> on <model>? ok /
  pick another / stop"). The user stops or overrides in one line.
- Full picker only on demand: fetch the vendor's current model list with its own
  tier/variant structure at call time, never baked into files.
- Record what ACTUALLY ran (`vendor_model:`). Symmetric on every host: picking a
  Claude model from another vendor's CLI works the same way.

## When a skill may OFFER it
Human-invoked only; a skill may OFFER at most once, at a named trigger, always
stating the reason, and never again after a decline. Triggers:
- **Risky review:** the change touches auth, payments, uploads, or data-access
  paths; or a review scored the security dimension below 2; or a finding is
  contested; or the review loop hit 2+ REQUEST-CHANGES cycles.
- **Big bet:** a critique flagged a sink-it assumption; multi-epic scope; or a
  hard-to-reverse decision.

## The comparison flow
1. The skill runs `second-opinion.sh` on the artifact (read-only; adversarial
   framing available for security-shaped reviews).
2. OUR matching reviewer (the SAME domain reviewer, not the main session, not a
   new agent) receives the vendor findings and authors the comparison in the
   record: **overlap** (both found it) / **only-ours** / **only-vendor** + a
   recommendation. The vendor never touches our verdict.
3. The main session presents the comparison and discusses next steps; the builder
   verifies before fixing, as with any review.
- **Adversarial mode is READ-ONLY:** the vendor reasons about HOW the artifact
  fails (file:line); it never edits or executes. When a finding needs proof, OUR
  builder writes the failing test in OUR worktree.
- **Reviewer asymmetry:** `code-reviewer`, `pm-reviewer`, and `design-reviewer`
  write their own records, so they author the comparison directly. The
  `architecture-reviewer` writes no record (it returns advice; the orchestrator
  records `arch_review:`), so for a plan target the orchestrating skill writes the
  comparison record instead.

## The record
Fits the eval-record family (see `docs/eval-framework.md`), stored at
`docs/evals/second-opinion-<target>-<id>.md`. It adds `vendor_model:`, `raw_log:`,
and `output_sha256:`; carries STRUCTURED findings (target, class, file:line,
severity, who-found); and a comparison body. It NEVER carries a gate `verdict:`,
it informs, and OUR reviewer's own record still holds the verdict.

## Absorption loop (every paid opinion upgrades the first)
When a vendor-unique finding CLASS recurs across records, `/odeo:improve` proposes it
as a permanent check in OUR matching reviewer, A/B tests old vs new, and the human
keeps or reverts. Structured findings from day one make this mineable, so a paid
review is never a one-off: it compounds into our free reviewers.

## Cost bounds
A review is a bounded job (one artifact or one diff). The review loop is capped at
3 cycles. Expensive classes (both vendors, repeat sends) declare a budget upfront,
and the user can downgrade the tier by explicit override at any time. The account's
own spend limit is the hard external wall; run state lives in files, so work
resumes cleanly after a reset.

## Vendor is an argument, never a name
No `codex-*` / `gemini-*` skill or command family exists (lint C10). Per-vendor CLI
differences live only inside `bin/second-opinion.sh`. Vendor names are legal only
in records (`vendor_model:`) and spoken at send time, never in a file or command
name.
