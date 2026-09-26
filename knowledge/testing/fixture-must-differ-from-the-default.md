---
module: tests for file writers (bin/set-global-language.sh atomic rewrite)
tags: [mutation-testing, fixture, file-mode, mktemp, masked-mutant, permissions]
problem_type: pattern
provenance: atomic overwrite in set-global-language.sh (code review round 1 nitpick)
reuse_count: 0
created: 2026-09-26
---

# A fixture must differ from what the broken code would produce anyway

## Context
Testing that an atomic rewrite (mktemp beside the file, cp -p, mv) keeps the file mode.
The fixture used mode 600, and the test passed even with `cp -p` removed.

## Guidance
mktemp creates files as 600. A fixture at 600 cannot tell "mode kept" from "mode lost", so
the mutant survived. Use 644. General rule: pick a fixture value the DEFAULT or broken path
cannot produce by accident, and prove it with the mutation (remove the mechanism, watch
the case go red) before calling the test a guard.

## When to apply
Any test of preserved metadata (mode, owner, mtime, encoding, line endings), and generally
any assertion whose expected value equals the system's default.
