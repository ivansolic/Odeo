---
id: USR-006
title: Warn on prose-language mismatch
prd: PRD-001
order: 6
depends_on: USR-002, USR-005
covers: R7
---

# USR-006: Warn on prose-language mismatch

**Card:** As a PM/builder, I want a warning when generated prose does not match my chosen
language, so that gross misses get caught while legitimate mixed technical terms are not
blocked.

## Acceptance criteria (observable, binary)
- With the effective language German and a generated body whose prose region is detected as
  predominantly (more than half) a language other than German, a warning is shown that names
  the artifact.
- With a correctly German body, no warning is shown.
- The check never hard-fails: its exit stays 0, it only warns.
- A body of German prose that embeds English technical terms (API names, code) does not
  trigger the warning.

**Verification note (this repo):** best-effort language detection over the prose region only
(exclude code blocks and frontmatter); tests with one matching and one mismatching sample.

## INVEST / size
~0.5 to 1 day. Depends on USR-002/005; last (polish).
