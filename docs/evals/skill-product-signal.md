---
artifact: product-signal
type: skill
branch: feature/product-signal-gather
artifact_version: 2
date: 2026-07-20
scorer: skill-reviewer
model: claude-opus-4-8[1m]
model_tier: strongest
scores: { trigger_clarity: 2, structure: 2, worked_example: 2, precision: 2, safety_integration: 2 }
total: 10/10
verdict: PASS
---

## Skill: product-signal (explicit command, disable-model-invocation: true)

## Scores
- trigger clarity: 2, "Weekly product-signal memo, gathers your users' feedback ... Run about weekly; a nudge reminds you." Explicit-command form: plain what-you-get + when to run, third person, no workflow-in-description leakage that would matter for an auto-invoked skill. Correct format for its type.
- structure: 2, Follows the body shape (essence -> when to use -> numbered process -> memo shape example -> rules). 56 lines, single file, no supporting refs (one-level rule trivially satisfied).
- worked example: 2, "1. <theme>  , 14 mentions (up from 6)  TREND: growing / \"quote\" · \"quote\"    -> suggests: <one line>" plus concrete path `docs/signals/2026-07-14.md`. Directly imitable memo shape with real values.
- precision: 2, The edited step 1 is now prescriptive, not vague: "pull the items in THIS window (since the last memo's date, else the last ~7 days), capped (say the ~100 most recent per source), and only the fields the memo uses, the text, the date, the source, and any severity/frequency signal." Named window, named cap, named field allowlist, named save path `docs/signals/<YYYY-MM-DD>.md`. No TBDs.
- safety integration: 2, "**Never invent or estimate feedback.**" and "A source is missing or empty? Note it and continue with what exists." plus "Real data only; missing sources are named, never filled in." The scope-tightening edit stays inside read-only gathering (it narrows what is read, never adds writes or fabrication) and references the honesty rules rather than restating a guardrail as new law.

## Total: 10/10   ## Verdict: PASS (threshold 8/10, no zero)

## History
- v2 (2026-07-20): step 1 tightened from "Gather from REAL sources only" to add explicit scope bounds (this-window, ~7 day fallback, ~100/source cap, field allowlist). First eval record for this skill (no prior record on this branch). Edit is consistent with the rest of the skill: still real-only, still names missing sources, still "Never invent or estimate feedback." No contradiction with the read-only gathering safety rule, the change constrains the read surface, it does not broaden capability. All five criteria at 2.

## Notes
- System-map duty satisfied: `/product-signal` is present in docs/system-map.md (line 104) with the weekly mark.
- The step-1 change is a wording/scope tightening, not a behavioral guardrail change; form is clean. If the intent is to prove the connector actually honors the window/cap at runtime, that is /improve subagent-test territory, not this review.
