---
artifact: code
type: code
branch: feature/superpowers-derived-upgrades
scope: bin/token-report.py + tests/token-report.test.sh + docs/system-map.md (utility-scripts line)
date: 2026-07-19
scorer: code-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 2, conventions: 2 }
total: 12/12
previous_total: 10/12
verdict: APPROVE
---

# Code review: token-report.py (per-agent token/cost reporter)

Test suite: 16/16 green (`bash tests/token-report.test.sh`, exit 0), run this
round. Round 2 re-review; the four round-1 Importants (all one root cause: the
parser trusted that any valid-JSON line was a usage-shaped dict) are fixed and
re-probed clean, so this is now a full pass.

The tool is well shaped: clean small functions, prices strictly from args (HARD
RULE holds, no model name or price baked into logic, re-verified by grep, prices
flow only from argparse `type=float, default=None` into arithmetic), correct
token math on well-formed input, and now a shape-tolerant parser that skips or
zeroes hostile input instead of crashing. The AGENTS.md rule "never expose stack
traces or internals" now holds against every input I could throw at it.

## Critical (must fix before merge)

None.

## Important (should fix)

None. All four round-1 Importants are resolved and re-probed:

- Valid-JSON non-object lines (`[1,2,3]`, `42`, `true`, `null`, `"str"`):
  `parse()` now has `if not isinstance(data, dict): continue` at
  token-report.py:107 immediately after `json.loads`. Probed a file of exactly
  these five line types, exit 1 ("no usage data"), no traceback.
- Non-dict / non-numeric usage: `add_usage` guards `if not isinstance(usage,
  dict): usage = {}` (token-report.py:85), and the new `_int()` helper
  (token-report.py:75-80) coerces every field via `max(0, int(value))` inside
  `except (TypeError, ValueError): return 0`. Probed `"usage": null`,
  `"usage": [1,2]`, `input_tokens: "lots"`, `output_tokens: -100`,
  `cache_read_input_tokens: null`, and a float (`10.9`): all exit 0, counted as
  0 (or truncated for the float), no traceback. This also closes the negative-
  token nitpick for free: `-100` input now yields 5 total, not -95.
- Uncaught file I/O: `main()` wraps `parse()` in `try/except OSError`
  (token-report.py:205-206) routing to `err(...)` (exit 2, `token-report:`
  prefix, `exc.strerror or exc` fallback so a bare OSError with no strerror
  still degrades cleanly). Probed a chmod-000 file: `token-report: cannot read
  d.jsonl: Permission denied`, exit 2, no traceback.
- Test coverage: `tests/token-report.test.sh` gained a hostile fixture
  (JSON array/scalar/bool/null lines, `usage: null`, non-numeric + negative
  tokens) asserting exit 0 AND `expect_missing ... "Traceback"`, plus an
  unreadable-file case asserting exit 2 (correctly skipped when the file stays
  readable, e.g. as root). Suite is 16/16.

## Nitpicks (optional)

- bin/token-report.py:141, the label column pads with `str(label)[:40]:<40`,
  which counts code points, not display width, so CJK/wide-glyph descriptions
  overflow and misalign the table. Cosmetic only; a real fix needs
  `unicodedata.east_asian_width`, not worth it for a personal terminal tool.
  (Carried from round 1, unchanged, still acceptable.)
- bin/token-report.py:119-121, the subagent label is the first 40 chars of the
  raw prompt, printed verbatim. Prompts can carry PII/secrets; this prints only
  to the operator's own terminal (not logged, not shared), so it stays within
  the AGENTS.md privacy posture. Worth a one-line awareness note, no change
  required. (Carried from round 1.)

## Security

Reads files only; no shell invocation, no `eval`, no `subprocess`, no network.
Prices are `type=float` args and flow only into arithmetic. Path handling uses
`pathlib`/`os` without interpolation into any command, so no injection surface.
The round-1 operational note (traceback leakage) is now closed. Clean, 2/2.

## Testing

16/16 green and the harness is well built (hermetic fixtures, exit-code and
substring assertions, temp dirs cleaned up, root-readable case guarded). The
three round-1 crash classes now each have a regression fixture that asserts a
clean exit and no traceback, which is exactly the coverage that was missing.
2/2.

## What's good

Prices are strictly injected, never baked in, and the header comment says why
(tiers live with the human, not the script), which is the whole point of the
tool. `resolve_transcript` cleanly handles file / directory / default-cwd in
one place. The cost model is stated precisely (input + both cache buckets billed
at input price) and applied consistently in `cost()` and the totals line. Exit
codes match the house contract (0 report / 1 no usage data / 2 usage error),
argparse supplies its own exit-2 on bad flags, and the `token-report:` prefix is
used consistently. The round-2 hardening (`_int` + isinstance guards) is the
right shape: one small helper plus two boundary checks, no defensive sprawl, and
the "don't trust parsed JSON shape" root cause is closed in one place rather
than patched per-field. The python3-not-bash exception is the documented one
(JSON without jq) and stays stdlib-only.

## History

- Round 1: APPROVE WITH COMMENTS, 10/12 (correctness 1/2, testing 1/2). Four
  Importants, all one root cause (the parser trusts parsed JSON shape):
  non-object JSON lines, non-dict/non-numeric usage, and uncaught file I/O all
  crashed with a traceback; the test suite had no coverage for any of them. No
  security or convention defects; token math and the no-hardcoded-price hard
  rule verified correct.
- Round 2 (this record): APPROVE, 12/12. All four Importants fixed and
  re-probed clean (`if not isinstance(data, dict): continue`; `_int()` coercion
  with `max(0, ...)`; `add_usage` dict guard; `try/except OSError` in `main`).
  Suite grew 13 -> 16 checks with a hostile-input fixture (no-traceback
  assertion) and an unreadable-file case. Re-probed the exact round-1 crash
  inputs (`[1,2,3]`, `42`, `true`, `null`, `"usage": null`, `usage: [1,2]`,
  non-numeric token, `chmod 000` file): none crash, all exit codes correct, zero
  tracebacks. Regression vs round 1: BETTER (correctness 1 -> 2, testing 1 -> 2;
  the negative-token nitpick closed for free via the clamp). No new findings; two
  cosmetic nitpicks (CJK column width, verbatim prompt label) carried unchanged.
