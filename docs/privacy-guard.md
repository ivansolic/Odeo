# Design: Automated privacy guard

## Outcome
A user cannot accidentally publish private data through this system, even when the
model's sanitization misses something. A deterministic scan catches it and forces
redaction (or an explicit per-item override) before anything leaves the machine.
Protects every user, not just the author.

## Why deterministic, not just the model
`/contribute-lesson` (the outward path to the public community knowledge repo)
relies on the model to sanitize plus the user's manual approval. Models can miss.
A regex/deny-list scan is predictable and testable: the safety net under the
model's judgment. Defense in depth: model generalizes, deterministic scan blocks
leaks, human approves.

## Components
- **`bin/privacy-scan.sh`**, a standalone scanner. Reads a file or stdin, scans for
  the categories below, prints findings, exits non-zero on any hit. No model
  involved; pure pattern matching, so it is deterministic and unit-testable.
- **`tests/privacy-scan.test.sh`**, the test suite (clean passes; each leak class
  blocks; allowlist and deny-list behavior).
- **Wiring in `/contribute-lesson`**, after the model sanitizes the draft, run the
  scanner on it before opening the PR. On a hit: block, show findings, require
  redaction or an explicit per-item override, then re-scan, then approve.
- **A user deny-list**, `~/.claude/privacy-denylist.txt` (gitignored by living in
  `~/.claude`, never in a repo). Each user seeds their own private terms (employer,
  internal product/tool names). Create it yourself when you need it; a missing file just means no extra terms.

## What it scans for
- Emails (`name@domain.tld`), with an allowlist for GitHub noreply addresses.
- Secrets: private-key headers, `API_KEY=/SECRET=/TOKEN=/PASSWORD=` style
  assignments, and known token prefixes (`ghp_`, `sk-`, `xoxb-`, `AKIA...`, etc.).
- Absolute local paths exposing a username (`/Users/<name>/`, `/home/<name>/`).
- IPv4 addresses.
- Every term in the user's deny-list (case-insensitive, literal).

## Behavior (decided)
- **Block, not warn.** A hit stops the flow.
- **Per-item override**, the user can explicitly confirm a specific finding is a
  generic example, not real data, and proceed. Override is a human decision in the
  command flow, not something the script grants.
- Nothing is published until the scan is clear (or overridden) and the user approves.

## Limits (stated honestly)
Regex cannot catch everything: paraphrased secrets, novel token formats,
context-dependent PII. This is a strong net, not a guarantee. The model
sanitization and human approval remain part of the flow. The guard deliberately
errs toward over-flagging (false positives are cheap given the override).

## Exit codes (`privacy-scan.sh`)
- `0`, clean.
- `1`, findings (BLOCK).
- `2`, usage error (e.g. file not found).
